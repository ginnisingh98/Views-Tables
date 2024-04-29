--------------------------------------------------------
--  DDL for Package HXT_TIME_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIME_DETAIL" AUTHID CURRENT_USER AS
/* $Header: hxttdet.pkh 120.1.12010000.2 2009/06/08 17:50:04 asrajago ship $ */

   TYPE parent_to_rexplode_info IS RECORD (
      parent_id   NUMBER
   );

   TYPE parent_to_rexplode_table IS TABLE OF parent_to_rexplode_info
      INDEX BY BINARY_INTEGER;

   g_parent_to_re_explode    parent_to_rexplode_table;



   -- Bug 7359347
   -- Global variable to hold session date.
   g_det_session_date        DATE;



   TYPE re_explode_det_info IS RECORD (
      earn_pol_id            NUMBER,
      parent_id              NUMBER,
      tim_id                 NUMBER,
      date_worked            DATE,
      assignment_id          NUMBER,
      hours                  NUMBER,
      time_in                DATE,
      time_out               DATE,
      element_type_id        NUMBER,
      fcl_earn_reason_code   hxt_det_hours_worked.fcl_earn_reason_code%TYPE,
      ffv_cost_center_id     hxt_det_hours_worked.ffv_cost_center_id%TYPE,
      tas_id                 hxt_det_hours_worked.tas_id%TYPE,
      location_id            hxt_det_hours_worked.location_id%TYPE,
      sht_id                 hxt_det_hours_worked.sht_id%TYPE,
      hrw_comment            hxt_det_hours_worked.hrw_comment%TYPE,
      ffv_rate_code_id       hxt_det_hours_worked.ffv_rate_code_id%TYPE,
      rate_multiple          hxt_det_hours_worked.rate_multiple%TYPE,
      hourly_rate            hxt_det_hours_worked.hourly_rate%TYPE,
      amount                 hxt_det_hours_worked.amount%TYPE,
      fcl_tax_rule_code      hxt_det_hours_worked.fcl_tax_rule_code%TYPE,
      separate_check_flag    hxt_det_hours_worked.separate_check_flag%TYPE,
      seqno                  hxt_det_hours_worked.seqno%TYPE,
      created_by             hxt_det_hours_worked.created_by%TYPE,
      creation_date          hxt_det_hours_worked.creation_date%TYPE,
      last_updated_by        hxt_det_hours_worked.last_updated_by%TYPE,
      last_update_date       hxt_det_hours_worked.last_update_date%TYPE,
      last_update_login      hxt_det_hours_worked.last_update_login%TYPE,
      effective_start_date   hxt_det_hours_worked.effective_start_date%TYPE,
      effective_end_date     hxt_det_hours_worked.effective_end_date%TYPE,
      project_id             hxt_det_hours_worked.project_id%TYPE,
      job_id                 hxt_det_hours_worked.job_id%TYPE,
      STATE_NAME             hxt_det_hours_worked_f.STATE_NAME%TYPE,
      COUNTY_NAME            hxt_det_hours_worked_f.COUNTY_NAME%TYPE,
      CITY_NAME              hxt_det_hours_worked_f.CITY_NAME%TYPE,
      ZIP_CODE               hxt_det_hours_worked_f.ZIP_CODE%TYPE
);

   TYPE re_explode_det_table IS TABLE OF re_explode_det_info
      INDEX BY BINARY_INTEGER;

   g_re_explode_detail       re_explode_det_table;

   TYPE special_explosion IS RECORD (
      element_type_id   NUMBER,
      hours_to_pay      NUMBER
   );

   TYPE special_explosion_table IS TABLE OF special_explosion
      INDEX BY BINARY_INTEGER;

   g_special_explosion       special_explosion_table;

   TYPE daily_explosion IS RECORD (
      element_type_id    NUMBER,
      hours_to_pay       NUMBER,
      earning_category   hxt_pay_element_types_f_ddf_v.hxt_earning_category%TYPE
   );

   TYPE daily_explosion_table IS TABLE OF daily_explosion
      INDEX BY BINARY_INTEGER;

   g_daily_explosion         daily_explosion_table;

   TYPE weekly_explosion IS RECORD (
      element_type_id    NUMBER,
      hours_to_pay       NUMBER,
      earning_category   hxt_pay_element_types_f_ddf_v.hxt_earning_category%TYPE
   );

   TYPE weekly_explosion_table IS TABLE OF weekly_explosion
      INDEX BY BINARY_INTEGER;

   g_weekly_explosion        weekly_explosion_table;

   TYPE day_week_combo_explosion IS RECORD (
      element_type_id   NUMBER,
      hours_to_pay      NUMBER
   );

   TYPE day_week_combo_table IS TABLE OF weekly_explosion
      INDEX BY BINARY_INTEGER;

   g_dy_wk_combo_explosion   day_week_combo_table;

   TYPE daily_earn_category IS RECORD (
      element_type_id    NUMBER,
      hours              NUMBER,
      earning_category   hxt_pay_element_types_f_ddf_v.hxt_earning_category%TYPE
   );

   TYPE daily_earn_category_table IS TABLE OF daily_earn_category
      INDEX BY BINARY_INTEGER;

   g_daily_earn_category     daily_earn_category_table;

   TYPE weekly_earn_category IS RECORD (
      element_type_id    NUMBER,
      hours              NUMBER,
      earning_category   hxt_pay_element_types_f_ddf_v.hxt_earning_category%TYPE
   );

   TYPE weekly_earn_category_table IS TABLE OF weekly_earn_category
      INDEX BY BINARY_INTEGER;

   g_weekly_earn_category    weekly_earn_category_table;
   g_count                   NUMBER                     := 0;
   g_explosion_to_use        VARCHAR2 (9)               := NULL;

   CURSOR reg_cur (p_tim_id NUMBER)
   IS
      SELECT hrw.ROWID hrw_rowid, hrw.hours, hrw.date_worked, hrw.parent_id,
             hrw.assignment_id, hrw.fcl_earn_reason_code,
             hrw.ffv_cost_center_id, hrw.tas_id, hrw.location_id, hrw.sht_id,
             hrw.hrw_comment, hrw.ffv_rate_code_id, hrw.rate_multiple,
             hrw.hourly_rate, hrw.amount, hrw.fcl_tax_rule_code,
             hrw.separate_check_flag, hrw.project_id, hrw.job_id,

             -- hrw.GROUP_ID,
             hrw.earn_pol_id
        FROM hxt_pay_element_types_f_ddf_v eltv,
             pay_element_types_f elt,
             hxt_det_hours_worked hrw
       WHERE hrw.tim_id = p_tim_id
         AND hrw.date_worked =
                (SELECT MAX (hrw.date_worked)
                   FROM hxt_pay_element_types_f_ddf_v eltv,
                        pay_element_types_f elt,
                        hxt_det_hours_worked hrw
                  WHERE hrw.tim_id = p_tim_id
                    AND NVL (hrw.hours, 0) > 0
                    AND elt.element_type_id = hrw.element_type_id
                    AND eltv.hxt_earning_category = 'REG'
                    AND hrw.date_worked BETWEEN elt.effective_start_date
                                            AND elt.effective_end_date
                    AND eltv.element_type_id = elt.element_type_id
                    AND hrw.date_worked BETWEEN eltv.effective_start_date
                                            AND eltv.effective_end_date)
         AND NVL (hrw.hours, 0) > 0
         AND elt.element_type_id = hrw.element_type_id
         AND eltv.hxt_earning_category = 'REG'
         AND hrw.date_worked BETWEEN elt.effective_start_date
                                 AND elt.effective_end_date
         AND eltv.element_type_id = elt.element_type_id
         AND hrw.date_worked BETWEEN eltv.effective_start_date
                                 AND eltv.effective_end_date;

   FUNCTION generate_special (
      p_ep_id                  IN   NUMBER,
      p_ep_type                IN   VARCHAR2,
      p_egt_id                 IN   NUMBER,
      p_sdf_id                 IN   NUMBER,
      p_hdp_id                 IN   NUMBER,
      p_hol_id                 IN   NUMBER,
      p_sdp_id                 IN   NUMBER,
      p_pep_id                 IN   NUMBER,
      p_pip_id                 IN   NUMBER,
      p_sdovr_id               IN   NUMBER,
      p_osp_id                 IN   NUMBER,
      p_hol_yn                 IN   VARCHAR2,
      p_person_id              IN   NUMBER,
      p_location               IN   VARCHAR2,
      p_id                     IN   NUMBER,
      p_tim_id                 IN   NUMBER,
      p_date_worked            IN   DATE,
      p_assignment_id          IN   NUMBER,
      p_hours                  IN   NUMBER,
      p_time_in                IN   DATE,
      p_time_out               IN   DATE,
      p_element_type_id        IN   NUMBER,
      p_fcl_earn_reason_code   IN   VARCHAR2,
      p_ffv_cost_center_id     IN   NUMBER,
      p_ffv_labor_account_id   IN   NUMBER,
      p_tas_id                 IN   NUMBER,
      p_location_id            IN   NUMBER,
      p_sht_id                 IN   NUMBER,
      p_hrw_comment            IN   VARCHAR2,
      p_ffv_rate_code_id       IN   NUMBER,
      p_rate_multiple          IN   NUMBER,
      p_hourly_rate            IN   NUMBER,
      p_amount                 IN   NUMBER,
      p_fcl_tax_rule_code      IN   VARCHAR2,
      p_separate_check_flag    IN   VARCHAR2,
      p_seqno                  IN   NUMBER,
      p_created_by             IN   NUMBER,
      p_creation_date          IN   DATE,
      p_last_updated_by        IN   NUMBER,
      p_last_update_date       IN   DATE,
      p_last_update_login      IN   NUMBER,
      p_start_day_of_week      IN   VARCHAR2,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE,
      p_project_id             IN   NUMBER,
      p_job_id                 IN   NUMBER,
      p_pay_status             IN   VARCHAR2,
      p_pa_status              IN   VARCHAR2,
      p_retro_batch_id         IN   NUMBER,
      p_period_start_date      IN   DATE,
      p_call_adjust_abs        IN   VARCHAR2,
      p_STATE_NAME             IN VARCHAR2 DEFAULT NULL,
      p_COUNTY_NAME            IN VARCHAR2 DEFAULT NULL,
      p_CITY_NAME              IN VARCHAR2 DEFAULT NULL,
      p_ZIP_CODE               IN VARCHAR2 DEFAULT NULL
--p_GROUP_ID              IN NUMBER
   )
      RETURN NUMBER;
END;

/
