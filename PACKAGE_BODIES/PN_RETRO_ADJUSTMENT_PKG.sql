--------------------------------------------------------
--  DDL for Package Body PN_RETRO_ADJUSTMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_RETRO_ADJUSTMENT_PKG" AS
/* $Header: PNRTADJB.pls 120.5.12010000.2 2009/05/26 07:08:33 rthumma ship $ */

------------------------------ DECLARATIONS ----------------------------------+

TYPE item_id_tbl_type IS TABLE OF pn_payment_items.payment_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE sched_id_tbl_type IS TABLE OF pn_payment_schedules.payment_schedule_id%TYPE INDEX BY BINARY_INTEGER;
TYPE amt_tbl_type IS TABLE OF pn_payment_items.actual_amount%TYPE INDEX BY BINARY_INTEGER;
TYPE date_tbl_type IS TABLE OF pn_payment_items.due_date%TYPE INDEX BY BINARY_INTEGER;

bad_input_exception        EXCEPTION;

------------------------------------------------------------------------------+
-- PROCEDURE   : create_virtual_schedules
-- DESCRIPTION : given a start date, end date, schedule day, amount, freq
--               create virtual items with corresponding dates.
-- HISTORY     :
-- 24-SEP-04 ftanudja o Created.
-- 10-AUG-05 piagrawa o Bug 4354810 - Added code to retrive the proper schedule
--                      start date
-- 05-APR-06 piagrawa o Bug 4354810 - Added handling for terms with start date
--                      equal to end date
------------------------------------------------------------------------------+

PROCEDURE create_virtual_schedules(
            p_start_date pn_payment_terms.start_date%TYPE,
            p_end_date   pn_payment_terms.end_date%TYPE,
            p_sch_day    pn_payment_terms.schedule_day%TYPE,
            p_amount     pn_payment_terms.actual_amount%TYPE,
            p_term_freq  pn_payment_terms.frequency_code%TYPE,
    	    p_payment_term_id pn_payment_terms_all.payment_term_id%TYPE,
            x_sched_tbl  OUT NOCOPY payment_item_tbl_type
         )
IS
  l_current_end_date   pn_payment_terms.end_date%TYPE;
  l_current_start_date pn_payment_terms.start_date%TYPE;
  l_current_amount     pn_payment_terms.actual_amount%TYPE;
  l_dummy_amount       pn_payment_terms.actual_amount%TYPE;

  l_count              NUMBER;
  l_freq_num           NUMBER;

  l_info               VARCHAR2(100);
  l_desc               VARCHAR2(100) := 'pn_retro_adjustment_pkg.create_virtual_schedules';
  l_cal_yr_st_dt       pn_leases_all.cal_start%type;
  l_yr_start_dt        DATE;
  l_sch_str_dt         DATE := NULL;

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' validating input ';
  pnp_debug_pkg.log(l_info);

  IF p_start_date IS NULL OR
     p_end_date IS NULL OR
     p_sch_day IS NULL OR
     p_amount IS NULL OR
     p_term_freq IS NULL OR
     p_start_date > p_end_date OR
     p_sch_day < 1 OR
     p_sch_day > 28
  THEN
     raise bad_input_exception;
  END IF;

  l_info := ' initializing variables ';
  pnp_debug_pkg.log(l_info);

 SELECT cal_start
 INTO   l_cal_yr_st_dt
 FROM PN_LEASES_ALL
 WHERE LEASE_ID = (select distinct lease_id from pn_payment_terms_all where payment_term_id = p_payment_term_id);


 IF l_cal_yr_st_dt IS NOT NULL THEN
       l_yr_start_dt := to_date(l_cal_yr_st_dt || '-' || to_char(p_start_date,'YYYY'),'DD-MM-YYYY');
 END IF;

 IF l_yr_start_dt IS NOT NULL AND p_term_freq NOT IN ('MON','OT') THEN
    pn_schedules_items.get_sch_start(p_yr_start_dt => l_yr_start_dt,
                      p_freq_code => p_term_freq,
	              p_term_start_dt => p_start_date,
                      p_sch_str_dt => l_sch_str_dt);
 END IF;

  l_current_start_date := NVL(l_sch_str_dt,p_start_date);
  l_current_end_date := p_start_date;

  -- special case for one time payments and terms with start date
  -- equal to end date
  IF p_term_freq = 'OT' OR (p_start_date = p_end_Date) THEN
     l_current_end_date := p_start_date - 1;
  END IF;

  l_info := ' creating items ';

  l_freq_num := pn_schedules_items.get_frequency(p_term_freq);

  WHILE l_current_end_date < p_end_date LOOP

     IF p_term_freq = 'MON' THEN
        l_current_end_date := last_day(l_current_start_date);
     ELSIF p_term_freq = 'OT' THEN
        l_current_end_date := l_current_start_date;
     ELSE
        l_current_end_date := add_months(l_current_start_date, l_freq_num) - 1;
     END IF;

     l_info := ' getting amount for schedule start: '|| l_current_start_date;
     pnp_debug_pkg.log(l_info);

     IF p_term_freq = 'OT' THEN

        l_current_amount := p_amount;

     ELSE

        IF p_term_freq IN ('MON') THEN

           l_current_start_date := pn_schedules_items.First_Day(l_current_start_date);

        END IF;

        pn_schedules_items.get_amount(
            p_sch_str_dt   => l_current_start_date,
            p_sch_end_dt   => l_current_end_date,
            p_trm_str_dt   => p_start_date,
            p_trm_end_dt   => p_end_date,
            p_act_amt      => p_amount,
            p_est_amt      => null,
            p_freq         => l_freq_num,
            p_cash_act_amt => l_current_amount,
            p_cash_est_amt => l_dummy_amount);

     END IF;

     -- make sure end date does not exceed the term end date
     -- NOTE: this has to be done AFTER calling pn_schedules_items.get_amount() !!
     l_current_end_date := LEAST(l_current_end_date, p_end_date);

     l_count := x_sched_tbl.COUNT;
     x_sched_tbl(l_count).start_date    := l_current_start_date;
     x_sched_tbl(l_count).end_date      := l_current_end_date;
     x_sched_tbl(l_count).schedule_date := last_day(add_months(l_current_start_date, -1)) + p_sch_day;
     x_sched_tbl(l_count).amount        := l_current_amount;

     l_current_start_date := l_current_end_date + 1;

     -- for one time payments, set logic to terminate loop
     IF p_term_freq = 'OT' THEN l_current_end_date := p_end_date + 1; END IF;

  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END create_virtual_schedules;

