--------------------------------------------------------
--  DDL for Package Body OZF_FUNDRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUNDRULES_PVT" AS
/* $Header: ozfvfrub.pls 120.5.12010000.2 2009/05/13 11:57:50 nepanda ship $ */
   g_pkg_name    CONSTANT VARCHAR2(30) := 'Ozf_FundRules_PVT';
   g_file_name   CONSTANT VARCHAR2(30) := 'ozfvfrub.pls';
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


---------------------------------------------------------------------
-- PROCEDURE
--    check_product_eligibility_exists
--
-- PURPOSE
--    check_product_eligibility_exists
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--    11/11/2002  Srinivasa Rudravarapu Modified Process_Offers Method.
-- NOTES
---------------------------------------------------------------------

PROCEDURE check_product_elig_exists(
      p_fund_id         IN       NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      l_dummy   VARCHAR2(3);

      -- CURSOR for  product eligibility
      CURSOR c_product_elig IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS( SELECT 1
                          FROM ams_act_products
                         WHERE act_product_used_by_id = p_fund_id AND arc_act_product_used_by = 'FUND');
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      -- Fetch the cursor
      OPEN c_product_elig;
      FETCH c_product_elig INTO l_dummy;
      CLOSE c_product_elig;

      IF l_dummy IS NULL THEN
         ozf_utility_pvt.error_message('OZF_ACCRUAL_NO_PROD');
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END check_product_elig_exists;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_amount_vs_parent
--
-- PURPOSE
--    Check fund amount against its parent.
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--    09/04/2001  Mumu Pande  Updated for different currency child
-- NOTES
---------------------------------------------------------------------
  PROCEDURE check_fund_amount_vs_parent(
      p_parent_id         IN       NUMBER,
      p_child_curr        IN       VARCHAR2,
      p_original_budget   IN       NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2) IS
      -- CURSOR for parent budget amounts
      CURSOR c_parent_amount IS
         SELECT original_budget,
                transfered_in_amt,
                transfered_out_amt,
                currency_code_tc
           FROM ozf_funds_all_vl
          WHERE fund_id = p_parent_id;

      CURSOR c_parent_type IS
         SELECT fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_parent_id;

      l_parent_fund_type   VARCHAR2(30);
      l_par_original_budget    NUMBER;
      l_par_trans_in_budget    NUMBER;
      l_par_trans_out_budget   NUMBER;
      l_par_curr_code          VARCHAR2(30);
      l_coverted_orig_budget   NUMBER;
      l_rate                   NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_parent_id IS NULL THEN
         RETURN;
      END IF;

      -- Fetch the parent fund amounts
      OPEN c_parent_amount;
      FETCH c_parent_amount INTO l_par_original_budget,
                                 l_par_trans_in_budget,
                                 l_par_trans_out_budget,
                                 l_par_curr_code;
      CLOSE c_parent_amount;

      OPEN c_parent_type;
      FETCH c_parent_type INTO l_parent_fund_type;
      CLOSE c_parent_type;

      IF l_par_curr_code = p_child_curr THEN
         l_coverted_orig_budget := p_original_budget;
      ELSE
         ozf_utility_pvt.convert_currency(
            x_return_status=> x_return_status,
            p_from_currency=> p_child_curr,
            p_to_currency=> l_par_curr_code,
            p_from_amount=> p_original_budget,
            x_to_amount=> l_coverted_orig_budget,
            x_rate=> l_rate);
      END IF;

      IF NVL(l_coverted_orig_budget, 0) >
              (NVL(l_par_original_budget, 0)  +
               NVL(l_par_trans_in_budget, 0)  -
               NVL(l_par_trans_out_budget, 0)) THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         IF l_parent_fund_type = 'QUOTA' THEN
             fnd_message.set_name('OZF', 'OZF_CHILD_EXCESS_QUOTA');
         ELSE
             fnd_message.set_name('OZF', 'OZF_CHILD_EXCESS_BUDGET');
         END IF;
         fnd_msg_pub.ADD;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END check_fund_amount_vs_parent;



---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_type_vs_parent
--
-- PURPOSE
--    Check fund type against its parent.
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--
-- NOTES
---------------------------------------------------------------------
   PROCEDURE check_fund_type_vs_parent(
      p_parent_id       IN       NUMBER,
      p_fund_type       IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      -- CURSOR for parent fund type
      CURSOR c_parent_type IS
         SELECT fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_parent_id;

      l_parent_fund_type   VARCHAR2(30);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_parent_id IS NULL THEN
         RETURN;
      END IF;

      -- Fetch the parent fund amounts
      OPEN c_parent_type;
      FETCH c_parent_type INTO l_parent_fund_type;
      CLOSE c_parent_type;

     IF p_fund_type <> l_parent_fund_type THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            IF p_fund_type = 'QUOTA' THEN
              fnd_message.set_name('OZF', 'OZF_TP_CHILD_WRONG_QUOTA_TYPE');
            ELSE
              fnd_message.set_name('OZF', 'OZF_CHILD_WRONG_FUND_TYPE');
            END IF;
            fnd_msg_pub.ADD;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END check_fund_type_vs_parent;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_status_vs_parent
--
-- PURPOSE
--    Check fund status(active,draft) against its parent.
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--
-- NOTES
---------------------------------------------------------------------
  PROCEDURE check_fund_status_vs_parent(
      p_parent_id       IN       NUMBER,
      p_status_code     IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      -- CURSOR for parent status
      CURSOR c_parent_status IS
         SELECT status_code, fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_parent_id;

      l_parent_fund_status   VARCHAR2(30);
      l_parent_fund_type     VARCHAR2(30);

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;


      IF p_parent_id IS NULL THEN
         RETURN;
      END IF;

      -- Fetch the parent fund status
      OPEN c_parent_status;
      FETCH c_parent_status INTO l_parent_fund_status, l_parent_fund_type;
      CLOSE c_parent_status;

      IF p_status_code = 'ACTIVE' THEN
         -- Check parent fund status
         IF l_parent_fund_status <> 'ACTIVE' THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               IF l_parent_fund_type = 'QUOTA' THEN
                 fnd_message.set_name('OZF', 'OZF_TP_ACTIVATE_QUOTA_PARENT');
               ELSE
                 fnd_message.set_name('OZF', 'OZF_ACTIVATE_FUND_PARENT');
               END IF;
               fnd_msg_pub.ADD;
            END IF;

            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      ELSIF p_status_code = 'ON_HOLD' THEN
         -- Check parent fund status
         IF l_parent_fund_status NOT IN ('ON_HOLD', 'ACTIVE') THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               IF l_parent_fund_type = 'QUOTA' THEN
                 fnd_message.set_name('OZF', 'OZF_TP_ACTIVATE_QUOTA_PARENT');
               ELSE
                 fnd_message.set_name('OZF', 'OZF_ACTIVATE_FUND_PARENT');
               END IF;
               fnd_msg_pub.ADD;
            END IF;

            x_return_status := fnd_api.g_ret_sts_error;
         END IF; --status_code
      END IF;
   END check_fund_status_vs_parent;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_dates_vs_parent
--
-- PURPOSE
--    Check fund dates against its parent.
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--
-- NOTES
---------------------------------------------------------------------
   PROCEDURE check_fund_dates_vs_parent(
      p_parent_id           IN       NUMBER,
      p_start_date_active   IN       DATE,
      p_end_date_active     IN       DATE,
      x_return_status       OUT NOCOPY      VARCHAR2) IS
      -- CURSOR for parent dates
      CURSOR c_parent_dates IS
         SELECT start_date_active,
                end_date_active
           FROM ozf_funds_all_vl
          WHERE fund_id = p_parent_id;

      l_parent_start_date   DATE;
      l_parent_end_date     DATE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_parent_id IS NULL THEN
         RETURN;
      END IF;

      -- Fetch the parent fund status
      OPEN c_parent_dates;
      FETCH c_parent_dates INTO l_parent_start_date, l_parent_end_date;
      CLOSE c_parent_dates;

      --Check validity of child fund's effectivity dates w.r.t. the parent fund
      IF    p_start_date_active < l_parent_start_date
         OR p_end_date_active > l_parent_end_date THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_CHILD_ILLEGAL_DATE');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END check_fund_dates_vs_parent;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_curr_vs_parent
--
-- PURPOSE
--    Check fund curr against its parent.
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--
-- NOTES
---------------------------------------------------------------------
   PROCEDURE check_fund_curr_vs_parent(
      p_parent_id       IN       NUMBER,
      p_fund_curr       IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      -- CURSOR for parent fund type
      CURSOR c_parent_curr IS
         SELECT currency_code_tc
           FROM ozf_funds_all_vl
          WHERE fund_id = p_parent_id;

      l_parent_fund_curr   VARCHAR2(30);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_parent_id IS NULL THEN
         RETURN;
      END IF;

      -- Fetch the parent fund amounts
      OPEN c_parent_curr;
      FETCH c_parent_curr INTO l_parent_fund_curr;
      CLOSE c_parent_curr;

      IF p_fund_curr <> l_parent_fund_curr THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_CHILD_ILLEGAL_CURRENCY');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END check_fund_curr_vs_parent;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_amount_vs_child
--
-- HISTORY
--    07/28/2000  mpande  Created.
--    09/04/2001  Mumu Pande  Updated for different currency child
---------------------------------------------------------------------
    PROCEDURE check_fund_amount_vs_child(
      p_fund_id                IN       NUMBER,
      p_fund_org_amount        IN       NUMBER,
      p_fund_tran_in_amount    IN       NUMBER,
      p_fund_tran_out_amount   IN       NUMBER,
      p_parent_currency        IN       VARCHAR2,
      x_return_status          OUT NOCOPY      VARCHAR2) IS
      l_api_name      CONSTANT VARCHAR2(30) := 'check_amount_type_vs_child';
      l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||
                                               '.'        ||
                                               l_api_name;
      l_org_budget             NUMBER;
      l_par_total_budget       NUMBER;
      l_coverted_orig_budget   NUMBER;
      l_rate                   NUMBER;

      CURSOR c_sub_fund IS
         SELECT short_name AS short_name,
                original_budget AS original_budget,
                currency_code_tc AS currency_code
        FROM ozf_funds_all_vl
          WHERE parent_fund_id = p_fund_id;

      CURSOR c_parent_type IS
         SELECT fund_type
           FROM ozf_funds_all_vl
          WHERE fund_id = p_fund_id;

      l_parent_fund_type   VARCHAR2(30);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_fund_id IS NULL THEN
         RETURN;
      END IF;

      OPEN c_parent_type;
      FETCH c_parent_type INTO l_parent_fund_type;
      CLOSE c_parent_type;

      l_org_budget := 0;
      l_par_total_budget := NVL(p_fund_org_amount, 0)      +
                            NVL(p_fund_tran_in_amount, 0)  -
                            NVL(p_fund_tran_out_amount, 0);
      FOR l_sub_rec IN c_sub_fund
      LOOP
         IF l_sub_rec.currency_code = p_parent_currency THEN
            l_coverted_orig_budget := l_sub_rec.original_budget;
         ELSE
            ozf_utility_pvt.convert_currency(
               x_return_status=> x_return_status,
               p_from_currency=> l_sub_rec.currency_code,
               p_to_currency=> p_parent_currency,
               p_from_amount=> l_sub_rec.original_budget,
               x_to_amount=> l_coverted_orig_budget,
               x_rate=> l_rate);
         END IF;

         --- fund amount of the parent cannot be less than the planned  added child funds
         l_org_budget := NVL(l_coverted_orig_budget, 0) +
                         NVL(l_org_budget, 0);

         IF (l_par_total_budget < NVL(l_org_budget, 0)) THEN
         IF l_parent_fund_type = 'QUOTA' THEN
               ozf_utility_pvt.error_message(
               'OZF_PAR_QUOTA_LESS_THAN_CHILD',
               'FUND_NAME',
               l_sub_rec.short_name);
         ELSE
               ozf_utility_pvt.error_message(
               'OZF_PAR_BUDGET_LESS_THAN_CHILD',
               'FUND_NAME',
               l_sub_rec.short_name);
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;
   END check_fund_amount_vs_child;

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_dates_vs_child
--
-- HISTORY
--    07/28/2000  mpande  Created.
---------------------------------------------------------------------
  PROCEDURE check_fund_dates_vs_child(
      p_fund_id         IN       NUMBER,
      p_start_date      IN       DATE,
      p_end_date        IN       DATE,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      l_api_name    CONSTANT VARCHAR2(30) := 'check_fund_dates_vs_child';
      l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||
                                             '.'        ||
                                             l_api_name;

      CURSOR c_sub_fund IS
         SELECT short_name AS short_name,
                start_date_active AS start_date,
                end_date_active AS end_date,
                fund_type AS fund_type
           FROM ozf_funds_all_vl
          WHERE parent_fund_id = p_fund_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_fund_id IS NULL THEN
         RETURN;
      END IF;

      FOR l_sub_rec IN c_sub_fund
      LOOP
         IF p_start_date > l_sub_rec.start_date THEN
            x_return_status := fnd_api.g_ret_sts_error;
            IF l_sub_rec.fund_type = 'QUOTA' THEN
               ozf_utility_pvt.error_message('OZF_TP_START_AFT_SUB_START', 'FUND_NAME', l_sub_rec.short_name);
            ELSE
               ozf_utility_pvt.error_message('OZF_FUND_START_AFT_SUB_START', 'FUND_NAME', l_sub_rec.short_name);
            END IF;
        ELSIF p_start_date > l_sub_rec.end_date THEN
            x_return_status := fnd_api.g_ret_sts_error;
            IF l_sub_rec.fund_type = 'QUOTA' THEN
               ozf_utility_pvt.error_message('OZF_TP_START_AFT_SUB_END', 'FUND_NAME', l_sub_rec.short_name);
            ELSE
               ozf_utility_pvt.error_message('OZF_FUND_START_AFT_SUB_END', 'FUND_NAME', l_sub_rec.short_name);
            END IF;
       END IF;

         IF p_end_date < l_sub_rec.end_date THEN
            x_return_status := fnd_api.g_ret_sts_error;
            IF l_sub_rec.fund_type = 'QUOTA' THEN
               ozf_utility_pvt.error_message('OZF_TP_QUOTA_END_BEF_SUB_END', 'FUND_NAME', l_sub_rec.short_name);
            ELSE
               ozf_utility_pvt.error_message('OZF_FUND_END_BEF_SUB_END', 'FUND_NAME', l_sub_rec.short_name);
            END IF;
         ELSIF p_end_date < l_sub_rec.start_date THEN
            x_return_status := fnd_api.g_ret_sts_error;
            IF l_sub_rec.fund_type = 'QUOTA' THEN
               ozf_utility_pvt.error_message('OZF_TP_END_BEF_SUB_START', 'FUND_NAME', l_sub_rec.short_name);
            ELSE
               ozf_utility_pvt.error_message('OZF_FUND_END_BEF_SUB_START', 'FUND_NAME', l_sub_rec.short_name);
            END IF;
         END IF;
      END LOOP;
   END check_fund_dates_vs_child;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_types_vs_child
--
-- HISTORY
--    07/28/2000  mpande  Created.
---------------------------------------------------------------------
   PROCEDURE check_fund_type_vs_child(
      p_fund_id         IN       NUMBER,
      p_fund_type       IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      l_api_name    CONSTANT VARCHAR2(30) := 'check_fund_type_vs_child';
      l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||
                                             '.'        ||
                                             l_api_name;

      CURSOR c_sub_fund IS
         SELECT short_name AS short_name,
                fund_type AS fund_type
           FROM ozf_funds_all_vl
          WHERE parent_fund_id = p_fund_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_fund_id IS NULL THEN
         RETURN;
      END IF;

      FOR l_sub_rec IN c_sub_fund
      LOOP
         --- fund type of the parent and child fund should be the same
         IF p_fund_type <> l_sub_rec.fund_type THEN
           IF l_sub_rec.fund_type = 'QUOTA' THEN
              ozf_utility_pvt.error_message('OZF_TP_PAR_MISMATCH_CHILD_TYPE', 'FUND_NAME', l_sub_rec.short_name);
           ELSE
               ozf_utility_pvt.error_message('OZF_PAR_MISMATCH_CHILD_TYPE', 'FUND_NAME', l_sub_rec.short_name);
           END IF;
           x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;
   END check_fund_type_vs_child;


---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_curr_vs_child
--
-- HISTORY
--    07/28/2000  mpande  Created.
---------------------------------------------------------------------
   PROCEDURE check_fund_curr_vs_child(
      p_fund_id         IN       NUMBER,
      p_fund_curr       IN       VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      l_api_name    CONSTANT VARCHAR2(30) := 'check_fund_curr_vs_child';
      l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||
                                             '.'        ||
                                             l_api_name;

      CURSOR c_sub_fund IS
         SELECT short_name AS short_name,
                currency_code_tc AS fund_curr,
		fund_type AS fund_type
           FROM ozf_funds_all_vl
          WHERE parent_fund_id = p_fund_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_fund_id IS NULL THEN
         RETURN;
      END IF;

      FOR l_sub_rec IN c_sub_fund
      LOOP
         --- fund curr of the parent and child fund should be the same
         IF p_fund_curr <> l_sub_rec.fund_curr THEN
            IF l_sub_rec.fund_type = 'QUOTA' THEN
               ozf_utility_pvt.error_message('OZF_TP_PAR_MISMATCH_CHILD_CURR', 'FUND_NAME', l_sub_rec.short_name);
            ELSE
                ozf_utility_pvt.error_message('OZF_PAR_MISMATCH_CHILD_CURR', 'FUND_NAME', l_sub_rec.short_name);
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END LOOP;
   END check_fund_curr_vs_child;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_fund_calendar
--
-- HISTORY
--    01/28/2001  mpande  Created.
-----------------------------------------------------------------------
   PROCEDURE check_fund_calendar(
      p_fund_calendar       IN       VARCHAR2,
      p_start_period_name   IN       VARCHAR2,
      p_end_period_name     IN       VARCHAR2,
      p_start_date          IN       DATE,
      p_end_date            IN       DATE,
      p_fund_type           IN       VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2) IS
      l_start_start   DATE;
      l_start_end     DATE;
      l_end_start     DATE;
      l_end_end       DATE;
      l_local         NUMBER;

      CURSOR c_fund_calendar IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS( SELECT 1
                          FROM gl_periods_v
                         WHERE period_set_name = p_fund_calendar);

      CURSOR c_start_period IS
         SELECT start_date,
                end_date
           FROM gl_periods_v
          WHERE period_set_name = p_fund_calendar AND period_name = p_start_period_name;

      CURSOR c_end_period IS
         SELECT start_date,
                end_date
           FROM gl_periods_v
          WHERE period_set_name = p_fund_calendar AND period_name = p_end_period_name;

      CURSOR c_start_period_quota IS
          SELECT START_DATE, END_DATE FROM OZF_TIME_ENT_PERIOD
          WHERE NAME = p_start_period_name
          UNION ALL
          SELECT START_DATE, END_DATE FROM OZF_TIME_ENT_QTR
          WHERE NAME = p_start_period_name
          UNION ALL
          SELECT START_DATE, END_DATE FROM OZF_TIME_ENT_YEAR
          WHERE NAME = p_start_period_name;

      CURSOR c_end_period_quota IS
          SELECT START_DATE, END_DATE FROM OZF_TIME_ENT_PERIOD
          WHERE NAME = p_end_period_name
          UNION ALL
          SELECT START_DATE, END_DATE FROM OZF_TIME_ENT_QTR
          WHERE NAME = p_end_period_name
          UNION ALL
          SELECT START_DATE, END_DATE FROM OZF_TIME_ENT_YEAR
          WHERE NAME = p_end_period_name;


/*
      CURSOR c_start_period_quota IS
          SELECT NAME, START_DATE, END_DATE
          FROM
             (SELECT NAME, START_DATE, END_DATE FROM OZF_TIME_ENT_PERIOD
              UNION ALL
              SELECT NAME, START_DATE, END_DATE FROM OZF_TIME_ENT_QTR
              UNION ALL
              SELECT NAME, START_DATE, END_DATE FROM OZF_TIME_ENT_YEAR
             )
          WHERE NAME = p_start_period_name;

      CURSOR c_end_period_quota IS
          SELECT NAME, START_DATE, END_DATE
          FROM
             (SELECT NAME, START_DATE, END_DATE FROM OZF_TIME_ENT_PERIOD
              UNION ALL
              SELECT NAME, START_DATE, END_DATE FROM OZF_TIME_ENT_QTR
              UNION ALL
              SELECT NAME, START_DATE, END_DATE FROM OZF_TIME_ENT_YEAR
             )
          WHERE NAME = p_end_period_name;
*/

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      -- check if p_fund_calendar is null
      IF  p_fund_calendar IS NULL AND p_start_period_name IS NULL AND p_end_period_name IS NULL THEN
         RETURN;
      ELSIF p_fund_calendar IS NULL THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_FUND_NO_CALENDAR');
         RETURN;
      END IF;

      -- check if p_fund_calendar is valid
      OPEN c_fund_calendar;
      FETCH c_fund_calendar INTO l_local;
      CLOSE c_fund_calendar;

      IF l_local IS NULL THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_FUND_BAD_CALENDAR');
         RETURN;
      END IF;

      -- check p_start_period_name
      IF p_start_period_name IS NOT NULL THEN

         IF p_fund_type = 'QUOTA' THEN
            OPEN c_start_period_quota;
            FETCH c_start_period_quota INTO l_start_start, l_start_end;
            CLOSE c_start_period_quota;
         ELSE
            OPEN c_start_period;
            FETCH c_start_period INTO l_start_start, l_start_end;
            CLOSE c_start_period;
         END IF;

         IF l_start_start IS NULL THEN
            x_return_status := fnd_api.g_ret_sts_error;
            ozf_utility_pvt.error_message('OZF_FUND_BAD_START_PERIOD');
            RETURN;
         ELSIF    p_start_date < l_start_start
               OR p_start_date > l_start_end THEN
            x_return_status := fnd_api.g_ret_sts_error;
            IF p_fund_type = 'QUOTA' THEN
                ozf_utility_pvt.error_message('OZF_TP_QUOTA_OUT_START_PERIOD');
            ELSE
                ozf_utility_pvt.error_message('OZF_FUND_OUT_START_PERIOD');
            END IF;
            RETURN;
         END IF;
      END IF;

      -- check p_end_period_name
      IF p_end_period_name IS NOT NULL THEN
         IF p_fund_type = 'QUOTA' THEN
            OPEN c_end_period_quota;
            FETCH c_end_period_quota INTO l_end_start, l_end_end;
            CLOSE c_end_period_quota;
         ELSE
            OPEN c_end_period;
            FETCH c_end_period INTO l_end_start, l_end_end;
            CLOSE c_end_period;
         END IF;

         IF l_end_end IS NULL THEN
            x_return_status := fnd_api.g_ret_sts_error;
            ozf_utility_pvt.error_message('OZF_FUND_BAD_END_PERIOD');
            RETURN;
         ELSIF    TRUNC(p_end_date) <  TRUNC(l_end_start)
               OR  TRUNC(p_end_date) >  TRUNC(l_end_end) THEN
            x_return_status := fnd_api.g_ret_sts_error;
             IF p_fund_type = 'QUOTA' THEN
                ozf_utility_pvt.error_message('OZF_TP_QUOTA_OUT_END_PERIOD');
            ELSE
                ozf_utility_pvt.error_message('OZF_FUND_OUT_END_PERIOD');
            END IF;
            RETURN;
         END IF;
      END IF;

      -- compare the start date and the end date
      IF  TRUNC(l_start_start) >  TRUNC(l_end_end) THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_FUND_BAD_PERIODS');
      END IF;
   END check_fund_calendar;


---------------------------------------------------------------------
-- PROCEDURE
--       process_offers
--
-- PURPOSE
--    This API does the following transactions
--    1) It creates a offer for a accrual fund and pushes all th eligibility
--   information of the fund to QP
--    2) It also create  =a record in the ozf_Act_budgets APi for the offer and the fund
--Parameters
--      (p_fund_rec      IN OZF_FUNDS_PVT.fund_rec_type ,
--       p_csch_id      IN NUMBER   := NULL,  If a schedule id is passed then the offer
--         would be associated to the schedule else to the fund
--       p_api_version      IN NUMBER,
--       x_msg_count      OUT NUMBER,
--       x_msg_data      OUT VARCHAR2,
--       x_return_status   OUT VARCHAR2 )
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
--    05/30/2001  Mumu Pande  Updated for new offer requirements
--    10/22/2001  Mumu Pande  Updated for accrual offer updation
--    01/12/2001  Mumu Pande  Updated for sales accrual offers
--    10/11/2002  Narasimha Ramu
--                Srinivasa Rudaravarapu Updated process offer for 11.5.9
-- NOTES
---------------------------------------------------------------------
   PROCEDURE process_offers(
      p_fund_rec        IN       ozf_funds_pvt.fund_rec_type,
      p_csch_id         IN       NUMBER := NULL -- this is not used anymore
                                               ,
      p_api_version     IN       NUMBER,
      p_mode            IN       VARCHAR2 := jtf_plsql_api.g_create,
      p_old_fund_status IN       VARCHAR2 := NULL,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2) IS
      l_return_status          VARCHAR2(1)                             := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_api_name      CONSTANT VARCHAR2(30)                            := 'process_offers';
      l_full_name     CONSTANT VARCHAR2(60)                            := g_pkg_name ||
                                                                          '.'        ||
                                                                          l_api_name;
      l_offer_hdr_rec          ozf_offer_pvt.modifier_list_rec_type;

--   l_upd_offer_hdr_rec       ozf_offer_pvt.modifier_list_rec_type;
      l_offer_line_tbl         ozf_offer_pvt.modifier_line_tbl_type;

--   l_offer_qlfr_tbl          ozf_offer_pvt.qualifiers_tbl_type;
--   l_offer_pricing_tbl       ozf_offer_pvt.pricing_attr_tbl_type;
--   l_segments_rec            ams_act_market_segments_pvt.mks_rec_type;
--   l_act_segment_id          NUMBER;
      l_error_location         NUMBER;
      --l_error_entity            VARCHAR2(200);
      --l_error_source            VARCHAR2(10);
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_act_budgets_rec_type   ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_budget_id          NUMBER;
      i                        NUMBER                                  := 1;
      j                        NUMBER                                  := 1;
      l_status_type            VARCHAR(30)                             := 'OZF_OFFER_STATUS';
      l_qp_list_header_id      NUMBER;
      l_ozf_offer_id           NUMBER;
      l_rec_idx                NUMBER                                  := 1;
      l_offer_advd_opt_rec     ozf_offer_pvt.advanced_option_rec_type;
      l_offer_obj_ver_num      NUMBER;
      l_offer_pending_flag     VARCHAR2(1);
      l_old_fund_status   VARCHAR(30) := p_old_fund_status;

      CURSOR c_offer_id(
         p_list_header_id   IN   NUMBER) IS
         SELECT offer_id,
                object_version_number
           FROM ozf_offers
          WHERE qp_list_header_id = p_list_header_id;

      CURSOR c_old_fund(
      cv_fund_id   IN   NUMBER)
      IS
      SELECT   status_code
      FROM     ozf_funds_all_b
      WHERE  fund_id = cv_fund_id;

  BEGIN
      SAVEPOINT process_offers;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name       ||
                                    ': create offers');
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_old_fund_status IS NULL THEN
          OPEN c_old_fund(p_fund_rec.fund_id);
          FETCH c_old_fund INTO l_old_fund_status;
          CLOSE c_old_fund;
      END IF;

      IF p_mode = 'CREATE' THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('Create');
         END IF;
         -- first process_offerss in QP
         l_offer_hdr_rec.qp_list_header_id := fnd_api.g_miss_num;
	 l_offer_hdr_rec.activity_media_id := p_fund_rec.task_id;
         l_offer_hdr_rec.offer_id := fnd_api.g_miss_num;

	 --kdass 18-MAY-2004 fix for bug 3628608
	 l_offer_hdr_rec.confidential_flag := 'Y';
         -- commented for 11.5.9
         /*
         IF p_fund_rec.liability_flag = 'Y' THEN
            l_offer_hdr_rec.offer_operation := 'CREATE';
         ELSE
            l_offer_hdr_rec.offer_operation := fnd_api.g_miss_char;
         END IF;
         */
         l_offer_hdr_rec.offer_operation := 'CREATE';
         l_offer_hdr_rec.modifier_operation := 'CREATE';
      ELSIF p_mode In ( 'UPDATE' ,'ACTIVE') THEN

         /* yzhao: 07/23/2001 create actbudget after updating offer modifiers
                so product eligibility check succeeds */ -- 10/11/2002
         /* fix bug 3464511 - duplicate REQUEST records in ozf_act_budgets whenever updating active accrual budget
           IF  p_fund_rec.status_code = 'ACTIVE' THEN
         */
         IF  p_fund_rec.status_code in ('ACTIVE','ON_HOLD') AND p_mode ='ACTIVE' THEN
             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message(l_full_name                   ||
                                           ': begin create act budgets ');
             END IF;
             --      Create_act_budgets for the created offers
             l_act_budgets_rec_type.act_budget_used_by_id := p_fund_rec.plan_id;
             l_act_budgets_rec_type.arc_act_budget_used_by := 'OFFR';
             l_act_budgets_rec_type.budget_source_type := 'FUND';
             l_act_budgets_rec_type.budget_source_id := p_fund_rec.fund_id;
             l_act_budgets_rec_type.transaction_type := 'CREDIT';
             /* yzhao: 12/17/2001 create a REQUEST rathen than TRANSFER so it shows in offer screen
             l_act_budgets_rec_type.transfer_type := 'TRANSFER';
             */
             l_act_budgets_rec_type.transfer_type := 'REQUEST';
             l_act_budgets_rec_type.request_amount := NVL(p_fund_rec.accrual_cap, 0);
             l_act_budgets_rec_type.request_currency := p_fund_rec.currency_code_tc;
             l_act_budgets_rec_type.request_date := SYSDATE;
             l_act_budgets_rec_type.user_status_id := 5001;
             l_act_budgets_rec_type.status_code := 'APPROVED';
             l_act_budgets_rec_type.user_status_id := ozf_utility_pvt.get_default_user_status(
                                                         'OZF_BUDGETSOURCE_STATUS',
                                                         'APPROVED');
             l_act_budgets_rec_type.approved_amount := NVL(p_fund_rec.accrual_cap, 0);
             l_act_budgets_rec_type.approved_original_amount := NVL(p_fund_rec.accrual_cap, 0);
             l_act_budgets_rec_type.approved_in_currency := p_fund_rec.currency_code_tc;
             l_act_budgets_rec_type.approval_date := SYSDATE;
             l_act_budgets_rec_type.approver_id := p_fund_rec.owner;
             l_act_budgets_rec_type.requester_id := p_fund_rec.owner;
             ozf_actbudgets_pvt.create_act_budgets(
                p_api_version=> l_api_version,
                x_return_status=> l_return_status,
                x_msg_count=> x_msg_count,
                x_msg_data=> x_msg_data,
                p_act_budgets_rec=> l_act_budgets_rec_type,
                p_act_util_rec=> ozf_actbudgets_pvt.g_miss_act_util_rec,
                x_act_budget_id=> l_act_budget_id,
                p_approval_flag=> fnd_api.g_true);

             -- dbms_output.put_line('fundrules: create_act_budget returns ' || l_return_status);
    -- dbms_output.put_line('     actbudget_used_by_id=' || l_act_budgets_rec_type.act_budget_used_by_id);
             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message(l_full_name             ||
                                           ': end create budgets ');
             END IF;
         END IF; -- end if for  active
   /* -- 10/11/2002
   ELSIF p_mode = 'UPDATE' THEN
-- 10/16/2001 mpande for updation of accrual offer
     OPEN c_actbudget_id( l_upd_offer_hdr_rec.qp_list_header_id, p_fund_rec.fund_id) ;
     FETCH c_actbudget_id INTO l_act_budget_id ;
     CLOSE c_actbudget_id;
     -- 10/11/2002 increment the object verison number
     UPDATE ozf_act_budgets
     SET approved_amount = NVL(p_fund_rec.accrual_cap,0),
         approved_original_amount = NVL(p_fund_rec.accrual_cap,0)
     WHERE activity_budget_Id = l_Act_budget_id;
   END IF;
   */

         -- dbms_OUTPUT.put_line('fund_status '         ||
  --                            p_fund_rec.status_code);
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('debug6');
         END IF;
         l_qp_list_header_id := p_fund_rec.plan_id;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('l_qp_list_header_id =>' ||
                                       l_qp_list_header_id);
         END IF;
         OPEN c_offer_id(l_qp_list_header_id);
         FETCH c_offer_id INTO l_ozf_offer_id, l_offer_obj_ver_num;
         CLOSE c_offer_id;
         l_offer_hdr_rec.qp_list_header_id := p_fund_rec.plan_id;
	 l_offer_hdr_rec.activity_media_id := p_fund_rec.task_id;
         l_offer_hdr_rec.offer_id := l_ozf_offer_id;
         l_offer_hdr_rec.object_version_number := l_offer_obj_ver_num;
         /*
         IF p_fund_rec.liability_flag = 'Y' THEN
            l_offer_hdr_rec.offer_operation := 'UPDATE';
         ELSE
            l_offer_hdr_rec.offer_operation := fnd_api.g_miss_char;
         END IF;
         */
         l_offer_hdr_rec.offer_operation := 'UPDATE';
         l_offer_hdr_rec.modifier_operation := 'UPDATE';
      END IF; -- end if for p_mode

      IF p_fund_rec.status_code = 'CLOSED' THEN
         l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                                             l_status_type,
                                             'COMPLETED');
         l_offer_hdr_rec.status_code := 'COMPLETED';
      ELSIF p_fund_rec.status_code = 'CANCELLED' THEN
         l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                                             l_status_type,
                                             'TERMINATED');
         l_offer_hdr_rec.status_code := 'TERMINATED';
      ELSIF p_fund_rec.status_code = 'DRAFT' THEN
         l_offer_hdr_rec.status_code := 'DRAFT';
         l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                                             l_status_type,
                                             'DRAFT');
      ELSIF p_fund_rec.status_code = 'PENDING' THEN
         IF l_old_fund_status = 'REJECTED' THEN
             l_offer_hdr_rec.status_code := 'REJECTED';
             l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                                             l_status_type,
                                             'REJECTED');
         ELSE
             l_offer_hdr_rec.status_code := 'DRAFT';
             l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                                             l_status_type,
                                             'DRAFT');
         END IF;
         l_offer_pending_flag := 'T';
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('debug5');
         END IF;
      ELSIF p_fund_rec.status_code = 'ON_HOLD' THEN
         l_offer_hdr_rec.status_code := 'ONHOLD';
         l_offer_hdr_rec.user_status_id := ams_utility_pvt.get_default_user_status(
                                                l_status_type,
                                                'ONHOLD');
      ELSIF p_fund_rec.status_code = 'REJECTED' THEN
         l_offer_hdr_rec.status_code := 'REJECTED';
         l_offer_hdr_rec.user_status_id := ams_utility_pvt.get_default_user_status(
                                                l_status_type,
                                                'REJECTED');
      ELSIF p_fund_rec.status_code = 'ACTIVE' THEN
         l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                                             l_status_type,
                                             'ACTIVE');
         l_offer_hdr_rec.status_code := 'ACTIVE';
      END IF;

       --   -- 10/11/2002 mpande
      -- all these parameters are same in create and update mode
      IF p_fund_rec.accrual_phase = 'VOLUME' THEN
         l_offer_hdr_rec.offer_type := 'VOLUME_OFFER';
         -- customer and customer_type
         l_offer_hdr_rec.retroactive  := p_fund_rec.retroactive_flag;
         l_offer_hdr_rec.custom_setup_id := 108;
         l_offer_hdr_rec.volume_offer_type := 'ACCRUAL';
      -- here pass the seeded custom setup id for volume offers 10/11/2002
      -- 10/11/2002 pass the volume offer customer informaiton
      ELSE
         l_offer_hdr_rec.offer_type := 'ACCRUAL';
         l_offer_hdr_rec.custom_setup_id := 101;
      END IF;
      l_offer_hdr_rec.NAME := p_fund_rec.short_name ||
                              '-'                   ||
                              p_fund_rec.fund_id;
      l_offer_hdr_rec.description := p_fund_rec.short_name;
      l_offer_hdr_rec.offer_amount := NVL(p_fund_rec.accrual_cap, 0);
      l_offer_hdr_rec.budget_amount_tc := NVL(p_fund_rec.accrual_cap, 0);
      --l_offer_hdr_rec.BUDGET_AMOUNT_FC           NUMBER         := Fnd_Api.g_miss_num
      IF l_qp_list_header_id IS NULL THEN
         l_offer_hdr_rec.offer_code := p_fund_rec.fund_number;
      END IF;
      l_offer_hdr_rec.ql_qualifier_type := p_fund_rec.apply_accrual_on;
      l_offer_hdr_rec.ql_qualifier_id := p_fund_rec.qualifier_id;
      l_offer_hdr_rec.owner_id := p_fund_rec.owner;
      l_offer_hdr_rec.perf_date_from := p_fund_rec.start_date_active;
      l_offer_hdr_rec.perf_date_to := p_fund_rec.end_date_active;
      l_offer_hdr_rec.status_date := p_fund_rec.start_date_active;
      l_offer_hdr_rec.source_from_parent := 'N';
      l_offer_hdr_rec.transaction_currency_code := p_fund_rec.currency_code_tc;
      l_offer_hdr_rec.currency_code := p_fund_rec.currency_code_tc;
      l_offer_hdr_rec.start_date_active := p_fund_rec.start_date_active;
      l_offer_hdr_rec.end_date_active := p_fund_rec.end_date_active;
      l_offer_hdr_rec.reusable := 'N';
      l_offer_hdr_rec.budget_offer_yn := 'Y';
      l_offer_hdr_rec.modifier_level_code := p_fund_rec.accrual_discount_level;
      -- dbms_OUTPUT.put_line('modifier_leve '                  ||
  --                         p_fund_rec.accrual_discount_level);
      -- bug fix 3088198.
    --  IF  p_fund_rec.status_code = 'ACTIVE' THEN
       /*  yzhao: 03/03/2004 fix bug 3464511 - duplicate REQUEST records in ozf_funds_utilized_all whenever updating active accrual budget
       IF  l_old_fund_status in('PENDING') AND p_fund_rec.status_code in('ACTIVE','ON_HOLD','REJECTED') THEN
        */
       IF  (p_mode = 'ACTIVE' OR l_old_fund_status in('PENDING'))
        AND p_fund_rec.status_code in('ACTIVE','ON_HOLD','REJECTED', 'DRAFT') THEN
       /* yzhao: 08/09/2005 for fully accrual budget PENDING => DRAFT, call update_offer_status not process_modifier
                            otherwise fully accrual budget can not be reverted to DRAFT from PENDING
                            since process_modifer checks ams_status_order_rules, and PENDING => DRAFT not allowed for offer
        AND p_fund_rec.status_code in('ACTIVE','ON_HOLD','REJECTED') THEN
        */
          ozf_offer_pvt.update_offer_status
         (
            p_commit => fnd_api.g_false,
            x_return_status=> l_return_status,
            x_msg_count=> x_msg_count,
            x_msg_data=> x_msg_data,
            p_modifier_list_rec => l_offer_hdr_rec
         );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('OZF_OFFR_UPDATE_SATAUS FAIL');
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

      ELSE
         IF G_DEBUG THEN
          ozf_utility_pvt.debug_message('process modifiers');
         END IF;
         ozf_offer_pvt.process_modifiers(
        p_init_msg_list=> fnd_api.g_false,
        p_api_version=> 1.0,
        p_commit=> fnd_api.g_false,
        x_return_status=> l_return_status,
        x_msg_count=> x_msg_count,
        x_msg_data=> x_msg_data,
        p_modifier_list_rec=> l_offer_hdr_rec,
        p_modifier_line_tbl=> l_offer_line_tbl,
        p_offer_type=> l_offer_hdr_rec.offer_type,
        x_qp_list_header_id=> l_qp_list_header_id,
        x_error_location=> l_error_location);
         IF G_DEBUG THEN
        ozf_utility_pvt.debug_message(
          'l_return_status' ||
          l_return_status   ||
          '-'               ||
          l_error_location  ||
          x_msg_data);
         END IF;
      END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('OZF_OFFR_QP_FAILURE' ||
                                       l_error_location      ||
                                       x_msg_data);
         END IF;

         --   ozf_utility_pvt.error_message('OZF_OFFR_QP_FAILURE'||l_error_location||x_msg_data);
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Update ozf_offers with status code 'PENDING' by incrementing object_version_number.
      IF l_offer_pending_flag = 'T' THEN
         l_offer_hdr_rec.user_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, 'PENDING');

         -- 10/11/2002 mpande pass the default user status and check what is the default status code
         UPDATE ozf_offers
            SET status_code = 'PENDING',
                user_status_id = l_offer_hdr_rec.user_status_id,
                object_version_number = object_version_number + 1
          WHERE offer_id = l_ozf_offer_id;

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('In update 1');
         END IF;
      END IF;

      IF p_mode = 'CREATE' THEN
         UPDATE ozf_funds_all_b
            SET plan_id = l_qp_list_header_id,
                plan_type = 'OFFR'
          WHERE fund_id = p_fund_rec.fund_id;
      ELSIF p_mode = 'UPDATE' THEN
         l_qp_list_header_id := p_fund_rec.plan_id;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('qp_list_header_id =>' ||
                                       l_qp_list_header_id);
         END IF;
      END IF; -- end of p_mode = CREATE/UPDATE

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name                           ||
                                    ': end update offer advanced option ');
      END IF;
      -- dbms_output.put_line('fundrules: process_modifiers to UPDATE returns ' || l_return_status || ' x_qp_list_header_id=' || l_qp_list_header_id);
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name          ||
                                    ': begin exclusion ');
      END IF;

