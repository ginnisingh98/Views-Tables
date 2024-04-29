--------------------------------------------------------
--  DDL for Package Body BIM_CAMP_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_CAMP_COLLECTION" AS
/*$Header: bimccolb.pls 120.1 2005/06/06 14:52:28 appldev  $*/
   g_pkg_name    CONSTANT VARCHAR2(40) := 'bim_camp_collection_new_t';
   g_file_name   CONSTANT VARCHAR2(40) := 'bimccolb.pls';
   PROCEDURE bim_dates_pop
   IS
      CURSOR c_month(l_date IN DATE)
      IS
         SELECT start_date
           FROM gl_periods
          WHERE period_type = 'Month'
            AND period_set_name =
                            fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER')
            AND TRUNC(start_date) >= TRUNC(l_date)
            AND TRUNC(start_date) <= SYSDATE
			AND ADJUSTMENT_PERIOD_FLAG ='N';
      CURSOR c_quarter(l_date IN DATE)
      IS
         SELECT start_date,
                period_num
           FROM gl_periods
          WHERE period_type = 'Quarter'
            AND period_set_name =
                            fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER')
            AND TRUNC(start_date) >= TRUNC(l_date)
            AND TRUNC(start_date) <= SYSDATE;
      CURSOR c_year(l_date IN DATE)
      IS
         SELECT start_date,
                period_num
           FROM gl_periods
          WHERE period_type = 'Year'
            AND period_set_name =
                            fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER')
            AND (   TRUNC(l_date) BETWEEN start_date AND end_date
                 OR TRUNC(l_date) < start_date
                )
            AND TRUNC(start_date) <= SYSDATE;
      l_min_start_date   DATE;
   BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bim_dates';
      SELECT MIN(start_date)
        INTO l_min_start_date
        FROM bim_rep_history
       WHERE OBJECT = 'CAMPAIGN';
      FOR x IN c_month(l_min_start_date)
      LOOP
         --BEGIN
         INSERT INTO bim_dates
                     (trdate,
                      creation_date,
                      last_update_date,
                      created_by,
                      last_updated_by,
                      last_update_login,
                      security_group_id,
                      fiscal_month,
                      fiscal_month_end,
                      fiscal_month_num,
                      fiscal_month_start,
                      fiscal_qtr,
                      fiscal_qtr_end,
                      fiscal_qtr_num,
                      fiscal_qtr_start,
                      fiscal_year,
                      fiscal_year_end,
                      fiscal_year_start,
                      pre_fiscal_month_end,
                      pre_fiscal_month_start,
                      pre_fiscal_qtr_end,
                      pre_fiscal_qtr_start,
                      pre_fiscal_year_end,
                      pre_fiscal_year_start,
                      period_type
                     )
            SELECT x.start_date,
                   SYSDATE,
                   SYSDATE,
                   -1,
                   -1,
                   -1,
                   -1,
                   bim_set_of_books.get_fiscal_month(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_num(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_start(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_num(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_start(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_month_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_month_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_qtr_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_qtr_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_year_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_year_start(x.start_date, 0),
                   'MONTH'
              FROM DUAL;

--commit;

      /* EXCEPTION
      WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
           END; */
      END LOOP;
-------------------------------------------------------------------------------------
      FOR x IN c_quarter(l_min_start_date)
      LOOP
         -- BEGIN
         INSERT INTO bim_dates
                     (trdate,
                      creation_date,
                      last_update_date,
                      created_by,
                      last_updated_by,
                      last_update_login,
                      security_group_id,
                      fiscal_month,
                      fiscal_month_end,
                      fiscal_month_num,
                      fiscal_month_start,
                      fiscal_qtr,
                      fiscal_qtr_end,
                      fiscal_qtr_num,
                      fiscal_qtr_start,
                      fiscal_year,
                      fiscal_year_end,
                      fiscal_year_start,
                      pre_fiscal_month_end,
                      pre_fiscal_month_start,
                      pre_fiscal_qtr_end,
                      pre_fiscal_qtr_start,
                      pre_fiscal_year_end,
                      pre_fiscal_year_start,
                      period_type
                     )
            SELECT x.start_date,
                   SYSDATE,
                   SYSDATE,
                   -1,
                   -1,
                   -1,
                   -1,
                   bim_set_of_books.get_fiscal_month(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_num(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_start(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_num(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_start(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_month_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_month_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_qtr_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_qtr_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_year_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_year_start(x.start_date, 0),
                   'QUARTER'
              FROM DUAL;

--commit;

      /* EXCEPTION
       WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
            END; */
      END LOOP;
-------------------------------------------------------------------------------------
      FOR x IN c_year(l_min_start_date)
      LOOP
         -- BEGIN
         INSERT INTO bim_dates
                     (trdate,
                      creation_date,
                      last_update_date,
                      created_by,
                      last_updated_by,
                      last_update_login,
                      security_group_id,
                      fiscal_month,
                      fiscal_month_end,
                      fiscal_month_num,
                      fiscal_month_start,
                      fiscal_qtr,
                      fiscal_qtr_end,
                      fiscal_qtr_num,
                      fiscal_qtr_start,
                      fiscal_year,
                      fiscal_year_end,
                      fiscal_year_start,
                      pre_fiscal_month_end,
                      pre_fiscal_month_start,
                      pre_fiscal_qtr_end,
                      pre_fiscal_qtr_start,
                      pre_fiscal_year_end,
                      pre_fiscal_year_start,
                      period_type
                     )
            SELECT x.start_date,
                   SYSDATE,
                   SYSDATE,
                   -1,
                   -1,
                   -1,
                   -1,
                   bim_set_of_books.get_fiscal_month(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_num(x.start_date, 0),
                   bim_set_of_books.get_fiscal_month_start(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_num(x.start_date, 0),
                   bim_set_of_books.get_fiscal_qtr_start(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year_end(x.start_date, 0),
                   bim_set_of_books.get_fiscal_year_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_month_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_month_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_qtr_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_qtr_start(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_year_end(x.start_date, 0),
                   bim_set_of_books.get_pre_fiscal_year_start(x.start_date, 0),
                   'YEAR'
              FROM DUAL;
--commit;
      /* EXCEPTION
       WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE));
            END; */
      END LOOP;
-------------------------------------------------------------------------------------
   /* EXCEPTION
   WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM(SQLCODE)); */
   END bim_dates_pop;
-----------------------------------------------------------------------------------------
   PROCEDURE get_increment_mqy_data
   IS
      l_org_id                       NUMBER;
      l_fiscal_month                 VARCHAR2(10);
      l_fiscal_month_end             DATE;
      l_fiscal_month_start           DATE;
      l_pre_fiscal_month_end         DATE;
      l_pre_fiscal_month_start       DATE;
      l_pre_pre_fiscal_month_start   DATE;
      l_fiscal_qtr                   VARCHAR2(10);
      l_fiscal_qtr_end               DATE;
      l_fiscal_qtr_start             DATE;
      l_pre_fiscal_qtr_end           DATE;
      l_pre_fiscal_qtr_start         DATE;
      l_fiscal_roll_year_start       DATE;
      l_fiscal_year                  VARCHAR2(10);
      l_fiscal_year_end              DATE;
      l_fiscal_year_start            DATE;
      l_pre_fiscal_year_end          DATE;
      l_pre_fiscal_year_start        DATE;
      --l_pre_fiscal_roll_year_end           DATE;
      l_pre_fiscal_roll_year_start   DATE;
      l_min_start_date               DATE;
      l_sysdate  date := trunc(sysdate);--'02-SEP-2000';
      sysdate_1  date := TRUNC(SYSDATE- 1);
      CURSOR chk_history_data
      IS
         SELECT MIN(start_date)
           FROM bim_rep_history
          WHERE OBJECT = 'CAMPAIGN';
   BEGIN
      OPEN chk_history_data;
      FETCH chk_history_data INTO l_min_start_date;
      CLOSE chk_history_data;
      l_org_id := 0;
      l_fiscal_month := bim_set_of_books.get_fiscal_month(l_SYSDATE - 1, l_org_id);
      l_fiscal_month_end := bim_set_of_books.get_fiscal_month_end(l_SYSDATE - 1, l_org_id);
      l_fiscal_month_start := bim_set_of_books.get_fiscal_month_start(l_SYSDATE - 1, l_org_id);
      l_pre_fiscal_month_end := bim_set_of_books.get_fiscal_month_end(l_fiscal_month_start - 1,l_org_id);
      l_pre_fiscal_month_start := bim_set_of_books.get_pre_fiscal_month_start(l_SYSDATE - 1, l_org_id);
      l_fiscal_qtr := bim_set_of_books.get_fiscal_qtr(l_SYSDATE - 1, l_org_id);
      l_fiscal_qtr_end := bim_set_of_books.get_fiscal_qtr_end(l_SYSDATE - 1, l_org_id);
      l_fiscal_qtr_start := bim_set_of_books.get_fiscal_qtr_start(l_SYSDATE - 1, l_org_id);
      l_pre_fiscal_qtr_end := bim_set_of_books.get_fiscal_qtr_end(l_fiscal_qtr_start - 1, l_org_id);
      l_pre_fiscal_qtr_start := bim_set_of_books.get_pre_fiscal_qtr_start(l_SYSDATE - 1, l_org_id);
      l_fiscal_roll_year_start := bim_set_of_books.get_fiscal_roll_year_start(l_SYSDATE - 1, l_org_id);
      l_fiscal_year := bim_set_of_books.get_fiscal_year(l_SYSDATE - 1, l_org_id);
      l_fiscal_year_end := bim_set_of_books.get_fiscal_year_end(l_SYSDATE - 1, l_org_id);
      l_fiscal_year_start := bim_set_of_books.get_fiscal_year_start(l_SYSDATE - 1, l_org_id);
      l_pre_fiscal_roll_year_start := bim_set_of_books.get_pre_fiscal_roll_year_start(l_SYSDATE - 1,l_org_id);
  --   EXECUTE IMMEDIATE 'TRUNCATE TABLE bim_r_camp_collection';
/* START OF THE INCREMENT DATA INSERT */
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: INCREMENT INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
           bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   report_type,
                   YEAR,
                   qtr,
                   MONTH,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	         'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                   resource_id,
                  'N' campaign_type,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  'BIN' report_type,
                  'N' YEAR,
                  'N' qtr,
                  'N' MONTH,
                  SUM(curr_count_value) current_count_value,
                  SUM(curr_started_value) current_started_value,
                  SUM(curr_ended_value) current_ended_value,
                  SUM(prev_count_value) previous_count_value,
                  SUM(prev_started_value) previous_started_value,
                  SUM(prev_ended_value) previous_ended_value
             FROM (SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
	                a.campaign_id campaign_id,
	                   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                           'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 1)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 2)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                          WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                      GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
				a.campaign_id campaign_id,
				c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 8)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 8)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 15)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 15)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          TRUNC(  SYSDATE
                                                                                - 8)),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id

                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
				a.campaign_id campaign_id,
				c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                           'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_month_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id

                     GROUP BY
			a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
			a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_qtr_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                       GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
			a.campaign_id campaign_id,
			c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            l_fiscal_roll_year_start
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			GROUP BY
			a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type

				  ---------- for admin
				  union all
				  -------------

	SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	         'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                   -1 resource_id,
                  'N' campaign_type,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  'BIN' report_type,
                  'N' YEAR,
                  'N' qtr,
                  'N' MONTH,
                  SUM(curr_count_value) current_count_value,
                  SUM(curr_started_value) current_started_value,
                  SUM(curr_ended_value) current_ended_value,
                  SUM(prev_count_value) previous_count_value,
                  SUM(prev_started_value) previous_started_value,
                  SUM(prev_ended_value) previous_ended_value
             FROM (SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
	                a.campaign_id campaign_id,
	                   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                           'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 1)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 2)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                          WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                      GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
				a.campaign_id campaign_id,
				c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 8)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 8)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 15)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 15)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          TRUNC(  SYSDATE
                                                                                - 8)),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
				a.campaign_id campaign_id,
				c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                           'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_month_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                     GROUP BY
			a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
			a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_qtr_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                       GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0)
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
			a.campaign_id campaign_id,
			c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) curr_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            l_fiscal_roll_year_start
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			GROUP BY
			a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0))
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  aggregate_by,
                  display_type;

	---------union all admin end

--commit;

/* END OF THE INCREMENT DATA INSERT */
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: INCREMENT INSERT END');
/* START OF THE MONTH, QUARTER ,YEAR DATA INSERT */
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: Q/M/Y INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
           bim_r_camp_collection  i
                  (schedule_area2,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   current_count_value,
                   previous_count_value,
                   current_started_value,
                   previous_started_value,
                   current_ended_value,
                   previous_ended_value,
                   report_type
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	          schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month,
                  SUM(curr_count) curr_count,
                  SUM(pre_count) pre_count,
                  SUM(curr_started) curr_started,
                  SUM(pre_started) pre_started,
                  SUM(curr_ended) curr_ended,
                  SUM(pre_ended) pre_ended,
                  'BIN' report_type
             FROM (
-- FOR THE PERIOD TYPE MONTH
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d)  */
		            a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.fiscal_month_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),

                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.pre_fiscal_month_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                      b.pre_fiscal_month_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             COUNT(schedule_id) curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,
		          c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             COUNT(schedule_id) pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.pre_fiscal_month_start
                                                  AND(b.fiscal_month_start - 1
                                                     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             COUNT(schedule_id) curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.fiscal_month_start
                                   AND b.fiscal_month_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             COUNT(schedule_id) pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.pre_fiscal_month_start
                                   AND(b.fiscal_month_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month

		  ---------- for admin
				  union all
				  -------------

				SELECT
	          schedule_area2,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month,
                  SUM(curr_count) curr_count,
                  SUM(pre_count) pre_count,
                  SUM(curr_started) curr_started,
                  SUM(pre_started) pre_started,
                  SUM(curr_ended) curr_ended,
                  SUM(pre_ended) pre_ended,
                  'BIN' report_type
             FROM (
-- FOR THE PERIOD TYPE MONTH
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d)  */
		            a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.fiscal_month_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),

                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.pre_fiscal_month_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                      b.pre_fiscal_month_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             COUNT(schedule_id) curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,
		          c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             COUNT(schedule_id) pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.pre_fiscal_month_start
                                                  AND(b.fiscal_month_start - 1
                                                     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             COUNT(schedule_id) curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.fiscal_month_start
                                   AND b.fiscal_month_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             COUNT(schedule_id) pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.pre_fiscal_month_start
                                   AND(b.fiscal_month_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month)
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month;

---------union all admin end
--commit;
-- FOR THE PERIOD TYPE QTR
      INSERT INTO  /*+ append parallel(i,5) */
                 bim_r_camp_collection i
                  (schedule_area2,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   current_count_value,
                   previous_count_value,
                   current_started_value,
                   previous_started_value,
                   current_ended_value,
                   previous_ended_value,
                   report_type
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */ schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month,
                  SUM(curr_count) curr_count,
                  SUM(pre_count) pre_count,
                  SUM(curr_started) curr_started,
                  SUM(pre_started) pre_started,
                  SUM(curr_ended) curr_ended,
                  SUM(pre_ended) pre_ended,
                  'BIN' report_type
             FROM (SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
	                     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.fiscal_qtr_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.pre_fiscal_qtr_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                        b.pre_fiscal_qtr_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             COUNT(schedule_id) curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
                                                  AND b.fiscal_qtr_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             COUNT(schedule_id) pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.pre_fiscal_qtr_start
                                                  AND(b.fiscal_qtr_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             COUNT(schedule_id) curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.fiscal_qtr_start
                                   AND b.fiscal_qtr_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             COUNT(schedule_id) pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.pre_fiscal_qtr_start
                                   AND(b.fiscal_qtr_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month

	  ---------- for admin
				  union all
				  -------------


				  SELECT   schedule_area2,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month,
                  SUM(curr_count) curr_count,
                  SUM(pre_count) pre_count,
                  SUM(curr_started) curr_started,
                  SUM(pre_started) pre_started,
                  SUM(curr_ended) curr_ended,
                  SUM(pre_ended) pre_ended,
                  'BIN' report_type
             FROM (SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
	                     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.fiscal_qtr_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.pre_fiscal_qtr_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                        b.pre_fiscal_qtr_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             COUNT(schedule_id) curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
                                                  AND b.fiscal_qtr_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             COUNT(schedule_id) pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.pre_fiscal_qtr_start
                                                  AND(b.fiscal_qtr_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             COUNT(schedule_id) curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.fiscal_qtr_start
                                   AND b.fiscal_qtr_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)    use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             COUNT(schedule_id) pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.pre_fiscal_qtr_start
                                   AND(b.fiscal_qtr_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            'N')
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month;


				  ---------union all admin end
--commit;
-- FOR THE PERIOD TYPE YEAR
      INSERT INTO  /*+ append parallel(i,5) */
              bim_r_camp_collection i
                  (schedule_area2,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   current_count_value,
                   previous_count_value,
                   current_started_value,
                   previous_started_value,
                   current_ended_value,
                   previous_ended_value,
                   report_type
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
		  schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month,
                  SUM(curr_count) curr_count,
                  SUM(pre_count) pre_count,
                  SUM(curr_started) curr_started,
                  SUM(pre_started) pre_started,
                  SUM(curr_ended) curr_ended,
                  SUM(pre_ended) pre_ended,
                  'BIN' report_type
             FROM (SELECT   /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
	                     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.fiscal_year_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.pre_fiscal_year_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                       b.pre_fiscal_year_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
	                     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             COUNT(schedule_id) curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             COUNT(schedule_id) pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.pre_fiscal_year_start
                                                  AND(b.fiscal_year_start - 1
                                                     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,
		           c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             COUNT(schedule_id) curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.fiscal_year_start
                                   AND b.fiscal_year_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             COUNT(schedule_id) pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.pre_fiscal_year_start
                                   AND(b.fiscal_year_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month

	  ---------- for admin
				  union all
				  -------------

				  SELECT
		  schedule_area2,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month,
                  SUM(curr_count) curr_count,
                  SUM(pre_count) pre_count,
                  SUM(curr_started) curr_started,
                  SUM(pre_started) pre_started,
                  SUM(curr_ended) curr_ended,
                  SUM(pre_ended) pre_ended,
                  'BIN' report_type
             FROM (SELECT   /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
	                     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.fiscal_year_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) < b.pre_fiscal_year_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                       b.pre_fiscal_year_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
	                     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             COUNT(schedule_id) curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             COUNT(schedule_id) pre_started,
                             0 curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) BETWEEN b.pre_fiscal_year_start
                                                  AND(b.fiscal_year_start - 1
                                                     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,
		           c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             COUNT(schedule_id) curr_ended,
                             0 pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.fiscal_year_start
                                   AND b.fiscal_year_end
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N'
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             COUNT(schedule_id) pre_ended
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date))
                               BETWEEN b.pre_fiscal_year_start
                                   AND(b.fiscal_year_start - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            b.fiscal_year,
                            'N',
                            'N')
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month;



				  ---------union all admin end
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: Q/M/Y COUNT UPDATE END');
/* END OF THE MONTH, QUARTER ,YEAR DATA INSERT */
   EXCEPTION
      WHEN OTHERS
      THEN
         ams_utility_pvt.write_conc_log(   'BIM_CAMP_COLLECTION:IN OTHERS EXCEPTION '
                                        || SQLERRM(SQLCODE));
         --dbms_utility.FORMAT_ERROR_STACK );
   END get_increment_mqy_data;
-------------------------------------------------------------------------------------------
---
--PROCEDURE TO GET THE SUMMARY DATA
---
------------------------------------------------------------------------------------------
   PROCEDURE get_summary_data
   IS
      l_org_id                       NUMBER;
      l_fiscal_month                 VARCHAR2(10);
      l_fiscal_month_end             DATE;
      l_fiscal_month_start           DATE;
      l_pre_fiscal_month_end         DATE;
      l_pre_fiscal_month_start       DATE;
      l_pre_pre_fiscal_month_start   DATE;
      l_fiscal_qtr                   VARCHAR2(10);
      l_fiscal_qtr_end               DATE;
      l_fiscal_qtr_start             DATE;
      l_pre_fiscal_qtr_end           DATE;
      l_pre_fiscal_qtr_start         DATE;
      l_fiscal_roll_year_start       DATE;
      l_fiscal_year                  VARCHAR2(10);
      l_fiscal_year_end              DATE;
      l_fiscal_year_start            DATE;
      l_pre_fiscal_year_end          DATE;
      l_pre_fiscal_year_start        DATE;
      --l_pre_fiscal_roll_year_end    DATE;
      l_pre_fiscal_roll_year_start   DATE;
      l_min_start_date               DATE;
      l_sysdate  date := trunc(sysdate);--'02-SEP-2000';
      sysdate_1  date := TRUNC(SYSDATE- 1);
      CURSOR chk_history_data
      IS
         SELECT MIN(start_date)
           FROM bim_rep_history
          WHERE OBJECT = 'CAMPAIGN';
   BEGIN
      OPEN chk_history_data;
      FETCH chk_history_data INTO l_min_start_date;
      CLOSE chk_history_data;
      l_org_id := 0;
      l_fiscal_month := bim_set_of_books.get_fiscal_month(l_SYSDATE - 1, l_org_id);
      l_fiscal_month_end := bim_set_of_books.get_fiscal_month_end(l_SYSDATE - 1, l_org_id);
      l_fiscal_month_start := bim_set_of_books.get_fiscal_month_start(l_SYSDATE - 1, l_org_id);
      l_pre_fiscal_month_end := bim_set_of_books.get_fiscal_month_end(l_fiscal_month_start - 1,l_org_id);
      l_pre_fiscal_month_start :=bim_set_of_books.get_pre_fiscal_month_start(l_SYSDATE - 1, l_org_id);
      l_fiscal_qtr := bim_set_of_books.get_fiscal_qtr(l_SYSDATE - 1, l_org_id);
      l_fiscal_qtr_end :=bim_set_of_books.get_fiscal_qtr_end(l_SYSDATE - 1, l_org_id);
      l_fiscal_qtr_start :=bim_set_of_books.get_fiscal_qtr_start(l_SYSDATE - 1, l_org_id);
      l_pre_fiscal_qtr_end :=bim_set_of_books.get_fiscal_qtr_end(l_fiscal_qtr_start - 1, l_org_id);
      l_pre_fiscal_qtr_start :=bim_set_of_books.get_pre_fiscal_qtr_start(l_SYSDATE - 1, l_org_id);
      l_fiscal_roll_year_start :=bim_set_of_books.get_fiscal_roll_year_start(l_SYSDATE - 1, l_org_id);
      l_fiscal_year := bim_set_of_books.get_fiscal_year(l_SYSDATE - 1, l_org_id);
      l_fiscal_year_end :=bim_set_of_books.get_fiscal_year_end(l_SYSDATE - 1, l_org_id);
      l_fiscal_year_start :=bim_set_of_books.get_fiscal_year_start(l_SYSDATE - 1, l_org_id);
      l_pre_fiscal_roll_year_start :=bim_set_of_books.get_pre_fiscal_roll_year_start(l_SYSDATE - 1,l_org_id);
--commit;
      --EXECUTE IMMEDIATE 'TRUNCATE TABLE bim_r_camp_collection';
/* START OF THE INCREMENT DATA FIRST INSERT */
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: INCREMENT FIRST INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
              bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   schedule_activity,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  'N' YEAR,
                  'N' qtr,
                  'N' MONTH,
                  'ACT' report_type,
                  SUM(curr_count_value) current_count_value,
                  SUM(curr_started_value) current_started_value,
                  SUM(curr_ended_value) current_ended_value,
                  SUM(prev_count_value) previous_count_value,
                  SUM(prev_started_value) previous_started_value,
                  SUM(prev_ended_value) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			   a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 1)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_count_value,
	--*** added curr_started_value to curr_count_value
/*
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_ended_value,
*/
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 2)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) +  SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_count_value,

--*** added prev_started_value to prev_count_value
/*
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_ended_value,
*/
                            0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=SYSDATE - 2
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(B) use_hash(C)  */
			   a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 8)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--*** started value is added to count value

 /*                           SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 8)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_ended_value,
*/

			    SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 15)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 15)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          TRUNC(  SYSDATE
                                                                                - 8)),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=SYSDATE - 15
                   GROUP BY a.campaign_id,
		            c.area1_code,
                            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			   a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--***
/*

                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
*/

                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_count_value,

--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_month_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=l_pre_fiscal_month_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			    a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
*/

                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_count_value,
--***
/*

                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_qtr_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/

			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=l_pre_fiscal_qtr_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			    a.campaign_id ,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
*/
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            l_fiscal_roll_year_start
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/

			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
			    0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=l_pre_fiscal_roll_year_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
-------------------------------------------------------------------------------------
--START OF CAMPAIGN COUNT CODE
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***  <= will get both active and started campaigns for DAY diaplay_type
                        AND trunc(a.start_date_time) <= TRUNC(SYSDATE - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                            TRUNC(SYSDATE - 1)

                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < TRUNC(SYSDATE - 8)
			     or
                             trunc(a.start_date_time) between TRUNC(SYSDATE - 8) and TRUNC(  SYSDATE
                                                                                  - 1)
                             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                            TRUNC(SYSDATE - 8)

                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		           a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < l_fiscal_month_start
			     or
                             trunc(a.start_date_time) between l_fiscal_month_start and TRUNC(  SYSDATE
                                                                                  - 1)
                             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                          l_fiscal_month_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < l_fiscal_qtr_start
			     or
                             trunc(a.start_date_time) between l_fiscal_qtr_start and TRUNC(  SYSDATE
                                                                                  - 1)
                              )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                            l_fiscal_qtr_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < l_fiscal_roll_year_start
			     or
                             trunc(a.start_date_time) between l_fiscal_roll_year_start and TRUNC(  SYSDATE
                                                                                  - 1)
                             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                      l_fiscal_roll_year_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
---START OF METRICS CODE FOR FRESP, TCUST, BAPPROVED
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), forecasted_responses,
                                       0
                                      )) forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), targeted_customers,
                                       0
                                      )) targeted_customers,

					SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 2)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +    SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 2), targeted_customers,
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), budget_approved,
                                       0
                                      )) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		           and trunc(a.start_date) <=  sysdate_1
			   and trunc(a.end_date) >= SYSDATE - 2
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     )))  forecasted_responses,

                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      ))+ SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ))) targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 15)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,

                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ))) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			     and trunc(a.end_date) >= SYSDATE - 15
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      ))  +

				 SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      ))  budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
			    and trunc(a.end_date) >= l_pre_fiscal_month_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      )) targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			     and trunc(a.end_date) >= l_pre_fiscal_qtr_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      ))  + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      )) forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      )) targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved
                       FROM bim_r_camp_daily_facts a,
		           jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			     and trunc(a.end_date) >= l_pre_fiscal_roll_year_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
                  ),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type


	  ---------- for admin
				  union all
				  -------------

		 SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  'N' YEAR,
                  'N' qtr,
                  'N' MONTH,
                  'ACT' report_type,
                  SUM(curr_count_value) current_count_value,
                  SUM(curr_started_value) current_started_value,
                  SUM(curr_ended_value) current_ended_value,
                  SUM(prev_count_value) previous_count_value,
                  SUM(prev_started_value) previous_started_value,
                  SUM(prev_ended_value) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			   a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 1)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_count_value,
	--*** added curr_started_value to curr_count_value