------------------------------------------------------------------------------+
-- PROCEDURE   : get_current_schedules
-- DESCRIPTION : given a payment term id, fetch all original and adjustment
--               items associated with it.
-- NOTES       :
-- The program works as follows:
-- 1) Fetch all original items into PL/SQL table
-- 2) Fetch all adjustment items into PL/SQL table
-- 3) Start comparing the two tables with the following rules
--    a) If no adjustment exists, return the original items table. No merging
--       is required here.
--    b) If any of the two tables has 'run out', exit loop and just parse
--       the rest of the other table into the output table.
--
-- HISTORY     :
-- 27-SEP-04 ftanudja o Created.
-- 15-JUL-05  SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+
PROCEDURE get_current_schedules(
            p_term_id    pn_payment_terms.payment_term_id%TYPE,
            x_sched_tbl  OUT NOCOPY payment_item_tbl_type
)
IS
  -- NOTE: important that the cursor is ordered by date
  CURSOR fetch_original_items IS
   SELECT item.payment_item_id,
          item.actual_amount,
          item.payment_schedule_id,
          schedule.schedule_date,
          schedule.payment_status_lookup_code
     FROM pn_payment_items_all item,
          pn_payment_schedules_all schedule
    WHERE item.payment_term_id = p_term_id
      AND item.payment_schedule_id = schedule.payment_schedule_id
      AND item.payment_item_type_lookup_code = 'CASH'
      AND item.last_adjustment_type_code IS NULL
    ORDER BY schedule.schedule_date;

  -- NOTE: important that the cursor is ordered by date
  CURSOR fetch_adj_items IS
   SELECT summary.adjustment_summary_id,
          summary.adj_schedule_date,
          summary.sum_adj_amount
     FROM pn_adjustment_summaries summary
    WHERE summary.payment_term_id = p_term_id
    ORDER BY summary.adj_schedule_date;

  l_orig_item_tbl payment_item_tbl_type;
  l_adj_item_tbl  payment_item_tbl_type;

  l_count_adj    NUMBER;
  l_count_orig   NUMBER;
  l_count_summ   NUMBER;
  l_info         VARCHAR2(300);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.get_current_schedules';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' fetching original items data ';
  pnp_debug_pkg.log(l_info);

  l_count_orig := l_orig_item_tbl.COUNT;

  FOR orig_data_rec IN fetch_original_items LOOP
     l_orig_item_tbl(l_count_orig).item_id        := orig_data_rec.payment_item_id;
     l_orig_item_tbl(l_count_orig).amount         := orig_data_rec.actual_amount;
     l_orig_item_tbl(l_count_orig).schedule_id    := orig_data_rec.payment_schedule_id;
     l_orig_item_tbl(l_count_orig).schedule_date  := orig_data_rec.schedule_date;
     l_orig_item_tbl(l_count_orig).payment_status := orig_data_rec.payment_status_lookup_code;
     l_count_orig := l_count_orig + 1;
  END LOOP;

  l_info := ' fetching adjustment items data ';
  pnp_debug_pkg.log(l_info);

  l_count_adj := l_adj_item_tbl.COUNT;

  FOR adj_data_rec IN fetch_adj_items LOOP
     l_adj_item_tbl(l_count_adj).adj_summ_id   := adj_data_rec.adjustment_summary_id;
     l_adj_item_tbl(l_count_adj).amount        := adj_data_rec.sum_adj_amount;
     l_adj_item_tbl(l_count_adj).schedule_date := adj_data_rec.adj_schedule_date;
     l_count_adj := l_count_adj + 1;
  END LOOP;

  l_info := ' merging the two tables ';
  pnp_debug_pkg.log(l_info);

  IF l_adj_item_tbl.COUNT = 0 THEN

     -- if no adjustments, then return l_orig_item_tbl
     x_sched_tbl := l_orig_item_tbl;

  ELSE
     l_count_orig := null;
     l_count_adj  := 0;
     l_count_summ := 0;

     FOR i IN 0 .. l_orig_item_tbl.COUNT - 1 LOOP

        IF l_orig_item_tbl(i).schedule_date = l_adj_item_tbl(l_count_adj).schedule_date THEN

           l_info := ' (orig = adj): inserting the current item into result table '||
                     ' orig_item date: '||l_orig_item_tbl(i).schedule_date ||
                     ' adj_item date: '||l_adj_item_tbl(l_count_adj).schedule_date;

           pnp_debug_pkg.log(l_info);

           x_sched_tbl(l_count_summ).item_id        := l_orig_item_tbl(i).item_id;
           x_sched_tbl(l_count_summ).schedule_id    := l_orig_item_tbl(i).schedule_id;
           x_sched_tbl(l_count_summ).schedule_date  := l_orig_item_tbl(i).schedule_date;
           x_sched_tbl(l_count_summ).payment_status := l_orig_item_tbl(i).payment_status;
           x_sched_tbl(l_count_summ).adj_summ_id    := l_adj_item_tbl(l_count_adj).adj_summ_id;
           x_sched_tbl(l_count_summ).amount         := l_orig_item_tbl(i).amount +
                                                       l_adj_item_tbl(l_count_adj).amount;

           l_count_summ                             := l_count_summ + 1;
           l_count_adj                              := l_count_adj + 1;

           IF l_count_adj = l_adj_item_tbl.COUNT THEN
              l_count_orig := i + 1;
              exit;
           END IF;

        ELSIF l_orig_item_tbl(i).schedule_date < l_adj_item_tbl(l_count_adj).schedule_date THEN

           l_info := ' (orig < adj): inserting the current item into result table '||
                     ' orig_item date: '||l_orig_item_tbl(i).schedule_date ||
                     ' adj_item date: '||l_adj_item_tbl(l_count_adj).schedule_date;

           pnp_debug_pkg.log(l_info);

           x_sched_tbl(l_count_summ).item_id        := l_orig_item_tbl(i).item_id;
           x_sched_tbl(l_count_summ).schedule_id    := l_orig_item_tbl(i).schedule_id;
           x_sched_tbl(l_count_summ).schedule_date  := l_orig_item_tbl(i).schedule_date;
           x_sched_tbl(l_count_summ).payment_status := l_orig_item_tbl(i).payment_status;
           x_sched_tbl(l_count_summ).amount         := l_orig_item_tbl(i).amount;
           l_count_summ                             := l_count_summ + 1;

        ELSE

           l_info := ' (orig > adj): looping through other table until a greater date is found ';

           pnp_debug_pkg.log(l_info);

           WHILE (l_count_adj <= l_adj_item_tbl.COUNT - 1) AND
                 (l_orig_item_tbl(i).schedule_date >
                  l_adj_item_tbl(l_count_adj).schedule_date)
           LOOP

              l_info := ' inserting the current item into result table '||
                        ' orig_item date: '||l_orig_item_tbl(i).schedule_date ||
                        ' adj_item date: '||l_adj_item_tbl(l_count_adj).schedule_date;

              pnp_debug_pkg.log(l_info);

              IF (l_count_summ <> 0 AND
                  x_sched_tbl(l_count_summ - 1).schedule_date <>
                  l_adj_item_tbl(l_count_adj).schedule_date)
                 OR l_count_summ = 0 THEN
                 x_sched_tbl(l_count_summ).adj_summ_id   := l_adj_item_tbl(l_count_adj).adj_summ_id;
                 x_sched_tbl(l_count_summ).schedule_date := l_adj_item_tbl(l_count_adj).schedule_date;
                 x_sched_tbl(l_count_summ).amount        := l_adj_item_tbl(l_count_adj).amount;
                 l_count_summ                            := l_count_summ + 1;
              END IF;

              l_count_adj                             := l_count_adj + 1;

           END LOOP;

           l_info := ' finished finding lesser adj dates, now inserting current orig '||
                     ' item into result table orig_item date: '|| l_orig_item_tbl(i).schedule_date;

           pnp_debug_pkg.log(l_info);

           x_sched_tbl(l_count_summ).item_id        := l_orig_item_tbl(i).item_id;
           x_sched_tbl(l_count_summ).schedule_id    := l_orig_item_tbl(i).schedule_id;
           x_sched_tbl(l_count_summ).schedule_date  := l_orig_item_tbl(i).schedule_date;
           x_sched_tbl(l_count_summ).payment_status := l_orig_item_tbl(i).payment_status;
           x_sched_tbl(l_count_summ).amount         := l_orig_item_tbl(i).amount;

           IF (l_count_adj <= l_adj_item_tbl.COUNT - 1) AND
              (l_orig_item_tbl(i).schedule_date = l_adj_item_tbl(l_count_adj).schedule_date)
           THEN
              x_sched_tbl(l_count_summ).adj_summ_id   := l_adj_item_tbl(l_count_adj).adj_summ_id;
              x_sched_tbl(l_count_summ).amount        := x_sched_tbl(l_count_summ).amount +
                                                         l_adj_item_tbl(l_count_adj).amount;
              l_count_adj := l_count_adj + 1;
           END IF;

           l_count_summ                             := l_count_summ + 1;

           IF l_count_adj = l_adj_item_tbl.COUNT THEN
              l_count_orig := i + 1;
              exit;
           END IF;

        END IF;

     END LOOP;

     l_info := ' merging the leftover items from l_orig_item_tbl ';
     pnp_debug_pkg.log(l_info);

     IF l_count_orig IS NOT NULL THEN
        FOR i IN l_count_orig .. l_orig_item_tbl.COUNT - 1 LOOP
           x_sched_tbl(l_count_summ).item_id        := l_orig_item_tbl(i).item_id;
           x_sched_tbl(l_count_summ).schedule_id    := l_orig_item_tbl(i).schedule_id;
           x_sched_tbl(l_count_summ).schedule_date  := l_orig_item_tbl(i).schedule_date;
           x_sched_tbl(l_count_summ).amount         := l_orig_item_tbl(i).amount;
           x_sched_tbl(l_count_summ).payment_status := l_orig_item_tbl(i).payment_status;
           l_count_summ := l_count_summ + 1;
        END LOOP;
     END IF;

     l_info := ' merging the leftover items from l_adj_item_tbl ';
     pnp_debug_pkg.log(l_info);

     FOR i IN l_count_adj  .. l_adj_item_tbl.COUNT - 1 LOOP
        IF (l_count_summ <> 0 AND
            x_sched_tbl(l_count_summ - 1).schedule_date <>
            l_adj_item_tbl(i).schedule_date)
           OR
           l_count_summ = 0 THEN
           x_sched_tbl(l_count_summ).adj_summ_id   := l_adj_item_tbl(i).adj_summ_id;
           x_sched_tbl(l_count_summ).schedule_date := l_adj_item_tbl(i).schedule_date;
           x_sched_tbl(l_count_summ).amount        := l_adj_item_tbl(i).amount;
           l_count_summ                            := l_count_summ + 1;
        END IF;
     END LOOP;
  END IF;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END get_current_schedules;

