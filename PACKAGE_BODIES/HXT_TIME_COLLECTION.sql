--------------------------------------------------------
--  DDL for Package Body HXT_TIME_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIME_COLLECTION" AS
/* $Header: hxttcol.pkb 120.8.12010000.7 2009/07/02 08:26:01 asrajago ship $ */

   /*-------------------------------------------------------------------------
||
||                     Private Module Declarations
||
-------------------------------------------------------------------------*/

   -- Global package name
   g_debug              BOOLEAN          := hr_utility.debug_enabled;
   g_package   CONSTANT VARCHAR2 (33)    := 'hxt_time_collection.';
   g_cache              BOOLEAN          := TRUE;
   g_max_tc_allowed     PLS_INTEGER   := fnd_profile.VALUE ('HXT_BATCH_SIZE');

   TYPE batch_info_rec IS RECORD (
      batch_id    pay_batch_headers.batch_id%TYPE,
      batch_ref   pay_batch_headers.batch_reference%TYPE,
      period_id   per_time_periods.time_period_id%TYPE,
      num_tcs     NUMBER
   );

   TYPE batch_info_table IS TABLE OF batch_info_rec
      INDEX BY BINARY_INTEGER;

   g_batch_info         batch_info_table;

   FUNCTION CACHE
      RETURN BOOLEAN
   IS
      l_proc   VARCHAR2 (72);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'cache';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF (g_cache)
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('   returning g_cache = TRUE', 20);
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location ('   returning g_cache = FALSE', 30);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 100);
      END IF;

      RETURN g_cache;
   END CACHE;

   PROCEDURE set_cache (p_cache IN BOOLEAN)
   IS
      l_proc   VARCHAR2 (72);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'set_cache';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF (p_cache)
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('   setting g_cache to TRUE', 20);
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location ('   setting g_cache to FALSE', 30);
         END IF;
      END IF;

      g_cache := p_cache;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 100);
      END IF;
   END set_cache;

   FUNCTION round_time (p_time DATE, p_interval NUMBER, p_round_up NUMBER)
      RETURN DATE;

   FUNCTION check_time_overlap (
      p_date       DATE,
      p_time_in    DATE,
      p_time_out   DATE,
      p_id         NUMBER,
      p_tim_id     NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION reset_hours (p_in IN DATE, p_out IN DATE)
      RETURN NUMBER;

--END SIR236
   FUNCTION get_time_period (
      i_payroll_id    IN              NUMBER,
      i_date_worked   IN              DATE,
      o_time_period   OUT NOCOPY      NUMBER,
      o_start_date    OUT NOCOPY      DATE,
      o_end_date      OUT NOCOPY      DATE
   )
      RETURN NUMBER;

   FUNCTION check_for_timecard (
      i_person_id        IN              NUMBER,
      i_time_period_id   IN              NUMBER,
      o_timecard_id      OUT NOCOPY      NUMBER,
      o_auto_gen_flag    OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION create_timecard (
      i_person_id              IN              NUMBER,
      i_business_group_id      IN              NUMBER,
      i_assignment_id          IN              NUMBER,
      i_payroll_id             IN              NUMBER,
      i_time_period_id         IN              NUMBER,
      i_approver_id            IN              NUMBER,
      i_timecard_source_code   IN              VARCHAR2,
      o_timecard_id            OUT NOCOPY      NUMBER
   )
      RETURN NUMBER;

   FUNCTION create_batch (
      i_source              IN              VARCHAR2,
      i_payroll_id          IN              NUMBER,
      i_time_period_id      IN              NUMBER,
      i_assignment_id       IN              NUMBER,
      i_person_id           IN              NUMBER,
      i_business_group_id   IN              NUMBER,
      o_batch_id            OUT NOCOPY      NUMBER
   )
      RETURN NUMBER;

   FUNCTION find_existing_batch (
      p_time_period_id    IN   per_time_periods.time_period_id%TYPE,
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE
   )
      RETURN pay_batch_headers.batch_id%TYPE;

   FUNCTION create_holiday_hours (
      i_person_id                 IN              NUMBER,
      i_hcl_id                    IN              NUMBER,
      i_hxt_rotation_plan         IN              NUMBER,             --SIR344
      i_start_date                IN              DATE,
      i_end_date                  IN              DATE,
      i_timecard_id               IN              NUMBER,
      i_wage_code                 IN              VARCHAR2,
      i_task_id                   IN              NUMBER,
      i_location_id               IN              NUMBER,
      i_project_id                IN              hxt_sum_hours_worked.project_id%TYPE,
      i_earn_pol_id               IN              hxt_sum_hours_worked.earn_pol_id%TYPE,
      i_earn_reason_code          IN              VARCHAR2,
      i_comment                   IN              VARCHAR2,
      i_rate_multiple             IN              NUMBER,
      i_hourly_rate               IN              NUMBER,
      i_amount                    IN              NUMBER,
      i_separate_check_flag       IN              VARCHAR2,
      i_assignment_id             IN              NUMBER,
      i_time_summary_id           IN              NUMBER,
      i_tim_sum_eff_start_date    IN              DATE,
      i_tim_sum_eff_end_date      IN              DATE,
      i_created_by                IN              NUMBER,
      i_last_updated_by           IN              NUMBER,
      i_last_update_login         IN              NUMBER,
      i_writesum_yn               IN              VARCHAR2,
      i_explode_yn                IN              VARCHAR2,
      i_batch_status              IN              VARCHAR2,
      i_dt_update_mode            IN              VARCHAR2,           --SIR290
      p_time_building_block_id    IN              NUMBER DEFAULT NULL,
      p_time_building_block_ovn   IN              NUMBER DEFAULT NULL,
      o_otm_error                 OUT NOCOPY      VARCHAR2,
      o_oracle_error              OUT NOCOPY      VARCHAR2,
      o_created_tim_sum_id        OUT NOCOPY      NUMBER,
      i_start_time                IN              DATE,
      i_end_time                  IN              DATE,
      i_state_name                IN              VARCHAR2 DEFAULT NULL,
      i_county_name               IN              VARCHAR2 DEFAULT NULL,
      i_city_name                 IN              VARCHAR2 DEFAULT NULL,
      i_zip_code                  IN              VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

   --p_mode IN VARCHAR2 default 'INSERT') RETURN NUMBER;
   FUNCTION check_for_batch_status (
      i_batch_id       IN              NUMBER,
      o_batch_status   OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;

   PROCEDURE load_policies (
      p_summ_id                 IN              NUMBER,
      p_summ_earn_pol_id        IN              NUMBER,
      p_summ_assignment_id      IN              NUMBER,
      p_summ_date_worked        IN              DATE,
      p_work_plan               OUT NOCOPY      NUMBER,
      p_rotation_plan           OUT NOCOPY      NUMBER,
      p_rotation_or_work_plan   OUT NOCOPY      VARCHAR2
                                                        --   ,p_retcode             OUT NOCOPY NUMBER
                                                        -- ,p_hours                OUT NOCOPY NUMBER
   ,
      p_shift_hours             OUT NOCOPY      NUMBER,
      p_egp_id                  OUT NOCOPY      hxt_sum_hours_worked.earn_pol_id%TYPE -- 5903580 NUMBER        earning policy
                                                      ,
      p_hdp_id                  OUT NOCOPY      NUMBER -- hrs deduction policy
                                                      -- ,p_hdy_id               OUT NOCOPY NUMBER     -- holiday day ID
   ,
      p_sdp_id                  OUT NOCOPY      NUMBER    -- shift diff policy
                                                      ,
      p_egp_type                OUT NOCOPY      VARCHAR2
                                                        -- earning policy type
   ,
      p_egt_id                  OUT NOCOPY      NUMBER
                                                      -- include earning group
   ,
      p_pep_id                  OUT NOCOPY      NUMBER     -- prem elig policy
                                                      ,
      p_pip_id                  OUT NOCOPY      NUMBER -- prem interact policy
                                                      ,
      p_hcl_id                  OUT NOCOPY      NUMBER     -- holiday calendar
                                                      ,
      p_hcl_elt_id              OUT NOCOPY      NUMBER -- holiday earning type
                                                      ,
      p_sdf_id                  OUT NOCOPY      NUMBER  -- override shift diff
                                                      ,
      p_osp_id                  OUT NOCOPY      NUMBER       -- off-shift prem
                                                      ,
      p_standard_start          OUT NOCOPY      NUMBER,
      p_standard_stop           OUT NOCOPY      NUMBER,
      p_early_start             OUT NOCOPY      NUMBER,
      p_late_stop               OUT NOCOPY      NUMBER,
      p_min_tcard_intvl         OUT NOCOPY      NUMBER,
      p_round_up                OUT NOCOPY      NUMBER,
      p_hol_code                OUT NOCOPY      NUMBER,
      p_hol_yn                  OUT NOCOPY      VARCHAR2,
      p_error                   OUT NOCOPY      NUMBER,
      p_overtime_type           OUT NOCOPY      VARCHAR2,
      p_otm_error               OUT NOCOPY      VARCHAR2
   );

   FUNCTION record_hours_worked (
      p_timecard_source           IN              VARCHAR2,
      b_generate_holiday          IN              BOOLEAN,
      i_timecard_id               IN              NUMBER,
      i_assignment_id             IN              NUMBER,
      i_person_id                 IN              NUMBER,
      i_date_worked               IN              DATE,
      i_element_id                IN              NUMBER,
      i_hours                     IN              NUMBER,
      i_start_time                IN              DATE,
      i_end_time                  IN              DATE,
      i_start_date                IN              DATE,
      i_wage_code                                 VARCHAR2,
      i_task_id                   IN              NUMBER,
      i_location_id               IN              NUMBER,
      i_project_id                IN              hxt_sum_hours_worked.project_id%TYPE,
      i_earn_pol_id               IN              hxt_sum_hours_worked.earn_pol_id%TYPE,
      i_earn_reason_code          IN              VARCHAR2,
      i_cost_center_id            IN              NUMBER,
      i_comment                   IN              VARCHAR2,
      i_rate_multiple             IN              NUMBER,
      i_hourly_rate               IN              NUMBER,
      i_amount                    IN              NUMBER,
      i_separate_check_flag       IN              VARCHAR2,
      i_time_summary_id           IN              NUMBER,
      i_tim_sum_eff_start_date    IN              DATE,
      i_tim_sum_eff_end_date      IN              DATE,
      i_created_by                IN              NUMBER,
      i_last_updated_by           IN              NUMBER,
      i_last_update_login         IN              NUMBER,
      i_writesum_yn               IN              VARCHAR2,
      i_explode_yn                IN              VARCHAR2,
      i_batch_status              IN              VARCHAR2,
      i_dt_update_mode            IN              VARCHAR2,
      p_time_building_block_id    IN              NUMBER DEFAULT NULL,
      p_time_building_block_ovn   IN              NUMBER DEFAULT NULL,
      o_otm_error                 OUT NOCOPY      VARCHAR2,
      o_oracle_error              OUT NOCOPY      VARCHAR2,
      o_created_tim_sum_id        OUT NOCOPY      NUMBER,
      i_state_name                IN              VARCHAR2 DEFAULT NULL,
      i_county_name               IN              VARCHAR2 DEFAULT NULL,
      i_city_name                 IN              VARCHAR2 DEFAULT NULL,
      i_zip_code                  IN              VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

--        p_mode IN VARCHAR2 default 'INSERT') RETURN NUMBER;
   PROCEDURE cost_allocation_entry (
      i_concat_segments      IN              VARCHAR2,
      i_cost_segment1        IN              VARCHAR2,
      i_cost_segment2        IN              VARCHAR2,
      i_cost_segment3        IN              VARCHAR2,
      i_cost_segment4        IN              VARCHAR2,
      i_cost_segment5        IN              VARCHAR2,
      i_cost_segment6        IN              VARCHAR2,
      i_cost_segment7        IN              VARCHAR2,
      i_cost_segment8        IN              VARCHAR2,
      i_cost_segment9        IN              VARCHAR2,
      i_cost_segment10       IN              VARCHAR2,
      i_cost_segment11       IN              VARCHAR2,
      i_cost_segment12       IN              VARCHAR2,
      i_cost_segment13       IN              VARCHAR2,
      i_cost_segment14       IN              VARCHAR2,
      i_cost_segment15       IN              VARCHAR2,
      i_cost_segment16       IN              VARCHAR2,
      i_cost_segment17       IN              VARCHAR2,
      i_cost_segment18       IN              VARCHAR2,
      i_cost_segment19       IN              VARCHAR2,
      i_cost_segment20       IN              VARCHAR2,
      i_cost_segment21       IN              VARCHAR2,
      i_cost_segment22       IN              VARCHAR2,
      i_cost_segment23       IN              VARCHAR2,
      i_cost_segment24       IN              VARCHAR2,
      i_cost_segment25       IN              VARCHAR2,
      i_cost_segment26       IN              VARCHAR2,
      i_cost_segment27       IN              VARCHAR2,
      i_cost_segment28       IN              VARCHAR2,
      i_cost_segment29       IN              VARCHAR2,
      i_cost_segment30       IN              VARCHAR2,
      i_business_group_id    IN              NUMBER,
      o_ffv_cost_center_id   OUT NOCOPY      NUMBER,
      o_otm_error            OUT NOCOPY      VARCHAR2,
      o_oracle_error         OUT NOCOPY      VARCHAR2
   );

   PROCEDURE call_hxthxc_gen_error (
      p_app_short_name   IN   VARCHAR2,
      p_msg_name         IN   VARCHAR2,
      p_msg_token        IN   VARCHAR2
   )
   IS
      l_msg_token   VARCHAR2 (500);
   --  calls error processing procedure  --
   BEGIN
      IF p_msg_name = 'HXC_HXT_DEP_VAL_OTMERR' AND p_msg_token IS NOT NULL
      THEN
         l_msg_token := 'ERROR&' || p_msg_token;
      ELSE
         l_msg_token := p_msg_token;
      END IF;

      IF    p_msg_name = 'HXC_HXT_DEP_VAL_OTMERR' AND p_msg_token IS NOT NULL
         OR p_msg_name <> 'HXC_HXT_DEP_VAL_OTMERR'
      THEN
         hxc_time_entry_rules_utils_pkg.add_error_to_table
                (p_message_table               => hxt_hxc_retrieval_process.g_otm_messages,
                 p_message_name                => p_msg_name,
                 p_message_token               => SUBSTR (l_msg_token, 1, 240),
                 p_message_level               => 'ERROR',
                 p_message_field               => NULL,
                 p_application_short_name      => p_app_short_name,
                 p_timecard_bb_id              => NULL,
                 p_time_attribute_id           => NULL,
                 p_timecard_bb_ovn             => NULL,
                 p_time_attribute_ovn          => NULL
                );
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('Adding to g_otm_messages' || p_msg_name);
      END IF;
   END;

--       p_mode IN VARCHAR2 default 'INSERT');
   FUNCTION delete_summary_record (p_sum_id IN hxt_sum_hours_worked_f.ID%TYPE)
      RETURN NUMBER;

/*-------------------------------------------------------------------------
||
||                     Public Module Definitions
||
-------------------------------------------------------------------------*/
   PROCEDURE record_time (
      timecard_source             IN              VARCHAR2,
      batch_ref                   IN              VARCHAR2 DEFAULT NULL,
      batch_name                  IN              VARCHAR2 DEFAULT NULL,
      approver_number             IN              VARCHAR2 DEFAULT NULL,
      employee_number             IN              VARCHAR2,
      date_worked                 IN              DATE DEFAULT NULL,
      start_time                  IN              DATE DEFAULT NULL,
      end_time                    IN              DATE DEFAULT NULL,
      hours                       IN              NUMBER DEFAULT NULL,
      wage_code                   IN              VARCHAR2 DEFAULT NULL,
      earning_policy              IN              VARCHAR2 DEFAULT NULL,
      hours_type                  IN              VARCHAR2 DEFAULT NULL,
      earn_reason_code            IN              VARCHAR2 DEFAULT NULL,
      project                     IN              VARCHAR2 DEFAULT NULL,
      task_number                 IN              VARCHAR2 DEFAULT NULL,
      location_code               IN              VARCHAR2 DEFAULT NULL,
      COMMENT                     IN              VARCHAR2 DEFAULT NULL,
      rate_multiple               IN              NUMBER DEFAULT NULL,
      hourly_rate                 IN              NUMBER DEFAULT NULL,
      amount                      IN              NUMBER DEFAULT NULL,
      separate_check_flag         IN              VARCHAR2 DEFAULT NULL,
      business_group_id           IN              NUMBER DEFAULT NULL,
      concat_cost_segments        IN              VARCHAR2 DEFAULT NULL,
      cost_segment1               IN              VARCHAR2 DEFAULT NULL,
      cost_segment2               IN              VARCHAR2 DEFAULT NULL,
      cost_segment3               IN              VARCHAR2 DEFAULT NULL,
      cost_segment4               IN              VARCHAR2 DEFAULT NULL,
      cost_segment5               IN              VARCHAR2 DEFAULT NULL,
      cost_segment6               IN              VARCHAR2 DEFAULT NULL,
      cost_segment7               IN              VARCHAR2 DEFAULT NULL,
      cost_segment8               IN              VARCHAR2 DEFAULT NULL,
      cost_segment9               IN              VARCHAR2 DEFAULT NULL,
      cost_segment10              IN              VARCHAR2 DEFAULT NULL,
      cost_segment11              IN              VARCHAR2 DEFAULT NULL,
      cost_segment12              IN              VARCHAR2 DEFAULT NULL,
      cost_segment13              IN              VARCHAR2 DEFAULT NULL,
      cost_segment14              IN              VARCHAR2 DEFAULT NULL,
      cost_segment15              IN              VARCHAR2 DEFAULT NULL,
      cost_segment16              IN              VARCHAR2 DEFAULT NULL,
      cost_segment17              IN              VARCHAR2 DEFAULT NULL,
      cost_segment18              IN              VARCHAR2 DEFAULT NULL,
      cost_segment19              IN              VARCHAR2 DEFAULT NULL,
      cost_segment20              IN              VARCHAR2 DEFAULT NULL,
      cost_segment21              IN              VARCHAR2 DEFAULT NULL,
      cost_segment22              IN              VARCHAR2 DEFAULT NULL,
      cost_segment23              IN              VARCHAR2 DEFAULT NULL,
      cost_segment24              IN              VARCHAR2 DEFAULT NULL,
      cost_segment25              IN              VARCHAR2 DEFAULT NULL,
      cost_segment26              IN              VARCHAR2 DEFAULT NULL,
      cost_segment27              IN              VARCHAR2 DEFAULT NULL,
      cost_segment28              IN              VARCHAR2 DEFAULT NULL,
      cost_segment29              IN              VARCHAR2 DEFAULT NULL,
      cost_segment30              IN              VARCHAR2 DEFAULT NULL,
      time_summary_id             IN              NUMBER DEFAULT NULL,
      tim_sum_eff_start_date      IN              DATE DEFAULT NULL,
      tim_sum_eff_end_date        IN              DATE DEFAULT NULL,
      created_by                  IN              NUMBER,
      last_updated_by             IN              NUMBER,
      last_update_login           IN              NUMBER,
      writesum_yn                 IN              VARCHAR2 DEFAULT 'Y',
      explode_yn                  IN              VARCHAR2 DEFAULT 'Y',
      delete_yn                   IN              VARCHAR2 DEFAULT 'N',
      --AM 001
      dt_update_mode              IN              VARCHAR2 DEFAULT NULL,
      created_tim_sum_id          OUT NOCOPY      NUMBER,
      otm_error                   OUT NOCOPY      VARCHAR2,
      oracle_error                OUT NOCOPY      VARCHAR2,
      p_time_building_block_id    IN              NUMBER DEFAULT NULL,
      p_time_building_block_ovn   IN              NUMBER DEFAULT NULL,
      p_validate                  IN              BOOLEAN DEFAULT FALSE,
      p_state_name                IN              VARCHAR2 DEFAULT NULL,
      p_county_name               IN              VARCHAR2 DEFAULT NULL,
      p_city_name                 IN              VARCHAR2 DEFAULT NULL,
      p_zip_code                  IN              VARCHAR2 DEFAULT NULL
   )
   IS
      l_person_id                  per_people_f.person_id%TYPE   DEFAULT NULL;
      l_last_name                  per_people_f.last_name%TYPE   DEFAULT NULL;
      l_first_name                 per_people_f.first_name%TYPE  DEFAULT NULL;
      l_approver_id                per_people_f.person_id%TYPE   DEFAULT NULL;
      l_appr_last_name             per_people_f.last_name%TYPE   DEFAULT NULL;
      l_appr_first_name            per_people_f.first_name%TYPE  DEFAULT NULL;
      l_timecard_id                hxt_timecards.ID%TYPE         DEFAULT NULL;
      l_date_worked                DATE                          DEFAULT NULL;
      l_element_type_id            pay_element_types_f.element_type_id%TYPE
                                                                 DEFAULT NULL;
      l_task_id                    hxt_tasks_v.task_id%TYPE      DEFAULT NULL;
      l_location_id                hr_locations.location_id%TYPE DEFAULT NULL;
      l_project_id                 hxt_sum_hours_worked.project_id%TYPE
                                                                 DEFAULT NULL;
      l_time_period_id             per_time_periods.time_period_id%TYPE
                                                                 DEFAULT NULL;
      l_start_date                 DATE                          DEFAULT NULL;
      l_end_date                   DATE                          DEFAULT NULL;
      l_auto_gen_flag              hxt_timecards.auto_gen_flag%TYPE
                                                                 DEFAULT NULL;
      l_timecard_exists            BOOLEAN                       DEFAULT TRUE;
      l_hours                      hxt_sum_hours_worked.hours%TYPE
                                                                 DEFAULT NULL;
      l_sep_chk_flg                hxt_sum_hours_worked.separate_check_flag%TYPE
                                                                 DEFAULT NULL;
      l_timecard_source_code       hxt_timecards.auto_gen_flag%TYPE
                                                                 DEFAULT NULL;
      l_earn_pol_id                hxt_sum_hours_worked.earn_pol_id%TYPE
                                                                 DEFAULT NULL;
      l_ffv_cost_center_id         hxt_sum_hours_worked.ffv_cost_center_id%TYPE
                                                                 DEFAULT NULL;
      l_created_tim_sum_id         hxt_sum_hours_worked.ID%TYPE  DEFAULT NULL;
      l_batch_status               VARCHAR2 (30);
      l_person_id_data_err         EXCEPTION;
      l_person_id_sys_err          EXCEPTION;
      l_appr_id_data_err           EXCEPTION;
      l_appr_id_sys_err            EXCEPTION;
      l_assign_id_data_err         EXCEPTION;
      l_assign_id_sys_err          EXCEPTION;
      l_pay_date_data_err          EXCEPTION;
      l_pay_date_sys_err           EXCEPTION;
      l_elem_type_data_err         EXCEPTION;
      l_elem_type_sys_err          EXCEPTION;
      l_elem_link_data_err         EXCEPTION;
      l_elem_link_sys_err          EXCEPTION;
      l_task_id_data_err           EXCEPTION;
      l_task_id_sys_err            EXCEPTION;
      l_locn_id_data_err           EXCEPTION;
      l_locn_id_sys_err            EXCEPTION;
      l_proj_id_data_err           EXCEPTION;
      l_proj_id_sys_err            EXCEPTION;
      l_time_per_data_err          EXCEPTION;
      l_time_per_sys_err           EXCEPTION;
      l_istimecard_sys_err         EXCEPTION;
      l_make_card_data_err         EXCEPTION;
      l_make_card_sys_err          EXCEPTION;
      l_make_hol_data_err          EXCEPTION;
      l_make_hol_sys_err           EXCEPTION;
      l_autogen_error              EXCEPTION;
      l_rec_hours_data_err         EXCEPTION;
      l_rec_hours_sys_err          EXCEPTION;
      l_sep_chk_flg_data_err       EXCEPTION;
      l_hours_reason_data_err      EXCEPTION;
      l_reason_code_data_err       EXCEPTION;
      l_reason_code_sys_err        EXCEPTION;
      l_time_summary_id_data_err   EXCEPTION;
      l_time_summary_id_sys_err    EXCEPTION;
      l_cost_center_data_err       EXCEPTION;
      l_cost_center_sys_err        EXCEPTION;
      l_prev_wage_data_err         EXCEPTION;
      l_prev_wage_sys_err          EXCEPTION;
      l_hours_amount_data_err      EXCEPTION;
      l_amt_hrs_elmnt_data_err     EXCEPTION;
      l_amt_hrs_zero_data_err      EXCEPTION;
      l_start_end_data_err         EXCEPTION;
      l_hours_null_data_err        EXCEPTION;
      l_no_time_data_err           EXCEPTION;
      l_tim_src_data_err           EXCEPTION;
      l_tim_src_sys_err            EXCEPTION;
      l_earn_pol_data_err          EXCEPTION;
      l_earn_pol_sys_err           EXCEPTION;
      l_sess_date_err              EXCEPTION;
      l_date_worked_time_err       EXCEPTION;
      l_delete_sys_error           EXCEPTION;
      l_delete_finished            EXCEPTION;
      l_dt_update_mode_err         EXCEPTION;
      l_dt_upt_mode_null_err       EXCEPTION;
      l_retcode                    NUMBER                           DEFAULT 0;
      l_error_text                 VARCHAR2 (240)                DEFAULT NULL;
      l_otm_error                  VARCHAR2 (240)                DEFAULT NULL;
      l_oracle_error               VARCHAR2 (512)                DEFAULT NULL;
      l_emp_rec                    g_employee_cur%ROWTYPE;
      l_proc                       VARCHAR2 (100);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := 'hxt_time_collection.RECORD_TIME';
         hr_utility.set_location (l_proc, 10);
      END IF;

      SAVEPOINT only_validate;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 20);
      END IF;

      /* Initialize globals */
      g_batch_ref := batch_ref;
      g_batch_name := batch_name;
      g_sysdate := TRUNC (SYSDATE);
      g_sysdatetime := SYSDATE;
      g_user_id := fnd_global.user_id;
      g_login_id := fnd_global.login_id;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 30);
      END IF;

      /* Copy parameters to error variables */
      e_timecard_source := timecard_source;
      e_approver_number := approver_number;
      e_employee_number := employee_number;
      e_date_worked := date_worked;
      e_start_time := start_time;
      e_end_time := end_time;
      e_hours := hours;
      e_hours_type := hours_type;
      e_earn_reason_code := earn_reason_code;
      e_project := project;
      e_task_number := task_number;
      e_location_code := location_code;
      -- Bug 8634917
      -- Added Substr.
      e_comment := SUBSTR(COMMENT,1,254);
      e_rate_multiple := rate_multiple;
      e_hourly_rate := hourly_rate;
      e_amount := amount;
      e_separate_check_flag := separate_check_flag;
      e_business_group_id := business_group_id;
      e_concat_cost_segments := concat_cost_segments;
      e_cost_segment1 := cost_segment1;
      e_cost_segment2 := cost_segment2;
      e_cost_segment3 := cost_segment3;
      e_cost_segment4 := cost_segment4;
      e_cost_segment5 := cost_segment5;
      e_cost_segment6 := cost_segment6;
      e_cost_segment7 := cost_segment7;
      e_cost_segment8 := cost_segment8;
      e_cost_segment9 := cost_segment9;
      e_cost_segment10 := cost_segment10;
      e_cost_segment11 := cost_segment11;
      e_cost_segment12 := cost_segment12;
      e_cost_segment13 := cost_segment13;
      e_cost_segment14 := cost_segment14;
      e_cost_segment15 := cost_segment15;
      e_cost_segment16 := cost_segment16;
      e_cost_segment17 := cost_segment17;
      e_cost_segment18 := cost_segment18;
      e_cost_segment19 := cost_segment19;
      e_cost_segment20 := cost_segment20;
      e_cost_segment21 := cost_segment21;
      e_cost_segment22 := cost_segment22;
      e_cost_segment23 := cost_segment23;
      e_cost_segment24 := cost_segment24;
      e_cost_segment25 := cost_segment25;
      e_cost_segment26 := cost_segment26;
      e_cost_segment27 := cost_segment27;
      e_cost_segment28 := cost_segment28;
      e_cost_segment29 := cost_segment29;
      e_cost_segment30 := cost_segment30;
      e_state_name := p_state_name;
      e_county_name := p_county_name;
      e_city_name := p_city_name;
      e_zip_code := p_zip_code;

      IF g_debug
      THEN
         hr_utility.TRACE ('Done INIT');
         hr_utility.set_location (l_proc, 40);
      END IF;

      /*Get Session Date*/
      l_retcode := hxt_tim_col_util.get_session_date (g_sess_date);

      IF g_debug
      THEN
         hr_utility.TRACE ('l_retcode :' || l_retcode);
      END IF;

      IF l_retcode = 1
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 50);
         END IF;

         RAISE l_sess_date_err;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('GOT SESS DATE');
      END IF;

      -- Bug 7359347
      -- We made some extensive code changes for this issue primarily
      -- to avoid contention with the FND_SESSIONS table.
      -- The table is being referred in the views hxt_timecards, hxt_sum_hours_worked,
      -- and hxt_det_hours_worked and each has two occurances of FND_SESSIONS.
      -- With this patch we introduced global variables to hold the value of session_id
      -- and session date and are using them in the ocde as input values to cursors so
      -- that FND_SESSIONS is not required.  Here are the global variables we
      -- use in all the packages;  they are being initialized here as this is the
      -- main entry point.

      -- Initialize globals

      hxt_time_summary.g_sum_session_date := g_sess_date;
      hxt_time_detail.g_det_session_date  := g_sess_date;
      hxt_time_pay.g_pay_session_date     := g_sess_date;
      hxt_time_gen.g_gen_session_date     := g_sess_date;
      hxt_td_util.g_td_session_date       := g_sess_date;



      /* Validate dt_update_mode */
      IF (time_summary_id IS NOT NULL) AND (dt_update_mode IS NULL)
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 60);
         END IF;

         RAISE l_dt_upt_mode_null_err;
      END IF;

      IF     (dt_update_mode IS NOT NULL)
         AND                                                         -- SIR293
             (dt_update_mode NOT IN ('CORRECTION', 'UPDATE')
             )
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 70);
         END IF;

         RAISE l_dt_update_mode_err;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('VALID DT MODE');
         hr_utility.set_location (l_proc, 80);
      END IF;

      /* Validate time summary id */
      IF time_summary_id IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 90);
         END IF;

         l_retcode :=
                   hxt_tim_col_util.validate_time_summary_id (time_summary_id);

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 100);
            END IF;

            RAISE l_time_summary_id_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 110);
            END IF;

            RAISE l_time_summary_id_sys_err;
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 120);
      END IF;

      /* Check for and perform any deletes */
      IF delete_yn = 'Y' AND time_summary_id IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 130);
         END IF;

         l_retcode := delete_summary_record (time_summary_id);

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 140);
            END IF;

            RAISE l_delete_sys_error;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 150);
         END IF;

         RAISE l_delete_finished;
      END IF;

      /*Determine date worked                                    */
      /* If there are start and end times derive date  from them */
      /* otherwise use date_worked parameter value.              */
      IF g_debug
      THEN
         hr_utility.TRACE ('date_worked :' || date_worked);
         hr_utility.TRACE ('start_time  :' || start_time);
         hr_utility.TRACE ('end_time    :' || end_time);
      END IF;

      IF start_time IS NOT NULL OR end_time IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 160);
         END IF;

         IF start_time IS NULL OR end_time IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 170);
            END IF;

            RAISE l_start_end_data_err;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 180);
            END IF;

            l_retcode :=
               hxt_tim_col_util.determine_pay_date (start_time,
                                                    end_time,
                                                    l_person_id,
                                                    l_date_worked
                                                   );

            IF l_retcode = 1
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 190);
               END IF;

               RAISE l_pay_date_data_err;
            ELSIF l_retcode = 2
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 200);
               END IF;

               RAISE l_pay_date_sys_err;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 210);
            END IF;

            /* Calcualte hours worked */
            l_hours := 24
                       * (TRUNC (end_time, 'MI') - TRUNC (start_time, 'MI'));

            IF g_debug
            THEN
               hr_utility.TRACE ('l_hours :' || l_hours);
            END IF;
         END IF;
      ELSIF date_worked IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 220);
            hr_utility.TRACE ('DATE WORKED is not null');
         END IF;

         l_date_worked := date_worked;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_date_worked      :' || l_date_worked);
            hr_utility.TRACE ('TRUNC(date_worked) :' || TRUNC (date_worked));
         END IF;

         IF date_worked <> TRUNC (date_worked)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 230);
            END IF;

            RAISE l_date_worked_time_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 240);
            hr_utility.TRACE ('hours :' || hours);
         END IF;

         IF hours IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 250);
            END IF;

            l_hours := hours;