/*
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_ended_value,
*/
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 2)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) +  SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_count_value,

--*** added prev_started_value to prev_count_value
/*
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_ended_value,
*/
                            0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >= SYSDATE - 2
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(B) use_hash(C)  */
			   a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 8)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--*** started value is added to count value

 /*                           SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 8)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_ended_value,
*/

			    SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 15)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 15)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          TRUNC(  SYSDATE
                                                                                - 8)),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=SYSDATE - 15
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY a.campaign_id,
		            c.area1_code,
                            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			   a.campaign_id campaign_id,
			   c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--***
/*

                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_month_start),
                                       TRUNC(end_date_time), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
*/

                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_count_value,

--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_month_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=l_pre_fiscal_month_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			    a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
*/

                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_count_value,
--***
/*

                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_qtr_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/

			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=l_pre_fiscal_qtr_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
			    a.campaign_id ,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
*/
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            l_fiscal_roll_year_start
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/

			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_started_value,
                            0 prev_ended_value,
			    0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
			and trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=l_pre_fiscal_roll_year_start
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
-------------------------------------------------------------------------------------
--START OF CAMPAIGN COUNT CODE
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***  <= will get both active and started campaigns for DAY diaplay_type
                        AND trunc(a.start_date_time) <= TRUNC(SYSDATE - 1)
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                            TRUNC(SYSDATE - 1)
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < TRUNC(SYSDATE - 8)
			     or
                             trunc(a.start_date_time) between TRUNC(SYSDATE - 8) and TRUNC(  SYSDATE
                                                                                  - 1)
                             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                            TRUNC(SYSDATE - 8)
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		           a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < l_fiscal_month_start
			     or
                             trunc(a.start_date_time) between l_fiscal_month_start and TRUNC(  SYSDATE
                                                                                  - 1)
                             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                          l_fiscal_month_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < l_fiscal_qtr_start
			     or
                             trunc(a.start_date_time) between l_fiscal_qtr_start and TRUNC(  SYSDATE
                                                                                  - 1)
                              )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                            l_fiscal_qtr_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(B) use_hash(C)  */
		            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.country_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ) schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            COUNT(DISTINCT a.campaign_id) campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