------------------------------------------------------------------------------+
-- PROCEDURE   : merge_schedules
-- DESCRIPTION : given two schedules, current and virtual, merge the two
--               together
-- NOTE        :
-- This uses 99% of the logic of get_current_schedules() to merge the tables
-- using dates. Only the updated fields are sometimes different. Here the
-- value of virtual items is put into the 'new_amount' column.
--
-- HISTORY     :
-- 28-SEP-04 ftanudja o Created.
------------------------------------------------------------------------------+
PROCEDURE merge_schedules(
            p_current_sched payment_item_tbl_type,
            p_virtual_sched payment_item_tbl_type,
            x_sched_tbl     OUT NOCOPY payment_item_tbl_type
)
IS
  l_count_virtl  NUMBER;
  l_count_curnt  NUMBER;
  l_count_merge  NUMBER;

  l_info         VARCHAR2(200);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.merge_schedules';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' initializing counters ';
  pnp_debug_pkg.log(l_info);

  l_count_curnt := null;
  l_count_virtl := 0;
  l_count_merge := 0;

  l_info := ' merging the two tables ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_current_sched.COUNT - 1 LOOP

     IF p_current_sched(i).schedule_date = p_virtual_sched(l_count_virtl).schedule_date THEN

        l_info := ' (curnt = virtl): inserting item into result table '||
                  ' curnt_item date: '||p_current_sched(i).schedule_date ||
                  ' virtl_item date: '||p_virtual_sched(l_count_virtl).schedule_date;

        pnp_debug_pkg.log(l_info);

        x_sched_tbl(l_count_merge).item_id        := p_current_sched(i).item_id;
        x_sched_tbl(l_count_merge).adj_summ_id    := p_current_sched(i).adj_summ_id;
        x_sched_tbl(l_count_merge).schedule_id    := p_current_sched(i).schedule_id;
        x_sched_tbl(l_count_merge).schedule_date  := p_current_sched(i).schedule_date;
        x_sched_tbl(l_count_merge).payment_status := p_current_sched(i).payment_status;
        x_sched_tbl(l_count_merge).amount         := p_current_sched(i).amount;

        x_sched_tbl(l_count_merge).new_amount     := p_virtual_sched(l_count_virtl).amount;
        x_sched_tbl(l_count_merge).start_date     := p_virtual_sched(l_count_virtl).start_date;
        x_sched_tbl(l_count_merge).end_date       := p_virtual_sched(l_count_virtl).end_date;

        l_count_merge                             := l_count_merge + 1;
        l_count_virtl                             := l_count_virtl + 1;

        IF l_count_virtl = p_virtual_sched.COUNT THEN
           l_count_curnt := i + 1;
           exit;
        END IF;

     ELSIF p_current_sched(i).schedule_date < p_virtual_sched(l_count_virtl).schedule_date THEN

        l_info := ' (curnt < virtl): inserting item into result table '||
                  ' curnt_item date: '||p_current_sched(i).schedule_date ||
                  ' virtl_item date: '||p_virtual_sched(l_count_virtl).schedule_date;

        pnp_debug_pkg.log(l_info);

        x_sched_tbl(l_count_merge).item_id        := p_current_sched(i).item_id;
        x_sched_tbl(l_count_merge).adj_summ_id    := p_current_sched(i).adj_summ_id;
        x_sched_tbl(l_count_merge).schedule_id    := p_current_sched(i).schedule_id;
        x_sched_tbl(l_count_merge).schedule_date  := p_current_sched(i).schedule_date;
        x_sched_tbl(l_count_merge).payment_status := p_current_sched(i).payment_status;
        x_sched_tbl(l_count_merge).amount         := p_current_sched(i).amount;
        l_count_merge                             := l_count_merge + 1;

     ELSE

        l_info := ' (curnt > virtl): looping through other table until a greater date is found ';

        pnp_debug_pkg.log(l_info);

        WHILE (l_count_virtl <= p_virtual_sched.COUNT - 1) AND
              (p_current_sched(i).schedule_date >
               p_virtual_sched(l_count_virtl).schedule_date)
        LOOP

           l_info := ' inserting into result table '||
                     ' curnt_item date: '||p_current_sched(i).schedule_date ||
                     ' virtl_item date: '||p_virtual_sched(l_count_virtl).schedule_date;

           pnp_debug_pkg.log(l_info);

           IF (l_count_merge <> 0 AND
               x_sched_tbl(l_count_merge - 1).schedule_date <>
               p_virtual_sched(l_count_virtl).schedule_date)
              OR l_count_merge = 0 THEN
              x_sched_tbl(l_count_merge).schedule_date := p_virtual_sched(l_count_virtl).schedule_date;
              x_sched_tbl(l_count_merge).new_amount    := p_virtual_sched(l_count_virtl).amount;
              x_sched_tbl(l_count_merge).start_date    := p_virtual_sched(l_count_virtl).start_date;
              x_sched_tbl(l_count_merge).end_date      := p_virtual_sched(l_count_virtl).end_date;

              l_count_merge                            := l_count_merge + 1;
           END IF;

           l_count_virtl                               := l_count_virtl + 1;

        END LOOP;

        l_info := ' finished finding lesser adj dates, now inserting current '||
                     ' item into result table curnt_item date:'||p_current_sched(i).schedule_date;

        pnp_debug_pkg.log(l_info);

        x_sched_tbl(l_count_merge).item_id        := p_current_sched(i).item_id;
        x_sched_tbl(l_count_merge).adj_summ_id    := p_current_sched(i).adj_summ_id;
        x_sched_tbl(l_count_merge).schedule_id    := p_current_sched(i).schedule_id;
        x_sched_tbl(l_count_merge).schedule_date  := p_current_sched(i).schedule_date;
        x_sched_tbl(l_count_merge).payment_status := p_current_sched(i).payment_status;
        x_sched_tbl(l_count_merge).amount         := p_current_sched(i).amount;

        IF (l_count_virtl <= p_virtual_sched.COUNT - 1) AND
           (p_current_sched(i).schedule_date = p_virtual_sched(l_count_virtl).schedule_date)
        THEN
           x_sched_tbl(l_count_merge).new_amount  := p_virtual_sched(l_count_virtl).amount;
           x_sched_tbl(l_count_merge).start_date  := p_virtual_sched(l_count_virtl).start_date;
           x_sched_tbl(l_count_merge).end_date    := p_virtual_sched(l_count_virtl).end_date;
           l_count_virtl                          := l_count_virtl + 1;

        END IF;

        l_count_merge                             := l_count_merge + 1;

        IF l_count_virtl = p_virtual_sched.COUNT THEN
           l_count_curnt := i + 1;
           exit;
        END IF;

     END IF;

  END LOOP;

  l_info := ' merging the leftover items from p_current_sched ';
  pnp_debug_pkg.log(l_info);

  IF l_count_curnt IS NOT NULL THEN
     FOR i IN l_count_curnt .. p_current_sched.COUNT - 1 LOOP
        x_sched_tbl(l_count_merge).item_id        := p_current_sched(i).item_id;
        x_sched_tbl(l_count_merge).adj_summ_id    := p_current_sched(i).adj_summ_id;
        x_sched_tbl(l_count_merge).schedule_id    := p_current_sched(i).schedule_id;
        x_sched_tbl(l_count_merge).schedule_date  := p_current_sched(i).schedule_date;
        x_sched_tbl(l_count_merge).amount         := p_current_sched(i).amount;
        x_sched_tbl(l_count_merge).payment_status := p_current_sched(i).payment_status;
        l_count_merge := l_count_merge + 1;
     END LOOP;
  END IF;

  l_info := ' merging the leftover items from p_virtual_sched ';
  pnp_debug_pkg.log(l_info);

  FOR i IN l_count_virtl  .. p_virtual_sched.COUNT - 1 LOOP
     IF (l_count_merge <> 0 AND
         x_sched_tbl(l_count_merge - 1).schedule_date <>
         p_virtual_sched(i).schedule_date)
        OR
        l_count_merge = 0 THEN

        x_sched_tbl(l_count_merge).schedule_date := p_virtual_sched(i).schedule_date;
        x_sched_tbl(l_count_merge).new_amount    := p_virtual_sched(i).amount;
        x_sched_tbl(l_count_merge).start_date    := p_virtual_sched(i).start_date;
        x_sched_tbl(l_count_merge).end_date      := p_virtual_sched(i).end_date;

        l_count_merge                            := l_count_merge + 1;
     END IF;
  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END merge_schedules;

------------------------------------------------------------------------------+
-- PROCEDURE   : find_start_end_dates
-- DESCRIPTION : In case the start and end dates are not found from the pl/sql
--               table, determine using term information.
-- NOTE        : This is usually called when a new adjustment is needed to
--               cancel out an approved item that is outside of the date range
--               due to retro adjustment.
-- HISTORY     :
-- 08-OCT-04 ftanudja o Created.
-- 14-JAN-05 atuppad  o removed least of p_term_end_dt for x_end_date
------------------------------------------------------------------------------+
PROCEDURE find_start_end_dates(
            p_term_freq     pn_payment_terms.frequency_code%TYPE,
            p_term_start_dt pn_payment_terms.start_date%TYPE,
            p_term_end_dt   pn_payment_terms.end_date%TYPE,
            p_schedule_dt   pn_payment_schedules.schedule_date%TYPE,
            x_start_date    OUT NOCOPY pn_payment_items.adj_start_date%TYPE,
            x_end_date      OUT NOCOPY pn_payment_items.adj_end_date%TYPE
)
IS
  l_freq_num     NUMBER;
  l_start_day    NUMBER;
  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.find_start_end_dates';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  IF p_term_freq = 'MON' THEN

     x_end_date   := last_day(p_schedule_dt);
     x_start_date := add_months(x_end_date, -1) + 1;
     x_end_date   := least(x_end_date, p_term_end_dt);

  ELSIF p_term_freq = 'QTR' THEN

     l_freq_num   := pn_schedules_items.get_frequency(p_term_freq);
     l_start_day  := TO_NUMBER(TO_CHAR(p_term_start_dt,'DD'));

     x_start_date := last_day(add_months(p_schedule_dt,- 1)) + l_start_day;
     x_end_date   := add_months(x_start_date, l_freq_num) - 1;

  END IF;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END find_start_end_dates;

