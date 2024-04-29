--------------------------------------------------------
--  DDL for Package Body HXT_TIME_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIME_DETAIL" AS
/* $Header: hxttdet.pkb 120.34.12010000.11 2009/12/28 09:52:00 asrajago ship $ */
--
--  Global variables for package
--  Used for parameters received that are not changed
   g_debug                  BOOLEAN               := hr_utility.debug_enabled;
   g_ep_id                  NUMBER;
   g_ep_type                hxt_earning_policies.fcl_earn_type%TYPE;
   g_egt_id                 NUMBER;
   g_sdf_id                 NUMBER;
   g_hdp_id                 NUMBER;
   g_hol_id                 NUMBER;
   g_sdp_id                 NUMBER;                     -- ORACLE bug #715964
   g_pep_id                 NUMBER;
   g_pip_id                 NUMBER;
   g_sdovr_id               NUMBER;
   g_osp_id                 NUMBER;
   g_hol_yn                 VARCHAR2 (1);
   g_person_id              NUMBER;
   g_id                     NUMBER;
   g_tim_id                 NUMBER;
   g_date_worked            DATE;
   g_assignment_id          NUMBER;
   g_hours                  NUMBER;
   g_time_in                DATE;
   g_time_out               DATE;
   g_element_type_id        NUMBER;
   g_fcl_earn_reason_code   hxt_det_hours_worked.fcl_earn_reason_code%TYPE;
   --C421
   g_ffv_cost_center_id     NUMBER;
   g_ffv_labor_account_id   NUMBER;
   g_tas_id                 NUMBER;
   g_location_id            NUMBER;
   g_sht_id                 NUMBER;
   g_hrw_comment            hxt_det_hours_worked.hrw_comment%TYPE;     --C421
   g_ffv_rate_code_id       NUMBER;
   g_rate_multiple          NUMBER;
   g_hourly_rate            NUMBER;
   g_amount                 NUMBER;
   g_fcl_tax_rule_code      hxt_det_hours_worked.fcl_tax_rule_code%TYPE;
   --C421
   g_separate_check_flag    hxt_det_hours_worked.separate_check_flag%TYPE;
   --C421
   g_seqno                  NUMBER;
   g_created_by             NUMBER;
   g_creation_date          DATE;
   g_last_updated_by        NUMBER;
   g_last_update_date       DATE;
   g_last_update_login      NUMBER;
   g_start_day_of_week      CHAR (30);    -- Increased to fit the whole name.
   g_effective_start_date   DATE;
   g_effective_end_date     DATE;
   g_project_id             NUMBER;                               -- PROJACCT
   g_job_id                 NUMBER;                                   -- TA35
   g_pay_status             CHAR (1);                             -- RETROPAY
   g_pa_status              CHAR (1);                             -- PROJACCT
   g_period_start_date      DATE;
   g_retro_batch_id         NUMBER;                               -- RETROPAY
   b_first_time             BOOLEAN;                               -- ZEROHRS
   g_location               VARCHAR2 (100);
--g_group_id                    NUMBER;   -- HXT11i1
   l_time_in                DATE;                                   -- SIR132
   l_time_out               DATE;                                   -- SIR132
   g_call_adjust_abs        VARCHAR2 (1);
   g_state_name             hxt_det_hours_worked_f.state_name%TYPE;
   g_county_name            hxt_det_hours_worked_f.county_name%TYPE;
   g_city_name              hxt_det_hours_worked_f.city_name%TYPE;
   g_zip_code               hxt_det_hours_worked_f.zip_code%TYPE;

   g_adjust_for_holiday     BOOLEAN;

   TYPE element_tab IS TABLE OF VARCHAR2(5) INDEX BY BINARY_INTEGER;
   g_reg_element            element_tab;

   -- Bug 8279779
   -- Added these datatypes for adj_stretch_sdp
   TYPE VARCHARTABLE IS TABLE OF VARCHAR2(15) INDEX BY VARCHAR2(20);
   sdp_adjusted  VARCHARTABLE;

   CURSOR check_abs_elem
   IS
      -- SELECT 'exist'
      -- FROM   sys.dual
      -- WHERE  EXISTS (
      SELECT 'x'
        FROM hxt_earn_groups erg, hxt_earning_policies egp
       WHERE egp.ID = g_ep_id
         AND erg.egt_id = egp.egt_id
         AND erg.element_type_id = g_element_type_id;

   l_abs_in_eg              VARCHAR2 (5)                               := NULL;

   CURSOR check_spc_dy_eg
   IS
      SELECT 'x'
        FROM hxt_earn_group_types egt
       WHERE egt.NAME = 'OTLR 7th Day Hours';

   g_spc_dy_eg              VARCHAR2 (1)                               := NULL;

--begin hxt11i1
   --
   -- The first part of the related_prem cursor looks for premium rows that are
   -- not REG or OVT, but have a higher seqno than the one passed in. The second
   -- part of the cursor (sub select) looks for REG and OVT rows with higher
   -- sequence numbers than the one passed in.  This is an effort to sandwich
   -- premiums between their related REG and OVT elements. Without this there is
   -- no guarantee thata premium selected would be associated with any given REG
   -- or OVT row in the hxt_det_hours_worked_f table.

   -- Bug 7359347
   -- Changed the below cursor to use the base tables instead of views
   -- referencing fnd_sessions.  Uses a global variable instead.
   /*
   CURSOR related_prem (
      a_parent_id   NUMBER,
      a_tim_id      NUMBER,
      a_seqno       NUMBER,
      a_hours       NUMBER
   )
   IS
      SELECT hrw.ROWID prem_row_id, hrw.seqno, hrw.time_in prem_time_in,
             hrw.time_out prem_time_out, hrw.hours prem_hours,
             elt.element_name
        FROM hxt_pay_element_types_f_ddf_v eltv,
             pay_element_types_f elt,
             hxt_det_hours_worked hrw
       WHERE hrw.tim_id = a_tim_id
         AND hrw.parent_id = a_parent_id
         AND hrw.seqno > a_seqno
         -- The sub select below tries to keep this cursor bound to premiums
         -- that fall between the REG and OVT pay elements that may already
         -- exist on the detail table so that we don't get the wrong premium
         -- when adjusting the hours on premiums rows
         AND (    -- Be sure we stay with premiums for the detail record being
                  -- dealt with
                 (hrw.seqno <
                     (SELECT MIN (det.seqno)
                        FROM hxt_pay_element_types_f_ddf_v eltv2,
                             pay_element_types_f elt2,
                             hxt_det_hours_worked det
                       WHERE det.tim_id = a_tim_id
                         AND det.parent_id = a_parent_id
                         AND det.seqno > a_seqno
                         AND det.element_type_id = elt2.element_type_id
                         AND eltv2.hxt_earning_category IN ('REG', 'OVT')
                         AND det.date_worked BETWEEN elt2.effective_start_date
                                                 AND elt2.effective_end_date
                         AND eltv2.element_type_id = elt2.element_type_id
                         AND det.date_worked BETWEEN eltv2.effective_start_date
                                                 AND eltv2.effective_end_date)
                 )
              OR         -- Proceed if no REG and OVT elements exist for other

                 -- detail records
                 (NOT EXISTS (
                     SELECT det.seqno
                       FROM hxt_pay_element_types_f_ddf_v eltv2,
                            pay_element_types_f elt2,
                            hxt_det_hours_worked det
                      WHERE det.tim_id = a_tim_id
                        AND det.parent_id = a_parent_id
                        AND det.seqno > a_seqno
                        AND det.element_type_id = elt2.element_type_id
                        AND eltv2.hxt_earning_category IN ('REG', 'OVT')
                        AND det.date_worked BETWEEN elt2.effective_start_date
                                                AND elt2.effective_end_date
                        AND eltv2.element_type_id = elt2.element_type_id
                        AND det.date_worked BETWEEN eltv2.effective_start_date
                                                AND eltv2.effective_end_date)
                 )
             )
         AND elt.element_type_id = hrw.element_type_id
         AND eltv.hxt_earning_category NOT IN ('REG', 'OVT')
         AND hrw.date_worked BETWEEN elt.effective_start_date
                                 AND elt.effective_end_date
         AND NVL (hrw.hours, 0) <> 0
         AND eltv.element_type_id = elt.element_type_id
         AND hrw.date_worked BETWEEN eltv.effective_start_date
                                 AND eltv.effective_end_date;

       */
   CURSOR related_prem (
      a_parent_id   NUMBER,
      a_tim_id      NUMBER,
      a_seqno       NUMBER,
      a_hours       NUMBER,
      a_session_date DATE
   )
   IS
      SELECT hrw.ROWID prem_row_id, hrw.seqno, hrw.time_in prem_time_in,
             hrw.time_out prem_time_out, hrw.hours prem_hours,
             elt.element_name
        FROM hxt_pay_element_types_f_ddf_v eltv,
             pay_element_types_f elt,
             hxt_det_hours_worked_f hrw
       WHERE hrw.tim_id = a_tim_id
         AND hrw.parent_id = a_parent_id
         AND hrw.seqno > a_seqno
         AND a_session_date BETWEEN hrw.effective_start_date
                                AND hrw.effective_end_date
         AND (    -- Be sure we stay with premiums for the detail record being
                  -- dealt with
                 (hrw.seqno <
                     (SELECT MIN (det.seqno)
                        FROM hxt_pay_element_types_f_ddf_v eltv2,
                             pay_element_types_f elt2,
                             hxt_det_hours_worked_f det
                       WHERE det.tim_id = a_tim_id
                         AND det.parent_id = a_parent_id
                         AND det.seqno > a_seqno
                         AND a_session_date BETWEEN det.effective_start_date
                                                AND det.effective_end_date
                         AND det.element_type_id = elt2.element_type_id
                         AND eltv2.hxt_earning_category IN ('REG', 'OVT')
                         AND det.date_worked BETWEEN elt2.effective_start_date
                                                 AND elt2.effective_end_date
                         AND eltv2.element_type_id = elt2.element_type_id
                         AND det.date_worked BETWEEN eltv2.effective_start_date
                                                 AND eltv2.effective_end_date)
                 )
              OR         -- Proceed if no REG and OVT elements exist for other
                 (NOT EXISTS (
                     SELECT det.seqno
                       FROM hxt_pay_element_types_f_ddf_v eltv2,
                            pay_element_types_f elt2,
                            hxt_det_hours_worked_f det
                      WHERE det.tim_id = a_tim_id
                        AND det.parent_id = a_parent_id
                        AND det.seqno > a_seqno
                        AND a_session_date  BETWEEN det.effective_start_date
                                                AND det.effective_end_date
                        AND det.element_type_id = elt2.element_type_id
                        AND eltv2.hxt_earning_category IN ('REG', 'OVT')
                        AND det.date_worked BETWEEN elt2.effective_start_date
                                                AND elt2.effective_end_date
                        AND eltv2.element_type_id = elt2.element_type_id
                        AND det.date_worked BETWEEN eltv2.effective_start_date
                                                AND eltv2.effective_end_date)
                 )
             )
         AND elt.element_type_id = hrw.element_type_id
         AND eltv.hxt_earning_category NOT IN ('REG', 'OVT')
         AND hrw.date_worked BETWEEN elt.effective_start_date
                                 AND elt.effective_end_date
         AND NVL (hrw.hours, 0) <> 0
         AND eltv.element_type_id = elt.element_type_id
         AND hrw.date_worked BETWEEN eltv.effective_start_date
                                 AND eltv.effective_end_date;



--  Function and Procedure declarations
   FUNCTION contig_hours_worked (
      p_date_worked   IN   hxt_det_hours_worked_f.date_worked%TYPE,
      p_egt_id        IN   hxt_earn_groups.egt_id%TYPE,
      p_tim_id        IN   hxt_det_hours_worked_f.tim_id%TYPE
   )
      RETURN hxt_det_hours_worked.hours%TYPE;

   -- Bug 7143238
   -- Added for effective calculation of hours worked
   -- when there is an SDP.

   FUNCTION contig_hours_worked2 (
      p_date_worked   IN   hxt_det_hours_worked_f.date_worked%TYPE,
      p_egt_id        IN   hxt_earn_groups.egt_id%TYPE,
      p_tim_id        IN   hxt_det_hours_worked_f.tim_id%TYPE
   )
      RETURN hxt_det_hours_worked.hours%TYPE;


   PROCEDURE overtime_hoursoverride (
      p_date_worked        IN              hxt_det_hours_worked_f.date_worked%TYPE,
      p_egt_id             IN              hxt_earn_groups.egt_id%TYPE,
      p_tim_id             IN              hxt_det_hours_worked_f.tim_id%TYPE,
      p_override_hrs       OUT NOCOPY      hxt_det_hours_worked_f.hours%TYPE,
      p_override_element   OUT NOCOPY      hxt_det_hours_worked_f.element_type_id%TYPE
   );

   FUNCTION delete_zero_hour_details (
      a_tim_id        NUMBER,
      a_ep_id         NUMBER,
      a_osp_id        NUMBER,
      a_date_worked   DATE
   )
      RETURN NUMBER;

   FUNCTION combine_contig_chunks
      RETURN NUMBER;

   FUNCTION holiday_rule_found (
      p_ep_id IN hxt_earning_policies.ID%TYPE,
      p_date_worked IN hxt_det_hours_worked_f.date_worked%TYPE
   )
      RETURN BOOLEAN
   IS
      l_holiday_rule_found      BOOLEAN;
      l_count_holiday_rules     PLS_INTEGER;
      c_holiday_rule   CONSTANT hxt_earning_rules.egr_type%TYPE   := 'HOL';
      c_no_rule        CONSTANT NUMBER                            := 0;
   BEGIN
      SELECT COUNT (1)
        INTO l_count_holiday_rules
        FROM hxt_earning_rules
       WHERE egp_id = p_ep_id AND egr_type = c_holiday_rule
       AND p_date_worked between effective_start_date and effective_end_date;

      IF (l_count_holiday_rules > c_no_rule)
       -- Bug 8600894
       AND  NVL(FND_PROFILE.VALUE('HXT_HOLIDAY_EXPLOSION'),'EX') = 'EX'
      THEN
         l_holiday_rule_found := TRUE;
      ELSE
         l_holiday_rule_found := FALSE;
      END IF;
      RETURN l_holiday_rule_found;
   END holiday_rule_found;

   FUNCTION call_gen_error (
      p_location            IN   VARCHAR2,
      p_error_text          IN   VARCHAR2,
      p_oracle_error_text   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
   --  calls error processing procedure  --
   BEGIN
      hxt_util.gen_error (g_tim_id,
                          g_id,
                          NULL,
                          p_error_text,
                          p_location,
                          p_oracle_error_text,
                          g_effective_start_date,
                          g_effective_end_date,
                          'ERR'
                         );
      hxt_util.DEBUG ('Return code is 2 from call gen error');
      RETURN 2;
   END;

   FUNCTION call_hxthxc_gen_error (
      p_app_short_name      IN   VARCHAR2,
      p_msg_name            IN   VARCHAR2,
      p_msg_token           IN   VARCHAR2,
      p_location            IN   VARCHAR2,
      p_error_text          IN   VARCHAR2,
      p_oracle_error_text   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
   --  calls error processing procedure  --
   BEGIN
      hxt_util.gen_error (g_tim_id,
                          g_id,
                          NULL,
                          p_error_text,
                          p_location,
                          p_oracle_error_text,
                          g_effective_start_date,
                          g_effective_end_date,
                          'ERR'
                         );
      hxc_time_entry_rules_utils_pkg.add_error_to_table
                 (p_message_table               => hxt_hxc_retrieval_process.g_otm_messages,
                  p_message_name                => p_msg_name,
                  p_message_token               => NULL,
                  p_message_level               => 'ERROR',
                  p_message_field               => NULL,
                  p_application_short_name      => p_app_short_name,
                  p_timecard_bb_id              => NULL,
                  p_time_attribute_id           => NULL,
                  p_timecard_bb_ovn             => NULL,
                  p_time_attribute_ovn          => NULL
                 );

      IF g_debug
      THEN
         hr_utility.TRACE ('Adding to g_otm_messages' || p_msg_name);
      END IF;

      hxt_util.DEBUG ('Return code is 2 from call gen error');
      RETURN 2;
   END;

   FUNCTION pay (
      a_hours_to_pay           IN   NUMBER,
      a_pay_element_type_id    IN   NUMBER,
      a_time_in                IN   DATE,
      a_time_out               IN   DATE,
      a_date_worked            IN   DATE,
      a_id                     IN   NUMBER,                       -- parent id
      a_assignment_id          IN   NUMBER,
      a_fcl_earn_reason_code   IN   VARCHAR2,
      a_ffv_cost_center_id     IN   NUMBER,
      a_ffv_labor_account_id   IN   NUMBER,
      a_tas_id                 IN   NUMBER,
      a_location_id            IN   NUMBER,
      a_sht_id                 IN   NUMBER,
      a_hrw_comment            IN   VARCHAR2,
      a_ffv_rate_code_id       IN   NUMBER,
      a_rate_multiple          IN   NUMBER,
      a_hourly_rate            IN   NUMBER,
      a_amount                 IN   NUMBER,
      a_fcl_tax_rule_code      IN   VARCHAR2,
      a_separate_check_flag    IN   VARCHAR2,
      a_project_id             IN   NUMBER,
      -- a_GROUP_ID IN NUMBER,
      a_earn_policy_id         IN   NUMBER,
      a_sdf_id                 IN   NUMBER DEFAULT NULL,
      a_state_name             IN   VARCHAR2 DEFAULT NULL,
      a_county_name            IN   VARCHAR2 DEFAULT NULL,
      a_city_name              IN   VARCHAR2 DEFAULT NULL,
      a_zip_code               IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION gen_special (
      p_location                IN   VARCHAR2,
      p_time_in                 IN   DATE,
      p_time_out                IN   DATE,
      p_hours_worked            IN   NUMBER,
      p_shift_diff_earning_id   IN   NUMBER,
      p_sdovr_earning_id        IN   NUMBER
   )
      RETURN NUMBER;

------------  generate special    loads globals and calls gen_special-----------
------------  return 0 normal   1 warning      2 error               -----------
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
      p_project_id             IN   NUMBER,                        -- PROJACCT
      p_job_id                 IN   NUMBER,                            -- TA35
      p_pay_status             IN   VARCHAR2,                      -- RETROPAY
      p_pa_status              IN   VARCHAR2,                      -- PROJACCT
      p_retro_batch_id         IN   NUMBER,                        -- RETROPAY
      p_period_start_date      IN   DATE,
      p_call_adjust_abs        IN   VARCHAR2,
      p_state_name             IN   VARCHAR2 DEFAULT NULL,
      p_county_name            IN   VARCHAR2 DEFAULT NULL,
      p_city_name              IN   VARCHAR2 DEFAULT NULL,
      p_zip_code               IN   VARCHAR2 DEFAULT NULL
   )
-- p_GROUP_ID                   IN NUMBER)   -- HXT11i1
   RETURN NUMBER
   IS
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         hr_utility.set_location ('hxt_time_detail.GENERATE_SPECIAL', 10);
         hr_utility.TRACE (   'p_time_in  :'
                           || TO_CHAR (p_time_in, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'p_time_out :'
                           || TO_CHAR (p_time_out, 'DD-MON-YYYY HH24:MI:SS')
                          );
      END IF;

-- Set global variables for package with parameter values
      g_ep_id := p_ep_id;
      g_ep_type := p_ep_type;
      g_egt_id := p_egt_id;
      g_sdf_id := p_sdf_id;
      g_hdp_id := p_hdp_id;
      g_hol_id := p_hol_id;
      g_sdp_id := p_sdp_id;                              -- ORACLE bug #715964
      g_pep_id := p_pep_id;
      g_pip_id := p_pip_id;
      g_sdovr_id := p_sdovr_id;
      g_osp_id := p_osp_id;
      g_hol_yn := p_hol_yn;
      g_person_id := p_person_id;
      g_id := p_id;
      g_tim_id := p_tim_id;
      g_date_worked := p_date_worked;
      g_assignment_id := p_assignment_id;
      g_hours := p_hours;
      g_time_in := p_time_in;
      g_time_out := p_time_out;
      g_element_type_id := p_element_type_id;
      g_fcl_earn_reason_code := p_fcl_earn_reason_code;
      g_ffv_cost_center_id := p_ffv_cost_center_id;
      g_ffv_labor_account_id := p_ffv_labor_account_id;
      g_tas_id := p_tas_id;
      g_location_id := p_location_id;
      g_sht_id := p_sht_id;
      g_hrw_comment := p_hrw_comment;
      g_ffv_rate_code_id := p_ffv_rate_code_id;
      g_rate_multiple := p_rate_multiple;
      g_hourly_rate := p_hourly_rate;
      g_amount := p_amount;
      g_fcl_tax_rule_code := p_fcl_tax_rule_code;
      g_separate_check_flag := p_separate_check_flag;
      g_seqno := p_seqno;
      g_created_by := p_created_by;
      g_creation_date := p_creation_date;
      g_last_updated_by := p_last_updated_by;
      g_last_update_date := p_last_update_date;
      g_last_update_login := p_last_update_login;
      g_start_day_of_week := p_start_day_of_week;
      g_effective_start_date := p_effective_start_date;
      g_effective_end_date := p_effective_end_date;
      g_project_id := p_project_id;                                -- PROJACCT
      g_job_id := p_job_id;
      g_pay_status := p_pay_status;                                -- RETROPAY
      g_pa_status := p_pa_status;                                  -- PROJACCT
      g_retro_batch_id := p_retro_batch_id;                        -- RETROPAY
      g_location := p_location;                                    -- RETROPAY
      g_period_start_date := p_period_start_date;
      g_call_adjust_abs := p_call_adjust_abs;
      g_state_name := p_state_name;
      g_county_name := p_county_name;
      g_city_name := p_city_name;
      g_zip_code := p_zip_code;

-- g_GROUP_ID              := p_GROUP_ID;             -- HXT11i1
      IF g_debug
      THEN
         hr_utility.set_location ('hxt_time_detail.GENERATE_SPECIAL', 20);
      END IF;

      RETURN gen_special (p_location,
                          g_time_in,
                          g_time_out,
                          g_hours,
                          g_sdf_id,
                          g_sdovr_id
                         );

      IF g_debug
      THEN
         hr_utility.set_location ('hxt_time_detail.GENERATE_SPECIAL', 30);
      END IF;
-- parameters used for compatibility with this version of gen special
   END;

--
----------------------------------GEN SPECIAL-----------------------------------
--
   FUNCTION gen_special (
      p_location                IN   VARCHAR2,
      p_time_in                 IN   DATE,
      p_time_out                IN   DATE,
      p_hours_worked            IN   NUMBER,
      p_shift_diff_earning_id   IN   NUMBER,
      p_sdovr_earning_id        IN   NUMBER
   )
      RETURN NUMBER
   IS
      --  Function GEN_SPECIAL
      --  Purpose
      --  Generate detail base and overtime records for the summary record that is
      --  passed.This is called for earning policies where overtime is calculated
      --  on a special basis.The earning rules are applied based on the category
      --  that is passed (NULL or ABS).
      --
      --  To handle a summary hours record that spans shifts, the calling routine
      --  splits the hours into segments that coincide with the shifts.  It then
      --  passes the time in and out of the segment, as well as the hours worked.
      --  The times in and out are given so they may be inserted in the hours worked
      --  table.Times,hours and shift differential earning are passed as parameters
      --  as they are determined by the gen_details routine and not by the globals.
      --
      --  Returns
      --  0 - No errors occured
      --  1 - Warnings occured
      --  2 - Errors occured

      --  Arguments
      --  p_time_in               -  Received time in
      --  p_time_out              -  Received time out
      --  p_hours_worked          -  Received number of hours worked in segment
      --  p_shift_diff_earning_id -  Received id of shift diff earning -- if
      --                             applicable - It is passed unchanged to
      --                             gen premiums
      --  p_location              -  The procedure and/or function path where an
      --                             error occurred -- Local variables - These may
      --                             be read by all local functions but should only
      --                             be modified by the main gen_special section
      ERROR_CODE                     NUMBER         := 0;
      l_error_return                 NUMBER         := 0;            --SIR014
      LOCATION                       VARCHAR2 (120) := p_location || ':SPCL';
      summary_earning_category       VARCHAR2 (10);
      --  category of earning from
      --  summary - NULL or ABS
      rule_type_to_pay               VARCHAR2 (3);
      --  rule type to use ABS,HOL,DAY
      hours_left_to_pay              NUMBER;    --  hours left to pay on this
                                                --  segment
      daily_rule_cap                 NUMBER;     --  number of hours that the
                                                 --  current daily rule spans
      hours_paid_daily_rule          NUMBER;
      --  number of hours that have been
      --  accumulated toward finishing
      --  the current daily rule
      daily_earning_type             NUMBER;
      --  earning element type to apply
      --  to current daily rule
      previous_detail_hours_day      NUMBER;  --  hours on the details of
                                              --  previous summaries this day
      weekly_rule_cap                NUMBER;    --  number of hours that the
                                                --  current weekly rule spans
      weekly_earning_type            NUMBER;
      --  earning element to apply AFTER
      --  the weekly cap is hit
      hours_paid_weekly_rule         NUMBER;
      --  number of hours that have been
      --  accumulated toward finishing
      --  the current weekly rule
      hours_paid_for_dtime_elig      NUMBER;
      --  number of hours paid to check
      --  whether eligible for doubletime
      current_weekly_earning         NUMBER;
      --  type being paid on weekly policy
      weekly_pay_back_earning_type   NUMBER;
      weekly_pay_back_cap            NUMBER;
      in_pay_back_period             BOOLEAN        := FALSE;
      saved_weekly_earning_type      NUMBER;
      --  earning element id of current
      --  rule saved when reading next
      --  rule in case there is no next
      --  rule
      previous_detail_hours_week     NUMBER;
      --  hours on the details of previous
      --  summaries this week
      first_weekly_cap_reached       BOOLEAN        := FALSE;
      second_weekly_cap_reached      BOOLEAN        := FALSE;
      consecutive_days_reached       BOOLEAN;
      --  TRUE means # of days have been
      --  worked for special to apply
      consecutive_days_limit         NUMBER; --  number of days to work until
                                             --  special rule applies
      consec_days_worked             NUMBER; --  SIR431 number of consec days
                                             --  worked
      special_daily_cap              NUMBER;
      --  number of hours to work during
      --  which special_earning_type
      --  applies after the consecutive
      --  days limit is hit
      special_earning_type           NUMBER;
                                          --  earning element id to apply
                                          --  after consec. days limit is hit
      -- Begin SPR C355
      special_earning_type2          NUMBER;
      --  earning element id to apply
      --  after special_daily_cap is hit
      special_daily_cap2             NUMBER;
      --  number of hours to work during
      --  which special_earning_type2
      --  applies
      consecutive_days_limit2        NUMBER;            --  dummy - not used.
      -- End SPR C355
      special_and_weekly_base        NUMBER;
      --  the base earning element
      --  applied to special and weekly
      --  before their caps are hit as
      --  they do not specify one
      seven_day_cal_rule             BOOLEAN;
      --  TRUE when earn pol has 7 day
      --  SPC rule            --SIR017
      five_day_cal_rule              BOOLEAN;
      --  TRUE when earn pol has 5 day
      --  SPC rule            --SIR017
      g_cons_days_worked             NUMBER; --  holds number of consecutive
                                             --  days worked         --SIR017
      first_daily_rule_cap           NUMBER;
      --  number of hours that the first
      --  daily rule spans    --SIR017
      l_day_total                    NUMBER;
                                            --  number of hours worked on 6th
                                            --  day of 7 day SPCrule--SIR017
      -- End PICKWKLDAY  SIR017
      dummy_days                     NUMBER;
      --  variable used to fetch daily
      --  rule with same cursor as special
      fetch_next_day                 BOOLEAN;
      --  flag set to TRUE when a cap is
      --  hit and next rule should be read
      fetch_next_week                BOOLEAN;
      rule_to_pay                    VARCHAR2 (4);
      --  string set to 'DAY' 'WKL' or
      -- 'SPC' to show which rule applies
      --  to a given sub-segment
      hours_to_pay_this_rule         NUMBER;      --  number of hours of this
                                                  --  sub-segment
      element_type_id_to_pay         NUMBER;
      --  element type of the sub-segment
      start_day_of_week              VARCHAR2 (30)  := g_start_day_of_week;
      end_of_day_rules               BOOLEAN        := FALSE;
      --  TRUE signifies that last daily
      --  rule has been read
      loop_counter                   NUMBER         := 0;
                                                 --  counts loop iterations for
                                                 --  checking
      -- MHANDA
      l_use_points_assigned          VARCHAR2 (3);

      -- Bug 8600894
      l_cache                        NUMBER;

      --  variable used to fetch the value
      --  of the flag ,checked or
      --  unchecked ,to determine the
      --  logic to be used for applying
      --  the daily and weekly rules
      CURSOR spc_earn_rules_cur (i_earn_policy NUMBER, i_days NUMBER)
      IS
         SELECT   er.hours, er.element_type_id, er.days
             FROM hxt_earning_rules er
            WHERE er.egr_type = 'SPC'
              AND er.days <= i_days
              AND er.days IS NOT NULL
              AND er.egp_id = i_earn_policy
              AND g_date_worked BETWEEN er.effective_start_date
                                    AND er.effective_end_date
         ORDER BY er.days DESC, er.hours ASC;

      CURSOR daily_earn_rules_cur (i_earn_policy NUMBER, i_egr_type VARCHAR2)
      IS
         SELECT   er.hours, er.element_type_id, er.days
             FROM hxt_earning_rules er
            WHERE er.egr_type = i_egr_type
              AND er.egp_id = i_earn_policy
              AND g_date_worked BETWEEN er.effective_start_date
                                    AND er.effective_end_date
         ORDER BY er.seq_no;

      CURSOR weekly_earn_rules_cur (i_earn_policy NUMBER)
      IS
         SELECT   er.hours, er.element_type_id
             FROM hxt_earning_rules er
            WHERE er.egr_type = 'WKL'
              AND er.egp_id = i_earn_policy
              AND g_date_worked BETWEEN er.effective_start_date
                                    AND er.effective_end_date
         ORDER BY er.seq_no;

      --SIR015
      --CURSOR all_details_hours_day(cursor_day_worked DATE
      --                           , cursor_person_id NUMBER) IS
      CURSOR all_details_hours_day (
         cursor_day_worked   DATE,
         cursor_person_id    NUMBER,
         cursor_tim_id       NUMBER
      )
      IS
         SELECT daily_hours
           FROM hxt_daily_hours_worked_v
          WHERE work_date || '' = cursor_day_worked AND tim_id = cursor_tim_id;

      FUNCTION get_weekly_total
         RETURN NUMBER
      IS
         weekly_base_hours    NUMBER;
         weekly_total_hours   NUMBER;
      BEGIN
         weekly_base_hours :=
            hxt_td_util.get_weekly_total (LOCATION,
                                          g_date_worked,
                                          start_day_of_week,
                                          g_tim_id,
                                          special_and_weekly_base,
                                          g_ep_id,
                                          g_person_id
                                         );
         RETURN weekly_base_hours;
      END;

      FUNCTION get_weekly_total_prev_days
         RETURN NUMBER
      IS
         weekly_base_hours    NUMBER;
         weekly_total_hours   NUMBER;
      BEGIN
         weekly_base_hours :=
            hxt_td_util.get_weekly_total_prev_days (LOCATION,
                                                    g_date_worked,
                                                    start_day_of_week,
                                                    g_tim_id,
                                                    special_and_weekly_base,
                                                    g_ep_id,
                                                    g_person_id
                                                   );
         RETURN weekly_base_hours;
      END get_weekly_total_prev_days;

      FUNCTION get_weekly_total_to_date (
         cp_earn_category   IN   VARCHAR2 DEFAULT NULL
      )
         RETURN NUMBER
      IS

         -- Bug 7359347
         -- Changed the below cursor to use a global variable instead of views
         -- referring to FND_SESSIONS
         /*
         CURSOR weekly_total_to_date
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked hrw,
                   hxt_timecards tim
             WHERE hrw.parent_id > 0
               AND hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND (g_date_worked - 1)
               AND asm.assignment_id = hrw.assignment_id
               AND eltv.hxt_earning_category LIKE NVL (cp_earn_category, '%')
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
-- Commented out for OTLR Recurrring Period Preference support.
-- AND     tim_id = g_tim_id
-- Added the following for OTLR Recurrring Period Preference support.
               AND tim.for_person_id = g_person_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND ( -- If absence, only include earnings to be counted toward
                     -- hours to be worked before being eligible for overtime.

                    --USEEARNGROUP -- include ANY earnings, not just absences. RTF
                    (    EXISTS (
                            SELECT 1
                              FROM hxt_earn_groups erg
                             WHERE erg.egt_id = egp.egt_id
                               AND erg.element_type_id = elt.element_type_id)
                     AND egp.egt_id IS NOT NULL
                    )
                   )
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               -- next line changed to use override earning policy.
               --      AND egp.id = asmv.hxt_earning_policy
               AND egp.ID = g_ep_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;
         */
         CURSOR weekly_total_to_date(session_date   IN DATE)
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked_f hrw,
                   hxt_timecards_f tim
             WHERE hrw.parent_id > 0
               AND hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND (g_date_worked - 1)
               AND asm.assignment_id = hrw.assignment_id
               AND session_date   BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
               AND session_date   BETWEEN tim.effective_start_date
                                      AND tim.effective_end_date
               AND eltv.hxt_earning_category LIKE NVL (cp_earn_category, '%')
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
               AND tim.for_person_id = g_person_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND (
                    (    EXISTS (
                            SELECT 1
                              FROM hxt_earn_groups erg
                             WHERE erg.egt_id = egp.egt_id
                               AND erg.element_type_id = elt.element_type_id)
                     AND egp.egt_id IS NOT NULL
                    )
                   )
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               AND egp.ID = g_ep_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;


         l_weekly_total_to_date   NUMBER;
         l_error_code             NUMBER;

      BEGIN

         -- Bug 7359347
         -- Setting the session date to pass as input to the below cursor.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         OPEN weekly_total_to_date(g_det_session_date);


         FETCH weekly_total_to_date
          INTO l_weekly_total_to_date;

         CLOSE weekly_total_to_date;

         RETURN NVL (l_weekly_total_to_date, 0);
      END get_weekly_total_to_date;

-- Function added to calculate total hours to be worked before being
-- eligible for doubletime -- MHANDA
      FUNCTION get_wkly_total_for_doubletime
         RETURN NUMBER
      IS
         -- Bug 7359347
         -- Changed the below cursor to look at the base tables and use a global
         -- session date variable.
         /*
         CURSOR weekly_total_to_date
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earn_groups erg,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked hrw,
                   hxt_timecards tim
             WHERE hrw.parent_id > 0
               AND hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND (g_date_worked)
               AND asm.assignment_id = hrw.assignment_id
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
               AND tim_id = g_tim_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND egp.egt_id IS NOT NULL
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               -- next line changed to use override earning policy.
               --      AND egp.id = asmv.hxt_earning_policy
               AND egp.ID = g_ep_id
               AND hrw.element_type_id = erg.element_type_id
               AND erg.egt_id = egp.egt_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;
           */

         CURSOR weekly_total_to_date(session_date   DATE)
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earn_groups erg,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked_f hrw,
                   hxt_timecards_f tim
             WHERE hrw.parent_id > 0
               AND hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND (g_date_worked)
               AND asm.assignment_id = hrw.assignment_id
               AND session_date    BETWEEN hrw.effective_start_date
                                       AND hrw.effective_end_date
               AND session_date    BETWEEN tim.effective_start_date
                                       AND tim.effective_end_date
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
               AND tim_id = g_tim_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND egp.egt_id IS NOT NULL
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               -- next line changed to use override earning policy.
               --      AND egp.id = asmv.hxt_earning_policy
               AND egp.ID = g_ep_id
               AND hrw.element_type_id = erg.element_type_id
               AND erg.egt_id = egp.egt_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;


         l_weekly_total_to_date   NUMBER;
      BEGIN

         -- Bug 7359347
         -- Setting the session date to be passed to the cursor below.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         OPEN weekly_total_to_date(g_det_session_date);

         FETCH weekly_total_to_date
          INTO l_weekly_total_to_date;

         CLOSE weekly_total_to_date;

         RETURN NVL (l_weekly_total_to_date, 0);
      END get_wkly_total_for_doubletime;

      FUNCTION get_daily_total
         RETURN NUMBER
      IS

         -- Bug 7359347
         -- Changed the cursor to use global session date instead of views
         -- referring fnd_sessions.
         /*
         CURSOR daily_total
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked hrw,
                   hxt_timecards tim
             WHERE hrw.parent_id > 0
               AND hrw.date_worked = g_date_worked
               AND asm.assignment_id = hrw.assignment_id
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
               AND tim_id = g_tim_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND ( -- If absence, only include earnings to be counted toward
                     -- hours to be worked before being eligible for overtime.
                       (    EXISTS (
                               SELECT 1
                                 FROM hxt_earn_groups erg
                                WHERE erg.egt_id = egp.egt_id
                                  AND erg.element_type_id =
                                                           elt.element_type_id)
                        AND eltv.hxt_earning_category = 'ABS'
                        AND egp.egt_id IS NOT NULL
                       )
                    OR eltv.hxt_earning_category = 'REG'
                    OR eltv.hxt_earning_category = 'OVT'
                   --      OR
                   --  to_char(hrw.element_type_id) LIKE
                   --                  NVL(to_char(special_and_weekly_base), '%')
                   )
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               -- next line changed to use override earning policy.
               --      AND egp.id = asmv.hxt_earning_policy
               AND egp.ID = g_ep_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;
             */

         CURSOR daily_total(session_date  DATE)
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked_f hrw,
                   hxt_timecards_f tim
             WHERE hrw.parent_id > 0
               AND hrw.date_worked = g_date_worked
               AND asm.assignment_id = hrw.assignment_id
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND session_date    BETWEEN hrw.effective_start_date
                                       AND hrw.effective_end_date
               AND session_date    BETWEEN tim.effective_start_date
                                       AND tim.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
               AND tim_id = g_tim_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND ( -- If absence, only include earnings to be counted toward
                     -- hours to be worked before being eligible for overtime.
                       (    EXISTS (
                               SELECT 1
                                 FROM hxt_earn_groups erg
                                WHERE erg.egt_id = egp.egt_id
                                  AND erg.element_type_id =
                                                           elt.element_type_id)
                        AND eltv.hxt_earning_category = 'ABS'
                        AND egp.egt_id IS NOT NULL
                       )
                    OR eltv.hxt_earning_category = 'REG'
                    OR eltv.hxt_earning_category = 'OVT'
                   --      OR
                   --  to_char(hrw.element_type_id) LIKE
                   --                  NVL(to_char(special_and_weekly_base), '%')
                   )
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               -- next line changed to use override earning policy.
               --      AND egp.id = asmv.hxt_earning_policy
               AND egp.ID = g_ep_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;

            CURSOR daily_hol_total(session_date IN DATE)
                IS
             select NVL(SUM(det.hours),0)
	       from hxt_det_hours_worked_f det,
	            hxt_sum_hours_worked_f sum,
	            hxt_earning_rules er
	      WHERE det.date_worked = g_date_worked
	        AND sum.id = det.parent_id
	        AND sum.element_type_id IS NULL
	        AND det.tim_id = g_tim_id
	        AND det.element_type_id = er.element_type_id
	        AND er.egp_id = g_ep_id
	        AND er.egr_type = 'HOL'
	        AND session_date BETWEEN er.effective_start_date
	                             AND er.effective_end_date
	        AND session_date BETWEEN det.effective_start_date
	                             AND det.effective_end_date
	        AND session_date BETWEEN sum.effective_start_date
	                             AND sum.effective_end_date;



         l_daily_total   NUMBER;
         l_daily_hol_total NUMBER;
      BEGIN

         -- Bug 7359347
         -- Getting the session date to pass to the cursor.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         OPEN daily_total(g_det_session_date);

         FETCH daily_total
          INTO l_daily_total;

         CLOSE daily_total;

        hr_utility.trace(' Hol : G_date_worked'||g_date_worked);

        hr_utility.trace(' Hol : l_daily_total '||l_daily_total);

        IF NVL(fnd_profile.value('HXT_HOLIDAY_EXPLOSION'),'EX') <> 'EX'
        THEN
            OPEN daily_hol_total(g_det_session_date);
            FETCH daily_hol_total INTO l_daily_hol_total;
            CLOSE daily_hol_total;

            l_daily_total := l_daily_total - l_daily_hol_total;
            hr_utility.trace(' Hol : l_dailyhol_total '||l_daily_hol_total);
            hr_utility.trace(' Hol : l_daily_total '||l_daily_total);
        END IF;

         RETURN NVL (l_daily_total, 0);
      END get_daily_total;

-- we have a hole in the 7 day california rule, on the 6th day.  Customers
-- may require that an employee be paid DoubleTime for any hours after 12.
-- but normal processing will see that as the weekly cap being hit and
-- pay it all as Overtime.  This function is called at the end of explode
-- for the sixth day if the daily total > 12.
-- For example, a person works:
--              M  T  W  T  F  S
--              8  8  8  8  4  15
-- explodes as  8  8  8  8  4  4   reg
--                             11  OT
--
-- This function does:   15 - 12 = 3  (number of hrs over 12)
--                       11 - 3  = 8  (update detail record, chg 11 to 8)
--                       insert new detail record - 3 hrs of doubletime.
      FUNCTION adjust_for_double_time (p_day_total IN NUMBER)
         RETURN NUMBER
      IS
         -- Bug 7359347
         -- Changed the below cursor to use a global session date variable
         -- rather than views referring to fnd_sessions.
         /*
         CURSOR overtime_cur
         IS
            SELECT hrw.ROWID hrw_rowid, hrw.hours
-- FROM pay_element_types_f_dfv eltv,
            FROM   hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked hrw,                            --C421
                   hxt_timecards tim
             WHERE hrw.date_worked = g_date_worked
               AND tim_id = g_tim_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND eltv.hxt_earning_category = 'OVT'
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;
          */

         CURSOR overtime_cur(session_date  DATE)
         IS
            SELECT hrw.ROWID hrw_rowid, hrw.hours
            FROM   hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked_f hrw,                            --C421
                   hxt_timecards_f tim
             WHERE hrw.date_worked = g_date_worked
               AND tim_id = g_tim_id
               AND tim.ID = hrw.tim_id
               AND session_date   BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
               AND session_date   BETWEEN tim.effective_start_date
                                      AND tim.effective_end_date
               AND elt.element_type_id = hrw.element_type_id
               AND eltv.hxt_earning_category = 'OVT'
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;


         CURSOR daily_earn_rules_cur2 (i_earn_policy NUMBER)
         IS
            SELECT   er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'DAY'
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

         l_delta              NUMBER;
         l_hours_to_adjust    NUMBER;
         l_rowid              ROWID;
         l_dummy_elem         NUMBER;
         l_double_time_elem   NUMBER;
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_double_time', 10);
         END IF;

         l_delta := p_day_total - 12;

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         OPEN overtime_cur(g_det_session_date);

         FETCH overtime_cur
          INTO l_rowid, l_hours_to_adjust;

         IF overtime_cur%NOTFOUND
         THEN
            CLOSE overtime_cur;

            RETURN 1;
         END IF;

         CLOSE overtime_cur;

         UPDATE hxt_det_hours_worked_f
            SET hours = l_hours_to_adjust - l_delta
          WHERE ROWID = l_rowid;

         OPEN daily_earn_rules_cur2 (g_ep_id);

         FETCH daily_earn_rules_cur2
          INTO l_dummy_elem;

         IF daily_earn_rules_cur2%FOUND
         THEN
            FETCH daily_earn_rules_cur2
             INTO l_dummy_elem;

            IF daily_earn_rules_cur2%FOUND
            THEN
               FETCH daily_earn_rules_cur2
                INTO l_double_time_elem;

               IF daily_earn_rules_cur2%FOUND
               THEN
                  NULL;
               ELSE
                  CLOSE daily_earn_rules_cur2;

                  RETURN 4;
               END IF;
            ELSE
               CLOSE daily_earn_rules_cur2;

               RETURN 3;
            END IF;
         ELSE
            CLOSE daily_earn_rules_cur2;

            hxt_util.DEBUG ('Return code is 2 from loc A');
            -- debug only --HXT115
            RETURN 2;
         END IF;

         CLOSE daily_earn_rules_cur2;

         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_double_time', 50);
         END IF;

         IF pay (l_delta,
                 l_double_time_elem,
                 NULL,
                 NULL,
                 g_date_worked,
                 g_id,                                            -- parent id
                 g_assignment_id,
                 g_fcl_earn_reason_code,
                 g_ffv_cost_center_id,
                 g_ffv_labor_account_id,
                 g_tas_id,
                 g_location_id,
                 g_sht_id,
                 g_hrw_comment,
                 g_ffv_rate_code_id,
                 g_rate_multiple,
                 g_hourly_rate,
                 g_amount,
                 g_fcl_tax_rule_code,
                 g_separate_check_flag,
                 g_project_id,
                 -- g_GROUP_ID,
                 g_ep_id,
                 a_state_name       => g_state_name,
                 a_county_name      => g_county_name,
                 a_city_name        => g_city_name,
                 a_zip_code         => g_zip_code
                ) <> 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('adjust_for_double_time', 75);
            END IF;

            RETURN 5;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_double_time', 100);
         END IF;

         RETURN 0;
      END adjust_for_double_time;

      FUNCTION get_weekly_total_incl_2day
         RETURN NUMBER
      IS
         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.
         /*
         CURSOR weekly_total_to_date
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked hrw,
                   hxt_timecards tim
             WHERE hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND g_date_worked
               AND asm.assignment_id = hrw.assignment_id
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
-- Commented out for OTLR Recurrring Period Preference support.
-- and     tim_id = g_tim_id
-- Added the following for OTLR Recurrring Period Preference support.
               AND tim.for_person_id = g_person_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND (
                    -- If absence, only include earnings to be counted toward
                    -- hours to be worked before being eligible for overtime.
                    --USEEARNGROUP -- include ANY earnings, not just absences. RTF
                    (    EXISTS (
                            SELECT 1
                              FROM hxt_earn_groups erg
                             WHERE erg.egt_id = egp.egt_id
                               AND erg.element_type_id = elt.element_type_id)
                     AND egp.egt_id IS NOT NULL
                    )
                   )
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               AND egp.ID = g_ep_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;

            */

         CURSOR weekly_total_to_date(session_date  DATE)
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_earning_policies egp,
                   hxt_per_aei_ddf_v asmv,
                   per_assignments_f asm,
                   hxt_det_hours_worked_f hrw,
                   hxt_timecards_f tim
             WHERE hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND g_date_worked
               AND asm.assignment_id = hrw.assignment_id
               AND hrw.date_worked BETWEEN asm.effective_start_date
                                       AND asm.effective_end_date
               AND asm.assignment_id = asmv.assignment_id
               AND session_date   BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
               AND session_date   BETWEEN tim.effective_start_date
                                      AND tim.effective_end_date
               AND hrw.date_worked BETWEEN asmv.effective_start_date
                                       AND asmv.effective_end_date
               AND tim.for_person_id = g_person_id
               AND tim.ID = hrw.tim_id
               AND elt.element_type_id = hrw.element_type_id
               AND (
                    (    EXISTS (
                            SELECT 1
                              FROM hxt_earn_groups erg
                             WHERE erg.egt_id = egp.egt_id
                               AND erg.element_type_id = elt.element_type_id)
                     AND egp.egt_id IS NOT NULL
                    )
                   )
               AND hrw.date_worked BETWEEN egp.effective_start_date
                                       AND egp.effective_end_date
               AND egp.ID = g_ep_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;


         l_weekly_total_to_date   NUMBER;
      BEGIN

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         OPEN weekly_total_to_date(g_det_session_date);

         FETCH weekly_total_to_date
          INTO l_weekly_total_to_date;

         CLOSE weekly_total_to_date;

         RETURN NVL (l_weekly_total_to_date, 0);
      END get_weekly_total_incl_2day;

      FUNCTION segment_start_in_rule (
         p_rule_earning_type    OUT NOCOPY      NUMBER,
         p_segment_start_time   IN              DATE
      )
         RETURN BOOLEAN
      IS
-- Checks to see if the segment start time falls within a shift diff rule.
-- If so, returns the earning type of the rule.  Returns true if the segment
-- start is within a rule, false if it is not.  The | in the comments shows
-- where midnight falls.  The segment start and stop are both dates while
-- sdr.start and stop are numbers.
         CURSOR sd_rules
         IS
            SELECT sdr.element_type_id
              FROM hxt_shift_diff_rules sdr
             WHERE sdr.sdp_id = g_sdp_id
               AND g_date_worked BETWEEN sdr.effective_start_date
                                     AND sdr.effective_end_date
               AND (   (    sdr.start_time <=
                               TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                   'HH24MI'
                                                  )
                                         )
                        AND TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) < sdr.stop_time
                       )
                    OR (    (TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                 'HH24MI'
                                                )
                                       ) <= sdr.start_time
                            )
                        AND TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) < sdr.stop_time
                        AND sdr.start_time > sdr.stop_time
                       )
                    OR (    sdr.start_time <=
                               TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                   'HH24MI'
                                                  )
                                         )
                        AND sdr.start_time > sdr.stop_time
                       )
                   );
      BEGIN
         OPEN sd_rules;

         FETCH sd_rules
          INTO p_rule_earning_type;

         IF sd_rules%NOTFOUND
         THEN
            CLOSE sd_rules;

            RETURN FALSE;
         END IF;

         CLOSE sd_rules;

         RETURN TRUE;
      END segment_start_in_rule;

      FUNCTION rule_start_in_segment (
         p_rule_earning_type    OUT NOCOPY      NUMBER,
         p_segment_start_time   IN              DATE,
         p_segment_stop_time    IN              DATE
      )
         RETURN BOOLEAN
      IS
         -- Checks to see if a shift diff rule starts within the time segment being
         -- generated.  This is only called if it is already determined that the start
         -- of the segment does not fall within any rule.
         CURSOR sd_rules
         IS
            SELECT sdr.element_type_id
              FROM hxt_shift_diff_rules sdr
             WHERE sdr.sdp_id = g_sdp_id
               AND g_date_worked BETWEEN sdr.effective_start_date
                                     AND sdr.effective_end_date
               AND (   (    TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) < sdr.start_time
                        AND sdr.start_time <
                               TO_NUMBER (TO_CHAR (p_segment_stop_time,
                                                   'HH24MI'
                                                  )
                                         )
                       )
                    OR (    TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) > sdr.start_time
                        AND sdr.start_time <
                               TO_NUMBER (TO_CHAR (p_segment_stop_time,
                                                   'HH24MI'
                                                  )
                                         )
                        AND TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) >
                               TO_NUMBER (TO_CHAR (p_segment_stop_time,
                                                   'HH24MI'
                                                  )
                                         )
                       )
                    OR (    TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) < sdr.start_time
                        AND TO_NUMBER (TO_CHAR (p_segment_start_time,
                                                'HH24MI')
                                      ) >
                               TO_NUMBER (TO_CHAR (p_segment_stop_time,
                                                   'HH24MI'
                                                  )
                                         )
                       )
                   );
      BEGIN
         OPEN sd_rules;

         FETCH sd_rules
          INTO p_rule_earning_type;

         IF sd_rules%NOTFOUND
         THEN
            CLOSE sd_rules;

            RETURN FALSE;
         END IF;

         CLOSE sd_rules;

         RETURN TRUE;
      END rule_start_in_segment;

-- END ORACLE bug #715964
      FUNCTION adjust_for_hdp_shortage (p_hours_short IN NUMBER)
         RETURN NUMBER
      IS
-- Update existing det rows for hours that can't be deducted from this segment
         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         CURSOR current_dtl (c_hours_short NUMBER,
                             session_date  DATE)
         IS
            SELECT   dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                     dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_det_hours_worked_f dhw
               WHERE dhw.tim_id = g_tim_id
                 AND dhw.date_worked = g_date_worked
                 AND session_date BETWEEN dhw.effective_start_date
                                      AND dhw.effective_end_date
                 AND dhw.hours > c_hours_short
                 AND elt.element_type_id = dhw.element_type_id
                 AND dhw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND eltv.element_type_id = elt.element_type_id
                 AND dhw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
                 AND eltv.hxt_earning_category IN ('REG', 'OVT')
            ORDER BY dhw.date_worked DESC, dhw.time_in DESC, dhw.seqno DESC;

         l_hours_to_adjust   NUMBER;
         current_dtl_row     current_dtl%ROWTYPE;
         l_proc              VARCHAR2 (250);
      BEGIN
         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.adjust_for_hdp_shortage';
            hr_utility.set_location (l_proc, 10);
         END IF;

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         OPEN current_dtl (p_hours_short,g_det_session_date);

         FETCH current_dtl
          INTO current_dtl_row;

         IF current_dtl%NOTFOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 20);
            END IF;

            CLOSE current_dtl;

            RETURN (p_hours_short);
         END IF;

         CLOSE current_dtl;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 30);
            hr_utility.TRACE ('current_dtl_row.hours:'
                              || current_dtl_row.hours
                             );
            hr_utility.TRACE ('p_hours_short      :' || p_hours_short);
         END IF;

         l_hours_to_adjust := current_dtl_row.hours - p_hours_short;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_hours_to_adjust:' || l_hours_to_adjust);
            hr_utility.TRACE (   'current_dtl_row.parent_id:'
                              || current_dtl_row.parent_id
                             );
            hr_utility.TRACE ('current_dtl_row.seqno:'
                              || current_dtl_row.seqno
                             );
            hr_utility.TRACE ('current_dtl_row.hours:'
                              || current_dtl_row.hours
                             );
         END IF;

         FOR l_prem IN related_prem (current_dtl_row.parent_id,
                                     current_dtl_row.tim_id,
                                     current_dtl_row.seqno,
                                     current_dtl_row.hours,
                                     g_det_session_date
                                    )
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 40);
            END IF;

            -- Bug 7359347
            -- Changed the view referred to base table as the where
            -- clause is on rowid.
            /*
            UPDATE hxt_det_hours_worked
               SET hours = l_hours_to_adjust,
                   time_out = time_out - (p_hours_short / 24)
             WHERE ROWID = l_prem.prem_row_id;
            */
            UPDATE hxt_det_hours_worked_f
               SET hours = l_hours_to_adjust,
                   time_out = time_out - (p_hours_short / 24)
             WHERE ROWID = l_prem.prem_row_id;

         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 50);
         END IF;

         -- Bug 7359347
            -- Changed the view referred to base table as the where
            -- clause is on rowid.
         /*
         UPDATE hxt_det_hours_worked
            SET hours = l_hours_to_adjust,
                time_out = time_out - (p_hours_short / 24)
          WHERE ROWID = current_dtl_row.dhw_rowid;
          */
         UPDATE hxt_det_hours_worked_f
            SET hours = l_hours_to_adjust,
                time_out = time_out - (p_hours_short / 24)
          WHERE ROWID = current_dtl_row.dhw_rowid;


         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 60);
         END IF;

         RETURN (0);
      END adjust_for_hdp_shortage;

      FUNCTION adjust_for_3tier (
         a_tim_id        NUMBER,
         a_ep_id         NUMBER,
         a_date_worked   DATE
      )
         RETURN NUMBER
      IS

         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR ovt_hrs_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            c_ovt_element   NUMBER
         )                                                         -- SIR 397
         IS
            SELECT   det.ROWID det_rowid, det.hours, det.date_worked,
                     det.parent_id, det.assignment_id,
                     det.fcl_earn_reason_code, det.ffv_cost_center_id,
                     det.tas_id, det.location_id, det.sht_id,
                     det.hrw_comment, det.ffv_rate_code_id,
                     det.rate_multiple, det.hourly_rate, det.amount,
                     det.fcl_tax_rule_code, det.separate_check_flag,
                     det.seqno, det.time_in, det.time_out, det.project_id,
                     det.element_type_id, det.effective_end_date,

                     -- det.group_id,
                     det.earn_pol_id, det.state_name, det.county_name,
                     det.city_name, det.zip_code
                FROM hxt_det_hours_worked det
               WHERE det.element_type_id = c_ovt_element            --SIR 397
                 AND det.date_worked <= c_date_worked
                 AND det.tim_id = c_tim_id
                 AND det.hours <> 0
            ORDER BY det.date_worked DESC, det.time_out DESC, det.ID DESC;

          */

         CURSOR ovt_hrs_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            c_ovt_element   NUMBER,
            session_date    DATE
         )                                                         -- SIR 397
         IS
            SELECT   det.ROWID det_rowid, det.hours, det.date_worked,
                     det.parent_id, det.assignment_id,
                     det.fcl_earn_reason_code, det.ffv_cost_center_id,
                     det.tas_id, det.location_id, det.sht_id,
                     det.hrw_comment, det.ffv_rate_code_id,
                     det.rate_multiple, det.hourly_rate, det.amount,
                     det.fcl_tax_rule_code, det.separate_check_flag,
                     det.seqno, det.time_in, det.time_out, det.project_id,
                     det.element_type_id, det.effective_end_date,

                     -- det.group_id,
                     det.earn_pol_id, det.state_name, det.county_name,
                     det.city_name, det.zip_code
                FROM hxt_det_hours_worked_f det
               WHERE det.element_type_id = c_ovt_element            --SIR 397
                 AND det.date_worked <= c_date_worked
                 AND session_date  BETWEEN det.effective_start_date
                                       AND det.effective_end_date
                 AND det.tim_id = c_tim_id
                 AND det.hours <> 0
            ORDER BY det.date_worked DESC, det.time_out DESC, det.ID DESC;

         CURSOR weekly_earn_rules_cur2 (
            c_earn_policy   NUMBER,
            c_date_worked   DATE
         )
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'WKL'
                 AND er.egp_id = c_earn_policy
                 AND c_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR sum_ovt_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            c_second_elem   NUMBER
         )
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_det_hours_worked hrw
             WHERE hrw.date_worked <= c_date_worked
               AND hrw.tim_id = c_tim_id
               AND hrw.element_type_id = c_second_elem;
         */

         CURSOR sum_ovt_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            c_second_elem   NUMBER,
            session_date    DATE
         )
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_det_hours_worked_f hrw
             WHERE hrw.date_worked <= c_date_worked
               AND hrw.tim_id = c_tim_id
               AND hrw.element_type_id = c_second_elem
               AND session_date BETWEEN hrw.effective_start_date
                                    AND hrw.effective_end_date;


         CURSOR prem_amount_cur (c_date_worked DATE, c_elem NUMBER)
         IS
            SELECT NVL (hxt_premium_amount, 0)
              FROM hxt_pay_element_types_f_ddf_v eltv
             WHERE c_date_worked BETWEEN eltv.effective_start_date
                                     AND eltv.effective_end_date
               AND eltv.element_type_id = c_elem;

         l_error_code        NUMBER;
         l_delta             NUMBER;
         l_hours_to_adjust   NUMBER;
         l_hours_left        NUMBER;
         l_first_elem        NUMBER;
         l_second_elem       NUMBER;
         l_third_elem        NUMBER;
         l_first_cap         NUMBER;
         l_second_cap        NUMBER;
         l_third_cap         NUMBER;
         l_ovt_hrs_cur       ovt_hrs_cur%ROWTYPE;
         l_sum_hours         NUMBER                := 0;
         l_sum_reg           NUMBER                := 0;
         l_multiple          NUMBER                := 0;
         l_id                NUMBER;                                   --debug
      BEGIN
-- collect earnings rules

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;


         IF g_ep_type NOT IN ('SPECIAL', 'WEEKLY')
         THEN
            RETURN 0;                                        -- nothing to do
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_3tier', 10);
         END IF;

         OPEN weekly_earn_rules_cur2 (a_ep_id, a_date_worked);

         FETCH weekly_earn_rules_cur2
          INTO l_first_cap, l_first_elem;

         IF weekly_earn_rules_cur2%FOUND
         THEN
            FETCH weekly_earn_rules_cur2
             INTO l_second_cap, l_second_elem;

            IF weekly_earn_rules_cur2%FOUND
            THEN
               FETCH weekly_earn_rules_cur2
                INTO l_third_cap, l_third_elem;

               IF weekly_earn_rules_cur2%FOUND
               THEN
                  NULL;
               ELSE
                  l_third_cap := 999;
               END IF;
            ELSE
               l_second_cap := 999;
            END IF;
         ELSE
            CLOSE weekly_earn_rules_cur2;

            hxt_util.DEBUG ('Return code is 2 from loc C');
            -- debug only --HXT115
            RETURN 2;
         END IF;

         CLOSE weekly_earn_rules_cur2;

         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_3tier', 30);
         END IF;

-- fetch sum of regular hours to date
/* CHANGED call to get only REGULAR Hours Worked instead of total hours*/
         l_sum_reg := get_weekly_total_incl_2day;

-- l_sum_reg := get_weekly_total_to_date('REG');

         -- fetch sum of overtime hours to date marker
         OPEN sum_ovt_cur (a_tim_id, a_date_worked, l_second_elem,g_det_session_date);


         -- OPEN sum_ovt_cur(a_tim_id, a_date_worked);
         FETCH sum_ovt_cur
          INTO l_delta;

         CLOSE sum_ovt_cur;

         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_3tier', 50);
         END IF;

         IF (l_sum_reg + l_delta) <= l_second_cap
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('adjust_for_3tier', 60);
            END IF;

            RETURN 0;
         END IF;

-- if sum of overtime hours to date is greater than the second cap
-- minus the first cap then set hours to adjust. Locate overtime
-- records that must be adjusted

         -- SIR 391 Change the criteria to: If the total overtime cap hours
-- SIR 391 for the week are greater than the second cap then adjust the
-- SIR 391 overtime records.
         IF (l_sum_reg + l_delta) <= l_second_cap
         THEN
            -- SIR 391 if(l_delta <= (l_second_cap - l_first_cap)) then
            RETURN (0);
         ELSE
            -- SIR 391 l_hours_to_adjust := (l_delta - (l_second_cap - l_first_cap));
            l_hours_to_adjust := (l_sum_reg + l_delta) - l_second_cap;

            -- SIR 391
            OPEN prem_amount_cur (a_date_worked, l_third_elem);

            FETCH prem_amount_cur
             INTO l_multiple;

            CLOSE prem_amount_cur;

            --SIR 397  OPEN ovt_hrs_cur(a_tim_id, a_date_worked);
            OPEN ovt_hrs_cur (a_tim_id, a_date_worked, l_second_elem,g_det_session_date);


            -- SIR 397
            WHILE l_hours_to_adjust > 0
            LOOP                      -- fetch overtime rows in reverse order
               FETCH ovt_hrs_cur
                INTO l_ovt_hrs_cur;

               IF ovt_hrs_cur%NOTFOUND
               THEN
                  CLOSE ovt_hrs_cur;

                  RETURN 1;
               END IF;

               --
               IF (l_ovt_hrs_cur.element_type_id = l_second_elem)
               THEN
                  IF (l_ovt_hrs_cur.hours >= l_hours_to_adjust)
                  THEN
                     l_hours_left := l_hours_to_adjust;
                  ELSE
                     l_hours_left := l_ovt_hrs_cur.hours;
                  END IF;

                  --
                  IF (l_ovt_hrs_cur.hours > l_hours_left)
                  THEN
                     UPDATE hxt_det_hours_worked_f
                        SET hours = (hours - l_hours_left),
                            time_out =
                                 time_in
                               + ((l_ovt_hrs_cur.hours - l_hours_left) / 24)
                      WHERE ROWID = l_ovt_hrs_cur.det_rowid;
                  ELSE
                     UPDATE hxt_det_hours_worked_f
                        --SIR382 SET hours    = (hours - l_hours_left),
                        --SIR382     time_out = time_in + (l_hours_left/24)
                     SET hours = 0,
                         time_out = time_in
                      WHERE ROWID = l_ovt_hrs_cur.det_rowid;
                  END IF;

                  --
                  FOR l_prem IN related_prem (l_ovt_hrs_cur.parent_id,
                                              a_tim_id,
                                              l_ovt_hrs_cur.seqno,
                                              l_ovt_hrs_cur.hours,
                                              g_det_session_date
                                             )
                  LOOP
                     IF (l_ovt_hrs_cur.hours > l_hours_left)
                     THEN
                        UPDATE hxt_det_hours_worked_f
                           SET hours = (hours - l_hours_left),
                               time_out =
                                    time_in
                                  + ((l_ovt_hrs_cur.hours - l_hours_left) / 24
                                    )
                         WHERE ROWID = l_prem.prem_row_id;
                     ELSE
                        UPDATE hxt_det_hours_worked_f
                           SET hours = 0,
                               time_out = time_in
                         WHERE ROWID = l_prem.prem_row_id;
                     END IF;
                  END LOOP;

                  --
                  IF g_debug
                  THEN
                     hr_utility.set_location ('adjust_for_3tier', 100);
                  END IF;

                  IF (l_ovt_hrs_cur.hours > l_hours_left)
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location ('adjust_for_3tier', 110);
                     END IF;

                     l_error_code :=
                        pay (l_hours_left,
                             l_third_elem,
                               l_ovt_hrs_cur.time_in
                             + ((l_ovt_hrs_cur.hours - l_hours_left) / 24),
                               l_ovt_hrs_cur.time_in
                             + (l_ovt_hrs_cur.hours / 24),
                             l_ovt_hrs_cur.date_worked,
                             l_ovt_hrs_cur.parent_id,
                             l_ovt_hrs_cur.assignment_id,
                             l_ovt_hrs_cur.fcl_earn_reason_code,
                             l_ovt_hrs_cur.ffv_cost_center_id,
                             NULL,
                             l_ovt_hrs_cur.tas_id,
                             l_ovt_hrs_cur.location_id,
                             l_ovt_hrs_cur.sht_id,
                             l_ovt_hrs_cur.hrw_comment,
                             l_ovt_hrs_cur.ffv_rate_code_id,
                             l_multiple,
                             l_ovt_hrs_cur.hourly_rate,
                             l_ovt_hrs_cur.amount,
                             l_ovt_hrs_cur.fcl_tax_rule_code,
                             l_ovt_hrs_cur.separate_check_flag,
                             l_ovt_hrs_cur.project_id,
                             -- l_ovt_hrs_cur.group_id,
                             l_ovt_hrs_cur.earn_pol_id,
                             a_state_name       => l_ovt_hrs_cur.state_name,
                             a_county_name      => l_ovt_hrs_cur.county_name,
                             a_city_name        => l_ovt_hrs_cur.city_name,
                             a_zip_code         => l_ovt_hrs_cur.zip_code
                            );                                        --SIR337
                  ELSIF (l_ovt_hrs_cur.hours = l_hours_left)
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location ('adjust_for_3tier', 120);
                     END IF;

                     l_error_code :=
                        pay (l_hours_left,
                             l_third_elem,
                             l_ovt_hrs_cur.time_in,
                             l_ovt_hrs_cur.time_out,
                             l_ovt_hrs_cur.date_worked,
                             l_ovt_hrs_cur.parent_id,
                             l_ovt_hrs_cur.assignment_id,
                             l_ovt_hrs_cur.fcl_earn_reason_code,
                             l_ovt_hrs_cur.ffv_cost_center_id,
                             NULL,
                             l_ovt_hrs_cur.tas_id,
                             l_ovt_hrs_cur.location_id,
                             l_ovt_hrs_cur.sht_id,
                             l_ovt_hrs_cur.hrw_comment,
                             l_ovt_hrs_cur.ffv_rate_code_id,
                             -- l_ovt_hrs_cur.rate_multiple,
                             l_multiple,
                             l_ovt_hrs_cur.hourly_rate,
                             l_ovt_hrs_cur.amount,
                             l_ovt_hrs_cur.fcl_tax_rule_code,
                             l_ovt_hrs_cur.separate_check_flag,
                             l_ovt_hrs_cur.project_id,
                             -- l_ovt_hrs_cur.group_id,
                             l_ovt_hrs_cur.earn_pol_id,
                             a_state_name       => l_ovt_hrs_cur.state_name,
                             a_county_name      => l_ovt_hrs_cur.county_name,
                             a_city_name        => l_ovt_hrs_cur.city_name,
                             a_zip_code         => l_ovt_hrs_cur.zip_code
                            );                                        --SIR337
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location ('adjust_for_3tier', 130);
                     END IF;

                     l_error_code :=
                        pay (l_hours_left,
                             l_third_elem,
                             l_ovt_hrs_cur.time_in,
                             l_ovt_hrs_cur.time_out - (l_hours_left / 24),
                             l_ovt_hrs_cur.date_worked,
                             l_ovt_hrs_cur.parent_id,
                             l_ovt_hrs_cur.assignment_id,
                             l_ovt_hrs_cur.fcl_earn_reason_code,
                             l_ovt_hrs_cur.ffv_cost_center_id,
                             NULL,
                             l_ovt_hrs_cur.tas_id,
                             l_ovt_hrs_cur.location_id,
                             l_ovt_hrs_cur.sht_id,
                             l_ovt_hrs_cur.hrw_comment,
                             l_ovt_hrs_cur.ffv_rate_code_id,
                             -- l_ovt_hrs_cur.rate_multiple,
                             l_multiple,
                             l_ovt_hrs_cur.hourly_rate,
                             l_ovt_hrs_cur.amount,
                             l_ovt_hrs_cur.fcl_tax_rule_code,
                             l_ovt_hrs_cur.separate_check_flag,
                             l_ovt_hrs_cur.project_id,
                             -- l_ovt_hrs_cur.group_id,
                             l_ovt_hrs_cur.earn_pol_id,
                             a_state_name       => l_ovt_hrs_cur.state_name,
                             a_county_name      => l_ovt_hrs_cur.county_name,
                             a_city_name        => l_ovt_hrs_cur.city_name,
                             a_zip_code         => l_ovt_hrs_cur.zip_code
                            );                                        --SIR337
                  END IF;

                  --
                  l_hours_to_adjust := (l_hours_to_adjust - l_hours_left);
               --
               END IF;

               --
               IF (l_hours_to_adjust = 0)
               THEN
                  CLOSE ovt_hrs_cur;

                  RETURN 0;
               END IF;
            --
            END LOOP;
         END IF;

         CLOSE ovt_hrs_cur;

         IF g_debug
         THEN
            hr_utility.set_location ('adjust_for_3tier', 200);
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code :=
               call_hxthxc_gen_error ('HXC',
                                      'HXC_HXT_DEP_VAL_OTMERR',
                                      'Adjust_for_3tier',
                                      LOCATION,
                                      'Adjust_for_3tier.',
                                      SQLERRM
                                     );
            --2278400      l_error_code := call_gen_error(location, 'Adjust_for_3tier.', sqlerrm);
            RETURN 4;
      END adjust_for_3tier;

--
--------------------------------------------------------------------------------
--
      PROCEDURE adjust_hours_for_premium (
         dtl_parent_id    IN              NUMBER,
         dtl_tim_id       IN              NUMBER,
         dtl_seqno        IN              NUMBER,
         dtl_hours        IN              NUMBER,
         p_sum_time_in    IN              DATE,
         p_sum_time_out   IN              DATE,
         deduct_premium   IN              NUMBER,
         adjust_by        IN              VARCHAR2,
         prem_adjusted    IN OUT NOCOPY   BOOLEAN
      )
      IS
         CURSOR sdp_rule_cursor
         IS
            SELECT sdr.start_time, sdr.stop_time, sdr.carryover_time,
                   elt.element_name
              FROM hxt_shift_diff_rules sdr, pay_element_types_f elt
             WHERE sdr.sdp_id = g_sdp_id
               AND sdr.element_type_id = elt.element_type_id
               AND trunc(p_sum_time_in) BETWEEN elt.effective_start_date
                                AND elt.effective_end_date;

         l_sdp_start       DATE;
         l_sdp_stop        DATE;
         l_sdp_carryover   DATE;
         l_proc            VARCHAR2 (250)
                                 := 'hxt_time_detail.adjust_hours_for_premium';
      BEGIN
         FOR l_sdp_rule IN sdp_rule_cursor
         LOOP
            hxt_time_summary.time_in_dates (l_sdp_rule.start_time,
                                            l_sdp_rule.stop_time,
                                            l_sdp_rule.carryover_time,
                                            l_sdp_start,
                                            l_sdp_stop,
                                            l_sdp_carryover,
                                            g_date_worked
                                           );

            IF    (    (    p_sum_time_in <= l_sdp_start
                        AND l_sdp_start <= p_sum_time_out
                       )
                   AND (    p_sum_time_in <= l_sdp_stop
                        AND l_sdp_stop <= p_sum_time_out
                       )
                  )
               OR (    (    l_sdp_start <= p_sum_time_in
                        AND p_sum_time_in <= l_sdp_stop
                       )
                   AND (    l_sdp_start <= p_sum_time_out
                        AND p_sum_time_out <= l_sdp_stop
                       )
                  )
               OR (    (    l_sdp_start <= p_sum_time_in
                        AND p_sum_time_in <= l_sdp_stop
                       )
                   AND (    l_sdp_start <= p_sum_time_out
                        AND l_sdp_stop <= p_sum_time_out
                       )
                  )
              -- Bug 7206554
              -- Below condition added to include the eligibility for
              -- HDP in a premium element even after it is after midnight.
              -- The issue here was that because it starts from midnight,
              -- it wouldnt fall in the SDP range.  To handle this particular
              -- case alone, the below condition would check the SDP range of the
              -- previous day.
              OR (   TRUNC(p_sum_time_out) = TRUNC(p_sum_time_in)
                      AND   (    l_sdp_start-1 <= p_sum_time_in
                              AND p_sum_time_in <= GREATEST(l_sdp_stop,l_sdp_carryover)-1
                            )
                      AND (    l_sdp_start-1 <= p_sum_time_out
                           AND p_sum_time_out <= GREATEST(l_sdp_stop,l_sdp_carryover)-1
                          )
                      )
           THEN
               IF adjust_by = 'UPDATE'
               THEN
                  FOR l_prem IN related_prem (dtl_parent_id,
                                              dtl_tim_id,
                                              dtl_seqno,
                                              dtl_hours,
                                              g_det_session_date
                                             )
                  LOOP
                     IF l_prem.element_name = l_sdp_rule.element_name
                     THEN
                        -- Bug 7359347
                        -- Using base table instead of view as where clause
                        -- is on rowid.
                        /*
                        UPDATE hxt_det_hours_worked
                           SET hours = l_prem.prem_hours - deduct_premium,
                               time_out =
                                    time_in
                                  + ((l_prem.prem_hours - deduct_premium) / 24
                                    )
                         WHERE ROWID = l_prem.prem_row_id;
                         */
                        UPDATE hxt_det_hours_worked_f
                           SET hours = l_prem.prem_hours - deduct_premium,
                               time_out =
                                    time_in
                                  + ((l_prem.prem_hours - deduct_premium) / 24
                                    )
                         WHERE ROWID = l_prem.prem_row_id;

                        IF deduct_premium <> 0
                        THEN
                           sdp_adjusted(rowidtochar(l_prem.prem_row_id)) := dtl_parent_id;
                        END IF;
                     END IF;

                     prem_adjusted := TRUE;
                  END LOOP;
               ELSIF adjust_by = 'DELETE'
               THEN
                  FOR l_prem IN related_prem (dtl_parent_id,
                                              dtl_tim_id,
                                              dtl_seqno,
                                              dtl_hours,
                                              g_det_session_date
                                             )
                  LOOP
                     IF l_prem.element_name = l_sdp_rule.element_name
                     THEN
                        -- Bug 7359347
                        -- Changing view to base table as where clause
                        -- is on rowid.
                        /*
                        DELETE FROM hxt_det_hours_worked
                              WHERE ROWID = l_prem.prem_row_id;
                        */
                        DELETE FROM hxt_det_hours_worked_f
                              WHERE ROWID = l_prem.prem_row_id;
                          -- Bug 8279779
                          -- Added this condition.
                          IF deduct_premium <> 0
                          THEN
                             sdp_adjusted(rowidtochar(l_prem.prem_row_id)) := dtl_parent_id;
                          END IF;
                       END IF;
                       prem_adjusted := TRUE;
                    END LOOP;
                 END IF;
              END IF;
           END LOOP;
        END adjust_hours_for_premium;


        -- Bug 8279779
        -- Added this function to take care of time entries stretching SDPs
        -- to deduct HDP.


      PROCEDURE adj_stretch_sdp
      IS

         CURSOR get_sdf_prem_detail_time
         IS
            SELECT /*+ LEADING(shw) */
                   dhw.time_in,
                   dhw.time_out,
                   dhw.element_type_id,
                   dhw.parent_id,
                   ROWIDTOCHAR(dhw.rowid)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   hxt_det_hours_worked_f dhw
             WHERE g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
               AND eltv.element_type_id = dhw.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category = 'SDF'
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
             ORDER BY dhw.time_in;


       CURSOR get_valid_parent(p_id IN NUMBER)
           IS SELECT 1
                FROM hxt_sum_hours_worked_f
               WHERE id = p_id
                 AND g_det_session_date BETWEEN effective_start_date
                                            AND effective_end_date;


        CURSOR get_hdp_rules IS
           SELECT hours, time_period
               FROM hxt_hour_deduction_rules thdr
              WHERE thdr.hdp_id = g_hdp_id
                AND g_date_worked BETWEEN thdr.effective_start_date
                                      AND thdr.effective_end_date
                ORDER BY time_period desc;


           TYPE sdf_time_rec IS RECORD (
           time_in   DATE,
           time_out  DATE,
           element_type_id  NUMBER,
           parent_id  NUMBER,
           rowid    VARCHAR2(20));


           TYPE sdf_time_tab IS TABLE OF sdf_time_rec INDEX BY BINARY_INTEGER;
           sdf_time  sdf_time_tab;

           idx   BINARY_INTEGER;
           del   BINARY_INTEGER;
           nex   BINARY_INTEGER;
           rw    VARCHAR2(20);
           l_parent  NUMBER;
           deduct_hours  NUMBER(8,2);

        BEGIN
            if sdf_time.COUNT >0
            THEN
               sdf_time.DELETE;
            END IF;

            IF sdp_adjusted.COUNT > 0
            THEN
               rw := sdp_adjusted.FIRST;
               LOOP
                  IF sdp_adjusted(rw) = g_id
                  THEN
                     RETURN;
                  END IF;
                  rw := sdp_adjusted.NEXT(rw);
                  EXIT WHEN NOT sdp_adjusted.EXISTS(rw);
               END LOOP;
            END IF;

            -- Bug 8888600
            -- Modified the constructs below.
            OPEN get_sdf_prem_detail_time;
            FETCH get_sdf_prem_detail_time
             BULK COLLECT
                     INTO sdf_time;
            CLOSE get_sdf_prem_detail_time;

            IF g_debug
            THEN
                hr_utility.trace('G_id '||g_id);
            END IF;

            IF g_debug
            THEN
                idx := sdf_time.FIRST;
                IF IDX is not null then
                LOOP
                   hr_utility.trace('sdf_time beginning('||idx||').'
                                    ||to_char(sdf_time(idx).time_in,'HH-MI')||'-'
                                    ||to_char(sdf_time(idx).time_out,'HH-MI'));
                   idx := sdf_time.NEXT(idx);
                   EXIT WHEN idx IS NULL;
                END LOOP;
                END IF;
             END IF;

             IF sdf_time.COUNT > 0
             THEN

                -- Check if this is adjusted and delete from the table if adjusted.
                -- Combine contiguous entries
                idx := sdf_time.FIRST;
                IF idx IS NOT NULL THEN
                LOOP
                      IF sdf_time.EXISTS(sdf_time.NEXT(idx))
                      THEN
                         nex:= sdf_time.NEXT(idx);
                         IF g_debug
                         THEN
                             hr_utility.trace('sdf_time processin('||idx||').'
                                              ||to_char(sdf_time(idx).time_in,'HH-MI')||'-'
                                              ||to_char(sdf_time(idx).time_out,'HH-MI'));
                   	     hr_utility.trace('sdf_time processin('||idx||').'||sdf_time(idx).rowid);
                   	     hr_utility.trace(' : Nex is '||nex);
                   	     hr_utility.trace('sdf_time processin on('||nex||').'
                   	                      ||to_char(sdf_time(nex).time_in,'HH-MI')
                   	                      ||'-'||to_char(sdf_time(nex).time_out,'HH-MI'));
                   	     hr_utility.trace('sdf_time processin on('||nex||').'||sdf_time(nex).rowid);

                   	 END IF;

                         IF    sdf_time(nex).time_in = sdf_time(idx).time_out
                           AND sdf_time(nex).element_type_id = sdf_time(idx).element_type_id
                         THEN
                            sdf_time(nex).time_in := sdf_time(idx).time_in;
                            sdf_time.DELETE(idx);
                            idx := nex;
                            hr_utility.trace(': IDX is '||idx);
                         ELSE
                            idx := nex;
                         END IF;

                       ELSE
                          EXIT;
                       END IF;
                   EXIT WHEN idx IS NULL;
                END LOOP ;


                END IF;


                idx := sdf_time.FIRST;
                LOOP
                   IF sdf_time(idx).parent_id <> g_id
                   THEN
                      del := idx;
                      idx := sdf_time.NEXT(idx);
                      sdf_time.DELETE(del);
                   ELSE
                      idx := sdf_time.NEXT(idx);
                   END IF;
                   EXIT WHEN idx IS NULL;
                END LOOP;


                -- List the values out.
                IF g_debug
                THEN
                   idx := sdf_time.FIRST;
                   IF IDX is not null then
                   LOOP
                      hr_utility.trace('sdf_time processed('||idx||').'||to_char(sdf_time(idx).time_in,'HH-MI')
                                       ||'-'||to_char(sdf_time(idx).time_out,'HH-MI'));
                      hr_utility.trace('sdf_time processed('||idx||').'||sdf_time(idx).rowid);

                      idx := sdf_time.NEXT(idx);
                      EXIT WHEN idx IS NULL;
                   END LOOP;
                   END IF;
                END IF;

             END IF;


             -- Adjust for hdp rules
             FOR hdp_rules IN get_hdp_rules
             LOOP
                idx := sdf_time.FIRST;
                IF IDX is not null then
                LOOP
                   IF hdp_rules.time_period <= (sdf_time(idx).time_out-sdf_time(idx).time_in)*24
                   THEN
                      deduct_hours := FLOOR(((sdf_time(idx).time_out-sdf_time(idx).time_in)*24) /hdp_rules.time_period)
                                          *hdp_rules.hours;
                      hr_utility.trace('adj stretch '||deduct_hours||' for '||hdp_rules.time_period);
                      UPDATE hxt_det_hours_worked_f
                         SET time_out = time_out - (deduct_hours/24),
                                hours = hours    - deduct_hours
                       WHERE ROWID = CHARTOROWID(sdf_time(idx).rowid)
                         RETURNING rowid INTO rw;
                   END IF;
                   idx := sdf_time.NEXT(idx);
                   EXIT WHEN idx IS NULL;
                 END LOOP;
                 END IF;
             END LOOP;



        END adj_stretch_sdp;


--
---------------------------------------------------------------------------
--
      FUNCTION adjust_hours_for_hdp
         RETURN NUMBER
      IS

         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR current_dtl
         IS
            SELECT   dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                     dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_det_hours_worked dhw
               WHERE dhw.tim_id = g_tim_id
                 AND dhw.date_worked = g_date_worked
                 AND elt.element_type_id = dhw.element_type_id
                 AND dhw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND eltv.element_type_id = elt.element_type_id
                 AND dhw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
                 AND eltv.hxt_earning_category IN ('REG', 'OVT')
		 AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y' /* Bug: 4489952
            ORDER BY dhw.date_worked DESC,
                     dhw.time_in DESC,
                     dhw.seqno DESC,
                     dhw.parent_id DESC;

         CURSOR day_of_wk_prem_dtl
         IS
            SELECT   dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                     dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_det_hours_worked dhw
               WHERE dhw.tim_id = g_tim_id
                 AND dhw.parent_id = g_id
                 AND dhw.date_worked = g_date_worked
                 AND elt.element_type_id = dhw.element_type_id
                 AND dhw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND eltv.element_type_id = elt.element_type_id
                 AND elt.element_type_id = g_osp_id
                 AND dhw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
                 AND eltv.hxt_earning_category = 'OSP'
                 AND eltv.hxt_premium_type <> 'FIXED'
		 AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y' /* Bug: 4489952
            ORDER BY dhw.date_worked DESC,
                     dhw.time_in DESC,
                     dhw.seqno DESC,
                     dhw.parent_id DESC;

         CURSOR oth_prem_dtl -- Bug 5447600
         IS
           SELECT dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                    dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
            FROM hxt_pay_element_types_f_ddf_v eltv,
                  pay_element_types_f elt,
                  hxt_det_hours_worked dhw
            WHERE dhw.parent_id = g_id
              AND dhw.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND eltv.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN eltv.effective_start_date
                                      AND eltv.effective_end_date
              AND eltv.hxt_earning_category = 'OTH'
              AND eltv.hxt_premium_type <> 'FIXED'
              AND dhw.tim_id = g_tim_id
              AND dhw.date_worked = g_date_worked
	      AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y' /* Bug: 4489952
           ORDER BY dhw.date_worked DESC,
                    dhw.time_in DESC,
                    dhw.seqno DESC,
                    dhw.parent_id DESC;

         CURSOR sdf_prem_detail_hours
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked dhw,
                   hxt_sum_hours_worked shw
             WHERE shw.ID = g_id
               AND shw.ID = dhw.parent_id
               AND shw.element_type_id IS NULL
               AND dhw.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category = 'SDF'
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
	       AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952

         CURSOR oth_prem_detail_hours -- Bug 5447600
         IS
           SELECT NVL (SUM (dhw.hours), 0) det_hours
            FROM hxt_pay_element_types_f_ddf_v eltv,
                  pay_element_types_f elt,
                  hxt_det_hours_worked dhw,
                  hxt_sum_hours_worked shw
            WHERE shw.ID = g_id
              AND shw.ID = dhw.parent_id
              AND shw.element_type_id IS NULL
              AND dhw.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND eltv.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN eltv.effective_start_date
                                      AND eltv.effective_end_date
              AND eltv.hxt_earning_category = 'OTH'
              AND dhw.tim_id = g_tim_id
              AND dhw.date_worked = g_date_worked
	      AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952

         CURSOR hdp_rule_cursor
         IS
            SELECT hours, time_period
              FROM hxt_hour_deduction_rules thdr
             WHERE thdr.hdp_id = g_hdp_id
               AND g_date_worked BETWEEN thdr.effective_start_date
                                     AND thdr.effective_end_date;

         CURSOR detail_hours_today
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked dhw,
                   hxt_sum_hours_worked shw
             WHERE shw.ID = g_id
               AND shw.ID = dhw.parent_id
               AND shw.element_type_id IS NULL
               AND dhw.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category IN ('REG', 'OVT')
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
	       AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952

         CURSOR detail_hours_incl_prev_rows
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked dhw,
                   hxt_sum_hours_worked shw                    --<-- New Table
             WHERE elt.element_type_id = dhw.element_type_id
               AND shw.ID = dhw.parent_id                       --<-- New Join
               AND shw.element_type_id IS NULL
               --<-- New check: No Hours Override
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category IN ('REG', 'OVT')
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
	       AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952

         CURSOR get_sum_hrs
         IS
            SELECT NVL (SUM (shw.hours), 0) sum_hours,
	           COUNT(*) sum_count   /*** 4969936 **
              FROM hxt_sum_hours_worked shw
             WHERE tim_id = g_tim_id AND shw.date_worked = g_date_worked
	     AND not exists ( SELECT 'X'    /* Bug: 4489952 *
                               FROM  hxt_add_elem_info_f hei, hxt_det_hours_worked dhw
                              WHERE  hei.element_type_id = dhw.element_type_id
                                AND  nvl(hei.exclude_from_explosion, 'N') = 'Y'
				AND  dhw.parent_id = shw.id
				AND  g_date_worked BETWEEN hei.effective_start_date
                                                       AND hei.effective_end_date);

         CURSOR get_sum_time_out
         IS
            SELECT hours, time_in, time_out
              FROM hxt_sum_hours_worked shw
             WHERE ID = g_id
	     AND not exists ( SELECT 'X'   /* Bug: 4489952 *
                               FROM  hxt_add_elem_info_f hei, hxt_det_hours_worked dhw
                              WHERE  hei.element_type_id = dhw.element_type_id
                                AND  nvl(hei.exclude_from_explosion, 'N') = 'Y'
				AND  dhw.parent_id = shw.id
				AND  g_date_worked BETWEEN hei.effective_start_date
                                                       AND hei.effective_end_date);

         CURSOR csr_work_hrs (
            p_date_worked   hxt_sum_hours_worked_f.date_worked%TYPE,
            p_tim_id        hxt_sum_hours_worked_f.tim_id%TYPE
         )
         IS
            SELECT   shw.ID, shw.hours, shw.time_in, shw.time_out
                FROM hxt_sum_hours_worked shw
               WHERE shw.tim_id = p_tim_id
                 AND shw.date_worked = p_date_worked
                 AND ((    shw.time_in IS NOT NULL
                       AND shw.time_out IS NOT NULL
                       AND shw.time_in <> shw.time_out
                      )
                     )
		 AND not exists ( SELECT 'X'  /* Bug: 4489952 *
                                  FROM   hxt_add_elem_info_f hei, hxt_det_hours_worked dhw
                                  WHERE  hei.element_type_id = dhw.element_type_id
                                  AND    nvl(hei.exclude_from_explosion, 'N') = 'Y'
				  AND    dhw.parent_id = shw.id
				  AND    g_date_worked BETWEEN hei.effective_start_date
                                                           AND hei.effective_end_date)
            ORDER BY shw.date_worked,
                     shw.element_type_id,
                     shw.time_in,
                     shw.seqno,
                     shw.ID;

*/

         -- Bug 8534160
         -- Added hxt_sum_hours_worked_f and associated conditions
         -- so that Override elements would not be affected.

         CURSOR current_dtl
         IS
            SELECT   dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                     dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_det_hours_worked_f dhw,
                     hxt_sum_hours_worked_f shw
               WHERE dhw.tim_id = g_tim_id
                 AND dhw.date_worked = g_date_worked
                 AND shw.id = dhw.parent_id
                 AND shw.element_type_id IS NULL
                 AND g_det_session_date BETWEEN shw.effective_start_date
                                            AND shw.effective_end_date
                 AND g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
                 AND elt.element_type_id = dhw.element_type_id
                 AND dhw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND eltv.element_type_id = elt.element_type_id
                 AND dhw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
                 AND eltv.hxt_earning_category IN ('REG', 'OVT')
		 AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y' /* Bug: 4489952 */
            ORDER BY dhw.date_worked DESC,
                     dhw.time_in DESC,
                     dhw.seqno DESC,
                     dhw.parent_id DESC;

         CURSOR day_of_wk_prem_dtl
         IS
            SELECT   dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                     dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_det_hours_worked_f dhw
               WHERE dhw.tim_id = g_tim_id
                 AND dhw.parent_id = g_id
                 AND dhw.date_worked = g_date_worked
                 AND g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
                 AND elt.element_type_id = dhw.element_type_id
                 AND dhw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND eltv.element_type_id = elt.element_type_id
                 AND elt.element_type_id = g_osp_id
                 AND dhw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
                 AND eltv.hxt_earning_category = 'OSP'
                 AND eltv.hxt_premium_type <> 'FIXED'
		 AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y' /* Bug: 4489952 */
            ORDER BY dhw.date_worked DESC,
                     dhw.time_in DESC,
                     dhw.seqno DESC,
                     dhw.parent_id DESC;

         CURSOR oth_prem_dtl -- Bug 5447600
         IS
           SELECT dhw.ROWID dhw_rowid, dhw.parent_id, dhw.tim_id,
                    dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno
            FROM hxt_pay_element_types_f_ddf_v eltv,
                  pay_element_types_f elt,
                  hxt_det_hours_worked_f dhw
            WHERE dhw.parent_id = g_id
              AND dhw.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND g_det_session_date BETWEEN dhw.effective_start_date
                                         AND dhw.effective_end_date
              AND eltv.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN eltv.effective_start_date
                                      AND eltv.effective_end_date
              AND eltv.hxt_earning_category = 'OTH'
              AND eltv.hxt_premium_type <> 'FIXED'
              AND dhw.tim_id = g_tim_id
              AND dhw.date_worked = g_date_worked
	      AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y' /* Bug: 4489952 */
           ORDER BY dhw.date_worked DESC,
                    dhw.time_in DESC,
                    dhw.seqno DESC,
                    dhw.parent_id DESC;

         CURSOR sdf_prem_detail_hours
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked_f dhw,
                   hxt_sum_hours_worked_f shw
             WHERE shw.ID = g_id
               AND shw.ID = dhw.parent_id
               AND shw.element_type_id IS NULL
               AND dhw.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
                 AND g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
                 AND g_det_session_date BETWEEN shw.effective_start_date
                                            AND shw.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category = 'SDF'
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
	       AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */

         CURSOR oth_prem_detail_hours -- Bug 5447600
         IS
           SELECT NVL (SUM (dhw.hours), 0) det_hours
            FROM hxt_pay_element_types_f_ddf_v eltv,
                  pay_element_types_f elt,
                  hxt_det_hours_worked_f dhw,
                  hxt_sum_hours_worked_f shw
            WHERE shw.ID = g_id
              AND shw.ID = dhw.parent_id
              AND shw.element_type_id IS NULL
              AND dhw.element_type_id = elt.element_type_id
                 AND g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
                 AND g_det_session_date BETWEEN shw.effective_start_date
                                            AND shw.effective_end_date
              AND dhw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND eltv.element_type_id = elt.element_type_id
              AND dhw.date_worked BETWEEN eltv.effective_start_date
                                      AND eltv.effective_end_date
              AND eltv.hxt_earning_category = 'OTH'
              AND dhw.tim_id = g_tim_id
              AND dhw.date_worked = g_date_worked
	      AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */

         CURSOR hdp_rule_cursor
         IS
            SELECT hours, time_period
              FROM hxt_hour_deduction_rules thdr
             WHERE thdr.hdp_id = g_hdp_id
               AND g_date_worked BETWEEN thdr.effective_start_date
                                     AND thdr.effective_end_date;

         CURSOR detail_hours_today
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked_f dhw,
                   hxt_sum_hours_worked_f shw
             WHERE shw.ID = g_id
               AND shw.ID = dhw.parent_id
               AND shw.element_type_id IS NULL
               AND dhw.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
                 AND g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
                 AND g_det_session_date BETWEEN shw.effective_start_date
                                            AND shw.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category IN ('REG', 'OVT')
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
	       AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */

         CURSOR detail_hours_incl_prev_rows
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked_f dhw,
                   hxt_sum_hours_worked_f shw                    --<-- New Table
             WHERE elt.element_type_id = dhw.element_type_id
               AND shw.ID = dhw.parent_id                       --<-- New Join
               AND shw.element_type_id IS NULL
               --<-- New check: No Hours Override
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
                 AND g_det_session_date BETWEEN dhw.effective_start_date
                                            AND dhw.effective_end_date
                 AND g_det_session_date BETWEEN shw.effective_start_date
                                            AND shw.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category IN ('REG', 'OVT')
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked
	       AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */

         CURSOR get_sum_hrs
         IS
            SELECT NVL (SUM (shw.hours), 0) sum_hours,
	           COUNT(*) sum_count   /*** 4969936 ***/
              FROM hxt_sum_hours_worked_f shw
             WHERE tim_id = g_tim_id
	     AND not exists ( SELECT 'X'    /* Bug: 4489952 */
                               FROM  hxt_add_elem_info_f hei, hxt_det_hours_worked dhw
                              WHERE  hei.element_type_id = dhw.element_type_id
                                AND  nvl(hei.exclude_from_explosion, 'N') = 'Y'
				AND  dhw.parent_id = shw.id
				AND  g_date_worked BETWEEN hei.effective_start_date
                                                       AND hei.effective_end_date)
             AND g_det_session_date BETWEEN shw.effective_start_date
                                            AND shw.effective_end_date

             AND shw.date_worked = g_date_worked;

         CURSOR get_sum_time_out
         IS
            SELECT hours, time_in, time_out
              FROM hxt_sum_hours_worked shw
             WHERE ID = g_id
	     AND not exists ( SELECT 'X'   /* Bug: 4489952 */
                               FROM  hxt_add_elem_info_f hei, hxt_det_hours_worked dhw
                              WHERE  hei.element_type_id = dhw.element_type_id
                                AND  nvl(hei.exclude_from_explosion, 'N') = 'Y'
				AND  dhw.parent_id = shw.id
				AND  g_date_worked BETWEEN hei.effective_start_date
                                                       AND hei.effective_end_date);

         CURSOR csr_work_hrs (
            p_date_worked   hxt_sum_hours_worked_f.date_worked%TYPE,
            p_tim_id        hxt_sum_hours_worked_f.tim_id%TYPE
         )
         IS
            SELECT   shw.ID, shw.hours, shw.time_in, shw.time_out
                FROM hxt_sum_hours_worked_f shw
               WHERE shw.tim_id = p_tim_id
                 AND shw.date_worked = p_date_worked
                     AND g_det_session_date BETWEEN shw.effective_start_date
		                                AND shw.effective_end_date
                 AND ((    shw.time_in IS NOT NULL
                       AND shw.time_out IS NOT NULL
                       AND shw.time_in <> shw.time_out
                      )
                     )
		 AND not exists ( SELECT 'X'  /* Bug: 4489952 */
                                  FROM   hxt_add_elem_info_f hei, hxt_det_hours_worked dhw
                                  WHERE  hei.element_type_id = dhw.element_type_id
                                  AND    nvl(hei.exclude_from_explosion, 'N') = 'Y'
				  AND    dhw.parent_id = shw.id
				  AND    g_date_worked BETWEEN hei.effective_start_date
                                                           AND hei.effective_end_date)
            ORDER BY shw.date_worked,
                     shw.element_type_id,
                     shw.time_in,
                     shw.seqno,
                     shw.ID;




         CURSOR hdp_hours_deducted_today
         IS
            SELECT (NVL (sum_hours, 0) - NVL (det_hours, 0))
              FROM hxt_hdp_sum_hours_worked_v shw,
                   hxt_hdp_det_hours_worked_v dhw
             WHERE dhw.det_date = g_date_worked
               AND dhw.det_tim_id = g_tim_id
               AND shw.sum_date = dhw.det_date
               AND shw.sum_tim_id = dhw.det_tim_id;

	 --Bug 4969936 Fix Start

	 CURSOR hdp_rules
         IS
            SELECT SUM(thdr.time_period) time_period,
                   COUNT(*) hdp_count
            FROM   hxt_hour_deduction_rules thdr
            WHERE  thdr.hdp_id = g_hdp_id
            AND    g_date_worked BETWEEN thdr.effective_start_date
                                     AND thdr.effective_end_date;

         sum_row_count         NUMBER                := 0;
         hdp_hrs               NUMBER                := 0;
         hdp_time_period       NUMBER                := 0;
         hdp_row_count         NUMBER                := 0;

	 --Bug 4969936 Fix End

         loop_count            NUMBER                := 0;
         hrs_deducted_today    NUMBER                := 0;
         sum_hours             NUMBER                := 0;
         sum_time_out          DATE                  := NULL;
         sum_time_in           DATE                  := NULL;
         hours_paid_today      NUMBER                := 0;
         sdf_prem_hours_paid   NUMBER                := 0;
	 oth_prem_hours_paid   NUMBER                := 0;
         detail_hrs_total      NUMBER                := 0;
         sum_hrs_total         NUMBER                := 0;
         deduct_hours          NUMBER                := 0;
         test_hours            NUMBER                := 0;
         deduct_prem_hours     NUMBER                := 0;
         current_dtl_row       current_dtl%ROWTYPE;
         l_prem_adjusted       BOOLEAN               := FALSE;
         l_proc                VARCHAR2 (250)
                                     := 'hxt_time_detail.adjust_hours_for_hdp';
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 10);
         END IF;

         -- Bug 7359347
         -- Setting session date
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         -- Bug 8888600
         sdp_adjusted.DELETE;

         IF g_hdp_id IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 20);
            END IF;

            RETURN (0);
         END IF;

         OPEN get_sum_time_out;

         FETCH get_sum_time_out
          INTO sum_hours, sum_time_in, sum_time_out;

         IF g_debug
         THEN
            hr_utility.TRACE (   'sum_time_in:'
                              || TO_CHAR (sum_time_in,
                                          'dd-mon-yyyy hh24:mi:ss'
                                         )
                             );
            hr_utility.TRACE (   'sum_time_out:'
                              || TO_CHAR (sum_time_out,
                                          'dd-mon-yyyy hh24:mi:ss'
                                         )
                             );
            hr_utility.TRACE (   'g_time_out:'
                              || TO_CHAR (g_time_out,
                                          'dd-mon-yyyy hh24:mi:ss')
                             );
         END IF;

         CLOSE get_sum_time_out;

         IF sum_time_out IS NOT NULL AND g_time_out IS NOT NULL
         THEN
            IF g_time_out < sum_time_out
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 30);
               END IF;

               RETURN (0);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE (   'g_time_out:'
                              || TO_CHAR (g_time_out,
                                          'dd-mon-yyyy hh24:mi:ss')
                             );
            hr_utility.TRACE ('g_tim_id:' || g_tim_id);
         END IF;

         -- Check for contiguity when time entered in Hours
         IF sum_time_in IS NULL AND sum_time_out IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 31);
            END IF;

            OPEN detail_hours_incl_prev_rows;

            FETCH detail_hours_incl_prev_rows
             INTO detail_hrs_total;

            IF g_debug
            THEN
               hr_utility.TRACE ('detail_hrs_total:' || detail_hrs_total);
            END IF;

            CLOSE detail_hours_incl_prev_rows;

            OPEN get_sum_hrs;

            FETCH get_sum_hrs
             INTO sum_hrs_total, sum_row_count;

            IF g_debug
            THEN
               hr_utility.TRACE ('sum_hrs_total:' || sum_hrs_total);
            END IF;

            CLOSE get_sum_hrs;

	    --Bug 4969936 Fix Start
            OPEN hdp_rules;
            FETCH hdp_rules
             INTO hdp_time_period, hdp_row_count;
            CLOSE hdp_rules;
	    --Bug 4969936 Fix End

            IF (detail_hrs_total = sum_hrs_total)
	           OR (hdp_row_count = 1 AND sum_hrs_total = hdp_time_period * sum_row_count) /*** 4969936 ***/
            THEN
               -- Time for the day entered in multiple rows are contiguous
               -- i.e., nothing got deducted form the previous row based on the hour
               -- deduction policy as the hours entered on the previous row were not
               -- enough to apply the HDP
               -- So apply hour deduction policy considering both the rows and see
               -- if the summed up hours are eligible for any deduction.
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 32);
               END IF;

               OPEN detail_hours_incl_prev_rows;

               FETCH detail_hours_incl_prev_rows
                INTO hours_paid_today;

               IF g_debug
               THEN
                  hr_utility.TRACE ('hours_paid_today:' || hours_paid_today);
               END IF;

               CLOSE detail_hours_incl_prev_rows;
/* v115.103 - M. Bhammar
            ELSE
               -- Time entered on multiple rows are not contiguous in the sense that
               -- hour deduction policy has already been applied on the first row
               -- entered for the day. So, consider just the hours entered on the
               -- current row being processed and see if any hours can be deducted
               -- from this row based on the hour deduction policy.
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 33);
               END IF;

               OPEN detail_hours_today;

               FETCH detail_hours_today
                INTO hours_paid_today;

               IF g_debug
               THEN
                  hr_utility.TRACE ('hours_paid_today:' || hours_paid_today);
               END IF;

               CLOSE detail_hours_today;
*/
            END IF;
         -- Check for contiguous entry when Time entered in TIME_IN/TIME_OUT
         ELSIF sum_time_in IS NOT NULL AND sum_time_out IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 35);
            END IF;

            FOR rec_work_hrs IN csr_work_hrs (g_date_worked, g_tim_id)
            LOOP
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 40);
               END IF;

               loop_count := loop_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('loop_count:' || loop_count);
                  hr_utility.TRACE (   'sum_time_in:'
                                    || TO_CHAR (sum_time_in,
                                                'dd-mon-yyyy hh24:mi:ss'
                                               )
                                   );
                  hr_utility.TRACE (   'sum_time_out:'
                                    || TO_CHAR (sum_time_out,
                                                'dd-mon-yyyy hh24:mi:ss'
                                               )
                                   );
                  hr_utility.TRACE (   'rec_work_hrs.time_out:'
                                    || TO_CHAR (rec_work_hrs.time_out,
                                                'dd-mon-yyyy hh24:mi:ss'
                                               )
                                   );
                  hr_utility.TRACE ('rec_work_hrs.id:' || rec_work_hrs.ID);
                  hr_utility.TRACE ('g_id:' || g_id);
               END IF;

               -- Check whether the Time entered on two rows is contiguous or not
               IF     sum_time_in <> sum_time_out
                  AND sum_time_in = rec_work_hrs.time_out
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 50);
                  END IF;

                  OPEN hdp_hours_deducted_today;

                  FETCH hdp_hours_deducted_today
                   INTO hrs_deducted_today;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hrs_deducted_today :'
                                       || hrs_deducted_today
                                      );
                  END IF;

                  CLOSE hdp_hours_deducted_today;

                  OPEN detail_hours_incl_prev_rows;

                  FETCH detail_hours_incl_prev_rows
                   INTO detail_hrs_total;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('detail_hrs_total:' || detail_hrs_total
                                      );
                  END IF;

                  CLOSE detail_hours_incl_prev_rows;

                  hours_paid_today := detail_hrs_total + hrs_deducted_today;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('hours_paid_today:' || hours_paid_today
                                      );
                  END IF;

                  EXIT;
               ELSIF loop_count = 1 AND g_id = rec_work_hrs.ID
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 51);
                  END IF;

                  OPEN detail_hours_incl_prev_rows;

                  FETCH detail_hours_incl_prev_rows
                   INTO hours_paid_today;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('hours_paid_today:' || hours_paid_today
                                      );
                  END IF;

                  CLOSE detail_hours_incl_prev_rows;

                  EXIT;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 52);
                  END IF;

                  OPEN detail_hours_today;

                  FETCH detail_hours_today
                   INTO hours_paid_today;

                  CLOSE detail_hours_today;
--                hours_paid_today := 0;
               END IF;
            END LOOP;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 53);
         END IF;

         FOR hdp_rule IN hdp_rule_cursor
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 54);
            END IF;

            IF g_debug
            THEN
               hr_utility.TRACE ('deduct_hours:' || deduct_hours);
               hr_utility.TRACE ('hours_paid_today:' || hours_paid_today);
               hr_utility.TRACE (   'hdp_rule.time_period:'
                                 || hdp_rule.time_period
                                );
               hr_utility.TRACE ('hdp_rule.hours:' || hdp_rule.hours);
            END IF;

            deduct_hours :=
                 deduct_hours
               + (  FLOOR (hours_paid_today / hdp_rule.time_period)
                  * hdp_rule.hours
                 );

            IF g_debug
            THEN
               hr_utility.TRACE ('deduct_hours:' || deduct_hours);
            END IF;

	    /* Moved the following statement outside the cursor loop for bug: 5481772 */
            -- deduct_hours := deduct_hours - hrs_deducted_today;

            IF g_debug
            THEN
               hr_utility.TRACE ('deduct_hours:' || deduct_hours);
            END IF;
         END LOOP;

         deduct_hours := deduct_hours - hrs_deducted_today;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 55);
         END IF;

         -- deduct_prem_hours := deduct_hours;
         OPEN sdf_prem_detail_hours;

         FETCH sdf_prem_detail_hours
          INTO sdf_prem_hours_paid;

         IF g_debug
         THEN
            hr_utility.TRACE ('sdf_prem_hours_paid:' || sdf_prem_hours_paid);
         END IF;

         CLOSE sdf_prem_detail_hours;

         OPEN oth_prem_detail_hours;

         FETCH oth_prem_detail_hours
          INTO oth_prem_hours_paid;

         CLOSE oth_prem_detail_hours;

         IF g_debug
         THEN
            hr_utility.TRACE ('oth_prem_hours_paid' || oth_prem_hours_paid);
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('deduct_prem_hours:' || deduct_prem_hours);
            hr_utility.TRACE ('sdf_prem_hours_paid:' || sdf_prem_hours_paid);
         END IF;

         FOR hdp_rule IN hdp_rule_cursor
         LOOP
            deduct_prem_hours :=
                 deduct_prem_hours
               + (  FLOOR (sdf_prem_hours_paid / hdp_rule.time_period)
                  * hdp_rule.hours
                 );

            IF g_debug
            THEN
               hr_utility.TRACE ('deduct_prem_hours:' || deduct_prem_hours);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 60);
         END IF;

         FOR current_dtl_row IN current_dtl
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 70);
            END IF;

            EXIT WHEN deduct_hours = 0 AND l_prem_adjusted = TRUE;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 80);
            END IF;

            IF deduct_hours = 0 AND l_prem_adjusted = FALSE
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 90);
               END IF;

               -- We just need to adjust the premium hrs and not the
               -- REG or OT detail rows
               adjust_hours_for_premium (current_dtl_row.parent_id,
                                         current_dtl_row.tim_id,
                                         current_dtl_row.seqno,
                                         current_dtl_row.hours,
                                         sum_time_in,
                                         sum_time_out,
                                         deduct_prem_hours,
                                         'UPDATE',
                                         l_prem_adjusted
                                        );
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 100);
            END IF;

            IF deduct_hours <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 110);
               END IF;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'current_dtl_row.hours:'
                                    || current_dtl_row.hours
                                   );
                  hr_utility.TRACE ('deduct_hours:' || deduct_hours);
               END IF;

               IF current_dtl_row.hours <= deduct_hours
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 120);
                  END IF;

                  adjust_hours_for_premium (current_dtl_row.parent_id,
                                            current_dtl_row.tim_id,
                                            current_dtl_row.seqno,
                                            current_dtl_row.hours,
                                            sum_time_in,
                                            sum_time_out,
                                            deduct_hours,
                                            'DELETE',
                                            l_prem_adjusted
                                           );

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('g_osp_id:' || g_osp_id);
                  END IF;

                  IF g_osp_id IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 130);
                     END IF;

                     FOR osp_dtl_row IN day_of_wk_prem_dtl
                     LOOP
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 140);
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'osp_dtl_row.hours:'
                                             || osp_dtl_row.hours
                                            );
                           hr_utility.TRACE ('deduct_hours:' || deduct_hours);
                        END IF;

                        -- Bug 7359347
                        -- changing view to table as WHERE clause is on rowid.
                        /*
                        UPDATE hxt_det_hours_worked
                           SET hours = osp_dtl_row.hours - deduct_hours,
                               time_out =
                                    time_in
                                  + ((osp_dtl_row.hours - deduct_hours) / 24
                                    )
                         WHERE ROWID = osp_dtl_row.dhw_rowid;
                         */
                        UPDATE hxt_det_hours_worked_f
                           SET hours = osp_dtl_row.hours - deduct_hours,
                               time_out =
                                    time_in
                                  + ((osp_dtl_row.hours - deduct_hours) / 24
                                    )
                         WHERE ROWID = osp_dtl_row.dhw_rowid;

                     END LOOP;
                  END IF;

		  IF oth_prem_hours_paid <> 0
		  THEN

		     IF g_debug
                     THEN
                          hr_utility.set_location (l_proc, 140.1);
                     END IF;

                     FOR oth_dtl_row IN oth_prem_dtl
                     LOOP

                          IF g_debug
                          THEN
                               hr_utility.set_location (l_proc, 140.2);
                          END IF;

                          IF g_debug
                          THEN
                               hr_utility.TRACE ('oth_prem_dtl.hours:' || oth_dtl_row.hours);
                               hr_utility.TRACE ('deduct_hours:' || deduct_hours);
                          END IF;

                          -- Bug 7359347
                          -- changing view to table as where clause is on rowid
                          /*
                          UPDATE hxt_det_hours_worked
                          SET hours = oth_dtl_row.hours - deduct_hours,
                               time_out = time_in
                               + ((oth_dtl_row.hours - deduct_hours) / 24)
                          WHERE ROWID = oth_dtl_row.dhw_rowid;
                          */
                          UPDATE hxt_det_hours_worked_f
                          SET hours = oth_dtl_row.hours - deduct_hours,
                               time_out = time_in
                               + ((oth_dtl_row.hours - deduct_hours) / 24)
                          WHERE ROWID = oth_dtl_row.dhw_rowid;


                     END LOOP;
                  END IF;

                  -- Bug 7359347
                  -- changing view to table.
                  /*
                  DELETE FROM hxt_det_hours_worked
                        WHERE ROWID = current_dtl_row.dhw_rowid;
                  */
                  DELETE FROM hxt_det_hours_worked_f
                        WHERE ROWID = current_dtl_row.dhw_rowid;


                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'current_dtl_row.hours:'
                                       || current_dtl_row.hours
                                      );
                  END IF;

                  deduct_hours := deduct_hours - current_dtl_row.hours;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('deduct_hours:' || deduct_hours);
                  END IF;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 150);
                  END IF;

                  IF l_prem_adjusted = TRUE
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 160);
                     END IF;

                     adjust_hours_for_premium (current_dtl_row.parent_id,
                                               current_dtl_row.tim_id,
                                               current_dtl_row.seqno,
                                               current_dtl_row.hours,
                                               sum_time_in,
                                               sum_time_out,
                                               deduct_hours,
                                               'UPDATE',
                                               l_prem_adjusted
                                              );
                  ELSIF l_prem_adjusted = FALSE
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 170);
                     END IF;

                     adjust_hours_for_premium (current_dtl_row.parent_id,
                                               current_dtl_row.tim_id,
                                               current_dtl_row.seqno,
                                               current_dtl_row.hours,
                                               sum_time_in,
                                               sum_time_out,
                                               deduct_prem_hours,
                                               'UPDATE',
                                               l_prem_adjusted
                                              );
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 180);
                  END IF;

                  IF g_osp_id IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 190);
                        hr_utility.TRACE ('g_tim_id :' || g_tim_id);
                        hr_utility.TRACE ('g_id :' || g_id);
                        hr_utility.TRACE ('g_osp_id :' || g_osp_id);
                        hr_utility.TRACE ('g_date_worked :' || g_date_worked);
                     END IF;

                     FOR osp_dtl_row IN day_of_wk_prem_dtl
                     LOOP
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 200);
                           hr_utility.TRACE ('deduct_hours :' || deduct_hours);
                        END IF;

                        -- Bug 7359347
                        -- changing view to table.
                        /*
                        UPDATE hxt_det_hours_worked
                           SET hours = osp_dtl_row.hours - deduct_hours,
                               time_out =
                                    time_in
                                  + ((osp_dtl_row.hours - deduct_hours) / 24
                                    )
                         WHERE ROWID = osp_dtl_row.dhw_rowid;
                        */
                        UPDATE hxt_det_hours_worked_f
                           SET hours = osp_dtl_row.hours - deduct_hours,
                               time_out =
                                    time_in
                                  + ((osp_dtl_row.hours - deduct_hours) / 24
                                    )
                         WHERE ROWID = osp_dtl_row.dhw_rowid;

                        /*
                        SELECT hours
                          INTO test_hours
                          FROM hxt_det_hours_worked
                         WHERE ROWID = osp_dtl_row.dhw_rowid;
                        */
                        SELECT hours
                          INTO test_hours
                          FROM hxt_det_hours_worked_f
                         WHERE ROWID = osp_dtl_row.dhw_rowid;


                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 200.5);
                           hr_utility.TRACE ('test_hours :' || test_hours);
                        END IF;
                     END LOOP;
                  END IF;

		  IF oth_prem_hours_paid <> 0
		  THEN

		     IF g_debug
                     THEN
                          hr_utility.set_location (l_proc, 200.6);
                     END IF;

                     FOR oth_dtl_row IN oth_prem_dtl
                     LOOP

                          IF g_debug
                          THEN
                               hr_utility.set_location (l_proc, 200.7);
                          END IF;

                          IF g_debug
                          THEN
                               hr_utility.TRACE ('oth_prem_dtl.hours:' || oth_dtl_row.hours);
                               hr_utility.TRACE ('deduct_hours:' || deduct_hours);
                          END IF;

                          -- Bug 7359347
                          -- changing view to table.
                          /*
                          UPDATE hxt_det_hours_worked
                          SET hours = oth_dtl_row.hours - deduct_hours,
                               time_out = time_in
                               + ((oth_dtl_row.hours - deduct_hours) / 24)
                          WHERE ROWID = oth_dtl_row.dhw_rowid;
                          */
                          UPDATE hxt_det_hours_worked_f
                          SET hours = oth_dtl_row.hours - deduct_hours,
                               time_out = time_in
                               + ((oth_dtl_row.hours - deduct_hours) / 24)
                          WHERE ROWID = oth_dtl_row.dhw_rowid;


                     END LOOP;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 210);
                  END IF;

                  -- Bug 7359347
                  -- changing view to table.
                  /*
                  UPDATE hxt_det_hours_worked
                     SET hours = current_dtl_row.hours - deduct_hours,
                         time_out =
                              time_in
                            + ((current_dtl_row.hours - deduct_hours) / 24)
                   WHERE ROWID = current_dtl_row.dhw_rowid;
                  */
                  UPDATE hxt_det_hours_worked_f
                     SET hours = current_dtl_row.hours - deduct_hours,
                         time_out =
                              time_in
                            + ((current_dtl_row.hours - deduct_hours) / 24)
                   WHERE ROWID = current_dtl_row.dhw_rowid;


                  deduct_hours := 0;
               END IF;
            END IF;
         END LOOP;

         -- Bug 8279779
         -- Added this call to take care of time entries stretching SDP
         -- window for deducting HDP.
         adj_stretch_sdp;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 220);
         END IF;

         RETURN (0);
      END adjust_hours_for_hdp;

--
--------------------------------------------------------------------------------
--
      FUNCTION adjust_for_hdp (
         p_hours_this_segment   IN              NUMBER,
         p_error_code           IN OUT NOCOPY   NUMBER
      )
         RETURN NUMBER
      IS
--  Returns the hours to be paid this segment after subtracting any applicable
--  hours from the hour deduction policy.
         CURSOR hdp_rule_cursor
         IS
            SELECT hours, time_period
              FROM hxt_hour_deduction_rules thdr
             WHERE thdr.hdp_id = g_hdp_id
               AND g_date_worked BETWEEN thdr.effective_start_date
                                     AND thdr.effective_end_date;

         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR detail_hours_today
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked dhw,
                   hxt_sum_hours_worked shw                    --<-- New Table
             WHERE elt.element_type_id = dhw.element_type_id
               AND shw.ID = dhw.parent_id                       --<-- New Join
               AND shw.element_type_id IS NULL
               --<-- New check: No Hours Override
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category IN ('REG', 'OVT')
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked;

            */

         CURSOR detail_hours_today
         IS
            SELECT NVL (SUM (dhw.hours), 0) det_hours
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt,
                   hxt_det_hours_worked_f dhw,
                   hxt_sum_hours_worked_f shw                    --<-- New Table
             WHERE elt.element_type_id = dhw.element_type_id
               AND shw.ID = dhw.parent_id                       --<-- New Join
               AND shw.element_type_id IS NULL
               --<-- New check: No Hours Override
               AND g_det_session_date   BETWEEN dhw.effective_start_date
                                      AND dhw.effective_end_date
               AND g_det_session_date   BETWEEN shw.effective_start_date
                                      AND shw.effective_end_date
               AND dhw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND eltv.element_type_id = elt.element_type_id
               AND dhw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category IN ('REG', 'OVT')
               AND dhw.tim_id = g_tim_id
               AND dhw.date_worked = g_date_worked;


         CURSOR hdp_hours_deducted_today
         IS
            SELECT (NVL (sum_hours, 0) - NVL (det_hours, 0))
              FROM hxt_hdp_sum_hours_worked_v shw,
                   hxt_hdp_det_hours_worked_v dhw
             WHERE dhw.det_date = g_date_worked
               AND dhw.det_tim_id = g_tim_id
               AND shw.sum_date = dhw.det_date
               AND shw.sum_tim_id = dhw.det_tim_id;

         CURSOR get_sum_time_out
         IS
            SELECT time_in, time_out
              FROM hxt_sum_hours_worked_f
             WHERE ID = g_id
               AND g_det_session_date   BETWEEN effective_start_date
                                            AND effective_end_date
;

         addback_hours        NUMBER         := 0;
         deduct_hours         NUMBER         := 0;
         daily_total_hours    NUMBER;
         hours_paid_already   NUMBER         := 0;
         sum_time_out         DATE           := NULL;
         sum_time_in          DATE           := NULL;
         l_proc               VARCHAR2 (250);
      BEGIN
         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.adjust_for_hdp';
            hr_utility.set_location (l_proc, 10);
            hr_utility.TRACE ('g_hdp_id :' || g_hdp_id);
         END IF;

         IF g_hdp_id IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 20);
            END IF;

            RETURN (p_hours_this_segment);
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 30);
         END IF;

         OPEN get_sum_time_out;

         FETCH get_sum_time_out
          INTO sum_time_in, sum_time_out;

         CLOSE get_sum_time_out;

         IF g_debug
         THEN
            hr_utility.TRACE (   'sum_time_in :'
                              || TO_CHAR (sum_time_in,
                                          'dd-mon-yyyy hh24:mi:ss'
                                         )
                             );
            hr_utility.TRACE (   'sum_time_out:'
                              || TO_CHAR (sum_time_out,
                                          'dd-mon-yyyy hh24:mi:ss'
                                         )
                             );
            hr_utility.TRACE (   'g_TIME_OUT  :'
                              || TO_CHAR (g_time_out,
                                          'dd-mon-yyyy hh24:mi:ss')
                             );
         END IF;

         IF sum_time_out IS NOT NULL AND g_time_out IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 40);
            END IF;

            IF g_time_out < sum_time_out
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               RETURN (p_hours_this_segment);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 60);
         END IF;

         OPEN detail_hours_today;

         FETCH detail_hours_today
          INTO hours_paid_already;

         IF g_debug
         THEN
            hr_utility.TRACE ('hours_paid_already :' || hours_paid_already);
         END IF;

         CLOSE detail_hours_today;

         OPEN hdp_hours_deducted_today;

         FETCH hdp_hours_deducted_today
          INTO addback_hours;

         IF g_debug
         THEN
            hr_utility.TRACE ('addback_hours :' || addback_hours);
         END IF;

         CLOSE hdp_hours_deducted_today;

         IF g_debug
         THEN
            hr_utility.TRACE (   'sum_time_in :'
                              || TO_CHAR (sum_time_in,
                                          'dd-mon-yyyy hh24:mi:ss'
                                         )
                             );
            hr_utility.TRACE (   'g_TIME_IN  :'
                              || TO_CHAR (g_time_in, 'dd-mon-yyyy hh24:mi:ss')
                             );
            hr_utility.TRACE ('p_hours_this_segment:' || p_hours_this_segment);
         END IF;

         IF sum_time_in IS NOT NULL AND g_time_in IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 70);
            END IF;

            IF g_time_in > sum_time_in
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 80);
                  hr_utility.TRACE ('-------g_time_in > sum_time_in------');
               END IF;

               addback_hours := addback_hours - p_hours_this_segment;

               IF g_debug
               THEN
                  hr_utility.TRACE ('addback_hours :' || addback_hours);
               END IF;
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 90);
            hr_utility.TRACE ('p_hours_this_segment:' || p_hours_this_segment);
            hr_utility.TRACE ('hours_paid_already  :' || hours_paid_already);
            hr_utility.TRACE ('addback_hours       :' || addback_hours);
         END IF;

         daily_total_hours :=
                     p_hours_this_segment + hours_paid_already + addback_hours;

         IF g_debug
         THEN
            hr_utility.TRACE ('daily_total_hours :' || daily_total_hours);
         END IF;

         FOR hdp_rule IN hdp_rule_cursor
         LOOP
            -- Calculate totals needed
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 100);
               hr_utility.TRACE (   'hdp_rule.time_period:'
                                 || hdp_rule.time_period
                                );
            END IF;

            deduct_hours :=
                 deduct_hours
               + (  FLOOR (daily_total_hours / hdp_rule.time_period)
                  * hdp_rule.hours
                 );

            IF g_debug
            THEN
               hr_utility.TRACE ('deduct_hours :' || deduct_hours);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 110);
            hr_utility.TRACE ('p_hours_this_segment:' || p_hours_this_segment);
            hr_utility.TRACE ('deduct_hours        :' || deduct_hours);
            hr_utility.TRACE ('addback_hours       :' || addback_hours);
         END IF;

--IF p_hours_this_segment <= (deduct_hours - addback_hours) THEN
--Above IF condition changed as follows for bug 3147339
         IF p_hours_this_segment < (deduct_hours - addback_hours)
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 120);
            END IF;

            IF adjust_for_hdp_shortage (deduct_hours - addback_hours) <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 130);
               END IF;

               fnd_message.set_name ('HXT', 'HXT_39488_CANT_DEDUCT_HOURS');
               p_error_code :=
                  call_hxthxc_gen_error ('HXT',
                                         'HXT_39488_CANT_DEDUCT_HOURS',
                                         NULL,
                                         g_location,
                                         ''
                                        );
            --2278400  p_error_code := call_gen_error(g_location, '');
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 140);
            END IF;

            RETURN (p_hours_this_segment);
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 150);
            hr_utility.TRACE ('p_hours_this_segment:' || p_hours_this_segment);
            hr_utility.TRACE ('deduct_hours        :' || deduct_hours);
            hr_utility.TRACE ('addback_hours       :' || addback_hours);
         END IF;

         RETURN (p_hours_this_segment - (deduct_hours - addback_hours));
      END;

--
--------------------------------------------------------------------------------
--
      FUNCTION set_consecutive_days_reached (p_consecutive_days_limit IN NUMBER)
         RETURN BOOLEAN
      IS
         -- returns TRUE if consecutive days number of special earning rule have been
         -- worked days must be in the same week starting from start_day_of_week
         consecutive_days   NUMBER;
      BEGIN
         SELECT (COUNT (DISTINCT work_date) + 1
                )                     -- 1 added for current day which may not
                                      -- be in db
           INTO consecutive_days
           FROM hxt_daily_hours_worked_v
          WHERE work_date BETWEEN   g_date_worked
                                  - (p_consecutive_days_limit - 1
                                    )                             -- start day
                              AND g_date_worked - 1               -- yesterday
            AND work_date >= NEXT_DAY (g_date_worked - 7, start_day_of_week)
            AND tim_id = g_tim_id;

         g_cons_days_worked := consecutive_days;

         IF consecutive_days >= p_consecutive_days_limit
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END;

--
-------------------------------------------------------------------------------
--
      FUNCTION getconsecutivedaysworked (a_date_worked IN DATE)
         RETURN NUMBER
      IS
         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR date_start_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            a_date_worked   DATE
         )
         IS
            SELECT sm.date_worked
              FROM hxt_sum_hours_worked sm
--Added this join to support the OTLR Recurring Preiod Preference
                   , hxt_timecards tim
--WHERE sm.tim_id = c_tim_id

            --Changed the above where clause as follows to support the
--OTLR Recurring Preiod Preference.
            WHERE  tim.for_person_id = g_person_id
               AND sm.tim_id = tim.ID
               AND sm.hours > 0
               AND sm.date_worked = c_date_worked
               AND sm.date_worked >=
                               NEXT_DAY (a_date_worked - 7, start_day_of_week);
          */
         CURSOR date_start_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            a_date_worked   DATE,
            session_date    DATE
         )
         IS
            SELECT sm.date_worked
              FROM hxt_sum_hours_worked_f sm
                   , hxt_timecards_f tim
            WHERE  tim.for_person_id = g_person_id
               AND sm.tim_id = tim.ID
               AND session_date BETWEEN sm.effective_start_date
                                    AND sm.effective_end_date
               AND session_date BETWEEN tim.effective_start_date
                                    AND tim.effective_end_date
               AND sm.hours > 0
               AND sm.date_worked = c_date_worked
               AND sm.date_worked >=
                               NEXT_DAY (a_date_worked - 7, start_day_of_week);


         consecutive_days   NUMBER         := 0;
         i                  NUMBER;
         l_date_start       DATE;
         l_continue         BOOLEAN        := TRUE;
         l_proc             VARCHAR2 (200);
      BEGIN
         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.GetConsecutiveDaysWorked';
            hr_utility.set_location (l_proc, 10);
         END IF;

         -- Bug 7359347
         -- Setting session date
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;


         i := 0;
         l_date_start := a_date_worked;

         IF g_debug
         THEN
            hr_utility.TRACE (   'l_date_start :'
                              || TO_CHAR (l_date_start,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
            hr_utility.TRACE ('i :' || i);
            hr_utility.set_location (l_proc, 20);
         END IF;

         WHILE (l_continue = TRUE AND i < 7)
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 30);
               hr_utility.TRACE ('i        :' || i);
               hr_utility.TRACE ('g_tim_id :' || g_tim_id);
               hr_utility.TRACE (   'a_date_worked :'
                                 || TO_CHAR (a_date_worked,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('start_day_of_week :' || start_day_of_week);
               hr_utility.TRACE ('g_person_id       :' || g_person_id);
            END IF;

            OPEN date_start_cur (g_tim_id, a_date_worked - i, a_date_worked,g_det_session_date);


            FETCH date_start_cur
             INTO l_date_start;

            IF g_debug
            THEN
               hr_utility.TRACE (   'l_date_start :'
                                 || TO_CHAR (l_date_start,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;

            IF date_start_cur%NOTFOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 40);
               END IF;

               l_continue := FALSE;
            END IF;

            CLOSE date_start_cur;

            IF l_continue = TRUE
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               i := i + 1;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 60);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 70);
            hr_utility.TRACE ('i        :' || i);
         END IF;

         RETURN i;
      END;

--
-------------------------------------------------------------------------------
--
      FUNCTION consecutivedaysworked_for_spc (a_date_worked IN DATE)
         RETURN NUMBER
      IS
         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR date_start_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            a_date_worked   DATE
         )
         IS
            SELECT sm.date_worked
              FROM hxt_sum_hours_worked sm, hxt_timecards tim
             WHERE tim.for_person_id = g_person_id
               AND sm.tim_id = tim.ID
               AND sm.hours > 0
               AND sm.date_worked = c_date_worked
               AND sm.date_worked >=
                               NEXT_DAY (a_date_worked - 7, start_day_of_week);

         CURSOR worked_elements_cur
         IS
            SELECT element_type_id
              FROM hxt_earn_groups eg, hxt_earn_group_types egt
             WHERE eg.egt_id = egt.ID AND egt.NAME = 'OTLR 7th Day Hours';

         l_wrkd_elements_cur      worked_elements_cur%ROWTYPE;

         CURSOR chk_det_for_wrkd_elements (a_date_start DATE)
         IS
            SELECT det.element_type_id
              FROM hxt_det_hours_worked det, hxt_timecards tim
             WHERE det.tim_id = tim.ID
               AND tim.for_person_id = g_person_id
               AND det.hours > 0
               AND det.date_worked = a_date_start;

          */
         CURSOR date_start_cur (
            c_tim_id        NUMBER,
            c_date_worked   DATE,
            a_date_worked   DATE
         )
         IS
            SELECT sm.date_worked
              FROM hxt_sum_hours_worked_f sm, hxt_timecards_f tim
             WHERE tim.for_person_id = g_person_id
               AND sm.tim_id = tim.ID
               AND g_det_session_date BETWEEN sm.effective_start_date
                                          AND sm.effective_end_date
               AND g_det_session_date BETWEEN tim.effective_start_date
                                          AND tim.effective_end_date
               AND sm.hours > 0
               AND sm.date_worked = c_date_worked
               AND sm.date_worked >=
                               NEXT_DAY (a_date_worked - 7, start_day_of_week);

         CURSOR worked_elements_cur
         IS
            SELECT element_type_id
              FROM hxt_earn_groups eg, hxt_earn_group_types egt
             WHERE eg.egt_id = egt.ID AND egt.NAME = 'OTLR 7th Day Hours';

         l_wrkd_elements_cur      worked_elements_cur%ROWTYPE;

         CURSOR chk_det_for_wrkd_elements (a_date_start DATE)
         IS
            SELECT det.element_type_id
              FROM hxt_det_hours_worked_f det, hxt_timecards_f tim
             WHERE det.tim_id = tim.ID
               AND g_det_session_date BETWEEN det.effective_start_date
                                          AND det.effective_end_date
               AND g_det_session_date BETWEEN tim.effective_start_date
                                          AND tim.effective_end_date
               AND tim.for_person_id = g_person_id
               AND det.hours > 0
               AND det.date_worked = a_date_start;


         l_chk_det_elements_cur   chk_det_for_wrkd_elements%ROWTYPE;
         consecutive_days         NUMBER                              := 0;
         i                        NUMBER;
         j                        NUMBER;
         l_date_start             DATE;
         l_continue               BOOLEAN                             := TRUE;
         l_day_worked             BOOLEAN                             := FALSE;
         l_proc                   VARCHAR2 (200);
      BEGIN
         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.ConsecutiveDaysWorked_for_SPC';
            hr_utility.set_location (l_proc, 10);
         END IF;

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;



         i := 0;
         j := 0;
         l_date_start := a_date_worked;

         IF g_debug
         THEN
            hr_utility.TRACE (   'l_date_start :'
                              || TO_CHAR (l_date_start,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
            hr_utility.TRACE ('i :' || i);
            hr_utility.set_location (l_proc, 20);
         END IF;

         WHILE (l_continue = TRUE AND i < 7)
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 30);
            END IF;

            l_day_worked := FALSE;

            IF g_debug
            THEN
               hr_utility.TRACE ('i        :' || i);
               hr_utility.TRACE ('g_tim_id :' || g_tim_id);
               hr_utility.TRACE (   'a_date_worked :'
                                 || TO_CHAR (a_date_worked,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('start_day_of_week :' || start_day_of_week);
               hr_utility.TRACE ('g_person_id       :' || g_person_id);
            END IF;

            OPEN date_start_cur (g_tim_id, a_date_worked - i, a_date_worked);

            FETCH date_start_cur
             INTO l_date_start;

            IF g_debug
            THEN
               hr_utility.TRACE (   'l_date_start :'
                                 || TO_CHAR (l_date_start,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;

            IF date_start_cur%NOTFOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 40);
               END IF;

               l_continue := FALSE;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 50);
            END IF;

            IF l_continue = TRUE
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 60);
               END IF;

               -- IF a_date_worked <> l_date_start THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 70);
               END IF;

               OPEN chk_det_for_wrkd_elements (l_date_start);

               LOOP                               -- fetch worked element rows
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 80);
                  END IF;

                  FETCH chk_det_for_wrkd_elements
                   INTO l_chk_det_elements_cur;

                  IF g_debug
                  THEN
                     hr_utility.TRACE
                                (   'l_chk_det_elements_cur.element_type_id:'
                                 || l_chk_det_elements_cur.element_type_id
                                );
                  END IF;

                  EXIT WHEN chk_det_for_wrkd_elements%NOTFOUND;

                  -- OR l_day_worked = TRUE;
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 90);
                  END IF;

                  OPEN worked_elements_cur;

                  LOOP
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 100);
                     END IF;

                     FETCH worked_elements_cur
                      INTO l_wrkd_elements_cur;

                     IF g_debug
                     THEN
                        hr_utility.TRACE
                                   (   'l_wrkd_elements_cur.element_type_id:'
                                    || l_wrkd_elements_cur.element_type_id
                                   );
                     END IF;

                     EXIT WHEN worked_elements_cur%NOTFOUND;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 110);
                     END IF;

                     IF (l_chk_det_elements_cur.element_type_id =
                                           l_wrkd_elements_cur.element_type_id
                        )
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 120);
                        END IF;

                        l_day_worked := TRUE;

                        -- CLOSE worked_elements_cur;
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 125);
                        END IF;

                        EXIT;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 130);
                        END IF;
                     END IF;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 140);
                     END IF;
                  END LOOP;

                  CLOSE worked_elements_cur;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 150);
                  END IF;

                  IF l_day_worked = TRUE
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 160);
                     END IF;

                     -- CLOSE chk_det_for_wrkd_elements;
                     EXIT;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 170);
                  END IF;
               END LOOP;

               CLOSE chk_det_for_wrkd_elements;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 180);
               END IF;

               --    END IF;
               IF (l_day_worked = TRUE) OR (l_date_start = a_date_worked)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 185);
                  END IF;

                  j := j + 1;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('j:' || j);
                  END IF;
               END IF;

               CLOSE date_start_cur;

               IF l_continue = TRUE
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 190);
                  END IF;

                  i := i + 1;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 190);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 200);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 210);
            hr_utility.TRACE ('j        :' || j);
         END IF;

         RETURN j;
      END;

--
-------------------------------------------------------------------------------
--
      FUNCTION adjust_abs_hrs_on_prev_days (
         c_tim_id            IN   NUMBER,
         c_date_worked       IN   DATE,
         c_tot_hours         IN   NUMBER,
         c_hours_left        IN   NUMBER,
         c_element_type_id   IN   NUMBER
      )
         RETURN NUMBER
      IS
         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR reg_hrs_cur (a_tim_id NUMBER, a_date_worked DATE)
         IS
            SELECT   hrw.ROWID hrw_rowid, hrw.hours, hrw.date_worked,
                     hrw.parent_id, hrw.assignment_id,
                     hrw.fcl_earn_reason_code, hrw.ffv_cost_center_id,
                     hrw.tas_id, hrw.location_id, hrw.sht_id,
                     hrw.hrw_comment, hrw.ffv_rate_code_id,
                     hrw.rate_multiple, hrw.hourly_rate, hrw.amount,
                     hrw.fcl_tax_rule_code, hrw.separate_check_flag,
                     hrw.seqno, hrw.time_in, hrw.time_out, hrw.project_id,
                     shr.earn_pol_id, hrw.tim_id, hrw.element_type_id,
                     hrw.created_by, hrw.creation_date, hrw.last_updated_by,
                     hrw.last_update_date, hrw.last_update_login,
                     hrw.effective_start_date, hrw.effective_end_date,
                     hrw.job_id, hrw.state_name, hrw.county_name,
                     hrw.city_name, hrw.zip_code
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_sum_hours_worked shr,
                     hxt_det_hours_worked hrw
               WHERE hrw.date_worked BETWEEN NEXT_DAY (a_date_worked - 7,
                                                       start_day_of_week
                                                      )
                                         AND a_date_worked
                 AND hrw.tim_id = a_tim_id
                 AND elt.element_type_id = hrw.element_type_id
                 AND eltv.hxt_earning_category = 'REG'
                 AND hrw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND hrw.parent_id = shr.ID
                 AND shr.element_type_id IS NULL
                 AND eltv.element_type_id = elt.element_type_id
                 AND hrw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
            ORDER BY hrw.date_worked DESC, hrw.time_in DESC, hrw.ID DESC;

         CURSOR clear_reg_detail_rec (c_parent_id NUMBER)
         IS
            SELECT hrw.ROWID
              FROM hxt_det_hours_worked hrw,
                   pay_element_types_f elt,
                   hxt_pay_element_types_f_ddf_v eltv
             WHERE hrw.parent_id = c_parent_id
               AND hrw.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND elt.element_type_id = eltv.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category = 'REG';

         CURSOR re_explode_details (c_parent_id NUMBER)
         IS
            SELECT hrw.ROWID hrw_rowid, hrw.hours, hrw.date_worked,
                   hrw.parent_id, hrw.assignment_id, hrw.fcl_earn_reason_code,
                   hrw.ffv_cost_center_id, hrw.tas_id, hrw.location_id,
                   hrw.sht_id, hrw.hrw_comment, hrw.ffv_rate_code_id,
                   hrw.rate_multiple, hrw.hourly_rate, hrw.amount,
                   hrw.fcl_tax_rule_code, hrw.separate_check_flag, hrw.seqno,
                   hrw.time_in, hrw.time_out, hrw.project_id, shr.earn_pol_id,
                   hrw.tim_id, hrw.element_type_id, hrw.created_by,
                   hrw.creation_date, hrw.last_updated_by,
                   hrw.last_update_date, hrw.last_update_login,
                   hrw.effective_start_date, hrw.effective_end_date,
                   hrw.job_id, hrw.state_name, hrw.county_name, hrw.city_name,
                   hrw.zip_code
              FROM hxt_det_hours_worked hrw,
                   hxt_sum_hours_worked shr,
                   pay_element_types_f elt,
                   hxt_pay_element_types_f_ddf_v eltv
             WHERE hrw.parent_id = c_parent_id
               AND hrw.element_type_id = elt.element_type_id
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND elt.element_type_id = eltv.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND hrw.parent_id = shr.ID
               AND eltv.hxt_earning_category IN ('REG', 'OVT');

           */

         -- Bug 8540828
         -- Added new columns hourly_rate,rate_multiple and amount
         -- from the summary row.
         CURSOR reg_hrs_cur (a_tim_id NUMBER, a_date_worked DATE,session_date DATE)
         IS
            SELECT   hrw.ROWID hrw_rowid, hrw.hours, hrw.date_worked,
                     hrw.parent_id, hrw.assignment_id,
                     hrw.fcl_earn_reason_code, hrw.ffv_cost_center_id,
                     hrw.tas_id, hrw.location_id, hrw.sht_id,
                     hrw.hrw_comment, hrw.ffv_rate_code_id,
                     hrw.rate_multiple, hrw.hourly_rate, hrw.amount,
                     hrw.fcl_tax_rule_code, hrw.separate_check_flag,
                     hrw.seqno, hrw.time_in, hrw.time_out, hrw.project_id,
                     shr.earn_pol_id, hrw.tim_id, hrw.element_type_id,
                     hrw.created_by, hrw.creation_date, hrw.last_updated_by,
                     hrw.last_update_date, hrw.last_update_login,
                     hrw.effective_start_date, hrw.effective_end_date,
                     hrw.job_id, hrw.state_name, hrw.county_name,
                     hrw.city_name, hrw.zip_code,
                     shr.hourly_rate sum_hourly_rate,
                     shr.amount sum_amount,
                     shr.rate_multiple sum_rate_multiple
                FROM hxt_pay_element_types_f_ddf_v eltv,
                     pay_element_types_f elt,
                     hxt_sum_hours_worked_f shr,
                     hxt_det_hours_worked_f hrw
               WHERE hrw.date_worked BETWEEN NEXT_DAY (a_date_worked - 7,
                                                       start_day_of_week
                                                      )
                                         AND a_date_worked
                 AND session_date BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
                 AND session_date BETWEEN shr.effective_start_date
                                      AND shr.effective_end_date
                 AND hrw.tim_id = a_tim_id
                 AND elt.element_type_id = hrw.element_type_id
                 AND eltv.hxt_earning_category = 'REG'
                 AND hrw.date_worked BETWEEN elt.effective_start_date
                                         AND elt.effective_end_date
                 AND hrw.parent_id = shr.ID
                 AND shr.element_type_id IS NULL
                 AND eltv.element_type_id = elt.element_type_id
                 AND hrw.date_worked BETWEEN eltv.effective_start_date
                                         AND eltv.effective_end_date
            ORDER BY hrw.date_worked DESC, hrw.time_in DESC, hrw.ID DESC;

         CURSOR clear_reg_detail_rec (c_parent_id NUMBER,session_date DATE)
         IS
            SELECT hrw.ROWID
              FROM hxt_det_hours_worked_f hrw,
                   pay_element_types_f elt,
                   hxt_pay_element_types_f_ddf_v eltv
             WHERE hrw.parent_id = c_parent_id
               AND hrw.element_type_id = elt.element_type_id
                 AND session_date BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND elt.element_type_id = eltv.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND eltv.hxt_earning_category = 'REG';


         -- Bug 8540828
         -- Added new columns hourly_rate,rate_multiple and amount
         -- from the summary row.
         CURSOR re_explode_details (c_parent_id NUMBER,session_date DATE)
         IS
            SELECT hrw.ROWID hrw_rowid, hrw.hours, hrw.date_worked,
                   hrw.parent_id, hrw.assignment_id, hrw.fcl_earn_reason_code,
                   hrw.ffv_cost_center_id, hrw.tas_id, hrw.location_id,
                   hrw.sht_id, hrw.hrw_comment, hrw.ffv_rate_code_id,
                   hrw.rate_multiple, hrw.hourly_rate, hrw.amount,
                   hrw.fcl_tax_rule_code, hrw.separate_check_flag, hrw.seqno,
                   hrw.time_in, hrw.time_out, hrw.project_id, shr.earn_pol_id,
                   hrw.tim_id, hrw.element_type_id, hrw.created_by,
                   hrw.creation_date, hrw.last_updated_by,
                   hrw.last_update_date, hrw.last_update_login,
                   hrw.effective_start_date, hrw.effective_end_date,
                   hrw.job_id, hrw.state_name, hrw.county_name, hrw.city_name,
                   hrw.zip_code,
                   shr.hourly_rate sum_hourly_rate,
                   shr.amount sum_amount,
                   shr.rate_multiple sum_rate_multiple
              FROM hxt_det_hours_worked_f hrw,
                   hxt_sum_hours_worked_f shr,
                   pay_element_types_f elt,
                   hxt_pay_element_types_f_ddf_v eltv
             WHERE hrw.parent_id = c_parent_id
               AND hrw.element_type_id = elt.element_type_id
                 AND session_date BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
                 AND session_date BETWEEN shr.effective_start_date
                                      AND shr.effective_end_date
               AND hrw.date_worked BETWEEN elt.effective_start_date
                                       AND elt.effective_end_date
               AND elt.element_type_id = eltv.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date
               AND hrw.parent_id = shr.ID
               AND eltv.hxt_earning_category IN ('REG', 'OVT');


         l_del_rowid               ROWID;
         l_rule_earning_type       NUMBER;
         l_segment_start_time      DATE;
         l_segment_stop_time       DATE;
         l_hours_to_pay            NUMBER;
         l_rowid                   ROWID;
         l_hours_to_adjust         NUMBER;
         l_days_worked             NUMBER;
         l_abs_count               NUMBER;
         l_reg_hrs_cur             reg_hrs_cur%ROWTYPE;
         l_re_explode_details      re_explode_details%ROWTYPE;
         l_update_rowid            ROWID;
         l_time_in                 hxt_det_hours_worked.time_in%TYPE;
         l_time_out                hxt_det_hours_worked.time_out%TYPE;
         l_hours                   NUMBER;
         l_hours_left              NUMBER;
         l_work_plan               NUMBER;
         l_rotation_plan           NUMBER;
         l_rotation_or_work_plan   VARCHAR2 (1);
         l_retcode                 NUMBER;
         l_hours                   NUMBER;
         l_shift_hours             NUMBER;                           -- SIR212
         l_egp_id                  NUMBER;                   -- earning policy
         l_hdp_id                  NUMBER;           -- hours deduction policy
         l_hdy_id                  NUMBER;                   -- holiday day ID
         l_sdp_id                  NUMBER;                -- shift diff policy
         l_egp_type                VARCHAR2 (30);       -- earning policy type
         l_egt_id                  NUMBER;            -- include earning group
         l_pep_id                  NUMBER;                 -- prem elig policy
         l_pip_id                  NUMBER;             -- prem interact policy
         l_hcl_id                  NUMBER;                 -- holiday calendar
         l_hcl_elt_id              NUMBER;             -- holiday earning type
         l_sdf_id                  NUMBER;         -- override shift diff prem
         l_osp_id                  NUMBER;                   -- off-shift prem
         l_standard_start          NUMBER;
         l_standard_stop           NUMBER;
         l_early_start             NUMBER;
         l_late_stop               NUMBER;
         l_min_tcard_intvl         NUMBER;
         l_round_up                NUMBER;
         l_hol_code                NUMBER;
         l_hol_yn                  VARCHAR2 (1)                         := 'N';
         l_error                   NUMBER;
         l_status                  NUMBER;
         l_next_index              BINARY_INTEGER                       := 0;
         l_next_parent_index       BINARY_INTEGER                       := 0;
         l_delete                  NUMBER;
         l_delete_det              NUMBER;
         l_re_explode              NUMBER;
         i                         NUMBER;
         j                         NUMBER;
         k                         NUMBER;
         l_proc                    VARCHAR2 (200);
      BEGIN
         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.adjust_abs_hrs_on_prev_days';
            hr_utility.set_location (l_proc, 10);
            hr_utility.TRACE ('c_tim_id:' || c_tim_id);
            hr_utility.TRACE (   'c_date_worked :'
                              || TO_CHAR (c_date_worked,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
            hr_utility.TRACE ('c_hours_left:' || c_hours_left);
         END IF;

         -- Bug 7359347
         -- Setting session date
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

         IF NVL(FND_PROFILE.VALUE('HXT_HOLIDAY_EXPLOSION'),'EX') <> 'EX'
         THEN
            RETURN 0;
         END IF;


         l_hours_left := c_hours_left;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_hours_left:' || l_hours_left);
         END IF;

         IF l_hours_left = 0
         THEN
            RETURN 0;
         END IF;


         IF g_parent_to_re_explode.COUNT > 0
         THEN
            -- Bug 8540828
            -- Not connected here, but the change is made.
            -- You dont have to NULL out everything and then
            -- delete.  Commenting the loop.
            /*
            l_delete := g_parent_to_re_explode.FIRST;

            LOOP
               EXIT WHEN NOT g_parent_to_re_explode.EXISTS (l_delete);
               g_parent_to_re_explode (l_delete).parent_id := NULL;
               l_delete := g_parent_to_re_explode.NEXT (l_delete);
            END LOOP;
	    */
            IF g_debug
            THEN
               hr_utility.TRACE
                              ('Deleting g_parent_to_re_explode PL/SQL table');
            END IF;

            g_parent_to_re_explode.DELETE;
         END IF;

         OPEN reg_hrs_cur (c_tim_id, c_date_worked,g_det_session_date);

         WHILE l_hours_left > 0
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 20);
            END IF;

            FETCH reg_hrs_cur
             INTO l_reg_hrs_cur;

            IF reg_hrs_cur%NOTFOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 30);
               END IF;

               -- Bug 7359347
         -- Changed the below query to pick up session date from global variable
         -- instead of fnd_sessions table.

               /*
               SELECT COUNT (*)
                 INTO l_abs_count
                 FROM hxt_pay_element_types_f_ddf_v eltv,
                      pay_element_types_f elt,
                      hxt_sum_hours_worked shr,
                      hxt_timecards tim
                WHERE shr.date_worked BETWEEN NEXT_DAY (c_date_worked - 7,
                                                        start_day_of_week
                                                       )
                                          AND c_date_worked
                  AND shr.tim_id = c_tim_id
                  AND elt.element_type_id = shr.element_type_id
                  AND eltv.hxt_earning_category = 'ABS'
                  AND shr.date_worked BETWEEN elt.effective_start_date
                                          AND elt.effective_end_date
                  AND shr.element_type_id IS NOT NULL
                  AND eltv.element_type_id = elt.element_type_id
                  AND shr.date_worked BETWEEN eltv.effective_start_date
                                          AND eltv.effective_end_date;
               */

               SELECT COUNT (*)
                 INTO l_abs_count
                 FROM hxt_pay_element_types_f_ddf_v eltv,
                      pay_element_types_f elt,
                      hxt_sum_hours_worked_f shr,
                      hxt_timecards_f tim
                WHERE shr.date_worked BETWEEN NEXT_DAY (c_date_worked - 7,
                                                        start_day_of_week
                                                       )
                                          AND c_date_worked
                  AND shr.tim_id = c_tim_id
                  AND g_det_session_date BETWEEN shr.effective_start_date
                                             AND shr.effective_end_date
                  AND g_det_session_date BETWEEN tim.effective_start_date
                                             AND tim.effective_end_date
                  AND elt.element_type_id = shr.element_type_id
                  AND eltv.hxt_earning_category = 'ABS'
                  AND shr.date_worked BETWEEN elt.effective_start_date
                                          AND elt.effective_end_date
                  AND shr.element_type_id IS NOT NULL
                  AND eltv.element_type_id = elt.element_type_id
                  AND shr.date_worked BETWEEN eltv.effective_start_date
                                          AND eltv.effective_end_date;


               IF g_debug
               THEN
                  hr_utility.TRACE ('l_abs_count :' || l_abs_count);
               END IF;

               IF g_spc_dy_eg IS NOT NULL
               THEN
                  l_days_worked :=
                                consecutivedaysworked_for_spc (g_date_worked);

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'date_worked :'
                                       || TO_CHAR (g_date_worked, 'DD/MON/YY')
                                      );
                     hr_utility.TRACE (   'consec_days_worked:'
                                       || TO_CHAR (consec_days_worked)
                                      );
                  END IF;
               ELSE
                  l_days_worked := getconsecutivedaysworked (g_date_worked);

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'date_worked:'
                                       || TO_CHAR (g_date_worked, 'DD/MON/YY')
                                      );
                     hr_utility.TRACE (   'consec_days_worked:'
                                       || TO_CHAR (consec_days_worked)
                                      );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_days_worked :' || l_days_worked);
               END IF;

               --If Timecard hours are all Vacation , i.e.,if a week of just vacation
               --,then do not calculate for an overtime amount
               IF l_abs_count = l_days_worked
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 40);
                  END IF;

                  CLOSE reg_hrs_cur;

                  RETURN 0;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               CLOSE reg_hrs_cur;

               RETURN 1;
            END IF;

            --Populate plsql table g_parent_to_re_explode with the parent_id of the
            --REG hrs detail row(the DET row on which ABS hrs are being adjusted)
            --All the REG hrs rows on which the absence hrs are adjusted
            --will be re-exploded in order to determine the Shift Premiums to be
            --paid with diff hours types that changed on previous days of the week
            --due to this ABS adjustment.

            -- Bug 8540828
            -- Added the below code to check and NULL out the hourly_rate/amount/
            -- rate_multiple.  If there is a Summary value, it means this is an
            -- overriden entry, and need to NULL out.

            IF l_reg_hrs_cur.sum_hourly_rate IS NULL
            THEN
               l_reg_hrs_cur.hourly_rate := NULL;
            END IF;

            IF l_reg_hrs_cur.sum_amount IS NULL
            THEN
               l_reg_hrs_cur.amount := NULL;
            END IF;

            IF l_reg_hrs_cur.sum_rate_multiple IS NULL
            THEN
               l_reg_hrs_cur.rate_multiple := NULL;
            END IF;



            l_next_parent_index := g_parent_to_re_explode.COUNT + 1;
            g_parent_to_re_explode (l_next_parent_index).parent_id :=
                                                       l_reg_hrs_cur.parent_id;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 51);
            END IF;

            l_hours_to_adjust := l_reg_hrs_cur.hours;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_hours_to_adjust :' || l_hours_to_adjust);
               hr_utility.TRACE ('l_hours_left      :' || l_hours_left);
            END IF;

            IF l_hours_to_adjust <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 55);
               END IF;

               IF l_hours_to_adjust <= l_hours_left
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 60);
                  END IF;

                  l_hours_left := l_hours_left - l_hours_to_adjust;
                  l_hours_to_pay := l_hours_to_adjust;
                  l_hours_to_adjust := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_hours_left      :' || l_hours_left);
                     hr_utility.TRACE ('l_hours_to_pay    :' || l_hours_to_pay
                                      );
                     hr_utility.TRACE (   'l_hours_to_adjust :'
                                       || l_hours_to_adjust
                                      );
                  END IF;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 70);
                  END IF;

                  l_hours_to_adjust := l_hours_to_adjust - l_hours_left;
                  l_hours_to_pay := l_hours_left;
                  l_hours_left := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_hours_left      :' || l_hours_left);
                     hr_utility.TRACE ('l_hours_to_pay    :' || l_hours_to_pay
                                      );
                     hr_utility.TRACE (   'l_hours_to_adjust :'
                                       || l_hours_to_adjust
                                      );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 80);
                  hr_utility.TRACE (   'l_reg_hrs_cur.parent_id :'
                                    || l_reg_hrs_cur.parent_id
                                   );
                  hr_utility.TRACE ('c_tim_id :' || c_tim_id);
                  hr_utility.TRACE (   'l_reg_hrs_cur.seqno :'
                                    || l_reg_hrs_cur.seqno
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.hours :'
                                    || l_reg_hrs_cur.hours
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.date_worked :'
                                    || TO_CHAR (l_reg_hrs_cur.date_worked,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.time_in :'
                                    || TO_CHAR (l_reg_hrs_cur.time_in,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.time_out :'
                                    || TO_CHAR (l_reg_hrs_cur.time_out,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.earn_pol_id :'
                                    || l_reg_hrs_cur.earn_pol_id
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.assignment_id :'
                                    || l_reg_hrs_cur.assignment_id
                                   );
                  hr_utility.set_location (l_proc, 81);
               END IF;

               -- Get the Policies and Premiums for current day - on which
               -- the REG hrs were found - where the absence hrs
               -- will be adjusted.
               hxt_util.get_policies (l_reg_hrs_cur.earn_pol_id,
                                      l_reg_hrs_cur.assignment_id,
                                      l_reg_hrs_cur.date_worked,
                                      l_work_plan,
                                      l_rotation_plan,
                                      l_egp_id,
                                      l_hdp_id,
                                      l_sdp_id,
                                      l_egp_type,
                                      l_egt_id,
                                      l_pep_id,
                                      l_pip_id,
                                      l_hcl_id,
                                      l_min_tcard_intvl,
                                      l_round_up,
                                      l_hcl_elt_id,
                                      l_error
                                     );

               -- Check if error encountered
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 82);
                  hr_utility.TRACE ('l_egp_id     :' || l_egp_id);
               END IF;

               IF l_error <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 83);
                  END IF;

                  RETURN 3;
               END IF;

               -- Check if person assigned work or rotation plan
               IF g_debug
               THEN
                  hr_utility.TRACE ('l_work_plan     :' || l_work_plan);
                  hr_utility.TRACE ('l_rotation_plan :' || l_rotation_plan);
               END IF;

               IF (l_work_plan IS NOT NULL) OR (l_rotation_plan IS NOT NULL)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 84);
                  END IF;

                  --Get premiums for shift
                  hxt_util.get_shift_info (l_reg_hrs_cur.date_worked,
                                           l_work_plan,
                                           l_rotation_plan,
                                           l_osp_id,
                                           l_sdf_id,
                                           l_standard_start,
                                           l_standard_stop,
                                           l_early_start,
                                           l_late_stop,
                                           l_shift_hours              --SIR212
                                                        ,
                                           l_error
                                          );

                  -- Check if error encountered
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 85);
                  END IF;

                  IF l_error <> 0
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 86);
                     END IF;

                     RETURN 3;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 87);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 88);
                  hr_utility.TRACE (   'l_reg_hrs_cur.parent_id:'
                                    || l_reg_hrs_cur.parent_id
                                   );
               END IF;

               -- Clear up all the details for reg_hrs_cur record as it will be
               -- re exploded.
               OPEN clear_reg_detail_rec (l_reg_hrs_cur.parent_id,g_det_session_date);

               FETCH clear_reg_detail_rec
                INTO l_del_rowid;

               CLOSE clear_reg_detail_rec;

               -- Bug 7359347
               -- changing view to table.
               /*
               DELETE FROM hxt_det_hours_worked
                     WHERE ROWID = l_del_rowid;
               */
               DELETE FROM hxt_det_hours_worked_f
                     WHERE ROWID = l_del_rowid;


               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 89);
                  hr_utility.TRACE (   'l_reg_hrs_cur.time_in :'
                                    || TO_CHAR (l_reg_hrs_cur.time_in,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'l_reg_hrs_cur.time_out :'
                                    || TO_CHAR (l_reg_hrs_cur.time_out,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE ('l_hours_to_adjust:' || l_hours_to_adjust);
                  hr_utility.TRACE
                         (   'l_reg_hrs_cur.time_in + (l_hours_to_adjust/24):'
                          || TO_CHAR (  l_reg_hrs_cur.time_in
                                      + (l_hours_to_adjust / 24),
                                      'DD-MON-YYYY HH24:MI:SS'
                                     )
                         );
               END IF;

               -- Re explode the details for the REG hours left after
               -- determining hours required for ABS adjustments.
               -- Generate details
               -- Bug 8540828
               -- Reverted the change done for bug 4967495 for
               -- passing NULL values for hourly_rate/rate_multiple/amount.
               -- This is to take care of Overriden entries where there is
               -- a value for these in the summary row.
               l_status :=
                  hxt_time_summary.generate_details
                                  (l_reg_hrs_cur.earn_pol_id -- earning policy
                                                            ,
                                   l_egp_type           -- earning policy type
                                             ,
                                   l_egt_id,
                                   l_sdp_id               -- shift diff policy
                                           ,
                                   l_hdp_id,
                                   l_hcl_id,
                                   l_pep_id,
                                   l_pip_id,
                                   l_sdf_id  -- override shift diff premium id
                                           ,
                                   l_osp_id            -- off-shift premium id
                                           ,
                                   l_standard_start,
                                   l_standard_stop,
                                   l_early_start,
                                   l_late_stop,
                                   l_hol_yn,
                                   g_person_id,
                                   'TIMC'                    -- calling source
                                         ,
                                   l_reg_hrs_cur.parent_id,
                                   l_reg_hrs_cur.tim_id,
                                   l_reg_hrs_cur.date_worked,
                                   l_reg_hrs_cur.assignment_id,
                                   l_hours_to_adjust    -- i.e., the REG hours
                                                    ,
                                   l_reg_hrs_cur.time_in,
                                   (  l_reg_hrs_cur.time_in
                                    + (l_hours_to_adjust / 24)
                                   ),
                                   l_reg_hrs_cur.element_type_id,
                                   l_reg_hrs_cur.fcl_earn_reason_code,
                                   l_reg_hrs_cur.ffv_cost_center_id,
                                   NULL,
                                   l_reg_hrs_cur.tas_id,
                                   l_reg_hrs_cur.location_id,
                                   l_reg_hrs_cur.sht_id,
                                   l_reg_hrs_cur.hrw_comment,
                                   l_reg_hrs_cur.ffv_rate_code_id,
                                   l_reg_hrs_cur.rate_multiple,
                                   l_reg_hrs_cur.hourly_rate,
                                   l_reg_hrs_cur.amount,
                                   l_reg_hrs_cur.fcl_tax_rule_code,
                                   l_reg_hrs_cur.separate_check_flag,
                                   l_reg_hrs_cur.seqno,
                                   l_reg_hrs_cur.created_by,
                                   l_reg_hrs_cur.creation_date,
                                   l_reg_hrs_cur.last_updated_by,
                                   l_reg_hrs_cur.last_update_date,
                                   l_reg_hrs_cur.last_update_login,
                                   g_period_start_date,
                                   NULL                               -- rowid
                                       ,
                                   l_reg_hrs_cur.effective_start_date,
                                   l_reg_hrs_cur.effective_end_date,
                                   l_reg_hrs_cur.project_id,
                                   l_reg_hrs_cur.job_id,
                                   NULL,
                                   NULL,
                                   NULL,
                                   'CORRECTION',
                                   'N',
                                   l_reg_hrs_cur.state_name,
                                   l_reg_hrs_cur.county_name,
                                   l_reg_hrs_cur.city_name,
                                   l_reg_hrs_cur.zip_code
                                  );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 90);
               END IF;

               IF l_status <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 91);
                  END IF;

                  RETURN 3;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 92);
               END IF;

               -- Now generate the detail records for c_element_type_id
               -- i.e., the OT or the DT that gets adjusted on
               -- reg_hrs_cur.date_worked
               IF l_reg_hrs_cur.time_in IS NOT NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 101);
                  END IF;

                  l_segment_start_time :=
                              l_reg_hrs_cur.time_in
                              + (l_hours_to_adjust / 24);
                  l_segment_stop_time :=
                                  l_segment_start_time
                                  + (l_hours_to_pay / 24);
               ELSE            -- time_in is null, i.e., time entered in hours
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 102);
                  END IF;

                  l_segment_start_time := NULL;
                  l_segment_stop_time := NULL;
               END IF;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_segment_start_time :'
                                    || TO_CHAR (l_segment_start_time,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'l_segment_stop_time  :'
                                    || TO_CHAR (l_segment_stop_time,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
               END IF;

--BEGIN SIR 491
               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_reg_hrs_cur.parent_id:'
                                    || l_reg_hrs_cur.parent_id
                                   );
                  hr_utility.TRACE ('c_tim_id               :' || c_tim_id);
                  hr_utility.TRACE (   'c_element_type_id      :'
                                    || c_element_type_id
                                   );
                  hr_utility.set_location (l_proc, 103);
               END IF;

               -- Bug 8540828
               -- Reverted the change done for bug 4967495 for
               -- passing NULL values for hourly_rate/rate_multiple/amount.
               -- This is to take care of Overriden entries where there is
               -- a value for these in the summary row.

               l_status :=
                  hxt_time_summary.generate_details
                                  (l_reg_hrs_cur.earn_pol_id -- earning policy
                                                            ,
                                   l_egp_type           -- earning policy type
                                             ,
                                   l_egt_id,
                                   l_sdp_id               -- shift diff policy
                                           ,
                                   l_hdp_id,
                                   l_hcl_id,
                                   l_pep_id,
                                   l_pip_id,
                                   l_sdf_id  -- override shift diff premium id
                                           ,
                                   l_osp_id            -- off-shift premium id
                                           ,
                                   l_standard_start,
                                   l_standard_stop,
                                   l_early_start,
                                   l_late_stop,
                                   l_hol_yn,
                                   g_person_id,
                                   'TIMC'                    -- calling source
                                         ,
                                   l_reg_hrs_cur.parent_id,
                                   l_reg_hrs_cur.tim_id,
                                   l_reg_hrs_cur.date_worked,
                                   l_reg_hrs_cur.assignment_id,
                                   l_hours_to_pay,
                                   l_segment_start_time,
                                   l_segment_stop_time,
                                   c_element_type_id         -- i.e., OT or DT
                                                    ,
                                   l_reg_hrs_cur.fcl_earn_reason_code,
                                   l_reg_hrs_cur.ffv_cost_center_id,
                                   NULL,
                                   l_reg_hrs_cur.tas_id,
                                   l_reg_hrs_cur.location_id,
                                   l_reg_hrs_cur.sht_id,
                                   l_reg_hrs_cur.hrw_comment,
                                   l_reg_hrs_cur.ffv_rate_code_id,
                                   l_reg_hrs_cur.rate_multiple,
                                   l_reg_hrs_cur.hourly_rate,
                                   l_reg_hrs_cur.amount,
                                   l_reg_hrs_cur.fcl_tax_rule_code,
                                   l_reg_hrs_cur.separate_check_flag,
                                   l_reg_hrs_cur.seqno,
                                   l_reg_hrs_cur.created_by,
                                   l_reg_hrs_cur.creation_date,
                                   l_reg_hrs_cur.last_updated_by,
                                   l_reg_hrs_cur.last_update_date,
                                   l_reg_hrs_cur.last_update_login,
                                   g_period_start_date,
                                   NULL                               -- rowid
                                       ,
                                   l_reg_hrs_cur.effective_start_date,
                                   l_reg_hrs_cur.effective_end_date,
                                   l_reg_hrs_cur.project_id,
                                   l_reg_hrs_cur.job_id,
                                   NULL,
                                   NULL,
                                   NULL,
                                   'CORRECTION',
                                   'N',
                                   l_reg_hrs_cur.state_name,
                                   l_reg_hrs_cur.county_name,
                                   l_reg_hrs_cur.city_name,
                                   l_reg_hrs_cur.zip_code
                                  );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 104);
               END IF;

               IF l_status <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 105);
                  END IF;

                  RETURN 3;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 106);
               END IF;
            END IF;                          -- end if l_hours_to_adjust <> 0;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 107);
            END IF;
         END LOOP;                                   -- While l_hours_left > 0

         -- After adjusting all the absence hrs, populate the details
         --( i.e. REG, OT and DT hours) of all the adjusted days in
         -- g_re_explode_detail plsql table.
         -- Then delete the details(i.e all the rows including Reg,OT,
         -- DT and all the premiums) of all the adjusted days and
         -- re-explode them based on the plsql data in order to pay
         -- the Shift Premiums, associated with the REG, OT and DT
         -- hours, correctly.
         IF g_debug
         THEN
            hr_utility.TRACE ('FYI');
         END IF;

         i := g_parent_to_re_explode.FIRST;

         LOOP
            EXIT WHEN NOT g_parent_to_re_explode.EXISTS (i);

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 107.1);
               hr_utility.TRACE ('i:' || i);
               hr_utility.TRACE (   'g_parent_to_re_explode(i).parent_id:'
                                 || g_parent_to_re_explode (i).parent_id
                                );
               hr_utility.set_location (l_proc, 107.2);
            END IF;

            i := g_parent_to_re_explode.NEXT (i);
         END LOOP;

         IF g_debug
         THEN
            hr_utility.TRACE ('END FYI');
            hr_utility.set_location (l_proc, 107.3);
            hr_utility.TRACE (   'g_parent_to_re_explode.count:'
                              || g_parent_to_re_explode.COUNT
                             );
         END IF;

         j := g_parent_to_re_explode.FIRST;

         LOOP
            EXIT WHEN NOT g_parent_to_re_explode.EXISTS (j);

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 107.4);
               hr_utility.TRACE ('j:' || j);
               hr_utility.TRACE (   'g_parent_to_re_explode(j).parent_id:'
                                 || g_parent_to_re_explode (j).parent_id
                                );
            END IF;

            IF g_re_explode_detail.COUNT > 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 107.5);
               END IF;

               -- Bug 8540828
               -- Not connected here, but the change is made.
               -- When you are deleting, needn't NULL out and then
               -- delete.  Commenting out the deleting code.
               /*
               l_delete_det := g_re_explode_detail.FIRST;

               LOOP
                  EXIT WHEN NOT g_re_explode_detail.EXISTS (l_delete_det);
                  g_re_explode_detail (l_delete_det).earn_pol_id := NULL;
                  g_re_explode_detail (l_delete_det).parent_id := NULL;
                  g_re_explode_detail (l_delete_det).tim_id := NULL;
                  g_re_explode_detail (l_delete_det).date_worked := NULL;
                  g_re_explode_detail (l_delete_det).assignment_id := NULL;
                  g_re_explode_detail (l_delete_det).hours := NULL;
                  g_re_explode_detail (l_delete_det).time_in := NULL;
                  g_re_explode_detail (l_delete_det).time_out := NULL;
                  g_re_explode_detail (l_delete_det).element_type_id := NULL;
                  g_re_explode_detail (l_delete_det).fcl_earn_reason_code :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).ffv_cost_center_id :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).tas_id := NULL;
                  g_re_explode_detail (l_delete_det).location_id := NULL;
                  g_re_explode_detail (l_delete_det).sht_id := NULL;
                  g_re_explode_detail (l_delete_det).hrw_comment := NULL;
                  g_re_explode_detail (l_delete_det).ffv_rate_code_id := NULL;
                  g_re_explode_detail (l_delete_det).rate_multiple := NULL;
                  g_re_explode_detail (l_delete_det).hourly_rate := NULL;
                  g_re_explode_detail (l_delete_det).amount := NULL;
                  g_re_explode_detail (l_delete_det).fcl_tax_rule_code :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).separate_check_flag :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).seqno := NULL;
                  g_re_explode_detail (l_delete_det).created_by := NULL;
                  g_re_explode_detail (l_delete_det).creation_date := NULL;
                  g_re_explode_detail (l_delete_det).last_updated_by := NULL;
                  g_re_explode_detail (l_delete_det).last_update_date := NULL;
                  g_re_explode_detail (l_delete_det).last_update_login :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).effective_start_date :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).effective_end_date :=
                                                                         NULL;
                  g_re_explode_detail (l_delete_det).project_id := NULL;
                  g_re_explode_detail (l_delete_det).job_id := NULL;
                  g_re_explode_detail (l_delete_det).state_name := NULL;
                  g_re_explode_detail (l_delete_det).county_name := NULL;
                  g_re_explode_detail (l_delete_det).city_name := NULL;
                  g_re_explode_detail (l_delete_det).zip_code := NULL;
                  l_delete_det := g_re_explode_detail.NEXT (l_delete_det);
               END LOOP;
	       */
               IF g_debug
               THEN
                  hr_utility.TRACE
                                 ('Deleting g_re_explode_detail PL/SQL table');
               END IF;

               g_re_explode_detail.DELETE;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 107.6);
            END IF;

            -- Populate the g_re_explode_detail plsql table with the details of
            -- the rows that need to be re-exploded
            OPEN re_explode_details (g_parent_to_re_explode (j).parent_id,g_det_session_date);

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 107.61);
            END IF;

            LOOP
               FETCH re_explode_details
                INTO l_re_explode_details;

               EXIT WHEN re_explode_details%NOTFOUND;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 108);
               END IF;

               l_next_index := g_re_explode_detail.COUNT + 1;

              -- Bug 8540828
              -- Added the below code to take care of overriden
              -- hourly_rates/rate_multiples/amounts.  This nulling
              -- is done here with a condition check so that
              -- bug 4967495 will not reappear.
              IF l_re_explode_details.sum_hourly_rate IS NULL
              THEN
                  l_re_explode_details.hourly_rate := NULL;
              END IF;

              IF l_re_explode_details.sum_amount IS NULL
              THEN
                  l_re_explode_details.amount := NULL;
              END IF;

              IF l_re_explode_details.sum_rate_multiple IS NULL
              THEN
                  l_re_explode_details.rate_multiple := NULL;
              END IF;



               IF g_debug
               THEN
                  hr_utility.TRACE ('l_next_index:' || l_next_index);
               END IF;

               g_re_explode_detail (l_next_index).earn_pol_id :=
                                              l_re_explode_details.earn_pol_id;
               g_re_explode_detail (l_next_index).parent_id :=
                                                l_re_explode_details.parent_id;
               g_re_explode_detail (l_next_index).tim_id :=
                                                   l_re_explode_details.tim_id;
               g_re_explode_detail (l_next_index).date_worked :=
                                              l_re_explode_details.date_worked;
               g_re_explode_detail (l_next_index).assignment_id :=
                                            l_re_explode_details.assignment_id;
               g_re_explode_detail (l_next_index).hours :=
                                                    l_re_explode_details.hours;
               g_re_explode_detail (l_next_index).time_in :=
                                                  l_re_explode_details.time_in;
               g_re_explode_detail (l_next_index).time_out :=
                                                 l_re_explode_details.time_out;
               g_re_explode_detail (l_next_index).element_type_id :=
                                          l_re_explode_details.element_type_id;
               g_re_explode_detail (l_next_index).fcl_earn_reason_code :=
                                     l_re_explode_details.fcl_earn_reason_code;
               g_re_explode_detail (l_next_index).ffv_cost_center_id :=
                                       l_re_explode_details.ffv_cost_center_id;
               g_re_explode_detail (l_next_index).tas_id :=
                                                   l_re_explode_details.tas_id;
               g_re_explode_detail (l_next_index).location_id :=
                                              l_re_explode_details.location_id;
               g_re_explode_detail (l_next_index).sht_id :=
                                                   l_re_explode_details.sht_id;
               g_re_explode_detail (l_next_index).hrw_comment :=
                                              l_re_explode_details.hrw_comment;
               g_re_explode_detail (l_next_index).ffv_rate_code_id :=
                                         l_re_explode_details.ffv_rate_code_id;
               g_re_explode_detail (l_next_index).rate_multiple :=
                                            l_re_explode_details.rate_multiple;
               g_re_explode_detail (l_next_index).hourly_rate :=
                                              l_re_explode_details.hourly_rate;
               g_re_explode_detail (l_next_index).amount :=
                                                   l_re_explode_details.amount;
               g_re_explode_detail (l_next_index).fcl_tax_rule_code :=
                                        l_re_explode_details.fcl_tax_rule_code;
               g_re_explode_detail (l_next_index).separate_check_flag :=
                                      l_re_explode_details.separate_check_flag;
               g_re_explode_detail (l_next_index).seqno :=
                                                    l_re_explode_details.seqno;
               g_re_explode_detail (l_next_index).created_by :=
                                               l_re_explode_details.created_by;
               g_re_explode_detail (l_next_index).creation_date :=
                                            l_re_explode_details.creation_date;
               g_re_explode_detail (l_next_index).last_updated_by :=
                                          l_re_explode_details.last_updated_by;
               g_re_explode_detail (l_next_index).last_update_date :=
                                         l_re_explode_details.last_update_date;
               g_re_explode_detail (l_next_index).last_update_login :=
                                        l_re_explode_details.last_update_login;
               g_re_explode_detail (l_next_index).effective_start_date :=
                                     l_re_explode_details.effective_start_date;
               g_re_explode_detail (l_next_index).effective_end_date :=
                                       l_re_explode_details.effective_end_date;
               g_re_explode_detail (l_next_index).project_id :=
                                               l_re_explode_details.project_id;
               g_re_explode_detail (l_next_index).job_id :=
                                                   l_re_explode_details.job_id;
               g_re_explode_detail (l_next_index).state_name :=
                                               l_re_explode_details.state_name;
               g_re_explode_detail (l_next_index).county_name :=
                                              l_re_explode_details.county_name;
               g_re_explode_detail (l_next_index).city_name :=
                                                l_re_explode_details.city_name;
               g_re_explode_detail (l_next_index).zip_code :=
                                                 l_re_explode_details.zip_code;
            END LOOP;        -- end populating g_re_explode_detail plsql table

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 109);
            END IF;

            CLOSE re_explode_details;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 109.1);
               hr_utility.TRACE ('parent_id:' || l_reg_hrs_cur.parent_id);
            END IF;

            -- Clear all the detail records for l_reg_hrs_cur.parent_id
         -- Bug 7359347
         -- Setting session date and changing view to table below.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

            /*
            DELETE FROM hxt_det_hours_worked
                  WHERE parent_id = g_parent_to_re_explode (j).parent_id;
            */
            DELETE FROM hxt_det_hours_worked_f
                  WHERE parent_id = g_parent_to_re_explode (j).parent_id
                    AND g_det_session_date BETWEEN effective_start_date
                                               AND effective_end_date;


            -- Bug 8540828
            -- Not connected here, but the change is made.
            -- You need to loop only if g_debug is enabled.
            -- Neednt loop, and then check inside the loop each time.
            IF g_debug
            THEN
               hr_utility.TRACE ('FYI');
               k := g_re_explode_detail.FIRST;

               LOOP
                  EXIT WHEN NOT g_re_explode_detail.EXISTS (k);

                     hr_utility.set_location (l_proc, 109.2);
                     hr_utility.TRACE ('k:' || k);
                     hr_utility.TRACE (   'g_re_explode_detail(k).earn_pol_id:'
                                       || g_re_explode_detail (k).earn_pol_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).parent_id:'
                                       || g_re_explode_detail (k).parent_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).tim_id:'
                                       || g_re_explode_detail (k).tim_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).date_worked:'
                                       || g_re_explode_detail (k).date_worked
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).assignment_id:'
                                       || g_re_explode_detail (k).assignment_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).hours:'
                                       || g_re_explode_detail (k).hours
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).time_in:'
                                       || TO_CHAR
                                                 (g_re_explode_detail (k).time_in,
                                                  'DD-MON-YYYY HH24:MI:SS'
                                                 )
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).time_out:'
                                       || TO_CHAR
                                                (g_re_explode_detail (k).time_out,
                                                 'DD-MON-YYYY HH24:MI:SS'
                                                )
                                      );
                     hr_utility.TRACE
                                    (   'g_re_explode_detail(k).element_type_id:'
                                     || g_re_explode_detail (k).element_type_id
                                    );
                     hr_utility.TRACE
                               (   'g_re_explode_detail(k).fcl_earn_reason_code:'
                                || g_re_explode_detail (k).fcl_earn_reason_code
                               );
                     hr_utility.TRACE
                                 (   'g_re_explode_detail(k).ffv_cost_center_id:'
                                  || g_re_explode_detail (k).ffv_cost_center_id
                                 );
                     hr_utility.TRACE (   'g_re_explode_detail(k).tas_id:'
                                       || g_re_explode_detail (k).tas_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).location_id:'
                                       || g_re_explode_detail (k).location_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).sht_id:'
                                       || g_re_explode_detail (k).sht_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).hrw_comment:'
                                       || g_re_explode_detail (k).hrw_comment
                                      );
                     hr_utility.TRACE
                                   (   'g_re_explode_detail(k).ffv_rate_code_id:'
                                    || g_re_explode_detail (k).ffv_rate_code_id
                                   );
                     hr_utility.TRACE (   'g_re_explode_detail(k).rate_multiple:'
                                       || g_re_explode_detail (k).rate_multiple
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).hourly_rate:'
                                       || g_re_explode_detail (k).hourly_rate
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).amount:'
                                       || g_re_explode_detail (k).amount
                                      );
                     hr_utility.TRACE
                                  (   'g_re_explode_detail(k).fcl_tax_rule_code:'
                                   || g_re_explode_detail (k).fcl_tax_rule_code
                                  );
                     hr_utility.TRACE
                                (   'g_re_explode_detail(k).separate_check_flag:'
                                 || g_re_explode_detail (k).separate_check_flag
                                );
                     hr_utility.TRACE (   'g_re_explode_detail(k).seqno:'
                                       || g_re_explode_detail (k).seqno
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).created_by:'
                                       || g_re_explode_detail (k).created_by
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).creation_date:'
                                       || g_re_explode_detail (k).creation_date
                                      );
                     hr_utility.TRACE
                                    (   'g_re_explode_detail(k).last_updated_by:'
                                     || g_re_explode_detail (k).last_updated_by
                                    );
                     hr_utility.TRACE
                                   (   'g_re_explode_detail(k).last_update_date:'
                                    || g_re_explode_detail (k).last_update_date
                                   );
                     hr_utility.TRACE
                                  (   'g_re_explode_detail(k).last_update_login:'
                                   || g_re_explode_detail (k).last_update_login
                                  );
                     hr_utility.TRACE
                               (   'g_re_explode_detail(k).effective_start_date:'
                                || g_re_explode_detail (k).effective_start_date
                               );
                     hr_utility.TRACE
                                 (   'g_re_explode_detail(k).effective_end_date:'
                                  || g_re_explode_detail (k).effective_end_date
                                 );
                     hr_utility.TRACE (   'g_re_explode_detail(k).project_id:'
                                       || g_re_explode_detail (k).project_id
                                      );
                     hr_utility.TRACE (   'g_re_explode_detail(k).job_id:'
                                       || g_re_explode_detail (k).job_id
                                      );
                     hr_utility.set_location (l_proc, 109.22);

                  k := g_re_explode_detail.NEXT (k);
               END LOOP;

               hr_utility.TRACE ('END FYI');
               hr_utility.set_location (l_proc, 109.23);
               hr_utility.TRACE (   'g_re_explode_detail.count:'
                                 || g_re_explode_detail.COUNT
                                );
            END IF;

            -- Re-explode the detail records
            l_re_explode := g_re_explode_detail.FIRST;

            LOOP
               EXIT WHEN NOT g_re_explode_detail.EXISTS (l_re_explode);

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 109.3);
                  hr_utility.TRACE ('l_re_explode:' || l_re_explode);
                  hr_utility.TRACE
                         (   'g_re_explode_detail(l_re_explode).earn_pol_id:'
                          || g_re_explode_detail (l_re_explode).earn_pol_id
                         );
                  hr_utility.TRACE
                            (   'g_re_explode_detail(l_re_explode).parent_id:'
                             || g_re_explode_detail (l_re_explode).parent_id
                            );
                  hr_utility.TRACE
                               (   'g_re_explode_detail(l_re_explode).tim_id:'
                                || g_re_explode_detail (l_re_explode).tim_id
                               );
                  hr_utility.TRACE
                          (   'g_re_explode_detail(l_re_explode).date_worked:'
                           || g_re_explode_detail (l_re_explode).date_worked
                          );
                  hr_utility.TRACE
                        (   'g_re_explode_detail(l_re_explode).assignment_id:'
                         || g_re_explode_detail (l_re_explode).assignment_id
                        );
                  hr_utility.TRACE
                                (   'g_re_explode_detail(l_re_explode).hours:'
                                 || g_re_explode_detail (l_re_explode).hours
                                );
                  hr_utility.TRACE
                          (   'g_re_explode_detail(l_re_explode).time_in:'
                           || TO_CHAR
                                   (g_re_explode_detail (l_re_explode).time_in,
                                    'DD-MON-YYYY HH24:MI:SS'
                                   )
                          );
                  hr_utility.TRACE
                         (   'g_re_explode_detail(l_re_explode).time_out:'
                          || TO_CHAR
                                  (g_re_explode_detail (l_re_explode).time_out,
                                   'DD-MON-YYYY HH24:MI:SS'
                                  )
                         );
                  hr_utility.TRACE
                      (   'g_re_explode_detail(l_re_explode).element_type_id:'
                       || g_re_explode_detail (l_re_explode).element_type_id
                      );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).fcl_earn_reason_code:'
                      || g_re_explode_detail (l_re_explode).fcl_earn_reason_code
                     );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).ffv_cost_center_id:'
                      || g_re_explode_detail (l_re_explode).ffv_cost_center_id
                     );
                  hr_utility.TRACE
                               (   'g_re_explode_detail(l_re_explode).tas_id:'
                                || g_re_explode_detail (l_re_explode).tas_id
                               );
                  hr_utility.TRACE
                          (   'g_re_explode_detail(l_re_explode).location_id:'
                           || g_re_explode_detail (l_re_explode).location_id
                          );
                  hr_utility.TRACE
                               (   'g_re_explode_detail(l_re_explode).sht_id:'
                                || g_re_explode_detail (l_re_explode).sht_id
                               );
                  hr_utility.TRACE
                          (   'g_re_explode_detail(l_re_explode).hrw_comment:'
                           || g_re_explode_detail (l_re_explode).hrw_comment
                          );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).ffv_rate_code_id:'
                      || g_re_explode_detail (l_re_explode).ffv_rate_code_id
                     );
                  hr_utility.TRACE
                        (   'g_re_explode_detail(l_re_explode).rate_multiple:'
                         || g_re_explode_detail (l_re_explode).rate_multiple
                        );
                  hr_utility.TRACE
                          (   'g_re_explode_detail(l_re_explode).hourly_rate:'
                           || g_re_explode_detail (l_re_explode).hourly_rate
                          );
                  hr_utility.TRACE
                               (   'g_re_explode_detail(l_re_explode).amount:'
                                || g_re_explode_detail (l_re_explode).amount
                               );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).fcl_tax_rule_code:'
                      || g_re_explode_detail (l_re_explode).fcl_tax_rule_code
                     );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).separate_check_flag:'
                      || g_re_explode_detail (l_re_explode).separate_check_flag
                     );
                  hr_utility.TRACE
                                (   'g_re_explode_detail(l_re_explode).seqno:'
                                 || g_re_explode_detail (l_re_explode).seqno
                                );
                  hr_utility.TRACE
                           (   'g_re_explode_detail(l_re_explode).created_by:'
                            || g_re_explode_detail (l_re_explode).created_by
                           );
                  hr_utility.TRACE
                        (   'g_re_explode_detail(l_re_explode).creation_date:'
                         || g_re_explode_detail (l_re_explode).creation_date
                        );
                  hr_utility.TRACE
                      (   'g_re_explode_detail(l_re_explode).last_updated_by:'
                       || g_re_explode_detail (l_re_explode).last_updated_by
                      );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).last_update_date:'
                      || g_re_explode_detail (l_re_explode).last_update_date
                     );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).last_update_login:'
                      || g_re_explode_detail (l_re_explode).last_update_login
                     );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).effective_start_date:'
                      || g_re_explode_detail (l_re_explode).effective_start_date
                     );
                  hr_utility.TRACE
                     (   'g_re_explode_detail(l_re_explode).effective_end_date:'
                      || g_re_explode_detail (l_re_explode).effective_end_date
                     );
                  hr_utility.TRACE
                           (   'g_re_explode_detail(l_re_explode).project_id:'
                            || g_re_explode_detail (l_re_explode).project_id
                           );
                  hr_utility.TRACE
                               (   'g_re_explode_detail(l_re_explode).job_id:'
                                || g_re_explode_detail (l_re_explode).job_id
                               );
               END IF;

               -- Generate details

               -- Bug 8540828
               -- Reverted the change done for bug 4967495 for
               -- passing NULL values for hourly_rate/rate_multiple/amount.
               -- This is to take care of Overriden entries where there is
               -- a value for these in the summary row.

               l_status :=
                  hxt_time_summary.generate_details
                      (g_re_explode_detail (l_re_explode).earn_pol_id
                                                                     --earning policy
                  ,
                       l_egp_type                       -- earning policy type
                                 ,
                       l_egt_id,
                       l_sdp_id                           -- shift diff policy
                               ,
                       l_hdp_id,
                       l_hcl_id,
                       l_pep_id,
                       l_pip_id,
                       l_sdf_id              -- override shift diff premium id
                               ,
                       l_osp_id                        -- off-shift premium id
                               ,
                       l_standard_start,
                       l_standard_stop,
                       l_early_start,
                       l_late_stop,
                       l_hol_yn,
                       g_person_id,
                       'TIMC'                                -- calling source
                             ,
                       g_re_explode_detail (l_re_explode).parent_id,
                       g_re_explode_detail (l_re_explode).tim_id,
                       g_re_explode_detail (l_re_explode).date_worked,
                       g_re_explode_detail (l_re_explode).assignment_id,
                       g_re_explode_detail (l_re_explode).hours,
                       g_re_explode_detail (l_re_explode).time_in,
                       g_re_explode_detail (l_re_explode).time_out,
                       g_re_explode_detail (l_re_explode).element_type_id,
                       g_re_explode_detail (l_re_explode).fcl_earn_reason_code,
                       g_re_explode_detail (l_re_explode).ffv_cost_center_id,
                       NULL,
                       g_re_explode_detail (l_re_explode).tas_id,
                       g_re_explode_detail (l_re_explode).location_id,
                       g_re_explode_detail (l_re_explode).sht_id,
                       g_re_explode_detail (l_re_explode).hrw_comment,
                       g_re_explode_detail (l_re_explode).ffv_rate_code_id,
                       g_re_explode_detail (l_re_explode).rate_multiple,
                       g_re_explode_detail (l_re_explode).hourly_rate,
                       g_re_explode_detail (l_re_explode).amount,
                       g_re_explode_detail (l_re_explode).fcl_tax_rule_code,
                       g_re_explode_detail (l_re_explode).separate_check_flag,
                       g_re_explode_detail (l_re_explode).seqno,
                       g_re_explode_detail (l_re_explode).created_by,
                       g_re_explode_detail (l_re_explode).creation_date,
                       g_re_explode_detail (l_re_explode).last_updated_by,
                       g_re_explode_detail (l_re_explode).last_update_date,
                       g_re_explode_detail (l_re_explode).last_update_login,
                       g_period_start_date,
                       NULL                                           -- rowid
                           ,
                       g_re_explode_detail (l_re_explode).effective_start_date,
                       g_re_explode_detail (l_re_explode).effective_end_date,
                       g_re_explode_detail (l_re_explode).project_id,
                       g_re_explode_detail (l_re_explode).job_id,
                       NULL,
                       NULL,
                       NULL,
                       'CORRECTION',
                       'N',
                       g_re_explode_detail (l_re_explode).state_name,
                       g_re_explode_detail (l_re_explode).county_name,
                       g_re_explode_detail (l_re_explode).city_name,
                       g_re_explode_detail (l_re_explode).zip_code
                      );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 109.4);
                  hr_utility.TRACE ('l_status:' || l_status);
               END IF;

               IF l_status <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 109.5);
                  END IF;

                  RETURN 3;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 109.6);
               END IF;

               l_re_explode := g_re_explode_detail.NEXT (l_re_explode);
            END LOOP; -- g_re_explode_detail.first .. g_re_explode_detail.last

            j := g_parent_to_re_explode.NEXT (j);
         END LOOP;

         -- g_parent_to_re_explode.first .. g_parent_to_re_explode.last
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 110);
         END IF;

         CLOSE reg_hrs_cur;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 120);
         END IF;

         RETURN 0;
      END adjust_abs_hrs_on_prev_days;

--
------------------------------------------------------------------------------
--
-- we have a problem where employees transition over 40 hours late
-- in the week, and the transition takes place as a result of an absence.
-- For example, a person works:
--              M  T  W  T  F  S
--              12 12 12 8V
-- explodes as  12 12 12 8V        reg
--
-- it should    12 12 8  8V
-- explode as         4OT
--
      FUNCTION adjust_for_absence (
         a_tim_id        NUMBER,
         a_ep_id         NUMBER,
         a_date_worked   DATE
      )
         RETURN NUMBER
      IS
         CURSOR daily_earn_rules_cur2 (
            c_earn_policy   NUMBER,
            c_date_worked   DATE
         )
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'DAY'
                 AND er.egp_id = c_earn_policy
                 AND c_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

         CURSOR weekly_earn_rules_cur2 (
            c_earn_policy   NUMBER,
            c_date_worked   DATE
         )
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'WKL'
                 AND er.egp_id = c_earn_policy
                 AND c_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

      -- Following cursor changed for bug 4444969
/*
         CURSOR get_wkl_tot_incl_hrs_2day
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_det_hours_worked hrw,
                   hxt_timecards tim,
                   hxt_earn_groups erg,
                   hxt_earn_group_types egt,
                   hxt_earning_policies erp,
                   hxt_add_elem_info_f aei
             WHERE tim.for_person_id = g_person_id
               AND hrw.tim_id = tim.ID
               AND erp.ID = g_ep_id
               AND egt.ID = erp.egt_id
               AND erg.egt_id = egt.ID
               AND erg.element_type_id = hrw.element_type_id
               AND hrw.element_type_id = aei.element_type_id
               AND (                               -- get weekly total to date
                       (hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                          start_day_of_week
                                                         )
                                            AND (g_date_worked - 1)
                       )
                    OR
                       -- get any hours worked on this day that were entered before the
                       -- current row, i.e., parent_id of the rest of the rows entered
                       -- for this day will be less than the current row.
                       -- i.e., for example when entering regular as well as vac hrs on
                       -- the same day but in two different rows, then get the hrs for the
                       -- rows that were entered before the current row that is being
                       -- processed for the day
                       (                  -- AND aei.earning_category <> 'ABS'
                            hrw.date_worked = g_date_worked
                        AND hrw.parent_id < g_id
                       )
                   )
               AND hrw.date_worked BETWEEN erp.effective_start_date
                                       AND erp.effective_end_date;
*/
-- This change considers the hours entered, while totaling for the week,
-- irrespective of the sequence in which the rows for a day were entered.

-- Bug 7359347
-- The below cursor changed to refer to the base table
-- instead of the view since the view is badly joining to FND_SESSIONS
-- twice. Added a session date parameter.

/*
        CURSOR get_wkl_tot_incl_hrs_2day
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_det_hours_worked hrw,
                   hxt_timecards tim,
                   hxt_earn_groups erg,
                   hxt_earn_group_types egt,
                   hxt_earning_policies erp,
                   hxt_add_elem_info_f aei
             WHERE tim.for_person_id = g_person_id
               AND hrw.tim_id = tim.ID
               AND erp.ID = g_ep_id
               AND egt.ID = erp.egt_id
               AND erg.egt_id = egt.ID
               AND erg.element_type_id = hrw.element_type_id
               AND hrw.element_type_id = aei.element_type_id
               AND                                 -- get weekly total to date
                   hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND g_date_worked
               AND hrw.date_worked BETWEEN erp.effective_start_date
                                       AND erp.effective_end_date
               AND hrw.date_worked BETWEEN aei.effective_start_date
                                       AND aei.effective_end_date
	       AND sysdate BETWEEN aei.effective_start_date
	                       AND aei.effective_end_date; /* Bug: 6674738 */

         CURSOR get_wkl_tot_incl_hrs_2day(effective_date   DATE)
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_det_hours_worked_f hrw,
                   hxt_timecards_f tim,
                   hxt_earn_groups erg,
                   hxt_earn_group_types egt,
                   hxt_earning_policies erp,
                   hxt_add_elem_info_f aei
             WHERE effective_date BETWEEN hrw.effective_start_date
                                      AND hrw.effective_end_date
               AND effective_date BETWEEN tim.effective_start_date
                                      AND tim.effective_end_date
               AND tim.for_person_id = g_person_id
               AND hrw.tim_id = tim.ID
               AND erp.ID = g_ep_id
               AND egt.ID = erp.egt_id
               AND erg.egt_id = egt.ID
               AND erg.element_type_id = hrw.element_type_id
               AND hrw.element_type_id = aei.element_type_id
               AND                                 -- get weekly total to date
                   hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     start_day_of_week
                                                    )
                                       AND g_date_worked
               AND hrw.date_worked BETWEEN erp.effective_start_date
                                       AND erp.effective_end_date
               AND hrw.date_worked BETWEEN aei.effective_start_date
                                       AND aei.effective_end_date
	       AND sysdate BETWEEN aei.effective_start_date
	                       AND aei.effective_end_date;



         l_hours_left          NUMBER;
         l_first_daily_elem    NUMBER;
         l_second_daily_elem   NUMBER;
         l_third_daily_elem    NUMBER;
         l_first_daily_cap     NUMBER;
         l_second_daily_cap    NUMBER;
         l_third_daily_cap     NUMBER;
         l_first_elem          NUMBER;
         l_second_elem         NUMBER;
         l_third_elem          NUMBER;
         l_first_cap           NUMBER;
         l_second_cap          NUMBER;
         l_third_cap           NUMBER;
         l_tot_hours           NUMBER;
         l_error_return        NUMBER         := 0;
         l_earning_category    VARCHAR2 (10);          --  category of earning
         l_proc                VARCHAR2 (200);
      BEGIN
         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.adjust_for_absence';
            hr_utility.set_location (l_proc, 10);
            hr_utility.TRACE ('a_ep_id:' || a_ep_id);
            hr_utility.TRACE (   'a_date_worked  :'
                              || TO_CHAR (a_date_worked,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
         END IF;

         IF g_ep_type = 'SPECIAL'
         THEN
            hr_utility.set_location (l_proc, 10.5);

            OPEN daily_earn_rules_cur2 (a_ep_id, a_date_worked);

            FETCH daily_earn_rules_cur2
             INTO l_first_daily_cap, l_first_daily_elem;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_first_daily_cap :' || l_first_daily_cap);
               hr_utility.TRACE ('l_first_daily_elem:' || l_first_daily_elem);
            END IF;

            IF daily_earn_rules_cur2%FOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 11);
               END IF;

               FETCH daily_earn_rules_cur2
                INTO l_second_daily_cap, l_second_daily_elem;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_second_daily_cap :'
                                    || l_second_daily_cap
                                   );
                  hr_utility.TRACE (   'l_second_daily_elem:'
                                    || l_second_daily_elem
                                   );
               END IF;

               IF daily_earn_rules_cur2%FOUND
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 12);
                  END IF;

                  FETCH daily_earn_rules_cur2
                   INTO l_third_daily_cap, l_third_daily_elem;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'l_third_daily_cap :'
                                       || l_third_daily_cap
                                      );
                     hr_utility.TRACE (   'l_third_daily_elem:'
                                       || l_third_daily_elem
                                      );
                  END IF;

                  IF daily_earn_rules_cur2%FOUND
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 13);
                     END IF;

                     NULL;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 14);
                     END IF;

                     l_third_daily_cap := 999;
                  END IF;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 15);
                  END IF;

                  l_second_daily_cap := 999;
               END IF;
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 16);
               END IF;

               CLOSE daily_earn_rules_cur2;

               hxt_util.DEBUG ('Return code is 2 from loc B');
               -- debug only --HXT115
               RETURN 2;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 20);
            END IF;

            CLOSE daily_earn_rules_cur2;
         END IF;

         OPEN weekly_earn_rules_cur2 (a_ep_id, a_date_worked);

         FETCH weekly_earn_rules_cur2
          INTO l_first_cap, l_first_elem;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_first_cap :' || l_first_cap);
            hr_utility.TRACE ('l_first_elem:' || l_first_elem);
         END IF;

         IF weekly_earn_rules_cur2%FOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 25);
            END IF;

            FETCH weekly_earn_rules_cur2
             INTO l_second_cap, l_second_elem;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_second_cap :' || l_second_cap);
               hr_utility.TRACE ('l_second_elem:' || l_second_elem);
            END IF;

            IF weekly_earn_rules_cur2%FOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 30);
               END IF;

               FETCH weekly_earn_rules_cur2
                INTO l_third_cap, l_third_elem;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_third_cap :' || l_third_cap);
                  hr_utility.TRACE ('l_third_elem:' || l_third_elem);
               END IF;

               IF weekly_earn_rules_cur2%FOUND
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 40);
                  END IF;

                  NULL;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 50);
                  END IF;

                  l_third_cap := 999;
               END IF;
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 60);
               END IF;

               l_second_cap := 999;
            END IF;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 70);
            END IF;

            CLOSE weekly_earn_rules_cur2;

            hxt_util.DEBUG ('Return code is 2 from loc B');
            -- debug only --HXT115
            RETURN 2;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 80);
         END IF;

         CLOSE weekly_earn_rules_cur2;

-- Get weekly total including today. For today only get the hours other than
-- ABS hours, since these need to be included in the total hrs for the week
-- when determining how many ABS hrs need to be adjusted as OT hrs.
-- Say for e.g., Weekly rule cap is 40
-- hrs entered for the week are as follows:
--      MON      TUE      WED    THURS
-- REG   9        5               5
-- VAC   2        6       10      6
-- The total hours for the week on Thurs when entering 5 hrs reg is 32.
-- Now when entering 6 hrs VAC on Thurs the total weekly hours should be
-- calculated as 32(Mon + Tue + Wed) + 5 hrs REG on Thurs = 37 hrs.

         -- l_earning_category := hxt_util.element_cat(g_element_type_id
--                                           ,g_date_worked);
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 81);
            hr_utility.TRACE ('l_earning_category:' || l_earning_category);
         END IF;

         /*  IF l_earning_category <> 'ABS' THEN
                     hr_utility.set_location(l_proc,82);
              l_tot_hours := get_weekly_total_to_date;
           ELSIF l_earning_category = 'ABS' THEN
                     hr_utility.set_location(l_proc,83);
              OPEN  get_wkl_tot_incl_non_abs_2day;
              FETCH get_wkl_tot_incl_non_abs_2day into l_tot_hours;
              CLOSE get_wkl_tot_incl_non_abs_2day;
           END IF; */
         IF g_debug
         THEN
            hr_utility.TRACE ('start_day_of_week:' || start_day_of_week);
            hr_utility.TRACE ('g_person_id      :' || g_person_id);
            hr_utility.TRACE ('g_ep_id          :' || g_ep_id);
            hr_utility.TRACE ('g_id(parent_id)  :' || g_id);
            hr_utility.TRACE (   'g_date_worked    :'
                              || TO_CHAR (g_date_worked, 'dd/mon/yy')
                             );
         END IF;

         -- l_tot_hours := get_weekly_total_to_date;
         OPEN get_wkl_tot_incl_hrs_2day(g_det_session_date);


         FETCH get_wkl_tot_incl_hrs_2day
          INTO l_tot_hours;

         CLOSE get_wkl_tot_incl_hrs_2day;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_tot_hours :' || l_tot_hours);
         END IF;

         -- Bug 4444969 fix
         -- While processing a row, the g_hours(hrs entered on the row being
         -- processed) are subtracted from the above total so that the Overtime
         -- can be calculated correctly. Subtracting is required since the
         -- above cursor brings back the total hrs from the details table and
         -- the record being processed already exists in the details table
         -- (since hxt_time_pay.pay is called before the call to
         -- adjust_for_absence function
         l_tot_hours := l_tot_hours - g_hours;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_tot_hours :' || l_tot_hours);
            hr_utility.TRACE ('l_first_cap :' || l_first_cap);
            hr_utility.TRACE ('g_hours     :' || g_hours);
         END IF;

         --If total weekly hours are less than the first weekly cap:
         IF l_tot_hours <= l_first_cap
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 90);
            END IF;

            IF (l_tot_hours + g_hours) <= l_first_cap
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 95);
               END IF;

               -- Nothing to adjust as per the Earning Policy's Weekly caps.

               -- And nothing gets adjusted on the basis of the daily EP rules as per
      -- the current functionality of the application. It is considered as an
      -- override as long as the weekly cap limits are not reached.
      -- Since the Earning Group is a counter for Weekly caps only, the
      -- application currently lacks enough information to take care of
      -- ABS adjustments based on EP daily rules. That's why commented out the
      -- following code otherwise it would double count the ABS hours that
      -- need to be adjusted based on both daily as well as weekly rules,
      -- screwing up the adjustment on previous days.
      -- So, as of now, the ABS hours get adjusted only when the weekly cap
      -- limit is reached, they are considered as overrides when daily EP rules
      -- are getting applied.
/*
      -- but if it is a SPECIAL Earning Policy then check if any hours
      -- need to be adjusted based on Earning Policy's Daily caps.

         IF (l_first_cap - l_tot_hours) >= g_hours THEN
                   hr_utility.set_location(l_proc,100);
                   hr_utility.trace('l_first_daily_cap  :'||l_first_daily_cap);
                    hr_utility.trace('l_second_daily_cap :'||l_second_daily_cap);
            IF g_EP_TYPE = 'SPECIAL' THEN
                         hr_utility.set_location(l_proc,105);
               IF g_hours <= l_first_daily_cap THEN
                             hr_utility.set_location(l_proc,110);
                  -- Nothing to adjust as per daily caps.
                     l_hours_left := 0;
               ELSIF l_first_daily_cap < g_hours AND
                     g_hours <= l_second_daily_cap THEN
                             hr_utility.set_location(l_proc,115);
                     l_hours_left := g_hours -l_first_daily_cap;
                             hr_utility.trace('l_hours_left :'||l_hours_left);
                     l_error_return := adjust_abs_hrs_on_prev_days
                                                    (a_tim_id
                                                    ,a_date_worked
                                                    ,l_tot_hours
                                                    ,l_hours_left
                                                    ,l_second_elem);
                             hr_utility.set_location(l_proc,120);
                             hr_utility.trace('l_error_return :'||l_error_return);
               ELSIF l_second_daily_cap < g_hours THEN
                             hr_utility.set_location(l_proc,125);
                     l_hours_left := g_hours - l_second_daily_cap;
                             hr_utility.trace('l_hours_left :'||l_hours_left);
                     l_error_return := adjust_abs_hrs_on_prev_days
                                                    (a_tim_id
                                                    ,a_date_worked
                                                    ,l_tot_hours
                                                    ,l_hours_left
                                                    ,l_third_elem);
                             hr_utility.set_location(l_proc,130);
                             hr_utility.trace('l_error_return :'||l_error_return);
                     IF l_error_return <> 0 THEN
                           hr_utility.set_location(l_proc,135);
                        return l_error_return;
                     END IF;
                             hr_utility.set_location(l_proc,140);
                     l_hours_left := l_second_daily_cap - l_first_daily_cap;
                             hr_utility.trace('l_hours_left :'||l_hours_left);
                     l_error_return := adjust_abs_hrs_on_prev_days
                                                    (a_tim_id
                                                    ,a_date_worked
                                                    ,l_tot_hours
                                                    ,l_hours_left
                                                    ,l_second_elem);
                        hr_utility.set_location(l_proc,145);
                        hr_utility.trace('l_error_return :'||l_error_return);
               END IF;
                       hr_utility.set_location(l_proc,150);
            END IF; -- g_EP_TYPE = 'SPECIAL'
                  hr_utility.set_location(l_proc,155);
         END IF; -- (first_cap - l_tot_hours) >= g_hours
             hr_utility.set_location(l_proc,160);
*/
     -- Since nothing to adjust, implies return back
               l_error_return := 0;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 165);
                  hr_utility.TRACE ('l_first_cap:' || l_first_cap);
                  hr_utility.TRACE ('l_second_cap:' || l_second_cap);
                  hr_utility.TRACE ('l_tot_hours:' || l_tot_hours);
               END IF;
            ELSIF     l_first_cap < (l_tot_hours + g_hours)
                  AND (l_tot_hours + g_hours) <= l_second_cap
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 170);
               END IF;

               l_hours_left := (l_tot_hours + g_hours) - l_first_cap;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours_left:' || l_hours_left);
               END IF;

               l_error_return :=
                  adjust_abs_hrs_on_prev_days (a_tim_id,
                                               a_date_worked,
                                               l_tot_hours,
                                               l_hours_left,
                                               l_second_elem
                                              );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 175);
                  hr_utility.TRACE ('l_error_return:' || l_error_return);
               END IF;
            ELSIF l_second_cap < (l_tot_hours + g_hours)
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 180);
               END IF;

               l_hours_left := (l_tot_hours + g_hours) - l_second_cap;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours_left:' || l_hours_left);
               END IF;

               l_error_return :=
                  adjust_abs_hrs_on_prev_days (a_tim_id,
                                               a_date_worked,
                                               l_tot_hours,
                                               l_hours_left,
                                               l_third_elem
                                              );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 185);
                  hr_utility.TRACE ('l_error_return:' || l_error_return);
               END IF;

               IF l_error_return <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 190);
                  END IF;

                  RETURN l_error_return;
               END IF;

               l_hours_left := l_second_cap - l_first_cap;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 195);
               END IF;

               l_error_return :=
                  adjust_abs_hrs_on_prev_days (a_tim_id,
                                               a_date_worked,
                                               l_tot_hours,
                                               l_hours_left,
                                               l_second_elem
                                              );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 200);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 205);
            END IF;
         --IF total weekly hours are between first weekly cap and second weekly cap:
         ELSIF l_first_cap < l_tot_hours AND l_tot_hours <= l_second_cap
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 210);
            END IF;

            IF (l_tot_hours + g_hours) <= l_second_cap
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 215);
               END IF;

               l_hours_left := g_hours;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours_left:' || l_hours_left);
               END IF;

               l_error_return :=
                  adjust_abs_hrs_on_prev_days (a_tim_id,
                                               a_date_worked,
                                               l_tot_hours,
                                               l_hours_left,
                                               l_second_elem
                                              );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 220);
                  hr_utility.TRACE ('l_error_return:' || l_error_return);
               END IF;
            ELSIF l_second_cap < (l_tot_hours + g_hours)
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 225);
               END IF;

               l_hours_left := (l_tot_hours + g_hours) - l_second_cap;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours_left:' || l_hours_left);
               END IF;

               l_error_return :=
                  adjust_abs_hrs_on_prev_days (a_tim_id,
                                               a_date_worked,
                                               l_tot_hours,
                                               l_hours_left,
                                               l_third_elem
                                              );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 230);
                  hr_utility.TRACE ('l_error_return:' || l_error_return);
               END IF;

               IF l_error_return <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 235);
                  END IF;

                  RETURN l_error_return;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 240);
               END IF;

               l_hours_left := l_second_cap - l_tot_hours;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_hours_left:' || l_hours_left);
               END IF;

               l_error_return :=
                  adjust_abs_hrs_on_prev_days (a_tim_id,
                                               a_date_worked,
                                               l_tot_hours,
                                               l_hours_left,
                                               l_second_elem
                                              );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 245);
                  hr_utility.TRACE ('l_error_return:' || l_error_return);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 250);
            END IF;
         --IF total weekly hours are greater than second weekly cap:
         ELSIF l_tot_hours > l_second_cap
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 255);
            END IF;

            l_hours_left := g_hours;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_hours_left:' || l_hours_left);
            END IF;

            l_error_return :=
               adjust_abs_hrs_on_prev_days (a_tim_id,
                                            a_date_worked,
                                            l_tot_hours,
                                            l_hours_left,
                                            l_third_elem
                                           );

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 260);
               hr_utility.TRACE ('l_error_return:' || l_error_return);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 270);
         END IF;

         RETURN l_error_return;
      END adjust_for_absence;

      PROCEDURE select_weekly_hours (
         p_rule_to_pay              OUT NOCOPY   VARCHAR2,
         p_hours_to_pay_this_rule   OUT NOCOPY   NUMBER,
         p_element_type_id_to_pay   OUT NOCOPY   NUMBER
      )
      IS
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location ('select_weekly_hours', 1);
            hr_utility.TRACE
                      (   'p_element_type_id_to_pay i.e weekly_earning_type:'
                       || weekly_earning_type
                      );
            hr_utility.TRACE ('hours_left_to_pay :' || hours_left_to_pay);
            hr_utility.TRACE ('weekly_rule_cap:' || weekly_rule_cap);
            hr_utility.TRACE (   'hours_paid_weekly_rule :'
                              || hours_paid_weekly_rule
                             );
         END IF;

         p_rule_to_pay := 'WKL';
         p_element_type_id_to_pay :=      /* SPR C148 current_weekly_earning*/
                                                           weekly_earning_type;
         p_hours_to_pay_this_rule :=
            LEAST (hours_left_to_pay,
                   (weekly_rule_cap - hours_paid_weekly_rule
                   )
                  );

         IF g_debug
         THEN
            hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                              || p_hours_to_pay_this_rule
                             );
            hr_utility.set_location ('select_weekly_hours', 2);
         END IF;
      END select_weekly_hours;

--------------------------------------------------------------------------------
      PROCEDURE select_hol_weekly_hours (
         p_rule_to_pay              OUT NOCOPY   VARCHAR2,
         p_hours_to_pay_this_rule   OUT NOCOPY   NUMBER,
         p_element_type_id_to_pay   OUT NOCOPY   NUMBER
      )
      IS
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location ('select_hol_weekly_hours', 10);
            hr_utility.trace('hours_left_to_pay is '||hours_left_to_pay);
            hr_utility.trace('hours_paid_daily_rule '||hours_paid_daily_rule);
            hr_utility.trace('hours daily_rule_cap '||daily_rule_cap);
         END IF;

         p_rule_to_pay := 'DAY';
         p_hours_to_pay_this_rule :=
            LEAST (hours_left_to_pay,
                   (daily_rule_cap - hours_paid_daily_rule
                   )
                  );
         p_element_type_id_to_pay := daily_earning_type;

         IF g_debug
         THEN
            hr_utility.set_location ('select_hol_weekly_hours', 20);
         END IF;
      END select_hol_weekly_hours;

--------------------------------------------------------------------------------
      PROCEDURE select_rule_and_hours (
         p_error_code               OUT NOCOPY   NUMBER,
         p_rule_to_pay              OUT NOCOPY   VARCHAR2,
         p_hours_to_pay_this_rule   OUT NOCOPY   NUMBER,
         p_element_type_id          OUT NOCOPY   NUMBER
      )
      IS
         --  Selects the rule type, hours, and earning element id to be paid on the
         --  current sub-segment.
         --  Daily rules are paid until either weekly or special cap is hit.
         --  Special rule is only applicable if consecutive days have been reached.
         --  It then acts like a daily rule in that its base can be overridden by the
         --  weekly cap until the special hours cap is hit.
         --  returns 0 for success, 2 for error
         srh_rule              VARCHAR2 (4);
         --  local used for error checking
         l_error_return        NUMBER       := 0;
         l_first_weekly_rule   NUMBER;

         CURSOR get_weekly_cap (i_earn_policy NUMBER)
         IS
            SELECT   er.hours
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'WKL'
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

         lv_override_hrs       NUMBER       := 0;
         lv_override_element   NUMBER;
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location ('select_rule_and_hours', 10);
         END IF;

         OPEN get_weekly_cap (g_ep_id);

         FETCH get_weekly_cap
          INTO l_first_weekly_rule;

         IF g_debug
         THEN
            hr_utility.TRACE (   'first_weekly_rule           :'
                              || l_first_weekly_rule
                             );
         END IF;

         CLOSE get_weekly_cap;

         p_error_code := 0;

         IF consecutive_days_reached = FALSE
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('select_rule_and_hours', 20);
               hr_utility.TRACE (   'hours_paid_weekly_rule   :'
                                 || hours_paid_weekly_rule
                                );
               hr_utility.TRACE (   'weekly_rule_cap          :'
                                 || weekly_rule_cap
                                );
               hr_utility.TRACE (   'first_daily_rule_cap     :'
                                 || first_daily_rule_cap
                                );
               hr_utility.TRACE (   'get_weekly_total_to_date :'
                                 || get_weekly_total_to_date
                                );
               hr_utility.TRACE (   'l_first_weekly_rule      :'
                                 || l_first_weekly_rule
                                );
            END IF;

            IF (first_weekly_cap_reached = TRUE)
            THEN                                --  hours paid over weekly cap
               IF g_debug
               THEN
                  hr_utility.set_location ('Select_rule_and_hours', 30);
                  hr_utility.TRACE (   'hours_left_to_pay      :'
                                    || hours_left_to_pay
                                   );
                  hr_utility.TRACE (   'weekly_rule_cap        :'
                                    || weekly_rule_cap
                                   );
                  hr_utility.TRACE (   'hours_paid_weekly_rule :'
                                    || hours_paid_weekly_rule
                                   );
               END IF;

               -- MHANDA Added this code for SPECIAL g_ep_type,where there are
               -- more than two weekly earning caps for example:
               -- the earning policy having weekly earning rules as
               -- Weekly Regular    - 40 hrs
               -- Weekly Overtime   - 52 hrs
               -- Weekly Doubletime - 99 hrs
               srh_rule := 'WKL';

               IF g_debug
               THEN
                  hr_utility.set_location ('select_rule_and_hours', 40);
               END IF;

               p_hours_to_pay_this_rule :=
                  LEAST (hours_left_to_pay,
                         (weekly_rule_cap - hours_paid_weekly_rule
                         )
                        );
               p_element_type_id := weekly_earning_type;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule :'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE ('p_element_type_id :' || p_element_type_id);
               END IF;
             /*IF weekly_rule_cap > l_first_weekly_rule THEN
                IF second_weekly_cap_reached = TRUE THEN
                   srh_rule := 'WKL';
                       hr_utility.set_location('select_rule_and_hours',40);
                   p_hours_to_pay_this_rule := LEAST(hours_left_to_pay,
                                        (weekly_rule_cap - hours_paid_for_dtime_elig));
                   p_element_type_id := weekly_earning_type;
            hr_utility.trace('p_hours_to_pay_this_rule :'
                  ||p_hours_to_pay_this_rule);
            hr_utility.trace('p_element_type_id :'||p_element_type_id);
                ELSE
                   srh_rule := 'WKL';
                        hr_utility.set_location('select_rule_and_hours',50);
                   p_hours_to_pay_this_rule := LEAST(hours_left_to_pay,
                                           (weekly_rule_cap - hours_paid_weekly_rule));
                   p_element_type_id := weekly_earning_type;
            hr_utility.trace('p_hours_to_pay_this_rule :'
                  ||p_hours_to_pay_this_rule);
            hr_utility.trace('p_element_type_id :'||p_element_type_id);
                END IF;
             ELSE
                srh_rule := 'WKL';
                          hr_utility.set_location('select_rule_and_hours',60);
                p_hours_to_pay_this_rule := LEAST(hours_left_to_pay,
                                          (weekly_rule_cap - hours_paid_weekly_rule)) ;
                p_element_type_id := weekly_earning_type;
              hr_utility.trace('p_hours_to_pay_this_rule :'
                    ||p_hours_to_pay_this_rule);
              hr_utility.trace('p_element_type_id :'||p_element_type_id);
             END IF;*/
            ELSIF    (first_weekly_cap_reached = FALSE)
                  OR (    seven_day_cal_rule = TRUE
                      AND g_cons_days_worked = 5
                      AND p_rule_to_pay = 'DAY'
                     )
                  OR                        -- added this and condition for
                                            -- bug 1801337 because rule to pay
                                            -- is DAY
                     (five_day_cal_rule = TRUE AND g_cons_days_worked = 4
                     )
                  OR (    five_day_cal_rule = FALSE
                      AND seven_day_cal_rule = FALSE
                      AND get_weekly_total_to_date <
                             (  l_first_weekly_rule
                              - NVL (first_daily_rule_cap, 0)
                             )
                     )
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('select_rule_and_hours', 70);
               END IF;

               srh_rule := 'DAY';

               IF end_of_day_rules
               THEN
                  -- flag set when no more daily rules found
                  -- it is not an error at that time as it allowed as long as another
                  -- sub-segment does not need daily rules to pay
                  IF g_debug
                  THEN
                     hr_utility.set_location ('select_rule_and_hours', 80);
                  END IF;

                  fnd_message.set_name ('HXT', 'HXT_39294_ERN_RUL_NF');
                  p_error_code :=
                     call_hxthxc_gen_error ('HXT',
                                            'HXT_39294_ERN_RUL_NF',
                                            NULL,
                                            LOCATION,
                                            ''
                                           );
                  --2278400 p_error_code := call_gen_error(location, '');
                  p_hours_to_pay_this_rule := 0;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location ('select_rule_and_hours', 90);
                  END IF;

                  overtime_hoursoverride (g_date_worked,
                                          g_egt_id,
                                          g_tim_id,
                                          lv_override_hrs,
                                          lv_override_element
                                         );

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('lv_override_hrs   :'
                                       || lv_override_hrs
                                      );
                     hr_utility.TRACE (   'lv_override_element :'
                                       || lv_override_element
                                      );
                     hr_utility.set_location ('select_rule_and_hours', 91);
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE ('daily_rule_cap    :' || daily_rule_cap);
                     hr_utility.TRACE (   'hours_paid_daily_rule:'
                                       || hours_paid_daily_rule
                                      );
                     hr_utility.TRACE (   'first_daily_rule_cap :'
                                       || first_daily_rule_cap
                                      );
                  END IF;

                  IF (hours_paid_daily_rule - lv_override_hrs) <
                                                          first_daily_rule_cap
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location ('select_rule_and_hours',
                                                 100);
                     END IF;

                     p_hours_to_pay_this_rule :=
                        LEAST (LEAST (hours_left_to_pay,
                                        daily_rule_cap
                                      - (  hours_paid_daily_rule
                                         - lv_override_hrs
                                        )
                                     ),
                               (weekly_rule_cap - hours_paid_weekly_rule
                               )
                              );

                     -- Changed for Bug 1801337 because rule to pay is DAY
                     -- p_hours_to_pay_this_rule := LEAST(hours_left_to_pay,
                     --                           daily_rule_cap - hours_paid_daily_rule);
                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                          || p_hours_to_pay_this_rule
                                         );
                     END IF;

                     IF     daily_earning_type = lv_override_element
                        AND p_hours_to_pay_this_rule > lv_override_hrs
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location ('select_rule_and_hours',
                                                    101
                                                   );
                        END IF;

                        p_hours_to_pay_this_rule :=
                                    p_hours_to_pay_this_rule - lv_override_hrs;
                     ELSIF     daily_earning_type = lv_override_element
                           AND p_hours_to_pay_this_rule <= lv_override_hrs
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'lv_override_hrs:'
                                             || lv_override_hrs
                                            );
                           hr_utility.TRACE (   'daily_earning_type:'
                                             || daily_earning_type
                                            );
                           hr_utility.TRACE (   'first_daily_rule_cap:'
                                             || first_daily_rule_cap
                                            );
                        END IF;

                        IF lv_override_hrs >=
                                         daily_rule_cap - first_daily_rule_cap
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location
                                                    ('select_rule_and_hours',
                                                     102
                                                    );
                           END IF;

                           p_hours_to_pay_this_rule := 0;
                        END IF;
                     END IF;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location ('select_rule_and_hours',
                                                 105);
                        hr_utility.TRACE (   'hours_left_to_pay :'
                                          || hours_left_to_pay
                                         );
                        hr_utility.TRACE (   'daily_rule_cap    :'
                                          || daily_rule_cap
                                         );
                        hr_utility.TRACE (   'hours_paid_daily_rule:'
                                          || hours_paid_daily_rule
                                         );
                     END IF;

                     IF daily_earning_type = lv_override_element
                     THEN
                        IF hours_left_to_pay <=
                              (  daily_rule_cap
                               - (hours_paid_daily_rule - lv_override_hrs)
                              )
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location
                                                    ('select_rule_and_hours',
                                                     110
                                                    );
                           END IF;

                           p_hours_to_pay_this_rule :=
                              LEAST (hours_left_to_pay,
                                     (daily_rule_cap
                                      - (hours_paid_daily_rule)
                                     )
                                    );
                        ELSE
                           IF g_debug
                           THEN
                              hr_utility.set_location
                                                    ('select_rule_and_hours',
                                                     115
                                                    );
                           END IF;

                           p_hours_to_pay_this_rule :=
                              LEAST (hours_left_to_pay,
                                       daily_rule_cap
                                     - (hours_paid_daily_rule
                                        - lv_override_hrs
                                       )
                                    );
                        END IF;
                     ELSE
                        IF g_debug
                        THEN
                           hr_utility.set_location ('select_rule_and_hours',
                                                    116
                                                   );
                        END IF;

                        p_hours_to_pay_this_rule :=
                           LEAST (hours_left_to_pay,
                                    daily_rule_cap
                                  - (hours_paid_daily_rule - lv_override_hrs
                                    )
                                 );
                     END IF;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                          || p_hours_to_pay_this_rule
                                         );
                     END IF;

                     IF     daily_earning_type = lv_override_element
                        AND p_hours_to_pay_this_rule > lv_override_hrs
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location ('select_rule_and_hours',
                                                    120
                                                   );
                        END IF;

                        p_hours_to_pay_this_rule :=
                                    p_hours_to_pay_this_rule - lv_override_hrs;
                     ELSIF     daily_earning_type = lv_override_element
                           AND p_hours_to_pay_this_rule <= lv_override_hrs
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location ('select_rule_and_hours',
                                                    125
                                                   );
                           hr_utility.TRACE (   'lv_override_hrs:'
                                             || lv_override_hrs
                                            );
                           hr_utility.TRACE (   'daily_earning_type:'
                                             || daily_earning_type
                                            );
                           hr_utility.TRACE (   'first_daily_rule_cap:'
                                             || first_daily_rule_cap
                                            );
                        END IF;

                        IF lv_override_hrs >=
                                         daily_rule_cap - first_daily_rule_cap
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location
                                                    ('select_rule_and_hours',
                                                     130
                                                    );
                           END IF;

                           p_hours_to_pay_this_rule := 0;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('select_rule_and_hours', 135);
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
               END IF;

               p_element_type_id := daily_earning_type;

               IF g_debug
               THEN
                  hr_utility.TRACE ('p_element_type_id :' || p_element_type_id
                                   );
               END IF;
                  /*ELSE  --  hours paid over weekly cap
                     hr_utility.set_location('select_rule_and_hours',120);
               hr_utility.trace('hours_left_to_pay :'||hours_left_to_pay);
               hr_utility.trace('weekly_rule_cap   :'||weekly_rule_cap);
               hr_utility.trace('hours_paid_weekly_rule :'||hours_paid_weekly_rule);
            srh_rule := 'WKL';
                        hr_utility.set_location('select_rule_and_hours',130);
                                      p_hours_to_pay_this_rule := LEAST(hours_left_to_pay,(weekly_rule_cap -
                                                                  hours_paid_weekly_rule)) ;
                      p_element_type_id := weekly_earning_type;
               hr_utility.trace('p_hours_to_pay_this_rule :'||p_hours_to_pay_this_rule);
               hr_utility.trace('p_element_type_id :'||p_element_type_id);
             */
            END IF;
         ELSE                                   --  special days limit reached
            IF g_debug
            THEN
               hr_utility.set_location ('select_rule_and_hours', 140);
            END IF;

            IF hours_paid_daily_rule < special_daily_cap
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('select_rule_and_hours', 150);
               END IF;

               srh_rule := 'SPC';
               p_hours_to_pay_this_rule :=
                  LEAST (hours_left_to_pay,
                         (special_daily_cap - hours_paid_daily_rule
                         )
                        );
               p_element_type_id := special_earning_type;          -- SPR C355

               IF g_debug
               THEN
                  hr_utility.TRACE ('p_element_type_id :' || p_element_type_id
                                   );
               END IF;
            ELSE                        --  over special days and hours limits
               IF g_debug
               THEN
                  hr_utility.set_location ('select_rule_and_hours', 160);
               END IF;

               srh_rule := 'SPC';
               p_hours_to_pay_this_rule := hours_left_to_pay;
               p_element_type_id := special_earning_type2;

               -- SPR C355 - chg'd to type2
               IF g_debug
               THEN
                  hr_utility.TRACE ('p_element_type_id :' || p_element_type_id
                                   );
               END IF;
            END IF;
         END IF;

         p_rule_to_pay := srh_rule;

         IF g_debug
         THEN
            hr_utility.TRACE ('p_rule_to_pay :' || p_rule_to_pay);
         END IF;

         IF srh_rule IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('select_rule_and_hours', 170);
            END IF;

            fnd_message.set_name ('HXT', 'HXT_39295_ERN_TYPE_NF');
            p_error_code :=
               call_hxthxc_gen_error ('HXT',
                                      'HXT_39295_ERN_TYPE_NF',
                                      NULL,
                                      LOCATION,
                                      ''
                                     );
         --2278400 p_error_code := call_gen_error(location, '');
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('select_rule_and_hours', 180);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('select_rule_and_hours', 190);
            END IF;

            fnd_message.set_name ('HXT', 'HXT_39274_OR_ERR_SEL_ERN_TYP');
            p_error_code :=
               call_hxthxc_gen_error ('HXT',
                                      'HXT_39274_OR_ERR_SEL_ERN_TYP',
                                      NULL,
                                      LOCATION,
                                      '',
                                      SQLERRM
                                     );
      --2278400 p_error_code := call_gen_error(location, '', sqlerrm);
      END;

--------------------------------------------------------------------------------
      PROCEDURE use_points_to_select_rule_hrs (
         p_error_code               OUT NOCOPY   NUMBER,
         p_rule_to_pay              OUT NOCOPY   VARCHAR2,
         p_hours_to_pay_this_rule   OUT NOCOPY   NUMBER,
         p_element_type_id          OUT NOCOPY   NUMBER
      )
      IS
         CURSOR special_earning_rules (
            i_earn_policy   NUMBER,
            i_days          NUMBER,
            spc_hrs_paid    NUMBER
         )
         IS
            SELECT   er.hours, er.element_type_id, er.days
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'SPC'
                 AND er.days = i_days
                 AND er.days IS NOT NULL
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
                 AND er.hours > spc_hrs_paid
            ORDER BY er.days DESC, er.hours ASC;

         CURSOR daily_earning_rules (i_earn_policy NUMBER)
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'DAY'
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

         CURSOR daily_earning_rules2 (i_earn_policy NUMBER, daily_cap NUMBER)
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'DAY'
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
                 AND er.hours > daily_cap
            ORDER BY er.seq_no;

         CURSOR weekly_earning_rules (i_earn_policy NUMBER)
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'WKL'
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
            ORDER BY er.seq_no;

         CURSOR weekly_earning_rules2 (i_earn_policy NUMBER, weekly_cap NUMBER)
         IS
            SELECT   er.hours, er.element_type_id
                FROM hxt_earning_rules er
               WHERE er.egr_type = 'WKL'
                 AND er.egp_id = i_earn_policy
                 AND g_date_worked BETWEEN er.effective_start_date
                                       AND er.effective_end_date
                 AND er.hours > weekly_cap
            ORDER BY er.seq_no;

         CURSOR elements_in_earn_groups (i_earn_policy NUMBER)
         IS
            SELECT eg.element_type_id
              FROM hxt_earn_groups eg
             WHERE eg.egt_id = (SELECT ep.egt_id
                                  FROM hxt_earning_policies ep
                                 WHERE ep.ID = g_ep_id);

         CURSOR all_detail_hours_spc (
            cursor_day_worked   DATE,
            cursor_person_id    NUMBER,
            cursor_tim_id       NUMBER
         )
         IS
            SELECT daily_hours
              FROM hxt_daily_hours_worked_v
             WHERE work_date || '' = cursor_day_worked
               AND tim_id = cursor_tim_id;

         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR weekly_earn_category_total --(cp_earning_category VARCHAR2)  BUG 5499459
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt2,
                   hxt_det_hours_worked hrw,
                   hxt_timecards tim,
                   hxt_earn_groups erg,
                   hxt_earn_group_types egt,
                   hxt_earning_policies erp
             WHERE tim.for_person_id = g_person_id
               AND hrw.tim_id = tim.ID
               AND hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     g_start_day_of_week
                                                    )
                                       AND g_date_worked
               AND erp.ID = g_ep_id
               AND egt.ID = erp.egt_id
               AND erg.egt_id = egt.ID
               AND erg.element_type_id = hrw.element_type_id
               AND hrw.date_worked BETWEEN erp.effective_start_date
                                       AND erp.effective_end_date
               AND hrw.element_type_id = elt2.element_type_id
               AND hrw.date_worked BETWEEN elt2.effective_start_date
                                       AND elt2.effective_end_date
               AND elt2.element_type_id = eltv.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;
               --AND eltv.hxt_earning_category = cp_earning_category;  BUG 5499459
            */

         CURSOR weekly_earn_category_total --(cp_earning_category VARCHAR2)  BUG 5499459
         IS
            SELECT NVL (SUM (hrw.hours), 0)
              FROM hxt_pay_element_types_f_ddf_v eltv,
                   pay_element_types_f elt2,
                   hxt_det_hours_worked_f hrw,
                   hxt_timecards_f tim,
                   hxt_earn_groups erg,
                   hxt_earn_group_types egt,
                   hxt_earning_policies erp
             WHERE tim.for_person_id = g_person_id
               AND hrw.tim_id = tim.ID
               AND hrw.date_worked BETWEEN NEXT_DAY (g_date_worked - 7,
                                                     g_start_day_of_week
                                                    )
                                       AND g_date_worked
               AND g_det_session_date BETWEEN hrw.effective_start_date
                                          AND hrw.effective_end_date
               AND g_det_session_date BETWEEN tim.effective_start_date
                                          AND tim.effective_end_date
               AND erp.ID = g_ep_id
               AND egt.ID = erp.egt_id
               AND erg.egt_id = egt.ID
               AND erg.element_type_id = hrw.element_type_id
               AND hrw.date_worked BETWEEN erp.effective_start_date
                                       AND erp.effective_end_date
               AND hrw.element_type_id = elt2.element_type_id
               AND hrw.date_worked BETWEEN elt2.effective_start_date
                                       AND elt2.effective_end_date
               AND elt2.element_type_id = eltv.element_type_id
               AND hrw.date_worked BETWEEN eltv.effective_start_date
                                       AND eltv.effective_end_date;
               --AND eltv.hxt_earning_category = cp_earning_category;  BUG 5499459


         daily_element_type_id      NUMBER;
         daily_earning_cap          NUMBER;
         daily_earning_cap2         NUMBER;
         spc_daily_earning_cap      NUMBER;
         spc_element_type_id        NUMBER;
         special_days               NUMBER;
         weekly_element_type_id     NUMBER;
         l_combo_elem_id            NUMBER;
         weekly_earning_cap         NUMBER;
         weekly_earning_cap2        NUMBER;
         l_element_type_id          NUMBER;
         total_hours_to_pay         NUMBER         := 0;
         spc_hours_paid             NUMBER         := 0;
         total_hrs_worked_on_spc    NUMBER         := 0;
         spc_hours                  NUMBER         := 0;
         hours_paid_for_week        NUMBER         := 0;
         hours_paid_for_day         NUMBER         := 0;
         hours_for_points           NUMBER;
         --no.of hours considered for calculating
         --points for the current segment.
         hours_left                 NUMBER;
         --no.of hours left to be paid for the day.
         segment_points             NUMBER;
         --points assigned to the current element.
         total_daily_points         NUMBER         := 0;
         --summation of segment points for a day.
         total_weekly_points        NUMBER         := 0;
         --summation of segment points for weekly rule
         l_points_assigned          NUMBER;
         l_weekly_total             NUMBER;     --total hours worked that week
         l_daily_total              NUMBER;      --total hours worked that day
         l_daily_index              BINARY_INTEGER := 0;
         l_weekly_index             BINARY_INTEGER := 0;
         l_spc_index                BINARY_INTEGER := 0;
         k                          NUMBER         := 0;
         j                          NUMBER         := 0;
         h                          NUMBER         := 0;
         special_day                BOOLEAN        := FALSE;
         l_left_over_hours          NUMBER         := 0;
         l_category_index           BINARY_INTEGER := 0;
         l_wkl_category_index       BINARY_INTEGER := 0;
         l_dy_wk_combo_index        BINARY_INTEGER := 0;
         l_reg_for_day              NUMBER;
         l_dy_wk_reg_elem_id        NUMBER;
         l_ovt_for_day              NUMBER;
         l_dy_wk_ovt_elem_id        NUMBER;
         l_dt_for_day               NUMBER;
         l_dy_wk_dt_elem_id         NUMBER;
         wky_reg_incl_dy_reg_expl   NUMBER;
         l_weekly_reg_hrs           NUMBER;
         l_weekly_reg_cap           NUMBER;
         total_combo_points         NUMBER         := 0;
         l_greatest_points          NUMBER         := 0;
         l_total_daily_hrs          NUMBER         := 0;
         l_total_combo_hrs          NUMBER         := 0;
         use_weekly_reg             VARCHAR2 (1)   := 'N';
         use_weekly_ot              VARCHAR2 (1)   := 'N';
         use_weekly_dt              VARCHAR2 (1)   := 'N';
         use_daily_reg              VARCHAR2 (1)   := 'N';
         use_daily_ot               VARCHAR2 (1)   := 'N';
         use_daily_dt               VARCHAR2 (1)   := 'N';
         l_override_hrs             NUMBER         := 0;
         l_override_element         NUMBER;
         hrs_already_paid           BOOLEAN        := FALSE;
         prev_daily_cap             NUMBER         := 0;
         prev_weekly_cap            NUMBER         := 0;
         l_proc                     VARCHAR2 (50);

         PROCEDURE init_for_wkl_combine_pts_cal (
            l_use_weekly_reg           IN              VARCHAR2,
            l_use_weekly_ot            IN              VARCHAR2,
            l_use_weekly_dt            IN              VARCHAR2,
            l_weekly_reg_cap           IN              NUMBER,
            l_dy_wk_reg_elem_id        OUT NOCOPY      pay_element_types_f.element_type_id%TYPE,
            l_dy_wk_ovt_elem_id        OUT NOCOPY      pay_element_types_f.element_type_id%TYPE,
            l_dy_wk_dt_elem_id         OUT NOCOPY      pay_element_types_f.element_type_id%TYPE,
            l_use_daily_reg            OUT NOCOPY      VARCHAR2,
            l_use_daily_ot             OUT NOCOPY      VARCHAR2,
            l_use_daily_dt             OUT NOCOPY      VARCHAR2,
            l_reg_for_day              OUT NOCOPY      NUMBER,
            l_ovt_for_day              OUT NOCOPY      NUMBER,
            l_dt_for_day               OUT NOCOPY      NUMBER,
            wky_reg_incl_dy_reg_expl   OUT NOCOPY      NUMBER,
            l_weekly_reg_hrs           OUT NOCOPY      NUMBER
         )
         IS
            l_proc   VARCHAR2 (50);
         BEGIN
            IF g_debug
            THEN
               l_proc := 'HXT_TIME_DETAIL.init_for_wkl_combine_pts_cal';
               hr_utility.set_location (l_proc, 10);
            END IF;

            OPEN weekly_earn_category_total; --('REG');

            FETCH weekly_earn_category_total
             INTO l_weekly_reg_hrs;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_weekly_REG_hrs:' || l_weekly_reg_hrs);
            END IF;

            CLOSE weekly_earn_category_total;

            -- Determine the daily REG, OT, DT hrs and the element types
            -- that need to be used for the rest of the week's explosion.
            FOR i IN 1 .. g_daily_explosion.COUNT
            LOOP
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 20);
               END IF;

               IF g_daily_explosion (i).earning_category = 'REG'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 30);
                  END IF;

                  l_reg_for_day := g_daily_explosion (i).hours_to_pay;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_reg_for_day:' || l_reg_for_day);
                  END IF;

                  IF     l_weekly_reg_hrs >= l_weekly_reg_cap
                     AND l_use_weekly_reg = 'Y'
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 40);
                     END IF;

                     l_dy_wk_reg_elem_id :=
                                    g_weekly_earn_category (i).element_type_id;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 50);
                     END IF;

                     l_use_daily_reg := 'Y';
                     l_dy_wk_reg_elem_id :=
                                         g_daily_explosion (i).element_type_id;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 60);
                     hr_utility.TRACE (   'l_dy_wk_reg_elem_id:'
                                       || l_dy_wk_reg_elem_id
                                      );
                  END IF;
               ELSIF g_daily_explosion (i).earning_category = 'OVT'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 70);
                  END IF;

                  l_ovt_for_day := g_daily_explosion (i).hours_to_pay;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_ovt_for_day:' || l_ovt_for_day);
                  END IF;

                  IF     l_weekly_reg_hrs >= l_weekly_reg_cap
                     AND use_weekly_ot = 'Y'
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 80);
                     END IF;

                     l_dy_wk_ovt_elem_id :=
                                    g_weekly_earn_category (i).element_type_id;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 90);
                     END IF;

                     l_use_daily_ot := 'Y';
                     l_dy_wk_ovt_elem_id :=
                                         g_daily_explosion (i).element_type_id;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 100);
                     hr_utility.TRACE (   'l_dy_wk_ovt_elem_id:'
                                       || l_dy_wk_ovt_elem_id
                                      );
                  END IF;
               ELSIF g_daily_explosion (i).earning_category = 'DT'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 110);
                  END IF;

                  l_dt_for_day := g_daily_explosion (i).hours_to_pay;

                  IF     l_weekly_reg_hrs >= l_weekly_reg_cap
                     AND use_weekly_dt = 'Y'
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 120);
                     END IF;

                     l_dy_wk_dt_elem_id :=
                                    g_weekly_earn_category (i).element_type_id;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 130);
                     END IF;

                     l_use_daily_dt := 'Y';
                     l_dy_wk_dt_elem_id :=
                                         g_daily_explosion (i).element_type_id;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 140);
                     hr_utility.TRACE ('l_dt_for_day:' || l_dt_for_day);
                     hr_utility.TRACE (   'l_dy_wk_dt_elem_id:'
                                       || l_dy_wk_dt_elem_id
                                      );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 150);
               END IF;
            END LOOP;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 160);
            END IF;

            OPEN weekly_earning_rules (g_ep_id);

            FETCH weekly_earning_rules
             INTO weekly_earning_cap, weekly_element_type_id;

            IF g_debug
            THEN
               hr_utility.TRACE ('weekly_earning_cap:' || weekly_earning_cap);
               hr_utility.TRACE (   'weekly_element_type_id:'
                                 || weekly_element_type_id
                                );
            END IF;

            CLOSE weekly_earning_rules;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 170);
               hr_utility.TRACE ('l_weekly_reg_hrs:' || l_weekly_reg_hrs);
               hr_utility.TRACE ('l_reg_for_day:' || l_reg_for_day);
            END IF;

            -- Calculate the weekly reg total including today's REG hrs
            wky_reg_incl_dy_reg_expl := l_weekly_reg_hrs + l_reg_for_day;

            IF g_debug
            THEN
               hr_utility.TRACE (   'wky_reg_incl_dy_reg_expl:'
                                 || wky_reg_incl_dy_reg_expl
                                );
               hr_utility.set_location (l_proc, 180);
            END IF;
         END;
      --  Selects the rule type, hours, and earning element id to be paid on the
      --  current sub-segment.
      --  Populate the  daily array with the daily explosion based on the daily
      --  earning rules and the weekly array with the weekly explosion based on the
      --  weekly earning rules.
      --  Calculate the daily and the weekly points based on the rules and the
      --  points counter,for example
      --  Setup Data:
      --  Earnings Group    Regular
      --  Earnings Policy                 Extra Element Information Points Assigned
      --    Daily       Regular     8           Regular      1
      --    Daily       Overtime    12          Overtime    1.5
      --    Daily       DoubleTime  24          Double Time 2
      --    Weekly      Regular     40          Holiday     0
      --    Weekly      Overtime    999
      --    Special - 7 Overtime    8
      --    Special - 7 DoubleTime  24
      --    Holiday     Holiday     8
      --
      --  Earnings Policy Explosion  would be ,if working 14 hrs a day :
      --   Say Monday -14 Hours
      --                8/4/2(Daily Rule)  -Points:(8x1)+(4x1.5)+(2x2)= 18
      --               14/0/0 (Weekly Rule)-Points:(14x1)             = 14
      --  Use the rule that produces the higher number of points.
      --  Special rule is only applicable if consecutive days have been reached.
      --  It then acts like a daily rule in that its base can be overridden by the
      --  weekly cap until the special hours cap is hit.
      --  returns 0 for success, 2 for error
      --  Set hours_left_to_pay = 0 when last record from the array is fetched
      BEGIN
         g_debug := hr_utility.debug_enabled;

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;



         IF g_debug
         THEN
            l_proc := 'hxt_time_detail.use_points_to_select_rule_hrs';
            hr_utility.set_location (l_proc, 10);
         END IF;

         -- Populate the g_daily_earn_category plsql table with element type, hrs
         -- and earning Category for each element.
         FOR daily_categories IN daily_earning_rules (g_ep_id)
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 15);
               hr_utility.TRACE (   'daily_categories.hours :'
                                 || daily_categories.hours
                                );
               hr_utility.TRACE (   'daily_categories.element_type_id :'
                                 || daily_categories.element_type_id
                                );
            END IF;

            l_category_index := l_category_index + 1;
            g_daily_earn_category (l_category_index).element_type_id :=
                                              daily_categories.element_type_id;
            g_daily_earn_category (l_category_index).hours :=
                                                        daily_categories.hours;

            IF l_category_index = 1
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 20);
               END IF;

               g_daily_earn_category (l_category_index).earning_category :=
                                                                         'REG';
            ELSIF l_category_index = 2
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 25);
               END IF;

               g_daily_earn_category (l_category_index).earning_category :=
                                                                         'OVT';
            ELSIF l_category_index = 3
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 30);
               END IF;

               g_daily_earn_category (l_category_index).earning_category :=
                                                                          'DT';
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 35);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 40);
         END IF;

         FOR i IN 1 .. g_daily_earn_category.COUNT
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 45);
               hr_utility.TRACE (   'daily_element_type_id:'
                                 || g_daily_earn_category (i).element_type_id
                                );
               hr_utility.TRACE (   'daily_hours:'
                                 || g_daily_earn_category (i).hours
                                );
               hr_utility.TRACE (   'daily_earning_category:'
                                 || g_daily_earn_category (i).earning_category
                                );
               hr_utility.set_location (l_proc, 50);
            END IF;
         END LOOP;

         -- Populate the g_weekly_earn_category plsql table with element type, hrs
         -- and earning Category for each element.
         FOR weekly_categories IN weekly_earning_rules (g_ep_id)
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 55);
               hr_utility.TRACE (   'weekly_categories.hours :'
                                 || weekly_categories.hours
                                );
               hr_utility.TRACE (   'weekly_categories.element_type_id :'
                                 || weekly_categories.element_type_id
                                );
            END IF;

            l_wkl_category_index := l_wkl_category_index + 1;
            g_weekly_earn_category (l_wkl_category_index).element_type_id :=
                                             weekly_categories.element_type_id;
            g_weekly_earn_category (l_wkl_category_index).hours :=
                                                       weekly_categories.hours;

            IF l_wkl_category_index = 1
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 60);
               END IF;

               g_weekly_earn_category (l_wkl_category_index).earning_category :=
                                                                         'REG';
               l_weekly_reg_cap :=
                           g_weekly_earn_category (l_wkl_category_index).hours;

               IF g_weekly_earn_category (1).element_type_id <>
                                     g_daily_earn_category (1).element_type_id
               THEN
                  use_weekly_reg := 'Y';
               END IF;
            ELSIF l_wkl_category_index = 2
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 65);
               END IF;

               g_weekly_earn_category (l_wkl_category_index).earning_category :=
                                                                         'OVT';

               IF g_weekly_earn_category (2).element_type_id <>
                                     g_daily_earn_category (2).element_type_id
               THEN
                  use_weekly_ot := 'Y';
               END IF;
            ELSIF l_wkl_category_index = 3
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 70);
               END IF;

               g_weekly_earn_category (l_wkl_category_index).earning_category :=
                                                                          'DT';

               IF g_weekly_earn_category (3).element_type_id <>
                                     g_daily_earn_category (3).element_type_id
               THEN
                  use_weekly_dt := 'Y';
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 75);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 80);
         END IF;

         FOR i IN 1 .. g_weekly_earn_category.COUNT
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 85);
               hr_utility.TRACE (   'weekly_element_type_id:'
                                 || g_weekly_earn_category (i).element_type_id
                                );
               hr_utility.TRACE (   'weekly_hours:'
                                 || g_weekly_earn_category (i).hours
                                );
               hr_utility.TRACE (   'weekly_earning_category:'
                                 || g_weekly_earn_category (i).earning_category
                                );
               hr_utility.set_location (l_proc, 90);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 100);
            hr_utility.TRACE ('g_explosion_to_use :' || g_explosion_to_use);
         END IF;

         IF g_explosion_to_use IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 110);
            END IF;

            IF g_explosion_to_use = 'SPC'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 120);
               END IF;

               FOR i IN g_special_explosion.FIRST .. g_special_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 130);
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                                (   'g_special_explosion(i).element_type_id:'
                                 || g_special_explosion (i).element_type_id
                                );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 140);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'SPC';
               p_hours_to_pay_this_rule :=
                                    g_special_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                                 g_special_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_special_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 150);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;
                  special_day := FALSE;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                  END IF;
               END IF;

               RETURN;
            ELSIF g_explosion_to_use = 'COMBO'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 160);
               END IF;

               FOR i IN
                  g_dy_wk_combo_explosion.FIRST .. g_dy_wk_combo_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                            (   'g_dy_wk_combo_explosion(i).element_type_id:'
                             || g_dy_wk_combo_explosion (i).element_type_id
                            );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 165);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'DAY';
               p_hours_to_pay_this_rule :=
                                g_dy_wk_combo_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                             g_dy_wk_combo_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_dy_wk_combo_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 170);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                  END IF;
               END IF;

               RETURN;
            ELSIF g_explosion_to_use = 'DAILY'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 175);
               END IF;

               FOR i IN g_daily_explosion.FIRST .. g_daily_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                                  (   'g_daily_explosion(i).element_type_id:'
                                   || g_daily_explosion (i).element_type_id
                                  );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 180);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'DAY';
               p_hours_to_pay_this_rule :=
                                      g_daily_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                                   g_daily_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_daily_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 185);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                  END IF;
               END IF;

               RETURN;
            ELSIF g_explosion_to_use = 'WEEKLY'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 190);
               END IF;

               FOR i IN g_weekly_explosion.FIRST .. g_weekly_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                                 (   'g_weekly_explosion(i).element_type_id:'
                                  || g_weekly_explosion (i).element_type_id
                                 );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 200);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'WKL';
               p_hours_to_pay_this_rule :=
                                     g_weekly_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                                  g_weekly_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_weekly_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 210);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                     hr_utility.TRACE ('g_count           :' || g_count);
                  END IF;
               END IF;

               RETURN;
            END IF;
         ELSIF g_explosion_to_use IS NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 220);
               hr_utility.TRACE ('g_ep_id :' || g_ep_id);
            END IF;

            IF consecutive_days_reached = TRUE
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 230);
               END IF;

               -- Get the contiguous hours worked on the special day
               -- Following code changed to fix 2839573
               spc_hours_paid := NVL (previous_detail_hours_day, 0);

               IF g_debug
               THEN
                  hr_utility.TRACE ('spc_hours_paid :' || spc_hours_paid);
                  hr_utility.TRACE ('g_hours :' || g_hours);
               END IF;

               total_hrs_worked_on_spc := g_hours + NVL (spc_hours_paid, 0);

               IF g_debug
               THEN
                  hr_utility.TRACE (   'total_hrs_worked_on_spc :'
                                    || total_hrs_worked_on_spc
                                   );
               END IF;

                /*
                   IF g_time_in IS NOT NULL
                   THEN
                              hr_utility.set_location (l_proc, 240);
                       spc_hours_paid :=
                          contig_hours_worked (g_date_worked, g_egt_id, g_tim_id);
               hr_utility.TRACE ('spc_hours_paid :' || spc_hours_paid);
               hr_utility.TRACE ('g_hours :' || g_hours);
                      total_hrs_worked_on_spc :=
                                                g_hours + NVL (spc_hours_paid, 0);
               hr_utility.TRACE (   'total_hrs_worked_on_spc :'
                       || total_hrs_worked_on_spc
                      );
                 ELSE
                              hr_utility.set_location (l_proc, 250);
                      OPEN all_detail_hours_spc (g_date_worked,
                                                 g_person_id,
                                                 g_tim_id
                                                );

                      FETCH all_detail_hours_spc
                       INTO spc_hours_paid;

                              hr_utility.TRACE ('spc_hours_paid :' || spc_hours_paid);
                      CLOSE all_detail_hours_spc;

                              hr_utility.TRACE ('g_hours :' || g_hours);
                      total_hrs_worked_on_spc := g_hours + NVL (spc_hours_paid, 0);
               hr_utility.TRACE (   'total_hrs_worked_on_spc :'
                       || total_hrs_worked_on_spc
                      );
                   END IF;
                */
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 240);
               END IF;

               -- Commented out the following as the fix for 2828201 was to do with
               -- the total hours not being calculated correctly when entering time
               -- as HOURS rather than time in/time out.
               -- This was fixed by adding the cursor all_detail_hours_spc to calculate
               -- the total hours worked on the SPC day when entering time as straight
               -- hours, whether hours entered for the SPC day being entered on a single
               -- row(bug 2828201) or multiple rows(bug 2839573).

               -- Moved outside loop for bug 2828201
                   -- total_hrs_worked_on_spc := g_hours + spc_hours_paid;
               -- END IF;
               -- total_hrs_worked_on_spc := g_hours + NVL(spc_hours_paid,0);

               -- next line changed as follows for bug 2852695
               -- OPEN special_earning_rules(g_ep_id, consec_days_worked);
               OPEN special_earning_rules (g_ep_id,
                                           consec_days_worked,
                                           spc_hours_paid
                                          );

               LOOP
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 270);
                  END IF;

                  FETCH special_earning_rules
                   INTO spc_daily_earning_cap, spc_element_type_id,
                        special_days;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'spc_daily_earning_cap     :'
                                       || spc_daily_earning_cap
                                      );
                     hr_utility.TRACE (   'spc_element_type_id       :'
                                       || spc_element_type_id
                                      );
                     hr_utility.TRACE (   'special_days              :'
                                       || special_days
                                      );
                     hr_utility.TRACE (   'spc_hours_paid            :'
                                       || spc_hours_paid
                                      );
                     hr_utility.TRACE ('g_hours                   :'
                                       || g_hours
                                      );
                     hr_utility.TRACE (   'total_hrs_worked_on_spc   :'
                                       || total_hrs_worked_on_spc
                                      );
                  END IF;

                  EXIT WHEN spc_hours_paid = total_hrs_worked_on_spc
                        OR special_earning_rules%NOTFOUND;

                  IF special_earning_rules%FOUND
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 280);
                     END IF;

                     special_day := TRUE;
                     g_explosion_to_use := 'SPC';
                  END IF;

                  IF spc_hours_paid < total_hrs_worked_on_spc
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 290);
                     END IF;

                     spc_hours :=
                        LEAST ((spc_daily_earning_cap - spc_hours_paid),
                               (total_hrs_worked_on_spc - spc_hours_paid
                               )
                              );
                     l_spc_index := l_spc_index + 1;
                     g_special_explosion (l_spc_index).element_type_id :=
                                                           spc_element_type_id;
                     g_special_explosion (l_spc_index).hours_to_pay :=
                                                                     spc_hours;

                     FOR i IN 1 .. g_special_explosion.COUNT
                     LOOP
                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                      (   'spc_element_type_id:'
                                       || g_special_explosion (i).element_type_id
                                      );
                           hr_utility.TRACE
                                          (   'hours_to_pay in plsql table:'
                                           || g_special_explosion (i).hours_to_pay
                                          );
                        END IF;
                     END LOOP;

                     spc_hours_paid := spc_hours_paid + spc_hours;

                     IF g_debug
                     THEN
                        hr_utility.TRACE ('spc_hours_paid:' || spc_hours_paid);
                     END IF;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 300);
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 310);
               END IF;

               CLOSE special_earning_rules;
            END IF;

            IF special_day = FALSE
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 320);
               END IF;

--
-----------------------------BEGIN Daily Points Calculation---------------------
--
               OPEN daily_earning_rules (g_ep_id);

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 330);
               END IF;

-- Commented out the following. Instead calling the adjust_for_hdp funtion
-- to determine the hours that are left to be paid, since hours need to be
-- deducted based on the hour deduction policy if assigned to the employee.
-- hours_left := g_hours;
            -- hours_left := adjust_for_hdp (p_hours_worked, error_code);
               hours_left := p_hours_worked;

               IF g_debug
               THEN
                  hr_utility.TRACE ('hours_left :' || hours_left);
                  hr_utility.TRACE ('l_override_hrs :' || l_override_hrs);
                  hr_utility.TRACE (   'g_date_worked :'
                                    || TO_CHAR (g_date_worked,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE ('g_egt_id :' || g_egt_id);
                  hr_utility.TRACE ('g_tim_id :' || g_tim_id);
               END IF;

               overtime_hoursoverride (g_date_worked,
                                       g_egt_id,
                                       g_tim_id,
                                       l_override_hrs,
                                       l_override_element
                                      );

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_override_hrs   :' || l_override_hrs);
                  hr_utility.TRACE (   'l_override_element :'
                                    || l_override_element
                                   );
               END IF;

               LOOP
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 340);
                  END IF;

                  hrs_already_paid := FALSE;
                  h := h + 1;

                  FETCH daily_earning_rules
                   INTO daily_earning_cap, daily_element_type_id;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'daily_earning_cap     :'
                                       || daily_earning_cap
                                      );
                     hr_utility.TRACE (   'daily_element_type_id :'
                                       || daily_element_type_id
                                      );
                  END IF;

                  IF h = 1
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 350);
                     END IF;

                     hours_paid_for_day := NVL (previous_detail_hours_day, 0);
                     --hours_paid_for_day:=hours_paid_for_day-2;
                     -- Changed the following to take into account the hour deduction policy.
                     -- Total hours to pay should be the hours left after deducting the hours
                     -- based on the hour deduction policy.
                     -- total_hours_to_pay :=  g_hours + hours_paid_for_day;
                     total_hours_to_pay := hours_left + hours_paid_for_day;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 360);
                     hr_utility.TRACE (   'hours_paid_for_day   :'
                                       || hours_paid_for_day
                                      );
                     hr_utility.TRACE ('g_hours              :' || g_hours);
                     hr_utility.TRACE (   'total_hours_to_pay   :'
                                       || total_hours_to_pay
                                      );
                  END IF;

                  EXIT WHEN hours_left = 0 AND h > 1;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 370);
                  END IF;

                  /* IF hours_paid_for_day < total_hours_to_pay THEN
                      hr_utility.set_location(l_proc,100);
                      hours_for_points := LEAST( (daily_earning_cap - hours_paid_for_day)
                                                ,(g_hours - hours_paid_for_day) );
                      hr_utility.trace('hours_for_points :'||hours_for_points);
                  */
                  /*  IF hours_paid_for_day < daily_earning_cap THEN
                      hours_for_points :=LEAST(g_hours,(daily_earning_cap - hours_paid_for_day));
                      hr_utility.set_location(l_proc,100);
                      hr_utility.trace('hours_for_points :'||hours_for_points);
                  */
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('hours_left:' || hours_left);
                     hr_utility.TRACE (   'hours_paid_for_day:'
                                       || hours_paid_for_day
                                      );
                     hr_utility.TRACE ('l_override_hrs:' || l_override_hrs);
                     hr_utility.TRACE (   'daily_earning_cap:'
                                       || daily_earning_cap
                                      );
                  END IF;

                  IF hours_left >= 0
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 380);
                     END IF;

                     IF (hours_paid_for_day - l_override_hrs) >=
                                                             daily_earning_cap
                     THEN
                        -- Commented the next line for bug 2853355 since l_daily_total is not
                        -- used anymore.
                        -- OR l_daily_total >= daily_earning_cap THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 390);
                        END IF;

                        -- next line changed for bug 2822172
                        OPEN daily_earning_rules2 (g_ep_id,
                                                     hours_paid_for_day
                                                   - l_override_hrs
                                                  );

                        -- daily_earning_cap);
                        FETCH daily_earning_rules2
                         INTO daily_earning_cap2, daily_element_type_id;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'daily_earning_cap2    :'
                                             || daily_earning_cap2
                                            );
                           hr_utility.TRACE (   'daily_element_type_id :'
                                             || daily_element_type_id
                                            );
                        END IF;

                        CLOSE daily_earning_rules2;

                        hours_for_points :=
                           LEAST ((daily_earning_cap2 - hours_paid_for_day),
                                  hours_left
                                 );

			-- Added the following for Bug:5095198

                        IF     daily_element_type_id = l_override_element
                              AND hours_for_points <= l_override_hrs
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'l_override_hrs:'
                                                || l_override_hrs
                                               );
                              hr_utility.TRACE (   'daily_earning_cap2:'
                                                || daily_earning_cap2
                                               );
                              hr_utility.TRACE (   'daily_earning_cap:'
                                                || daily_earning_cap
                                               );
                           END IF;

                           IF l_override_hrs >=
                                            daily_earning_cap2 - daily_earning_cap
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 390.1);
                              END IF;

                              hrs_already_paid := TRUE;
                              hours_for_points := 0;
                              segment_points := 0;
			   END IF;
			END IF;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_for_points :'
                                             || hours_for_points
                                            );
                        END IF;
                     ELSE
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 400);
                        END IF;

                        IF daily_element_type_id = l_override_element
                        THEN
                           IF hours_left <=
                                 (  daily_earning_cap
                                  - (hours_paid_for_day - l_override_hrs)
                                 )
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 400.1);
                              END IF;

                              hours_for_points :=
                                 LEAST (hours_left,
                                        (  daily_earning_cap
                                         - (hours_paid_for_day)
                                        )
                                       );
                           ELSE
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 400.2);
                              END IF;

                              hours_for_points :=
                                 LEAST (hours_left,
                                        (  daily_earning_cap
                                         - (hours_paid_for_day
                                            - l_override_hrs
                                           )
                                        )
                                       );
                           END IF;
                        ELSE
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 400.3);
                           END IF;

                           hours_for_points :=
                              LEAST (hours_left,
                                     (  daily_earning_cap
                                      - (hours_paid_for_day - l_override_hrs
                                        )
                                     )
                                    );
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_for_points :'
                                             || hours_for_points
                                            );
                        END IF;

                        -- Say for example entering time as follows:
                        -- hrs   element
                        -- 13   (no override)
                        -- 2     OT
                        -- This should explode to
                        -- 13 hrs -> 8/2/3
                        -- 2 OT   ->   2
                        -- From the above logic we get the hours for the 2nd
                        -- Daily Cap element i.e., LEAST(5,(12-(10 - 2))
                        -- i.e., 4 hrs OT
                        -- But since 2 hrs OT already overriden => (4 - 2)OT left
                        -- to be paid
                        IF     daily_element_type_id = l_override_element
                           AND hours_for_points > l_override_hrs
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 401);
                           END IF;

                           hrs_already_paid := FALSE;
                           hours_for_points :=
                                             hours_for_points - l_override_hrs;
                        ELSIF     daily_element_type_id = l_override_element
                              AND hours_for_points <= l_override_hrs
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'l_override_hrs:'
                                                || l_override_hrs
                                               );
                              hr_utility.TRACE (   'daily_earning_cap:'
                                                || daily_earning_cap
                                               );
                              hr_utility.TRACE (   'prev_daily_cap:'
                                                || prev_daily_cap
                                               );
                           END IF;

                           IF l_override_hrs >=
                                            daily_earning_cap - prev_daily_cap
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 402);
                              END IF;

                              hrs_already_paid := TRUE;
                              hours_for_points := 0;
                              segment_points := 0;
                           ELSE
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 402.1);
                              END IF;

                              hrs_already_paid := FALSE;
                           END IF;
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 403);
                           hr_utility.TRACE (   'hours_for_points :'
                                             || hours_for_points
                                            );
                        END IF;
                     END IF;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 405);
                        hr_utility.TRACE ('segment_points:' || segment_points);
                     END IF;

                     IF hrs_already_paid = FALSE
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 410);
                        END IF;

                        hours_left := (hours_left - (hours_for_points));

                        IF g_debug
                        THEN
                           hr_utility.TRACE ('hours_left :' || hours_left);
                        END IF;

                        SELECT NVL (points_assigned, 0)
                          INTO l_points_assigned
                          FROM hxt_add_elem_info_f aei
                         WHERE aei.element_type_id = daily_element_type_id
                           AND g_date_worked BETWEEN aei.effective_start_date
                                                 AND aei.effective_end_date;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_points_assigned :'
                                             || l_points_assigned
                                            );
                        END IF;

                        segment_points := hours_for_points * l_points_assigned;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'segment_points :'
                                             || segment_points
                                            );
                        END IF;

                        l_daily_index := l_daily_index + 1;
                        g_daily_explosion (l_daily_index).element_type_id :=
                                                         daily_element_type_id;
                        g_daily_explosion (l_daily_index).hours_to_pay :=
                                                              hours_for_points;

                        FOR i IN 1 .. g_daily_earn_category.COUNT
                        LOOP
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 420);
                              hr_utility.TRACE (   'daily_element_type_id:'
                                                || daily_element_type_id
                                               );
                              hr_utility.TRACE
                                 (   'g_daily_earn_category(i).element_type_id:'
                                  || g_daily_earn_category (i).element_type_id
                                 );
                           END IF;

                           IF g_daily_earn_category (i).element_type_id =
                                                         daily_element_type_id
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 430);
                              END IF;

                              g_daily_explosion (l_daily_index).earning_category :=
                                    g_daily_earn_category (i).earning_category;
                           END IF;

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 440);
                           END IF;
                        END LOOP;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 450);
                        END IF;

                        FOR i IN 1 .. g_daily_explosion.COUNT
                        LOOP
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 460);
                              hr_utility.TRACE
                                        (   'daily_element_type_id:'
                                         || g_daily_explosion (i).element_type_id
                                        );
                              hr_utility.TRACE
                                            (   'hours_to_pay in plsql table:'
                                             || g_daily_explosion (i).hours_to_pay
                                            );
                              hr_utility.set_location (l_proc, 470);
                           END IF;
                        END LOOP;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 480);
                        END IF;

                        -- Added the following for bug 2853355.
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 490);
                           hr_utility.TRACE (   'hours_paid_for_day:'
                                             || hours_paid_for_day
                                            );
                           hr_utility.TRACE (   'hours_for_points:'
                                             || hours_for_points
                                            );
                           hr_utility.TRACE (   'l_override_hrs:'
                                             || l_override_hrs
                                            );
                        END IF;

                        hours_paid_for_day :=
                                         hours_paid_for_day + hours_for_points;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_paid_for_day:'
                                             || hours_paid_for_day
                                            );
                           hr_utility.set_location (l_proc, 500);
                        END IF;
                     END IF;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 510);
                  END IF;

                  total_daily_points := total_daily_points + segment_points;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'total_daily_points :'
                                       || total_daily_points
                                      );
                  END IF;

                  prev_daily_cap := daily_earning_cap;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('prev_daily_cap:' || prev_daily_cap);
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'total_hours_to_pay :'
                                       || total_hours_to_pay
                                      );
                     hr_utility.TRACE (   'hours_paid_for_day :'
                                       || hours_paid_for_day
                                      );
                  END IF;

                  -- EXIT WHEN hours_paid_for_day = g_hours;
                  -- EXIT WHEN total_hours_to_pay = hours_paid_for_day;
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 520);
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 530);
               END IF;

               CLOSE daily_earning_rules;

--
------------------------------END Daily Points calculation----------------------
--
--
---------------------------BEGIN Weekly Points Calculation----------------------
--
               IF g_debug
               THEN
                  hr_utility.TRACE ('use_weekly_REG:' || use_weekly_reg);
                  hr_utility.TRACE ('use_weekly_OT:' || use_weekly_ot);
                  hr_utility.TRACE ('use_weekly_DT:' || use_weekly_dt);
                  hr_utility.TRACE ('l_weekly_reg_cap:' || l_weekly_reg_cap);
               END IF;

               -- Initialize the variables before calculating the weekly points
               init_for_wkl_combine_pts_cal (use_weekly_reg,
                                             use_weekly_ot,
                                             use_weekly_dt,
                                             l_weekly_reg_cap,
                                             l_dy_wk_reg_elem_id,
                                             l_dy_wk_ovt_elem_id,
                                             l_dy_wk_dt_elem_id,
                                             use_daily_reg,
                                             use_daily_ot,
                                             use_daily_dt,
                                             l_reg_for_day,
                                             l_ovt_for_day,
                                             l_dt_for_day,
                                             wky_reg_incl_dy_reg_expl,
                                             l_weekly_reg_hrs
                                            );

               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_dy_wk_reg_elem_id:'
                                    || l_dy_wk_reg_elem_id
                                   );
                  hr_utility.TRACE (   'l_dy_wk_ovt_elem_id:'
                                    || l_dy_wk_ovt_elem_id
                                   );
                  hr_utility.TRACE ('l_dy_wk_dt_elem_id:'
                                    || l_dy_wk_dt_elem_id
                                   );
                  hr_utility.TRACE ('use_daily_reg:' || use_daily_reg);
                  hr_utility.TRACE ('use_daily_ot:' || use_daily_ot);
                  hr_utility.TRACE ('use_daily_dt:' || use_daily_dt);
                  hr_utility.TRACE ('l_reg_for_day:' || l_reg_for_day);
                  hr_utility.TRACE ('l_ovt_for_day:' || l_ovt_for_day);
                  hr_utility.TRACE ('l_dt_for_day:' || l_dt_for_day);
                  hr_utility.TRACE (   'wky_reg_incl_dy_reg_expl:'
                                    || wky_reg_incl_dy_reg_expl
                                   );
                  hr_utility.TRACE ('l_weekly_REG_hrs:' || l_weekly_reg_hrs);
               END IF;

               OPEN weekly_earning_rules (g_ep_id);

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 620);
               END IF;

-- Commented out the following. Instead calling the adjust_for_hdp funtion
-- to determine the hours that are left to be paid, since hours need to be
-- deducted based on the hour deduction policy if assigned to the employee.
-- hours_left := g_hours;
            -- hours_left := adjust_for_hdp (p_hours_worked, error_code);
               hours_left := p_hours_worked;

               IF g_debug
               THEN
                  hr_utility.TRACE ('hours_left :' || hours_left);
               END IF;

               -- line added for bug 2822172
               hours_for_points := 0;

               LOOP
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 625);
                  END IF;

                  j := j + 1;

                  FETCH weekly_earning_rules
                   INTO weekly_earning_cap, weekly_element_type_id;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'weekly_earning_cap     :'
                                       || weekly_earning_cap
                                      );
                     hr_utility.TRACE (   'weekly_element_type_id :'
                                       || weekly_element_type_id
                                      );
                  END IF;

-- line commented for bug 2822172
--    IF j = 1 THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 630);
                     hr_utility.TRACE (   'get_weekly_total_prev_days:'
                                       || get_weekly_total_prev_days
                                      );
                     hr_utility.TRACE (   'previous_detail_hours_day:'
                                       || previous_detail_hours_day
                                      );
                     hr_utility.TRACE ('hours_for_points:' || hours_for_points);
                  END IF;

                  -- line changed for bug 2822172
                  -- hours_paid_for_week := get_weekly_total;
                  hours_paid_for_week :=
                       get_weekly_total_prev_days
                     + NVL (previous_detail_hours_day, 0)
                     + hours_for_points;

-- line commented for bug 2822172
--    END IF;
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 635);
                     hr_utility.TRACE (   'hours_paid_for_week   :'
                                       || hours_paid_for_week
                                      );
                     hr_utility.TRACE ('g_hours               :' || g_hours);
                  END IF;

--  Following condition modified for bug 3868995
--  EXIT WHEN hours_left = 0;
                  EXIT WHEN hours_left = 0 AND j > 1;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 640);
                  END IF;

--  Following condition modified for bug 3868995
--  IF hours_left > 0 THEN
                  IF hours_left >= 0
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 645);
                     END IF;

                     IF    (hours_paid_for_week - l_override_hrs) >=
                                                            weekly_earning_cap
                        OR l_weekly_total >= weekly_earning_cap
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 650);
                        END IF;

                        -- line changed for bug 2822172
                        OPEN weekly_earning_rules2 (g_ep_id,
                                                    hours_paid_for_week
                                                   );  -- weekly_earning_cap);

                        FETCH weekly_earning_rules2
                         INTO weekly_earning_cap2, weekly_element_type_id;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'weekly_earning_cap2    :'
                                             || weekly_earning_cap2
                                            );
                           hr_utility.TRACE (   'weekly_element_type_id :'
                                             || weekly_element_type_id
                                            );
                        END IF;

                        CLOSE weekly_earning_rules2;

                        hours_for_points :=
                           LEAST ((weekly_earning_cap2 - hours_paid_for_week
                                  ),
                                  hours_left
                                 );

-- ADDED BY MV TO AVOID INFINITE LOOP
                        IF (hours_for_points = 0)
                        THEN
                           l_left_over_hours := hours_left;
                        ELSE
                           l_left_over_hours := 0;
                        END IF;

        -- I tried this first but it didn't work, it caused outer issues.
        -- hours_for_points := hours_left;
-- END ADDED BY MV TO AVOID INFINITE LOOP
                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_for_points :'
                                             || hours_for_points
                                            );
                        END IF;
                     ELSE
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 655);
                        END IF;

                        IF weekly_element_type_id = l_override_element
                        THEN
                           IF hours_left <=
                                 (  weekly_earning_cap
                                  - (hours_paid_for_week - l_override_hrs)
                                 )
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 655.1);
                              END IF;

                              hours_for_points :=
                                 LEAST (hours_left,
                                        (  weekly_earning_cap
                                         - (hours_paid_for_week)
                                        )
                                       );
                           ELSE
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 655.2);
                              END IF;

                              hours_for_points :=
                                 LEAST (hours_left,
                                        (  weekly_earning_cap
                                         - (  hours_paid_for_week
                                            - l_override_hrs
                                           )
                                        )
                                       );
                           END IF;
                        ELSE
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 655.3);
                           END IF;

                           hours_for_points :=
                              LEAST (hours_left,
                                     (  weekly_earning_cap
                                      - (hours_paid_for_week - l_override_hrs
                                        )
                                     )
                                    );
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_for_points :'
                                             || hours_for_points
                                            );
                        END IF;

                        -- Say for example entering time as follows:
                        -- hrs   element
                        -- 13   (no override)
                        -- 2     OT
                        -- This should explode to
                        -- 13 hrs -> 8/2/3
                        -- 2 OT   ->   2
                        -- From the above logic we get the hours for the 2nd
                        -- Daily Cap element i.e., LEAST(5,(12-(10 - 2))
                        -- i.e., 4 hrs OT
                        -- But since 2 hrs OT already overriden => (4 - 2)OT left
                        -- to be paid
                        IF     weekly_element_type_id = l_override_element
                           AND hours_for_points > l_override_hrs
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 656);
                           END IF;

                           hrs_already_paid := FALSE;
                           hours_for_points :=
                                             hours_for_points - l_override_hrs;
                        ELSIF     weekly_element_type_id = l_override_element
                              AND hours_for_points <= l_override_hrs
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'l_override_hrs:'
                                                || l_override_hrs
                                               );
                              hr_utility.TRACE (   'weekly_earning_cap:'
                                                || weekly_earning_cap
                                               );
                              hr_utility.TRACE (   'prev_weekly_cap:'
                                                || prev_weekly_cap
                                               );
                           END IF;

                           IF l_override_hrs >=
                                          weekly_earning_cap - prev_weekly_cap
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 657);
                              END IF;

                              hrs_already_paid := TRUE;
                              hours_for_points := 0;
                              segment_points := 0;
                           ELSE
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 658);
                              END IF;

                              hrs_already_paid := FALSE;
                           END IF;
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 659);
                           hr_utility.TRACE (   'hours_for_points :'
                                             || hours_for_points
                                            );
                        END IF;
                     END IF;

/*
                        hours_for_points :=
                           LEAST (hours_left,
                                  (weekly_earning_cap - hours_paid_for_week
                                  )
                                 );
                        hr_utility.TRACE (   'hours_for_points :'
                                          || hours_for_points
                                         );
                     END IF;
*/
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 659.1);
                        hr_utility.TRACE ('segment_points:' || segment_points);
                     END IF;

                     IF hrs_already_paid = FALSE
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 660);
                        END IF;

                        hours_left :=
                           (hours_left - hours_for_points - l_left_over_hours
                           );

                        IF g_debug
                        THEN
                           hr_utility.TRACE ('hours_left :' || hours_left);
                        END IF;

                        -- Added the following FOR LOOP to determine the elements that
                        -- need to be paid when the Daily(REG,OT,DT) and Weekly(REG,OT,DT)
                        -- elements in the Earning Policy rules are different.
                        FOR i IN 1 .. g_weekly_earn_category.COUNT
                        LOOP
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 661);
                              hr_utility.TRACE
                                 (   'g_weekly_earn_category(i).element_type_id:'
                                  || g_weekly_earn_category (i).element_type_id
                                 );
                              hr_utility.TRACE
                                 (   'g_weekly_earn_category(i).earning_category:'
                                  || g_weekly_earn_category (i).earning_category
                                 );
                              hr_utility.TRACE (   'weekly_element_type_id:'
                                                || weekly_element_type_id
                                               );
                              hr_utility.TRACE (   'use_daily_REG:'
                                                || use_daily_reg
                                               );
                              hr_utility.TRACE ('use_daily_OT:'
                                                || use_daily_ot
                                               );
                              hr_utility.TRACE ('use_daily_DT:'
                                                || use_daily_dt
                                               );
                              hr_utility.TRACE (   'use_weekly_REG:'
                                                || use_weekly_reg
                                               );
                              hr_utility.TRACE (   'use_weekly_OT:'
                                                || use_weekly_ot
                                               );
                              hr_utility.TRACE (   'use_weekly_DT:'
                                                || use_weekly_dt
                                               );
                           END IF;

                           IF     g_weekly_earn_category (i).earning_category =
                                                                         'REG'
                              AND g_weekly_earn_category (i).element_type_id =
                                                        weekly_element_type_id
                              AND use_daily_reg = 'Y'
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 662);
                              END IF;

                              weekly_element_type_id := l_dy_wk_reg_elem_id;
                              EXIT;
                           ELSIF     g_weekly_earn_category (i).earning_category =
                                                                         'OVT'
                                 AND g_weekly_earn_category (i).element_type_id =
                                                        weekly_element_type_id
                                 AND use_daily_ot = 'Y'
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 663);
                              END IF;

                              weekly_element_type_id := l_dy_wk_ovt_elem_id;
                              EXIT;
                           ELSIF     g_weekly_earn_category (i).earning_category =
                                                                          'DT'
                                 AND g_weekly_earn_category (i).element_type_id =
                                                        weekly_element_type_id
                                 AND use_daily_dt = 'Y'
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 664);
                              END IF;

                              weekly_element_type_id := l_dy_wk_dt_elem_id;
                              EXIT;
                           END IF;

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 665);
                           END IF;
                        END LOOP;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 670);
                           hr_utility.TRACE (   'weekly_element_type_id:'
                                             || weekly_element_type_id
                                            );
                        END IF;

                        SELECT NVL (points_assigned, 0)
                          INTO l_points_assigned
                          FROM hxt_add_elem_info_f aei
                         WHERE aei.element_type_id = weekly_element_type_id
                           AND g_date_worked BETWEEN aei.effective_start_date
                                                 AND aei.effective_end_date;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_points_assigned :'
                                             || l_points_assigned
                                            );
                        END IF;

                        segment_points := hours_for_points * l_points_assigned;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'segment_points :'
                                             || segment_points
                                            );
                        END IF;

                        l_weekly_index := l_weekly_index + 1;
                        g_weekly_explosion (l_weekly_index).element_type_id :=
                                                        weekly_element_type_id;
                        g_weekly_explosion (l_weekly_index).hours_to_pay :=
                                                              hours_for_points;

                        FOR i IN 1 .. g_weekly_earn_category.COUNT
                        LOOP
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 675);
                              hr_utility.TRACE (   'weekly_element_type_id:'
                                                || weekly_element_type_id
                                               );
                              hr_utility.TRACE
                                 (   'g_weekly_earn_category(i).element_type_id:'
                                  || g_weekly_earn_category (i).element_type_id
                                 );
                           END IF;

                           IF g_weekly_earn_category (i).element_type_id =
                                                        weekly_element_type_id
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 680);
                              END IF;

                              g_weekly_explosion (l_weekly_index).earning_category :=
                                   g_weekly_earn_category (i).earning_category;
                           END IF;

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 685);
                           END IF;
                        END LOOP;

                        FOR i IN 1 .. g_weekly_explosion.COUNT
                        LOOP
                           IF g_debug
                           THEN
                              hr_utility.TRACE
                                       (   'weekly_element_type_id:'
                                        || g_weekly_explosion (i).element_type_id
                                       );
                              hr_utility.TRACE
                                           (   'hours_to_pay in plsql table:'
                                            || g_weekly_explosion (i).hours_to_pay
                                           );
                              hr_utility.TRACE
                                       (   'earning_category:'
                                        || g_weekly_explosion (i).earning_category
                                       );
                           END IF;
                        END LOOP;

                        -- hours_paid_for_week := hours_paid_for_week + hours_for_points;
                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_paid_for_week:'
                                             || hours_paid_for_week
                                            );
                           hr_utility.TRACE (   'hours_for_points:'
                                             || hours_for_points
                                            );
                           hr_utility.TRACE (   'l_override_hrs:'
                                             || l_override_hrs
                                            );
                        END IF;

                        l_weekly_total :=
                                        hours_paid_for_week + hours_for_points;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_weekly_total :'
                                             || l_weekly_total
                                            );
                        END IF;

                        OPEN elements_in_earn_groups (g_ep_id);

                        LOOP
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 690);
                           END IF;

                           FETCH elements_in_earn_groups
                            INTO l_element_type_id;

                           EXIT WHEN elements_in_earn_groups%NOTFOUND;

                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'l_element_type_id :'
                                                || l_element_type_id
                                               );
                              hr_utility.TRACE (   'hours_for_points  :'
                                                || hours_for_points
                                               );
                              hr_utility.TRACE (   'hours_paid_for_week:'
                                                || hours_paid_for_week
                                               );
                           END IF;

                           IF weekly_element_type_id = l_element_type_id
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 695);
                              END IF;

                              hours_paid_for_week :=
                                        hours_paid_for_week + hours_for_points;
                           END IF;

                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'hours_paid_for_week:'
                                                || hours_paid_for_week
                                               );
                              hr_utility.set_location (l_proc, 700);
                           END IF;
                        END LOOP;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 710);
                        END IF;

                        CLOSE elements_in_earn_groups;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 715);
                        END IF;
                     END IF;
                  END IF;

                  l_weekly_reg_hrs := l_weekly_reg_hrs + hours_for_points;

                  -- Once the weekly regular hrs including today's REG hrs reaches
                  -- the weekly REG cap, the daily OT and DT elements should
                  -- not be paid anymore(in cases where daily rules elements are
                  -- different than the elements used for weekly rules)
                  IF l_weekly_reg_hrs >= l_weekly_reg_cap
                  THEN
                     use_daily_ot := 'N';
                     use_daily_dt := 'N';
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 720);
                  END IF;

                  total_weekly_points := total_weekly_points + segment_points;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'total_weekly_points :'
                                       || total_weekly_points
                                      );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 725);
                  hr_utility.TRACE (   'total_daily_points :'
                                    || total_daily_points
                                   );
                  hr_utility.TRACE (   'total_weekly_points :'
                                    || total_weekly_points
                                   );
               END IF;

               CLOSE weekly_earning_rules;

--
------------------------END Weekly Points Calculation---------------------------
--

               --
--------------------BEGIN Combination Points Calculation------------------------
--
-- The logic being used for calculating the combination points is as follows:
-- Say for example:
-- Earning Policy - Daily
--                  REG,OT, DT : 8,12,24
--                  Weekly
--                  REG,OT    : 40,999
-- Earning Group  - REG

               -- Example 1:
-- Timecard Entered:
--  DAY    Mon Tue Wed Thur Fri Sat
--  HRS    14  14  14  14   14  14
-- Mon to Fri the explosion will be 8,4,2
-- The issue arises for Sat. We need to apply a combination of Daily and Weekly
-- rules on this day. So, the logic being followed here is to explode this day
-- based on daily rules and then apply the weekly rules on the Daily REG hrs.
-- We already have the explosion based on Daily rules for this day in the
-- g_daily_explosion plsql table. Now apply the weekly rule on the Daily REG hrs
-- So, for Sat 14 hrs daily explosion in g_daily_explosion plsql table will be:
-- 8 REG
-- 4 OT
-- 2 DT
-- Now apply Weekly rule on 8 hrs REG, which would explode to 8 OT(since 40 REG
-- weekly cap has already been reached)
-- Now add this 8 OT to the Daily OT which would result in the following
-- explosion:
-- 0 REG
-- 12(4 + 8) OT
-- 2 DT

               -- Example 2:
-- Timecard Entered:
--  DAY    Mon Tue Wed Thur Fri Sat
--  HRS    8   8   8   8    1   13
-- Mon to Fri explosion is:
-- REG     8   8   8   8    1
-- OT
-- DT
-- Now the daily explosion for 13 hrs on Sat in g_daily_explosion is:
-- REG 8
-- OT  4
-- DT  1
-- Applying weekly rules on 8 REG explodes to 7 REG + 1 OT
-- So the combine explosion for sat would be:
-- REG 7
-- OT  4 + 1 = 5
-- DT  1
               IF g_debug
               THEN
                  hr_utility.TRACE
                             (   'fnd_profile.VALUE (''HXT_CA_LABOR_RULE''):'
                              || fnd_profile.VALUE ('HXT_CA_LABOR_RULE')
                             );
               END IF;

               -- If the following profile is set to 'YES', only then calculate the
               -- combination points.
               IF (NVL (fnd_profile.VALUE ('HXT_CA_LABOR_RULE'), 'N') = 'Y')
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 726);
                     hr_utility.TRACE ('use_weekly_REG:' || use_weekly_reg);
                     hr_utility.TRACE ('use_weekly_OT:' || use_weekly_ot);
                     hr_utility.TRACE ('use_weekly_DT:' || use_weekly_dt);
                     hr_utility.TRACE ('l_weekly_reg_cap:' || l_weekly_reg_cap
                                      );
                  END IF;

                  -- Initialize the variables before calculating the combine points
                  init_for_wkl_combine_pts_cal (use_weekly_reg,
                                                use_weekly_ot,
                                                use_weekly_dt,
                                                l_weekly_reg_cap,
                                                l_dy_wk_reg_elem_id,
                                                l_dy_wk_ovt_elem_id,
                                                l_dy_wk_dt_elem_id,
                                                use_daily_reg,
                                                use_daily_ot,
                                                use_daily_dt,
                                                l_reg_for_day,
                                                l_ovt_for_day,
                                                l_dt_for_day,
                                                wky_reg_incl_dy_reg_expl,
                                                l_weekly_reg_hrs
                                               );

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 727);
                     hr_utility.TRACE (   'l_dy_wk_reg_elem_id:'
                                       || l_dy_wk_reg_elem_id
                                      );
                     hr_utility.TRACE (   'l_dy_wk_ovt_elem_id:'
                                       || l_dy_wk_ovt_elem_id
                                      );
                     hr_utility.TRACE (   'l_dy_wk_dt_elem_id:'
                                       || l_dy_wk_dt_elem_id
                                      );
                     hr_utility.TRACE ('use_daily_reg:' || use_daily_reg);
                     hr_utility.TRACE ('use_daily_ot:' || use_daily_ot);
                     hr_utility.TRACE ('use_daily_dt:' || use_daily_dt);
                     hr_utility.TRACE ('l_reg_for_day:' || l_reg_for_day);
                     hr_utility.TRACE ('l_ovt_for_day:' || l_ovt_for_day);
                     hr_utility.TRACE ('l_dt_for_day:' || l_dt_for_day);
                     hr_utility.TRACE (   'wky_reg_incl_dy_reg_expl:'
                                       || wky_reg_incl_dy_reg_expl
                                      );
                     hr_utility.TRACE ('l_weekly_REG_hrs:' || l_weekly_reg_hrs);
                  END IF;

                  FOR i IN 1 .. g_dy_wk_combo_explosion.COUNT
                  LOOP
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 730);
                        hr_utility.TRACE
                                  (   'combo_element_type_id:'
                                   || g_dy_wk_combo_explosion (i).element_type_id
                                  );
                        hr_utility.TRACE
                                      (   'hours_to_pay in plsql table:'
                                       || g_dy_wk_combo_explosion (i).hours_to_pay
                                      );
                     END IF;
                  END LOOP;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   ' g_daily_explosion.COUNT:'
                                       || g_daily_explosion.COUNT
                                      );
                  END IF;

                  FOR i IN 1 .. g_daily_explosion.COUNT
                  LOOP
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 735);
                        hr_utility.TRACE
                                        (   'daily_element_type_id:'
                                         || g_daily_explosion (i).element_type_id
                                        );
                        hr_utility.TRACE (   'hours_to_pay in plsql table:'
                                          || g_daily_explosion (i).hours_to_pay
                                         );
                        hr_utility.TRACE
                                        (   'earning_category:'
                                         || g_daily_explosion (i).earning_category
                                        );
                        hr_utility.set_location (l_proc, 740);
                     END IF;
                  END LOOP;

                  OPEN weekly_earning_rules (g_ep_id);

                  FETCH weekly_earning_rules
                   INTO weekly_earning_cap, weekly_element_type_id;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'weekly_earning_cap:'
                                       || weekly_earning_cap
                                      );
                     hr_utility.TRACE (   'weekly_element_type_id:'
                                       || weekly_element_type_id
                                      );
                  END IF;

                  CLOSE weekly_earning_rules;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'wky_reg_incl_dy_reg_expl:'
                                       || wky_reg_incl_dy_reg_expl
                                      );
                     hr_utility.TRACE (   'weekly_earning_cap:'
                                       || weekly_earning_cap
                                      );
                  END IF;

                  -- Check if the weekly REG including today's REG hrs is greater
                  -- than the weekly REG cap then proceed further to calculate the
                  -- combination points.
                  IF    wky_reg_incl_dy_reg_expl >= weekly_earning_cap
                     OR g_hours = 0
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 745);
                     END IF;

                     OPEN weekly_earning_rules (g_ep_id);

                     hours_left := NVL(l_reg_for_day, 0); -- added NVL for 5441313

                     IF g_debug
                     THEN
                        hr_utility.TRACE ('hours_left :' || hours_left);
                     END IF;

                     hours_for_points := 0;

                     LOOP
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 750);
                        END IF;

                        k := k + 1;

                        FETCH weekly_earning_rules
                         INTO weekly_earning_cap, weekly_element_type_id;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'weekly_earning_cap     :'
                                             || weekly_earning_cap
                                            );
                           hr_utility.TRACE (   'weekly_element_type_id :'
                                             || weekly_element_type_id
                                            );
                        END IF;

                        hours_paid_for_week :=
                             get_weekly_total_prev_days
                           + NVL (previous_detail_hours_day, 0)
                           + hours_for_points;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 755);
                           hr_utility.TRACE (   'hours_paid_for_week   :'
                                             || hours_paid_for_week
                                            );
                           hr_utility.TRACE (   'g_hours               :'
                                             || g_hours
                                            );
                        END IF;

                        EXIT WHEN hours_left = 0 AND k > 1;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 760);
                        END IF;

                        IF hours_left >= 0
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 770);
                              hr_utility.TRACE (   'hours_paid_for_week   :'
                                                || hours_paid_for_week
                                               );
                              hr_utility.TRACE (   'weekly_earning_cap   :'
                                                || weekly_earning_cap
                                               );
                           END IF;

                           IF (hours_paid_for_week - l_override_hrs) >= weekly_earning_cap
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 780);
                              END IF;

                              OPEN weekly_earning_rules2 (g_ep_id,
                                                          hours_paid_for_week
                                                         );

                              FETCH weekly_earning_rules2
                               INTO weekly_earning_cap2,
                                    weekly_element_type_id;

                              IF g_debug
                              THEN
                                 hr_utility.TRACE
                                               (   'weekly_earning_cap2    :'
                                                || weekly_earning_cap2
                                               );
                                 hr_utility.TRACE
                                                (   'weekly_element_type_id :'
                                                 || weekly_element_type_id
                                                );
                              END IF;

                              CLOSE weekly_earning_rules2;

                              hours_for_points :=
                                 LEAST ((  weekly_earning_cap2
                                         - hours_paid_for_week
                                        ),
                                        hours_left
                                       );

                              IF (hours_for_points = 0)
                              THEN
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 790);
                                 END IF;

                                 l_left_over_hours := hours_left;
                              ELSE
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 800);
                                 END IF;

                                 l_left_over_hours := 0;
                              END IF;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 810);
                                 hr_utility.TRACE (   'hours_for_points :'
                                                   || hours_for_points
                                                  );
                              END IF;
                           ELSE
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 815);
                              END IF;

			      IF weekly_element_type_id = l_override_element
			      THEN
                                 IF hours_left <=
                                    (  weekly_earning_cap
                                     - (hours_paid_for_week - l_override_hrs)
                                    )
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 815.1);
                                    END IF;

                                    hours_for_points :=
                                       LEAST (hours_left,
                                              (  weekly_earning_cap
                                               - (hours_paid_for_week)
                                              )
                                             );
                                 ELSE
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 815.2);
                                    END IF;

                                    hours_for_points :=
                                       LEAST (hours_left,
                                              (  weekly_earning_cap
                                               - (  hours_paid_for_week
                                                  - l_override_hrs
                                                 )
                                              )
                                             );
                                 END IF;
                              ELSE
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 815.3);
                                 END IF;

                                 hours_for_points :=
                                    LEAST (hours_left,
                                           (  weekly_earning_cap
                                            - (hours_paid_for_week - l_override_hrs
                                              )
                                           )
                                          );
                              END IF;

                              IF g_debug
                              THEN
                                 hr_utility.TRACE (   'hours_for_points :'
                                                   || hours_for_points
                                                  );
                              END IF;

                              -- Say for example entering time as follows:
                              -- hrs   element
                              -- 13   (no override)
                              -- 2     OT
                              -- This should explode to
                              -- 13 hrs -> 8/2/3
                              -- 2 OT   ->   2
                              -- From the above logic we get the hours for the 2nd
                              -- Daily Cap element i.e., LEAST(5,(12-(10 - 2))
                              -- i.e., 4 hrs OT
                              -- But since 2 hrs OT already overriden => (4 - 2)OT left
                              -- to be paid

			      IF     weekly_element_type_id = l_override_element
                                 AND hours_for_points > l_override_hrs
                              THEN
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 816);
                                 END IF;

                                 hrs_already_paid := FALSE;
                                 hours_for_points :=
                                                   hours_for_points - l_override_hrs;
                              ELSIF     weekly_element_type_id = l_override_element
                                    AND hours_for_points <= l_override_hrs
                              THEN
                                 IF g_debug
                                 THEN
                                    hr_utility.TRACE (   'l_override_hrs:'
                                                      || l_override_hrs
                                                     );
                                    hr_utility.TRACE (   'weekly_earning_cap:'
                                                      || weekly_earning_cap
                                                     );
                                    hr_utility.TRACE (   'prev_weekly_cap:'
                                                      || prev_weekly_cap
                                                     );
                                 END IF;

                                 IF l_override_hrs >=
                                                weekly_earning_cap - prev_weekly_cap
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 817);
                                    END IF;

                                    hrs_already_paid := TRUE;
                                    hours_for_points := 0;
                                    segment_points := 0;
                                 ELSE
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 818);
                                    END IF;

                                    hrs_already_paid := FALSE;
                                 END IF;
                              END IF;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 819);
                                 hr_utility.TRACE (   'hours_for_points :'
                                                   || hours_for_points
                                                  );
                              END IF;
                           END IF;

/*
                              hours_for_points :=
                                 LEAST (hours_left,
                                        (  weekly_earning_cap
                                         - hours_paid_for_week
                                        )
                                       );

                              IF g_debug
                              THEN
                                 hr_utility.TRACE (   'hours_for_points :'
                                                   || hours_for_points
                                                  );
                              END IF;
                           END IF;
*/

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 819.1);
                              hr_utility.TRACE ('segment_points:' || segment_points);
                           END IF;

			   IF hrs_already_paid = FALSE
			   THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 820);
                              END IF;

                              hours_left :=
                                 (hours_left - hours_for_points
                                  - l_left_over_hours
                                 );

                              IF g_debug
                              THEN
                                 hr_utility.TRACE ('hours_left :' || hours_left);
                                 hr_utility.TRACE (   ' l_dy_wk_reg_elem_id:'
                                                   || l_dy_wk_reg_elem_id
                                                  );
                                 hr_utility.TRACE (   ' l_dy_wk_ovt_elem_id:'
                                                   || l_dy_wk_ovt_elem_id
                                                  );
                                 hr_utility.TRACE (   ' l_dy_wk_dt_elem_id:'
                                                   || l_dy_wk_dt_elem_id
                                                  );
                                 hr_utility.TRACE (   ' l_ovt_for_day:'
                                                   || l_ovt_for_day
                                                  );
                                 hr_utility.TRACE (   ' l_dt_for_day:'
                                                   || l_dt_for_day
                                                  );
                              END IF;

                              FOR i IN 1 .. g_weekly_earn_category.COUNT
                              LOOP
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 825);
                                    hr_utility.TRACE
                                                    (   'daily_element_type_id:'
                                                     || daily_element_type_id
                                                    );
                                    hr_utility.TRACE
                                       (   'g_weekly_earn_category(i).element_type_id:'
                                        || g_weekly_earn_category (i).element_type_id
                                       );
                                    hr_utility.TRACE
                                       (   'g_weekly_earn_category(i).earning_category:'
                                        || g_weekly_earn_category (i).earning_category
                                       );
                                    hr_utility.TRACE
                                                    (   'weekly_element_type_id:'
                                                     || weekly_element_type_id
                                                   );
                                    hr_utility.TRACE (   'use_daily_REG:'
                                                   || use_daily_reg
                                                  );
                                    hr_utility.TRACE (   'use_daily_OT:'
                                                      || use_daily_ot
                                                     );
                                    hr_utility.TRACE (   'use_daily_DT:'
                                                      || use_daily_dt
                                                     );
                                    hr_utility.TRACE (   'use_weekly_REG:'
                                                      || use_weekly_reg
                                                     );
                                    hr_utility.TRACE (   'use_weekly_OT:'
                                                      || use_weekly_ot
                                                     );
                                    hr_utility.TRACE (   'use_weekly_DT:'
                                                      || use_weekly_dt
                                                     );
                                 END IF;

                                 -- Determine whether daily or weekly OT, DT elements
                                 -- need to be paid(in cases where the daily and
                                 -- weekly elements are different)
                                 IF     g_weekly_earn_category (i).earning_category =
                                                                            'REG'
                                    AND g_weekly_earn_category (i).element_type_id =
                                                           weekly_element_type_id
                                    AND use_daily_reg = 'Y'
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 830);
                                    END IF;

                                    weekly_element_type_id := l_dy_wk_reg_elem_id;
                                    EXIT;
                                 ELSIF     g_weekly_earn_category (i).earning_category =
                                                                            'OVT'
                                       AND g_weekly_earn_category (i).element_type_id =
                                                           weekly_element_type_id
                                       AND use_daily_ot = 'Y'
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 835);
                                    END IF;

                                    weekly_element_type_id := l_dy_wk_ovt_elem_id;
                                    EXIT;
                                 ELSIF     g_weekly_earn_category (i).earning_category =
                                                                             'DT'
                                       AND g_weekly_earn_category (i).element_type_id =
                                                           weekly_element_type_id
                                       AND use_daily_dt = 'Y'
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 840);
                                    END IF;

                                    weekly_element_type_id := l_dy_wk_dt_elem_id;
                                    EXIT;
                                 END IF;

                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 845);
                                 END IF;
                              END LOOP;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 846);
                                 hr_utility.TRACE (   'weekly_element_type_id:'
                                                   || weekly_element_type_id
                                                  );
                              END IF;

                              IF weekly_element_type_id = l_dy_wk_ovt_elem_id
                              THEN
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 850);
                                 END IF;

                                 hours_for_points :=
                                                 hours_for_points + l_ovt_for_day;
                              ELSIF weekly_element_type_id = l_dy_wk_dt_elem_id
                              THEN
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 855);
                                 END IF;

                                 hours_for_points :=
                                                  hours_for_points + l_dt_for_day;
                              END IF;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 860);
                              END IF;

                              SELECT NVL (points_assigned, 0)
                                INTO l_points_assigned
                                FROM hxt_add_elem_info_f aei
                               WHERE aei.element_type_id = weekly_element_type_id
                                 AND g_date_worked BETWEEN aei.effective_start_date
                                                       AND aei.effective_end_date;

                              IF g_debug
                              THEN
                                 hr_utility.TRACE (   'l_points_assigned :'
                                                   || l_points_assigned
                                                  );
                                 hr_utility.TRACE (   ' weekly_element_type_id:'
                                                   || weekly_element_type_id
                                                  );
                              END IF;

                              segment_points :=
                                             hours_for_points * l_points_assigned;

                              IF g_debug
                              THEN
                                 hr_utility.TRACE (   'segment_points :'
                                                   || segment_points
                                                  );
                              END IF;

                              l_dy_wk_combo_index := l_dy_wk_combo_index + 1;
                              g_dy_wk_combo_explosion (l_dy_wk_combo_index).element_type_id :=
                                                           weekly_element_type_id;
                              g_dy_wk_combo_explosion (l_dy_wk_combo_index).hours_to_pay :=
                                                                 hours_for_points;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 865);
                              END IF;

                              FOR i IN 1 .. g_dy_wk_combo_explosion.COUNT
                              LOOP
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (l_proc, 870);
                                    hr_utility.TRACE
                                      (   'combo_element_type_id:'
                                        || g_dy_wk_combo_explosion (i).element_type_id
                                      );
                                    hr_utility.TRACE
                                      (   'hours_to_pay in plsql table:'
                                       || g_dy_wk_combo_explosion (i).hours_to_pay
                                      );
                                 END IF;
                              END LOOP;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 875);
                                 hr_utility.TRACE ('hours_left :' || hours_left);
                              END IF;
			   END IF;  /*End hrs_already_paid = FALSE */
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 880);
                        END IF;

                        l_weekly_reg_hrs :=
                                           l_weekly_reg_hrs + hours_for_points;

                        -- Once the weekly regular hrs including today's REG hrs reaches
                        -- the weekly REG cap, the Daily OT and DT elements should
                        -- not be paid anymore(in cases where daily rules elements are
                        -- different than the elements used for weekly rules)
                        IF l_weekly_reg_hrs >= l_weekly_reg_cap
                        THEN
                           use_daily_ot := 'N';
                           use_daily_dt := 'N';
                        END IF;

                        total_combo_points :=
                                           total_combo_points + segment_points;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'total_combo_points :'
                                             || total_combo_points
                                            );
                        END IF;
                     END LOOP;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 885);
                     END IF;

                     CLOSE weekly_earning_rules;

                     FOR i IN 1 .. g_dy_wk_combo_explosion.COUNT
                     LOOP
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 890);
                           hr_utility.TRACE ('i:' || i);
                           hr_utility.TRACE
                                  (   'combo_element_type_id:'
                                   || g_dy_wk_combo_explosion (i).element_type_id
                                  );
                           hr_utility.TRACE
                                      (   'hours_to_pay in plsql table:'
                                       || g_dy_wk_combo_explosion (i).hours_to_pay
                                      );
                        END IF;

                        l_total_combo_hrs :=
                             l_total_combo_hrs
                           + g_dy_wk_combo_explosion (i).hours_to_pay;
                     END LOOP;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 895);
                     END IF;

                     l_dy_wk_combo_index := g_dy_wk_combo_explosion.COUNT;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'g_dy_wk_combo_explosion.COUNT:'
                                          || g_dy_wk_combo_explosion.COUNT
                                         );
                        hr_utility.TRACE (   'l_total_combo_hrs:'
                                          || l_total_combo_hrs
                                         );
                        hr_utility.TRACE (   'l_dy_wk_combo_index:'
                                          || l_dy_wk_combo_index
                                         );
                     END IF;

                     -- Once the Weekly rules have been applied to the REG hrs
                     -- in the g_daily_explosion for the day, populate the
                     -- g_dy_wk_combo_explosion table with the rest of the
                     -- g_daily_explosion records for the day.
                     FOR i IN 1 .. g_daily_explosion.COUNT
                     LOOP
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 900);
                           hr_utility.TRACE
                                        (   'daily_element_type_id:'
                                         || g_daily_explosion (i).element_type_id
                                        );
                           hr_utility.TRACE (   'hours_to_pay in plsql table:'
                                             || g_daily_explosion (i).hours_to_pay
                                            );
                           hr_utility.TRACE
                                        (   'earning_category:'
                                         || g_daily_explosion (i).earning_category
                                        );
                        END IF;

                        l_combo_elem_id :=
                                         g_daily_explosion (i).element_type_id;
                        l_total_daily_hrs :=
                             l_total_daily_hrs
                           + g_daily_explosion (i).hours_to_pay;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_combo_elem_id:'
                                             || l_combo_elem_id
                                            );
                           hr_utility.TRACE (   'l_total_daily_hrs:'
                                             || l_total_daily_hrs
                                            );
                           hr_utility.TRACE (   'l_total_combo_hrs:'
                                             || l_total_combo_hrs
                                            );
                        END IF;

                        IF l_total_daily_hrs > l_total_combo_hrs
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 910);
                           END IF;

                           FOR j IN 1 .. g_weekly_earn_category.COUNT
                           LOOP
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 911);
                                 hr_utility.TRACE
                                    (   'g_weekly_earn_category(j).element_type_id:'
                                     || g_weekly_earn_category (j).element_type_id
                                    );
                                 hr_utility.TRACE
                                    (   'g_daily_explosion (i).element_type_id:'
                                     || g_daily_explosion (i).element_type_id
                                    );
                                 hr_utility.TRACE
                                    (   'g_weekly_earn_category(j).earning_category:'
                                     || g_weekly_earn_category (j).earning_category
                                    );
                                 hr_utility.TRACE (   'use_daily_OT:'
                                                   || use_daily_ot
                                                  );
                                 hr_utility.TRACE (   'use_daily_DT:'
                                                   || use_daily_dt
                                                  );
                              END IF;

                              IF (get_weekly_total_prev_days >=
                                                              l_weekly_reg_cap
                                 )
                              THEN
                                 IF     g_daily_explosion (i).earning_category =
                                           g_weekly_earn_category (j).earning_category
                                    AND g_weekly_earn_category (j).earning_category =
                                                                         'OVT'
                                    AND use_daily_ot = 'N'
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 912);
                                    END IF;

                                    l_combo_elem_id :=
                                       g_weekly_earn_category (j).element_type_id;
                                    EXIT;
                                 ELSIF     g_daily_explosion (i).earning_category =
                                              g_weekly_earn_category (j).earning_category
                                       AND g_weekly_earn_category (j).earning_category =
                                                                          'DT'
                                       AND use_daily_dt = 'N'
                                 THEN
                                    IF g_debug
                                    THEN
                                       hr_utility.set_location (l_proc, 913);
                                    END IF;

                                    l_combo_elem_id :=
                                       g_weekly_earn_category (j).element_type_id;
                                    EXIT;
                                 END IF;
                              END IF;

                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 914);
                              END IF;
                           END LOOP;

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 915);
                              hr_utility.TRACE (   'l_combo_elem_id:'
                                                || l_combo_elem_id
                                               );
                           END IF;

                           l_dy_wk_combo_index := l_dy_wk_combo_index + 1;
                           g_dy_wk_combo_explosion (l_dy_wk_combo_index).element_type_id :=
                                                               l_combo_elem_id;
                           g_dy_wk_combo_explosion (l_dy_wk_combo_index).hours_to_pay :=
                                            g_daily_explosion (i).hours_to_pay;
                           l_total_combo_hrs :=
                                l_total_combo_hrs
                              + g_dy_wk_combo_explosion (l_dy_wk_combo_index).hours_to_pay;

                           FOR i IN 1 .. g_dy_wk_combo_explosion.COUNT
                           LOOP
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 916);
                                 hr_utility.TRACE
                                    (   'combo_element_type_id:'
                                     || g_dy_wk_combo_explosion (i).element_type_id
                                    );
                                 hr_utility.TRACE
                                      (   'hours_to_pay in plsql table:'
                                       || g_dy_wk_combo_explosion (i).hours_to_pay
                                      );
                              END IF;
                           END LOOP;

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 920);
                           END IF;

                           SELECT NVL (points_assigned, 0)
                             INTO l_points_assigned
                             FROM hxt_add_elem_info_f aei
                            WHERE aei.element_type_id = l_combo_elem_id
                              AND g_date_worked BETWEEN aei.effective_start_date
                                                    AND aei.effective_end_date;

                           segment_points :=
                                g_daily_explosion (i).hours_to_pay
                              * l_points_assigned;

                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'segment_points :'
                                                || segment_points
                                               );
                           END IF;

                           total_combo_points :=
                                           total_combo_points + segment_points;

                           IF g_debug
                           THEN
                              hr_utility.TRACE (   'total_combo_points :'
                                                || total_combo_points
                                               );
                           END IF;
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 925);
                        END IF;
                     END LOOP;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 930);
                     END IF;
                  END IF;
               END IF;

--
----------------------END Combination Points Calculation------------------------
--
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 935);
                  hr_utility.TRACE
                             (   'fnd_profile.VALUE (''HXT_CA_LABOR_RULE''):'
                              || fnd_profile.VALUE ('HXT_CA_LABOR_RULE')
                             );
               END IF;

               -- IF the following profile set to 'Yes' then include combination
               -- points while determining the greatest of the Daily, Weekly and
               -- combination points.
               -- If all the three are of same points then 'Combination' takes the
               -- precedence. The order of precedence in case of 'EQUAL' points is
               -- as follows:
               -- Combination
               -- Weekly
               -- Daily
               IF (NVL (fnd_profile.VALUE ('HXT_CA_LABOR_RULE'), 'N') = 'Y')
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 936);
                  END IF;

                  l_greatest_points :=
                     GREATEST (total_daily_points,
                               total_weekly_points,
                               total_combo_points
                              );

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'l_greatest_points:'
                                       || l_greatest_points
                                      );
                  END IF;

                  IF l_greatest_points = total_combo_points
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 940);
                     END IF;

                     g_explosion_to_use := 'COMBO';
                  ELSIF l_greatest_points = total_weekly_points
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 945);
                     END IF;

                     g_explosion_to_use := 'WEEKLY';
                  ELSIF l_greatest_points = total_daily_points
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 950);
                     END IF;

                     g_explosion_to_use := 'DAILY';
                  END IF;
               -- Else determine the greatest of Daily and Weekly points
               -- If Weekly and Daily both come out to be of same points then
               -- Weekly takes precedence over Daily.
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 960);
                  END IF;

                  IF total_weekly_points > total_daily_points
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 970);
                     END IF;

                     g_explosion_to_use := 'WEEKLY';
                  ELSIF total_daily_points > total_weekly_points
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 980);
                     END IF;

                     g_explosion_to_use := 'DAILY';
                  ELSIF total_daily_points = total_weekly_points
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 990);
                     END IF;

                     g_explosion_to_use := 'WEEKLY';
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 991);
               END IF;
            END IF;                                  -- IF special_day = FALSE

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 992);
            END IF;

            IF g_explosion_to_use = 'SPC'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 993);
               END IF;

               FOR i IN g_special_explosion.FIRST .. g_special_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                                (   'g_special_explosion(i).element_type_id:'
                                 || g_special_explosion (i).element_type_id
                                );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 994);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'SPC';
               p_hours_to_pay_this_rule :=
                                    g_special_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                                 g_special_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_special_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 995);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;
                  special_day := FALSE;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                     hr_utility.TRACE ('g_count           :' || g_count);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 996);
               END IF;

               RETURN;
            ELSIF g_explosion_to_use = 'COMBO'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 997);
               END IF;

               FOR i IN
                  g_dy_wk_combo_explosion.FIRST .. g_dy_wk_combo_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                            (   'g_dy_wk_combo_explosion(i).element_type_id:'
                             || g_dy_wk_combo_explosion (i).element_type_id
                            );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 998);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'DAY';
               p_hours_to_pay_this_rule :=
                                g_dy_wk_combo_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                             g_dy_wk_combo_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_dy_wk_combo_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 1000);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                     hr_utility.TRACE ('g_count           :' || g_count);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1010);
               END IF;

               RETURN;
            ELSIF g_explosion_to_use = 'DAILY'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1015);
               END IF;

               FOR i IN g_daily_explosion.FIRST .. g_daily_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                                  (   'g_daily_explosion(i).element_type_id:'
                                   || g_daily_explosion (i).element_type_id
                                  );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1020);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'DAY';
               p_hours_to_pay_this_rule :=
                                      g_daily_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                                   g_daily_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_daily_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 1025);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                     hr_utility.TRACE ('g_count           :' || g_count);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1030);
               END IF;

               RETURN;
            ELSIF g_explosion_to_use = 'WEEKLY'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1035);
               END IF;

               FOR i IN g_weekly_explosion.FIRST .. g_weekly_explosion.LAST
               LOOP
                  IF g_debug
                  THEN
                     hr_utility.TRACE ('i:' || i);
                     hr_utility.TRACE
                                 (   'g_weekly_explosion(i).element_type_id:'
                                  || g_weekly_explosion (i).element_type_id
                                 );
                  END IF;
               END LOOP;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1040);
               END IF;

               g_count := g_count + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('g_count:' || g_count);
               END IF;

               p_error_code := 0;
               p_rule_to_pay := 'WKL';
               p_hours_to_pay_this_rule :=
                                     g_weekly_explosion (g_count).hours_to_pay;
               p_element_type_id :=
                                  g_weekly_explosion (g_count).element_type_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'p_hours_to_pay_this_rule:'
                                    || p_hours_to_pay_this_rule
                                   );
                  hr_utility.TRACE (   'p_element_type_id       :'
                                    || p_element_type_id
                                   );
               END IF;

               IF g_count = g_weekly_explosion.COUNT
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 1045);
                  END IF;

                  hours_left_to_pay := 0;
                  g_explosion_to_use := NULL;
                  g_count := 0;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_left_to_pay :'
                                       || hours_left_to_pay
                                      );
                     hr_utility.TRACE (   'g_explosion_to_use:'
                                       || g_explosion_to_use
                                      );
                     hr_utility.TRACE ('g_count           :' || g_count);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 1050);
               END IF;

               RETURN;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 1055);
            END IF;
         END IF;                              --g_explosion_to_use is not null

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 1060);
         END IF;
      END;

--------------------------------------------------------------------------------
      PROCEDURE reset_rules (
         p_hours_paid_daily_rule    IN OUT NOCOPY   NUMBER,
         p_hours_paid_weekly_rule   IN OUT NOCOPY   NUMBER,
         p_fetch_next_day           OUT NOCOPY      BOOLEAN,
         p_fetch_next_week          OUT NOCOPY      BOOLEAN,
         p_rule_used                IN              VARCHAR2
      )
      IS
      -- recalculates total accumulations towards meeting the various caps
      -- after a sub-segment has been paid
      -- 'fetch next' set to true if a cap has been met and a new rule is needed
      BEGIN
         IF g_debug
         THEN
            hr_utility.set_location ('Reset_rules', 1);
         END IF;

         p_fetch_next_day := FALSE;
         p_fetch_next_week := FALSE;

         IF g_debug
         THEN
            hr_utility.TRACE ('g_egt_id                :' || g_egt_id);
            hr_utility.TRACE (   'element_type_id_to_pay  :'
                              || element_type_id_to_pay
                             );
            hr_utility.TRACE (   'special_and_weekly_base :'
                              || special_and_weekly_base
                             );
            hr_utility.TRACE (   'g_date_worked           :'
                              || TO_CHAR (g_date_worked, 'dd/mon/yy')
                             );
            hr_utility.TRACE ('p_rule_used             :' || p_rule_used);
            hr_utility.TRACE (   'hours_to_pay_this_rule  :'
                              || hours_to_pay_this_rule
                             );
            hr_utility.TRACE (   'p_hours_paid_daily_rule :'
                              || p_hours_paid_daily_rule
                             );
            hr_utility.TRACE (   'p_hours_paid_weekly_rule:'
                              || p_hours_paid_weekly_rule
                             );
            hr_utility.TRACE ('daily_rule_cap          :' || daily_rule_cap);
            hr_utility.TRACE ('weekly_rule_cap         :' || weekly_rule_cap);
         END IF;

         IF    g_egt_id IS NULL
            OR p_rule_used = 'WKL'
            OR hxt_td_util.include_for_ot_cap (g_egt_id,
                                               element_type_id_to_pay,
                                               special_and_weekly_base,
                                               g_date_worked
                                              )
         THEN
            --  everything counted if no include group

            --Added this for Bug 1801337 because when rule to pay is 'WKL'
--and hours_to_pay_this_rule = 0 then next fetch should be set to true so that
--the 'Loop Counter Exceeded' error does not occur and the next row of the
--weekly_earn_rule_cur is fetched
            IF g_debug
            THEN
               hr_utility.set_location ('reset_rules', 2);
            END IF;

            IF p_rule_used = 'WKL' AND hours_to_pay_this_rule = 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('reset_rules', 3);
               END IF;

               p_fetch_next_week := TRUE;
               first_weekly_cap_reached := TRUE;
            END IF;

            p_hours_paid_daily_rule :=
                              p_hours_paid_daily_rule + hours_to_pay_this_rule;
            p_hours_paid_weekly_rule :=
                             p_hours_paid_weekly_rule + hours_to_pay_this_rule;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_hours_paid_daily_rule :'
                                 || p_hours_paid_daily_rule
                                );
               hr_utility.TRACE (   'p_hours_paid_weekly_rule:'
                                 || p_hours_paid_weekly_rule
                                );
            END IF;
         ELSIF p_rule_used = 'DAY' OR p_rule_used = 'SPC'
         THEN                                                      -- SPR C355
            --  OT daily hours not counted for weekly cap
            IF g_debug
            THEN
               hr_utility.set_location ('reset_rules', 4);
            END IF;

            p_hours_paid_daily_rule :=
                              p_hours_paid_daily_rule + hours_to_pay_this_rule;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_hours_paid_daily_rule :'
                                 || p_hours_paid_daily_rule
                                );
            END IF;
         END IF;

         IF     p_hours_paid_daily_rule >= daily_rule_cap
            AND p_rule_used = 'DAY'
            -- Bug 8679560
            -- Commented this out -- let there be next day rule even
            -- for seventh days which are holidays.
            --AND consecutive_days_reached = FALSE
         THEN
            --  do not reset daily hours if counting toward special cap
            IF g_debug
            THEN
               hr_utility.set_location ('reset_rules', 5);
            END IF;

            p_fetch_next_day := TRUE;
         END IF;

-- Bug 1801337 mhanda
-- If the OTM day starts with the day policy, it completes the day policy.
-- If the OTM day starts eligible for the week policy it uses the week policy.
-- If the OTM day starts with the Special policy, then it uses the special day.
-- FAZ-MHANDA changed this condition on 26-oct-02
         IF p_hours_paid_weekly_rule >= weekly_rule_cap
         THEN
-- FAZ-MHANDA commented on 26-oct-02
-- IF (p_hours_paid_weekly_rule - p_hours_paid_daily_rule) > weekly_rule_cap THEN
            IF g_debug
            THEN
               hr_utility.set_location ('reset_rules', 6);
            END IF;

            p_fetch_next_week := TRUE;
            first_weekly_cap_reached := TRUE;
         ELSIF p_hours_paid_weekly_rule < weekly_rule_cap
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('reset_rules', 7);
            END IF;

            first_weekly_cap_reached := FALSE;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('reset_rules', 8);
         END IF;
      END reset_rules;


      -- Bug 8600894
      -- Picks up elements which are to be excluded from
      -- payment on Holiday days.
      PROCEDURE pick_elements_to_be_adjusted
      IS

      CURSOR get_reg_elements(p_ep_id   IN NUMBER,
                              p_date    IN DATE)
          IS SELECT DISTINCT
                    er.element_type_id
               FROM hxt_earning_rules er,
                    hxt_pay_element_types_f_ddf_v elem
              WHERE er.egp_id = p_ep_id
                AND p_date BETWEEN er.effective_start_date
                               AND er.effective_end_date
                AND elem.element_type_id = er.element_type_id
                AND elem.hxt_earning_category = 'REG';
       l_element NUMBER;

      BEGIN
           g_reg_element.DELETE;
           OPEN get_reg_elements(g_ep_id, g_date_worked);
           LOOP
              FETCH get_reg_elements INTO l_element;
              EXIT WHEN get_reg_elements%NOTFOUND;
              g_reg_element(l_element) := 'Y';
           END LOOP;
           CLOSE get_reg_elements;
       END pick_elements_to_be_adjusted;

----------------------------Gen Special Main Section ---------------------------
   BEGIN                                                       --  Gen Special
      g_debug := hr_utility.debug_enabled;
      hxt_util.DEBUG ('Top of Gen_Special.');          -- debug only --HXT115
      hxt_util.DEBUG ('person id ' || TO_CHAR (g_person_id));

      -- debug only --HXT115
      IF g_debug
      THEN
         hr_utility.TRACE ('--------------Gen Special-----------------');
         hr_utility.set_location ('hxt_time_detail.gen_special', 1);
         hr_utility.TRACE (   'p_time_in               :'
                           || TO_CHAR (p_time_in, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'p_time_out              :'
                           || TO_CHAR (p_time_out, 'DD_MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE ('person id :' || TO_CHAR (g_person_id));
      END IF;

      -- Bug 8679560
      -- Commented out the explicit NULLING out of the tables
      -- below. When you are deleting, why NULL out explicitly ?
      IF g_special_explosion.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted g_special_explosion PL/SQL table');
         END IF;

         g_special_explosion.DELETE;
      END IF;

      IF g_dy_wk_combo_explosion.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted combo PL/SQL table');
         END IF;

         g_dy_wk_combo_explosion.DELETE;
      END IF;

      IF g_daily_explosion.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted daily PL/SQL table');
         END IF;

         g_daily_explosion.DELETE;
      END IF;

      IF g_weekly_explosion.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted weekly PL/SQL table');
         END IF;

         g_weekly_explosion.DELETE;
      END IF;

      IF g_daily_earn_category.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted g_daily_earn_category PL/SQL table');
         END IF;

         g_daily_earn_category.DELETE;
      END IF;

      IF g_weekly_earn_category.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted g_weekly_earn_category PL/SQL table');
         END IF;

         g_weekly_earn_category.DELETE;
      END IF;

      --  Determine which earning rule TYPE should be used.
      --  If element category is null, means hours passed are hours worked that day.
      --  Pay hours using regular daily rules, unless hours worked are on a holiday.
      --  Then pay hours using holiday rules.
      --  Determine the Earning Category  -  Validated earlier
      IF g_debug
      THEN
         hr_utility.TRACE ('g_element_type_id :' || g_element_type_id);
      END IF;

      IF g_element_type_id IS NULL
      THEN
         summary_earning_category := NULL;
      ELSE
         -- BEGIN ORACLE bug #712501
         summary_earning_category :=
                      hxt_util.element_cat (g_element_type_id, g_date_worked);
      -- END ORACLE bug #712501
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE (   'summary_earning_category :'
                           || summary_earning_category
                          );
         hr_utility.set_location ('hxt_time_detail.gen_special', 2);
      END IF;

      IF summary_earning_category IS NULL
      THEN                                            --- regular hours worked
         IF g_hol_yn = 'Y' AND holiday_rule_found(g_ep_id, g_date_worked)
         THEN                                            --- day is a holiday
            rule_type_to_pay := 'HOL';             --- then use holiday rules
         ELSE                                              --- normal work day
            rule_type_to_pay := 'DAY';               --- then use daily rules
         END IF;
         -- Bug 8600894
         pick_elements_to_be_adjusted;

      ELSIF summary_earning_category IN
                           ('ABS', 'OVT', 'REG', 'SDF', 'OTH', 'OSP', 'REG2')
      THEN
         rule_type_to_pay := 'ABS';
      ELSE
         rule_type_to_pay := NULL;
         fnd_message.set_name ('HXT', 'HXT_39304_INV_ERN_CAT');
         ERROR_CODE :=
            call_hxthxc_gen_error ('HXT',
                                   'HXT_39304_INV_ERN_CAT',
                                   NULL,
                                   LOCATION,
                                   ''
                                  );

         --2278400 error_code := call_gen_error(location, '');
         IF ERROR_CODE > l_error_return
         THEN
            l_error_return := ERROR_CODE;
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('rule_type_to_pay :' || rule_type_to_pay);
      END IF;

      OPEN check_spc_dy_eg;

      FETCH check_spc_dy_eg
       INTO g_spc_dy_eg;

      CLOSE check_spc_dy_eg;

      IF g_debug
      THEN
         hr_utility.TRACE ('g_SPC_DY_EG:' || g_spc_dy_eg);
      END IF;

      IF rule_type_to_pay = 'ABS'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('hxt_time_detail.gen_special', 3);
            hr_utility.TRACE
                    ('-----------Entering rule_type_to_pay = ABS------------');
         END IF;

         -- Pay absence hours with earning element from Summary (parent) record.
         IF g_debug
         THEN
            hr_utility.TRACE ('g_sdf_id:' || g_sdf_id);
            hr_utility.TRACE ('g_osp_id:' || g_osp_id);
         END IF;

         ERROR_CODE :=
            pay (p_hours_worked,
                 g_element_type_id,
                 p_time_in,
                 p_time_out,
                 g_date_worked,
                 g_id                                             -- parent id
                     ,
                 g_assignment_id,
                 g_fcl_earn_reason_code,
                 g_ffv_cost_center_id,
                 g_ffv_labor_account_id,
                 g_tas_id,
                 g_location_id,
                 g_sht_id,
                 g_hrw_comment,
                 g_ffv_rate_code_id,
                 g_rate_multiple,
                 g_hourly_rate,
                 g_amount,
                 g_fcl_tax_rule_code,
                 g_separate_check_flag,
                 g_project_id                                   -- ,g_GROUP_ID
                             ,
                 g_ep_id,
                 a_state_name       => g_state_name,
                 a_county_name      => g_county_name,
                 a_city_name        => g_city_name,
                 a_zip_code         => g_zip_code
                );

         IF g_debug
         THEN
            hr_utility.set_location ('hxt_time_detail.gen_special', 4);
         END IF;

         IF ERROR_CODE <> 0
         THEN
            IF ERROR_CODE > l_error_return
            THEN
               l_error_return := ERROR_CODE;
            END IF;

            hxt_util.DEBUG (   'Loc D. Return code is '
                            || TO_CHAR (l_error_return)
                           );

            IF g_debug
            THEN
               hr_utility.TRACE (   'Loc D. Return code is :'
                                 || TO_CHAR (l_error_return)
                                );
            END IF;

            RETURN l_error_return;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('hxt_time_detail.gen_special', 4.2);
            hr_utility.TRACE (   'date_worked           :'
                              || TO_CHAR (g_date_worked, 'DD/MON/YY')
                             );
            hr_utility.TRACE ('g_call_adjust_abs :' || g_call_adjust_abs);
            hr_utility.TRACE ('g_ep_id:' || g_ep_id);
            hr_utility.TRACE ('g_element_type_id:' || g_element_type_id);
         END IF;

         IF g_call_adjust_abs = 'Y'
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 4.3);
            END IF;

            -- begin 688072
            IF g_ep_type IN ('WEEKLY', 'SPECIAL')
            THEN
               -- Bug 2795054
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special',
                                           4.4);
               END IF;

               -- Bug 2795054
               -- Check if the Absence element count towards the Weekly Overtime cap,
               -- if yes only then call adjust for absence to re-adjust these absence
               -- hours over  the previous days of the week.
               l_abs_in_eg := NULL;

               OPEN check_abs_elem;

               FETCH check_abs_elem
                INTO l_abs_in_eg;

               CLOSE check_abs_elem;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_abs_in_eg:' || l_abs_in_eg);
               END IF;

               IF (l_abs_in_eg IS NOT NULL)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              4.5
                                             );
                  END IF;

                  ERROR_CODE :=
                         adjust_for_absence (g_tim_id, g_ep_id, g_date_worked);

                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              5
                                             );
                     hr_utility.TRACE ('error_code :' || ERROR_CODE);
                  END IF;

                  --SIR491 Begin
                  IF ERROR_CODE = 1
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               5.1
                                              );
                     END IF;

                     fnd_message.set_name ('HXT', 'HXT_39577_NO_HOURS_ADJUST');
                     ERROR_CODE :=
                        call_hxthxc_gen_error ('HXT',
                                               'HXT_39577_NO_HOURS_ADJUST',
                                               NULL,
                                               LOCATION,
                                               ''
                                              );
                  --2278400 error_code := call_gen_error(location, '');
                  ELSIF ERROR_CODE = 2
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               5.2
                                              );
                     END IF;

                     fnd_message.set_name ('HXT',
                                           'HXT_39311_WKLY_ERN_RULES_NF'
                                          );
                     ERROR_CODE :=
                        call_hxthxc_gen_error ('HXT',
                                               'HXT_39311_WKLY_ERN_RULES_NF',
                                               NULL,
                                               LOCATION,
                                               ''
                                              );
                  -- 2278400 error_code := call_gen_error(location, '');
                  ELSIF ERROR_CODE = 3
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               5.3
                                              );
                     END IF;

                     fnd_message.set_name ('HXT', 'HXT_39578_PAY_FAILED');
                     ERROR_CODE :=
                        call_hxthxc_gen_error ('HXT',
                                               'HXT_39578_PAY_FAILED',
                                               NULL,
                                               LOCATION,
                                               ''
                                              );
                  -- 2278400 error_code := call_gen_error(location, '');
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_error_return :' || l_error_return);
                  END IF;

                  IF ERROR_CODE > l_error_return
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               6
                                              );
                     END IF;

                     l_error_return := ERROR_CODE;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'Loc E. Return code is :'
                                          || TO_CHAR (l_error_return)
                                         );
                     END IF;
                  END IF;

                  --SIR491 END
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              6.1
                                             );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special',
                                           6.2);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 6.3);
            END IF;
         -- end 688072
         END IF;
      ELSE                                          -- rule_type_to_pay <> ABS
         IF g_debug
         THEN
            hr_utility.set_location ('hxt_time_detail.gen_special', 7);
            hr_utility.TRACE
                           ('------------rule_type_to_pay <> ABS------------');
         END IF;

         --  Loop through the earning rules for the earning policy
         --  Finish when the hours to be paid are all done
         --  all_detail_hours shows the hours for the day already in detail records
         previous_detail_hours_day :=
                       contig_hours_worked (g_date_worked, g_egt_id, g_tim_id);

         IF g_debug
         THEN
            hr_utility.TRACE (   'previous_detail_hours_day :'
                              || previous_detail_hours_day
                             );
         END IF;

         hours_paid_daily_rule := NVL (previous_detail_hours_day, 0);

         --from daily view
         IF g_debug
         THEN
            hr_utility.TRACE ('hours_paid_daily_rule:'
                              || hours_paid_daily_rule
                             );
         END IF;

         -- The previous call to procedure adjust_for_hdp has been commented
         -- out(not -- used anymore)
         -- hours_left_to_pay := adjust_for_hdp (p_hours_worked, ERROR_CODE);
         hours_left_to_pay := p_hours_worked;

         IF g_debug
         THEN
            hr_utility.TRACE ('hours_left_to_pay:' || hours_left_to_pay);
         END IF;

         IF ERROR_CODE > l_error_return
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 10);
            END IF;

            l_error_return := ERROR_CODE;
            hxt_util.DEBUG (   'Loc F. Return code is '
                            || TO_CHAR (l_error_return)
                           );                                    -- debug only

            IF g_debug
            THEN
               hr_utility.TRACE (   'Loc F. Return code is :'
                                 || TO_CHAR (l_error_return)
                                );
            END IF;
         END IF;

         hxt_util.DEBUG ('Hours left to pay is '
                         || TO_CHAR (hours_left_to_pay)
                        );                              -- debug only --HXT115

         -- Open the daily earning rules cursor and fetch the special row.
         -- If none is found the consecutive day limit flag is set to false.
         -- This can be done this way now as there is only one special rule allowed.
         -- If more are allowed in the future a loop may be needed to go through the
         -- rules.
         -- Weekly set to 999 if none found.
         IF g_debug
         THEN
            hr_utility.set_location ('hxt_time_detail.gen_special', 11);
         END IF;

         seven_day_cal_rule := FALSE;
         five_day_cal_rule := FALSE;
         consecutive_days_reached := FALSE;

         OPEN daily_earn_rules_cur (g_ep_id, 'SPC');

         FETCH daily_earn_rules_cur
          INTO special_daily_cap, special_earning_type,
               consecutive_days_limit;

         IF g_debug
         THEN
            hr_utility.TRACE ('special_daily_cap      :' || special_daily_cap);
            hr_utility.TRACE (   'special_earning_type   :'
                              || special_earning_type
                             );
            hr_utility.TRACE (   'consecutive_days_limit :'
                              || consecutive_days_limit
                             );
         END IF;

         IF daily_earn_rules_cur%FOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 12);
            END IF;

            -- Now that we know there is at least one day rule, determine how many
            -- consecutive days worked.  Use the rule with the highest day number
            -- less than or equal to consec days worked.
            CLOSE daily_earn_rules_cur;

            IF g_debug
            THEN
               hr_utility.TRACE ('g_SPC_DY_EG:' || g_spc_dy_eg);
            END IF;

            IF g_spc_dy_eg IS NOT NULL
            THEN
               consec_days_worked :=
                                consecutivedaysworked_for_spc (g_date_worked);

               IF g_debug
               THEN
                  hr_utility.TRACE (   'date_worked :'
                                    || TO_CHAR (g_date_worked, 'DD/MON/YY')
                                   );
                  hr_utility.TRACE (   'consec_days_worked:'
                                    || TO_CHAR (consec_days_worked)
                                   );
               END IF;
            ELSE
               consec_days_worked := getconsecutivedaysworked (g_date_worked);

               IF g_debug
               THEN
                  hr_utility.TRACE (   'date_worked:'
                                    || TO_CHAR (g_date_worked, 'DD/MON/YY')
                                   );
                  hr_utility.TRACE (   'consec_days_worked:'
                                    || TO_CHAR (consec_days_worked)
                                   );
               END IF;
            END IF;

            OPEN spc_earn_rules_cur (g_ep_id, consec_days_worked);

            FETCH spc_earn_rules_cur
             INTO special_daily_cap, special_earning_type,
                  consecutive_days_limit;

            hxt_util.DEBUG (   'cap,earn_type,days'
                            || TO_CHAR (special_daily_cap)
                            || ','                               -- debug only
                            || TO_CHAR (special_earning_type)
                            || ','                               -- debug only
                            || TO_CHAR (consecutive_days_limit)
                           );                                    -- debug only

            IF g_debug
            THEN
               hr_utility.TRACE (   'special_daily_cap     :'
                                 || TO_CHAR (special_daily_cap)
                                );
               hr_utility.TRACE (   'special_earning_type  :'
                                 || TO_CHAR (special_earning_type)
                                );
               hr_utility.TRACE (   'consecutive_days_limit:'
                                 || TO_CHAR (consecutive_days_limit)
                                );
            END IF;

            IF spc_earn_rules_cur%FOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 13);
               END IF;

               FETCH spc_earn_rules_cur
                INTO special_daily_cap2, special_earning_type2,
                     consecutive_days_limit2;

               IF consecutive_days_limit <> consecutive_days_limit2
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              14
                                             );
                  END IF;

                  special_daily_cap2 := 99;
                  special_earning_type2 := NULL;
               END IF;

               IF consec_days_worked >= consecutive_days_limit
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              15
                                             );
                  END IF;

                  consecutive_days_reached := TRUE;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              16
                                             );
                  END IF;

                  consecutive_days_reached := FALSE;
               END IF;

               IF consecutive_days_limit = 7
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              17
                                             );
                  END IF;

                  seven_day_cal_rule := TRUE;
               ELSIF consecutive_days_limit = 5
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              18
                                             );
                  END IF;

                  five_day_cal_rule := TRUE;
               END IF;

               hxt_util.DEBUG (   '2nd cap,earn_type,days,reached'
                               || TO_CHAR (special_daily_cap2)
                               || ','                            -- debug only
                               || TO_CHAR (special_earning_type2)
                               || ','                            -- debug only
                               || TO_CHAR (consecutive_days_limit2)
                              );                                 -- debug only

               IF g_debug
               THEN
                  hr_utility.TRACE (   'special_daily_cap2      :'
                                    || TO_CHAR (special_daily_cap2)
                                   );
                  hr_utility.TRACE (   'special_earning_type2   :'
                                    || TO_CHAR (special_earning_type2)
                                   );
                  hr_utility.TRACE (   'consecutive_days_limit2 :'
                                    || TO_CHAR (consecutive_days_limit2)
                                   );
               END IF;
            ELSE                               -- spc_earn_rules_cur NOT FOUND
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 19);
               END IF;

               special_daily_cap := 99;
               special_earning_type := NULL;
               special_daily_cap2 := 99;
               special_earning_type2 := NULL;
            END IF;
         ELSE       -- daily_earn_rules_cur NOT FOUND (NO SPECIAL (DAYS) RULE)
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 20);
            END IF;

            CLOSE daily_earn_rules_cur;
         END IF;

         -- Open the daily and weekly cursors and fetch the first row of each.
         -- The two must be processed differently now as the daily hours are for the
         -- earning type of the current daily rule while the weekly earning type is
         -- applied to the hours of the next weekly rule if there are any.
         OPEN daily_earn_rules_cur (g_ep_id, 'DAY');

         FETCH daily_earn_rules_cur
          INTO daily_rule_cap, daily_earning_type, dummy_days;

         first_daily_rule_cap := daily_rule_cap;

         IF g_debug
         THEN
            hr_utility.TRACE ('first_daily_rule_cap:' || first_daily_rule_cap);
            hr_utility.TRACE ('g_EP_TYPE           :' || g_ep_type);
         END IF;

         IF (daily_earn_rules_cur%NOTFOUND AND (g_ep_type = 'WEEKLY'))
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 21);
               hr_utility.TRACE
                        ('daily_earn_rules_cur NOTFOUND and EP_TYPE = WEEKLY');
            END IF;

            daily_rule_cap := 24;
            first_daily_rule_cap := 24;
         END IF;

         IF (daily_earn_rules_cur%NOTFOUND AND (g_ep_type <> 'WEEKLY'))
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 22);
               hr_utility.TRACE
                         ('daily_earn_rules_cur NOTFOUND and EP_TYPE<>WEEKLY');
            END IF;

            fnd_message.set_name ('HXT', 'HXT_39307_DAILY_BASE_REC_NF');
            ERROR_CODE :=
               call_hxthxc_gen_error ('HXT',
                                      'HXT_39307_DAILY_BASE_REC_NF',
                                      NULL,
                                      LOCATION,
                                      ''
                                     );

            --2278400 error_code := call_gen_error(location, '');
            IF ERROR_CODE > l_error_return
            THEN
               l_error_return := ERROR_CODE;
               hxt_util.DEBUG (   'Loc G. Return code is '
                               || TO_CHAR (l_error_return)
                              );

               IF g_debug
               THEN
                  hr_utility.TRACE (   'Loc G. Return code is:'
                                    || TO_CHAR (l_error_return)
                                   );
               END IF;
            END IF;
         END IF;

         special_and_weekly_base := daily_earning_type;

         IF g_debug
         THEN
            hr_utility.TRACE (   'special_and_weekly_base :'
                              || special_and_weekly_base
                             );
         END IF;

         -- base for special and weekly earnings as none can be specified except
         -- on a weekly type policy
         IF rule_type_to_pay <> 'DAY'
         THEN                                             --  for now only HOL
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 23);
            END IF;

            CLOSE daily_earn_rules_cur;          --  opened with parameter DAY

            OPEN daily_earn_rules_cur (g_ep_id, rule_type_to_pay);

            -- open for HOL rules
            FETCH daily_earn_rules_cur
             INTO daily_rule_cap, daily_earning_type, dummy_days;

            IF daily_earn_rules_cur%NOTFOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 24);
               END IF;

               end_of_day_rules := TRUE;
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('g_ep_id :' || g_ep_id);
         END IF;

         OPEN weekly_earn_rules_cur (g_ep_id);

         IF g_debug
         THEN
            hr_utility.TRACE
                            ('---------OPEN weekly_earn_rules_cur-----------');
         END IF;

         FETCH weekly_earn_rules_cur
          INTO weekly_rule_cap, weekly_earning_type;

         IF g_debug
         THEN
            hr_utility.TRACE
                          ('---------FETCHED weekly_earn_rules_cur----------');
            hr_utility.TRACE ('weekly_rule_cap     :' || weekly_rule_cap);
            hr_utility.TRACE ('weekly_earning_type :' || weekly_earning_type);
         END IF;

         IF weekly_earn_rules_cur%NOTFOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 25);
            END IF;

            IF g_ep_type = 'WEEKLY'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 26);
               END IF;

               fnd_message.set_name ('HXT', 'HXT_39311_WKLY_ERN_RULES_NF');
               ERROR_CODE :=
                  call_hxthxc_gen_error ('HXT',
                                         'HXT_39311_WKLY_ERN_RULES_NF',
                                         NULL,
                                         LOCATION,
                                         ''
                                        );

               --2278400 error_code := call_gen_error(location, '');
               IF ERROR_CODE > l_error_return
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              27
                                             );
                  END IF;

                  l_error_return := ERROR_CODE;
                  hxt_util.DEBUG (   'Loc H. Return code is '
                                  || TO_CHAR (l_error_return)
                                 );
               END IF;                                                --SIR014
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 28);
               END IF;

               weekly_rule_cap := 999;
               hours_paid_weekly_rule := 0;
            END IF;
         END IF;


         -- Bug 6854096
         -- Reverted back the below changes made for 5260857.
         -- This was done to cater for a slight change in OT explosion
         -- when straight time was entered in place of hours, in case
         -- an SDP is attached.  This change would actually topple up the
         -- rest of weekly explosion, and hence reverting it back.
         -- The original issue remains unanswered now, and need to fix that
         -- with another bug. Nevertheless, its a corner scenario.

         /*
         hours_paid_weekly_rule := --get_weekly_total;               -- SPR C148
                           get_weekly_total_prev_days   --M. Bhammar bug 5260857
                           + NVL (previous_detail_hours_day, 0);
         */

         -- Bug 7143238
         -- Guessing we fixed the above open issue here.
         -- The change is called only if there is an SDP attached, and start/stop
         -- times are entered instead of hours.  The issue with fix above was
         -- that previous_detail_hours_day was picking up all hours which are
         -- recorded against the day, instead of those which are generated by OTLR
         -- according to the plans.
         -- The new function contig_hours_worked2 picks up hours entered on that
         -- day, which dont have an element in summary table ( not any kind of
         -- override elements ).

         IF g_debug
         THEN
             hr_utility.trace('get_weekly_total = '||get_weekly_total);
             hr_utility.trace('get_weekly_total_prev_days '||get_weekly_total_prev_days);
             hr_utility.trace('previous_detail_hours_day '||previous_detail_hours_day);
             hr_utility.trace('p_time_in '||p_time_in);
             hr_utility.trace('p_time_out '||p_time_out);
         END IF;

         IF (      g_sdp_id   IS NOT NULL
  	      AND  p_time_in  IS NOT NULL
  	      AND  p_time_out IS NOT NULL )
  	 THEN

  	        hours_paid_weekly_rule := get_weekly_total_prev_days +
  	                    NVL(contig_hours_worked2(g_date_worked, g_egt_id, g_tim_id),0);
  	 ELSE
  	        hours_paid_weekly_rule := get_weekly_total;               -- SPR C148

  	 END IF ;





         -- hours_paid_weekly_rule := get_weekly_total_to_date('REG');
         IF g_debug
         THEN
            hr_utility.TRACE (   'hours_paid_weekly_rule :'
                              || hours_paid_weekly_rule
                             );
         END IF;

         -- HXT_UTIL.DEBUG('get_weekly_total is '||to_char(hours_paid_weekly_rule));
         IF hours_paid_weekly_rule >= weekly_rule_cap
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 29);
            END IF;

            first_weekly_cap_reached := TRUE;
         END IF;

         b_first_time := TRUE;
         l_time_in := p_time_in;
         l_time_out := p_time_out;

         IF g_debug
         THEN
            hr_utility.TRACE ('l_time_in :' || TO_CHAR (l_time_in, 'HH24:MI'));
            hr_utility.TRACE ('l_time_out:' || TO_CHAR (l_time_out, 'HH24:MI')
                             );
         END IF;

--SIR494 We must allow the loop to process at least once or we will not be able
--SIR494 to pay rows where hours are zero but an amount has been entered PWM 09FEB00
--SIR494 WHILE hours_left_to_pay <> 0 AND error_code = 0 LOOP
         WHILE (   (hours_left_to_pay <> 0 AND ERROR_CODE = 0)
                OR (    b_first_time = TRUE
                    AND NVL (l_use_points_assigned, 'N') = 'N'
                   )
               )                                  -- Added this AND clause for
         -- bug 2956224 fix.
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 30);
            END IF;

            IF g_ep_type = 'WEEKLY' AND rule_type_to_pay <> 'HOL'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 31);
               END IF;

               select_weekly_hours (rule_to_pay,
                                    hours_to_pay_this_rule,
                                    element_type_id_to_pay
                                   );

               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special',
                                           31.5
                                          );
               END IF;

               IF ERROR_CODE > l_error_return
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              32
                                             );
                  END IF;

                  l_error_return := ERROR_CODE;
                  hxt_util.DEBUG (   'Loc I. Return code is'
                                  || TO_CHAR (l_error_return)
                                 );
               END IF;
            ELSIF     g_ep_type IN ('WEEKLY', 'SPECIAL')
                  AND rule_type_to_pay = 'HOL'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special',
                                           32.1
                                          );
               END IF;

               select_hol_weekly_hours (rule_to_pay,
                                        hours_to_pay_this_rule,
                                        element_type_id_to_pay
                                       );

               IF g_debug
               THEN
                   hr_utility.trace(' Rule to pay : '||rule_to_pay);
                   hr_utility.trace(' hours_to_pay_this_rule : '||hours_to_pay_this_rule);
                   hr_utility.trace(' element_type_id_to_pay : '||element_type_id_to_pay);
               END IF;

               IF ERROR_CODE > l_error_return
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              32.5
                                             );
                  END IF;

                  l_error_return := ERROR_CODE;
                  hxt_util.DEBUG (   'Loc I. Return code is'
                                  || TO_CHAR (l_error_return)
                                 );
               END IF;
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 33);
               END IF;

               --MHANDA Determine whether the rules to be applied use the
               --points counter.
               SELECT use_points_assigned
                 INTO l_use_points_assigned
                 FROM hxt_earning_policies
                WHERE ID = g_ep_id;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'use_points_assigned? :'
                                    || l_use_points_assigned
                                   );
               END IF;

               IF l_use_points_assigned = 'N' OR l_use_points_assigned IS NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              33.1
                                             );
                  END IF;

                  select_rule_and_hours (ERROR_CODE,
                                         rule_to_pay,
                                         hours_to_pay_this_rule,
                                         element_type_id_to_pay
                                        );

                  IF g_debug
                  THEN
                      hr_utility.trace('rule_to_pay '||rule_to_pay);
                      hr_utility.trace('hours_to_pay_this_rule '||hours_to_pay_this_rule);
                      hr_utility.trace('element_type_id_to_pay '||element_type_id_to_pay);
                  END IF;

               ELSIF l_use_points_assigned = 'Y'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              33.2
                                             );
                  END IF;

                  use_points_to_select_rule_hrs (ERROR_CODE,
                                                 rule_to_pay,
                                                 hours_to_pay_this_rule,
                                                 element_type_id_to_pay
                                                );

                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              33.3
                                             );
                  END IF;
               END IF;

               IF ERROR_CODE > l_error_return
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              34
                                             );
                  END IF;

                  l_error_return := ERROR_CODE;
                  hxt_util.DEBUG (   'Loc J. Return code is'
                                  || TO_CHAR (l_error_return)
                                 );
               END IF;                                                --SIR014
            END IF;

            IF g_debug
            THEN
               hr_utility.TRACE ('g_hours :' || g_hours);
            END IF;

            IF l_use_points_assigned = 'N' OR l_use_points_assigned IS NULL
            THEN
               IF g_hours >= 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              35
                                             );
                     hr_utility.TRACE (   'hours_to_pay_this_rule :'
                                       || hours_to_pay_this_rule
                                      );
                  END IF;

                  hours_to_pay_this_rule :=
                                          GREATEST (hours_to_pay_this_rule, 0);

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'hours_to_pay_this_rule :'
                                       || hours_to_pay_this_rule
                                      );
                  END IF;
               -- can be negative if a rule was
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.TRACE ('error_code :' || ERROR_CODE);
            END IF;

            IF (   (hours_to_pay_this_rule > 0 AND ERROR_CODE = 0)
                OR (b_first_time = TRUE)
               )
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 36);
                  hr_utility.TRACE (   'l_time_in :'
                                    || TO_CHAR (l_time_in, 'HH24:MI')
                                   );
                  hr_utility.TRACE (   'l_time_out:'
                                    || TO_CHAR (l_time_out, 'HH24:MI')
                                   );
               END IF;

               -- l_time_out := l_time_in + (hours_to_pay_this_rule/24);
               l_time_in := ROUND (l_time_in, 'MI');
               l_time_out :=
                       ROUND (l_time_in + (hours_to_pay_this_rule / 24), 'MI');

               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_time_in :'
                                    || TO_CHAR (l_time_in, 'HH24:MI')
                                   );
                  hr_utility.TRACE (   'l_time_out:'
                                    || TO_CHAR (l_time_out, 'HH24:MI')
                                   );
                  hr_utility.TRACE ('********RM BEFORE CALL TO PAY**********');
                  hr_utility.TRACE (   'hours_to_pay_this_rule IS : *** : '
                                    || TO_CHAR (hours_to_pay_this_rule)
                                   );
                  hr_utility.TRACE (   'l_time_in IS : *** : '
                                    || TO_CHAR (l_time_in,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'l_time_out IS : *** : '
                                    || TO_CHAR (l_time_out,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'element_type_id_to_pay IS : *** : '
                                    || TO_CHAR (element_type_id_to_pay)
                                   );
                  hr_utility.TRACE (   'g_date_worked IS : *** : '
                                    || TO_CHAR (g_date_worked, 'DD-MON-YYYY')
                                   );
               END IF;


               -- Bug 8600894
               IF g_hol_yn = 'Y'
                 AND fnd_profile.value('HXT_HOLIDAY_EXPLOSION') IN ( 'NO','OO')
                 AND g_reg_element.EXISTS(element_type_id_to_pay)
               THEN
                  l_cache := g_pep_id;
                  g_pep_id := NULL;
               END IF;

               ERROR_CODE :=
                  pay (hours_to_pay_this_rule,
                       element_type_id_to_pay,
                       l_time_in,
                       l_time_out,
                       g_date_worked,
                       g_id                                       -- parent id
                           ,
                       g_assignment_id,
                       g_fcl_earn_reason_code,
                       g_ffv_cost_center_id,
                       g_ffv_labor_account_id,
                       g_tas_id,
                       g_location_id,
                       g_sht_id,
                       g_hrw_comment,
                       g_ffv_rate_code_id,
                       g_rate_multiple,
                       g_hourly_rate,
                       g_amount,
                       g_fcl_tax_rule_code,
                       g_separate_check_flag,
                       g_project_id                              --,g_GROUP_ID
                                   ,
                       g_ep_id,
                       a_state_name       => g_state_name,
                       a_county_name      => g_county_name,
                       a_city_name        => g_city_name,
                       a_zip_code         => g_zip_code
                      );

               -- Bug 8600894
               IF g_hol_yn = 'Y'
                 AND fnd_profile.value('HXT_HOLIDAY_EXPLOSION') IN ( 'NO','OO')
                 AND g_reg_element.EXISTS(element_type_id_to_pay)
               THEN
                  g_pep_id := l_cache;
                  l_cache := NULL;
               END IF;

               IF ERROR_CODE <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              37
                                             );
                  END IF;

                  IF ERROR_CODE > l_error_return
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               38
                                              );
                     END IF;

                     l_error_return := ERROR_CODE;
                  END IF;

                  hxt_util.DEBUG (   'Loc K. Return code is '
                                  || TO_CHAR (l_error_return)
                                 );
                  RETURN l_error_return;
               --return error_code;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 39);
                  hr_utility.TRACE (   'hours_left_to_pay :'
                                    || TO_CHAR (hours_left_to_pay)
                                   );
               END IF;

               hxt_util.DEBUG (   'Ahrslefttopay is '
                               || TO_CHAR (hours_left_to_pay)
                              );

               IF g_debug
               THEN
                  hr_utility.TRACE (   'hours_to_pay_this_rule :'
                                    || TO_CHAR (hours_to_pay_this_rule)
                                   );
                  hr_utility.TRACE (   'l_use_points_assigned :'
                                    || l_use_points_assigned
                                   );
               END IF;

               l_time_in := l_time_in + (hours_to_pay_this_rule / 24);

               IF l_use_points_assigned = 'N' OR l_use_points_assigned IS NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              39.5
                                             );
                  END IF;

                  hours_left_to_pay :=
                                    hours_left_to_pay - hours_to_pay_this_rule;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 40);
                  hr_utility.TRACE (   'hours_left_to_pay :'
                                    || TO_CHAR (hours_left_to_pay)
                                   );
               END IF;

               hxt_util.DEBUG (   'Bhrslefttopay is '
                               || TO_CHAR (hours_left_to_pay)
                              );
            END IF;

            b_first_time := FALSE;

            IF l_use_points_assigned = 'N' OR l_use_points_assigned IS NULL
            THEN
               IF hours_left_to_pay >= 0 AND ERROR_CODE = 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              41
                                             );
                  END IF;

                  --changed to >= in order to payback wkly if cap hit at 0
                  reset_rules (hours_paid_daily_rule,
                               hours_paid_weekly_rule,
                               fetch_next_day,
                               fetch_next_week,
                               rule_to_pay
                              );

                  -- MHANDA Added to fetch the next weekly cap once the
                  -- weekly cap is reached
                  IF     hours_paid_weekly_rule >= weekly_rule_cap
                     AND g_ep_type = 'SPECIAL'
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               41.5
                                              );
                     END IF;

                     fetch_next_week := TRUE;
                  END IF;

                  IF fetch_next_day = TRUE
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               42
                                              );
                     END IF;

                     FETCH daily_earn_rules_cur
                      INTO daily_rule_cap, daily_earning_type, dummy_days;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'daily_rule_cap     :'
                                          || daily_rule_cap
                                         );
                        hr_utility.TRACE (   'daily_earning_type :'
                                          || daily_earning_type
                                         );
                        hr_utility.TRACE ('dummy_days         :' || dummy_days);
                     END IF;

                     IF daily_earn_rules_cur%NOTFOUND
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               43
                                              );
                        END IF;

                        end_of_day_rules := TRUE;
                     END IF;
                  END IF;

                  IF fetch_next_week = TRUE
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               44
                                              );
                     END IF;

                     current_weekly_earning := weekly_earning_type;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'current_weekly_earning :'
                                          || current_weekly_earning
                                         );
                     END IF;

                     FETCH weekly_earn_rules_cur
                      INTO weekly_rule_cap, weekly_earning_type;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'weekly_rule_cap     :'
                                          || weekly_rule_cap
                                         );
                        hr_utility.TRACE (   'weekly_earning_type :'
                                          || weekly_earning_type
                                         );
                     END IF;

                     -- MHANDA checking whether the person is eligible for doubletime
                     -- once the weekly overtime cap is reached ,when the earning
                     -- policy is of type SPECIAL
                     IF g_ep_type = 'SPECIAL'
                     THEN
                        hours_paid_for_dtime_elig :=
                                                get_wkly_total_for_doubletime;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'hours_paid_for_dtime_elig :'
                                             || hours_paid_for_dtime_elig
                                            );
                        END IF;

                        IF hours_paid_for_dtime_elig >= weekly_rule_cap
                        THEN
                           second_weekly_cap_reached := TRUE;

                           IF hours_paid_for_dtime_elig > weekly_rule_cap
                           THEN
                              hours_paid_weekly_rule :=
                                                get_wkly_total_for_doubletime;
                           END IF;
                        END IF;
                     END IF;

                      -- MHANDA getting total number of hours after which the person
                      -- is eligible for doubletime i.e., when second weekly cap is
                      -- reached,when earning policy type is WEEKLY.
                     /* IF g_EP_TYPE = 'WEEKLY' THEN
                         hours_paid_weekly_rule := get_wkly_total_for_doubletime;
                         hr_utility.trace('hours_paid_weekly_rule :'||hours_paid_weekly_rule);
                      END IF;
                      */
                     IF weekly_earn_rules_cur%NOTFOUND
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               45
                                              );
                        END IF;

                        weekly_rule_cap := 999;
                     END IF;
                  END IF;                            -- fetch_next_week = TRUE
               ELSIF hours_left_to_pay < 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              46
                                             );
                  END IF;

                  IF g_hours >= 0
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               47
                                              );
                     END IF;

                     fnd_message.set_name ('HXT',
                                           'HXT_39303_HRS_PD_GRT_HRS_PAY'
                                          );
                     ERROR_CODE :=
                        call_hxthxc_gen_error ('HXT',
                                               'HXT_39303_HRS_PD_GRT_HRS_PAY',
                                               NULL,
                                               LOCATION,
                                               ''
                                              );

                     --2278400 error_code := call_gen_error(location, '');
                     IF ERROR_CODE > l_error_return
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               48
                                              );
                        END IF;

                        l_error_return := ERROR_CODE;
                        hxt_util.DEBUG (   'Loc L. Return code is'
                                        || TO_CHAR (l_error_return)
                                       );
                     END IF;                                          --SIR014
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                              ('hxt_time_detail.gen_special',
                                               49
                                              );
                     END IF;

                     hours_left_to_pay := 0;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              50
                                             );
                  END IF;
               END IF;              --hours_left_to_pay > 0 and error_code = 0
            END IF;                              --l_use_points_assigned = 'N'

            loop_counter := loop_counter + 1;

            IF loop_counter > 50
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 52);
               END IF;

               fnd_message.set_name ('HXT', 'HXT_39305_LOOP_LIMIT_EXC');
               ERROR_CODE :=
                  call_hxthxc_gen_error ('HXT',
                                         'HXT_39305_LOOP_LIMIT_EXC',
                                         NULL,
                                         LOCATION,
                                         ''
                                        );

               --2278400 error_code := call_gen_error(location, '');
               IF ERROR_CODE > l_error_return
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              53
                                             );
                  END IF;

                  l_error_return := ERROR_CODE;
               END IF;

               hxt_util.DEBUG (   'Loc M. Return code is'
                               || TO_CHAR (l_error_return)
                              );
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 54);
            END IF;
         END LOOP;         --  While hours_left_to_pay <> 0 AND error_code = 0

         CLOSE daily_earn_rules_cur;

         CLOSE weekly_earn_rules_cur;

         IF     seven_day_cal_rule = TRUE
            AND g_cons_days_worked = 6
            AND ERROR_CODE = 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 54.5);
            END IF;

            l_day_total := get_daily_total;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_day_total :' || l_day_total);
            END IF;

            IF l_day_total > 12
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 55);
               END IF;

               ERROR_CODE := adjust_for_double_time (l_day_total);

               IF ERROR_CODE = 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              56
                                             );
                  END IF;

                  NULL;
               ELSIF ERROR_CODE = 1
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              57
                                             );
                  END IF;

                  fnd_message.set_name ('HXT', 'HXT_39474_6TH_DAY_OT_NF');
                  ERROR_CODE :=
                     call_hxthxc_gen_error ('HXT',
                                            'HXT_39474_6TH_DAY_OT_NF',
                                            NULL,
                                            LOCATION,
                                            ''
                                           );
               -- 2278400 error_code := call_gen_error(location, '');
               ELSIF ERROR_CODE = 2
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              58
                                             );
                  END IF;

                  fnd_message.set_name ('HXT', 'HXT_39475_1ST_RULE_NF');
                  ERROR_CODE :=
                     call_hxthxc_gen_error ('HXT',
                                            'HXT_39475_1ST_RULE_NF',
                                            NULL,
                                            LOCATION,
                                            ''
                                           );
               --2278400 error_code := call_gen_error(location, '');
               ELSIF ERROR_CODE = 3
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              59
                                             );
                  END IF;

                  fnd_message.set_name ('HXT', 'HXT_39476_2ND_RULE_NF');
                  ERROR_CODE :=
                     call_hxthxc_gen_error ('HXT',
                                            'HXT_39476_2ND_RULE_NF',
                                            NULL,
                                            LOCATION,
                                            ''
                                           );
               -- 2278400 error_code := call_gen_error(location, '');
               ELSIF ERROR_CODE = 4
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              60
                                             );
                  END IF;

                  fnd_message.set_name ('HXT', 'HXT_39477_3RD_RULE_NF');
                  ERROR_CODE :=
                     call_hxthxc_gen_error ('HXT',
                                            'HXT_39477_3RD_RULE_NF',
                                            NULL,
                                            LOCATION,
                                            ''
                                           );
               -- 2278400 error_code := call_gen_error(location, '');
               ELSIF ERROR_CODE = 5
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              61
                                             );
                  END IF;

                  fnd_message.set_name ('HXT', 'HXT_39478_ERR_IN_MOD_PAY');
                  ERROR_CODE :=
                     call_hxthxc_gen_error ('HXT',
                                            'HXT_39478_ERR_IN_MOD_PAY',
                                            NULL,
                                            LOCATION,
                                            ''
                                           );
               --2278400 error_code := call_gen_error(location, '');
               END IF;

               IF ERROR_CODE > l_error_return
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location ('hxt_time_detail.gen_special',
                                              62
                                             );
                  END IF;

                  l_error_return := ERROR_CODE;
                  hxt_util.DEBUG (   'Loc N. Return code is '
                                  || TO_CHAR (l_error_return)
                                 );
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('hxt_time_detail.gen_special', 63);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location ('hxt_time_detail.gen_special', 64);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE
                     ('-----------Leaving rule_type_to_pay = ABS------------');
         END IF;
      END IF;                                      -- rule_type_to_pay = 'ABS'

-- the following function deletes erroneously generated detail rows
-- that have zero hours and time_in is equal to time_out. These rows have
-- caused endless looping in the get_contig_hours function. The cursor in
-- get_contig_hours has been altered to exclude rows where time_in =
-- time_out and delete_zero_hour_details removes these invalid rows from
-- table hxt_det_hours_worked. PWM 06-MAR-00
      ERROR_CODE :=
         (delete_zero_hour_details (g_tim_id, g_ep_id, g_osp_id,
                                    g_date_worked)
         );

      IF ERROR_CODE > l_error_return
      THEN
         l_error_return := ERROR_CODE;
         hxt_util.DEBUG ('Loc O. Return code is ' || TO_CHAR (l_error_return));
      END IF;

/* MHANDA - Changed on 10/22/2001
   Commenting out this function call as it is updating all
   overtime records to Zero and time in and time out to be the
   same for earning policy with 3 tier weekly rules
   error_code := adjust_for_3tier(g_tim_id,
                                   g_ep_id,
                                   g_date_worked);

    IF error_code > l_error_return THEN
       l_error_return := error_code;
       HXT_UTIL.DEBUG('Loc P. Return code is '||to_char(l_error_return));
    End if;
*/

      -- Combine the exploded chunks if they are contiguous for an element
      ERROR_CODE := combine_contig_chunks;

      IF ERROR_CODE > l_error_return
      THEN
         l_error_return := ERROR_CODE;
         hxt_util.DEBUG ('Loc O. Return code is ' || TO_CHAR (l_error_return));
      END IF;

      -- Bug 8600894
      IF fnd_profile.value('HXT_HOLIDAY_EXPLOSION') IN ('NO','OO')
      THEN
          g_hdp_id := NULL;
      END IF;

      ERROR_CODE := adjust_hours_for_hdp;

      IF ERROR_CODE > l_error_return
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('hxt_time_detail.gen_special', 65);
         END IF;

         l_error_return := ERROR_CODE;
         hxt_util.DEBUG ('Loc F. Return code is ' || TO_CHAR (l_error_return));

         -- debug only
         IF g_debug
         THEN
            hr_utility.TRACE (   'Loc F. Return code is :'
                              || TO_CHAR (l_error_return)
                             );
         END IF;
      END IF;

      RETURN (l_error_return);
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39269_ORACLE_ERROR');
         ERROR_CODE :=
            call_hxthxc_gen_error ('HXT',
                                   'HXT_39269_ORACLE_ERROR',
                                   NULL,
                                   LOCATION,
                                   ''
                                  );
         --2278400 error_code := call_gen_error(location, '');
         hxt_util.DEBUG ('Loc Q. Return code is ' || TO_CHAR (ERROR_CODE));
         hxt_util.DEBUG ('code is ' || SQLERRM);
         RETURN (ERROR_CODE);
   END;                                                        --  gen special

   FUNCTION delete_zero_hour_details (
      a_tim_id        NUMBER,
      a_ep_id         NUMBER,
      a_osp_id        NUMBER,
      a_date_worked   DATE
   )
      RETURN NUMBER
   IS
/* SIR538 This cursor was deleting detail rows that had amounts, but zero hours
   so it was re-written. PWM 03-MAR-00 */
      -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

      /*
      CURSOR zero_hrs_cur (c_tim_id NUMBER, c_date_worked DATE)
      IS
         SELECT hrw.ROWID hrw_rowid
           FROM hxt_det_hours_worked hrw
          WHERE hrw.date_worked <= c_date_worked
            AND hrw.tim_id = c_tim_id
            AND (   (
                         -- To take care of errorneous records created after the records
                         -- have been transferred to OTLR/BEE and then TC modified to zero
                         -- hrs(i.e., basically to delete TC) in SS
                         (NVL (hrw.hours, 0) = 0)
                     AND (NVL (hrw.amount, 0) = 0)
                     AND (hrw.time_in = hrw.time_out)
                     AND (hrw.time_in IS NOT NULL)
                     AND (hrw.time_out IS NOT NULL)
                     AND (hrw.retro_batch_id IS NOT NULL)
                    )
                 OR (       (NVL (hrw.hours, 0) = 0)
                        AND (NVL (hrw.amount, 0) = 0)
                        -- Commented out the following in order to delete the erroneous
                        -- records generated when updating a TC already transferred to BEE.
                        AND (hrw.retro_batch_id IS NULL
                            )                       -- Put it back for 3536182
                     -- Added this OR condition to delete erroneously generated
                     -- Shift diff Premium records where amount is not null and
                     -- time_in is equal to time_out.
                     OR (    (NVL (hrw.hours, 0) = 0)
                         AND NVL (hrw.amount, 0) <> 0
                         AND hrw.time_in = hrw.time_out
                         AND hrw.retro_batch_id IS NULL
                        )
                    )
                );
        */

      CURSOR zero_hrs_cur (c_tim_id NUMBER, c_date_worked DATE,c_session_date DATE)
      IS
         SELECT hrw.ROWID hrw_rowid
           FROM hxt_det_hours_worked_f hrw
          WHERE hrw.date_worked <= c_date_worked
            AND c_session_date BETWEEN hrw.effective_start_date
                                   AND hrw.effective_end_date
            AND hrw.tim_id = c_tim_id
            AND (   (
                         (NVL (hrw.hours, 0) = 0)
                     AND (NVL (hrw.amount, 0) = 0)
                     AND (hrw.time_in = hrw.time_out)
                     AND (hrw.time_in IS NOT NULL)
                     AND (hrw.time_out IS NOT NULL)
                     AND (hrw.retro_batch_id IS NOT NULL)
                    )
                 OR (       (NVL (hrw.hours, 0) = 0)
                        AND (NVL (hrw.amount, 0) = 0)
                        AND (hrw.retro_batch_id IS NULL
                            )                       -- Put it back for 3536182
                     OR (    (NVL (hrw.hours, 0) = 0)
                         AND NVL (hrw.amount, 0) <> 0
                         AND hrw.time_in = hrw.time_out
                         AND hrw.retro_batch_id IS NULL
                        )
                    )
                );


      CURSOR duplicate_flat_dy_prems (
         c_tim_id        NUMBER,
         c_osp_id        NUMBER,
         c_date_worked   DATE
      )
      IS
         SELECT   dhw.ROWID dhw_rowid, dhw.ID, dhw.parent_id, dhw.tim_id,
                  dhw.hours, dhw.time_in, dhw.time_out, dhw.seqno,
                  eltv.hxt_premium_amount, eltv.hxt_earning_category,
                  dhw.element_type_id
             FROM hxt_pay_element_types_f_ddf_v eltv,
                  pay_element_types_f elt,
                  hxt_det_hours_worked_f dhw
            WHERE dhw.tim_id = c_tim_id
              AND dhw.date_worked = c_date_worked
              AND elt.element_type_id = dhw.element_type_id
              AND dhw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND eltv.element_type_id = elt.element_type_id
              AND elt.element_type_id = c_osp_id
              AND dhw.date_worked BETWEEN eltv.effective_start_date
                                      AND eltv.effective_end_date
              AND eltv.hxt_earning_category = 'OSP'
              AND eltv.hxt_premium_type = 'FIXED'
              AND dhw.ID >
                     (SELECT /*+ NO_UNNEST */
                             MIN (hdw.ID)
                        FROM hxt_det_hours_worked_f hdw
                       WHERE hdw.tim_id = dhw.tim_id
                         AND hdw.date_worked = c_date_worked
                         AND hdw.element_type_id = dhw.element_type_id
			 AND SYSDATE BETWEEN hdw.effective_start_date and hdw.effective_end_date)
         ORDER BY dhw.date_worked DESC,
                  dhw.time_in DESC,
                  dhw.seqno DESC,
                  dhw.parent_id DESC;

      l_error_code   NUMBER         := 0;
      LOCATION       VARCHAR2 (120) := g_location || ':DDTL';
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location ('hxt_time_detail.delete_zero_hour_details',
                                  10
                                 );
      END IF;

         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;


      FOR zero_rec IN zero_hrs_cur (a_tim_id, a_date_worked,g_det_session_date)
      LOOP                    -- through detail rows and delete zero hour rows
         IF g_debug
         THEN
            hr_utility.set_location
                                 ('hxt_time_detail.delete_zero_hour_details',
                                  20
                                 );
         END IF;

         -- Bug 7359347
         -- Changing view to table.
         /*
         DELETE FROM hxt_det_hours_worked
               WHERE ROWID = zero_rec.hrw_rowid;
         */
         DELETE FROM hxt_det_hours_worked_f
               WHERE ROWID = zero_rec.hrw_rowid;

      END LOOP;

      FOR dup_flat_amt_rec IN duplicate_flat_dy_prems (a_tim_id,
                                                       a_osp_id,
                                                       a_date_worked
                                                      )
      LOOP
         -- through flat amount day prem records and delete duplicates
         -- for a day. Flat amount Day Premium should be paid only once a day.
         IF g_debug
         THEN
            hr_utility.set_location
                                 ('hxt_time_detail.delete_zero_hour_details',
                                  30
                                 );
         END IF;

         -- Bug 7359347
         -- Changing view to table.
         /*
         DELETE FROM hxt_det_hours_worked
               WHERE ROWID = dup_flat_amt_rec.dhw_rowid;
         */
         DELETE FROM hxt_det_hours_worked_f
               WHERE ROWID = dup_flat_amt_rec.dhw_rowid;

      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location ('hxt_time_detail.delete_zero_hour_details',
                                  40
                                 );
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39579_DELETE_DETAIL_ERR');
         l_error_code :=
            call_hxthxc_gen_error ('HXT',
                                   'HXT_39579_DELETE_DETAIL_ERR',
                                   NULL,
                                   LOCATION,
                                   '',
                                   SQLERRM
                                  );
   --2278400 l_error_code := call_gen_error(location, '', sqlerrm);
   END delete_zero_hour_details;

-- end delete_zero_hour_details;
   FUNCTION combine_contig_chunks
      RETURN NUMBER
   IS
/* This cursor brings back the distinct element_types, that exploded in the
   detail block ,for a summary record */
/*      CURSOR c_distinct_elements (a_parent_id NUMBER)
      IS
         SELECT DISTINCT element_type_id
                    FROM hxt_det_hours_worked hrw
                   WHERE hrw.parent_id = a_parent_id;
*/
      CURSOR c_distinct_elements (a_parent_id NUMBER,session_date DATE)
      IS
         SELECT DISTINCT element_type_id
                    FROM hxt_det_hours_worked_f hrw
                   WHERE hrw.parent_id = a_parent_id
                     AND session_date BETWEEN hrw.effective_start_date
                                                AND hrw.effective_end_date ;
/* This cursor brings back all the detail records for an element */
/*      CURSOR c_detail_chunks (a_parent_id NUMBER, a_element_type_id NUMBER)
      IS
         SELECT   hrw.ROWID hrw_rowid, hrw.time_in, hrw.time_out, hrw.hours,
                  hrw.amount, hrw.hourly_rate, hrw.rate_multiple,
                  hrw.prev_wage_code
             FROM hxt_det_hours_worked hrw
            WHERE hrw.parent_id = a_parent_id
              AND hrw.element_type_id = a_element_type_id
         ORDER BY time_in, time_out;
*/
    CURSOR c_detail_chunks (a_parent_id NUMBER, a_element_type_id NUMBER,session_date DATE)
      IS
         SELECT   hrw.ROWID hrw_rowid, hrw.time_in, hrw.time_out, hrw.hours,
                  hrw.amount, hrw.hourly_rate, hrw.rate_multiple,
                  hrw.prev_wage_code
             FROM hxt_det_hours_worked_f hrw
            WHERE hrw.parent_id = a_parent_id
              AND session_date BETWEEN hrw.effective_start_date
                                         AND hrw.effective_end_date
              AND hrw.element_type_id = a_element_type_id
         ORDER BY time_in, time_out;

      l_error_code         NUMBER                                     := 0;
      LOCATION             VARCHAR2 (120)             := g_location || ':DDTL';
      row_id               VARCHAR2 (50);   --hxt_det_hours_worked.rowid%TYPE;
      row_id1              VARCHAR2 (50);   --hxt_det_hours_worked.rowid%TYPE;
      ln_row_id            VARCHAR2 (50);   --hxt_det_hours_worked.rowid%TYPE;
      start_time           hxt_det_hours_worked.time_in%TYPE;
      end_time             hxt_det_hours_worked.time_out%TYPE;
      hours                hxt_det_hours_worked.hours%TYPE;
      ln_hours             hxt_det_hours_worked.hours%TYPE;
      ln_amount            hxt_det_hours_worked.amount%TYPE;
      ln_hourly_rate       hxt_det_hours_worked.hourly_rate%TYPE;
      ln_rate_multiple     hxt_det_hours_worked.rate_multiple%TYPE;
      lv_prev_wage_code    hxt_det_hours_worked.prev_wage_code%TYPE;
      start_time1          hxt_det_hours_worked.time_in%TYPE;
      end_time1            hxt_det_hours_worked.time_out%TYPE;
      hours1               hxt_det_hours_worked.hours%TYPE;
      ln_amount1           hxt_det_hours_worked.amount%TYPE;
      ln_hourly_rate1      hxt_det_hours_worked.hourly_rate%TYPE;
      ln_rate_multiple1    hxt_det_hours_worked.rate_multiple%TYPE;
      lv_prev_wage_code1   hxt_det_hours_worked.prev_wage_code%TYPE;
      ln_start_time        hxt_det_hours_worked.time_in%TYPE;
      ln_end_time          hxt_det_hours_worked.time_out%TYPE;
      ln_hours_worked      hxt_det_hours_worked.hours%TYPE;
      l_proc               VARCHAR2 (250);
   BEGIN
      IF g_debug
      THEN
         l_proc := 'hxt_time_detail.combine_contig_chunks';
         hr_utility.set_location (l_proc, 10);
         hr_utility.TRACE ('g_id:' || g_id);
      END IF;


         -- Bug 7359347
         -- Setting session date
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;


      FOR elem_rec IN c_distinct_elements (g_id,g_det_session_date)

      -- Loop through detail rows for each element and if contiguous times found
      -- then combine them into one.
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 20);
            hr_utility.TRACE (   'elem_rec.element_type_id :'
                              || elem_rec.element_type_id
                             );
         END IF;

         IF c_distinct_elements%NOTFOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 25);
            END IF;

            EXIT;
         END IF;

         OPEN c_detail_chunks (g_id, elem_rec.element_type_id,g_det_session_date);

         FETCH c_detail_chunks
          INTO row_id, start_time, end_time, hours, ln_amount, ln_hourly_rate,
               ln_rate_multiple, lv_prev_wage_code;

         IF g_debug
         THEN
            hr_utility.TRACE ('row_id :' || row_id);
            hr_utility.TRACE (   'start_time :'
                              || TO_CHAR (start_time,
                                          'DD-MON-YYYY HH24:MI:SS')
                             );
            hr_utility.TRACE (   'end_time   :'
                              || TO_CHAR (end_time, 'DD-MON-YYYY HH24:MI:SS')
                             );
            hr_utility.TRACE ('hours             :' || hours);
            hr_utility.TRACE ('ln_amount         :' || ln_amount);
            hr_utility.TRACE ('ln_hourly_rate    :' || ln_hourly_rate);
            hr_utility.TRACE ('ln_rate_multiple  :' || ln_rate_multiple);
            hr_utility.TRACE ('lv_prev_wage_code :' || lv_prev_wage_code);
         END IF;

         IF c_detail_chunks%FOUND
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 30);
            END IF;

            ln_row_id := row_id;
            ln_start_time := start_time;
            ln_end_time := end_time;
            ln_hours := hours;

            IF g_debug
            THEN
               hr_utility.TRACE ('ln_row_id     :' || ln_row_id);
               hr_utility.TRACE (   'ln_start_time :'
                                 || TO_CHAR (ln_start_time,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'ln_end_time   :'
                                 || TO_CHAR (ln_end_time,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('ln_hours      :' || ln_hours);
            END IF;
         END IF;

         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 35);
            END IF;

            FETCH c_detail_chunks
             INTO row_id1, start_time1, end_time1, hours1, ln_amount1,
                  ln_hourly_rate1, ln_rate_multiple1, lv_prev_wage_code1;

            IF g_debug
            THEN
               hr_utility.TRACE ('row_id1     :' || row_id1);
               hr_utility.TRACE (   'start_time1 :'
                                 || TO_CHAR (start_time1,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'end_time1   :'
                                 || TO_CHAR (end_time1,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('hours1             :' || hours1);
               hr_utility.TRACE ('ln_amount1         :' || ln_amount1);
               hr_utility.TRACE ('ln_hourly_rate1    :' || ln_hourly_rate1);
               hr_utility.TRACE ('ln_rate_multiple1  :' || ln_rate_multiple1);
               hr_utility.TRACE ('lv_prev_wage_code1 :' || lv_prev_wage_code1);
            END IF;

            IF c_detail_chunks%NOTFOUND
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 40);
               END IF;

               CLOSE c_detail_chunks;

               EXIT;
            END IF;

            IF g_debug
            THEN
               hr_utility.TRACE (   'ln_end_time :'
                                 || TO_CHAR (ln_end_time,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'start_time1 :'
                                 || TO_CHAR (start_time1,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('ln_hours :' || ln_hours);
               hr_utility.TRACE ('hours1   :' || hours1);
               hr_utility.TRACE ('ln_amount        :' || ln_amount);
               hr_utility.TRACE ('ln_hourly_rate   :' || ln_hourly_rate);
               hr_utility.TRACE ('ln_rate_multiple :' || ln_rate_multiple);
               hr_utility.TRACE ('lv_prev_wage_code:' || lv_prev_wage_code);
            END IF;

            IF ln_end_time IS NULL
            THEN
               -- implies that Time entered in HOURS and not IN/OUT time.
               -- Combine the hours rows  for the element.
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 45);
               END IF;

               -- Check if amount, hourly rate, rate multiple or prev wage code is
               -- the same for the segment chunks. If so then combine the chunks
               -- otherwise explode the chunk as it is.
               IF     NVL (ln_amount, -1) = NVL (ln_amount1, -1)
                  AND NVL (ln_hourly_rate, -1) = NVL (ln_hourly_rate1, -1)
                  AND NVL (ln_rate_multiple, -1) = NVL (ln_rate_multiple1, -1)
                  AND NVL (lv_prev_wage_code, -1) =
                                                   NVL (lv_prev_wage_code1,
                                                        -1)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 50);
                  END IF;

                  ln_hours := ln_hours + hours1;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('ln_hours :' || ln_hours);
                     hr_utility.TRACE ('row_id1     :' || row_id1);
                  END IF;

                  -- Bug 7359347
                  -- changing view to table.
                  /*
                  DELETE FROM hxt_det_hours_worked
                        WHERE ROWID = row_id1;

                  UPDATE hxt_det_hours_worked
                     SET hours = ln_hours
                   WHERE ROWID = ln_row_id;
                   */
                  DELETE FROM hxt_det_hours_worked_f
                        WHERE ROWID = row_id1;

                  UPDATE hxt_det_hours_worked_f
                     SET hours = ln_hours
                   WHERE ROWID = ln_row_id;

               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 55);
               END IF;
            ELSIF ln_end_time = start_time1
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 60);
               END IF;

               -- Check if amount, hourly rate, rate multiple or prev wage code is
               -- the same for the segment chunks. If so then combine the chunks
               -- otherwise explode the chunk as it is.
               IF     NVL (ln_amount, -1) = NVL (ln_amount1, -1)
                  AND NVL (ln_hourly_rate, -1) = NVL (ln_hourly_rate1, -1)
                  AND NVL (ln_rate_multiple, -1) = NVL (ln_rate_multiple1, -1)
                  AND NVL (lv_prev_wage_code, -1) =
                                                   NVL (lv_prev_wage_code1,
                                                        -1)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 65);
                  END IF;

                  ln_end_time := end_time1;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'ln_end_time :'
                                       || TO_CHAR (ln_end_time,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE ('row_id1     :' || row_id1);
                  END IF;

                  -- Bug 7359347
                  -- Changing view to table.
                  /*
                  DELETE FROM hxt_det_hours_worked
                        WHERE ROWID = row_id1;
                  */
                  DELETE FROM hxt_det_hours_worked_f
                        WHERE ROWID = row_id1;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 70);
                  END IF;

                  IF ln_amount1 IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 75);
                     END IF;

                     ln_hours_worked := 0;

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'ln_hours_worked :'
                                          || ln_hours_worked
                                         );
                     END IF;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 80);
                     END IF;

                     ln_hours_worked := ((ln_end_time - ln_start_time) * 24);

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'ln_hours_worked :'
                                          || ln_hours_worked
                                         );
                     END IF;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('ln_row_id   :' || ln_row_id);
                  END IF;

                  -- Bug 7359347
                  -- Changing view to table.
                  /*
                  UPDATE hxt_det_hours_worked
                     SET time_out = ln_end_time,
                         hours = ln_hours_worked
                   WHERE ROWID = ln_row_id;
                  */
                  UPDATE hxt_det_hours_worked_f
                     SET time_out = ln_end_time,
                         hours = ln_hours_worked
                   WHERE ROWID = ln_row_id;

               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 85);
                  END IF;

                  ln_start_time := start_time1;
                  ln_end_time := end_time1;
                  ln_hours := ((ln_end_time - ln_start_time) * 24);
                  ln_row_id := row_id1;
                  ln_amount := ln_amount1;
                  ln_hourly_rate := ln_hourly_rate1;
                  ln_rate_multiple := ln_rate_multiple1;
                  lv_prev_wage_code := lv_prev_wage_code1;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('ln_row_id        :' || ln_row_id);
                     hr_utility.TRACE (   'ln_start_time    :'
                                       || TO_CHAR (ln_start_time,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'ln_end_time      :'
                                       || TO_CHAR (ln_end_time,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE ('ln_hours         :' || ln_hours);
                     hr_utility.TRACE ('ln_amount        :' || ln_amount);
                     hr_utility.TRACE ('ln_hourly_rate   :' || ln_hourly_rate);
                     hr_utility.TRACE ('ln_rate_multiple :'
                                       || ln_rate_multiple
                                      );
                     hr_utility.TRACE (   'lv_prev_wage_code:'
                                       || lv_prev_wage_code
                                      );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 90);
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 95);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 100);
         END IF;
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 110);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 120);
         END IF;

         RETURN 0;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 130);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_XXXXX_COMBINE_HRS_ERR');
         l_error_code :=
            call_hxthxc_gen_error ('HXT',
                                   'HXT_XXXXX_COMBINE_HRS_ERR',
                                   NULL,
                                   LOCATION,
                                   '',
                                   SQLERRM
                                  );
   END combine_contig_chunks;

   FUNCTION pay (
      a_hours_to_pay           IN   NUMBER,
      a_pay_element_type_id    IN   NUMBER,
      a_time_in                IN   DATE,
      a_time_out               IN   DATE,
      a_date_worked            IN   DATE,
      a_id                     IN   NUMBER,
      a_assignment_id          IN   NUMBER,
      a_fcl_earn_reason_code   IN   VARCHAR2,
      a_ffv_cost_center_id     IN   NUMBER,
      a_ffv_labor_account_id   IN   NUMBER,
      a_tas_id                 IN   NUMBER,
      a_location_id            IN   NUMBER,
      a_sht_id                 IN   NUMBER,
      a_hrw_comment            IN   VARCHAR2,
      a_ffv_rate_code_id       IN   NUMBER,
      a_rate_multiple          IN   NUMBER,
      a_hourly_rate            IN   NUMBER,
      a_amount                 IN   NUMBER,
      a_fcl_tax_rule_code      IN   VARCHAR2,
      a_separate_check_flag    IN   VARCHAR2,
      a_project_id             IN   NUMBER,
      -- a_GROUP_ID IN NUMBER,
      a_earn_policy_id         IN   NUMBER,
      a_sdf_id                 IN   NUMBER DEFAULT NULL,
      a_state_name             IN   VARCHAR2 DEFAULT NULL,
      a_county_name            IN   VARCHAR2 DEFAULT NULL,
      a_city_name              IN   VARCHAR2 DEFAULT NULL,
      a_zip_code               IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
-- declare local variables
      l_work_plan           NUMBER;
      l_rotation_plan       NUMBER;
      l_retcode             NUMBER;
      l_hours               NUMBER;
      l_shift_hours         NUMBER;
      l_hdp_id              NUMBER;
      l_hol_id              NUMBER;
      l_sdp_id              NUMBER;
      l_ep_type             hxt_earning_policies.fcl_earn_type%TYPE;
      l_egt_id              NUMBER;
      l_pep_id              NUMBER;
      l_pip_id              NUMBER;
      l_hcl_id              NUMBER;
      l_hcl_elt_id          NUMBER;
      l_sdf_id              NUMBER;
      l_osp_id              NUMBER;
      l_standard_start      NUMBER;
      l_standard_stop       NUMBER;
      l_early_start         NUMBER;
      l_late_stop           NUMBER;
      l_min_tcard_intvl     NUMBER;
      l_round_up            NUMBER;
      l_hol_code            NUMBER;
      l_hol_yn              VARCHAR2 (1)                              := 'N';
      l_error               NUMBER;
      l_overtime_type       VARCHAR2 (4);                          --OVEREARN
      l_errmsg              VARCHAR2 (400);
      l_earn_id             NUMBER;
      error_in_gen_pol      EXCEPTION;                            -- OVEREARN
      error_in_policies     EXCEPTION;
      error_in_shift_info   EXCEPTION;
      error_in_check_hol    EXCEPTION;
      l_proc                VARCHAR2 (200);
      l_det_count           NUMBER;


      -- Bug 7388588
      -- Forced hints and modified the below query to get rid of the
      -- performance issue.
      /*
      CURSOR csr_test_for_osp (p_assignment_id NUMBER, p_date_worked DATE)
      IS
         SELECT hws.off_shift_prem_id
           FROM hxt_shifts hs,
                hxt_work_shifts hws,
                hxt_per_aei_ddf_v aeiv,
                hxt_rotation_schedules hrs
          WHERE aeiv.assignment_id = p_assignment_id
            AND p_date_worked BETWEEN aeiv.effective_start_date
                                  AND aeiv.effective_end_date
            AND hrs.rtp_id = aeiv.hxt_rotation_plan
            AND hrs.start_date =
                   (SELECT MAX (start_date)
                      FROM hxt_rotation_schedules
                     WHERE rtp_id = hrs.rtp_id AND start_date <= p_date_worked)
            AND hws.tws_id = hrs.tws_id
            AND hws.week_day = TO_CHAR (p_date_worked, 'DY')
            AND hws.sht_id = hs.ID;

      */

      CURSOR csr_test_for_osp (p_assignment_id NUMBER, p_date_worked DATE)
      IS
         SELECT /*+ ORDERED
                    INDEX(hrs hxt_rotation_schedules_pk)
                    USE_NL(aeiv hrs)
		    USE_NL(hrs hws) */
                hws.off_shift_prem_id
           FROM hxt_per_aei_ddf_v aeiv,
                hxt_rotation_schedules hrs,
                hxt_work_shifts hws,
                hxt_shifts hs
          WHERE aeiv.assignment_id = p_assignment_id
            AND p_date_worked BETWEEN aeiv.effective_start_date
                                  AND aeiv.effective_end_date
            AND hrs.rtp_id = aeiv.hxt_rotation_plan
            AND hrs.start_date <= p_date_worked
            AND hws.tws_id = hrs.tws_id
            AND hws.week_day = TO_CHAR (p_date_worked, 'DY')
            AND hws.sht_id = hs.ID
          ORDER BY hrs.start_date DESC;

   BEGIN
      IF g_debug
      THEN
         l_proc := 'hxt_time_detail.pay';
         hr_utility.set_location (l_proc, 10);
         hr_utility.TRACE (   'a_time_in :'
                           || TO_CHAR (a_time_in, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'a_time_out:'
                           || TO_CHAR (a_time_out, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE ('g_sdf_id :' || g_sdf_id);
      END IF;

      IF a_hours_to_pay = 0 and (a_amount is null or a_amount = 0) /* Bug: 5744162 */
      THEN
         SELECT count(*)
	 INTO   l_det_count
         FROM   hxt_det_hours_worked_f
	 WHERE  date_worked = a_date_worked
	 AND    assignment_id = a_assignment_id;

         IF l_det_count = 0 THEN
            RETURN 0;
	 END IF;
      END IF;

      IF g_id <> a_id
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 20);
         END IF;

-- We have backed up to a previous day to apply overtime due
-- to an absence at the end of the week so we need to get the
-- rules for the new day we are processing

         --    get policy information for the actual date worked

         -- Get policies assigned to person
         BEGIN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 30);
            END IF;

            hxt_util.get_policies (a_earn_policy_id,
                                   a_assignment_id,
                                   a_date_worked,
                                   l_work_plan,
                                   l_rotation_plan,
                                   l_earn_id,
                                   l_hdp_id,
                                   l_sdp_id,
                                   l_ep_type,
                                   l_egt_id,
                                   l_pep_id,
                                   l_pip_id,
                                   l_hcl_id,
                                   l_min_tcard_intvl,
                                   l_round_up,
                                   l_hcl_elt_id,
                                   l_error
                                  );

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 40);
               hr_utility.TRACE ('l_sdp_id:' || l_sdp_id);
               hr_utility.TRACE ('l_pep_id:' || l_pep_id);
            END IF;

            -- Check if error encountered
            IF l_error <> 0
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               RAISE error_in_policies;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 60);
            END IF;
         END;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 70);
         END IF;

         -- Check if person assigned work or rotation plan
         BEGIN
            IF (l_work_plan IS NOT NULL) OR (l_rotation_plan IS NOT NULL)
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 80);
               END IF;

               -- Get premiums for shift
               hxt_util.get_shift_info (a_date_worked,
                                        l_work_plan,
                                        l_rotation_plan,
                                        l_osp_id,
                                        l_sdf_id,
                                        l_standard_start,
                                        l_standard_stop,
                                        l_early_start,
                                        l_late_stop,
                                        l_shift_hours,
                                        l_error
                                       );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 90);
                  hr_utility.TRACE ('l_sdf_id :' || l_sdf_id);
                  hr_utility.TRACE ('l_osp_id :' || l_osp_id);
               END IF;

               -- Check if error encountered
               IF l_error <> 0
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 100);
                  END IF;

                  RAISE error_in_shift_info;
               END IF;

               -- IF shift override id i.e., l_sdf_id is NULL then
               -- set it to Shift diff ID -  from the shift differential policy
               IF l_sdf_id IS NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 105);
                  END IF;

                  l_sdf_id := a_sdf_id;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_sdf_id :' || l_sdf_id);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 110);
               END IF;
            END IF;                   -- person assigned work or rotation plan

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 120);
            END IF;
         END;

         -- Get holiday earning, day before/after, etc
         BEGIN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 130);
            END IF;

            hxt_util.check_for_holiday (a_date_worked,
                                        l_hcl_id,
                                        l_hol_id,
                                        l_hours,
                                        l_retcode
                                       );

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 135);
            END IF;

            -- Check if holiday
            IF l_retcode = 1
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 140);
               END IF;

               -- Set holiday code
               l_hol_yn := 'Y';
            END IF;                                          -- holiday or not

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 145);
            END IF;
         EXCEPTION
            -- Check for error
            WHEN OTHERS
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 150);
               END IF;

               l_errmsg := SQLCODE;
               RAISE error_in_check_hol;
         END;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 155);
         END IF;

         OPEN csr_test_for_osp (a_assignment_id, a_date_worked);

         FETCH csr_test_for_osp
          INTO l_osp_id;

         CLOSE csr_test_for_osp;

         -- Bug 8600894
         IF l_hol_yn = 'Y'
           AND fnd_profile.value('HXT_HOLIDAY_EXPLOSION') IN( 'NO','OO')
           AND g_reg_element.EXISTS(a_pay_element_type_id)
         THEN
           l_pep_id := NULL;
         END IF;

         IF g_debug
         THEN
            hr_utility.trace('About to pay ');
            hr_utility.trace('a_sdf_id '||a_sdf_id);
            hr_utility.trace('l_pep_id '||l_pep_id);
         END IF;



         RETURN hxt_time_pay.pay (a_earn_policy_id,                   --SIR337
                                  l_ep_type,
                                  l_egt_id,
                                  a_sdf_id,
                                  l_hdp_id,
                                  l_hol_id,
                                  l_pep_id,
                                  l_pip_id,
                                  NULL,                          --g_sdovr_id,
                                  l_osp_id,
                                  l_hol_yn,
                                  g_person_id,
                                  g_location,
                                  a_id,
                                  g_tim_id,
                                  a_date_worked,
                                  a_assignment_id,
                                  a_hours_to_pay,
                                  a_time_in,
                                  a_time_out,
                                  a_pay_element_type_id,
                                  a_fcl_earn_reason_code,
                                  a_ffv_cost_center_id,
                                  a_ffv_labor_account_id,
                                  a_tas_id,
                                  a_location_id,
                                  a_sht_id,
                                  a_hrw_comment,
                                  a_ffv_rate_code_id,
                                  a_rate_multiple,
                                  a_hourly_rate,
                                  a_amount,
                                  a_fcl_tax_rule_code,
                                  a_separate_check_flag,
                                  g_seqno,            -- not used for anything
                                  g_created_by,
                                  g_creation_date,
                                  g_last_updated_by,
                                  g_last_update_date,
                                  g_last_update_login,
                                  g_effective_start_date,
                                  g_effective_end_date,                -- C431
                                  a_project_id,
                                  g_pay_status,                    -- RETROPAY
                                  g_pa_status,                     -- PROJACCT
                                  g_retro_batch_id,                -- RETROPAY
                                  g_state_name       => a_state_name,
                                  g_county_name      => a_county_name,
                                  g_city_name        => a_city_name,
                                  g_zip_code         => a_zip_code
                                 -- a_GROUP_ID                    -- HXT11i1
                                 );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 160);
         END IF;
      ELSE
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 165);
            hr_utility.TRACE ('a_sdf_id :' || a_sdf_id);
         END IF;

         OPEN csr_test_for_osp (a_assignment_id, a_date_worked);

         FETCH csr_test_for_osp
          INTO g_osp_id;

         CLOSE csr_test_for_osp;

         -- Bug 8600894
         IF l_hol_yn = 'Y'
           AND fnd_profile.value('HXT_HOLIDAY_EXPLOSION') IN ('NO','OO')
           AND g_reg_element.EXISTS(a_pay_element_type_id)
         THEN
           l_pep_id := NULL;
         END IF;

         IF g_debug
         THEN
             hr_utility.trace('About to pay ');
             hr_utility.trace('a_sdf_id '||a_sdf_id);
             hr_utility.trace('l_pep_id '||l_pep_id);
         END IF;

         RETURN hxt_time_pay.pay (g_ep_id,
                                  g_ep_type,
                                  g_egt_id,
                                  g_sdf_id,
                                  g_hdp_id,
                                  g_hol_id,
                                  g_pep_id,
                                  g_pip_id,
                                  g_sdovr_id,
                                  g_osp_id,
                                  g_hol_yn,
                                  g_person_id,
                                  g_location,
                                  a_id,
                                  g_tim_id,
                                  a_date_worked,
                                  a_assignment_id,
                                  a_hours_to_pay,
                                  a_time_in,
                                  a_time_out,
                                  a_pay_element_type_id,
                                  a_fcl_earn_reason_code,
                                  a_ffv_cost_center_id,
                                  a_ffv_labor_account_id,
                                  a_tas_id,
                                  a_location_id,
                                  a_sht_id,
                                  a_hrw_comment,
                                  a_ffv_rate_code_id,
                                  a_rate_multiple,
                                  a_hourly_rate,
                                  a_amount,
                                  a_fcl_tax_rule_code,
                                  a_separate_check_flag,
                                  g_seqno,
                                  g_created_by,
                                  g_creation_date,
                                  g_last_updated_by,
                                  g_last_update_date,
                                  g_last_update_login,
                                  g_effective_start_date,
                                  g_effective_end_date,
                                  a_project_id,
                                  g_pay_status,
                                  g_pa_status,
                                  g_retro_batch_id,
                                  g_state_name       => a_state_name,
                                  g_county_name      => a_county_name,
                                  g_city_name        => a_city_name,
                                  g_zip_code         => a_zip_code
                                 -- a_GROUP_ID
                                 );

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 170);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 175);
      END IF;
   EXCEPTION
      --Begin OVEREARN
      WHEN error_in_gen_pol
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 180);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39440_GEN_EP_ERR');
         RETURN call_hxthxc_gen_error ('HXT',
                                       'HXT_39440_GEN_EP_ERR',
                                       NULL,
                                       g_location,
                                       '',
                                       SQLERRM
                                      );
          --2278400 RETURN call_gen_error(g_location, '', sqlerrm);
      --End OVEREARN
      WHEN error_in_policies
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 185);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39171_ERN_POL_OP_VIOL');
         RETURN call_hxthxc_gen_error ('HXT',
                                       'HXT_39171_ERN_POL_OP_VIOL',
                                       NULL,
                                       g_location,
                                       '',
                                       SQLERRM
                                      );
      --2278400 RETURN call_gen_error(g_location, '', sqlerrm);
      WHEN error_in_shift_info
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 190);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39172_SHF_PREMS_OP_VIOL');
         RETURN call_hxthxc_gen_error ('HXT',
                                       'HXT_39172_SHF_PREMS_OP_VIOL',
                                       NULL,
                                       g_location,
                                       '',
                                       SQLERRM
                                      );
      --2278400 RETURN call_gen_error(g_location, '', sqlerrm);
      WHEN error_in_check_hol
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 195);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39173_HOL_OP_VIOL');
         RETURN call_hxthxc_gen_error ('HXT',
                                       'HXT_39173_HOL_OP_VIOL',
                                       NULL,
                                       g_location,
                                       '',
                                       SQLERRM
                                      );
      --2278400 RETURN call_gen_error(g_location, '', sqlerrm);
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 200);
         END IF;

         fnd_message.set_name ('HXT', 'HXT_39269_ORACLE_ERROR');
         RETURN call_hxthxc_gen_error ('HXT',
                                       'HXT_39269_ORACLE_ERROR',
                                       NULL,
                                       g_location,
                                       '',
                                       SQLERRM
                                      );
   --2278400 RETURN call_gen_error(g_location, '', sqlerrm);
   END;

--------------------------------------------------------------------------------
--BEGIN HXT11i1
   FUNCTION contig_hours_worked (
      p_date_worked   IN   hxt_det_hours_worked_f.date_worked%TYPE,
      p_egt_id        IN   hxt_earn_groups.egt_id%TYPE,
      p_tim_id        IN   hxt_det_hours_worked_f.tim_id%TYPE
   )
      RETURN hxt_det_hours_worked.hours%TYPE
   IS
      /*  Local Variable Declaration */
      l_worked_hours   hxt_det_hours_worked.hours%TYPE   := 0;
      l_daily_hol_total  NUMBER;

      CURSOR daily_hol_total(session_date IN DATE)
                      IS
      select NVL(SUM(det.hours),0)
        from hxt_det_hours_worked_f det,
             hxt_sum_hours_worked_f sum,
             hxt_earning_rules er
       WHERE det.date_worked = g_date_worked
         AND sum.id = det.parent_id
         AND sum.element_type_id IS NULL
         AND det.tim_id = g_tim_id
         AND det.element_type_id = er.element_type_id
         AND er.egp_id = g_ep_id
         AND er.egr_type = 'HOL'
         AND session_date BETWEEN er.effective_start_date
                              AND er.effective_end_date
         AND session_date BETWEEN det.effective_start_date
                              AND det.effective_end_date
         AND session_date BETWEEN sum.effective_start_date
                              AND sum.effective_end_date;


      /*Cursor Declaration */
      CURSOR csr_work_hrs (
         p_date_worked   hxt_det_hours_worked_f.date_worked%TYPE,
         p_tim_id        hxt_det_hours_worked_f.tim_id%TYPE,
         session_date    DATE
      )
      IS
         SELECT hrw.hours, hrw.element_type_id, eltv.hxt_earning_category
           FROM hxt_det_hours_worked_f hrw,
                hxt_pay_element_types_f_ddf_v eltv,
                pay_element_types_f elt
          WHERE elt.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND session_date BETWEEN hrw.effective_start_date
                                 AND hrw.effective_end_date
            AND eltv.element_type_id = elt.element_type_id
            AND hrw.date_worked BETWEEN eltv.effective_start_date
                                    AND eltv.effective_end_date
            AND hrw.tim_id = p_tim_id
            AND hrw.date_worked = p_date_worked
            AND (   (    hrw.time_in IS NOT NULL
                     AND hrw.time_out IS NOT NULL
                     AND hrw.time_in <> hrw.time_out
                    )
                 OR (hrw.time_in IS NULL AND hrw.time_out IS NULL)
                )
	    AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */

      FUNCTION in_earnings_group (
         p_element_type_id   IN   hxt_earn_groups.element_type_id%TYPE,
         p_egt_id            IN   hxt_earn_groups.egt_id%TYPE
      )
         RETURN BOOLEAN
      AS
         CURSOR csr_in_earnings_group (
            p_element_type_id   hxt_earn_groups.element_type_id%TYPE,
            p_egt_id            hxt_earn_groups.egt_id%TYPE
         )
         IS
            SELECT 1
              FROM hxt_earn_group_types hegt, hxt_earn_groups heg
             WHERE hegt.ID = p_egt_id
               AND heg.egt_id = p_egt_id
               AND heg.element_type_id = p_element_type_id;

         l_found               csr_in_earnings_group%ROWTYPE;
         l_in_earnings_group   BOOLEAN                         := FALSE;
      BEGIN
         OPEN csr_in_earnings_group (p_element_type_id, p_egt_id);

         FETCH csr_in_earnings_group
          INTO l_found;

         IF (csr_in_earnings_group%FOUND)
         THEN
            l_in_earnings_group := TRUE;
         END IF;

         CLOSE csr_in_earnings_group;

         RETURN l_in_earnings_group;
      END in_earnings_group;
/* Main Function */
   BEGIN


         -- Bug 7359347
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;


      <<process_hrs>>
      FOR rec_work_hrs IN csr_work_hrs (p_date_worked, p_tim_id,g_det_session_date)
      LOOP
         IF (   (rec_work_hrs.hxt_earning_category IN ('REG', 'OVT'))
             OR (    (rec_work_hrs.hxt_earning_category = 'ABS')
                 AND (in_earnings_group (rec_work_hrs.element_type_id,
                                         p_egt_id
                                        )
                     )
                )
            )
         THEN
            l_worked_hours := l_worked_hours + rec_work_hrs.hours;

         END IF;
      END LOOP process_hrs;
      hr_utility.trace('Hol : l_daily_total for '||g_date_worked);
      hr_utility.trace('Hol : l_worked hours '||l_worked_hours);

        IF NVL(fnd_profile.value('HXT_HOLIDAY_EXPLOSION'),'EX') <> 'EX'
        THEN
            OPEN daily_hol_total(g_det_session_date);
            FETCH daily_hol_total INTO l_daily_hol_total;
            CLOSE daily_hol_total;

            l_worked_hours := l_worked_hours - l_daily_hol_total;
       hr_utility.trace('Hol : l_dailyhol_total '||l_daily_hol_total);
       hr_utility.trace('Hol : l_daily_total now '||l_worked_hours);
        END IF;





      RETURN l_worked_hours;
   END contig_hours_worked;



   -- Bug 7143238
   -- Created this function mocking the above function, but
   -- will pick up only those hours which are not override entries
   -- entered by the user.

   FUNCTION contig_hours_worked2 (
      p_date_worked   IN   hxt_det_hours_worked_f.date_worked%TYPE,
      p_egt_id        IN   hxt_earn_groups.egt_id%TYPE,
      p_tim_id        IN   hxt_det_hours_worked_f.tim_id%TYPE
   )
      RETURN hxt_det_hours_worked.hours%TYPE
   IS
      /*  Local Variable Declaration */
      l_worked_hours   hxt_det_hours_worked.hours%TYPE   := 0;

      /*Cursor Declaration */

      -- Pick up all hours worked which are not override hours
      --
      CURSOR csr_work_hrs (
         p_date_worked   hxt_det_hours_worked_f.date_worked%TYPE,
         p_tim_id        hxt_det_hours_worked_f.tim_id%TYPE,
         session_date    DATE
      )
      IS
         SELECT SUM(hrw.hours)
           FROM hxt_det_hours_worked_f hrw,
                hxt_pay_element_types_f_ddf_v eltv,
                pay_element_types_f elt,
                hxt_sum_hours_worked_f sum
          WHERE elt.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND session_date BETWEEN hrw.effective_start_date
                                 AND hrw.effective_end_date
            AND eltv.element_type_id = elt.element_type_id
            AND sum.id = hrw.parent_id
            AND session_date BETWEEN sum.effective_start_date
                                 AND sum.effective_end_date
            AND hrw.date_worked BETWEEN eltv.effective_start_date
                                    AND eltv.effective_end_date
            AND sum.element_type_id IS NULL
            AND hrw.tim_id = p_tim_id
            -- Bug 8757974
            AND (   hrw.parent_id = g_id
                  OR ( EXISTS ( SELECT 1
                                  FROM hxt_earn_groups eg
                                 WHERE eg.element_type_id = hrw.element_type_id
                                   AND eg.egt_id          = p_egt_id)
                      )
                 )
            AND eltv.hxt_earning_category IN ('REG','OVT')
            AND hrw.date_worked = p_date_worked
            AND (   (    hrw.time_in IS NOT NULL
                     AND hrw.time_out IS NOT NULL
                     AND hrw.time_in <> hrw.time_out
                    )
                 OR (hrw.time_in IS NULL AND hrw.time_out IS NULL)
                );

   BEGIN
         -- Setting session date.
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;

        OPEN csr_work_hrs(p_date_worked, p_tim_id,g_det_session_date);
        FETCH csr_work_hrs INTO l_worked_hours;
        CLOSE csr_work_hrs;
      RETURN l_worked_hours;
   END contig_hours_worked2;




--
-------------------------------------------------------------------------------
--
   PROCEDURE overtime_hoursoverride (
      p_date_worked        IN              hxt_det_hours_worked_f.date_worked%TYPE,
      p_egt_id             IN              hxt_earn_groups.egt_id%TYPE,
      p_tim_id             IN              hxt_det_hours_worked_f.tim_id%TYPE,
      p_override_hrs       OUT NOCOPY      hxt_det_hours_worked_f.hours%TYPE,
      p_override_element   OUT NOCOPY      hxt_det_hours_worked_f.element_type_id%TYPE
   )
   -- RETURN hxt_det_hours_worked.hours%TYPE
   IS
      /*  Local Variable Declaration */
      l_worked_hours      hxt_det_hours_worked.hours%TYPE             := 0;
      l_element_type_id   hxt_det_hours_worked.element_type_id%TYPE;

      /*Cursor Declaration */
      -- Bug 7359347
               -- Changed the below cursor to pick up session date from global variable
               -- instead of fnd_sessions table.
      /*
      CURSOR csr_override_hrs (
         p_date_worked   hxt_det_hours_worked_f.date_worked%TYPE,
         p_tim_id        hxt_det_hours_worked_f.tim_id%TYPE
      )
      IS
         SELECT hrw.hours, hrw.element_type_id, eltv.hxt_earning_category
           FROM hxt_sum_hours_worked hrw,
                hxt_pay_element_types_f_ddf_v eltv,
                pay_element_types_f elt
          WHERE elt.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND eltv.element_type_id = elt.element_type_id
            AND hrw.date_worked BETWEEN eltv.effective_start_date
                                    AND eltv.effective_end_date
            AND hrw.tim_id = p_tim_id
            AND hrw.date_worked = p_date_worked
            AND (   (    hrw.time_in IS NOT NULL
                     AND hrw.time_out IS NOT NULL
                     AND hrw.time_in <> hrw.time_out
                    )
                 OR (hrw.time_in IS NULL AND hrw.time_out IS NULL)
                )
            -- Following condition to get total for override hrs only
            AND hrw.element_type_id IS NOT NULL
	    AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */


      CURSOR csr_override_hrs (
         p_date_worked   hxt_det_hours_worked_f.date_worked%TYPE,
         p_tim_id        hxt_det_hours_worked_f.tim_id%TYPE,
         p_session_date  DATE
      )
      IS
         SELECT hrw.hours, hrw.element_type_id, eltv.hxt_earning_category
           FROM hxt_sum_hours_worked_f hrw,
                hxt_pay_element_types_f_ddf_v eltv,
                pay_element_types_f elt
          WHERE elt.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND p_session_date BETWEEN  hrw.effective_start_date
                                   AND hrw.effective_end_date
            AND eltv.element_type_id = elt.element_type_id
            AND hrw.date_worked BETWEEN eltv.effective_start_date
                                    AND eltv.effective_end_date
            AND hrw.tim_id = p_tim_id
            AND hrw.date_worked = p_date_worked
            AND (   (    hrw.time_in IS NOT NULL
                     AND hrw.time_out IS NOT NULL
                     AND hrw.time_in <> hrw.time_out
                    )
                 OR (hrw.time_in IS NULL AND hrw.time_out IS NULL)
                )
            -- Following condition to get total for override hrs only
            AND hrw.element_type_id IS NOT NULL
	    AND nvl(eltv.exclude_from_explosion, 'N') <> 'Y'; /* Bug: 4489952 */

      l_proc              VARCHAR2 (500);
   /* Main Function */
   BEGIN
      IF g_debug
      THEN
         l_proc := 'hxt_time_detail.Overtime_Hoursoverride';
         hr_utility.set_location (l_proc, 10);
      END IF;

         -- Bug 7359347
         -- Setting session date
         IF g_det_session_date IS NULL
         THEN
            g_det_session_date := hxt_tim_col_util.return_session_date;
   	 END IF;



      <<process_hrs>>
      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 20);
      END IF;

      FOR rec_work_hrs IN csr_override_hrs (p_date_worked, p_tim_id,g_det_session_date)
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 30);
            hr_utility.TRACE (   'rec_work_hrs.hxt_earning_category:'
                              || rec_work_hrs.hxt_earning_category
                             );
            hr_utility.TRACE ('rec_work_hrs.hours:' || rec_work_hrs.hours);
            hr_utility.TRACE (   'rec_work_hrs.element_type_id:'
                              || rec_work_hrs.element_type_id
                             );
         END IF;

         IF rec_work_hrs.hxt_earning_category = 'OVT'
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 40);
            END IF;

            l_worked_hours := l_worked_hours + rec_work_hrs.hours;
            l_element_type_id := rec_work_hrs.element_type_id;

            IF g_debug
            THEN
               hr_utility.TRACE ('l_worked_hours:' || l_worked_hours);
               hr_utility.TRACE ('l_element_type_id:' || l_element_type_id);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 50);
         END IF;
      END LOOP process_hrs;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 60);
      END IF;

      -- RETURN NVL (l_worked_hours, 0);
      p_override_hrs := l_worked_hours;
      p_override_element := l_element_type_id;

      IF g_debug
      THEN
         hr_utility.TRACE ('p_override_hrs:' || p_override_hrs);
         hr_utility.TRACE ('p_override_element:' || p_override_element);
      END IF;
   END overtime_hoursoverride;
--
-------------------------------------------------------------------------------
--
END;                                                               --  package

/