--***
                        AND (trunc(a.start_date_time) < l_fiscal_roll_year_start
			     or
                             trunc(a.start_date_time) between l_fiscal_roll_year_start and TRUNC(  SYSDATE
                                                                                  - 1)
                             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND trunc(NVL(a.end_date_time, b.actual_exec_end_date)) >=
                                                      l_fiscal_roll_year_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(b.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  )
------------------------------------------------------------------------------------------------
---START OF METRICS CODE FOR FRESP, TCUST, BAPPROVED
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
			    c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), forecasted_responses,
                                       0
                                      )) forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), targeted_customers,
                                       0
                                      )) targeted_customers,

					SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 2)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +    SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 2), targeted_customers,
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), budget_approved,
                                       0
                                      )) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			     and trunc(a.end_date) >= SYSDATE - 2
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     )))  forecasted_responses,

                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      ))+ SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ))) targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 15)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,

                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ))) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			      and trunc(a.end_date) >= SYSDATE - 15
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      ))  +

				 SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      ))  budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			      and trunc(a.end_date) >= l_pre_fiscal_month_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      )) targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
			    and trunc(a.end_date) >= l_pre_fiscal_qtr_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)  use_hash(C)  */
		            a.campaign_id campaign_id,
		            c.area2_code schedule_area2,
                            a.schedule_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.schedule_activity_id schedule_activity_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      ))  + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      )) forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      )) targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
		             and trunc(a.start_date) <=  sysdate_1
			     and trunc(a.end_date) >= l_pre_fiscal_roll_year_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id
                  )
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type;


				  ---------union all admin end