------------------------------------------------------------------------------+
-- PROCEDURE   : create_adjustment_tables
-- DESCRIPTION : Given a table of schedules and items, determine what action
--               needs to be done. Group items into tables, depending on what
--               action needs to be done. All changes to original items go
--               to xxx_orig_table; all changes to adjustment items go to
--               xxx_adj_table.
--
-- Program logic as follows
--
-- IF virtual item exists, and current item doesn't exist THEN
--   IF schedule date > last_appr_sch_dt THEN
--      create new original item
--   ELSE
--      create new adjustment item
--   END IF
-- ELSIF virtual item doesn't exist, and current item exists THEN
--   IF payment status = 'DRAFT' THEN
--      delete original item
---  ELSE
--      update adjustment item
--   END IF
-- ELSIF virtual item exists, and current item exists, and they're not = THEN
--   IF payment status = 'DRAFT' THEN
--      update original item
--   ELSE
--      update adjustment item
--   END IF
-- END IF
--
-- HISTORY     :
-- 29-SEP-04 ftanudja o Created.
-- 14-JAN-04 atuppad  o for the records in x_adj_table, made sure that they
--                      start_date and end_date.
------------------------------------------------------------------------------+
PROCEDURE create_adjustment_tables (
            p_sched_table    payment_item_tbl_type,
            p_last_appr_dt   DATE,
            p_term_freq      pn_payment_terms.frequency_code%TYPE,
            p_term_start_dt  pn_payment_terms.start_date%TYPE,
            p_term_end_dt    pn_payment_terms.end_date%TYPE,
            x_new_orig_table OUT NOCOPY payment_item_tbl_type,
            x_upd_orig_table OUT NOCOPY payment_item_tbl_type,
            x_del_orig_table OUT NOCOPY payment_item_tbl_type,
            x_adj_table      OUT NOCOPY payment_item_tbl_type
)
IS
  l_count_new_orig NUMBER := 0;
  l_count_upd_orig NUMBER := 0;
  l_count_del_orig NUMBER := 0;
  l_count_chg_adj  NUMBER := 0;
  l_last_appr_dt   DATE;

  l_start_date   pn_adjustment_details.adj_start_date%TYPE;
  l_end_date     pn_adjustment_details.adj_end_date%TYPE;

  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.create_adjustment_tables';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' looping through the schedule table ';
  pnp_debug_pkg.log(l_info);

  l_last_appr_dt := nvl(p_last_appr_dt, TO_DATE('01/01/0001','DD/MM/YYYY'));

  FOR i IN 0 .. p_sched_table.COUNT - 1 LOOP

     IF p_sched_table(i).new_amount IS NOT NULL AND
        p_sched_table(i).amount IS NULL AND
        p_sched_table(i).new_amount <> 0
     THEN

        IF p_sched_table(i).schedule_date > l_last_appr_dt THEN
           x_new_orig_table(l_count_new_orig).amount        := p_sched_table(i).new_amount;
           x_new_orig_table(l_count_new_orig).schedule_date := p_sched_table(i).schedule_date;
           x_new_orig_table(l_count_new_orig).trx_date      := p_sched_table(i).schedule_date;
           l_count_new_orig                                 := l_count_new_orig + 1;

        ELSE
           x_adj_table(l_count_chg_adj).amount        := p_sched_table(i).new_amount;
           x_adj_table(l_count_chg_adj).schedule_date := p_sched_table(i).schedule_date;
           x_adj_table(l_count_chg_adj).start_date    := p_sched_table(i).start_date;
           x_adj_table(l_count_chg_adj).end_date      := p_sched_table(i).end_date;
           l_count_chg_adj                            := l_count_chg_adj + 1;

        END IF;

     ELSIF p_sched_table(i).new_amount IS NULL AND
           p_sched_table(i).amount IS NOT NULL
     THEN

        IF p_sched_table(i).payment_status = 'DRAFT' THEN

           x_del_orig_table(l_count_del_orig).item_id       := p_sched_table(i).item_id;
           x_del_orig_table(l_count_del_orig).schedule_id   := p_sched_table(i).schedule_id;
           x_del_orig_table(l_count_del_orig).schedule_date := p_sched_table(i).schedule_date;
           l_count_del_orig                                 := l_count_del_orig + 1;

        ELSIF p_sched_table(i).amount <> 0 THEN

           x_adj_table(l_count_chg_adj).amount        := - p_sched_table(i).amount;
           x_adj_table(l_count_chg_adj).schedule_date := p_sched_table(i).schedule_date;
           x_adj_table(l_count_chg_adj).start_date    := p_sched_table(i).start_date;
           x_adj_table(l_count_chg_adj).end_date      := p_sched_table(i).end_date;
           x_adj_table(l_count_chg_adj).adj_summ_id   := p_sched_table(i).adj_summ_id;
           l_count_chg_adj                            := l_count_chg_adj + 1;

        END IF;

     ELSIF p_sched_table(i).new_amount IS NOT NULL AND
           p_sched_table(i).amount IS NOT NULL AND
           p_sched_table(i).amount <> p_sched_table(i).new_amount
     THEN

        IF p_sched_table(i).payment_status = 'DRAFT' AND p_sched_table(i).new_amount <> 0 THEN

           x_upd_orig_table(l_count_upd_orig).item_id       := p_sched_table(i).item_id;
           x_upd_orig_table(l_count_upd_orig).schedule_date := p_sched_table(i).schedule_date;
           x_upd_orig_table(l_count_upd_orig).amount        := p_sched_table(i).new_amount;

           l_count_upd_orig := l_count_upd_orig + 1;

        -- this case is almost never going to happen
        ELSIF p_sched_table(i).payment_status = 'DRAFT' AND p_sched_table(i).new_amount = 0 THEN

           x_del_orig_table(l_count_del_orig).item_id       := p_sched_table(i).item_id;
           x_del_orig_table(l_count_del_orig).schedule_id   := p_sched_table(i).schedule_id;
           x_del_orig_table(l_count_del_orig).schedule_date := p_sched_table(i).schedule_date;
           l_count_del_orig                                 := l_count_del_orig + 1;

        ELSE

           x_adj_table(l_count_chg_adj).amount        := p_sched_table(i).new_amount -
                                                             p_sched_table(i).amount;
           x_adj_table(l_count_chg_adj).schedule_date := p_sched_table(i).schedule_date;
           x_adj_table(l_count_chg_adj).start_date    := p_sched_table(i).start_date;
           x_adj_table(l_count_chg_adj).end_date      := p_sched_table(i).end_date;
           x_adj_table(l_count_chg_adj).adj_summ_id   := p_sched_table(i).adj_summ_id;
           l_count_chg_adj                            := l_count_chg_adj + 1;

        END IF;

     END IF;

  END LOOP;

  /* AMTNEW CHANGES - START */
  FOR i IN 0 .. x_adj_table.COUNT - 1 LOOP

     IF x_adj_table(i).start_date IS NULL OR x_adj_table(i).end_date IS NULL THEN

        l_info := ' now figuring out start and end dates for schedule date:'||
                    x_adj_table(i).schedule_date;
        pnp_debug_pkg.log(l_info);

        find_start_end_dates(
           p_term_freq     => p_term_freq,
           p_term_start_dt => p_term_start_dt,
           p_term_end_dt   => p_term_end_dt,
           p_schedule_dt   => x_adj_table(i).schedule_date,
           x_start_date    => l_start_date,
           x_end_date      => l_end_date
        );
        x_adj_table(i).start_date := l_start_date;
        x_adj_table(i).end_date := l_end_date;

     END IF;

  END LOOP;
  /* AMTNEW CHANGES - END */

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END create_adjustment_tables;

------------------------------------------------------------------------------+
-- PROCEDURE   : calculate_adjustment_details
-- DESCRIPTION : given a table of adjustments, find all payment items that are
--               impacted and separate them into 3 tables: one for updation,
--               one for deletion, and one for creation.
-- HISTORY     :
-- 29-SEP-04 ftanudja o Created.
-- 15-JUL-05  SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+

PROCEDURE calculate_adjustment_details(
             p_adj_table     IN OUT NOCOPY payment_item_tbl_type,
             p_new_itm_table OUT NOCOPY payment_item_tbl_type,
             p_upd_itm_table OUT NOCOPY payment_item_tbl_type,
             p_del_itm_table OUT NOCOPY payment_item_tbl_type
)
IS

  CURSOR get_item_details (p_adj_summ_id pn_adjustment_summaries.adjustment_summary_id%TYPE)IS
     SELECT item.payment_item_id,
            item.actual_amount amount,
            schedule.payment_schedule_id,
            schedule.schedule_date
       FROM pn_payment_items_all item,
            pn_payment_schedules_all schedule
      WHERE schedule.payment_schedule_id = item.payment_schedule_id
        AND schedule.payment_status_lookup_code = 'DRAFT'
        AND item.payment_item_id IN
            (SELECT payment_item_id
               FROM pn_adjustment_details
              WHERE adjustment_summary_id = p_adj_summ_id);

  l_items_table     payment_item_tbl_type;

  -- for table counters
  l_count_new_itm   NUMBER;
  l_count_upd_itm   NUMBER;
  l_count_del_itm   NUMBER;
  l_count_items     NUMBER;

  l_sch_date        DATE;
  l_temp_amt        NUMBER;
  l_exist_draft_adj BOOLEAN;

  l_info            VARCHAR2(100);
  l_desc            VARCHAR2(100) := 'pn_retro_adjustment_pkg.calculate_adjustment_details';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' initializing counters ';
  pnp_debug_pkg.log(l_info);

  l_count_new_itm := 0;
  l_count_upd_itm := 0;
  l_count_del_itm := 0;
  l_count_items   := 0;

  FOR i IN 0 .. p_adj_table.COUNT - 1 LOOP

     l_items_table.delete;
     l_exist_draft_adj := FALSE;

     IF p_adj_table(i).adj_summ_id IS NOT NULL THEN

        l_info := ' fetching items for adj summary id: '||p_adj_table(i).adj_summ_id;
        pnp_debug_pkg.log(l_info);

        FOR items_rec IN get_item_details (p_adj_table(i).adj_summ_id) LOOP

           l_exist_draft_adj := TRUE;
           l_temp_amt := items_rec.amount + p_adj_table(i).amount;

           -- if new amount is zero, delete, else update
           IF l_temp_amt = 0 THEN

              p_del_itm_table(l_count_del_itm).item_id       := items_rec.payment_item_id;
              p_del_itm_table(l_count_del_itm).schedule_date := items_rec.schedule_date;
              p_del_itm_table(l_count_del_itm).schedule_id   := items_rec.payment_schedule_id;
              l_count_del_itm                                := l_count_del_itm + 1;

           ELSIF l_temp_amt <> 0 THEN

              p_adj_table(i).item_id                       := items_rec.payment_item_id;
              p_upd_itm_table(l_count_upd_itm).item_id     := items_rec.payment_item_id;
              p_upd_itm_table(l_count_upd_itm).amount      := l_temp_amt;
              l_count_upd_itm                              := l_count_upd_itm + 1;

           END IF;

           -- there should be only one draft item, or even if there are multiple,
           -- only one should be changed
           exit;

        END LOOP;

     END IF;

     -- if nothing found, create new adjustment

     IF NOT l_exist_draft_adj THEN
        p_new_itm_table(l_count_new_itm).amount        := p_adj_table(i).amount;
        p_new_itm_table(l_count_new_itm).schedule_date := p_adj_table(i).schedule_date;
        p_new_itm_table(l_count_new_itm).start_date    := p_adj_table(i).start_date;
        p_new_itm_table(l_count_new_itm).end_date      := p_adj_table(i).end_date;
        l_count_new_itm                                := l_count_new_itm + 1;
     END IF;

  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END calculate_adjustment_details;