--kdass 11-MAR-2004 fixed bug 3465281 - advanced options is handled by offers, budgets need to handle this
/*
      -- for Fund_status = 'DRAFT' or p_mode = 'CREATE'.
      IF (   p_mode = 'CREATE'
          OR p_fund_rec.status_code = 'DRAFT') THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message(l_full_name                             ||
                                       ': begin update offer advanced option ');
         END IF;
         --- 08/20/2001 mpande addded for discount level and bucket to process advanced options
         l_offer_advd_opt_rec.list_header_id := l_qp_list_header_id;
         l_offer_advd_opt_rec.offer_type := l_offer_hdr_rec.offer_type;
         l_offer_advd_opt_rec.modifier_level_code := p_fund_rec.accrual_discount_level;

         -- order level does not need a bucket
         IF p_fund_rec.accrual_discount_level <> 'ORDER' THEN
            l_offer_advd_opt_rec.pricing_group_sequence := p_fund_rec.accrual_method;
         END IF;

         --l_offer_advd_opt_rec.PRINT_ON_INVOICE_FLAG      VARCHAR2(1)     := Fnd_Api.g_miss_char
         ozf_offer_pvt.process_adv_options(
            p_init_msg_list=> fnd_api.g_false,
            p_api_version=> 1.0,
            p_commit=> fnd_api.g_false,
            x_return_status=> l_return_status,
            x_msg_count=> l_msg_count,
            x_msg_data=> l_msg_data,
            p_advanced_options_rec=> l_offer_advd_opt_rec);
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('ret status for process adv options =>' ||
                                       l_return_status);
         END IF;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
*/
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO process_offers;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO process_offers;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO process_offers;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
   END process_offers;