/* END OF THE INCREMENT DATA FIRST INSERT */

--commit;
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: INCREMENT FIRST INSERT END');
/* START OF THE INCREMENT DATA SECOND INSERT */
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: INCREMENT SECOND INSERT START');


      INSERT INTO   /*+ append parallel(i,5) */
                bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   campaign_id,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  'N' YEAR,
                  'N' qtr,
                  'N' MONTH,
                  'CAMP' report_type,
                  SUM(curr_count_value) current_count_value,
                  SUM(curr_started_value) current_started_value,
                  SUM(curr_ended_value) current_ended_value,
                  SUM(prev_count_value) previous_count_value,
                  SUM(prev_started_value) previous_started_value,
                  SUM(prev_ended_value) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (SELECT /*+ use_hash(A)    use_hash(B) use_hash(C)  */
	                   c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 1)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_count_value,
--*** added curr_started_value to curr_count_value
 /*                           SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 2)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		           c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 8)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--*** started value is added to count value
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 8)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 15)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 15)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          TRUNC(  SYSDATE
                                                                                - 8)),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		            c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  curr_count_value,
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_month_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		            c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_qtr_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		            c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            l_fiscal_roll_year_start
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
-----------------------------------------------------------------------------------------------
---
---START OF METRICS CODE FOR FRESP, TCUST, BAPPROVED
---
-----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(C)  */
		           c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), forecasted_responses,
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), targeted_customers,
                                       0
                                      ))   targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 2)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                           0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), budget_approved,
                                       0
                                      )) budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)   use_hash(C)  */
		           c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     )))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     )))  targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 15)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                                0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ))) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)   use_hash(C)  */
		            c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      )) targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                           0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      ))  budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(A)   use_hash(C)  */
		            c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                           0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)   use_hash(C)  */
		            c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                           0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		            and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
                  ),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  campaign_id,
                  aggregate_by,
                  display_type
         HAVING   SUM(curr_count_value) > 0
               OR SUM(curr_started_value) > 0
               OR SUM(curr_ended_value) > 0
               OR SUM(prev_count_value) > 0
               OR SUM(prev_started_value) > 0
               OR SUM(prev_ended_value) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0

			     ---------- for admin
				  union all
				  -------------