------------------------------------------------------------------------------+
-- PROCEDURE   : prepare_new_items_from_adj
-- DESCRIPTION : Given a table of adjustments data, creates a table of items
--               that needs to be created based on various system options
--               values.
-- HISTORY     :
-- 05-OCT-04 ftanudja o Created.
-- 10-AUG-05 piagrawa o Bug#4284035 - Modified the signature to pass org id
------------------------------------------------------------------------------+
PROCEDURE prepare_new_items_from_adj (
            p_sch_day      pn_payment_terms.schedule_day%TYPE,
            p_item_adj_tbl IN OUT NOCOPY payment_item_tbl_type,
            p_org_id       NUMBER
)
IS
  l_item_dtl_tbl   payment_item_tbl_type;

  -- for system option values
  l_consolidate    BOOLEAN;
  l_use_crnt_month BOOLEAN;
  l_trx_sysdate    BOOLEAN;

  l_sch_dt         pn_payment_schedules.schedule_date%TYPE;
  l_trx_dt         pn_payment_items.due_date%TYPE;
  l_total_amt      pn_payment_items.actual_amount%TYPE;

  l_info           VARCHAR2(100);
  l_desc           VARCHAR2(100) := 'pn_retro_adjustment_pkg.prepare_new_items_from_adj';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' fetching system option values ';
  pnp_debug_pkg.log(l_info);

  IF pn_mo_cache_utils.get_profile_value('PN_CONSOLIDATE_ADJ_ITEMS', p_org_id) = 'Y' THEN
     l_consolidate := TRUE;
  ELSE
     l_consolidate := FALSE;
  END IF;

  IF pn_mo_cache_utils.get_profile_value('PN_USE_SYSDATE_FOR_ADJ', p_org_id) = 'Y' THEN
     l_use_crnt_month := TRUE;
  ELSE
     l_use_crnt_month := FALSE;
  END IF;

  IF pn_mo_cache_utils.get_profile_value('PN_USE_SYSDATE_AS_TRX_DATE', p_org_id) = 'Y' THEN
     l_trx_sysdate := TRUE;
  ELSE
     l_trx_sysdate := FALSE;
  END IF;

  l_total_amt      := 0;

  FOR i IN 0 .. p_item_adj_tbl.COUNT - 1 LOOP

     IF l_consolidate AND l_use_crnt_month THEN
        l_total_amt := l_total_amt + p_item_adj_tbl(i).amount;

     ELSIF NOT l_consolidate THEN

        IF l_use_crnt_month THEN
           l_sch_dt := last_day(add_months(TRUNC(SYSDATE), -1)) + p_sch_day;

        ELSE
           l_sch_dt := p_item_adj_tbl(i).schedule_date;
        END IF;

        IF l_trx_sysdate THEN
           l_trx_dt := TRUNC(SYSDATE);
        ELSE
           l_trx_dt := l_sch_dt;
        END IF;

        l_item_dtl_tbl(i).schedule_date := l_sch_dt;
        l_item_dtl_tbl(i).trx_date      := l_trx_dt;
        l_item_dtl_tbl(i).start_date    := p_item_adj_tbl(i).start_date;
        l_item_dtl_tbl(i).end_date      := p_item_adj_tbl(i).end_date;
        l_item_dtl_tbl(i).amount        := p_item_adj_tbl(i).amount;

     END IF;

  END LOOP;

  IF l_use_crnt_month AND l_consolidate AND l_total_amt <> 0 THEN

     l_item_dtl_tbl(0).schedule_date := last_day(add_months(TRUNC(SYSDATE), -1)) + p_sch_day;
     l_item_dtl_tbl(0).start_date    := p_item_adj_tbl(0).start_date;
     l_item_dtl_tbl(0).end_date      := p_item_adj_tbl(p_item_adj_tbl.COUNT - 1).end_date;
     l_item_dtl_tbl(0).amount        := l_total_amt;

     IF l_trx_sysdate THEN
        l_item_dtl_tbl(0).trx_date   := TRUNC(SYSDATE);
     ELSE
        l_item_dtl_tbl(0).trx_date   := l_item_dtl_tbl(0).schedule_date;
     END IF;

  END IF;

  p_item_adj_tbl := l_item_dtl_tbl;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END prepare_new_items_from_adj;

------------------------------------------------------------------------------+
-- PROCEDURE   : find_schedule
-- DESCRIPTION : finds a draft schedule for a given schedule date for a lease
--               OR creates a new draft schedule if none is found.
-- HISTORY     :
-- 19-OCT-04  ftanudja  o Created.
-- 15-JUL-05  SatyaDeep o Replaced base views with their _ALL tables
-- 10-AUG-05  piagrawa  o Bug #4284035 - Passed org id of the lease to insert_row
------------------------------------------------------------------------------+
PROCEDURE find_schedule (
            p_lease_id        pn_leases.lease_id%TYPE,
            p_lease_change_id pn_lease_changes.lease_change_id%TYPE,
            p_term_id         pn_payment_terms.payment_term_id%TYPE,
            p_schedule_date   pn_payment_schedules.schedule_date%TYPE,
            p_schedule_id     OUT NOCOPY pn_payment_schedules.payment_schedule_id%TYPE
)
IS
  CURSOR fetch_schedule IS
   SELECT payment_schedule_id
     FROM pn_payment_schedules_all
    WHERE schedule_date = p_schedule_date
      AND lease_id = p_lease_id
      AND payment_status_lookup_code = 'DRAFT';

  CURSOR check_if_sch_belong_to_term(p_sch_id pn_payment_schedules.payment_schedule_id%TYPE) IS
   SELECT 'Y'
     FROM dual
    WHERE EXISTS (SELECT NULL
                    FROM pn_payment_items_all
                   WHERE payment_schedule_id = p_sch_id
                     AND payment_term_id = p_term_id);

  CURSOR org_id_cur IS
   SELECT org_id
   FROM pn_leases_all
   WHERE lease_id = p_lease_id;

  l_rowid        VARCHAR2(100);
  l_found        BOOLEAN := FALSE;

  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.find_schedule';
  l_org_id       NUMBER;

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info:= ' finding draft schedules for date: '||p_schedule_date;
  pnp_debug_pkg.log(l_info);

  FOR org_id_rec IN org_id_cur LOOP
     l_org_id := org_id_rec.org_id;
  END LOOP;

  FOR schedule_rec IN fetch_schedule LOOP

     IF l_found = FALSE THEN

        l_found := TRUE;
        p_schedule_id := schedule_rec.payment_schedule_id;

        l_info := ' getting draft schedule id: '||p_schedule_id;
        pnp_debug_pkg.log(l_info);

     ELSE -- if multiple schedules find

        l_info := ' checking multiple schedules for : '||p_schedule_date;
        pnp_debug_pkg.log(l_info);

        FOR get_id_rec IN check_if_sch_belong_to_term(schedule_rec.payment_schedule_id) LOOP
           p_schedule_id := schedule_rec.payment_schedule_id;
        END LOOP;

     END IF;

  END LOOP;

  IF NOT l_found THEN
     l_info:= ' inserting a new draft schedule for date: '||p_schedule_date;
     pnp_debug_pkg.log(l_info);

     pnt_payment_schedules_pkg.insert_row(
        x_context                     => null,
        x_rowid                       => l_rowid,
        x_payment_schedule_id         => p_schedule_id,
        x_schedule_date               => p_schedule_date,
        x_lease_change_id             => p_lease_change_id,
        x_lease_id                    => p_lease_id,
        x_approved_by_user_id         => null,
        x_transferred_by_user_ID      => null,
        x_payment_status_lookup_code  => 'DRAFT',
        x_approval_date               => null,
        x_transfer_date               => null,
        x_period_name                 => null,
        x_attribute_category          => null,
        x_attribute1                  => null,
        x_attribute2                  => null,
        x_attribute3                  => null,
        x_attribute4                  => null,
        x_attribute5                  => null,
        x_attribute6                  => null,
        x_attribute7                  => null,
        x_attribute8                  => null,
        x_attribute9                  => null,
        x_attribute10                 => null,
        x_attribute11                 => null,
        x_attribute12                 => null,
        x_attribute13                 => null,
        x_attribute14                 => null,
        x_attribute15                 => null,
        x_creation_date               => SYSDATE,
        x_created_by                  => fnd_global.user_id,
        x_last_update_date            => SYSDATE,
        x_last_updated_by             => fnd_global.user_id,
        x_last_update_login           => fnd_global.login_id,
        x_org_id                      => l_org_id
     );

  END IF;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END find_schedule;

------------------------------------------------------------------------------+
-- PROCEDURE   : get_schedule_id_for_new_items
-- DESCRIPTION : calls pn_schedules_items.create_schedule for every schedule
--               date in the table and returns the schedule id to the same
--               table.
-- NOTE        : This is dependent on pn_schedules_items.create_schedule()
-- HISTORY     :
-- 05-OCT-04 ftanudja o Created.
------------------------------------------------------------------------------+
PROCEDURE get_schedule_id_for_new_items(
            p_lease_id        pn_leases.lease_id%TYPE,
            p_term_id         pn_payment_terms.payment_term_id%TYPE,
            p_lease_change_id pn_lease_changes.lease_change_id%TYPE,
            p_sched_tbl       IN OUT NOCOPY payment_item_tbl_type
)
IS
  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.get_schedule_id_for_new_items';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' starting loop ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_sched_tbl.COUNT - 1 LOOP

     l_info := ' finding schedule for '||p_sched_tbl(i).schedule_date ;
     pnp_debug_pkg.log(l_info);

     find_schedule(
        p_lease_id        => p_lease_id,
        p_lease_change_id => p_lease_change_id,
        p_term_id         => p_term_id,
        p_schedule_date   => p_sched_tbl(i).schedule_date,
        p_schedule_id     => p_sched_tbl(i).schedule_id
     );

  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END get_schedule_id_for_new_items;

------------------------------------------------------------------------------+
-- PROCEDURE   : remove_item_reference
-- DESCRIPTION : takes a table containing payment id and remove all reference
--               to it from the pn_adjustment_details table.
-- HISTORY     :
-- 05-OCT-04 ftanudja o Created.
------------------------------------------------------------------------------+

PROCEDURE remove_item_reference (
            p_item_tbl payment_item_tbl_type
)
IS

  l_payment_id_tbl item_id_tbl_type;

  l_info           VARCHAR2(100);
  l_desc           VARCHAR2(100) := 'pn_retro_adjustment_pkg.remove_item_reference';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' preparing for bulk update ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_item_tbl.COUNT - 1 LOOP
     l_payment_id_tbl(i) := p_item_tbl(i).item_id;
  END LOOP;

  l_info := ' performing bulk update ';
  pnp_debug_pkg.log(l_info);

  FORALL i IN 0 .. l_payment_id_tbl.COUNT - 1
    UPDATE pn_adjustment_details
       SET payment_item_id   = null,
           last_update_date  = SYSDATE,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
     WHERE payment_item_id = l_payment_id_tbl(i);

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END remove_item_reference;