---------------------------------------------------------------------
-- PROCEDURE
--    process_approval
--
-- PURPOSE
--    This API is called when  fund is approved from a workflow.
--    This API does the following transactions for a Active fund.
--    1) Record for  holdback amount
--    2) Handle  transactions for a  Accrual type fund
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
-- NOTES
---------------------------------------------------------------------
   PROCEDURE process_approval(
      p_fund_rec        IN       ozf_funds_pvt.fund_rec_type,
      p_mode            IN       VARCHAR2,
      p_old_fund_status IN       VARCHAR2 := NULL,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_api_version     IN       NUMBER) IS
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)                            := 'process_approval';
      l_full_name     CONSTANT VARCHAR2(60)                            := g_pkg_name ||
                                                                          '.'        ||
                                                                          l_api_name;
      l_return_status          VARCHAR2(1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_act_budget_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_budget_id          NUMBER;
   BEGIN
      -- If the fund_status is changing from 'DRAFT to 'ACTIVE', we need to create a record in the
      -- FUND_REQUESTS table for the holdback amount.
      SAVEPOINT process_approval;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_mode = 'ACTIVE' THEN
         IF (NVL(p_fund_rec.holdback_amt, 0) <> 0) THEN
            l_act_budget_rec.status_code := 'APPROVED';
            l_act_budget_rec.arc_act_budget_used_by := 'FUND'; -- hardcoded to fund
            l_act_budget_rec.act_budget_used_by_id := p_fund_rec.fund_id;
            l_act_budget_rec.requester_id := p_fund_rec.owner;
            l_act_budget_rec.approver_id := p_fund_rec.owner;
            l_act_budget_rec.request_amount := p_fund_rec.holdback_amt; --- in transferring to fund currency
            l_act_budget_rec.approved_amount := p_fund_rec.holdback_amt; --- in transferring to fund currency
            l_act_budget_rec.approved_original_amount := p_fund_rec.holdback_amt; --- in transferring to fund currency
            l_act_budget_rec.budget_source_type := 'FUND';
            l_act_budget_rec.budget_source_id := p_fund_rec.fund_id;
            l_act_budget_rec.transfer_type := 'RESERVE';
            l_act_budget_rec.transaction_type := 'CREDIT';
            l_act_budget_rec.approved_in_currency := p_fund_rec.currency_code_tc;
            l_act_budget_rec.adjusted_flag := 'N';
            --l_act_budget_rec.date_required_by := p_needbydate;
            -- Create_transfer record
            ozf_actbudgets_pvt.create_act_budgets(
               p_api_version=> l_api_version,
               x_return_status=> l_return_status,
               x_msg_count=> x_msg_count,
               x_msg_data=> x_msg_data,
               p_act_budgets_rec=> l_act_budget_rec,
               x_act_budget_id=> l_act_budget_id);

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF; -- end for holdback mat
      END IF;

      IF p_fund_rec.fund_type = 'FULLY_ACCRUED' THEN
         -- 10/14/2002 mpande for 11.5.9
         ozf_fundrules_pvt.process_accrual(
            p_fund_rec=> p_fund_rec,
            p_api_version=> l_api_version,
            p_mode=> p_mode,
            p_old_fund_status => p_old_fund_status,
            x_return_status=> l_return_status,
            x_msg_count=> x_msg_count,
            x_msg_data=> x_msg_data);

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name ||
                                    ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO process_approval;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO process_approval;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO process_approval;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
   END process_approval;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_fund_before_close
--
-- PURPOSE
--    Check fund amount before close/cancel an ACTIVE/ON_HOLD budget
--    fix bug 2532491 TST 1158.7 MASTER FUNC : CAN CANCEL AND ARCHIEVE BUDGETS WITH AVAILABLE FUNDS
-- HISTORY
--    01/20/2003  yzhao  Create
-- parameters
--    p_fund_id             IN   NUMBER
--    x_return_status       OUT  VARCAHR2
-----------------------------------------------------------------------
PROCEDURE check_fund_before_close(
   p_fund_id           IN           NUMBER
  ,x_return_status     OUT NOCOPY   VARCHAR2
  ,x_msg_count         OUT NOCOPY   NUMBER
  ,x_msg_data          OUT NOCOPY   VARCHAR2)
IS
   --12/08/2005 rimehrot - sql repository fix SQL ID 14893182 - query the base table directly
   --asylvia 11-May-2006 bug 5199719 - SQL ID  17779489
  CURSOR c_get_fund_amount IS
    SELECT (NVL(original_budget, 0) + NVL(transfered_in_amt,0) - NVL(transfered_out_amt, 0))
    , NVL(recal_committed, 0),
           NVL(utilized_amt, 0), NVL(earned_amt, 0), NVL(paid_amt, 0), fund_type    -- yzhao: 11.5.10 added utilized_amt
    FROM   ozf_funds_all_b
    WHERE  fund_id = p_fund_id;

  l_recal_flag            VARCHAR2(1);
  l_total_budget          NUMBER;
  l_committed_amt         NUMBER;
  l_utilized_amt          NUMBER;
  l_earned_amt            NUMBER;
  l_paid_amt              NUMBER;
  l_fund_type             VARCHAR2(20);
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  OPEN c_get_fund_amount;
  FETCH c_get_fund_amount INTO l_total_budget, l_committed_amt, l_utilized_amt, l_earned_amt, l_paid_amt, l_fund_type;
  CLOSE c_get_fund_amount;

  IF l_total_budget > l_committed_amt THEN
     -- total > committed >= utilized >= earned >= paid
     -- don't close budget because there's available money
      IF l_fund_type = 'QUOTA' THEN
         ozf_utility_pvt.error_message('OZF_TP_QUOTA_BAN_CLOSE');
      ELSE
         ozf_utility_pvt.error_message('OZF_FUND_BAN_CLOSE');
      END IF;
    x_return_status := fnd_api.g_ret_sts_error;
  ELSIF l_total_budget < l_committed_amt THEN
     -- total < re-calculated committed This only happens when profile 'OZF_BUDGET_ADJ_ALLOW_RECAL' is 'Y'
     -- don't close budget because re-calculated committed has committed funds for over the pool of money originally available,
     -- need a budget transfer into the budget
     IF l_fund_type = 'QUOTA' THEN
         ozf_utility_pvt.error_message('OZF_TP_QUOTA_BAN_CLOSE');
      ELSE
         ozf_utility_pvt.error_message('OZF_FUND_BAN_CLOSE_COMM_MORE');
      END IF;
     x_return_status := fnd_api.g_ret_sts_error;
  ELSE
     -- total = committed
     IF l_committed_amt > l_utilized_amt THEN
        -- total = calculated committed > utilized
        -- don't close budget because there is committed fund but not yet utilized
         IF l_fund_type = 'QUOTA' THEN
         ozf_utility_pvt.error_message('OZF_TP_QUOTA_BAN_CLOSE');
         ELSE
         ozf_utility_pvt.error_message('OZF_FUND_BAN_CLOSE_UTIL_LESS');
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
     ELSIF l_committed_amt = l_utilized_amt THEN
         -- total = committed = utilized
         IF l_utilized_amt > l_earned_amt THEN
            -- total = calculated committed = utilized > earned
            -- don't close budget because there is utilized fund but not yet posted to GL
           IF l_fund_type = 'QUOTA' THEN
              ozf_utility_pvt.error_message('OZF_TP_QUOTA_BAN_CLOSE');
           ELSE
              ozf_utility_pvt.error_message('OZF_FUND_BAN_CLOSE_EARN_LESS');
           END IF;
            x_return_status := fnd_api.g_ret_sts_error;
         ELSIF l_utilized_amt = l_earned_amt THEN
            -- total = calculated committed = utilized = earned
            IF l_earned_amt > l_paid_amt THEN
               -- total = re-calculated committed = utilized = earned > paid
               -- don't close budget because there's un-paid fund (trade management is implemented,
               -- accrual earnings not paid out by claim or deduction yet).
               IF l_fund_type = 'QUOTA' THEN
                   ozf_utility_pvt.error_message('OZF_TP_QUOTA_BAN_CLOSE');
               ELSE
                   ozf_utility_pvt.error_message('OZF_FUND_BAN_CLOSE_PAID_LESS');
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
            ELSIF l_earned_amt = l_paid_amt THEN
               -- total = re-calculated committed = utilized = earned = paid
               x_return_status := fnd_api.g_ret_sts_success;
            END IF;
         END IF;
     END IF;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END check_fund_before_close;

-----------------------------------------------------------------------
-- PROCEDURE
--    update_fund_status
--
-- PURPOSE
--    Update fund status .This procedure is called by the update fund API
--    It takes care of all the status changes that take place in funds in the
--    update mode
-- HISTORY
--    01/15/2001  Mumu Pande  Create.
-- parameters    p_fund_rec            IN  fund_rec_type,
--       x_new_status_code       OUT VARCHAR2  the new fund status code
--       x_new_status_id       OUT NUMBER
--       x_return_status           OUT VARCAHR2
-----------------------------------------------------------------------
   PROCEDURE update_fund_status(
      p_fund_rec                 IN       ozf_funds_pvt.fund_rec_type,
      x_new_status_code          OUT NOCOPY      VARCHAR2,
      x_new_status_id            OUT NOCOPY      NUMBER,
      x_submit_budget_approval   OUT NOCOPY      VARCHAR2,
      x_submit_child_approval    OUT NOCOPY      VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2,
      x_msg_count                OUT NOCOPY      NUMBER,
      x_msg_data                 OUT NOCOPY      VARCHAR2,
      p_api_version              IN       NUMBER) IS
      l_api_version   CONSTANT NUMBER         := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)   := 'Update_fund_status';
      l_full_name     CONSTANT VARCHAR2(60)   := g_pkg_name ||
                                                 '.'        ||
                                                 l_api_name;
      l_return_status          VARCHAR2(1)    := fnd_api.g_ret_sts_success;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(4000);
      l_old_status_code        VARCHAR2(30);
      l_old_user_status_id     NUMBER;
      l_new_status_code        VARCHAR2(30);
      l_request_id             NUMBER;
      l_is_requestor_owner     VARCHAR2(1);
      l_approver_id            NUMBER;
      l_status_type            VARCHAR2(30)   := 'OZF_FUND_STATUS';
      l_workflow_process       VARCHAR2(30)   := 'AMSGAPP';
      l_item_type              VARCHAR2(30)   := 'AMSGAPP';
      l_reject_status_id       NUMBER;
      l_old_owner_id           NUMBER;
      l_resource_id            NUMBER;
      l_fund_type              VARCHAR2(30);
      l_list_line              NUMBER;
      l_plan_id                NUMBER;
      l_requester_id           NUMBER;

      CURSOR l_old_status IS
         SELECT status_code,
                user_status_id,
                owner,
                fund_type,
                plan_id
           FROM ozf_funds_all_b
          WHERE fund_id = p_fund_rec.fund_id;

      -- Cursor to find the owner of the parent fund
      CURSOR c_parent_fund_owner(
         p_parent_fund_id   NUMBER) IS
         SELECT owner
           FROM ozf_funds_all_b
          WHERE fund_id = p_parent_fund_id;