-- Removed for bug 3868006
--         ELSE
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 260);
            END IF;
--            RAISE l_hours_null_data_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 270);
         END IF;
      ELSIF date_worked IS NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 280);
         END IF;

         RAISE l_no_time_data_err;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 290);
      END IF;

      /* Obtain person id from user exit if call not from the time store */
      IF timecard_source <> 'Time Store'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 300);
         END IF;

         l_retcode :=
            hxt_tim_col_util.get_person_id (employee_number,
                                            business_group_id,        --SIR461
                                            l_date_worked,
                                            l_person_id,
                                            l_last_name,
                                            l_first_name
                                           );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 310);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 320);
            END IF;

            RAISE l_person_id_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 330);
            END IF;

            RAISE l_person_id_sys_err;
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 340);
         END IF;

         l_person_id := TO_NUMBER (employee_number);

         IF g_debug
         THEN
            hr_utility.TRACE ('l_person_id :' || l_person_id);
         END IF;

         SELECT last_name, first_name
           INTO l_last_name, l_first_name
           FROM per_all_people_f
          WHERE person_id = l_person_id
            AND l_date_worked BETWEEN effective_start_date AND effective_end_date;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_last_name :' || l_last_name);
            hr_utility.TRACE ('l_first_name:' || l_first_name);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 350);
         hr_utility.TRACE ('Person ID is ' || TO_CHAR (l_person_id));
      END IF;

      /*Obtain vital employee information*/
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 360);
         END IF;

         OPEN g_employee_cur (l_person_id, l_date_worked);

         FETCH g_employee_cur
          INTO l_emp_rec;

         CLOSE g_employee_cur;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 370);
            END IF;

            l_retcode := 1;
            RAISE l_assign_id_data_err;
         WHEN OTHERS
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 380);
            END IF;

            l_retcode := 2;
            RAISE l_assign_id_sys_err;
      END;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 390);
         hr_utility.TRACE ('Got emp info');
      END IF;

      /* Obtain person id for APPROVER_NUMBER from user exit */
      IF approver_number IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 400);
         END IF;

         l_retcode :=
            hxt_tim_col_util.get_person_id (approver_number,
                                            business_group_id,        --SIR461
                                            l_date_worked,
                                            l_approver_id,
                                            l_appr_last_name,
                                            l_appr_first_name
                                           );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 410);
            END IF;

            RAISE l_appr_id_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 420);
            END IF;

            RAISE l_appr_id_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 430);
         END IF;
      END IF;

      /* Validate the timecard source */
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 440);
         hr_utility.TRACE ('BEFORE VALID TIMECARD SOURCE');
      END IF;

      l_retcode :=
         hxt_tim_col_util.validate_timecard_source (timecard_source,
                                                    l_date_worked,
                                                    l_timecard_source_code
                                                   );

      IF g_debug
      THEN
         hr_utility.TRACE ('l_retcode :' || l_retcode);
      END IF;

      IF l_retcode = 1
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 450);
         END IF;

         RAISE l_tim_src_data_err;
      ELSIF l_retcode = 2
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 460);
         END IF;

         RAISE l_tim_src_sys_err;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 470);
         hr_utility.TRACE ('VALID TIMECARD SOURCE');
      END IF;

      /*Obtain element type id */
      IF g_debug
      THEN
         hr_utility.TRACE ('hours_type :' || hours_type);
      END IF;

      IF hours_type IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 480);
         END IF;

         l_retcode :=
            hxt_tim_col_util.get_element_type_id (hours_type,
                                                  l_date_worked,
                                                  business_group_id,
                                                  l_element_type_id
                                                 );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 490);
            END IF;

            RAISE l_elem_type_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 500);
            END IF;

            RAISE l_elem_type_sys_err;
         END IF;

         --
         IF g_debug
         THEN
            hr_utility.TRACE ('element type id is ' || l_element_type_id);
         END IF;

         --
         -- Check Element Link eligibility
         --
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 510);
         END IF;

         l_retcode :=
            hxt_tim_col_util.chk_element_link
                                       (p_asg_id               => l_emp_rec.assignment_id,
                                        p_date_worked          => l_date_worked,
                                        p_element_type_id      => l_element_type_id
                                       );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 520);
            END IF;

            RAISE l_elem_link_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 530);
            END IF;

            RAISE l_elem_link_sys_err;
         END IF;

         --
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 540);
         END IF;
      END IF;

      --
      IF g_debug
      THEN
         hr_utility.TRACE ('element link id is ' || l_element_type_id);
      END IF;

      --

      /* Validate Amount/Hours 05-APR-00 PWM changed 'hours' variable
           to 'l_hours' in case user entered in/out times */

      /* Bring API in line with Timecard behavior. 15-AUG-2001 AI
         IF amount IS NOT NULL THEN
            hr_utility.set_location(l_proc, 550);
      -- 05-APR-00 PWM      IF hours IS NULL THEN

            IF l_hours <> 0 THEN -- 05-APR-00 PWM Hours and Amounts are exclusive
                         hr_utility.set_location(l_proc, 560);
               RAISE l_hours_amount_data_err;
            ELSIF l_hours = 0 AND l_element_type_id IS NULL THEN
                         hr_utility.set_location(l_proc, 570);
               RAISE l_amt_hrs_elmnt_data_err;
            END IF;
      --   ELSIF l_hours IS NOT NULL THEN PWM 05-APR-00

         ELSE
                   hr_utility.set_location(l_proc, 580);
            IF l_hours = 0 THEN
                         hr_utility.set_location(l_proc, 590);
               RAISE l_amt_hrs_zero_data_err;
            END IF;
                   hr_utility.set_location(l_proc, 600);
         END IF;
      */

      /* Validate Wage Code */
      IF wage_code IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 610);
         END IF;

         l_retcode :=
                hxt_tim_col_util.validate_wage_code (wage_code, l_date_worked);

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 620);
            END IF;

            RAISE l_prev_wage_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 630);
            END IF;

            RAISE l_prev_wage_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 640);
         END IF;
      END IF;

      /* Get Earning Policy Id - If null get based on assignment, otherwise, */
      /*                         get override policy id.                     */
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 650);
      END IF;

      l_retcode :=
         hxt_tim_col_util.get_earn_pol_id (l_emp_rec.assignment_id,
                                           l_date_worked,
                                           earning_policy,
                                           l_earn_pol_id
                                          );

      IF g_debug
      THEN
         hr_utility.TRACE ('l_retcode :' || l_retcode);
      END IF;

      IF l_retcode = 1
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 660);
         END IF;

         RAISE l_earn_pol_data_err;
      ELSIF l_retcode = 2
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 670);
         END IF;

         RAISE l_earn_pol_sys_err;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('earning policy id is ' || l_earn_pol_id);
         hr_utility.set_location (l_proc, 680);
      END IF;

      /* Obtain project id */
      IF g_debug
      THEN
         hr_utility.TRACE ('project :' || project);
      END IF;

      IF project IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 680);
         END IF;

         l_retcode :=
            hxt_tim_col_util.get_project_id (project,
                                             l_date_worked,
                                             l_project_id
                                            );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 690);
            END IF;

            RAISE l_proj_id_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 700);
            END IF;

            RAISE l_proj_id_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 710);
         END IF;
      END IF;

      /*Obtain task id */
      IF g_debug
      THEN
         hr_utility.TRACE ('task_number :' || task_number);
      END IF;

      IF task_number IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 720);
         END IF;

         l_retcode :=
            hxt_tim_col_util.get_task_id (task_number,
                                          l_date_worked,
                                          l_project_id,    /* PWM 05-APR-00 */
                                          l_task_id
                                         );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 730);
            END IF;

            RAISE l_task_id_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 740);
            END IF;

            RAISE l_task_id_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 750);
         END IF;
      END IF;

      /*Obtain location id */
      IF g_debug
      THEN
         hr_utility.TRACE ('location_code :' || location_code);
      END IF;

      IF location_code IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 760);
         END IF;

         l_retcode :=
            hxt_tim_col_util.get_location_id (location_code,
                                              l_date_worked,
                                              l_location_id
                                             );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 770);
            END IF;

            RAISE l_locn_id_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 780);
            END IF;

            RAISE l_locn_id_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 790);
         END IF;
      END IF;

      /* Validate earn reason code */
      IF g_debug
      THEN
         hr_utility.TRACE ('earn_reason_code :' || earn_reason_code);
      END IF;

      IF earn_reason_code IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 800);
         END IF;

         l_retcode :=
            hxt_tim_col_util.validate_earn_reason_code (earn_reason_code,
                                                        l_date_worked
                                                       );

         --      l_element_type_id );
         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 810);
            END IF;

            RAISE l_hours_reason_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 820);
            END IF;

            RAISE l_reason_code_data_err;
         ELSIF l_retcode = 3
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 830);
            END IF;

            RAISE l_reason_code_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 840);
         END IF;
      END IF;

      /* Validate separate check flag */
      IF g_debug
      THEN
         hr_utility.TRACE ('separate_check_flag :' || separate_check_flag);
      END IF;

      IF separate_check_flag IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 850);
         END IF;

         l_sep_chk_flg := separate_check_flag;
         l_retcode :=
                    hxt_tim_col_util.validate_separate_chk_flg (l_sep_chk_flg);

         IF g_debug
         THEN
            hr_utility.TRACE ('l_sep_chk_flg :' || l_sep_chk_flg);
            hr_utility.TRACE ('l_retcode     :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 860);
            END IF;

            RAISE l_sep_chk_flg_data_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 870);
         END IF;
      END IF;

      /*Obtain the current time period id for this payroll and date*/
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 880);
      END IF;

      l_retcode :=
         get_time_period (l_emp_rec.payroll_id,
                          l_date_worked,
                          l_time_period_id,
                          l_start_date,
                          l_end_date
                         );

      IF g_debug
      THEN
         hr_utility.TRACE ('l_start_date :' || l_start_date);
         hr_utility.TRACE ('l_end_date   :' || l_end_date);
         hr_utility.TRACE ('l_retcode :' || l_retcode);
      END IF;

      IF l_retcode = 1
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 890);
         END IF;

         RAISE l_time_per_data_err;
      ELSIF l_retcode = 2
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 900);
         END IF;

         RAISE l_time_per_sys_err;
      END IF;

      g_time_period_err_id := l_time_period_id;

      IF g_debug
      THEN
         hr_utility.TRACE ('Time Period id is ' || l_time_period_id);
      END IF;

      /*Determine effective start date*/
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 910);
      END IF;

--Bug#2995224
--      IF l_emp_rec.effective_start_date > l_start_date
--     THEN
--                 hr_utility.set_location (l_proc, 920);
--         l_start_date := l_emp_rec.effective_start_date;
--      END IF;

      --      IF l_emp_rec.effective_end_date < l_end_date
--      THEN
--             hr_utility.set_location (l_proc, 930);
--         l_end_date := l_emp_rec.effective_end_date;
--      END IF;

      /*Make cost allocation entry. */
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 940);
      END IF;

      cost_allocation_entry (concat_cost_segments,
                             cost_segment1,
                             cost_segment2,
                             cost_segment3,
                             cost_segment4,
                             cost_segment5,
                             cost_segment6,
                             cost_segment7,
                             cost_segment8,
                             cost_segment9,
                             cost_segment10,
                             cost_segment11,
                             cost_segment12,
                             cost_segment13,
                             cost_segment14,
                             cost_segment15,
                             cost_segment16,
                             cost_segment17,
                             cost_segment18,
                             cost_segment19,
                             cost_segment20,
                             cost_segment21,
                             cost_segment22,
                             cost_segment23,
                             cost_segment24,
                             cost_segment25,
                             cost_segment26,
                             cost_segment27,
                             cost_segment28,
                             cost_segment29,
                             cost_segment30,
                             business_group_id,
                             l_ffv_cost_center_id,
                             otm_error,
                             oracle_error
                            );

      IF g_debug
      THEN
         hr_utility.TRACE ('Cost Alloc entry made ');
      END IF;

-----------------------------------------------------------------------------
   /*Check for an existing timecard */
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 950);
         hr_utility.TRACE ('calling check_for_timecard');
      END IF;

      l_retcode :=
         check_for_timecard (l_person_id,
                             l_time_period_id,
                             l_timecard_id,
                             l_auto_gen_flag
                            );

      IF g_debug
      THEN
         hr_utility.TRACE ('after call to check_for_timecard');
         hr_utility.TRACE ('l_retcode       :' || l_retcode);
         hr_utility.TRACE ('l_timecard_id   :' || l_timecard_id);
         hr_utility.TRACE ('l_auto_gen_flag :' || l_auto_gen_flag);
         hr_utility.TRACE ('l_retcode       :' || l_retcode);
         hr_utility.set_location (l_proc, 960);
      END IF;

      IF l_retcode = 0
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 970);
         END IF;

         g_timecard_err_id := l_timecard_id;
      ELSIF l_retcode = 1
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 980);
            hr_utility.TRACE ('BEFORE create timecard');
         END IF;

         l_retcode :=
            create_timecard (l_person_id,
                             business_group_id,
                             l_emp_rec.assignment_id,
                             l_emp_rec.payroll_id,
                             l_time_period_id,
                             l_approver_id,
                             l_timecard_source_code,
                             l_timecard_id
                            );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 990);
            END IF;

            RAISE l_make_card_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 1000);
            END IF;

            RAISE l_make_card_sys_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1010);
         END IF;

         g_timecard_err_id := l_timecard_id;

         IF g_debug
         THEN
            hr_utility.TRACE ('Created TIMECARD. ID is ' || l_timecard_id);
         END IF;

           /* Create holiday hours on the new timecard */
           /*l_retcode := create_holiday_hours(l_person_id,
                                             l_emp_rec.hcl_id,
                    l_emp_rec.hxt_rotation_plan,--SIR344
                                             l_start_date,
                                             l_end_date,
                                             l_timecard_id,
                                             wage_code,
                                             l_task_id,
                                             l_location_id,
                                             l_project_id,
                                             l_earn_pol_id,
                                             earn_reason_code,
                                             comment,
                                             rate_multiple,
                                             hourly_rate,
                                             amount,
                                             l_sep_chk_flg,
                                             l_emp_rec.assignment_id,
                                             time_summary_id,
                                             tim_sum_eff_start_date,
                                             tim_sum_eff_end_date,
                                             created_by,
                                             last_updated_by,
                                             last_update_login,
                                             writesum_yn,
                                             explode_yn,
                                             l_batch_status,
                                             dt_update_mode, --SIR290
                                             p_time_building_block_id,
                                             p_time_building_block_ovn,
                                             l_otm_error,
                                             l_oracle_error,
                                             l_created_tim_sum_id,
                                             start_time,
                                             end_time);
                                           --p_mode);


         hr_utility.set_location(l_proc, 1020);
         hr_utility.trace('Created Holiday Hours ');
         hr_utility.trace('l_retcode :'||l_retcode);

           IF l_retcode = 1 THEN
                     hr_utility.set_location(l_proc, 1030);
              RAISE l_make_hol_data_err;
           ELSIF l_retcode = 2 THEN
                     hr_utility.set_location(l_proc, 1040);
              RAISE l_make_hol_sys_err;
           END IF;
           */
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1050);
         END IF;
      ELSIF l_retcode = 2
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1060);
         END IF;

         RAISE l_istimecard_sys_err;
      END IF;