------------------------------------------------------------------------------+
-- PROCEDURE   : process_items
-- DESCRIPTION : Takes 3 tables for UPDATE, DELETE, and INSERT operation
--               into the pn_payment_items table. Does BULK operations for
--               efficiency.
-- HISTORY     :
-- 05-OCT-04 ftanudja o Created.
-- 15-JUL-05  SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+
PROCEDURE process_items(
            p_term_id      pn_payment_terms.payment_term_id%TYPE,
            p_adj_type_cd  pn_payment_items.last_adjustment_type_code%TYPE,
            p_upd_item_tbl payment_item_tbl_type,
            p_del_item_tbl payment_item_tbl_type,
            p_new_item_tbl IN OUT NOCOPY payment_item_tbl_type
)
IS

  CURSOR get_term_data IS
   SELECT vendor_id,
          vendor_site_id,
          customer_id,
          customer_site_use_id,
          cust_ship_site_id,
          set_of_books_id,
          currency_code,
          rate,
          estimated_amount,
          org_id
     FROM pn_payment_terms_all
    WHERE payment_term_id = p_term_id;

  l_new_itm_id_tbl        item_id_tbl_type;
  l_payment_id_tbl        item_id_tbl_type;
  l_sched_id_tbl          sched_id_tbl_type;
  l_act_amt_tbl           amt_tbl_type;
  l_est_amt_tbl           amt_tbl_type;
  l_trx_date_tbl          date_tbl_type;
  l_start_date_tbl        date_tbl_type;
  l_end_date_tbl          date_tbl_type;

  l_vendor_id             pn_payment_terms.vendor_id%TYPE;
  l_vendor_site_id        pn_payment_terms.vendor_site_id%TYPE;
  l_customer_id           pn_payment_terms.customer_id%TYPE;
  l_customer_site_use_id  pn_payment_terms.customer_site_use_id%TYPE;
  l_cust_ship_site_id     pn_payment_terms.cust_ship_site_id%TYPE;
  l_set_of_books_id       pn_payment_terms.set_of_books_id%TYPE;
  l_currency_code         pn_payment_terms.currency_code%TYPE;
  l_rate                  pn_payment_terms.rate%TYPE;

  l_precision             NUMBER;
  l_ext_precision         NUMBER;
  l_min_acct_unit         NUMBER;

  l_has_est_amt           BOOLEAN;

  l_info                  VARCHAR2(100);
  l_desc                  VARCHAR2(100) := 'pn_retro_adjustment_pkg.process_items';
  l_org_id                NUMBER;

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' updating items ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_upd_item_tbl.COUNT - 1 LOOP
    l_act_amt_tbl(i)    := p_upd_item_tbl(i).amount;
    l_payment_id_tbl(i) := p_upd_item_tbl(i).item_id;
    IF l_has_est_amt THEN
       l_est_amt_tbl(i) := p_upd_item_tbl(i).amount;
    ELSE
       l_est_amt_tbl(i) := null;
    END IF;
  END LOOP;

  l_info := ' preparing for bulk update ';
  pnp_debug_pkg.log(l_info);

  FOR term_rec IN get_term_data LOOP

    l_currency_code := term_rec.currency_code;
    fnd_currency.get_info(  l_currency_code
                          , l_precision
                          , l_ext_precision
                          , l_min_acct_unit);

    EXIT;
  END LOOP;

  FORALL i IN 0 .. l_payment_id_tbl.COUNT - 1
    UPDATE pn_payment_items_all
       SET actual_amount     = ROUND(l_act_amt_tbl(i), l_precision),
           estimated_amount  = ROUND(l_est_amt_tbl(i), l_precision),
           last_update_date  = SYSDATE,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
     WHERE payment_item_id   = l_payment_id_tbl(i);

  l_info := ' deleting items ';
  pnp_debug_pkg.log(l_info);

  l_payment_id_tbl.delete;

  FOR i IN 0 .. p_del_item_tbl.COUNT - 1 LOOP
    l_payment_id_tbl(i)  := p_del_item_tbl(i).item_id;
  END LOOP;

  l_info := ' preparing for bulk delete ';
  pnp_debug_pkg.log(l_info);

  FORALL i IN 0 .. l_payment_id_tbl.COUNT - 1
    DELETE pn_payment_items
     WHERE payment_item_id = l_payment_id_tbl(i);

  l_info := ' creating items ';
  pnp_debug_pkg.log(l_info);

  l_payment_id_tbl.delete;
  l_act_amt_tbl.delete;
  l_est_amt_tbl.delete;
  l_has_est_amt := FALSE;

  l_info := ' fetching term details ';
  pnp_debug_pkg.log(l_info);

  FOR term_rec IN get_term_data LOOP

    l_vendor_id             := term_rec.vendor_id;
    l_vendor_site_id        := term_rec.vendor_site_id;
    l_customer_id           := term_rec.customer_id;
    l_customer_site_use_id  := term_rec.customer_site_use_id;
    l_cust_ship_site_id     := term_rec.cust_ship_site_id;
    l_set_of_books_id       := term_rec.set_of_books_id;
    l_currency_code         := term_rec.currency_code;
    l_rate                  := term_rec.rate;
    l_org_id                := term_rec.org_id;
    IF term_rec.estimated_amount IS NOT NULL THEN
       l_has_est_amt        := TRUE;
    END IF;

    fnd_currency.get_info(l_currency_code, l_precision, l_ext_precision, l_min_acct_unit);

    EXIT;
  END LOOP;

  l_info := ' preparing for bulk insert ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_new_item_tbl.COUNT - 1 LOOP
     l_sched_id_tbl(i)    := p_new_item_tbl(i).schedule_id;
     l_act_amt_tbl(i)     := p_new_item_tbl(i).amount;
     l_trx_date_tbl(i)    := p_new_item_tbl(i).trx_date;
     l_start_date_tbl(i)  := p_new_item_tbl(i).start_date;
     l_end_date_tbl(i)    := p_new_item_tbl(i).end_date;

     IF l_has_est_amt THEN
        l_est_amt_tbl(i)  := p_new_item_tbl(i).amount;
     ELSE
        l_est_amt_tbl(i)  := null;
     END IF;

  END LOOP;

  FORALL i IN 0 .. l_sched_id_tbl.COUNT - 1
    INSERT INTO pn_payment_items_all
    (
       payment_item_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       actual_amount,
       estimated_amount,
       due_date,
       adj_start_date,
       adj_end_date,
       last_adjustment_type_code,
       payment_item_type_lookup_code,
       payment_term_id,
       payment_schedule_id,
       period_fraction,
       vendor_id,
       customer_id,
       vendor_site_id,
       customer_site_use_id,
       cust_ship_site_id,
       set_of_books_id,
       currency_code,
       export_currency_code,
       export_currency_amount,
       rate,
       org_id
    )
    VALUES
    (
       pn_payment_items_s.nextval,
       SYSDATE,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.login_id,
       ROUND(l_act_amt_tbl(i), l_precision),
       ROUND(l_est_amt_tbl(i), l_precision),
       l_trx_date_tbl(i),
       l_start_date_tbl(i),
       l_end_date_tbl(i),
       p_adj_type_cd,
       'CASH',
       p_term_id,
       l_sched_id_tbl(i),
       1,
       l_vendor_id,
       l_customer_id,
       l_vendor_site_id,
       l_customer_site_use_id,
       l_cust_ship_site_id,
       l_set_of_books_id,
       l_currency_code,
       l_currency_code,
       null,
       l_rate,
       l_org_id
     ) RETURNING payment_item_id BULK COLLECT INTO l_new_itm_id_tbl;

  -- NOTE: l_new_itm_id_tbl is populated starting from (1), not (0) --

  l_info := ' updating p_new_item_tbl with newly inserted item id ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_new_item_tbl.COUNT - 1 LOOP
     p_new_item_tbl(i).item_id := l_new_itm_id_tbl(i + 1);
  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END process_items;

------------------------------------------------------------------------------+
-- PROCEDURE   : populate_new_item_id
-- DESCRIPTION : puts newly inserted payment item ID's into adjustment table
--               by doing a simple bubble search
-- NOTES       : the procedure assumes both tables are ordered by dates
-- HISTORY     :
-- 07-OCT-04 ftanudja o Created.
------------------------------------------------------------------------------+
PROCEDURE populate_new_item_id(
            p_new_item_tbl payment_item_tbl_type,
            p_adj_tbl      IN OUT NOCOPY payment_item_tbl_type
)
IS
  l_mark       NUMBER := 0;

  l_info       VARCHAR2(100);
  l_desc       VARCHAR2(100) := 'pn_retro_adjustment_pkg.populate_new_item_id';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' starting loop ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_adj_tbl.COUNT - 1 LOOP

     IF p_adj_tbl(i).item_id IS NULL THEN

        l_info := ' looping through adjustment table for start date '||p_adj_tbl(i).start_date||
                  ' and end date '||p_adj_tbl(i).end_date;
        pnp_debug_pkg.log(l_info);

        FOR j IN l_mark .. p_new_item_tbl.COUNT - 1 LOOP

           IF p_new_item_tbl(j).start_date <= p_adj_tbl(i).start_date AND
              p_new_item_tbl(j).end_date >= p_adj_tbl(i).end_date
           THEN

              l_info := ' found item match with start date '||p_new_item_tbl(j).start_date||
                       ' and end date '||p_new_item_tbl(j).end_date;
              pnp_debug_pkg.log(l_info);

              p_adj_tbl(i).item_id := p_new_item_tbl(j).item_id;
              l_mark := j;
              exit;
           END IF;

        END LOOP;

     END IF;

  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END populate_new_item_id;