SELECT
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  'N' YEAR,
                  'N' qtr,
                  'N' MONTH,
                  'CAMP' report_type,
                  SUM(curr_count_value) current_count_value,
                  SUM(curr_started_value) current_started_value,
                  SUM(curr_ended_value) current_ended_value,
                  SUM(prev_count_value) previous_count_value,
                  SUM(prev_started_value) previous_started_value,
                  SUM(prev_ended_value) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (SELECT /*+ use_hash(A)    use_hash(B) use_hash(C)  */
	                   c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 1)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_count_value,
--*** added curr_started_value to curr_count_value
 /*                           SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 1), 1,
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 2)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                       TRUNC(SYSDATE - 2), 1,
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		           c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 8)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--*** started value is added to count value
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 8)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      TRUNC(  SYSDATE
                                                                                            - 15)),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                TRUNC(SYSDATE - 15)),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            TRUNC(  SYSDATE
                                                                                  - 8)),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                TRUNC(SYSDATE - 15)),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          TRUNC(  SYSDATE
                                                                                - 8)),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		            c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  curr_count_value,
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_month_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_month_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_month_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_month_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_month_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		            c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_qtr_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_qtr_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                            l_pre_fiscal_qtr_end),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_qtr_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                          l_pre_fiscal_qtr_end),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)    use_hash(B) use_hash(C)  */
		            c.area2_code schedule_area2,
                            b.city_id schedule_country,
                            NVL(b.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      ))  curr_count_value,
--***
/*
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) curr_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            SYSDATE
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) curr_ended_value,
                            SUM(DECODE(TRUNC(start_date_time),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date_time),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date_time), DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                                      l_pre_fiscal_roll_year_start),
                                                                             trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                             0
                                                                            ),
                                              0
                                             )
                                      )) prev_count_value,
                            SUM(DECODE(GREATEST(TRUNC(start_date_time),
                                                l_pre_fiscal_roll_year_start),
                                       TRUNC(start_date_time), DECODE(LEAST(TRUNC(start_date_time),
                                                                              l_fiscal_roll_year_start
                                                                            - 1),
                                                                      TRUNC(start_date_time), 1,
                                                                      0
                                                                     ),
                                       0
                                      )) prev_started_value,
                            SUM(DECODE(GREATEST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                l_pre_fiscal_roll_year_start),
                                       trunc(NVL(a.end_date_time, b.actual_exec_end_date)), DECODE(LEAST(trunc(NVL(a.end_date_time, b.actual_exec_end_date)),
                                                                            l_fiscal_roll_year_start
                                                                          - 1),
                                                                    trunc(NVL(a.end_date_time, b.actual_exec_end_date)), 1,
                                                                    0
                                                                   ),
                                       0
                                      )) prev_ended_value,
*/
			    0 curr_started_value,
			    0 curr_ended_value,
			    0 prev_count_value,
			    0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            0 forecasted_responses,
                            0 targeted_customers,
                            0 prev_targeted_customers,
                            0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b b
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                        AND trunc(a.start_date_time) >= l_min_start_date
			and trunc(a.start_date_time) <= sysdate_1
                        AND b.city_id = c.location_hierarchy_id
                        AND a.campaign_id = b.campaign_id
                   GROUP BY c.area2_code,
                            b.city_id,
                            NVL(b.business_unit_id, 0),
                            a.campaign_id
-----------------------------------------------------------------------------------------------
---
---START OF METRICS CODE FOR FRESP, TCUST, BAPPROVED
---
-----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT  /*+ use_hash(A)   use_hash(C)  */
		           c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'DAY' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), forecasted_responses,
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), targeted_customers,
                                       0
                                      ))   targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 2), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 2)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 2)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                             0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 1)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 1)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 1), budget_approved,
                                       0
                                      )) budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		       and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)   use_hash(C)  */
		           c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'WEEK' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     )))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     )))  targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 15), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 15)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 15)),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                         0  prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       TRUNC(SYSDATE - 8), 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    TRUNC(SYSDATE - 8)),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 TRUNC(  SYSDATE
                                                                                       - 8)),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +  SUM(DECODE(GREATEST(TRUNC(start_date),
                                                TRUNC(SYSDATE - 8)),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                            TRUNC(  SYSDATE
                                                                                  - 1)),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ))) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		       and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)   use_hash(C)  */
		            c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'MONTH' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      )) targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_month_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                           0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_month_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_month_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_month_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) +
				      SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_month_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      ))  budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		       and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(A)   use_hash(C)  */
		            c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'QUARTER' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_qtr_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                            0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_qtr_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_qtr_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_qtr_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_qtr_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		       and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
------------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------------
                   SELECT   /*+ use_hash(A)   use_hash(C)  */
		            c.area2_code schedule_area2,
                            a.campaign_country schedule_country,
                            NVL(a.business_unit_id, 0) business_unit_id,
                            a.campaign_id campaign_id,
                            'INCREMENT' aggregate_by,
                            'YEAR' display_type,
                            0 curr_count_value,
                            0 curr_started_value,
                            0 curr_ended_value,
                            0 prev_count_value,
                            0 prev_started_value,
                            0 prev_ended_value,
                            0 campaign_count,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), forecasted_responses,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), forecasted_responses,
                                                                      0
                                                                     ),
                                       0
                                      ))  forecasted_responses,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), targeted_customers,
                                                                      0
                                                                     ),
                                       0
                                      ))  targeted_customers,