-----------------------------------------------------------------------------

      /*Check to see if pre-existing timecards were autogened*/
      IF l_auto_gen_flag = 'A'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1070);
         END IF;

         RAISE l_autogen_error;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 1080);
      END IF;

      l_retcode := check_for_batch_status (g_batch_err_id, l_batch_status);

      IF g_debug
      THEN
         hr_utility.TRACE ('l_retcode :' || l_retcode);
         hr_utility.TRACE ('delete_yn:' || delete_yn);
      END IF;

      IF delete_yn = 'N'
      THEN
         -- Bugs 3384941, 3382457, 3381642 fix
         -- i.e., If it is not a deleted record then create it.
         -- If it is a deleted record then we should skip this call to
         -- record_hours_worked

         -- Insert hours to the hxt_sum_hours_worked table and
         -- call generate details
         IF g_debug
         THEN
            hr_utility.TRACE ('BEFORE record_hours worked');
         END IF;

         l_retcode :=
            record_hours_worked (timecard_source,
                                 FALSE,
                                 l_timecard_id,
                                 l_emp_rec.assignment_id,
                                 l_person_id,
                                 l_date_worked,
                                 l_element_type_id,
                                 l_hours,
                                 start_time,
                                 end_time,
                                 l_start_date,
                                 wage_code,
                                 l_task_id,
                                 l_location_id,
                                 l_project_id,
                                 l_earn_pol_id,
                                 earn_reason_code,
                                 l_ffv_cost_center_id,
                                 -- Bug 8634917
                                 -- Changed variable to e_comment.
                                 e_comment,
                                 rate_multiple,
                                 hourly_rate,
                                 amount,
                                 l_sep_chk_flg,
                                 time_summary_id,
                                 tim_sum_eff_start_date,
                                 tim_sum_eff_end_date,
                                 created_by,
                                 last_updated_by,
                                 last_update_login,
                                 writesum_yn,
                                 explode_yn,
                                 l_batch_status,
                                 dt_update_mode,
                                 p_time_building_block_id,
                                 p_time_building_block_ovn,
                                 l_otm_error,
                                 l_oracle_error,
                                 l_created_tim_sum_id,
                                 p_state_name,
                                 p_county_name,
                                 p_city_name,
                                 p_zip_code
                                -- , p_mode
                                );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1090);
            hr_utility.TRACE ('AFTER record_hours worked');
            hr_utility.TRACE (   'AFTER record_hours worked RET CODE IS '
                              || TO_CHAR (l_retcode)
                             );
            hr_utility.TRACE ('OTM ERROR IS ' || l_otm_error);
            hr_utility.TRACE ('ORACLE ERROR IS ' || l_oracle_error);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 1100);
            END IF;

            otm_error := l_otm_error;
            oracle_error := l_oracle_error;
            RAISE l_rec_hours_data_err;
         ELSIF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 1110);
            END IF;

            otm_error := l_otm_error;
            oracle_error := l_oracle_error;
            RAISE l_rec_hours_sys_err;
         END IF;

--
         created_tim_sum_id := l_created_tim_sum_id;

         IF g_debug
         THEN
            hr_utility.TRACE ('created_tim_sum_id :' || created_tim_sum_id);
         END IF;

--
         otm_error := NULL;
         oracle_error := NULL;
      END IF;

      IF p_validate
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1120);
            hr_utility.TRACE ('VALIDATE only so ROLLBACK');
         END IF;

         ROLLBACK TO only_validate;
         created_tim_sum_id := 0;

         IF g_debug
         THEN
            hr_utility.TRACE ('created_tim_sum_id :' || created_tim_sum_id);
         END IF;
      END IF;                                           -- End of p_mode check

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 1130);
      END IF;

      RETURN;
   EXCEPTION
      WHEN l_person_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1140);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39308_EMPLYEE_NF');
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_person_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1150);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39529_EMP_DATA_SYS_ERR');
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_appr_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1160);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39530_APPRVR_NF');
         fnd_message.set_token ('APP_NUMBER', approver_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_appr_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1170);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39531_APP_DATA_SYS_ERR');
         fnd_message.set_token ('APP_NUMBER', approver_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_assign_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1180);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39306_ASSIGN_NF');
         fnd_message.set_token ('FIRST_NAME', l_first_name);
         fnd_message.set_token ('LAST_NAME', l_last_name);
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_assign_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1190);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39319_ERR_GET_ASSIGN');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39319_ERR_GET_ASSIGN', NULL);
         --2278400
         RETURN;
      WHEN l_pay_date_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1200);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39331_CANT_CALC_DAT_WRKED');
         fnd_message.set_token ('START_TIME', TO_CHAR (start_time));
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_pay_date_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1210);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39323_ERR_DATE_WRKED');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39323_ERR_DATE_WRKED', NULL);
         --2278400
         RETURN;
      WHEN l_prev_wage_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1220);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39532_INV_PREV_WAGE_CODE');
         fnd_message.set_token ('WAGE_CODE', wage_code);
         l_error_text := fnd_message.get;
         otm_error := l_error_text;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', otm_error);
         --2278400
         RETURN;
      WHEN l_prev_wage_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1230);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39533_PREV_WAGE_CD_SYS_ERR');
         l_error_text := fnd_message.get;
         otm_error := l_error_text;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39533_PREV_WAGE_CD_SYS_ERR', NULL);
                                                                     --2278400
         RETURN;
      WHEN l_elem_type_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1240);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39534_ELEM_TYPE_NF');
         fnd_message.set_token ('HRS_TYPE', hours_type);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', otm_error);
         --2278400
         RETURN;
      WHEN l_elem_type_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1250);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39535_ELEM_TYPE_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39535_ELEM_TYPE_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_elem_link_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1260);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_ELEM_LINK_NF');
         fnd_message.set_token ('HRS_TYPE', hours_type);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_elem_link_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1270);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_ELEM_LINK_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_ELEM_LINK_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_task_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1280);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39536_TASK_ID_NF');
         fnd_message.set_token ('TASK_NUMBER', task_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_task_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1290);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39537_TASK_ID_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         RETURN;
      WHEN l_locn_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1300);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39538_LOC_ID_NF');
         fnd_message.set_token ('LOC_CODE', location_code);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_locn_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1310);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39539_LOC_ID_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39539_LOC_ID_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_proj_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1320);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39540_PRJ_ID_NF');
         fnd_message.set_token ('PRJ_NUMBER', project);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_proj_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1330);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39541_PRJ_ID_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39541_PRJ_ID_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_hours_reason_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1340);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39542_ERN_RSN_WO_HRS_TYPE');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39542_ERN_RSN_WO_HRS_TYPE', NULL);
         --2278400
         RETURN;
      WHEN l_reason_code_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1350);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39543_ERN_RSN_NF');
         fnd_message.set_token ('ERN_RSN_CD', earn_reason_code);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_reason_code_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1360);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39544_ERN_RSN_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39544_ERN_RSN_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_sep_chk_flg_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1370);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39545_SEP_CHK_NF');
         fnd_message.set_token ('SEP_CHK', l_sep_chk_flg);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_time_per_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1380);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39330_CANT_CALC_TIM_PER');
         fnd_message.set_token ('DATE_WORKED', TO_CHAR (l_date_worked));
         fnd_message.set_token ('PAYROLL', TO_CHAR (l_emp_rec.payroll_id));
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_time_per_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1390);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39324_ERR_TIME_PERIOD');
         fnd_message.set_token ('SQLERR', SQLERRM);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_istimecard_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1400);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39298_ERR_GET_TIMCARD');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39298_ERR_GET_TIMCARD', NULL);
         --2278400
         RETURN;
      WHEN l_autogen_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1410);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39267_AG_TCARD_EXISTS');
         fnd_message.set_token ('FIRST_NAME', l_first_name);
         fnd_message.set_token ('LAST_NAME', l_last_name);
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_make_card_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1420);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39291_CRT_TCARD_ERR');
         fnd_message.set_token ('FIRST_NAME', l_first_name);
         fnd_message.set_token ('LAST_NAME', l_last_name);
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_make_card_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1430);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39318_ERR_CREAT_TCARD');
         fnd_message.set_token ('FIRST_NAME', l_first_name);
         fnd_message.set_token ('LAST_NAME', l_last_name);
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         l_oracle_error := SQLERRM;
         otm_error := l_otm_error;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         oracle_error := SQLERRM;
         RETURN;
      WHEN l_make_hol_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1440);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39292_CRT_HOL_HRS');
         fnd_message.set_token ('FIRST_NAME', l_first_name);
         fnd_message.set_token ('LAST_NAME', l_last_name);
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_make_hol_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1450);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39320_ERR_CREAT_HOL');
         fnd_message.set_token ('FIRST_NAME', l_first_name);
         fnd_message.set_token ('LAST_NAME', l_last_name);
         fnd_message.set_token ('EMP_NUMBER', employee_number);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_rec_hours_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1460);
         END IF;

         -- GPM v115.23
         -- there is no point writing over a specific system error
         -- with a generic translated error
         IF (l_otm_error IS NULL)
         THEN
            fnd_message.set_name ('HXT', 'HXT_39293_REC_HRS_ERR');
            l_otm_error := fnd_message.get;
         END IF;

         otm_error := l_otm_error;

         IF (l_oracle_error IS NULL)
         THEN
            oracle_error := SQLERRM;
         ELSE
            oracle_error := l_oracle_error;
         END IF;

         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_rec_hours_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1470);
         END IF;

         -- GPM v115.23
         -- there is no point writing over a specific system error
         -- with a generic translated error
         IF (l_otm_error IS NULL)
         THEN
            fnd_message.set_name ('HXT', 'HXT_39321_ERR_REC_HRS');
            l_otm_error := fnd_message.get;
         END IF;

         otm_error := l_otm_error;

         IF (l_oracle_error IS NULL)
         THEN
            oracle_error := SQLERRM;
         ELSE
            oracle_error := l_oracle_error;
         END IF;

         l_otm_error := fnd_message.get;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
      WHEN l_hours_amount_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1480);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39527_HRS_REQ_IF_AMT');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39527_HRS_REQ_IF_AMT', NULL);
         --2278400
         RETURN;
      WHEN l_amt_hrs_elmnt_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1490);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39528_HRS_NE0_IF_NO_HRSTYP');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39528_HRS_NE0_IF_NO_HRSTYP', NULL);
                                                                     --2278400
         RETURN;
      WHEN l_amt_hrs_zero_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1500);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39546_HRS_NE0_IF_NO_AMT');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39546_HRS_NE0_IF_NO_AMT', NULL);
         --2278400
         RETURN;
      WHEN l_start_end_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1510);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39547_START_END_REQ');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39547_START_END_REQ', NULL);
         --2278400
         RETURN;
      WHEN l_hours_null_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1520);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39548_HRS_REQ_IF_DT_WRK');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39548_HRS_REQ_IF_DT_WRK', NULL);
         --2278400
         RETURN;
      WHEN l_no_time_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1530);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39549_ST_END_OR_DT_WRK_REQ');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39549_ST_END_OR_DT_WRK_REQ', NULL);
                                                                     --2278400
         RETURN;
      WHEN l_tim_src_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1540);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39550_TIM_SRC_NF');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39550_TIM_SRC_NF', NULL);
         --2278400
         RETURN;
      WHEN l_tim_src_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1550);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39551_TIM_SRC_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39551_TIM_SRC_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_time_summary_id_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1560);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39552_TIM_SUM_ID_NF');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39552_TIM_SUM_ID_NF', NULL);
         --2278400
         RETURN;
      WHEN l_time_summary_id_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1570);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39553_TIM_SUM_ID_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39553_TIM_SUM_ID_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_earn_pol_data_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1580);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39554_ERN_POL_NF');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39554_ERN_POL_NF', NULL);
         --2278400
         RETURN;
      WHEN l_earn_pol_sys_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1590);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39555_ERN_POL_SYS_ERR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39555_ERN_POL_SYS_ERR', NULL);
         --2278400
         RETURN;
      WHEN l_sess_date_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1600);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39556_SESSION_DT_NF');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39556_SESSION_DT_NF', NULL);
         --2278400
         RETURN;
      WHEN l_date_worked_time_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1610);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39557_NO_TIME_IN_DT_WRK');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39557_NO_TIME_IN_DT_WRK', NULL);
         --2278400
         RETURN;
      WHEN l_delete_sys_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1620);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39558_ERR_IN_DSR');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := SQLERRM;
-- Removed for bug 3868006
--         call_hxthxc_gen_error ('HXT', 'HXT_39558_ERR_IN_DSR', NULL); --2278400
         RETURN;
      WHEN l_delete_finished
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1630);
         END IF;

         NULL;
--SIR290
      WHEN l_dt_update_mode_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1640);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39559_DT_UPD_MODE_INV');
         fnd_message.set_token ('DT_UPD_MODE', dt_update_mode);
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := '';
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
--SIR293
      WHEN l_dt_upt_mode_null_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1650);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39560_DT_UPD_MODE_NULL');
         l_otm_error := fnd_message.get;
         otm_error := l_otm_error;
         oracle_error := '';
         call_hxthxc_gen_error ('HXT', 'HXT_39560_DT_UPD_MODE_NULL', NULL);
         --2278400
         RETURN;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1660);
         END IF;

         -- GPM v115.23
         IF (l_otm_error IS NULL)
         THEN
            fnd_message.set_name ('HXT', 'HXT_39406_EXCP_REC_TIME');
            l_otm_error := fnd_message.get;
         END IF;

         otm_error := l_otm_error;

         IF (l_oracle_error IS NULL)
         THEN
            oracle_error := SQLERRM;
         ELSE
            oracle_error := l_oracle_error;
         END IF;

         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', l_otm_error);
         --2278400
         RETURN;
   END record_time;

   PROCEDURE log_timeclock_errors (
      otm_msg                  IN              VARCHAR2,
      created_by               IN              NUMBER,
      ora_message              IN              VARCHAR2,
      timecard_source          IN              VARCHAR2,
      approver_number          IN              VARCHAR2 DEFAULT NULL,
      employee_number          IN              VARCHAR2,
      date_worked              IN              DATE DEFAULT NULL,
      start_time               IN              DATE DEFAULT NULL,
      end_time                 IN              DATE DEFAULT NULL,
      hours                    IN              NUMBER DEFAULT NULL,
      wage_code                IN              VARCHAR2 DEFAULT NULL,
      earning_policy           IN              VARCHAR2 DEFAULT NULL,
      hours_type               IN              VARCHAR2 DEFAULT NULL,
      earn_reason_code         IN              VARCHAR2 DEFAULT NULL,
      cost_center_id           IN              NUMBER DEFAULT NULL,
      project                  IN              VARCHAR2 DEFAULT NULL,
      task_number              IN              VARCHAR2 DEFAULT NULL,
      location_code            IN              VARCHAR2 DEFAULT NULL,
      hrw_comment              IN              VARCHAR2 DEFAULT NULL,
      rate_multiple            IN              NUMBER DEFAULT NULL,
      hourly_rate              IN              NUMBER DEFAULT NULL,
      amount                   IN              NUMBER DEFAULT NULL,
      separate_check_flag      IN              VARCHAR2 DEFAULT NULL,
      business_group_id        IN              NUMBER DEFAULT NULL,
      concat_cost_segments     IN              VARCHAR2 DEFAULT NULL,
      cost_segment1            IN              VARCHAR2 DEFAULT NULL,
      cost_segment2            IN              VARCHAR2 DEFAULT NULL,
      cost_segment3            IN              VARCHAR2 DEFAULT NULL,
      cost_segment4            IN              VARCHAR2 DEFAULT NULL,
      cost_segment5            IN              VARCHAR2 DEFAULT NULL,
      cost_segment6            IN              VARCHAR2 DEFAULT NULL,
      cost_segment7            IN              VARCHAR2 DEFAULT NULL,
      cost_segment8            IN              VARCHAR2 DEFAULT NULL,
      cost_segment9            IN              VARCHAR2 DEFAULT NULL,
      cost_segment10           IN              VARCHAR2 DEFAULT NULL,
      cost_segment11           IN              VARCHAR2 DEFAULT NULL,
      cost_segment12           IN              VARCHAR2 DEFAULT NULL,
      cost_segment13           IN              VARCHAR2 DEFAULT NULL,
      cost_segment14           IN              VARCHAR2 DEFAULT NULL,
      cost_segment15           IN              VARCHAR2 DEFAULT NULL,
      cost_segment16           IN              VARCHAR2 DEFAULT NULL,
      cost_segment17           IN              VARCHAR2 DEFAULT NULL,
      cost_segment18           IN              VARCHAR2 DEFAULT NULL,
      cost_segment19           IN              VARCHAR2 DEFAULT NULL,
      cost_segment20           IN              VARCHAR2 DEFAULT NULL,
      cost_segment21           IN              VARCHAR2 DEFAULT NULL,
      cost_segment22           IN              VARCHAR2 DEFAULT NULL,
      cost_segment23           IN              VARCHAR2 DEFAULT NULL,
      cost_segment24           IN              VARCHAR2 DEFAULT NULL,
      cost_segment25           IN              VARCHAR2 DEFAULT NULL,
      cost_segment26           IN              VARCHAR2 DEFAULT NULL,
      cost_segment27           IN              VARCHAR2 DEFAULT NULL,
      cost_segment28           IN              VARCHAR2 DEFAULT NULL,
      cost_segment29           IN              VARCHAR2 DEFAULT NULL,
      cost_segment30           IN              VARCHAR2 DEFAULT NULL,
      time_summary_id          IN              NUMBER DEFAULT NULL,
      tim_sum_eff_start_date   IN              DATE DEFAULT NULL,
      tim_sum_eff_end_date     IN              DATE DEFAULT NULL,
      oracle_error             OUT NOCOPY      VARCHAR2
   )
   IS
      l_error_seqno   NUMBER DEFAULT NULL;
   BEGIN
      /* Initialize globals */
      g_sysdate := TRUNC (SYSDATE);
      g_sysdatetime := SYSDATE;
      g_user_id := fnd_global.user_id;
      g_login_id := fnd_global.login_id;

      SELECT hxt_seqno.NEXTVAL
        INTO l_error_seqno
        FROM DUAL;

      --
      INSERT INTO hxt_timeclock_errors
                  (ID, otm_error, creation_date, created_by,
                   ora_error, timecard_source, approver_number,
                   employee_number, date_worked, start_time, end_time, hours,
                   earning_policy, hours_type, earn_reason_code, project,
                   task_number, location_code, hrw_comment, rate_multiple,
                   hourly_rate, amount, separate_check_flag,
                   business_group_id, concat_cost_segments, cost_segment1,
                   cost_segment2, cost_segment3, cost_segment4,
                   cost_segment5, cost_segment6, cost_segment7,
                   cost_segment8, cost_segment9, cost_segment10,
                   cost_segment11, cost_segment12, cost_segment13,
                   cost_segment14, cost_segment15, cost_segment16,
                   cost_segment17, cost_segment18, cost_segment19,
                   cost_segment20, cost_segment21, cost_segment22,
                   cost_segment23, cost_segment24, cost_segment25,
                   cost_segment26, cost_segment27, cost_segment28,
                   cost_segment29, cost_segment30, time_summary_id,
                   tim_sum_eff_start_date, tim_sum_eff_end_date
                  )
           VALUES (l_error_seqno, otm_msg, g_sysdatetime, created_by,
                   ora_message, timecard_source, approver_number,
                   employee_number, date_worked, start_time, end_time, hours,
                   earning_policy, hours_type, earn_reason_code, project,
                   task_number, location_code, hrw_comment, rate_multiple,
                   hourly_rate, amount, separate_check_flag,
                   business_group_id, concat_cost_segments, cost_segment1,
                   cost_segment2, cost_segment3, cost_segment4,
                   cost_segment5, cost_segment6, cost_segment7,
                   cost_segment8, cost_segment9, cost_segment10,
                   cost_segment11, cost_segment12, cost_segment13,
                   cost_segment14, cost_segment15, cost_segment16,
                   cost_segment17, cost_segment18, cost_segment19,
                   cost_segment20, cost_segment21, cost_segment22,
                   cost_segment23, cost_segment24, cost_segment25,
                   cost_segment26, cost_segment27, cost_segment28,
                   cost_segment29, cost_segment30, time_summary_id,
                   tim_sum_eff_start_date, tim_sum_eff_end_date
                  );
   END;

/**********************************************************
re_explode_timecard()
Fetch all hxt_sum_hours_worked records for the timecard
indicated. Call record_time for each record to re-explode.
***********************************************************/
   PROCEDURE re_explode_timecard (
      timecard_id          IN              NUMBER,
      tim_eff_start_date   IN              DATE,
      tim_eff_end_date     IN              DATE,
      dt_update_mode       IN              VARCHAR2,                  --SIR290
      otm_error            OUT NOCOPY      VARCHAR2,
      oracle_error         OUT NOCOPY      VARCHAR2
   )
--  p_mode IN VARCHAR2 default 'INSERT')
   IS