------------------------------------------------------------------------------+
-- PROCEDURE   : create_adjustment_entries
-- DESCRIPTION : creates a new batch of adjustment entries for the current
--               term history
-- HISTORY     :
-- 06-OCT-04 ftanudja o Created.
-- 10-AUG-05 piagrawa o Bug#4284035 - Modified the signature to pass org id.
------------------------------------------------------------------------------+
PROCEDURE create_adjustment_entries(
            p_term_id        pn_payment_terms.payment_term_id%TYPE,
            p_term_freq      pn_payment_terms.frequency_code%TYPE,
            p_term_start_dt  pn_payment_terms.start_date%TYPE,
            p_term_end_dt    pn_payment_terms.end_date%TYPE,
            p_term_hist_id   pn_payment_terms_history.term_history_id%TYPE,
            p_adj_table      payment_item_tbl_type,
            p_org_id         NUMBER
)
IS
  l_start_date   pn_adjustment_details.adj_start_date%TYPE;
  l_end_date     pn_adjustment_details.adj_end_date%TYPE;
  l_adj_summ_id  pn_adjustment_summaries.adjustment_summary_id%TYPE;

  l_group_num    NUMBER := 0;
  l_consolidate  BOOLEAN;

  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.create_adjustment_entries';

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' preparing adjustment data ';
  pnp_debug_pkg.log(l_info);

  IF pn_mo_cache_utils.get_profile_value('PN_USE_SYSDATE_FOR_ADJ', p_org_id) = 'Y' AND
     pn_mo_cache_utils.get_profile_value('PN_CONSOLIDATE_ADJ_ITEMS', p_org_id) = 'Y' THEN
     l_consolidate := TRUE;
  ELSE
     l_consolidate := FALSE;
  END IF;

  FOR i IN 0 .. p_adj_table.COUNT - 1 LOOP

     IF p_adj_table(i).adj_summ_id IS NULL THEN

       l_info := ' inserting into adjustment summary table for schedule date:'||
                   p_adj_table(i).schedule_date;
       pnp_debug_pkg.log(l_info);

       INSERT INTO pn_adjustment_summaries (
          adjustment_summary_id,
          adj_schedule_date,
          payment_term_id,
          sum_adj_amount,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
       ) VALUES (
          pn_adjustment_summaries_s.nextval,
          p_adj_table(i).schedule_date,
          p_term_id,
          p_adj_table(i).amount,
          SYSDATE,
          fnd_global.user_id,
          SYSDATE,
          fnd_global.user_id,
          fnd_global.login_id
       ) RETURNING adjustment_summary_id INTO l_adj_summ_id;

     ELSE

        l_adj_summ_id := p_adj_table(i).adj_summ_id;

     END IF;

     IF p_adj_table(i).start_date IS NULL OR p_adj_table(i).end_date IS NULL THEN

        l_info := ' figuring out start and end dates for schedule date:'||
                    p_adj_table(i).schedule_date;
        pnp_debug_pkg.log(l_info);

        find_start_end_dates(
           p_term_freq     => p_term_freq,
           p_term_start_dt => p_term_start_dt,
           p_term_end_dt   => p_term_end_dt,
           p_schedule_dt   => p_adj_table(i).schedule_date,
           x_start_date    => l_start_date,
           x_end_date      => l_end_date
        );
     ELSE

        l_start_date := p_adj_table(i).start_date;
        l_end_date   := p_adj_table(i).end_date;

     END IF;

     l_info := ' finding system options to determine group num ';
     pnp_debug_pkg.log(l_info);

     IF NOT l_consolidate THEN
        l_group_num := l_group_num + 1;
     END IF;

     l_info := ' inserting new adjustment for schedule date:'||
                 p_adj_table(i).schedule_date;
     pnp_debug_pkg.log(l_info);

     INSERT INTO pn_adjustment_details (
        adjustment_detail_id,
        term_history_id,
        adjustment_summary_id,
        payment_item_id,
        adj_start_date,
        adj_end_date,
        adjustment_amount,
        group_num,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
     ) VALUES (
        pn_adjustment_details_s.nextval,
        p_term_hist_id,
        l_adj_summ_id,
        p_adj_table(i).item_id,
        l_start_date,
        l_end_date,
        p_adj_table(i).amount,
        l_group_num,
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        fnd_global.login_id
     );

     IF p_adj_table(i).adj_summ_id IS NOT NULL THEN

        l_info := ' updating adjustment summary id:'||
                    p_adj_table(i).adj_summ_id;
        pnp_debug_pkg.log(l_info);

        UPDATE pn_adjustment_summaries
           SET sum_adj_amount        = sum_adj_amount + p_adj_table(i).amount,
               last_update_date      = SYSDATE,
               last_updated_by       = fnd_global.user_id,
               last_update_login     = fnd_global.login_id
         WHERE adjustment_summary_id = p_adj_table(i).adj_summ_id;

     END IF;

  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END create_adjustment_entries;


------------------------------------------------------------------------------+
-- PROCEDURE     : cleanup_schedules
-- DESCRIPTION   : Given a lease id and lease end date it clean up schedules.
--                 Delete schedules with no items.Also deletes the draft schedules
--                 which lie outside the lease.
--  PURPOSE      :
--  INVOKED FROM : schedules_items.mini_retro_contraction
--  ARGUMENTS    : p_lease_id
--  HISTORY      :
--  08-OCT-04  piagrawa  o Bug 4354810 - Overloaded for mini -retro.
--  04-APR-06  piagrawa  o Bug#5107134 - modified schedules_draft_cur to include
--                          status 'ON_HOLD'
------------------------------------------------------------------------------+
PROCEDURE cleanup_schedules(p_lease_id        pn_leases_all.lease_id%TYPE)
IS

   CURSOR schedules_draft_cur IS
     SELECT payment_schedule_id
     FROM pn_payment_schedules_all
     WHERE lease_id = p_lease_id
     AND payment_status_lookup_code IN ('DRAFT', 'ON_HOLD');

   CURSOR find_payment_items_cur (p_sch_id pn_payment_schedules.payment_schedule_id%TYPE)IS
      SELECT payment_item_id
      FROM pn_payment_items_all  item
      WHERE item.payment_schedule_id = p_sch_id;

  l_found  BOOLEAN;

BEGIN
   pnp_debug_pkg.log('cleanup_schedules   (+)');

   FOR schedules_draft_rec IN schedules_draft_cur LOOP

     l_found := FALSE;

     FOR find_payment_items_rec IN find_payment_items_cur(schedules_draft_rec.payment_schedule_id) LOOP
        l_found := TRUE;
     END LOOP;

     IF(l_found = FALSE) THEN

        pnp_debug_pkg.log('Deleting schedule id ........'||schedules_draft_rec.payment_schedule_id);

        DELETE pn_payment_schedules_all
        WHERE payment_schedule_id = schedules_draft_rec.payment_schedule_id;

     END IF;

   END LOOP;

   pnp_debug_pkg.log('cleanup_schedules   (-)');

END cleanup_schedules;

------------------------------------------------------------------------------+
-- PROCEDURE   : cleanup_schedules
-- DESCRIPTION : Given a list of schedule id's, clean up schedules. Delete
--               schedules with no items. Create 0 cash item for schedules
--               with no cash items.
-- HISTORY     :
-- 08-OCT-04 ftanudja o Created.
-- 15-JUL-05  SatyaDeep o Replaced base views with their _ALL tables
------------------------------------------------------------------------------+
PROCEDURE cleanup_schedules(
            p_term_id       pn_payment_terms.payment_term_id%TYPE,
            p_orig_item_tbl payment_item_tbl_type,
            p_adj_item_tbl  payment_item_tbl_type
)
IS

  CURSOR find_cash_items (p_sch_id pn_payment_schedules.payment_schedule_id%TYPE)IS
   SELECT SUM(DECODE(item.payment_item_type_lookup_code, 'CASH', 1, 0)) num_cash
     FROM pn_payment_items_all  item
    WHERE item.payment_schedule_id = p_sch_id;

  CURSOR get_term_data IS
   SELECT vendor_id,
          vendor_site_id,
          customer_id,
          customer_site_use_id,
          cust_ship_site_id,
          set_of_books_id,
          currency_code,
          rate,
          estimated_amount,
          org_id
     FROM pn_payment_terms_all
    WHERE payment_term_id = p_term_id;

  l_vendor_id             pn_payment_terms.vendor_id%TYPE;
  l_vendor_site_id        pn_payment_terms.vendor_site_id%TYPE;
  l_customer_id           pn_payment_terms.customer_id%TYPE;
  l_customer_site_use_id  pn_payment_terms.customer_site_use_id%TYPE;
  l_cust_ship_site_id     pn_payment_terms.cust_ship_site_id%TYPE;
  l_set_of_books_id       pn_payment_terms.set_of_books_id%TYPE;
  l_currency_code         pn_payment_terms.currency_code%TYPE;
  l_rate                  pn_payment_terms.rate%TYPE;

  l_sched_id_tbl          sched_id_tbl_type;
  l_sched_dt_tbl          date_tbl_type;
  l_found                 BOOLEAN;
  l_num_item              NUMBER;

  l_info                  VARCHAR2(100);
  l_desc                  VARCHAR2(100) := 'pn_retro_adjustment_pkg.cleanup_schedules';
  l_org_id                NUMBER;

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  l_info := ' looping through original items table ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_orig_item_tbl.COUNT - 1 LOOP
     l_sched_id_tbl(i) := p_orig_item_tbl(i).schedule_id;
     l_sched_dt_tbl(i) := p_orig_item_tbl(i).schedule_date;
  END LOOP;

  l_info := ' looping through adjustment items table ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. p_adj_item_tbl.COUNT - 1 LOOP

     l_found := FALSE;

     FOR j IN 0 .. l_sched_id_tbl.COUNT - 1 LOOP

        IF l_sched_id_tbl(j) = p_adj_item_tbl(i).schedule_id THEN
           l_found := TRUE;
        END IF;

     END LOOP;

     IF NOT l_found THEN
        l_sched_id_tbl(l_sched_id_tbl.COUNT) := p_adj_item_tbl(i).schedule_id;
        l_sched_dt_tbl(l_sched_dt_tbl.COUNT) := p_adj_item_tbl(i).schedule_date;
     END IF;

  END LOOP;

  l_info := ' looping through schedule id table ';
  pnp_debug_pkg.log(l_info);

  FOR i IN 0 .. l_sched_id_tbl.COUNT - 1 LOOP

     l_found := FALSE;

     l_info := ' looping through schedule id table ';
     pnp_debug_pkg.log(l_info);

     FOR items_rec IN find_cash_items(l_sched_id_tbl(i)) LOOP
        l_found    := TRUE;
        l_num_item := items_rec.num_cash;
     END LOOP;

     IF l_found AND l_num_item = 0 THEN

        l_info := ' inserting $0 cash item onto schedule id: '||l_sched_id_tbl(i);

        pnp_debug_pkg.log(l_info);

        FOR term_rec IN get_term_data LOOP

          l_vendor_id             := term_rec.vendor_id;
          l_vendor_site_id        := term_rec.vendor_site_id;
          l_customer_id           := term_rec.customer_id;
          l_customer_site_use_id  := term_rec.customer_site_use_id;
          l_cust_ship_site_id     := term_rec.cust_ship_site_id;
          l_set_of_books_id       := term_rec.set_of_books_id;
          l_currency_code         := term_rec.currency_code;
          l_rate                  := term_rec.rate;
          l_org_id                := term_rec.org_id;
          EXIT;

        END LOOP;

        INSERT INTO pn_payment_items_all
        (
           payment_item_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           actual_amount,
           estimated_amount,
           due_date,
           adj_start_date,
           adj_end_date,
           payment_item_type_lookup_code,
           payment_term_id,
           payment_schedule_id,
           period_fraction,
           vendor_id,
           customer_id,
           vendor_site_id,
           customer_site_use_id,
           cust_ship_site_id,
           set_of_books_id,
           currency_code,
           export_currency_code,
           export_currency_amount,
           rate,
           org_id
        ) VALUES
        (
           pn_payment_items_s.nextval,
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
           0,
           null,
           l_sched_dt_tbl(i),
           null,
           null,
           'CASH',
           p_term_id,
           l_sched_id_tbl(i),
           1,
           l_vendor_id,
           l_customer_id,
           l_vendor_site_id,
           l_customer_site_use_id,
           l_cust_ship_site_id,
           l_set_of_books_id,
           l_currency_code,
           l_currency_code,
           null,
           l_rate,
           l_org_id
        );

     ELSIF NOT l_found THEN

        l_info := ' deleting schedule id : '||l_sched_id_tbl(i);
        pnp_debug_pkg.log(l_info);

        DELETE pn_payment_schedules_all
         WHERE payment_schedule_id = l_sched_id_tbl(i);

     END IF;
  END LOOP;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END cleanup_schedules;