BEGIN
      SAVEPOINT update_fund_status;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name ||
                                    '- enter');
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      -- initiallize the out params 08/14/2001 mpande added
      x_submit_budget_approval := fnd_api.g_false;
      x_submit_child_approval := fnd_api.g_false;
      --Get old_status
      OPEN l_old_status;
      FETCH l_old_status INTO l_old_status_code, l_old_user_status_id, l_old_owner_id, l_fund_type, l_plan_id;
      CLOSE l_old_status;
      l_reject_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, 'REJECTED');
      l_new_status_code := p_fund_rec.status_code;

      IF l_old_status_code <> l_new_status_code THEN
         IF l_old_status_code IN ('CLOSED', 'ARCHIVED', 'CANCELLED') THEN
            IF l_new_status_code NOT IN ('ARCHIVED') THEN
               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message(l_full_name   ||
                                             'fund closed');
               END IF;
               IF l_fund_type = 'QUOTA' THEN
                 ozf_utility_pvt.error_message('OZF_TP_QUOTA_BAN_UPDATE');
               ELSE
                 ozf_utility_pvt.error_message('OZF_FUND_BAN_UPDATE');
               END IF;
               --return the old status
               x_new_status_id := l_old_user_status_id;
               x_new_status_code := l_old_status_code;
               x_return_status := fnd_api.g_ret_sts_error;
            ELSE
               x_new_status_code := p_fund_rec.status_code;
               x_new_status_id := p_fund_rec.user_status_id;
            END IF;
         -- Cases of valid approval:
         --    1) WF approval process responds to request to APPROVE, in which case, old status
         --       equals PENDING and new status equals ONHOLD/ACTIVE.
         --    2) WF approval is always started. If the owner does not find anybody to approve above him
         --       the workflow will autoamtically approve it.--
         --   The following case happens only from workflow
         ELSIF l_old_status_code = 'PENDING' THEN
            IF l_new_status_code IN ('ACTIVE', 'ON_HOLD') THEN
               --The following subroutine will take care of all the processing that take place for a active fund.
               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message(l_full_name    ||
                                             'fund aproved');
               END IF;
               x_new_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, l_new_status_code);
               x_new_status_code := l_new_status_code;
            --END IF;
            ELSIF l_new_status_code = 'REJECTED' THEN
               -- Update the fund with status REJECTED
               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message(l_full_name     ||
                                             'fund rejected');
               END IF;
               x_new_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, 'REJECTED');
               x_new_status_code := 'REJECTED';
            ELSIF l_new_status_code = 'DRAFT' THEN
               --An error occurred during the approval process, revert back to 'DRAFT
               --Update the fund with status 'DRAFT'
               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message(l_full_name        ||
                                             'error in aproval');
               END IF;
               x_new_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, 'DRAFT');
               x_new_status_code := 'DRAFT';
            END IF; -- end pending
         ELSIF l_old_status_code IN ('DRAFT', 'REJECTED') THEN
            IF l_new_status_code IN ('ACTIVE', 'ON_HOLD') THEN
            -- niprakas added
                IF (p_fund_rec.fund_usage = 'MTRAN') THEN
                ozf_utility_pvt.write_conc_log(' The fund_usage is Mass Transfer');
                   x_new_status_id := ozf_utility_pvt.get_default_user_status(
                                           l_status_type,
                                           l_new_status_code);
                   x_new_status_code := l_new_status_code;
                   IF p_fund_rec.parent_fund_id IS NOT NULL THEN
                      x_submit_child_approval := fnd_api.g_true;
                   END IF;
             END IF;
         -- niprakas ends

               IF (p_fund_rec.fund_usage = 'ALLOC') THEN
                   -- yzhao: 02/26/2003 fix bug bug 2823606 - when called from budget allocation activation, approval is not needed
                   x_new_status_id := ozf_utility_pvt.get_default_user_status(
                                           l_status_type,
                                           l_new_status_code);
                   x_new_status_code := l_new_status_code;
                   IF p_fund_rec.parent_fund_id IS NOT NULL THEN
                      x_submit_child_approval := fnd_api.g_true;
                   END IF;
               ELSE
                   /* yzhao: 01/29/2003 fix bug 2775762 MKTF1R9:1159.0127:FUNC: ACCRUAL BUDGET CANNOT GO ACTIVE
                      for accrual budget, check if discount rule already defined
                      SELECT 1
                      FROM   qp_list_lines
                      WHERE  list_header_id = (SELECT plan_id FROM ozf_funds_all_b WHERE fund_id = p_fund_rec.fund_id);
                    */
                   IF (l_fund_type = 'FULLY_ACCRUED') THEN
                       l_list_line := ozf_offer_pvt.discount_lines_exist(p_list_header_id => l_plan_id);
                       IF l_list_line <> 0 THEN
                          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                             FND_MESSAGE.set_name('OZF', 'OZF_OFFR_NO_DISC_LINES');
                             FND_MSG_PUB.add;
                          END IF;
                          RAISE FND_API.g_exc_error;
                       END IF;
                   END IF;
                   -- yzhao: 01/29/2003 fix bug 2775762 ends

                   IF p_fund_rec.parent_fund_id IS NOT NULL THEN
                      -- changing status from 'DRAFT or 'REJECTED' to 'ACTIVE or ON_HOLD  is
                      -- equivalent to submitting for approval.
                      -- Approval submission   child fund
                      IF G_DEBUG THEN
                         ozf_utility_pvt.debug_message(l_full_name      ||
                                                    'owner'          ||
                                                    p_fund_rec.owner);
                      END IF;
                      x_submit_child_approval := fnd_api.g_true;
                      OPEN c_parent_fund_owner(p_fund_rec.parent_fund_id);
                      FETCH c_parent_fund_owner INTO l_approver_id;

                      IF (c_parent_fund_owner%NOTFOUND) THEN
                         CLOSE c_parent_fund_owner;

                         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
                            fnd_msg_pub.ADD;
                         END IF;

                         RAISE fnd_api.g_exc_error;
                      END IF;

                      CLOSE c_parent_fund_owner;

		      -- nepanda : fix for bug # 8434546
		      --getting the requester id for the fund
 	              l_requester_id := ozf_utility_pvt.get_resource_id(p_user_id => fnd_global.user_id);

 	              -- Check if requester is also the owner of the parent fund OR child fund owner is same as parent fund owner
                      IF l_approver_id = p_fund_rec.owner OR l_approver_id = l_requester_id THEN
                         l_is_requestor_owner := 'Y';
                      ELSE
                         l_is_requestor_owner := 'N';
                      END IF;

                      IF l_is_requestor_owner = 'N' THEN
                         x_new_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, 'PENDING');
                         x_new_status_code := 'PENDING';
                      ELSE
                         x_new_status_id := ozf_utility_pvt.get_default_user_status(
                                               l_status_type,
                                               l_new_status_code);
                         x_new_status_code := l_new_status_code;
                      END IF;
                   ELSE
                      -- Here Approval submission would be done for  parent less  fund
                      -- call the approval API**********************************
                      -- the approval API would  updatethe fund status to pending
                      IF G_DEBUG THEN
                         ozf_utility_pvt.debug_message('Approval');
                      END IF;
                      x_submit_budget_approval := fnd_api.g_true;
                      x_new_status_id := ozf_utility_pvt.get_default_user_status(l_status_type, 'PENDING');
                      x_new_status_code := 'PENDING';
                   END IF; -- end of parent fund id check
               END IF; -- IF (p_fund_rec.fund_usage == 'ALLOC')
            -- 07/03/2001 bUG#1540719 -- Cancelled spellingwas incorrect
            ELSIF l_new_status_code NOT IN ('CANCELLED') THEN
               ozf_utility_pvt.error_message('OZF_FUND_WRONG_STATUS');
               --return the old status
               x_new_status_id := l_old_user_status_id;
               x_new_status_code := l_old_status_code;
               x_return_status := fnd_api.g_ret_sts_error;
            ELSE
               x_new_status_code := p_fund_rec.status_code;
               x_new_status_id := p_fund_rec.user_status_id;
            END IF; -- end for old draft
         -- 01/20/2003 yzhao: fix bug 2532491 TST 1158.7 MASTER FUNC : CAN CANCEL AND ARCHIEVE BUDGETS WITH AVAILABLE FUNDS
         ELSIF l_old_status_code IN('ACTIVE', 'ON_HOLD') THEN
            IF l_new_status_code IN('CANCELLED', 'CLOSED') THEN
               -- 06/14/2004 yzhao: for quota, do not check remaining amount before closing
               IF l_fund_type = 'QUOTA' THEN
                  l_return_status := fnd_api.g_ret_sts_success;
               ELSE
                  check_fund_before_close( p_fund_id         => p_fund_rec.fund_id
                                      , x_return_status   => l_return_status
                                      , x_msg_count       => l_msg_count
                                      , x_msg_data        => l_msg_data);
               END IF;
               IF l_return_status = fnd_api.g_ret_sts_success THEN
                  x_new_status_code := p_fund_rec.status_code;
                  x_new_status_id := p_fund_rec.user_status_id;
               ELSE
                  -- can not close budget, return the old status
                  x_new_status_id := l_old_user_status_id;
                  x_new_status_code := l_old_status_code;
                  x_return_status := fnd_api.g_ret_sts_error;
               END IF;

        -- 05/11/2003 niprakas added the else loop for the bug#2950428
        ELSIF l_new_status_code IN('ACTIVE') THEN
               x_new_status_code := p_fund_rec.status_code;
               x_new_status_id := p_fund_rec.user_status_id;
       --  05/11/2003 niprakas else loop ends here for the bug#2950428

            ELSE
               -- Invalid status change, should not get here.
               ozf_utility_pvt.error_message('OZF_FUND_WRONG_STATUS');
               -- return the old status
               x_new_status_id := l_old_user_status_id;
               x_new_status_code := l_old_status_code;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         -- 01/20/2003 yzhao bug 2532491 ends

         ELSE
            x_new_status_code := p_fund_rec.status_code;
            x_new_status_id := p_fund_rec.user_status_id;
         END IF;
      /* 12/18/2001 yzhao: locking rule locks owner for 'CANCELLED','CLOSED','ARCHIVED'
         ELSIF  l_old_status_code IN ('ACTIVE','CANCELLED','CLOSED','ARCHIVED','ON_HOLD') THEN
       */
      ELSIF l_old_status_code IN ('ACTIVE', 'ON_HOLD') THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message(l_full_name                   ||
                                       'fund no update except owner');
         END IF;
         --06/04/2001 added validations for accrual type fund
         -- all locking rules are to be implemented by locking rules so I am not raising a error here
         -- Accrual Type Offer could be modified
         l_resource_id := ozf_utility_pvt.get_resource_id(p_user_id => fnd_global.user_id);

         -- the owner could be changed in a active status by the current owner
         -- 12/18/2001 yzhao: owner could be changed by super admin too
         IF p_fund_rec.owner <> l_old_owner_id THEN
            IF    l_resource_id = l_old_owner_id
               OR ams_access_pvt.check_admin_access(l_resource_id) THEN
               x_new_status_id := l_old_user_status_id;
               x_new_status_code := l_old_status_code;
               x_return_status := fnd_api.g_ret_sts_success;
            ELSE
               --ozf_utility_pvt.error_message('OZF_FUND_BAN_UPDATE');
                IF l_fund_type = 'QUOTA' THEN
                 ozf_utility_pvt.error_message('OZF_TP_QUOTA_UPDT_OWNER_PERM');
               ELSE
                  ozf_utility_pvt.error_message('OZF_FUND_UPDT_OWNER_PERM');
               END IF;
               --return the old status
               x_new_status_id := l_old_user_status_id;
               x_new_status_code := l_old_status_code;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         /*
         ELSIF p_fund_rec.fund_type = 'FULLY_ACCRUED' THEN
            x_new_status_id := l_old_user_status_id;
            x_new_status_code := l_old_status_code;
            x_return_status := fnd_api.g_ret_sts_success;
          */
         ELSE
            x_new_status_code := p_fund_rec.status_code;
            x_new_status_id := p_fund_rec.user_status_id;
            x_return_status := fnd_api.g_ret_sts_success;
         END IF;
      ELSE
         x_new_status_code := p_fund_rec.status_code;
         x_new_status_id := p_fund_rec.user_status_id;
      END IF; --check for old and new diff

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name ||
                                    ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_fund_status;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_fund_status;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO update_fund_status;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
   END update_fund_status;