-- Bug 7359347
-- Changed the below cursors to use a session_date input value.
/*
      CURSOR get_timecard_rec (
         c_tim_id           NUMBER,
         c_tim_start_date   DATE,
         c_tim_end_date     DATE
      )
      IS
         SELECT tim.for_person_id, tbh.status, ptp.start_date        --SIR286
           FROM hxt_timecards tim,                                    --SIR290
                hxt_batch_states tbh,
                per_time_periods ptp                                  --SIR286
          WHERE tim.ID = c_tim_id
            AND tbh.batch_id = tim.batch_id
            AND ptp.time_period_id = tim.time_period_id              -- SIR286
                                                       ;              --SIR290
*/

      CURSOR get_timecard_rec (
         c_tim_id           NUMBER,
         c_tim_start_date   DATE
      )
      IS
         SELECT tim.for_person_id, tbh.status, ptp.start_date        --SIR286
           FROM hxt_timecards_f tim,                                    --SIR290
                hxt_batch_states tbh,
                per_time_periods ptp                                  --SIR286
          WHERE tim.ID = c_tim_id
            AND tbh.batch_id = tim.batch_id
            AND ptp.time_period_id = tim.time_period_id
            AND c_tim_start_date BETWEEN effective_start_date
                                     AND effective_end_date ;
                                     -- SIR286

      -- Bug 7359347

      /*
      CURSOR get_summary_rows (
         c_tim_id           NUMBER,
         c_tim_start_date   DATE,
         c_tim_end_date     DATE
      )
      IS
         SELECT   ID,                                             -- group_id,
                     effective_start_date, effective_end_date, tim_id,
                  date_worked, assignment_id, seqno, hours, time_in, time_out,
                  element_type_id, fcl_earn_reason_code, ffv_cost_center_id,
                  tas_id, location_id, sht_id, hrw_comment, ffv_rate_code_id,
                  rate_multiple, hourly_rate, amount, fcl_tax_rule_code,
                  separate_check_flag, created_by, creation_date,
                  last_updated_by, last_update_date, last_update_login,
                  actual_time_in, actual_time_out, prev_wage_code, project_id,
                  earn_pol_id, time_building_block_id,
                  time_building_block_ovn, state_name, county_name, city_name,
                  zip_code
             FROM hxt_sum_hours_worked
            WHERE tim_id = c_tim_id
         ORDER BY date_worked, element_type_id, time_in, seqno, ID;
       */

      CURSOR get_summary_rows (
         c_tim_id           NUMBER,
         c_tim_end_date     DATE
      )
      IS
         SELECT   ID,                                             -- group_id,
                     effective_start_date, effective_end_date, tim_id,
                  date_worked, assignment_id, seqno, hours, time_in, time_out,
                  element_type_id, fcl_earn_reason_code, ffv_cost_center_id,
                  tas_id, location_id, sht_id, hrw_comment, ffv_rate_code_id,
                  rate_multiple, hourly_rate, amount, fcl_tax_rule_code,
                  separate_check_flag, created_by, creation_date,
                  last_updated_by, last_update_date, last_update_login,
                  actual_time_in, actual_time_out, prev_wage_code, project_id,
                  earn_pol_id, time_building_block_id,
                  time_building_block_ovn, state_name, county_name, city_name,
                  zip_code
             FROM hxt_sum_hours_worked_f
            WHERE tim_id = c_tim_id
              AND c_tim_end_date BETWEEN effective_start_date
                                     AND effective_end_date
         ORDER BY date_worked, element_type_id, time_in, seqno, ID;


      l_retcode              NUMBER;
      l_batch_status         VARCHAR2 (30);
      l_timecard_rec         get_timecard_rec%ROWTYPE;
      l_otm_error            VARCHAR2 (120)                 DEFAULT NULL;
      l_oracle_error         VARCHAR2 (512)                 DEFAULT NULL;
      l_created_tim_sum_id   hxt_sum_hours_worked.ID%TYPE   DEFAULT NULL;
      l_tim_not_found_err    EXCEPTION;
      l_rec_hours_data_err   EXCEPTION;
      l_rec_hours_sys_err    EXCEPTION;
      l_delete_details_err   EXCEPTION;
      l_session_date         DATE;
      l_sess_date_err        EXCEPTION;
   BEGIN
      /* Initialize globals */
      g_debug := hr_utility.debug_enabled;
      g_sysdate := TRUNC (SYSDATE);
      g_sysdatetime := SYSDATE;
      g_user_id := fnd_global.user_id;
      g_login_id := fnd_global.login_id;

      IF g_debug
      THEN
         hr_utility.TRACE ('start re explode for loop');
      END IF;

      --
      -- Retrieve the timecard's header information.
      --
      -- Bug 7359347
      -- Moved this call below, so that session date is
      -- captured before this is done.
      /*
      OPEN get_timecard_rec (timecard_id, tim_eff_start_date,
                             tim_eff_end_date);

      FETCH get_timecard_rec
       INTO l_timecard_rec;

      IF get_timecard_rec%NOTFOUND
      THEN
         CLOSE get_timecard_rec;

         RAISE l_tim_not_found_err;
      ELSE
         CLOSE get_timecard_rec;
      END IF;

      */


      IF g_sess_date IS NULL
      THEN
         l_retcode := hxt_tim_col_util.get_session_date (g_sess_date);
      ELSE
         l_retcode := 0;
      END IF;

      l_session_date := g_sess_date;


      IF l_retcode = 1
      THEN
         RAISE l_sess_date_err;
      END IF;

      OPEN get_timecard_rec (timecard_id, l_session_date);

      FETCH get_timecard_rec
       INTO l_timecard_rec;

      IF get_timecard_rec%NOTFOUND
      THEN
         CLOSE get_timecard_rec;

         RAISE l_tim_not_found_err;
      ELSE
         CLOSE get_timecard_rec;

      END IF;

      hxt_time_collection.delete_details (timecard_id,
                                          dt_update_mode,
                                          l_session_date,
                                          l_otm_error
                                         );

      IF l_otm_error IS NOT NULL
      THEN
         RAISE l_delete_details_err;
      END IF;

      --
      -- Call record_hours_worked to re-explode each summary record.
      IF g_debug
      THEN
         hr_utility.TRACE ('Before for loop');
      END IF;

      --
      -- Bug 7359347
      -- Instead of start and end dates, pass the session_date.
      /*
      FOR l_sum_hours_rec IN get_summary_rows (timecard_id,
                                               tim_eff_start_date,
                                               tim_eff_end_date
                                              )
      */
      FOR l_sum_hours_rec IN get_summary_rows (timecard_id,
                                               l_session_date
                                              )
      LOOP
         l_retcode :=
            record_hours_worked (NULL,
                                 FALSE,
                                 l_sum_hours_rec.tim_id,
                                 l_sum_hours_rec.assignment_id,
                                 l_timecard_rec.for_person_id,
                                 l_sum_hours_rec.date_worked,
                                 l_sum_hours_rec.element_type_id,
                                 l_sum_hours_rec.hours,
                                 l_sum_hours_rec.time_in,
                                 l_sum_hours_rec.time_out,
                                 l_timecard_rec.start_date,
                                 l_sum_hours_rec.prev_wage_code,
                                 l_sum_hours_rec.tas_id,
                                 l_sum_hours_rec.location_id,
                                 l_sum_hours_rec.project_id,
                                 l_sum_hours_rec.earn_pol_id,
                                 l_sum_hours_rec.fcl_earn_reason_code,
                                 l_sum_hours_rec.ffv_cost_center_id,
                                 l_sum_hours_rec.hrw_comment,
                                 l_sum_hours_rec.rate_multiple,
                                 l_sum_hours_rec.hourly_rate,
                                 l_sum_hours_rec.amount,
                                 l_sum_hours_rec.separate_check_flag,
                                 l_sum_hours_rec.ID,
                                 l_sum_hours_rec.effective_start_date,
                                 l_sum_hours_rec.effective_end_date,
                                 l_sum_hours_rec.created_by,
                                 l_sum_hours_rec.last_updated_by,
                                 l_sum_hours_rec.last_update_login,
                                 'N',                            --writesum_yn
                                 'Y',                             --explode_yn
                                 l_timecard_rec.status,
                                 dt_update_mode,                      --SIR290
                                 l_sum_hours_rec.time_building_block_id,
                                 l_sum_hours_rec.time_building_block_ovn,
                                 l_otm_error,
                                 l_oracle_error,
                                 l_created_tim_sum_id,
                                 l_sum_hours_rec.state_name,
                                 l_sum_hours_rec.county_name,
                                 l_sum_hours_rec.city_name,
                                 l_sum_hours_rec.zip_code
                                );

         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode is :' || TO_CHAR (l_retcode));
         END IF;

         IF l_retcode = 1
         THEN
            RAISE l_rec_hours_data_err;
         ELSIF l_retcode = 2
         THEN
            RAISE l_rec_hours_sys_err;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN l_tim_not_found_err
      THEN
         fnd_message.set_name ('HXT', 'HXT_39561_CANNOT_FIND_TCARD');
         fnd_message.set_token ('TIM_ID', TO_CHAR (timecard_id));
         otm_error := fnd_message.get;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', otm_error);
      --2278400
      WHEN l_rec_hours_data_err
      THEN
         fnd_message.set_name ('HXT', 'HXT_39562_ERR_IN_RET');
         fnd_message.set_token ('ERR_TEXT', l_otm_error);
         otm_error := fnd_message.get;
      --call_hxthxc_gen_error('HXC','HXC_HXT_DEP_VAL_OTMERR',otm_error);  --2278400
      WHEN l_rec_hours_sys_err
      THEN
         fnd_message.set_name ('HXT', 'HXT_39562_ERR_IN_RET');
         fnd_message.set_token ('ERR_TEXT', l_oracle_error);
         oracle_error := fnd_message.get;
    --call_hxthxc_gen_error('HXC','HXC_HXT_DEP_VAL_OTMERR',oracle_error);  --2278400
--begin SIR334
      WHEN l_delete_details_err
      THEN
         fnd_message.set_name ('HXT', 'HXT_39563_ERR_IN_RET_DD');
         fnd_message.set_token ('ERR_TEXT', l_otm_error);
         otm_error := fnd_message.get;
      --call_hxthxc_gen_error('HXC','HXC_HXT_DEP_VAL_OTMERR',otm_error);  --2278400
      WHEN l_sess_date_err
      THEN
         fnd_message.set_name ('HXT', 'HXT_39556_SESSION_DT_NF');
         otm_error := fnd_message.get;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', otm_error);
                                                                    --2278400
--end SIR334
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39564_EXCP_IN_RET');
         otm_error := fnd_message.get;
         oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39564_EXCP_IN_RET', NULL);
   --2278400
   END re_explode_timecard;

/*-------------------------------------------------------------------------
||
||                     Private Module Definitions
||
-------------------------------------------------------------------------*/

   /***********************************
    get_time_period()
    Obtain the time period identifier
    for this particular pay date
   ************************************/
   FUNCTION get_time_period (
      i_payroll_id    IN              NUMBER,
      i_date_worked   IN              DATE,
      o_time_period   OUT NOCOPY      NUMBER,
      o_start_date    OUT NOCOPY      DATE,
      o_end_date      OUT NOCOPY      DATE
   )
      RETURN NUMBER
   IS
   BEGIN
      SELECT time_period_id, start_date, end_date
        INTO o_time_period, o_start_date, o_end_date
        FROM per_time_periods
       WHERE payroll_id = i_payroll_id
         AND TRUNC (i_date_worked) BETWEEN TRUNC (start_date) AND TRUNC
                                                                     (end_date);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 1;
      WHEN OTHERS
      THEN
         RETURN 2;
   END get_time_period;

/***************************************************
 check_for_timecard()
 Check the HXT_TIMECARDS table to see if a timecard
 already exists for the person punching the clock
****************************************************/
   FUNCTION check_for_timecard (
      i_person_id        IN              NUMBER,
      i_time_period_id   IN              NUMBER,
      o_timecard_id      OUT NOCOPY      NUMBER,
      o_auto_gen_flag    OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location ('hxt_time_collection.check_for_timecard',
                                  10
                                 );
      END IF;

      SELECT ID, auto_gen_flag, batch_id
        INTO o_timecard_id, o_auto_gen_flag, g_batch_err_id
        FROM hxt_timecards_f
       WHERE for_person_id = i_person_id AND time_period_id = i_time_period_id;

      IF g_debug
      THEN
         hr_utility.TRACE ('Timecard id is:' || o_timecard_id);
         hr_utility.TRACE ('auto_gen_flag :' || o_auto_gen_flag);
         hr_utility.TRACE ('batch_id      :' || g_batch_err_id);
         hr_utility.set_location ('hxt_time_collection.check_for_timecard',
                                  20
                                 );
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         IF g_debug
         THEN
            hr_utility.set_location
                                   ('hxt_time_collection.check_for_timecard',
                                    30
                                   );
         END IF;

         RETURN 1;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location
                                   ('hxt_time_collection.check_for_timecard',
                                    40
                                   );
         END IF;

         RETURN 2;
   END check_for_timecard;

/****************************************************
 check_for_batch_status()
****************************************************/
   FUNCTION check_for_batch_status (
      i_batch_id       IN              NUMBER,
      o_batch_status   OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN
      SELECT status
        INTO o_batch_status
        FROM hxt_batch_states
       WHERE batch_id = i_batch_id;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 1;
      WHEN OTHERS
      THEN
         RETURN 2;
   END check_for_batch_status;

/********************************************************
   create_timecard()
   Creates a timecard for the person punching the clock
   for this particular time period based on the payroll
   for this person.
*********************************************************/
   FUNCTION create_timecard (
      i_person_id              IN              NUMBER,
      i_business_group_id      IN              NUMBER,
      i_assignment_id          IN              NUMBER,
      i_payroll_id             IN              NUMBER,
      i_time_period_id         IN              NUMBER,
      i_approver_id            IN              NUMBER,
      i_timecard_source_code   IN              VARCHAR2,
      o_timecard_id            OUT NOCOPY      NUMBER
   )
      RETURN NUMBER
   IS
      l_proc                    VARCHAR2 (72);
      l_retcode                 NUMBER                            DEFAULT 0;
      l_batch_creation_error    EXCEPTION;
      l_batch_location_error    EXCEPTION;
      l_tim_id_creation_error   EXCEPTION;
      l_batch_id                pay_batch_headers.batch_id%TYPE  DEFAULT NULL;
      l_timecard_id             hxt_timecards.ID%TYPE            DEFAULT NULL;
      l_object_version_number   NUMBER                           DEFAULT NULL;
      l_rowid                   ROWID;
   BEGIN
      /* Obtain a batch id for the new timecard */
      IF g_debug
      THEN
         l_proc := g_package || 'create_timecard';
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

      l_batch_id :=
         find_existing_batch (p_time_period_id       => i_time_period_id,
                              --SIR413
                              p_batch_reference      => g_batch_ref
                             );

      /* If Not Found */
      IF (l_batch_id IS NULL)
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('No existing_batch ');
         END IF;

         /* Create a batch id for the new timecard */
         /* A Autogen;    C Autogen (changed); M Manual; U Manual (changed);
            T Time Clock; S Time Store */
         l_retcode :=
            create_batch (i_timecard_source_code,    --'C' source is timeclock
                          i_payroll_id,
                          i_time_period_id,
                          i_assignment_id,
                          i_person_id,
                          i_business_group_id,
                          l_batch_id
                         );

         IF g_debug
         THEN
            hr_utility.TRACE (   'AFTER create batch.  Create batch id is '
                              || TO_CHAR (l_batch_id)
                             );
            hr_utility.TRACE (   'AFTER create batch.  RETCODE is '
                              || TO_CHAR (l_retcode)
                             );
         END IF;

         IF l_retcode <> 0
         THEN
            RAISE l_batch_creation_error;
         END IF;

         -- Initialize counter + batch_id
         g_batch_info (NVL (g_batch_info.LAST, 0) + 1).batch_id := l_batch_id;
         g_batch_info (g_batch_info.LAST).period_id := i_time_period_id;
         g_batch_info (g_batch_info.LAST).batch_ref := g_batch_ref;
         g_batch_info (g_batch_info.LAST).num_tcs := 1;
      ELSIF l_retcode = 2
      THEN
         RAISE l_batch_location_error;
      END IF;

      g_batch_err_id := l_batch_id;
      --
        /* Generate a unique timecard id for the new timecard */
      l_timecard_id := hxt_time_gen.get_hxt_seqno;

      IF l_timecard_id = NULL
      THEN
         RAISE l_tim_id_creation_error;
      END IF;

       --
         /* Insert new timecard info to hxt_timecards */
         /* INSERT into hxt_timecards_f
            ( id,
              for_person_id,
              payroll_id,
              time_period_id,
              batch_id,
              approv_person_id,
              auto_gen_flag,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              effective_start_date,
              effective_end_date)
         VALUES
            ( l_timecard_id,
              i_person_id,
              i_payroll_id,
              i_time_period_id,
              l_batch_id,
              i_approver_id,
              i_timecard_source_code,
              g_user_id,
              g_sysdatetime,
              g_user_id,
              g_sysdatetime,
              g_login_id,
              trunc(g_sess_date),
              hr_general.end_of_time);
      */

      /* Call dml to insert new timecard. */
      IF g_debug
      THEN
         hr_utility.TRACE ('BEFORE DML create timecard');
      END IF;

      hxt_dml.insert_hxt_timecards
                           (p_rowid                      => l_rowid,
                            p_id                         => l_timecard_id,
                            p_for_person_id              => i_person_id,
                            p_time_period_id             => i_time_period_id,
                            p_auto_gen_flag              => i_timecard_source_code,
                            p_batch_id                   => l_batch_id,
                            p_approv_person_id           => i_approver_id,
                            p_approved_timestamp         => NULL,
                            p_created_by                 => g_user_id,
                            p_creation_date              => g_sysdatetime,
                            p_last_updated_by            => g_user_id,
                            p_last_update_date           => g_sysdatetime,
                            p_last_update_login          => g_login_id,
                            p_payroll_id                 => i_payroll_id,
                            p_status                     => NULL,
                            p_effective_start_date       => TRUNC (g_sess_date),
                            p_effective_end_date         => hr_general.end_of_time,
                            p_object_version_number      => l_object_version_number
                           );
      --
      o_timecard_id := l_timecard_id;

      IF g_debug
      THEN
         hr_utility.TRACE (   'AFTER DML create timecard.  timecard id is '
                           || TO_CHAR (l_timecard_id)
                          );
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN l_batch_creation_error
      THEN
         RETURN l_retcode;
      WHEN l_batch_location_error
      THEN
         RETURN l_retcode;
      WHEN l_tim_id_creation_error
      THEN
         RETURN 2;
      WHEN OTHERS
      THEN
         RETURN 2;
   END create_timecard;

/******************************************************************
  create_batch()
  Obtains an existing clock batch id for this particular timecard.
  If no clock batch id with less than 50 timecards exists.
  Creates a new batch id for this particular timecard.
******************************************************************/
   FUNCTION create_batch (
      i_source              IN              VARCHAR2,
      i_payroll_id          IN              NUMBER,
      i_time_period_id      IN              NUMBER,
      i_assignment_id       IN              NUMBER,
      i_person_id           IN              NUMBER,
      i_business_group_id   IN              NUMBER,
      o_batch_id            OUT NOCOPY      NUMBER
   )
      RETURN NUMBER
   IS
      l_batch_id                pay_batch_headers.batch_id%TYPE  DEFAULT NULL;
      l_batch_name              pay_batch_headers.batch_name%TYPE
                                                                 DEFAULT NULL;
      l_reference_num           pay_batch_headers.batch_reference%TYPE
                                                                 DEFAULT NULL;
      l_error_text              VARCHAR2 (128)                   DEFAULT NULL;
      l_batch_id_error          EXCEPTION;
      l_batch_name_error        EXCEPTION;
      l_reference_num_error     EXCEPTION;
      l_retcode                 NUMBER                              DEFAULT 0;
      l_object_version_number   NUMBER;
   BEGIN
      IF g_debug
      THEN
         hr_utility.TRACE ('IN cREATE BATCH ');
      END IF;

      IF (i_source = 'S') OR (g_batch_ref IS NOT NULL)
      THEN
         l_reference_num := g_batch_ref;
      ELSE
         hxt_user_exits.define_reference_number (i_payroll_id,
                                                 i_time_period_id,
                                                 i_assignment_id,
                                                 i_person_id,
                                                 g_user_name,
                                                 i_source,
                                                 l_reference_num,
                                                 l_error_text
                                                );
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('AFTER REF NUM ');
      END IF;

      IF l_error_text <> NULL
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('ERROR IS ' || l_error_text);
         END IF;

         RAISE l_reference_num_error;
      END IF;

      --
      IF g_debug
      THEN
         hr_utility.TRACE ('GET batch id');
      END IF;

      /* Get next batch number */
/*      l_batch_id := hxt_time_gen.get_next_batch_id;

      IF l_batch_id = NULL
      THEN
             hr_utility.TRACE ('batch id is null');
         RAISE l_batch_id_error;
      END IF;

      --
         hr_utility.TRACE (   'batch id is -----'
            || TO_CHAR (l_batch_id));
      IF i_source = 'S'
      THEN
         l_batch_name :=    g_batch_name
                         || TO_CHAR (l_batch_id);
      ELSE
         hxt_user_exits.define_batch_name (
            l_batch_id,
            l_batch_name,
            l_error_text
         );
      END IF;
*/
      IF g_debug
      THEN
         hr_utility.TRACE ('batch name is -----' || l_batch_name);
      END IF;

      IF l_error_text <> NULL
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('batch name error ');
         END IF;

         RAISE l_batch_name_error;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('BEFORE INSERT batch ');
      END IF;

/*      INSERT INTO pay_batch_headers
                  (batch_id, business_group_id, batch_name, batch_status,
                   action_if_exists, batch_reference, batch_source,
                   purge_after_transfer, reject_if_future_changes,
                   last_update_date, last_updated_by, last_update_login,
                   created_by, creation_date)
           VALUES (l_batch_id, i_business_group_id, l_batch_name, 'U',
                   'I', l_reference_num, 'OTM',
                   'N', 'N',
                   g_sysdatetime, g_user_id, g_login_id,
                   g_user_id, g_sysdatetime);

               hr_utility.TRACE ('AFTER insert batch ');
             */-- create a batch first
      pay_batch_element_entry_api.create_batch_header
                           (p_session_date                  => g_sysdatetime,
                            p_batch_name                    => TO_CHAR
                                                                  (SYSDATE,
                                                                   'DD-MM-RRRR HH24:MI:SS'
                                                                  ),
                            p_batch_status                  => 'U',
                            p_business_group_id             => i_business_group_id,
                            p_action_if_exists              => 'I',
                            p_batch_reference               => l_reference_num,
                            p_batch_source                  => 'OTM',
                            p_purge_after_transfer          => 'N',
                            p_reject_if_future_changes      => 'N',
                            p_batch_id                      => l_batch_id,
                            p_object_version_number         => l_object_version_number
                           );

      -- from the batch id, get the batch name
      IF i_source = 'S'
      THEN
         l_batch_name := g_batch_name || TO_CHAR (l_batch_id);
      ELSE
         hxt_user_exits.define_batch_name (l_batch_id,
                                           l_batch_name,
                                           l_error_text
                                          );
      END IF;

      IF l_error_text <> NULL
      THEN
         RAISE l_batch_name_error;
      END IF;

      --update the batch name
      pay_batch_element_entry_api.update_batch_header
                          (p_session_date               => g_sysdatetime,
                           p_batch_id                   => l_batch_id,
                           p_object_version_number      => l_object_version_number,
                           p_batch_name                 => l_batch_name
                          );
      o_batch_id := l_batch_id;
      RETURN 0;
   EXCEPTION
      WHEN l_batch_id_error
      THEN
         fnd_message.set_name ('HXT', 'HXT_39409_CREATE_BATCH');
         call_hxthxc_gen_error ('HXT', 'HXT_39409_CREATE_BATCH', NULL);
         --2278400
         RETURN 2;
      WHEN l_reference_num_error
      THEN
         fnd_message.set_name ('HXT', 'HXT_39410_CREATE_REF_FUNC');
         call_hxthxc_gen_error ('HXT', 'HXT_39410_CREATE_REF_FUNC', NULL);
         --2278400
         RETURN l_retcode;
      WHEN l_batch_name_error
      THEN
         fnd_message.set_name ('HXT', 'HXT_39484_CREATE_BATCH_NAME');
         call_hxthxc_gen_error ('HXT', 'HXT_39484_CREATE_BATCH_NAME', NULL);
         --2278400
         RETURN l_retcode;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39411_CREATE_BATCH_FUNC');
         call_hxthxc_gen_error ('HXT', 'HXT_39411_CREATE_BATCH_FUNC', NULL);
         --2278400
         RETURN 2;
   END create_batch;

/********************************************************************
  find_existing_batch()
  Examine the pay_batch_headers and the hxt_timeclocks
  tables for existing unprocessed timeclock batches. The
  batches must be in a hold status (batch_status = 'H')
  and have less than the max amount of timecards allowed per batch.
********************************************************************/
   FUNCTION find_existing_batch (
      p_time_period_id    IN   per_time_periods.time_period_id%TYPE,
      p_batch_reference   IN   pay_batch_headers.batch_reference%TYPE
   )
      RETURN pay_batch_headers.batch_id%TYPE
   IS
      CURSOR csr_timecard_batches (
         p_time_period_id    per_time_periods.time_period_id%TYPE,
         p_batch_reference   pay_batch_headers.batch_reference%TYPE
      )
      IS
         SELECT   COUNT (ht.ID) num_tcs, MAX (ht.batch_id) batch_id
             FROM hxt_timecards ht,
                  hxt_batch_states hbs,
                  pay_batch_headers pbh
            WHERE ht.time_period_id = p_time_period_id
              AND hbs.batch_id = ht.batch_id
              AND pbh.batch_id = ht.batch_id
              AND hbs.status <> 'VT'
              AND pbh.batch_reference LIKE NVL (p_batch_reference, '%') || '%'
           HAVING COUNT (ht.ID) < g_max_tc_allowed
         GROUP BY ht.batch_id;

      l_proc               VARCHAR2 (72);
      l_timecard_batches   csr_timecard_batches%ROWTYPE;
      l_batch_id           pay_batch_headers.batch_id%TYPE;
      l_batch_tbl_idx      PLS_INTEGER                   := g_batch_info.FIRST;
   BEGIN
      IF g_debug
      THEN
         l_proc := g_package || 'find_existing_batch';
         hr_utility.set_location ('Entering:' || l_proc, 10);
      END IF;

      IF (CACHE)
      THEN

         <<check_cached_batches>>
         LOOP
            EXIT check_cached_batches WHEN (NOT (g_batch_info.EXISTS
                                                              (l_batch_tbl_idx)
                                                )
                                           );

            IF (    (g_batch_info (l_batch_tbl_idx).batch_ref LIKE
                                                  NVL (p_batch_reference, '%')
                    )
                AND (g_batch_info (l_batch_tbl_idx).period_id =
                                                              p_time_period_id
                    )
                AND (g_batch_info (l_batch_tbl_idx).num_tcs < g_max_tc_allowed
                    )
               )
            THEN
               l_batch_id := g_batch_info (l_batch_tbl_idx).batch_id;
               g_batch_info (l_batch_tbl_idx).num_tcs :=
                                   g_batch_info (l_batch_tbl_idx).num_tcs + 1;
               l_batch_tbl_idx := g_batch_info.LAST;

               -- to trigger exit of loop
               IF g_debug
               THEN
                  hr_utility.set_location (   '   Found batch_id in cache:'
                                           || l_batch_id,
                                           20
                                          );
               END IF;
            END IF;

            l_batch_tbl_idx := g_batch_info.NEXT (l_batch_tbl_idx);
         END LOOP check_cached_batches;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving:' || l_proc, 100);
      END IF;

      RETURN l_batch_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39412_FIND_BATCH_FUNC');
         call_hxthxc_gen_error ('HXT', 'HXT_39412_FIND_BATCH_FUNC', NULL);
         RETURN NULL;
   END find_existing_batch;

/**********************************************************
  create_holiday_hours()
  Creates hours on new timecards for all holidays falling
  between the start and end dates of the pay period.
**********************************************************/
   FUNCTION create_holiday_hours (
      i_person_id                 IN              NUMBER,
      i_hcl_id                    IN              NUMBER,
      i_hxt_rotation_plan         IN              NUMBER,             --SIR344
      i_start_date                IN              DATE,
      i_end_date                  IN              DATE,
      i_timecard_id               IN              NUMBER,
      i_wage_code                 IN              VARCHAR2,
      i_task_id                   IN              NUMBER,
      i_location_id               IN              NUMBER,
      i_project_id                IN              hxt_sum_hours_worked.project_id%TYPE,
      i_earn_pol_id               IN              hxt_sum_hours_worked.earn_pol_id%TYPE,
      i_earn_reason_code          IN              VARCHAR2,
      i_comment                   IN              VARCHAR2,
      i_rate_multiple             IN              NUMBER,
      i_hourly_rate               IN              NUMBER,
      i_amount                    IN              NUMBER,
      i_separate_check_flag       IN              VARCHAR2,
      i_assignment_id             IN              NUMBER,
      i_time_summary_id           IN              NUMBER,
      i_tim_sum_eff_start_date    IN              DATE,
      i_tim_sum_eff_end_date      IN              DATE,
      i_created_by                IN              NUMBER,
      i_last_updated_by           IN              NUMBER,
      i_last_update_login         IN              NUMBER,
      i_writesum_yn               IN              VARCHAR2,
      i_explode_yn                IN              VARCHAR2,
      i_batch_status              IN              VARCHAR2,
      i_dt_update_mode            IN              VARCHAR2,           --SIR290
      p_time_building_block_id    IN              NUMBER DEFAULT NULL,
      p_time_building_block_ovn   IN              NUMBER DEFAULT NULL,
      o_otm_error                 OUT NOCOPY      VARCHAR2,
      o_oracle_error              OUT NOCOPY      VARCHAR2,
      o_created_tim_sum_id        OUT NOCOPY      NUMBER,
      i_start_time                IN              DATE,
      i_end_time                  IN              DATE,
      i_state_name                IN              VARCHAR2 DEFAULT NULL,
      i_county_name               IN              VARCHAR2 DEFAULT NULL,
      i_city_name                 IN              VARCHAR2 DEFAULT NULL,
      i_zip_code                  IN              VARCHAR2 DEFAULT NULL
   )
      --          p_mode IN VARCHAR2 default 'INSERT')
   RETURN NUMBER
   IS
      l_hol_rec              g_hol_cur%ROWTYPE;
      l_retcode              NUMBER                         DEFAULT 0;
      l_otm_error            VARCHAR2 (120)                 DEFAULT NULL;
      l_oracle_error         VARCHAR2 (512)                 DEFAULT NULL;
      l_created_tim_sum_id   hxt_sum_hours_worked.ID%TYPE   DEFAULT NULL;
      l_hours_worked_error   EXCEPTION;
--BEGIN SIR344
      l_time_in              DATE                           := NULL;
      l_time_out             DATE                           := NULL;
      l_hours                NUMBER;
      l_work_id              NUMBER;
      l_osp_id               NUMBER;
      l_sdf_id               NUMBER;
      l_standard_start       NUMBER;
      l_standard_stop        NUMBER;
      l_early_start          NUMBER;
      l_late_stop            NUMBER;
      l_proc                 VARCHAR2 (100);
   BEGIN
      IF g_debug
      THEN
         l_proc := 'hxt_time_collection.CREATE_HOLIDAY_HOURS';
         hr_utility.set_location (l_proc, 10);
         hr_utility.TRACE ('i_start_date :' || i_start_date);
         hr_utility.TRACE ('i_end_date   :' || i_end_date);
         hr_utility.TRACE ('i_hcl_id     :' || i_hcl_id);
         hr_utility.TRACE (   'i_start_time is '
                           || TO_CHAR (i_start_time, 'DD-MON-YYYY HH:MI:SS')
                          );
         hr_utility.TRACE (   'i_end_time is '
                           || TO_CHAR (i_end_time, 'DD-MON-YYYY HH:MI:SS')
                          );
      END IF;

      FOR l_hol_rec IN g_hol_cur (i_start_date, i_end_date, i_hcl_id)
      LOOP
         hr_utility.set_location (l_proc, 20);

         IF (   fnd_profile.VALUE ('HXT_HOL_HOURS_FROM_HOL_CAL') = 'Y'
             OR fnd_profile.VALUE ('HXT_HOL_HOURS_FROM_HOL_CAL') IS NULL
            )
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 30);
            END IF;

            l_hours := l_hol_rec.hours;
            l_time_out := NULL;
            l_time_in := NULL;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_hours    :' || l_hours);
               hr_utility.TRACE ('l_time_in  :' || l_time_in);
               hr_utility.TRACE ('l_time_out :' || l_time_out);
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 40);
            END IF;

            IF i_hxt_rotation_plan IS NOT NULL
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               hxt_util.get_shift_info (l_hol_rec.holiday_date,
                                        l_work_id,
                                        i_hxt_rotation_plan,
                                        l_osp_id,
                                        l_sdf_id,
                                        l_standard_start,
                                        l_standard_stop,
                                        l_early_start,
                                        l_late_stop,
                                        l_hours,
                                        l_retcode
                                       );

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_retcode :' || l_retcode);
               END IF;

               IF l_retcode <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 60);
                  END IF;

                  RAISE l_hours_worked_error;
               END IF;

               IF l_hours IS NOT NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 70);
                  END IF;

                  l_time_out := NULL;
                  l_time_in := NULL;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_time_in  :' || l_time_in);
                     hr_utility.TRACE ('l_time_out :' || l_time_out);
                  END IF;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 80);
                  END IF;

                  l_time_in :=
                     TO_DATE (   TO_CHAR (l_hol_rec.holiday_date, 'DDMMYYYY ')
                              || TO_CHAR (l_standard_start, '0009'),
                              'DDMMYYYY HH24MI'
                             );
                  l_time_out :=
                     TO_DATE (   TO_CHAR (l_hol_rec.holiday_date, 'DDMMYYYY ')
                              || TO_CHAR (l_standard_stop, '0009'),
                              'DDMMYYYY HH24MI'
                             );
                  l_hours := 24 * (l_time_out - l_time_in);

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_hours    :' || l_hours);
                     hr_utility.TRACE ('l_time_in  :' || l_time_in);
                     hr_utility.TRACE ('l_time_out :' || l_time_out);
                  END IF;

                  IF l_hours = 0
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 90);
                     END IF;

                     l_time_out := NULL;
                     l_time_in := NULL;

                     IF g_debug
                     THEN
                        hr_utility.TRACE ('l_time_in  :' || l_time_in);
                        hr_utility.TRACE ('l_time_out :' || l_time_out);
                     END IF;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 100);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 110);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 120);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_hours:' || l_hours);
         END IF;

         IF l_hours >= 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 130);
            END IF;

            l_retcode :=
               record_hours_worked (NULL,
                                    TRUE,
                                    i_timecard_id,
                                    i_assignment_id,
                                    i_person_id,
                                    l_hol_rec.holiday_date,
                                    l_hol_rec.element_type_id,
                                    l_hours,
                                    --l_time_in,
                                    --l_time_out,
                                    i_start_time,
                                    i_end_time,
                                    i_start_date,
                                    i_wage_code,
                                    i_task_id,
                                    i_location_id,
                                    i_project_id,
                                    i_earn_pol_id,
                                    i_earn_reason_code,
                                    NULL,
                                    i_comment,
                                    i_rate_multiple,
                                    i_hourly_rate,
                                    i_amount,
                                    i_separate_check_flag,
                                    i_time_summary_id,
                                    i_tim_sum_eff_start_date,
                                    i_tim_sum_eff_end_date,
                                    i_created_by,
                                    i_last_updated_by,
                                    i_last_update_login,
                                    i_writesum_yn,
                                    i_explode_yn,
                                    i_batch_status,
                                    i_dt_update_mode,
                                    p_time_building_block_id,
                                    p_time_building_block_ovn,
                                    l_otm_error,
                                    l_oracle_error,
                                    l_created_tim_sum_id,
                                    i_state_name,
                                    i_county_name,
                                    i_city_name,
                                    i_zip_code
                                   );

            --p_mode);
            IF g_debug
            THEN
               hr_utility.TRACE ('l_retcode :' || l_retcode);
               hr_utility.set_location (l_proc, 140);
            END IF;
         END IF;

         IF l_retcode <> 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 150);
            END IF;

            RAISE l_hours_worked_error;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 160);
         END IF;

         o_otm_error := l_otm_error;
         o_oracle_error := l_oracle_error;
         o_created_tim_sum_id := l_created_tim_sum_id;

         IF g_debug
         THEN
            hr_utility.TRACE ('o_otm_error          :' || o_otm_error);
            hr_utility.TRACE ('o_oracle_error       :' || o_oracle_error);
            hr_utility.TRACE ('o_created_tim_sum_id :' || o_created_tim_sum_id
                             );
         END IF;
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 170);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 180);
         END IF;

         RETURN 0;
      WHEN l_hours_worked_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 190);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39565_ERR_IN_CHH');
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39565_ERR_IN_CHH', NULL);
         --2278400
         RETURN 1;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 200);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39413_LOC_HOL');
         fnd_message.set_token ('ASG_ID', TO_CHAR (i_assignment_id));
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', o_otm_error);
         --2278400
         RETURN 2;
   END create_holiday_hours;