--***
/*
                            SUM(DECODE(TRUNC(start_date),
                                       l_pre_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_pre_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_pre_fiscal_roll_year_start),
                                                                        TRUNC(end_date), targeted_customers,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) prev_targeted_customers,
*/
                            0 prev_targeted_customers,
                            SUM(DECODE(TRUNC(start_date),
                                       l_fiscal_roll_year_start, 0,
                                       DECODE(LEAST(TRUNC(start_date),
                                                    l_fiscal_roll_year_start),
                                              TRUNC(start_date), DECODE(GREATEST(TRUNC(end_date),
                                                                                 l_fiscal_roll_year_start),
                                                                        TRUNC(end_date), budget_approved,
                                                                        0
                                                                       ),
                                              0
                                             )
                                      )) + SUM(DECODE(GREATEST(TRUNC(start_date),
                                                l_fiscal_roll_year_start),
                                       TRUNC(start_date), DECODE(LEAST(TRUNC(start_date),
                                                                              SYSDATE
                                                                            - 1),
                                                                      TRUNC(start_date), budget_approved,
                                                                      0
                                                                     ),
                                       0
                                      )) budget_approved

                       FROM bim_r_camp_daily_facts a,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
		       and trunc(a.start_date) <=  sysdate_1
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id
                  )
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
   --***               resource_id,
                  campaign_id,
                  aggregate_by,
                  display_type
         HAVING   SUM(curr_count_value) > 0
               OR SUM(curr_started_value) > 0
               OR SUM(curr_ended_value) > 0
               OR SUM(prev_count_value) > 0
               OR SUM(prev_started_value) > 0
               OR SUM(prev_ended_value) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0;

				  ---------union all admin end


	       --commit;