----------------------------------------------------------------------
-- PROCEDURE
--    process_accrual
--
-- PURPOSE
--    Based on accrual basis the offer accrues to customer if Accrual_Basis = 'Customer
--    If accrual_Basis = 'SALES' it accrues to Sales force.
--
--
-- HISTORY
--    10/7/2001 Srinivasa Rudravarapu  Create.
--
-- parameters
--        p_fund_rec            IN  fund_rec_type,
--        p_mode                IN  VARCHAR2  Whether 'INSERT' or 'UPDATE'
--       x_msg_count            OUT NUMBER
--       x_return_status        OUT VARCAHR2
--       x_msg_data             OUT VARCHAR2
-----------------------------------------------------------------------
   PROCEDURE process_accrual(
      p_fund_rec        IN       ozf_funds_pvt.fund_rec_type,
      p_api_version     IN       NUMBER,
      p_mode            IN       VARCHAR2,
      p_old_fund_status IN       VARCHAR2 := NULL,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2) IS
      l_api_name      CONSTANT VARCHAR2(30)                := 'process_accrual';
      l_full_name     CONSTANT VARCHAR2(60)                := g_pkg_name ||
                                                              '.'        ||
                                                              l_api_name;
      l_api_version   CONSTANT NUMBER                      := 1.0;
      l_return_status          VARCHAR2(1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(4000);
      l_fund_rec               ozf_funds_pvt.fund_rec_type := p_fund_rec;
      l_fund_id                NUMBER;
      l_fund_status            VARCHAR2(30);
      l_accrual_basis          VARCHAR2(30);
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name ||
                                    ': begin');
      END IF;
      SAVEPOINT process_accrual;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- dbms_OUTPUT.put_line('FUND ID '           ||
                  --         p_fund_rec.fund_id   ||
                        --   'fundtype'           ||
                        --   p_fund_rec.fund_type);

      IF    p_fund_rec.fund_id IS NULL
         OR p_fund_rec.fund_type <> 'FULLY_ACCRUED' THEN
         RETURN;
      END IF;

      process_offers(
         p_fund_rec=> l_fund_rec,
         p_api_version=> l_api_version,
         p_mode=> p_mode,
         p_old_fund_status => p_old_fund_status,
         x_msg_count=> l_msg_count,
         x_msg_data=> l_msg_data,
         x_return_status=> l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO process_accrual;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO process_accrual;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO process_accrual;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded=> fnd_api.g_false,
            p_count=> x_msg_count,
            p_data=> x_msg_data);
   END process_accrual;
END ozf_fundrules_pvt;

/