/*************************************************************************/
  --  Procedure LOAD_POLICIES
  --  Purpose:  Gets policies and premiums assigned to an input person
  --         on the date worked.
  --
  -- Modification Log:
  -- MM/DD/YY   INI   Description
/*************************************************************************/
   PROCEDURE load_policies (
      p_summ_id                 IN              NUMBER,
      p_summ_earn_pol_id        IN              NUMBER,
      p_summ_assignment_id      IN              NUMBER,
      p_summ_date_worked        IN              DATE,
      p_work_plan               OUT NOCOPY      NUMBER,
      p_rotation_plan           OUT NOCOPY      NUMBER,
      p_rotation_or_work_plan   OUT NOCOPY      VARCHAR2
                                                        -- ,p_retcode                 OUT NOCOPY NUMBER
                                                                                 -- ,p_hours                OUT NOCOPY NUMBER
   ,
      p_shift_hours             OUT NOCOPY      NUMBER,
      p_egp_id                  OUT NOCOPY      hxt_sum_hours_worked.earn_pol_id%TYPE -- 5903580 NUMBER        earning policy
                                                      ,
      p_hdp_id                  OUT NOCOPY      NUMBER -- hrs deduction policy
                                                      -- ,p_hdy_id                 OUT NOCOPY NUMBER    -- holiday day ID
   ,
      p_sdp_id                  OUT NOCOPY      NUMBER    -- shift diff policy
                                                      ,
      p_egp_type                OUT NOCOPY      VARCHAR2
                                                        -- earning policy type
   ,
      p_egt_id                  OUT NOCOPY      NUMBER
                                                      -- include earning group
   ,
      p_pep_id                  OUT NOCOPY      NUMBER     -- prem elig policy
                                                      ,
      p_pip_id                  OUT NOCOPY      NUMBER -- prem interact policy
                                                      ,
      p_hcl_id                  OUT NOCOPY      NUMBER     -- holiday calendar
                                                      ,
      p_hcl_elt_id              OUT NOCOPY      NUMBER -- holiday earning type
                                                      ,
      p_sdf_id                  OUT NOCOPY      NUMBER  -- override shift diff
                                                      ,
      p_osp_id                  OUT NOCOPY      NUMBER       -- off-shift prem
                                                      ,
      p_standard_start          OUT NOCOPY      NUMBER,
      p_standard_stop           OUT NOCOPY      NUMBER,
      p_early_start             OUT NOCOPY      NUMBER,
      p_late_stop               OUT NOCOPY      NUMBER,
      p_min_tcard_intvl         OUT NOCOPY      NUMBER,
      p_round_up                OUT NOCOPY      NUMBER,
      p_hol_code                OUT NOCOPY      NUMBER,
      p_hol_yn                  OUT NOCOPY      VARCHAR2,
      p_error                   OUT NOCOPY      NUMBER,
      p_overtime_type           OUT NOCOPY      VARCHAR2,
      p_otm_error               OUT NOCOPY      VARCHAR2
   )
   IS
      error_in_policies     EXCEPTION;
      error_in_shift_info   EXCEPTION;
      --  error_in_check_hol   exception;
      l_proc                VARCHAR2 (100);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := 'hxt_time_collection.LOAD_POLICIES';
         hr_utility.set_location (l_proc, 10);
      END IF;

      p_hol_yn := 'N';

-- Get policies assigned to person
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 20);
         END IF;

         p_egp_id := p_summ_earn_pol_id;
         hxt_util.get_policies (p_egp_id,
                                p_summ_assignment_id,
                                p_summ_date_worked,
                                p_work_plan,
                                p_rotation_plan,
                                p_egp_id,
                                p_hdp_id,
                                p_sdp_id,
                                p_egp_type,
                                p_egt_id,
                                p_pep_id,
                                p_pip_id,
                                p_hcl_id,
                                p_min_tcard_intvl,
                                p_round_up,
                                p_hcl_elt_id,
                                p_error
                               );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 30);
         END IF;

         -- Check if error encountered
         IF p_error <> 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 40);
            END IF;

            RAISE error_in_policies;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 50);
         END IF;
      END;

-- Check if person assigned work or rotation plan
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 60);
         END IF;

         IF (p_work_plan IS NOT NULL) OR (p_rotation_plan IS NOT NULL)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 70);
            END IF;

            -- Get premiums for shift
            hxt_util.get_shift_info (p_summ_date_worked,
                                     p_work_plan,
                                     p_rotation_plan,
                                     p_osp_id,
                                     p_sdf_id,
                                     p_standard_start,
                                     p_standard_stop,
                                     p_early_start,
                                     p_late_stop,
                                     p_shift_hours,
                                     p_error
                                    );

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 80);
            END IF;

            -- Check if error encountered
            IF p_error <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 90);
               END IF;

               RAISE error_in_shift_info;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 100);
            END IF;
         END IF;                      -- person assigned work or rotation plan

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 110);
         END IF;
      END;
-- Get holiday earning, day before/after, etc
/*   BEGIN

       HXT_UTIL.Check_For_Holiday
                           (p_summ_date_worked
                          , p_hcl_id
                          , p_hdy_id
                          , p_hours
                          , p_retcode);

       -- Check if holiday
          IF p_retcode = 1 THEN
             p_hol_yn := 'Y';     -- Set holiday code
          END IF;                 -- holiday or not

   EXCEPTION
      -- Check for error
         WHEN others THEN
              RAISE error_in_check_hol;
   END;
*/
   EXCEPTION
      WHEN error_in_policies
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 120);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39171_ERN_POL_OP_VIOL');
         fnd_message.set_token ('ORA_ERROR', SQLERRM);
         p_otm_error := fnd_message.get;
      WHEN error_in_shift_info
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 130);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39172_SHF_PREMS_OP_VIOL');
         fnd_message.set_token ('ORA_ERROR', SQLERRM);
         p_otm_error := fnd_message.get;
/*
   WHEN error_in_check_hol THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39173_HOL_OP_VIOL');
       FND_MESSAGE.SET_TOKEN('ORA_ERROR',SQLERRM);
       p_otm_error := fnd_message.get;
*/
   END load_policies;