------------------------------------------------------------------------------+
-- PROCEDURE   : update_terms_history
-- DESCRIPTION : updates the term history table with the latest adjustment
--               type code.
-- HISTORY     :
-- 14-OCT-04 ftanudja o Created.
-- 14-JAN-05 atuppad  o Added code to update total_adj_amount
------------------------------------------------------------------------------+
PROCEDURE update_terms_history(
            p_term_hist_id     pn_payment_terms_history.term_history_id%TYPE,
            p_adj_type_cd      pn_payment_items.last_adjustment_type_code%TYPE,
            p_lease_change_id  pn_lease_changes.lease_change_id%TYPE,
            p_term_id          pn_payment_terms.payment_term_id%TYPE
)
IS

  -- Get total adj amount
  CURSOR get_total_adj_amt IS
    SELECT SUM(pad.adjustment_amount) total_adj_amount
    FROM   pn_adjustment_details pad,
           pn_payment_terms_history pth
    WHERE  pth.payment_term_id = p_term_id
    AND    pth.lease_change_id = p_lease_change_id
    AND    pad.term_history_id = pth.term_history_id;

  l_info         VARCHAR2(100);
  l_desc         VARCHAR2(100) := 'pn_retro_adjustment_pkg.update_terms_history';
  l_amount       NUMBER;

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  FOR amt_rec IN get_total_adj_amt LOOP
    l_amount := amt_rec.total_adj_amount;
  END LOOP;

  UPDATE pn_payment_terms_history
     SET adjustment_type_code = p_adj_type_cd,
         total_adj_amount     = l_amount,
         last_update_date     = SYSDATE,
         last_update_login    = fnd_global.login_id,
         last_updated_by      = fnd_global.user_id
   WHERE term_history_id      = p_term_hist_id;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END update_terms_history;

------------------------------------------------------------------------------+
-- PROCEDURE   : create_retro_adjustments
-- DESCRIPTION : This is the main procedure being called for retro adjustment
--               changes.
-- HISTORY     :
-- 04-OCT-04 ftanudja o Created.
-- 14-JAN-05 atuppad  o Changed the signature of below proc
--                      - create_adjustment_tables
--                      - update_terms_history
-- 15-JUL-05  SatyaDeep o Replaced base views with their _ALL tables
-- 10-AUG-05  piagrawa  o Bug #4284035 - Updated the calls to proc
--                        prepare_new_items_from_adj and create_adjustment_entries
--                        to pass org id.
------------------------------------------------------------------------------+
PROCEDURE create_retro_adjustments(
            p_lease_id      pn_payment_terms.lease_id%TYPE,
            p_lease_chg_id  pn_lease_changes.lease_change_id%TYPE,
            p_term_id       pn_payment_terms.payment_term_id%TYPE,
            p_term_start_dt pn_payment_terms.start_date%TYPE,
            p_term_end_dt   pn_payment_terms.end_date%TYPE,
            p_term_sch_day  pn_payment_terms.schedule_day%TYPE,
            p_term_act_amt  pn_payment_terms.actual_amount%TYPE,
            p_term_freq     pn_payment_terms.frequency_code%TYPE,
            p_term_hist_id  pn_payment_terms_history.term_history_id%TYPE,
            p_adj_type_cd   pn_payment_items.last_adjustment_type_code%TYPE
)
IS
  CURSOR get_last_appr_sched IS
   SELECT max(schedule_date) schedule_date
   FROM pn_payment_schedules_all
   WHERE lease_id = p_lease_id
   AND payment_status_lookup_code = 'APPROVED';

  CURSOR org_id_cur IS
   SELECT org_id
   FROM pn_leases_all
   WHERE lease_id = p_lease_id;

  l_virtual_sched  payment_item_tbl_type;
  l_current_sched  payment_item_tbl_type;
  l_merged_sched   payment_item_tbl_type;

  l_new_orig_table payment_item_tbl_type;
  l_upd_orig_table payment_item_tbl_type;
  l_del_orig_table payment_item_tbl_type;

  l_new_itm_table  payment_item_tbl_type;
  l_upd_itm_table  payment_item_tbl_type;
  l_del_itm_table  payment_item_tbl_type;

  l_adj_table      payment_item_tbl_type;

  l_last_appr_dt   DATE;
  l_info           VARCHAR2(100);
  l_desc           VARCHAR2(100) := 'pn_retro_adjustment_pkg.create_retro_adjustments';
  l_org_id         NUMBER;

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');

  FOR org_id_rec IN org_id_cur LOOP
     l_org_id := org_id_rec.org_id;
  END LOOP;

  create_virtual_schedules (
     p_start_date => p_term_start_dt,
     p_end_date   => p_term_end_dt,
     p_sch_day    => p_term_sch_day,
     p_amount     => p_term_act_amt,
     p_term_freq  => p_term_freq,
     p_payment_term_id => p_term_id,
     x_sched_tbl  => l_virtual_sched
  );

  get_current_schedules(
     p_term_id    => p_term_id,
     x_sched_tbl  => l_current_sched
  );

  merge_schedules(
     p_current_sched => l_current_sched,
     p_virtual_sched => l_virtual_sched,
     x_sched_tbl     => l_merged_sched
  );

  -- get last approved schedule date
  FOR date_rec IN get_last_appr_sched LOOP
     l_last_appr_dt := date_rec.schedule_date;
     exit;
  END LOOP;

  create_adjustment_tables(
     p_sched_table    => l_merged_sched,
     p_last_appr_dt   => l_last_appr_dt,
     p_term_freq      => p_term_freq,
     p_term_start_dt  => p_term_start_dt,
     p_term_end_dt    => p_term_end_dt,
     x_new_orig_table => l_new_orig_table,
     x_upd_orig_table => l_upd_orig_table,
     x_del_orig_table => l_del_orig_table,
     x_adj_table      => l_adj_table
  );

  -- for new items, find schedule id
  get_schedule_id_for_new_items(
     p_lease_id        => p_lease_id,
     p_term_id         => p_term_id,
     p_lease_change_id => p_lease_chg_id,
     p_sched_tbl       => l_new_orig_table
  );

  -- process original items
  process_items(
     p_term_id      => p_term_id,
     p_adj_type_cd  => null,
     p_upd_item_tbl => l_upd_orig_table,
     p_del_item_tbl => l_del_orig_table,
     p_new_item_tbl => l_new_orig_table
  );

  calculate_adjustment_details(
     p_adj_table     => l_adj_table,
     p_new_itm_table => l_new_itm_table,
     p_upd_itm_table => l_upd_itm_table,
     p_del_itm_table => l_del_itm_table
  );

  -- before deleting items, remove reference of items to be deleted
  -- from the adjustment table
  remove_item_reference(
     p_item_tbl     => l_del_itm_table
  );

  prepare_new_items_from_adj (
     p_sch_day      => p_term_sch_day,
     p_item_adj_tbl => l_new_itm_table,
     p_org_id       => l_org_id
  );

  -- for new items, find schedule id
  get_schedule_id_for_new_items(
     p_lease_id        => p_lease_id,
     p_term_id         => p_term_id,
     p_lease_change_id => p_lease_chg_id,
     p_sched_tbl       => l_new_itm_table
  );

  -- process adjustment items
  process_items(
     p_term_id      => p_term_id,
     p_adj_type_cd  => p_adj_type_cd,
     p_upd_item_tbl => l_upd_itm_table,
     p_del_item_tbl => l_del_itm_table,
     p_new_item_tbl => l_new_itm_table
  );

  populate_new_item_id(
     p_new_item_tbl => l_new_itm_table,
     p_adj_tbl      => l_adj_table
  );

  create_adjustment_entries(
     p_term_id       => p_term_id,
     p_term_freq     => p_term_freq,
     p_term_start_dt => p_term_start_dt,
     p_term_end_dt   => p_term_end_dt,
     p_term_hist_id  => p_term_hist_id,
     p_adj_table     => l_adj_table,
     p_org_id        => l_org_id
  );

  -- clean up schedules of deleted items (original and adjustment)
  cleanup_schedules(
     p_term_id       => p_term_id,
     p_orig_item_tbl => l_del_orig_table,
     p_adj_item_tbl  => l_del_itm_table
  );

  IF l_adj_table.COUNT > 0 THEN

     update_terms_history(
        p_term_hist_id    => p_term_hist_id,
        p_adj_type_cd     => p_adj_type_cd,
        p_lease_change_id => p_lease_chg_id,
        p_term_id         => p_term_id
     );

  END IF;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END create_retro_adjustments;


END pn_retro_adjustment_pkg;

/