/* END OF THE INCREMENT DATA SECOND INSERT */
/* START OF THE MONTH, QUARTER ,YEAR DATA INSERT */
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY ACT MONTH INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
            bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   schedule_activity,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT   /* +INDEX_FFS(R,BIM_DBI_U2) */
	         'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'ACT' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE MONTH
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
              --***
	                AND (trunc(a.start_date_time) < b.fiscal_month_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
			     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
         --***
	                AND (trunc(a.start_date_time) < b.pre_fiscal_month_start
			     or
                             trunc(a.start_date_time) BETWEEN b.pre_fiscal_month_start
			                     AND (b.fiscal_month_start - 1  )
		             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                      b.pre_fiscal_month_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             COUNT(DISTINCT a.campaign_id) campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
       --***
                  AND (trunc(a.start_date_time) < b.fiscal_month_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
			     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY a.campaign_id ,
		             c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		            a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
        --***
	               AND ( trunc(a.start_date) < b.fiscal_month_start
		                  or
			    trunc(a.start_date)  between b.fiscal_month_start and b.fiscal_month_end
                           )
                        AND trunc(a.end_date) >= b.fiscal_month_start
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             SUM(targeted_customers) prev_targeted_customers,
                             0 budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
       --***
                       AND (trunc(a.start_date) < b.pre_fiscal_month_start
		            or
                           trunc(a.start_date) BETWEEN b.pre_fiscal_month_start
			                       and (b.fiscal_month_start - 1  )
		            )
                        AND trunc(a.end_date) >= b.pre_fiscal_month_start
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month

		  ---------- for admin
				  union all
				  -------------
				  SELECT
	         'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'ACT' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE MONTH
                   SELECT    /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
		             		 a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
        --***
	                AND (trunc(a.start_date_time) < b.fiscal_month_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
			     )

                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
          --***
	                AND (trunc(a.start_date_time) < b.pre_fiscal_month_start
			     or
                             trunc(a.start_date_time) BETWEEN b.pre_fiscal_month_start
			                     AND (b.fiscal_month_start - 1  )
		             )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'MONTH'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                      b.pre_fiscal_month_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             COUNT(DISTINCT a.campaign_id) campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
         --***
	                AND (trunc(a.start_date_time) < b.fiscal_month_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
			     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY a.campaign_id ,
		             c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		            a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
        --***
	               AND ( trunc(a.start_date) < b.fiscal_month_start
		                  or
			    trunc(a.start_date)  between b.fiscal_month_start and b.fiscal_month_end
                           )
                        AND trunc(a.end_date) >= b.fiscal_month_start
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT    /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
		             a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             SUM(targeted_customers) prev_targeted_customers,
                             0 budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
        --***
                         AND (trunc(a.start_date) < b.pre_fiscal_month_start
		            or
                           trunc(a.start_date) BETWEEN b.pre_fiscal_month_start
			                       and ( b.fiscal_month_start - 1  )
		            )

                        AND trunc(a.end_date) >= b.pre_fiscal_month_start
                        AND b.period_type = 'MONTH'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month)
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month;

				  ---------union all admin end


--commit;


      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY ACT MONTH INSERT END');
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY ACT QTR INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
        bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   schedule_activity,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT   /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'ACT' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE QTR
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
			a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
        --***
	                 AND (trunc(a.start_date_time) < b.fiscal_qtr_start
			      or
			      trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'QUARTER'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY a.campaign_id,
			    c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
			    a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
       --***
                        AND ( trunc(a.start_date_time) < b.pre_fiscal_qtr_start
			     or
			     trunc(a.start_date_time) BETWEEN b.pre_fiscal_qtr_start
			                        and (b.fiscal_qtr_start - 1)
			     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                        b.pre_fiscal_qtr_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
			     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             COUNT(DISTINCT a.campaign_id) campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
            --***
	                 AND (trunc(a.start_date_time) < b.fiscal_qtr_start
			      or
			      trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'QUARTER'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
			    a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
     --***
                           AND (trunc(a.start_date) < b.fiscal_qtr_start
			        or
                                trunc(a.start_date) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND trunc(a.end_date) >= b.fiscal_qtr_start
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             SUM(targeted_customers) prev_targeted_customers,
                             0 budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
       --***
                          AND (trunc(a.start_date) < b.pre_fiscal_qtr_start
			         or
			      trunc(a.start_date)  BETWEEN b.pre_fiscal_qtr_start
			                        and (b.fiscal_qtr_start - 1)
			     )
                        AND trunc(a.end_date) >= b.pre_fiscal_qtr_start
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr) ,ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month

  ---------- for admin
				  union all
				  -------------


				  SELECT   /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                 -1 resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'ACT' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE QTR
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
			a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
        --***
	                 AND (trunc(a.start_date_time) < b.fiscal_qtr_start
			      or
			      trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'QUARTER'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY a.campaign_id,
			    c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
			    a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
         --***
                        AND ( trunc(a.start_date_time) < b.pre_fiscal_qtr_start
			     or
			     trunc(a.start_date_time) BETWEEN b.pre_fiscal_qtr_start
			                        and (b.fiscal_qtr_start - 1)
			     )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'QUARTER'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                        b.pre_fiscal_qtr_start
                   GROUP BY a.campaign_id,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
			     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             COUNT(DISTINCT a.campaign_id) campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
    --***
	                 AND (trunc(a.start_date_time) < b.fiscal_qtr_start
			      or
			      trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'QUARTER'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
			    a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
        --***
                           AND (trunc(a.start_date) < b.fiscal_qtr_start
			        or
                                trunc(a.start_date) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND trunc(a.end_date) >= b.fiscal_qtr_start
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             SUM(targeted_customers) prev_targeted_customers,
                             0 budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
      --***
                          AND (trunc(a.start_date) < b.pre_fiscal_qtr_start
			         or
			      trunc(a.start_date)  BETWEEN b.pre_fiscal_qtr_start
			                        and (b.fiscal_qtr_start - 1)
			     )
                        AND trunc(a.end_date) >= b.pre_fiscal_qtr_start
                        AND b.period_type = 'QUARTER'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year,
                            b.fiscal_qtr)
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month;






--------union all admin end


 --commit;


      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY ACT QTR INSERT END');
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY ACT YEAR INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
	bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   schedule_activity,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	           'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'ACT' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE YEAR
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
                --***
                         AND (trunc(a.start_date_time) < b.fiscal_year_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'YEAR'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY a.campaign_id ,
			   c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
			     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
            --***
	               AND (trunc(a.start_date_time) < b.pre_fiscal_year_start
		            or
			    trunc(a.start_date_time) BETWEEN b.pre_fiscal_year_start
                                                  AND(b.fiscal_year_start - 1
                                                     )
			    )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                       b.pre_fiscal_year_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
			    a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             COUNT(DISTINCT a.campaign_id) campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
          --***
                         AND (trunc(a.start_date_time) < b.fiscal_year_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
			      )

                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'YEAR'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c)  */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
       --***
                     AND ( trunc(a.start_date) < b.fiscal_year_start
		          or
			   trunc(a.start_date) between b.fiscal_year_start
                                                  AND b.fiscal_year_end
			  )
                        AND trunc(a.end_date) >= b.fiscal_year_start
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c)  */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             SUM(targeted_customers) prev_targeted_customers,
                             0 budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
       --***
                        AND (trunc(a.start_date) < b.pre_fiscal_year_start
			     or
			     trunc(a.start_date) between b.pre_fiscal_year_start
                                                  AND(b.fiscal_year_start - 1
                                                     )
			    )
                        AND trunc(a.end_date) >= b.pre_fiscal_year_start
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
	  ---------- for admin
				  union all
				  -------------



	SELECT
	           'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  schedule_activity_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'ACT' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE YEAR
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
          --***
                         AND (trunc(a.start_date_time) < b.fiscal_year_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'YEAR'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY a.campaign_id ,
			   c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
			     a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             COUNT(a.schedule_id) pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
          --***
	               AND (trunc(a.start_date_time) < b.pre_fiscal_year_start
		            or
			    trunc(a.start_date_time) BETWEEN b.pre_fiscal_year_start
                                                  AND(b.fiscal_year_start - 1
                                                     )
			    )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND b.period_type = 'YEAR'
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                       b.pre_fiscal_year_start
                   GROUP BY a.campaign_id,
		            c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
			    a.campaign_id campaign_id,
                             c.area2_code schedule_area2,
                             a.country_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             DECODE(a.activity_type_code,
                                    'EVENTS', -9999,
                                    a.activity_id
                                   ) schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             COUNT(DISTINCT a.campaign_id) campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
           --***
                         AND (trunc(a.start_date_time) < b.fiscal_year_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
			      )
                        AND a.country_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'YEAR'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.country_id,
                            NVL(d.business_unit_id, 0),
                            DECODE(a.activity_type_code,
                                   'EVENTS', -9999,
                                   a.activity_id
                                  ),
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c)  */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
        --***
                     AND ( trunc(a.start_date) < b.fiscal_year_start
		          or
			  trunc(a.start_date) between b.fiscal_year_start
                                                  AND b.fiscal_year_end
			  )

                        AND trunc(a.end_date) >= b.fiscal_year_start
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c)  */
                             a.campaign_id campaign_id,
			     c.area2_code schedule_area2,
                             a.schedule_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.schedule_activity_id schedule_activity_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             SUM(targeted_customers) prev_targeted_customers,
                             0 budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.schedule_country = c.location_hierarchy_id
         --***
	              AND (trunc(a.start_date) < b.pre_fiscal_year_start
		            or
			   trunc(a.start_date) BETWEEN b.pre_fiscal_year_start
                                                  AND(b.fiscal_year_start - 1
                                                     )
			    )
                        AND trunc(a.end_date) >= b.pre_fiscal_year_start
                        AND b.period_type = 'YEAR'
                   GROUP BY a.campaign_id ,
		            c.area2_code,
                            a.schedule_country,
                            NVL(a.business_unit_id, 0),
                            a.schedule_activity_id,
                            b.fiscal_year)
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  schedule_activity_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month;

	---------union all admin end





 --commit;


      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY ACT QTR INSERT END');
---------------------------------------------------------------------------------------
-- START OF CAMP SUMMARY DATA
--------------------------------------------------------------------------------------
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY CAMP MONTH INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
           bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   campaign_id,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT   /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'CAMP' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE MONTH
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             c.area2_code schedule_area2,
                             d.city_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
    --***
	                AND (trunc(a.start_date_time) < b.fiscal_month_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
			     )
                        AND d.city_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY c.area2_code,
                            d.city_id,
                            NVL(d.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c)  */
                             c.area2_code schedule_area2,
                             a.campaign_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
     --***
	               AND ( trunc(a.start_date) < b.fiscal_month_start
		                  or
			    trunc(a.start_date)  between b.fiscal_month_start and b.fiscal_month_end
                           )
                        AND trunc(a.end_date) >= b.fiscal_month_start
                        AND b.period_type = 'MONTH'
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month)
 ,ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  campaign_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
           HAVING SUM(curr_count) > 0
               OR SUM(curr_started) > 0
               OR SUM(curr_ended) > 0
               OR SUM(pre_count) > 0
               OR SUM(pre_started) > 0
               OR SUM(pre_ended) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0

			  ---------- for admin
				  union all
				  -------------


				  SELECT
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'CAMP' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE MONTH
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             c.area2_code schedule_area2,
                             d.city_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')

 --***
	                AND (trunc(a.start_date_time) < b.fiscal_month_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_month_start
                                                  AND b.fiscal_month_end
			     )
                        AND d.city_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'MONTH'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                          b.fiscal_month_start
                   GROUP BY c.area2_code,
                            d.city_id,
                            NVL(d.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c)  */
                             c.area2_code schedule_area2,
                             a.campaign_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'MONTH' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             b.fiscal_month fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
            --***
	               AND ( trunc(a.start_date) < b.fiscal_month_start
		                  or
			    trunc(a.start_date)  between b.fiscal_month_start and b.fiscal_month_end
                           )
                        AND trunc(a.end_date) >= b.fiscal_month_start
                        AND b.period_type = 'MONTH'
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr,
                            b.fiscal_month)
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  campaign_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
           HAVING SUM(curr_count) > 0
               OR SUM(curr_started) > 0
               OR SUM(curr_ended) > 0
               OR SUM(pre_count) > 0
               OR SUM(pre_started) > 0
               OR SUM(pre_ended) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0;

			   ---------union all admin end


 --commit;

      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY CAMP QTR INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
             bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   campaign_id,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT
/* +INDEX_FFS(R,BIM_DBI_U2) */
                  'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'CAMP' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE QUARTER
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
                             c.area2_code schedule_area2,
                             d.city_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
      --***
	                 AND (trunc(a.start_date_time) < b.fiscal_qtr_start
			      or
			      trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
			                               and b.fiscal_qtr_end
			      )
                        AND d.city_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'QUARTER'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY c.area2_code,
                            d.city_id,
                            NVL(d.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) */
                             c.area2_code schedule_area2,
                             a.campaign_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
     --***
                           AND (trunc(a.start_date) < b.fiscal_qtr_start
			        or
                                trunc(a.start_date) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND trunc(a.end_date) >= b.fiscal_qtr_start
                        AND b.period_type = 'QUARTER'
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr) ,ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  campaign_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
           HAVING SUM(curr_count) > 0
               OR SUM(curr_started) > 0
               OR SUM(curr_ended) > 0
               OR SUM(pre_count) > 0
               OR SUM(pre_started) > 0
               OR SUM(pre_ended) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0

  ---------- for admin
				  union all
				  -------------

				SELECT

                  'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'CAMP' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE QUARTER
                   SELECT
                        /*+ use_hash(a)   use_hash(b)  use_hash(c) use_hash(d) */
                             c.area2_code schedule_area2,
                             d.city_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
     --***
	                 AND (trunc(a.start_date_time) < b.fiscal_qtr_start
			      or
			      trunc(a.start_date_time) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND d.city_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'QUARTER'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                            b.fiscal_qtr_start
                   GROUP BY c.area2_code,
                            d.city_id,
                            NVL(d.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) */
                             c.area2_code schedule_area2,
                             a.campaign_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'QTR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             b.fiscal_qtr fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
    --***
                           AND (trunc(a.start_date) < b.fiscal_qtr_start
			        or
                                trunc(a.start_date) BETWEEN b.fiscal_qtr_start
			                             and b.fiscal_qtr_end
			      )
                        AND trunc(a.end_date) >= b.fiscal_qtr_start
                        AND b.period_type = 'QUARTER'
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year,
                            b.fiscal_qtr)
			      GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  campaign_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
           HAVING SUM(curr_count) > 0
               OR SUM(curr_started) > 0
               OR SUM(curr_ended) > 0
               OR SUM(pre_count) > 0
               OR SUM(pre_started) > 0
               OR SUM(pre_ended) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0;


---------union all admin end


--commit;

      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY CAMP QTR INSERT END');
      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY CAMP YEAR INSERT START');
      INSERT INTO  /*+ append parallel(i,5) */
           bim_r_camp_collection i
                  (campaign_area1,
                   campaign_area2,
                   schedule_area1,
                   schedule_area2,
                   campaign_country,
                   schedule_country,
                   business_unit_id,
                   resource_id,
                   campaign_type,
                   campaign_id,
                   schedule_activity_type,
                   campaign_status,
                   schedule_status,
                   aggregate_by,
                   display_type,
                   YEAR,
                   qtr,
                   MONTH,
                   report_type,
                   current_count_value,
                   current_started_value,
                   current_ended_value,
                   previous_count_value,
                   previous_started_value,
                   previous_ended_value,
                   campaign_count,
                   forecasted_responses,
                   targeted_customers,
                   prev_targeted_customers,
                   budget_approved
                  )
         SELECT  /* +INDEX_FFS(R,BIM_DBI_U2) */
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'CAMP' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE YEAR
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             c.area2_code schedule_area2,
                             d.city_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
         --***
                         AND (trunc(a.start_date_time) < b.fiscal_year_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
			      )
                        AND d.city_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'YEAR'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY c.area2_code,
                            d.city_id,
                            NVL(d.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c)  */
                             c.area2_code schedule_area2,
                             a.campaign_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
          --***
                     AND ( trunc(a.start_date) < b.fiscal_year_start
		          or
			  trunc(a.start_date) between b.fiscal_year_start
                                                  AND b.fiscal_year_end
			  )
                        AND trunc(a.end_date) >= b.fiscal_year_start
                        AND b.period_type = 'YEAR'
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year),ams_act_access_denorm R
			    where campaign_id=r.object_id
			    and r.object_type='CAMP'
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  resource_id,
                  campaign_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
           HAVING SUM(curr_count) > 0
               OR SUM(curr_started) > 0
               OR SUM(curr_ended) > 0
               OR SUM(pre_count) > 0
               OR SUM(pre_started) > 0
               OR SUM(pre_ended) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0



			     ---------- for admin
				  union all
				  -------------

				  SELECT
	          'N' campaign_area1,
                  'N' campaign_area2,
                  'N' schedule_area1,
                  schedule_area2,
                  'N' campaign_country,
                  schedule_country,
                  business_unit_id,
                  -1 resource_id,
                  'N' campaign_type,
                  campaign_id,
                  'N' schedule_activity_type,
                  'N' campaign_status,
                  'N' schedule_status,
                  aggregate_by,
                  display_type,
                  fiscal_year YEAR,
                  fiscal_qtr qtr,
                  fiscal_month MONTH,
                  'CAMP' report_type,
                  SUM(curr_count) current_count_value,
                  SUM(curr_started) current_started_value,
                  SUM(curr_ended) current_ended_value,
                  SUM(pre_count) previous_count_value,
                  SUM(pre_started) previous_started_value,
                  SUM(pre_ended) previous_ended_value,
                  SUM(campaign_count) campaign_count,
                  SUM(forecasted_responses) forecasted_responses,
                  SUM(targeted_customers) targeted_customers,
                  SUM(prev_targeted_customers) prev_targeted_customers,
                  SUM(budget_approved) budget_approved
             FROM (
-- FOR THE PERIOD TYPE YEAR
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c) use_hash(d) */
                             c.area2_code schedule_area2,
                             d.city_id schedule_country,
                             NVL(d.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             COUNT(a.schedule_id) curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             0 forecasted_responses,
                             0 targeted_customers,
                             0 prev_targeted_customers,
                             0 budget_approved
                       FROM ams_campaign_schedules_b a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c,
                            ams_campaigns_all_b d
                      WHERE a.status_code IN
                                ('ACTIVE', 'CANCELLED', 'COMPLETED', 'CLOSED')
         --***
                         AND (trunc(a.start_date_time) < b.fiscal_year_start
			     or
			     trunc(a.start_date_time) BETWEEN b.fiscal_year_start
                                                  AND b.fiscal_year_end
			      )
                        AND d.city_id = c.location_hierarchy_id
                        AND a.campaign_id = d.campaign_id
                        AND b.period_type = 'YEAR'
                        AND trunc(a.start_date_time) >= l_min_start_date
                        AND trunc(NVL(a.end_date_time, d.actual_exec_end_date)) >=
                                                           b.fiscal_year_start
                   GROUP BY c.area2_code,
                            d.city_id,
                            NVL(d.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year
------------------------------------------------------------------------------------------
                   UNION ALL
------------------------------------------------------------------------------------------
                   SELECT
                        /*+ use_hash(a)  use_hash(b)  use_hash(c)  */
                             c.area2_code schedule_area2,
                             a.campaign_country schedule_country,
                             NVL(a.business_unit_id, 0) business_unit_id,
                             a.campaign_id campaign_id,
                             'YEAR' aggregate_by,
                             'Z' display_type,
                             b.fiscal_year fiscal_year,
                             'N' fiscal_qtr,
                             'N' fiscal_month,
                             0 curr_count,
                             0 pre_count,
                             0 curr_started,
                             0 pre_started,
                             0 curr_ended,
                             0 pre_ended,
                             0 campaign_count,
                             SUM(forecasted_responses) forecasted_responses,
                             SUM(targeted_customers) targeted_customers,
                             0 prev_targeted_customers,
                             SUM(budget_approved) budget_approved
                       FROM bim_r_camp_daily_facts a,
                            bim_dates b,
                            jtf_loc_hierarchies_b c
                      WHERE a.campaign_country = c.location_hierarchy_id
        --***
                     AND (trunc(a.start_date) < b.fiscal_year_start
		          or
			  trunc(a.start_date) between b.fiscal_year_start
                                                  AND b.fiscal_year_end
			  )
                        AND trunc(a.end_date) >= b.fiscal_year_start
                        AND b.period_type = 'YEAR'
                   GROUP BY c.area2_code,
                            a.campaign_country,
                            NVL(a.business_unit_id, 0),
                            a.campaign_id,
                            b.fiscal_year)
         GROUP BY schedule_area2,
                  schedule_country,
                  business_unit_id,
                  campaign_id,
                  aggregate_by,
                  display_type,
                  fiscal_year,
                  fiscal_qtr,
                  fiscal_month
           HAVING SUM(curr_count) > 0
               OR SUM(curr_started) > 0
               OR SUM(curr_ended) > 0
               OR SUM(pre_count) > 0
               OR SUM(pre_started) > 0
               OR SUM(pre_ended) > 0
               OR SUM(targeted_customers) > 0
               OR SUM(prev_targeted_customers) > 0
               OR SUM(forecasted_responses) > 0
               OR SUM(budget_approved) <> 0;


				  ---------union all admin end


 --commit;

      ams_utility_pvt.write_conc_log('BIM_CAMP_COLLECTION: SUMMARY CAMP QTR INSERT END');
   EXCEPTION
      WHEN OTHERS
      THEN
         ams_utility_pvt.write_conc_log(   'BIM_CAMP_COLLECTION:IN OTHERS EXCEPTION '|| SQLERRM(SQLCODE));
   END get_summary_data;
END bim_camp_collection;

/