/*************************************************************************
  record_hours_worked()
  Fetches additional assignment details about employees.
  Creates hours worked records on the hxt_hours_worked database table.
  Calls the hxt_time_summary.generate_details function to explode details.
**************************************************************************/
   FUNCTION record_hours_worked (
      p_timecard_source           IN              VARCHAR2,
      b_generate_holiday          IN              BOOLEAN,
      i_timecard_id               IN              NUMBER,
      i_assignment_id             IN              NUMBER,
      i_person_id                 IN              NUMBER,
      i_date_worked               IN              DATE,
      i_element_id                IN              NUMBER,
      i_hours                     IN              NUMBER,
      i_start_time                IN              DATE,
      i_end_time                  IN              DATE,
      i_start_date                IN              DATE,
      i_wage_code                                 VARCHAR2,
      i_task_id                   IN              NUMBER,
      i_location_id               IN              NUMBER,
      i_project_id                IN              hxt_sum_hours_worked.project_id%TYPE,
      i_earn_pol_id               IN              hxt_sum_hours_worked.earn_pol_id%TYPE,
      -- SIR286
      i_earn_reason_code          IN              VARCHAR2,
      i_cost_center_id            IN              NUMBER,
      i_comment                   IN              VARCHAR2,
      i_rate_multiple             IN              NUMBER,
      i_hourly_rate               IN              NUMBER,
      i_amount                    IN              NUMBER,
      i_separate_check_flag       IN              VARCHAR2,
      i_time_summary_id           IN              NUMBER,
      i_tim_sum_eff_start_date    IN              DATE,
      i_tim_sum_eff_end_date      IN              DATE,
      i_created_by                IN              NUMBER,
      i_last_updated_by           IN              NUMBER,
      i_last_update_login         IN              NUMBER,
      i_writesum_yn               IN              VARCHAR2,
      i_explode_yn                IN              VARCHAR2,
      i_batch_status              IN              VARCHAR2,
      i_dt_update_mode            IN              VARCHAR2,           --SIR290
      p_time_building_block_id    IN              NUMBER DEFAULT NULL,
      p_time_building_block_ovn   IN              NUMBER DEFAULT NULL,
      o_otm_error                 OUT NOCOPY      VARCHAR2,
      o_oracle_error              OUT NOCOPY      VARCHAR2,
      o_created_tim_sum_id        OUT NOCOPY      NUMBER,
      i_state_name                IN              VARCHAR2 DEFAULT NULL,
      i_county_name               IN              VARCHAR2 DEFAULT NULL,
      i_city_name                 IN              VARCHAR2 DEFAULT NULL,
      i_zip_code                  IN              VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
     -- Bug 7359347
     -- Changed the below cursors to pick up
     -- the base table instead of the view.
/*
      CURSOR upd_det_cur (p_id NUMBER)
      IS
         SELECT fcl_earn_reason_code, ffv_cost_center_id, rate_multiple,
                hourly_rate, separate_check_flag, seqno, creation_date
           -- group_id
         FROM   hxt_sum_hours_worked
          WHERE ID = p_id
            AND g_sysdate BETWEEN effective_start_date AND effective_end_date;

      -- Begin AM 007a
      CURSOR allow_summary_correction (c_sum_id NUMBER)
      IS
         SELECT 'Y'
           FROM hxt_sum_hours_worked
          WHERE ID = c_sum_id AND effective_start_date = TRUNC (g_sess_date);
*/

      CURSOR upd_det_cur (p_id NUMBER)
      IS
         SELECT fcl_earn_reason_code, ffv_cost_center_id, rate_multiple,
                hourly_rate, separate_check_flag, seqno, creation_date
           -- group_id
         FROM   hxt_sum_hours_worked_f
          WHERE ID = p_id
            AND g_sysdate BETWEEN effective_start_date AND effective_end_date;

      -- Begin AM 007a
      CURSOR allow_summary_correction (c_sum_id NUMBER)
      IS
         SELECT 'Y'
           FROM hxt_sum_hours_worked_f
          WHERE ID = c_sum_id AND effective_start_date = TRUNC (g_sess_date);


      -- END AM 007a

      -- l_hol_yn                   CHAR           DEFAULT 'N';
      l_details_error            EXCEPTION;
      l_details_system_error     EXCEPTION;
      l_hours_worked_id_error    EXCEPTION;
      l_seq_num_error            EXCEPTION;
      l_paymix_error             EXCEPTION;
      l_generate_details_error   EXCEPTION;
      l_inc_tim_hr_entry_err     EXCEPTION;
      l_adjust_tim_error         EXCEPTION;
      l_retcode                  NUMBER                              DEFAULT 0;
      l_hours_worked_id          NUMBER                           DEFAULT NULL;
      l_sequence_number          NUMBER                           DEFAULT NULL;
      l_otm_error                VARCHAR2 (300);
      l_rowid                    ROWID;
      l_object_version_number    NUMBER                           DEFAULT NULL;
      l_allow_sum_correction     VARCHAR2 (1)                           := 'N';
      --l_det_rec                  g_details_cur%ROWTYPE;
      --l_ep_det_rec               g_earn_pol_details_cur%ROWTYPE;
      l_dt_update_mode           VARCHAR2 (20)             := i_dt_update_mode;
      l_return_code              NUMBER;
      l_error_message            VARCHAR2 (300);
      v_row_id                   ROWID;
      l_time_id                  NUMBER;
      l_created_by               NUMBER;
      l_creation_date            DATE;
      l_actual_time_in           DATE;
      l_actual_time_out          DATE;
      l_job_id                   NUMBER;
      l_start_time               DATE                          := i_start_time;
      l_end_time                 DATE                            := i_end_time;
      l_d_hours                  NUMBER;
      l_hours                    NUMBER                             := i_hours;
      l_ad_code                  NUMBER;
      l_ad_error                 VARCHAR2 (300);
      l_session_date             DATE;
      l_sess_date_err            EXCEPTION;
      l_retro_edit_err           EXCEPTION;
      l_delete_details_err       EXCEPTION;
      o_error_message            VARCHAR2 (300);
      o_return_code              NUMBER;
      l_work_plan                NUMBER;
      l_rotation_plan            NUMBER;
      l_rotation_or_work_plan    VARCHAR2 (1);
      l_shift_hours              NUMBER;
      l_egp_id                   NUMBER;                     -- earning policy
      l_hdp_id                   NUMBER;             -- hours deduction policy
      l_hdy_id                   NUMBER;                     -- holiday day ID
      l_sdp_id                   NUMBER;                  -- shift diff policy
      l_egp_type                 VARCHAR2 (30);         -- earning policy type
      l_egt_id                   NUMBER;              -- include earning group
      l_pep_id                   NUMBER;                   -- prem elig policy
      l_pip_id                   NUMBER;               -- prem interact policy
      l_hcl_id                   NUMBER;                   -- holiday calendar
      l_hcl_elt_id               NUMBER;               -- holiday earning type
      l_sdf_id                   NUMBER;           -- override shift diff prem
      l_osp_id                   NUMBER;                     -- off-shift prem
      l_standard_start           NUMBER;
      l_standard_stop            NUMBER;
      l_early_start              NUMBER;
      l_late_stop                NUMBER;
      l_min_tcard_intvl          NUMBER;
      l_round_up                 NUMBER;
      l_hol_code                 NUMBER;
      l_hol_yn                   VARCHAR2 (1)                           := 'N';
      l_error                    NUMBER;
      l_overtime_type            VARCHAR2 (4);
      l_otm_err                  VARCHAR2 (400);
      l_upd_rec                  upd_det_cur%ROWTYPE;
      l_proc                     VARCHAR2 (100);
      l_timecard_info            hxc_self_service_time_deposit.timecard_info;
      l_index                    NUMBER;
      l_changed_flag             BOOLEAN;
   BEGIN
      IF g_debug
      THEN
         l_proc := 'hxt_time_collection.RECORD_HOURS_WORKED';
         hr_utility.set_location (l_proc, 10);
      END IF;

      /*Fetch additional assignment details about this employee*/
/*
      BEGIN
             hr_utility.set_location (l_proc, 20);
         OPEN g_details_cur (i_assignment_id, i_date_worked);
         FETCH g_details_cur INTO l_det_rec;
         CLOSE g_details_cur;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
                   hr_utility.set_location (l_proc, 30);
            RAISE l_details_error;
         WHEN OTHERS
         THEN
                   hr_utility.set_location (l_proc, 40);
            RAISE l_details_system_error;
      END;
*/
      /*Get earning policy details */
/*
               hr_utility.set_location (l_proc, 50);
      OPEN g_earn_pol_details_cur (
         NVL (i_earn_pol_id, l_det_rec.hxt_earning_policy),
         i_date_worked
      );
      FETCH g_earn_pol_details_cur INTO l_ep_det_rec;
      CLOSE g_earn_pol_details_cur;
*/

      -- Gets policies and premiums assigned to the person on the date worked.
      load_policies (i_time_summary_id,
                     i_earn_pol_id,
                     i_assignment_id,
                     i_date_worked,
                     l_work_plan,
                     l_rotation_plan,
                     l_rotation_or_work_plan,
                     --   l_retcode,
                     --   l_hours,
                     l_shift_hours,                                  -- SIR212
                     l_egp_id,                               -- earning policy
                     l_hdp_id,                       -- hours deduction policy
                     --   l_hdy_id,              -- holiday day ID
                     l_sdp_id,                            -- shift diff policy
                     l_egp_type,                        -- earning policy type
                     l_egt_id,                        -- include earning group
                     l_pep_id,                             -- prem elig policy
                     l_pip_id,                         -- prem interact policy
                     l_hcl_id,                             -- holiday calendar
                     l_hcl_elt_id,                     -- holiday earning type
                     l_sdf_id,                     -- override shift diff prem
                     l_osp_id,                               -- off-shift prem
                     l_standard_start,
                     l_standard_stop,
                     l_early_start,
                     l_late_stop,
                     l_min_tcard_intvl,
                     l_round_up,
                     l_hol_code,
                     l_hol_yn,
                     l_error,
                     l_overtime_type,
                     l_otm_error
                    );

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 20);
      END IF;

      IF l_otm_error IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 30);
         END IF;

         RAISE l_details_error;
      END IF;

      /* Adjust the timings for any T/C Interval and Rounding factors given in */
      /* the earn policies - SIR236 */

      /* Perform the holiday processing */

      /*Obtain a unique hours worked id*/
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 40);
      END IF;

      IF i_time_summary_id IS NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 50);
         END IF;

         l_hours_worked_id := hxt_time_gen.get_hxt_seqno;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_hours_worked_id :' || l_hours_worked_id);
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 60);
         END IF;

         l_hours_worked_id := i_time_summary_id;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_hours_worked_id :' || l_hours_worked_id);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 70);
      END IF;

      IF l_hours_worked_id = NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 80);
         END IF;

         RAISE l_hours_worked_id_error;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 90);
      END IF;

      g_hours_worked_err_id := l_hours_worked_id;
      o_created_tim_sum_id := l_hours_worked_id;

      IF g_debug
      THEN
         hr_utility.TRACE ('g_hours_worked_err_id :' || g_hours_worked_err_id);
         hr_utility.TRACE ('o_created_tim_sum_id  :' || o_created_tim_sum_id);
      END IF;

      IF b_generate_holiday = TRUE
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 100);
         END IF;

         l_hours := i_hours;
         l_start_time := i_start_time;
         l_end_time := i_end_time;
         l_hol_yn := 'Y';

         IF g_debug
         THEN
            hr_utility.TRACE ('l_hours      :' || l_hours);
            hr_utility.TRACE ('l_start_time :' || l_start_time);
            hr_utility.TRACE ('l_end_time   :' || l_end_time);
            hr_utility.TRACE ('l_hol_yn     :' || l_hol_yn);
         END IF;
      ELSE
         IF (i_start_time IS NOT NULL AND i_end_time IS NOT NULL)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 110);
               hr_utility.TRACE ('before Adjust_Timings');
            END IF;

            hxt_time_collection.adjust_timings
                                            (p_timecard_source,
                                             i_assignment_id,
                                             i_person_id,
                                             i_date_worked,
                                             i_timecard_id,
                                             l_hours_worked_id,
                                             i_earn_pol_id,
                                             l_start_time,
                                             l_end_time,
                                             l_d_hours,
                                             l_ad_code,
                                             l_ad_error,
                                             l_start_time,            -- null,
                                             l_end_time,              -- null,
                                             l_start_time,
                                                          -- l_actual_time_in,
                                             l_end_time   -- l_actual_time_out
                                            );                       -- SIR236

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 120);
               hr_utility.TRACE ('after Adjust_Timings');
               hr_utility.TRACE ('l_ad_error is : ' || l_ad_error);
               hr_utility.TRACE ('l_ad_code is : ' || TO_CHAR (l_ad_code));
            END IF;

            IF l_ad_code <> 0
            THEN                                                     -- SIR236
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 125);
               END IF;

               RAISE l_adjust_tim_error;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 130);
            END IF;

            l_hours := reset_hours (l_start_time, l_end_time);

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 140);
               hr_utility.TRACE ('l_hours :' || l_hours);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 150);
         END IF;
      END IF;

      /*Obtain a unique hours worked id*/

      /*
            IF i_time_summary_id IS NULL THEN
               l_hours_worked_id := hxt_time_gen.Get_HXT_Seqno;
            ELSE
               l_hours_worked_id := i_time_summary_id;
            END IF;
          --

            IF l_hours_worked_id = NULL THEN
               RAISE l_hours_worked_id_error;
            END IF;
          --
            g_hours_worked_err_id := l_hours_worked_id;
            o_created_tim_sum_id := l_hours_worked_id;
      */
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 155);
      END IF;

      /*Obtain the next sequence number for hours worked on this day*/
      l_sequence_number :=
                        hxt_util.get_next_seqno (i_timecard_id, i_date_worked);

      IF g_debug
      THEN
         hr_utility.TRACE ('l_sequence_number :' || l_sequence_number);
      END IF;

      --
      IF l_sequence_number = NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 160);
         END IF;

         RAISE l_seq_num_error;
      END IF;

      --
      IF i_writesum_yn = 'Y'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 170);
         END IF;

         IF i_time_summary_id IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 180);
            END IF;

            -- SELECT hxt_group_id_s.nextval
                -- INTO l_group_id
                -- FROM dual;
                --
             /*
                INSERT INTO hxt_sum_hours_worked_f
             ( id,
               tim_id,
               date_worked,
               seqno,
               hours,
               group_id,
               assignment_id,
               element_type_id,
               actual_time_in,  --SIR374
               actual_time_out, --SIR374
               time_in,
               time_out,
               fcl_earn_reason_code,
               ffv_cost_center_id,
               tas_id,
               location_id,
               project_id,
               earn_pol_id,
               separate_check_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               prev_wage_code,
               hrw_comment,
               rate_multiple,
               hourly_rate,
               amount,
               effective_start_date,
               effective_end_date)
             VALUES
             ( l_hours_worked_id,
               i_timecard_id,
               i_date_worked,
               l_sequence_number,
               l_hours,             -- SIR236
               l_group_id,
               i_assignment_id,
               i_element_id,
               i_start_time,        -- SIR374 Actual time in
               i_end_time,          -- SIR374 Actual time out
               l_start_time,
               l_end_time,
               i_earn_reason_code,
               i_cost_center_id,
               i_task_id,
               i_location_id,
               i_project_id,
               i_earn_pol_id,
               i_separate_check_flag,
               i_created_by,
               g_sysdatetime,
               i_last_updated_by,
               g_sysdatetime,
               i_last_update_login,
               i_wage_code,
               i_comment,
               i_rate_multiple,
               i_hourly_rate,
               i_amount,
               TRUNC(g_sess_date),
               hr_general.end_of_time);
            */

            /* Call dml to insert hours */
            hxt_dml.insert_hxt_sum_hours_worked
                      (p_rowid                        => l_rowid,
                       p_id                           => l_hours_worked_id,
                       p_tim_id                       => i_timecard_id,
                       p_date_worked                  => i_date_worked,
                       p_assignment_id                => i_assignment_id,
                       p_hours                        => l_hours,
                       p_time_in                      => l_start_time,
                       p_time_out                     => l_end_time,
                       p_element_type_id              => i_element_id,
                       p_fcl_earn_reason_code         => i_earn_reason_code,
                       p_ffv_cost_center_id           => i_cost_center_id,
                       p_ffv_labor_account_id         => NULL,
                       p_tas_id                       => i_task_id,
                       p_location_id                  => i_location_id,
                       p_sht_id                       => NULL,
                       p_hrw_comment                  => i_comment,
                       p_ffv_rate_code_id             => NULL,
                       p_rate_multiple                => i_rate_multiple,
                       p_hourly_rate                  => i_hourly_rate,
                       p_amount                       => i_amount,
                       p_fcl_tax_rule_code            => NULL,
                       p_separate_check_flag          => i_separate_check_flag,
                       p_seqno                        => l_sequence_number,
                       p_created_by                   => i_created_by,
                       p_creation_date                => g_sysdatetime,
                       p_last_updated_by              => i_last_updated_by,
                       p_last_update_date             => g_sysdatetime,
                       p_last_update_login            => i_last_update_login,
                       p_actual_time_in               => i_start_time,
                       p_actual_time_out              => i_end_time,
                       p_effective_start_date         => TRUNC (g_sess_date),
                       p_effective_end_date           => hr_general.end_of_time,
                       p_project_id                   => i_project_id,
                       p_prev_wage_code               => i_wage_code,
                       p_job_id                       => NULL,
                       p_earn_pol_id                  => i_earn_pol_id,
                       p_time_building_block_id       => p_time_building_block_id,
                       p_time_building_block_ovn      => p_time_building_block_ovn,
                       p_object_version_number        => l_object_version_number,
                       p_state_name                   => i_state_name,
                       p_county_name                  => i_county_name,
                       p_city_name                    => i_city_name,
                       p_zip_code                     => i_zip_code
                      );

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 190);
            END IF;
--
-- Note: If a non-NULL tim_summary_id value is received by the API, check
--       the current batch status.  If the batch is in a hold state the
--       current summary row may be updated. *ALL* input values will be
--  updated. This means that if a named parameter call was used any
--       parameters not received by the API will be NULL'ed out.  If the
--  batch is not in a hold status make a 'retro' entry. That is,
--  expire the old summary record and insert a new one that goes into
--  effect immediately after the expiration of the old record.
--
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 200);
            END IF;

            --SIR290 IF nvl(i_batch_status, 'QQ') in ('VV','VW', 'H', 'VE') THEN
            --
            -- Check whether to allow corrections to summary rows during retro.
            --
            OPEN allow_summary_correction (i_time_summary_id);

            FETCH allow_summary_correction
             INTO l_allow_sum_correction;

            IF g_debug
            THEN
               hr_utility.TRACE (   'l_allow_sum_correction :'
                                 || l_allow_sum_correction
                                );
            END IF;

            CLOSE allow_summary_correction;

            --
            IF     (l_dt_update_mode = 'CORRECTION')
               AND (l_allow_sum_correction = 'Y')
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 210);
               END IF;

               /*  UPDATE hxt_sum_hours_worked_f
                     SET effective_start_date = i_tim_sum_eff_start_date,
                         effective_end_date = i_tim_sum_eff_end_date,
                         date_worked = i_date_worked,
                         assignment_id = i_assignment_id,
                         hours = l_hours,        -- SIR236
                         time_in = l_start_time, -- SIR236
                         time_out = l_end_time,  -- SIR236
                         element_type_id = i_element_id,
                         fcl_earn_reason_code = i_earn_reason_code,
                         ffv_cost_center_id = i_cost_center_id,
                         tas_id = i_task_id,
                         location_id = i_location_id,
                         hrw_comment = i_comment,
                         rate_multiple = i_rate_multiple,
                         hourly_rate = i_hourly_rate,
                         amount = i_amount,
                         separate_check_flag = i_separate_check_flag,
                         last_updated_by = i_last_updated_by,
                         last_update_date = g_sysdatetime,
                         last_update_login = i_last_update_login,
                         prev_wage_code = i_wage_code,
                         project_id = i_project_id,
                         earn_pol_id = i_earn_pol_id
                   WHERE ROWID = (SELECT ROWID
                                    FROM hxt_sum_hours_worked
                                   WHERE id = i_time_summary_id); */

               /* Call DML to do the update */
               -- Bug 7359347
               -- Changed the query below to pick up the base table instead of the
               -- view.
               /*
               SELECT ROWID, tim_id, seqno, created_by,
                      creation_date, actual_time_in, actual_time_out,
                      job_id, object_version_number
                 INTO l_rowid, l_time_id, l_sequence_number, l_created_by,
                      l_creation_date, l_actual_time_in, l_actual_time_out,
                      l_job_id, l_object_version_number
                 FROM hxt_sum_hours_worked
                WHERE ID = i_time_summary_id;

               */

               SELECT ROWID, tim_id, seqno, created_by,
                      creation_date, actual_time_in, actual_time_out,
                      job_id, object_version_number
                 INTO l_rowid, l_time_id, l_sequence_number, l_created_by,
                      l_creation_date, l_actual_time_in, l_actual_time_out,
                      l_job_id, l_object_version_number
                 FROM hxt_sum_hours_worked_f
                WHERE ID = i_time_summary_id
                  AND g_sess_date BETWEEN effective_start_date
                                      AND effective_end_date ;


               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 220);
               END IF;

               hxt_dml.update_hxt_sum_hours_worked
                      (p_rowid                        => l_rowid,
                       p_id                           => i_time_summary_id,
                       p_tim_id                       => l_time_id,
                       p_date_worked                  => i_date_worked,
                       p_assignment_id                => i_assignment_id,
                       p_hours                        => l_hours,
                       p_time_in                      => l_start_time,
                       p_time_out                     => l_end_time,
                       p_element_type_id              => i_element_id,
                       p_fcl_earn_reason_code         => i_earn_reason_code,
                       p_ffv_cost_center_id           => i_cost_center_id,
                       p_ffv_labor_account_id         => NULL,
                       p_tas_id                       => i_task_id,
                       p_location_id                  => i_location_id,
                       p_sht_id                       => NULL,
                       p_hrw_comment                  => i_comment,
                       p_ffv_rate_code_id             => NULL,
                       p_rate_multiple                => i_rate_multiple,
                       p_hourly_rate                  => i_hourly_rate,
                       p_amount                       => i_amount,
                       p_fcl_tax_rule_code            => NULL,
                       p_separate_check_flag          => i_separate_check_flag,
                       p_seqno                        => l_sequence_number,
                       p_created_by                   => l_created_by,
                       p_creation_date                => l_creation_date,
                       p_last_updated_by              => i_last_updated_by,
                       p_last_update_date             => g_sysdatetime,
                       p_last_update_login            => i_last_update_login,
                       p_actual_time_in               => l_actual_time_in,
                       p_actual_time_out              => l_actual_time_out,
                       p_effective_start_date         => i_tim_sum_eff_start_date,
                       p_effective_end_date           => i_tim_sum_eff_end_date,
                       p_project_id                   => i_project_id,
                       p_prev_wage_code               => i_wage_code,
                       p_job_id                       => l_job_id,
                       p_earn_pol_id                  => i_earn_pol_id,
                       p_time_building_block_id       => p_time_building_block_id,
                       p_time_building_block_ovn      => p_time_building_block_ovn,
                       p_object_version_number        => l_object_version_number,
                       p_state_name                   => i_state_name,
                       p_county_name                  => i_county_name,
                       p_city_name                    => i_city_name,
                       p_zip_code                     => i_zip_code
                      );
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 230);
               END IF;

               -- Bug 7359347
               -- Picking up rowid, so querying on the base table instead of the view.
               /*
               SELECT ROWID
                 INTO v_row_id
                 FROM hxt_sum_hours_worked
                WHERE ID = i_time_summary_id;
              */

               SELECT ROWID
                 INTO v_row_id
                 FROM hxt_sum_hours_worked_f
                WHERE ID = i_time_summary_id
                  AND g_sess_date BETWEEN effective_start_date
                                      AND effective_end_date ;


          --
/*
            INSERT INTO hxt_sum_hours_worked_f
                  ( id,
                    tim_id,
                    date_worked,
                    seqno,
                    hours,
                    -- group_id,
                    assignment_id,
                    element_type_id,
                    actual_time_in,  --SIR374
                    actual_time_out, --SIR374
                    time_in,
                    time_out,
                    fcl_earn_reason_code,
                    ffv_cost_center_id,
                    tas_id,
                    location_id,
                    project_id,
                    earn_pol_id,
                    separate_check_flag,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    prev_wage_code,
                    hrw_comment,
                    rate_multiple,
                    hourly_rate,
                    amount,
                    effective_start_date,
                    effective_end_date)
             SELECT tsm.id,
                    tsm.tim_id,
                    i_date_worked,           -- SIR290 tsm.date_worked,
                    tsm.seqno,
                    i_hours,                 -- SIR290 tsm.hours,
                    -- l_group_id,
                    i_assignment_id,         -- SIR290 tsm.assignment_id,
                    i_element_id,            -- SIR290 tsm.element_type_id,
                    i_start_time,            -- SIR374 Actual time in
                    i_end_time,              -- SIR374 Actual time out
                    i_start_time,            -- SIR290 tsm.time_in,
                    i_end_time,              -- SIR290 tsm.time_out,
                    i_earn_reason_code,      -- SIR290 tsm.fcl_earn_reason_code,
                    i_cost_center_id,        -- SIR290 tsm.ffv_cost_center_id,
                    i_task_id,               -- SIR290 tsm.tas_id,
                    i_location_id,           -- SIR290 tsm.location_id,
                    i_project_id,            -- SIR290 tsm.project_id,
                    i_earn_pol_id,           -- SIR290 tsm.earn_pol_id,
                    i_separate_check_flag,   -- SIR290 tsm.separate_check_flag,
                    i_created_by,            -- SIR290 tsm.created_by,
                    g_sysdatetime,           -- SIR290 tsm.creation_date,
                    i_last_updated_by,
                    g_sysdatetime,
                    i_last_update_login,
                    i_wage_code,             -- SIR290 tsm.wage_code,
                    i_comment,               -- SIR290 tsm.hrw_comment,
                    i_rate_multiple,         -- SIR290 tsm.rate_multiple,
                    i_hourly_rate,           -- SIR290 tsm.hourly_rate,
                    i_amount,                -- SIR290 tsm.amount,
                    trunc(g_sess_date),
                    hr_general.end_of_time
               FROM HXT_SUM_HOURS_WORKED_F TSM
              WHERE ROWID = v_row_id;
*/
               SELECT tsm.ID, tsm.tim_id, tsm.seqno
                 INTO l_hours_worked_id, l_time_id, l_sequence_number
                 FROM hxt_sum_hours_worked_f tsm
                WHERE ROWID = v_row_id;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 240);
               END IF;

               hxt_dml.insert_hxt_sum_hours_worked
                      (p_rowid                        => l_rowid,
                       p_id                           => l_hours_worked_id,
                       p_tim_id                       => l_time_id,
                       p_date_worked                  => i_date_worked,
                       p_assignment_id                => i_assignment_id,
                       p_hours                        => l_hours,
                       p_time_in                      => l_start_time,
                       p_time_out                     => l_end_time,
                       p_element_type_id              => i_element_id,
                       p_fcl_earn_reason_code         => i_earn_reason_code,
                       p_ffv_cost_center_id           => i_cost_center_id,
                       p_ffv_labor_account_id         => NULL,
                       p_tas_id                       => i_task_id,
                       p_location_id                  => i_location_id,
                       p_sht_id                       => NULL,
                       p_hrw_comment                  => i_comment,
                       p_ffv_rate_code_id             => NULL,
                       p_rate_multiple                => i_rate_multiple,
                       p_hourly_rate                  => i_hourly_rate,
                       p_amount                       => i_amount,
                       p_fcl_tax_rule_code            => NULL,
                       p_separate_check_flag          => i_separate_check_flag,
                       p_seqno                        => l_sequence_number,
                       p_created_by                   => i_created_by,
                       p_creation_date                => g_sysdatetime,
                       p_last_updated_by              => i_last_updated_by,
                       p_last_update_date             => g_sysdatetime,
                       p_last_update_login            => i_last_update_login,
                       p_actual_time_in               => i_start_time,
                       p_actual_time_out              => i_end_time,
                       p_effective_start_date         => TRUNC (g_sess_date),
                       p_effective_end_date           => hr_general.end_of_time,
                       p_project_id                   => i_project_id,
                       p_prev_wage_code               => i_wage_code,
                       p_job_id                       => NULL,
                       p_earn_pol_id                  => i_earn_pol_id,
                       p_time_building_block_id       => p_time_building_block_id,
                       p_time_building_block_ovn      => p_time_building_block_ovn,
                       p_object_version_number        => l_object_version_number,
                       p_state_name                   => i_state_name,
                       p_county_name                  => i_county_name,
                       p_city_name                    => i_city_name,
                       p_zip_code                     => i_zip_code
                      );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 250);
               END IF;

               --
               UPDATE hxt_sum_hours_worked_f
                  SET effective_end_date = TRUNC (g_sess_date - 1)
                WHERE ROWID = v_row_id;

               --
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 260);
               END IF;
            END IF;                         -- End of Correction/History Check

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 270);
            END IF;
         END IF;                               -- End of Time Summary Id Check

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 280);
         END IF;
      END IF;                                    -- End of Write Summary Check

      /*Generate time details*/
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 290);
      END IF;

      OPEN upd_det_cur (l_hours_worked_id);

      FETCH upd_det_cur
       INTO l_upd_rec;

      CLOSE upd_det_cur;

      --
      IF i_explode_yn = 'Y'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 300);
         END IF;

         --
         IF g_sess_date IS NULL
         THEN
            l_retcode := hxt_tim_col_util.get_session_date (g_sess_date);
         ELSE
            l_retcode := 0;
         END IF;

         l_session_date := g_sess_date;


         IF g_debug
         THEN
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 1
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 310);
            END IF;

            RAISE l_sess_date_err;
         END IF;

         --
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 320);
         END IF;

         hxt_td_util.retro_restrict_edit (p_tim_id             => i_timecard_id,
                                          p_session_date       => l_session_date,
                                          o_dt_update_mod      => l_dt_update_mode,
                                          o_error_message      => l_otm_error,
                                          o_return_code        => o_return_code,
                                          p_parent_id          => l_hours_worked_id
                                         );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 330);
            hr_utility.TRACE ('o_return_code :' || o_return_code);
         END IF;

         IF o_return_code = 1 OR l_otm_error IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 340);
            END IF;

            -- Bug 7380181
            -- Raised the exception here instead of raising it from the
            -- below IF construct.  This checks for time building blocks info
            -- if it is changed, while it does not look at the attributes being changed.
            -- For a timecard which is transferred to BEE today, even an attribute change
            -- should be stopped.

            RAISE l_retro_edit_err;
            /*
            l_timecard_info :=
                          hxc_self_service_time_deposit.get_building_blocks
                                                                           ();
            l_index := l_timecard_info.FIRST;

            LOOP
               EXIT WHEN NOT l_timecard_info.EXISTS (l_index);

               IF (   l_timecard_info (l_index).changed = 'N'
                   OR l_timecard_info (l_index).changed IS NULL
                  )
               THEN
                  l_changed_flag := FALSE;
               ELSE
                  l_changed_flag := TRUE;
                  EXIT;
               END IF;

               l_index := l_timecard_info.NEXT (l_index);
            END LOOP;

            IF p_timecard_source = 'Time Store' AND l_changed_flag = FALSE
            THEN
               NULL;
            ELSE
               RAISE l_retro_edit_err;
            END IF;
            */
         END IF;

         --
         BEGIN
            IF NVL (l_dt_update_mode, 'CORRECTION') = 'CORRECTION'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 350);
               END IF;

               -- Delete
               -- Bug 7359347
               -- Changed the below DELETE to use one instance of the base table
               -- and a session_date
               /*
               DELETE FROM hxt_det_hours_worked_f
                     WHERE ROWID IN (SELECT ROWID
                                       FROM hxt_det_hours_worked
                                      WHERE parent_id = l_hours_worked_id);

               */

               DELETE FROM hxt_det_hours_worked_f
                     WHERE parent_id = l_hours_worked_id
                       AND l_session_date BETWEEN effective_start_date
                                              AND effective_end_date;

               DELETE FROM hxt_errors_f
                     WHERE ROWID IN (
                              SELECT ROWID
                                FROM hxt_errors
                               WHERE hrw_id = l_hours_worked_id
                                 AND hrw_id IS NOT NULL
                                                       --hxt11ipatch don't delete timecard
                           );                                   --level errors
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 360);
               END IF;

               -- Expire
               -- Bug 7359347
               -- Changed the below update to use the base table instead of the view.

               /*
               UPDATE hxt_det_hours_worked_f
                  SET effective_end_date = l_session_date - 1
                WHERE ROWID IN (SELECT ROWID
                                  FROM hxt_det_hours_worked
                                 WHERE parent_id = l_hours_worked_id);

                */
               UPDATE hxt_det_hours_worked_f
                  SET effective_end_date = l_session_date - 1
                WHERE parent_id = l_hours_worked_id
                  AND l_session_date BETWEEN effective_start_date
                                         AND effective_end_date ;

               UPDATE hxt_errors_f
                  SET effective_end_date = l_session_date - 1
                WHERE ROWID IN (
                         SELECT ROWID
                           FROM hxt_errors
                          WHERE hrw_id = l_hours_worked_id
                            AND hrw_id IS NOT NULL
                                                  --hxt11ipatch don't expire timecard
                      );                                       -- level errors
            END IF;                                    -- Update or Correction

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 370);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 380);
               END IF;

               fnd_message.set_name ('HXT', 'HXT_39567_ERR_IN_DD');
               fnd_message.set_token ('ERR_TEXT', SQLERRM);
               o_error_message := fnd_message.get;
               call_hxthxc_gen_error ('HXC',
                                      'HXC_HXT_DEP_VAL_OTMERR',
                                      o_error_message
                                     );                              --2278400
         END;                                                -- delete details

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 390);
            hr_utility.TRACE ('Before Generate_Details ');
            hr_utility.TRACE ('l_osp_id       :' || l_osp_id);
            hr_utility.TRACE ('l_sdf_id       :' || l_sdf_id);
            hr_utility.TRACE ('l_sdp_id       :' || l_sdp_id);
            hr_utility.TRACE ('l_hdp_id       :' || l_hdp_id);
            hr_utility.TRACE ('l_egp_id       :' || l_egp_id);
            hr_utility.TRACE ('l_rotation_plan:' || l_rotation_plan);
         END IF;

         --
         l_retcode :=
            hxt_time_summary.generate_details
                       (l_egp_id,
                        l_egp_type                            -- fcl_earn_type
                                  ,
                        l_egt_id                                     -- egt_id
                                ,
                        l_sdp_id              -- hxt_shift_differential_policy
                                ,
                        l_hdp_id                  -- hxt_hour_deduction_policy
                                ,
                        l_hcl_id               -- hcl_id --Holiday calendar id
                                ,
                        l_pep_id                                     -- pep_id
                                ,
                        l_pip_id                                     -- pip_id
                                ,
                        l_sdf_id                        -- shift_diff_ovrrd_id
                                ,
                        l_osp_id                          -- off_shift_prem_id
                                ,
                        NULL                                 -- standard start
                            ,
                        NULL                                  -- standard stop
                            ,
                        NULL                                    -- early start
                            ,
                        NULL                                      -- late stop
                            ,
                        l_hol_yn,
                        i_person_id,
                        'hxt_time_collection',
                        l_hours_worked_id,
                        i_timecard_id,
                        i_date_worked,
                        i_assignment_id,
                        l_hours,
                        l_start_time,
                        l_end_time,
                        i_element_id,
                        l_upd_rec.fcl_earn_reason_code -- fcl_earn_reason_code
                                                      ,
                        l_upd_rec.ffv_cost_center_id     -- ffv_cost_center_id
                                                    ,
                        NULL                           -- ffv_labor_account_id
                            ,
                        i_task_id                                    -- tas_id
                                 ,
                        i_location_id                           -- location_id
                                     ,
                        NULL                                         -- sht_id
                            ,
                        i_comment                               -- hrw_comment
                                 ,
                        NULL                               -- ffv_rate_code_id
                            ,
                        l_upd_rec.rate_multiple               -- rate_multiple
                                               ,
                        l_upd_rec.hourly_rate                   -- hourly_rate
                                             ,
                        i_amount                                     -- amount
                                ,
                        NULL                              -- fcl_tax_rule_code
                            ,
                        l_upd_rec.separate_check_flag -- separarate_check_flag
                                                     ,
                        l_upd_rec.seqno,
                        i_created_by,
                        l_upd_rec.creation_date,
                        i_last_updated_by,
                        SYSDATE                            -- last_update_date
                               ,
                        i_last_update_login,
                        i_start_date,
                        NULL,
                        TRUNC (g_sess_date),
                        hr_general.end_of_time,
                        i_project_id                           -- p_PROJECT_ID
                                    ,
                        NULL                                       -- p_job_id
                            ,
                        'P'                                    -- p_PAY_STATUS
                           ,
                        'P'                                     -- p_PA_STATUS
                           ,
                        NULL                               -- p_RETRO_BATCH_ID
                            ,
                        NVL (l_dt_update_mode, 'CORRECTION'),
                        p_state_name       => i_state_name,
                        p_county_name      => i_county_name,
                        p_city_name        => i_city_name,
                        p_zip_code         => i_zip_code
                       );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 400);
            hr_utility.TRACE ('l_retcode :' || l_retcode);
         END IF;

         IF l_retcode = 2
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 410);
            END IF;

            RAISE l_generate_details_error;
         END IF;

         IF l_retcode = 11
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 415);
            END IF;

            RAISE l_inc_tim_hr_entry_err;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 420);
         END IF;
      END IF;                                       -- End of Explode YN Check

      --
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 430);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN l_adjust_tim_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 440);
         END IF;

         o_otm_error := l_ad_error;

         IF g_debug
         THEN
            hr_utility.TRACE ('o_otm_error :' || o_otm_error);
         END IF;

         RETURN 2;
      WHEN l_details_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 450);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39414_LOC_ADDL_ASG');
         fnd_message.set_token ('ASG_ID', TO_CHAR (i_assignment_id));
         o_otm_error := fnd_message.get;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', o_otm_error);
         --2278400
         RETURN 1;
      WHEN l_details_system_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 460);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39415_FETCH_ASG_DET');
         fnd_message.set_token ('ASG_ID', TO_CHAR (i_assignment_id));
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', o_otm_error);
         --2278400
         RETURN 2;
      WHEN l_paymix_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 470);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39445_CHG_DATE');
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39445_CHG_DATE', NULL);  --2278400
         RETURN 1;
      WHEN l_hours_worked_id_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 480);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39416_GET_HRW_ID');
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39416_GET_HRW_ID', NULL);
         --2278400
         RETURN 2;
      WHEN l_generate_details_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 490);
         END IF;

         --fnd_message.set_name ('HXT', 'HXT_39417_PROB_GEN_DET');
         o_otm_error := fnd_message.get;
         --call_hxthxc_gen_error('HXT', 'HXT_39417_PROB_GEN_DET',NULL);  --2278400
         RETURN 2;
      WHEN l_inc_tim_hr_entry_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 495);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39329_INC_TIM_HR_ENTRIES');
         o_otm_error := fnd_message.get;
         call_hxthxc_gen_error ('HXT', 'HXT_39329_INC_TIM_HR_ENTRIES', NULL);
         --2278400
         RETURN 2;
      WHEN l_seq_num_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 500);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39418_GET_HRW_SEQ');
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39418_GET_HRW_SEQ', NULL);
         --2278400
         RETURN 2;
      WHEN l_delete_details_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 510);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39563_ERR_IN_RET_DD');
         fnd_message.set_token ('ERR_TEXT', l_otm_error);
         o_otm_error := fnd_message.get;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', o_otm_error);
      --2278400
      WHEN l_sess_date_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 520);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39556_SESSION_DT_NF');
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39556_SESSION_DT_NF', NULL);
      --2278400
      WHEN l_retro_edit_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 530);
         END IF;

         o_otm_error := l_otm_error;
         o_oracle_error := SQLERRM;
-- Replace message + return added
--         call_hxthxc_gen_error('HXC','HXC_HXT_DEP_VAL_OTMERR',o_otm_error);  --2278400
         call_hxthxc_gen_error ('HXT',
                                'HXT_TC_CANNOT_BE_CHANGED_TODAY',
                                o_otm_error
                               );                                    --2278400
         RETURN 2;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 540);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39419_SYSERR_RECFUNC');
         o_otm_error := fnd_message.get;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39419_SYSERR_RECFUNC', NULL);
         --2278400
         RETURN 2;
   END record_hours_worked;

/**********************************************************
  cost_allocation_entry()
  Creates or retrieves cost allocation entries for segments
  and business group entered by calling HR function
  maintain_cost_keyflex. Returns costing_keyflex_i in
  out nocopy parameter o_keyflex_id.
**********************************************************/
   PROCEDURE cost_allocation_entry (
      i_concat_segments      IN              VARCHAR2,
      i_cost_segment1        IN              VARCHAR2,
      i_cost_segment2        IN              VARCHAR2,
      i_cost_segment3        IN              VARCHAR2,
      i_cost_segment4        IN              VARCHAR2,
      i_cost_segment5        IN              VARCHAR2,
      i_cost_segment6        IN              VARCHAR2,
      i_cost_segment7        IN              VARCHAR2,
      i_cost_segment8        IN              VARCHAR2,
      i_cost_segment9        IN              VARCHAR2,
      i_cost_segment10       IN              VARCHAR2,
      i_cost_segment11       IN              VARCHAR2,
      i_cost_segment12       IN              VARCHAR2,
      i_cost_segment13       IN              VARCHAR2,
      i_cost_segment14       IN              VARCHAR2,
      i_cost_segment15       IN              VARCHAR2,
      i_cost_segment16       IN              VARCHAR2,
      i_cost_segment17       IN              VARCHAR2,
      i_cost_segment18       IN              VARCHAR2,
      i_cost_segment19       IN              VARCHAR2,
      i_cost_segment20       IN              VARCHAR2,
      i_cost_segment21       IN              VARCHAR2,
      i_cost_segment22       IN              VARCHAR2,
      i_cost_segment23       IN              VARCHAR2,
      i_cost_segment24       IN              VARCHAR2,
      i_cost_segment25       IN              VARCHAR2,
      i_cost_segment26       IN              VARCHAR2,
      i_cost_segment27       IN              VARCHAR2,
      i_cost_segment28       IN              VARCHAR2,
      i_cost_segment29       IN              VARCHAR2,
      i_cost_segment30       IN              VARCHAR2,
      i_business_group_id    IN              NUMBER,
      o_ffv_cost_center_id   OUT NOCOPY      NUMBER,
      o_otm_error            OUT NOCOPY      VARCHAR2,
      o_oracle_error         OUT NOCOPY      VARCHAR2
   )
--  p_mode IN VARCHAR2 default 'INSERT')
   IS
      l_retcode              NUMBER;
      l_ffv_cost_center_id   NUMBER (15);
      l_otm_error            VARCHAR2 (240);
      l_oracle_error         VARCHAR2 (512);
      cost_alloc_entry_err   EXCEPTION;
   BEGIN
      IF    i_cost_segment1 IS NOT NULL
         OR i_cost_segment2 IS NOT NULL
         OR i_cost_segment3 IS NOT NULL
         OR i_cost_segment4 IS NOT NULL
         OR i_cost_segment5 IS NOT NULL
         OR i_cost_segment6 IS NOT NULL
         OR i_cost_segment7 IS NOT NULL
         OR i_cost_segment8 IS NOT NULL
         OR i_cost_segment9 IS NOT NULL
         OR i_cost_segment10 IS NOT NULL
         OR i_cost_segment11 IS NOT NULL
         OR i_cost_segment12 IS NOT NULL
         OR i_cost_segment13 IS NOT NULL
         OR i_cost_segment14 IS NOT NULL
         OR i_cost_segment15 IS NOT NULL
         OR i_cost_segment16 IS NOT NULL
         OR i_cost_segment17 IS NOT NULL
         OR i_cost_segment18 IS NOT NULL
         OR i_cost_segment19 IS NOT NULL
         OR i_cost_segment20 IS NOT NULL
         OR i_cost_segment21 IS NOT NULL
         OR i_cost_segment22 IS NOT NULL
         OR i_cost_segment23 IS NOT NULL
         OR i_cost_segment24 IS NOT NULL
         OR i_cost_segment25 IS NOT NULL
         OR i_cost_segment26 IS NOT NULL
         OR i_cost_segment27 IS NOT NULL
         OR i_cost_segment28 IS NOT NULL
         OR i_cost_segment29 IS NOT NULL
         OR i_cost_segment30 IS NOT NULL
      THEN
         l_retcode :=
            hxt_util.build_cost_alloc_flex_entry (i_cost_segment1,
                                                  i_cost_segment2,
                                                  i_cost_segment3,
                                                  i_cost_segment4,
                                                  i_cost_segment5,
                                                  i_cost_segment6,
                                                  i_cost_segment7,
                                                  i_cost_segment8,
                                                  i_cost_segment9,
                                                  i_cost_segment10,
                                                  i_cost_segment11,
                                                  i_cost_segment12,
                                                  i_cost_segment13,
                                                  i_cost_segment14,
                                                  i_cost_segment15,
                                                  i_cost_segment16,
                                                  i_cost_segment17,
                                                  i_cost_segment18,
                                                  i_cost_segment19,
                                                  i_cost_segment20,
                                                  i_cost_segment21,
                                                  i_cost_segment22,
                                                  i_cost_segment23,
                                                  i_cost_segment24,
                                                  i_cost_segment25,
                                                  i_cost_segment26,
                                                  i_cost_segment27,
                                                  i_cost_segment28,
                                                  i_cost_segment29,
                                                  i_cost_segment30,
                                                  i_business_group_id,
                                                  l_ffv_cost_center_id,
                                                  l_otm_error
                                                 );

         --      p_mode);
         IF l_retcode = 1
         THEN
            RAISE cost_alloc_entry_err;
         END IF;

         --
         o_ffv_cost_center_id := l_ffv_cost_center_id;
      END IF;
   EXCEPTION
      WHEN cost_alloc_entry_err
      THEN
         o_otm_error := l_otm_error;
         o_oracle_error := SQLERRM;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39566_ERR_IN_CAE');
         l_otm_error := fnd_message.get;
         o_otm_error := l_otm_error;
         o_oracle_error := SQLERRM;
         call_hxthxc_gen_error ('HXT', 'HXT_39566_ERR_IN_CAE', NULL);
   --2278400
   END cost_allocation_entry;

/**************************************************************
 delete_summary_record()
 Deletes hxt_sum_hours_worked_f row indicated by i_tim_sum_id.
***************************************************************/
   FUNCTION delete_summary_record (p_sum_id IN hxt_sum_hours_worked_f.ID%TYPE)
      RETURN NUMBER
   IS
      l_proc                 VARCHAR2 (72);
      c_success     CONSTANT NUMBER         := 0;
      c_failure     CONSTANT NUMBER         := 1;
      l_retro_edit_err       EXCEPTION;
      l_delete_not_allowed   EXCEPTION;
      l_dt_update_mode       VARCHAR2 (20);
      l_return_code          NUMBER;
      l_error_message        VARCHAR2 (300);

      FUNCTION tim_id (p_sum_id IN hxt_sum_hours_worked_f.ID%TYPE)
         RETURN hxt_sum_hours_worked_f.tim_id%TYPE
      AS
         l_proc     VARCHAR2 (72);

         -- Bug 7359347
         -- Added a new date parameter to the existing cursor
         -- so that the view is replaced with the base table.
         CURSOR csr_tim_id (p_sum_id hxt_sum_hours_worked_f.ID%TYPE,
                            p_date   DATE)
         IS
            SELECT tim_id
              FROM hxt_sum_hours_worked_f
             WHERE ID = p_sum_id
               AND g_sess_date BETWEEN effective_start_date
                                   AND effective_end_date;

         l_tim_id   csr_tim_id%ROWTYPE;
      BEGIN
         IF g_debug
         THEN
            l_proc := g_package || 'tim_id';
            hr_utility.set_location ('Entering ' || l_proc, 10);
         END IF;

         -- Bug 7359347
         -- Added the session_date parameter to the cursor.
         OPEN csr_tim_id (p_sum_id, g_sess_date);

         FETCH csr_tim_id
          INTO l_tim_id;

         CLOSE csr_tim_id;

         IF g_debug
         THEN
            hr_utility.set_location (   '   returning l_tim_id = '
                                     || l_tim_id.tim_id,
                                     20
                                    );
            hr_utility.set_location ('Leaving ' || l_proc, 100);
         END IF;

         RETURN l_tim_id.tim_id;
      END tim_id;

      PROCEDURE remove_tc_details (p_sum_id IN hxt_sum_hours_worked_f.ID%TYPE)
      AS
         l_proc   VARCHAR2 (72);
      BEGIN
         IF g_debug
         THEN
            l_proc := g_package || 'remove_tc_details';
            hr_utility.set_location ('Entering ' || l_proc, 10);
         END IF;

         DELETE FROM hxt_det_hours_worked_f
               WHERE parent_id = p_sum_id;

         DELETE FROM hxt_sum_hours_worked_f
               WHERE ID = p_sum_id;

         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 100);
         END IF;
      END remove_tc_details;
   BEGIN                                         -- Main delete_summary_record
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'delete_summary_record';
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

      hxt_td_util.retro_restrict_edit (p_tim_id             => tim_id
                                                                     (p_sum_id),
                                       p_session_date       => g_sess_date,
                                       o_dt_update_mod      => l_dt_update_mode,
                                       o_error_message      => l_error_message,
                                       o_return_code        => l_return_code
                                      );

      IF g_debug
      THEN
         hr_utility.TRACE ('   l_return_code :' || l_return_code);
      END IF;

      IF (l_dt_update_mode IS NULL)
      THEN
         RAISE l_retro_edit_err;
      ELSIF (l_dt_update_mode = 'UPDATE')
      THEN
         RAISE l_delete_not_allowed;
      ELSE
         remove_tc_details (p_sum_id => p_sum_id);
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving ' || l_proc, 100);
      END IF;

      RETURN c_success;
   EXCEPTION
      WHEN l_retro_edit_err
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 110);
         END IF;

         call_hxthxc_gen_error ('HXT',
                                'HXT_TC_CANNOT_BE_CHANGED_TODAY',
                                l_error_message
                               );
         RETURN c_failure;
      WHEN l_delete_not_allowed
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 120);
         END IF;

         call_hxthxc_gen_error ('HXT',
                                'HXT_TC_CANNOT_BE_DELETED',
                                l_error_message
                               );
         RETURN c_failure;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 130);
         END IF;

         RETURN c_failure;
   END delete_summary_record;

--BEGIN SIR334
---------------------------------------------------------------------------
   PROCEDURE delete_details (
      p_tim_id                 IN              NUMBER,
      p_dt_update_mode         IN              VARCHAR2,
      p_effective_start_date   IN              DATE,
      o_error_message          OUT NOCOPY      NUMBER
   )
   IS
   BEGIN
      /* Initialize globals */
      g_sysdate := TRUNC (SYSDATE);
      g_sysdatetime := SYSDATE;
      g_user_id := fnd_global.user_id;
      g_login_id := fnd_global.login_id;

      IF NVL (p_dt_update_mode, 'CORRECTION') = 'CORRECTION'
      THEN
         -- Bug 7359347
         -- Changed the below DELETE to look at the table instead
         -- of the view.
         /*
         DELETE FROM hxt_det_hours_worked_f
               WHERE ROWID IN (SELECT ROWID
                                 FROM hxt_det_hours_worked
                                WHERE tim_id = p_tim_id);
         */

          DELETE FROM hxt_det_hours_worked_f
	        WHERE tim_id = p_tim_id
	          AND p_effective_start_date BETWEEN effective_start_date
	                                         AND effective_end_date ;



         DELETE FROM hxt_errors_f
               WHERE ROWID IN (
                               SELECT ROWID
                                 FROM hxt_errors
                                WHERE tim_id = p_tim_id
                                      AND hrw_id IS NOT NULL
                                                            --hxt11ipatch don't delete timecard
                     );                                       -- level errors
      ELSE
         -- Expire

         -- Bug 7359347
         -- changed the update below to use the base table instead
         -- of the view.
         /*
         UPDATE hxt_det_hours_worked_f
            SET effective_end_date = p_effective_start_date - 1
          WHERE ROWID IN (SELECT ROWID
                            FROM hxt_det_hours_worked
                           WHERE tim_id = p_tim_id);
         */


         UPDATE hxt_det_hours_worked_f
            SET effective_end_date = p_effective_start_date - 1
          WHERE tim_id = p_tim_id
            AND p_effective_start_date BETWEEN effective_start_date
                                           AND effective_end_date ;


         UPDATE hxt_errors_f
            SET effective_end_date = p_effective_start_date - 1
          WHERE ROWID IN (SELECT ROWID
                            FROM hxt_errors
                           WHERE tim_id = p_tim_id AND hrw_id IS NOT NULL
                                                                         --hxt11ipatch don't expire timecard
                );                                             -- level errors
      END IF;                                          -- Update or Correction
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39567_ERR_IN_DD');
         fnd_message.set_token ('ERR_TEXT', SQLERRM);
         o_error_message := fnd_message.get;
         call_hxthxc_gen_error ('HXC',
                                'HXC_HXT_DEP_VAL_OTMERR',
                                o_error_message
                               );                                    --2278400
   END;                                                      -- delete details

---------------------------------------------------------------------------
--END SIR334

   --BEGIN SIR236
/**************************************************************
 Adjust_timings()

***************************************************************/
   PROCEDURE adjust_timings (
      p_timecard_source   IN              VARCHAR2,
      p_assignment_id     IN              NUMBER,
      p_person_id         IN              NUMBER,
      p_date_worked       IN              DATE,
      p_tim_id            IN              NUMBER,
      p_hours_id          IN              NUMBER,
      p_earn_pol_id       IN              NUMBER,
      p_time_in           IN OUT NOCOPY   DATE,
      p_time_out          IN OUT NOCOPY   DATE,
      p_hours             IN OUT NOCOPY   NUMBER,
      p_code              OUT NOCOPY      NUMBER,
      p_error             OUT NOCOPY      VARCHAR2,
      p_org_in            IN              DATE DEFAULT NULL,
      p_org_out           IN              DATE DEFAULT NULL,
      p_actual_time_in    IN OUT NOCOPY   DATE,
      p_actual_time_out   IN OUT NOCOPY   DATE
   )
   IS
      l_tc_intvl          hxt_earning_policies.min_tcard_intvl%TYPE;
      l_round_up          hxt_earning_policies.round_up%TYPE;
      l_rot_id            hxt_rotation_plans.ID%TYPE;
      l_work_id           hxt_rotation_schedules.tws_id%TYPE;
      l_osp_id            NUMBER;
      l_sdf_id            NUMBER;
      l_standard_start    NUMBER;
      l_standard_stop     NUMBER;
      l_early_start       NUMBER;
      l_late_stop         NUMBER;
      l_hours             NUMBER;
      l_error             NUMBER;
      l_ovlp_error        VARCHAR2 (1);
      l_in_time_std       BOOLEAN                                    := FALSE;
      l_out_time_std      BOOLEAN                                    := FALSE;
      l_time_in_date      DATE;
      l_early_date        DATE;
      l_std_date_start    DATE;
      l_time_out_date     DATE;
      l_late_date         DATE;
      l_std_date_stop     DATE;
      l_time_in_actual    DATE;
      l_time_out_actual   DATE;
      l_valid_entry       BOOLEAN;
      l_proc              VARCHAR2 (100);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := 'hxt_time_collection.ADJUST_TIMINGS';
         hr_utility.TRACE ('hxt_time_collection.ADJUST_TIMINGS BEGIN');
         hr_utility.set_location (l_proc, 10);
         hr_utility.TRACE (   'p_time_in:'
                           || TO_CHAR (p_time_in, 'dd-mon-yyyy hh24:mi:ss')
                          );
         hr_utility.TRACE (   'p_time_out:'
                           || TO_CHAR (p_time_out, 'dd-mon-yyyy hh24:mi:ss')
                          );
         hr_utility.TRACE (   'p_actual_time_in:'
                           || TO_CHAR (p_actual_time_in,
                                       'dd-mon-yyyy hh24:mi:ss'
                                      )
                          );
         hr_utility.TRACE (   'p_actual_time_out:'
                           || TO_CHAR (p_actual_time_out,
                                       'dd-mon-yyyy hh24:mi:ss'
                                      )
                          );
         hr_utility.TRACE (   'p_org_in:'
                           || TO_CHAR (p_org_in, 'dd-mon-yyyy hh24:mi:ss')
                          );
         hr_utility.TRACE (   'p_org_out:'
                           || TO_CHAR (p_org_out, 'dd-mon-yyyy hh24:mi:ss')
                          );
      END IF;

      l_time_in_actual := p_actual_time_in;
      l_time_out_actual := p_actual_time_out;

--get rotation plan id for the assignment
      BEGIN
         SELECT hxt_rotation_plan
           INTO l_rot_id
           FROM hxt_per_aei_ddf_v aeiv, per_assignments_f asm
          WHERE asm.assignment_id = p_assignment_id
            AND asm.assignment_id = aeiv.assignment_id
            AND p_date_worked BETWEEN asm.effective_start_date
                                  AND asm.effective_end_date
            AND p_date_worked BETWEEN aeiv.effective_start_date
                                  AND aeiv.effective_end_date;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 20);
            hr_utility.TRACE ('l_rot_id :' || l_rot_id);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 30);
            END IF;

            l_rot_id := NULL;
      END;

      --
      IF l_rot_id IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 40);
         END IF;

         hxt_util.get_shift_info (p_date_worked,
                                  l_work_id,
                                  l_rot_id,
                                  l_osp_id,
                                  l_sdf_id,
                                  l_standard_start,
                                  l_standard_stop,
                                  l_early_start,
                                  l_late_stop,
                                  l_hours,
                                  l_error
                                 );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 50);
            hr_utility.TRACE ('l_error :' || l_error);
         END IF;

         IF (l_error = 0)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 60);
            END IF;

            -- No error, so get the early start,etc timings...
            -- convert time_in, standard_start, and early_start to a date, plus
            -- embed date_worked into all three.
            IF p_time_in IS NOT NULL
            THEN
               IF (l_early_start IS NOT NULL AND l_standard_start IS NOT NULL
                  )
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 70);
                  END IF;

                  l_time_in_date := p_time_in;
                   /* ROUND (
                       TRUNC (p_date_worked, 'DD')
                     + (  p_time_in
                        - TRUNC (p_time_in, 'DD')
                       ),
                     'MI'
                  );*/
                  l_early_date :=
                       TRUNC (p_date_worked)
                     + hxt_util.time_to_hours (l_early_start) / 24;
                    /*  TO_DATE (
                        TO_CHAR (p_date_worked, 'DD-MM-YYYY ')
                     || TO_CHAR (l_early_start, '0009'),
                     'DD-MM-YYYY HH24MI'
                  );*/
                  l_std_date_start :=
                       TRUNC (p_date_worked)
                     + hxt_util.time_to_hours (l_standard_start) / 24;

                  /* TO_DATE (
                          TO_CHAR (
                             p_date_worked,
                             'DD-MM-YYYY '
                          )
                       || TO_CHAR (l_standard_start, '0009'),
                       'DD-MM-YYYY HH24MI'
                    );*/
                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'l_time_in_date  :'
                                       || TO_CHAR (l_time_in_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'l_early_date    :'
                                       || TO_CHAR (l_early_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'l_std_date_start:'
                                       || TO_CHAR (l_std_date_start,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                  END IF;

                  IF l_time_in_date BETWEEN l_early_date AND l_std_date_start
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 80);
                     END IF;

                     p_time_in := l_std_date_start;
                     l_in_time_std := TRUE;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'p_time_in     :'
                                          || TO_CHAR (p_time_in,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                     END IF;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 90);
                  END IF;
               END IF;                -- ( l_early_start is not null  AND....)
            END IF;

            IF p_time_out IS NOT NULL
            THEN
               -- For Time Store
               IF (   (    l_late_stop IS NOT NULL
                       AND l_standard_stop IS NOT NULL
                       AND p_timecard_source = 'Time Store'
                      )
                   -- For PUI
                   OR (p_timecard_source <> 'Time Store')
                  )
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 100);
                  END IF;

                  l_time_out_date := p_time_out;

                   /*   ROUND (
                       TRUNC (p_date_worked, 'DD')
                     + (  p_time_out
                        - TRUNC (p_time_out, 'DD')
                       ),
                     'MI'
                  );*/
                  IF l_late_stop IS NOT NULL
                  THEN
                     l_late_date :=
                          TRUNC (p_date_worked)
                        + hxt_util.time_to_hours (l_late_stop) / 24;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'l_late_date      :'
                                          || TO_CHAR (l_late_date,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                     END IF;
                  END IF;

                     /*   TO_DATE (
                        TO_CHAR (p_date_worked, 'DD-MM-YYYY ')
                     || TO_CHAR (l_late_stop, '0009'),
                     'DD-MM-YYYY HH24MI'
                  );*/
                  l_std_date_stop :=
                       TRUNC (p_date_worked)
                     + hxt_util.time_to_hours (l_standard_stop) / 24;

                    /*   TO_DATE (
                        TO_CHAR (p_date_worked, 'DD-MM-YYYY ')
                     || TO_CHAR (l_standard_stop, '0009'),
                     'DD-MM-YYYY HH24MI'
                  );*/
                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'l_time_out_date  :'
                                       || TO_CHAR (l_time_out_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'l_std_date_stop  :'
                                       || TO_CHAR (l_std_date_stop,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                  END IF;

                  IF p_timecard_source <> 'Time Store' and p_timecard_source <> 'Time Clock'
                  THEN
                     -- i.e., adjust_timings being called from the PUI then
                     -- Check if Time_out goes over midnight
                     IF    (l_time_out_date - TRUNC (l_time_out_date, 'DD')
                           ) < (p_time_in - TRUNC (p_time_in, 'DD'))
                        OR (    (    l_late_date IS NOT NULL
                                 AND l_std_date_stop IS NOT NULL
                                )
                            AND (    l_time_out_date BETWEEN l_std_date_stop
                                                         AND l_late_date
                                 AND (  l_std_date_stop
                                      - TRUNC (l_std_date_stop, 'DD')
                                     ) <
                                        (p_time_in - TRUNC (p_time_in, 'DD')
                                        )
                                )
                           )
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 105);
                        END IF;

                        l_time_out_date := l_time_out_date + 1;
                     END IF;

                     IF l_late_stop IS NOT NULL
                     THEN
                        l_late_date :=
                             TRUNC (l_time_out_date)
                           + hxt_util.time_to_hours (l_late_stop) / 24;

                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                           (   'l_late_date      :'
                                            || TO_CHAR
                                                     (l_late_date,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                           );
                        END IF;
                     END IF;

                     l_std_date_stop :=
                          TRUNC (l_time_out_date)
                        + hxt_util.time_to_hours (l_standard_stop) / 24;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'l_time_out_date  :'
                                          || TO_CHAR (l_time_out_date,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                        hr_utility.TRACE (   'l_std_date_stop  :'
                                          || TO_CHAR (l_std_date_stop,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                     END IF;

                     IF l_time_out_date BETWEEN l_std_date_stop AND l_late_date
                     THEN
                        hr_utility.set_location (l_proc, 110);
                        p_time_out := l_std_date_stop;
                        l_out_time_std := TRUE;

                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                           (   'p_time_out     :'
                                            || TO_CHAR
                                                     (p_time_out,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                           );
                        END IF;
                     ELSE
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 115);
                        END IF;

                        p_time_out := l_time_out_date;

                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                           (   'p_time_out     :'
                                            || TO_CHAR
                                                     (p_time_out,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                           );
                        END IF;
                     END IF;
                  ELSE                     -- P_timecard_source = 'Time Store'
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 116);
                     END IF;

                     l_late_date :=
                          TRUNC (l_time_out_date)
                        + hxt_util.time_to_hours (l_late_stop) / 24;
                     l_std_date_stop :=
                          TRUNC (l_time_out_date)
                        + hxt_util.time_to_hours (l_standard_stop) / 24;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'l_time_out_date  :'
                                          || TO_CHAR (l_time_out_date,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                        hr_utility.TRACE (   'l_late_date      :'
                                          || TO_CHAR (l_late_date,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                        hr_utility.TRACE (   'l_std_date_stop  :'
                                          || TO_CHAR (l_std_date_stop,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                         );
                     END IF;

                     IF l_time_out_date BETWEEN l_std_date_stop AND l_late_date
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 120);
                        END IF;

                        p_time_out := l_std_date_stop;
                        l_out_time_std := TRUE;

                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                           (   'p_time_out     :'
                                            || TO_CHAR
                                                     (p_time_out,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                           );
                           hr_utility.TRACE (   'p_org_out     :'
                                             || TO_CHAR
                                                     (p_org_out,
                                                      'DD-MON-YYYY HH24:MI:SS'
                                                     )
                                            );
                        END IF;
                     END IF;
                  END IF;                 -- P_timecard_source <> 'Time Store'

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 125);
                  END IF;
               END IF;                  -- ( l_late_stop is not null  AND....)
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 130);
            END IF;
         END IF;                                              -- (l_error = 0)

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 140);
         END IF;
      -- END IF; -- (rot id is not NULL)
      ELSE                                                 -- l_rot_id IS NULL
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 141);
         END IF;

         IF p_time_out IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 142);
            END IF;

            l_time_out_date := p_time_out;

            IF p_timecard_source <> 'Time Store' and p_timecard_source <> 'Time Clock'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 143);
               END IF;

               -- i.e., adjust_timings being called from the PUI then
               -- Check if Time_out goes over midnight
               IF (l_time_out_date - TRUNC (l_time_out_date, 'DD')) <
                                        (p_time_in - TRUNC (p_time_in, 'DD')
                                        )
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 144);
                  END IF;

                  l_time_out_date := l_time_out_date + 1;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 145);
               END IF;
            END IF;                       -- P_timecard_source <> 'Time Store'

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 146);
            END IF;

            p_time_out := l_time_out_date;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 147);
         END IF;
      END IF;                                              -- (rot id is NULL)

--Round the timings according to the earn policy, if not std....
      IF (l_in_time_std <> TRUE OR l_out_time_std <> TRUE)
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 150);
         END IF;

         SELECT min_tcard_intvl, round_up
           INTO l_tc_intvl, l_round_up
           FROM hxt_earning_policies
          WHERE ID = p_earn_pol_id;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_tc_intvl :' || l_tc_intvl);
            hr_utility.TRACE ('l_round_up :' || l_round_up);
         END IF;

         IF (l_in_time_std <> TRUE)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 160);
            END IF;

            p_time_in := round_time (p_time_in, l_tc_intvl, l_round_up);
         END IF;

         IF (l_out_time_std <> TRUE)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 165);
            END IF;

            p_time_out := round_time (p_time_out, l_tc_intvl, l_round_up);
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 170);
         END IF;
      END IF;

      IF p_timecard_source <> 'Time Store'
      THEN
         IF p_org_in IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 175);
            END IF;

            p_actual_time_in := p_org_in;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_actual_time_in     :'
                                 || TO_CHAR (p_actual_time_in,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE (   'p_org_out     :'
                              || TO_CHAR (p_org_out, 'DD-MON-YYYY HH24:MI:SS')
                             );
         END IF;

         IF p_org_out IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 180);
            END IF;

            p_actual_time_out := p_org_out;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_actual_time_out     :'
                                 || TO_CHAR (p_actual_time_out,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;
         END IF;
      END IF;

      -- Check that time does not fall within another time entry
      --Bug 2770487 Sonarasi 04-Apr-2003
      --The parameters of check_time_overlap have been changed. Previously this
      --function used to be called two times once for IN time and once for OUT time.
      --Now both IN time and OUT time are being passed and a common error is being
      --raised instead of two errors.
      --Bug 2770487 Sonarasi Over
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 190);
      END IF;

      IF p_timecard_source <> 'Time Store'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 191);
         END IF;

         l_ovlp_error :=
            check_time_overlap (p_date_worked,
                                p_time_in,
                                p_time_out,
                                p_hours_id,
                                p_tim_id
                               );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 200);
            hr_utility.TRACE ('l_ovlp_error :' || l_ovlp_error);
         END IF;

         -- Raise exception if found
         IF l_ovlp_error = 'E'
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 210);
            END IF;

            fnd_message.set_name ('HXT', 'HXT_39598_IN_OUT_TIME_OVERLAP');
            fnd_message.set_token ('TIME_IN', TO_CHAR (p_time_in, 'HH24MI'));
            fnd_message.set_token ('TIME_OUT', TO_CHAR (p_time_out, 'HH24MI'));
            fnd_message.set_token ('DT_WRK',
                                   TO_CHAR (p_date_worked, 'DD-MON-YYYY')
                                  );
            fnd_message.set_token ('TIM_ID', TO_CHAR (p_tim_id));
            fnd_message.set_token ('SUM_ID', TO_CHAR (p_hours_id));
            p_error := fnd_message.get;
            call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', p_error);
            --2278400
            p_code := 1;
            RETURN;
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE (   'p_time_in:'
                           || TO_CHAR (p_time_in, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'p_time_out:'
                           || TO_CHAR (p_time_out, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'p_actual_time_in:'
                           || TO_CHAR (p_actual_time_in,
                                       'DD-MON-YYYY HH24:MI:SS'
                                      )
                          );
         hr_utility.TRACE (   'p_actual_time_out:'
                           || TO_CHAR (p_actual_time_out,
                                       'DD-MON-YYYY HH24:MI:SS'
                                      )
                          );
         hr_utility.TRACE (   'l_time_in_actual:'
                           || TO_CHAR (l_time_in_actual,
                                       'DD-MON-YYYY HH24:MI:SS'
                                      )
                          );
         hr_utility.TRACE (   'l_time_out_actual:'
                           || TO_CHAR (l_time_out_actual,
                                       'DD-MON-YYYY HH24:MI:SS'
                                      )
                          );
      END IF;

      IF p_timecard_source = 'Time Store'
      THEN
         l_valid_entry :=
            hxt_util.is_valid_time_entry
                                     (l_time_in_actual,   -- p_actual_time_in,
                                      p_time_in,
                                      l_time_out_actual, -- p_actual_time_out,
                                      p_time_out
                                     );
      END IF;

      IF l_valid_entry = FALSE
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 220);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39600_INVALID_ENTRIES');
         p_error := fnd_message.get;
         call_hxthxc_gen_error ('HXC', 'HXC_HXT_DEP_VAL_OTMERR', p_error);
         --2278400
         p_code := 1;
         RETURN;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 250);
      END IF;

      p_code := 0;

      IF g_debug
      THEN
         hr_utility.TRACE ('hxt_time_collection.ADJUST_TIMINGS END');
      END IF;
   END adjust_timings;

/**************************************************************
 round_time() --

***************************************************************/
   FUNCTION round_time (p_time DATE, p_interval NUMBER, p_round_up NUMBER)
      RETURN DATE
   IS
      l_min   NUMBER;
      l_mod   NUMBER;
   -- Modification Log
   -- 02/13/96  PJA  Round number of minutes past midnite.
   --
   BEGIN
      -- Get number of minutes past midnite
      l_min := ROUND ((p_time - TRUNC (p_time, 'DAY')) * (24 * 60));
      -- Get number of minutes past interval
      l_mod := MOD (l_min, p_interval);

      -- Apply interval rules to number of minutes (if remainder is less than round value,
      -- deduct the remainder - otherwise, deduct the remainder then add the interval)
      IF (l_mod - p_round_up) < 0
      THEN
         l_min := l_min - l_mod;
      ELSE
         l_min := l_min - l_mod + p_interval;
      END IF;

      -- Return new time (add minutes converted to date to date at midnite)
      RETURN TRUNC (p_time, 'DAY') + (l_min / 60 / 24);
   END round_time;

------------------------------------------------------------
   FUNCTION check_time_overlap (
      p_date       DATE,
      p_time_in    DATE,
      p_time_out   DATE,
      p_id         NUMBER,
      p_tim_id     NUMBER
   )
      RETURN VARCHAR2
   IS
      -- Description:
      -- Returns 'E'rror if time passed falls within in and out
      -- times on other summary lines.

      -- Parameters:
      -- p_date - date worked
      -- p_time_in - in time being evaluated
      -- p_time_out - out time being evaluated
      -- p_id   - hour worked ID
      -- p_tim_id - timecard ID

      --Bug 2770487 Sonarasi 04-Apr-2003
--The parameters for the function check_time_overlap have been changed.
--The p_type and p_time parameters have been removed. Instead p_time_in and p_time_out
--are passed to the function. This is because both in time and out time are necessary
--to detect overlap.
--Bug 2770487 Sonarasi Over

      -- Modification Log:
      -- 12/28/95   PJA   Created

      -- Check that time does not fall within any other time block on
-- this timesheet.

      -- Define cursor - OK for out-time to be same as another in-time
      -- Bug 7359347
      -- changed the below cursor to use an input value which holds
      -- session date.
      /*
      CURSOR c
      IS
         SELECT 'E'
           FROM hxt_sum_hours_worked                                   --C421
          WHERE (p_time_in < time_out AND p_time_out > time_in)
--C421      AND  parent_id = 0
            AND date_worked = p_date
            AND ID <> NVL (p_id, 0)
            AND tim_id = p_tim_id;
      */
      CURSOR c(session_date  DATE)
      IS
         SELECT 'E'
           FROM hxt_sum_hours_worked_f                                   --C421
          WHERE (p_time_in < time_out AND p_time_out > time_in)
--C421      AND  parent_id = 0
            AND date_worked = p_date
            AND session_date BETWEEN effective_start_date
                                 AND effective_end_date
            AND ID <> NVL (p_id, 0)
            AND tim_id = p_tim_id;


      l_error   VARCHAR2 (1)   := NULL;
      l_proc    VARCHAR2 (100);
      l_retcode  NUMBER;
   BEGIN
      IF g_debug
      THEN
         l_proc := 'hxt_time_collection.Check_Time_Overlap';
         hr_utility.set_location (l_proc, 10);
      END IF;

      --Check if overlap found
      --begin SPR C245  - have to check for null or this process will hang,
      --causing need to bounce database.
      IF p_time_in IS NOT NULL AND p_time_out IS NOT NULL
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 20);
         END IF;

         --end SPR C245

         -- Bug 7359347
         -- Get the session date before opening the cursor
         -- and pass that to the cursor.
         IF g_sess_date IS NULL
         THEN
            l_retcode := hxt_tim_col_util.get_session_date(g_sess_date);
         END IF;

         OPEN c(g_sess_date);


         FETCH c
          INTO l_error;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_error :' || l_error);
         END IF;

         CLOSE c;

         RETURN l_error;
      --begin SPR C245
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 30);
         END IF;

         RETURN ('');
      END IF;

      --end SPR C245
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 40);
      END IF;
   END check_time_overlap;

--------------------------------------------------------------------------------
   FUNCTION reset_hours (p_in IN DATE, p_out IN DATE)
      RETURN NUMBER
   IS
      -- Reset input hours if they don't match times
      l_diff   NUMBER;
   BEGIN
      -- Get number of hours between times
      l_diff := (p_out - p_in) * 24;

      -- begin SPR C260
      -- Check if time out after midnite
      IF l_diff < 0
      THEN
         l_diff := l_diff + 24;
      END IF;

      RETURN (l_diff);
   END reset_hours;
--END SIR236
END hxt_time_collection;

/
