--------------------------------------------------------
--  DDL for Package HXT_TIME_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIME_COLLECTION" AUTHID CURRENT_USER AS
/* $Header: hxttcol.pkh 120.4 2005/11/23 09:09:47 sgadipal noship $ */
/*#
 * This package contains record time API
 * @rep:scope public
 * @rep:product hxt
 * @rep:displayname Record Time
*/
   /*----------------------------------------------
    || Global variables, constants, cursors  and exceptions
    ----------------------------------------------*/
   g_user_id                        fnd_user.user_id%TYPE
                                                        := fnd_global.user_id;
   g_login_id                       fnd_user.user_id%TYPE
                                                       := fnd_global.login_id;
   g_user_name                      fnd_user.user_name%TYPE
                                                           := 'TimeCollection';
   g_sysdate                        DATE                      := TRUNC (
                                                                    SYSDATE
                                                                 );
   g_sysdatetime                    DATE                              := SYSDATE;
   g_sess_date                      DATE;
   g_bus_group_id                   hr_organization_units.business_group_id%TYPE
                               := fnd_profile.VALUE ('PER_BUSINESS_GROUP_ID');
   g_batch_err_id                   hxt_errors.ppb_id%TYPE          DEFAULT NULL;
   g_timecard_err_id                hxt_errors.tim_id%TYPE          DEFAULT NULL;
   g_hours_worked_err_id            hxt_errors.hrw_id%TYPE          DEFAULT NULL;
   g_time_period_err_id             hxt_errors.ptp_id%TYPE          DEFAULT NULL;
   g_batch_ref                      pay_batch_headers.batch_reference%TYPE
                                                                 DEFAULT NULL;
   g_batch_name                     pay_batch_headers.batch_name%TYPE
                                                                 DEFAULT NULL;
   g_orcl_tm_app_id_cons   CONSTANT hr_lookups.application_id%TYPE                 := 808;
   g_orcl_hr_app_id_cons   CONSTANT hr_lookups.application_id%TYPE                 := 800;

   CURSOR g_employee_cur (c_person_id NUMBER, c_date_worked DATE)
   IS
      SELECT asm.payroll_id, asm.assignment_id, asm.effective_start_date,
             asm.effective_end_date, asmv.hxt_rotation_plan, egp.hcl_id
        FROM hxt_earning_policies egp,
             hxt_per_aei_ddf_v asmv,
             per_assignment_status_types ast,
             per_all_assignments_f asm
       WHERE c_person_id = asm.person_id
         AND asm.primary_flag = 'Y'
         AND TRUNC (c_date_worked) BETWEEN TRUNC (asm.effective_start_date)
                                       AND TRUNC (asm.effective_end_date)
         AND ast.assignment_status_type_id = asm.assignment_status_type_id
         AND ast.pay_system_status = 'P' -- Check payroll status
         AND asmv.assignment_id = asm.assignment_id
         AND TRUNC (c_date_worked) BETWEEN TRUNC (asmv.effective_start_date)
                                       AND TRUNC (asmv.effective_end_date)
         AND egp.id(+) = asmv.hxt_earning_policy;


-- RM Why not use assignment id here (above) too?

   CURSOR g_details_cur (c_assignment_id NUMBER, c_date_worked DATE)
   IS
      SELECT asmv.hxt_earning_policy, asmv.hxt_shift_differential_policy,
             asmv.hxt_hour_deduction_policy, wsh.off_shift_prem_id,
             wsh.shift_diff_ovrrd_id
        FROM hxt_per_aei_ddf_v asmv,
             per_assignment_status_types ast,
             per_assignments_f asm,
             hxt_shifts sht,
             hxt_weekly_work_schedules wws,
             hxt_work_shifts wsh,
             hxt_rotation_schedules rts
       WHERE c_assignment_id = asm.assignment_id
         AND TRUNC (c_date_worked) BETWEEN TRUNC (asm.effective_start_date)
                                       AND TRUNC (asm.effective_end_date)
         AND ast.assignment_status_type_id = asm.assignment_status_type_id
         AND ast.pay_system_status = 'P' -- Check payroll status
         AND asmv.assignment_id = asm.assignment_id
         AND TRUNC (c_date_worked) BETWEEN TRUNC (asmv.effective_start_date)
                                       AND TRUNC (asmv.effective_end_date)
         AND asmv.hxt_rotation_plan = rts.rtp_id -- SIR 336
         --  AND c_date_worked  >=  rts.start_date
         AND wsh.week_day = hxt_util.get_week_day (c_date_worked)
         AND wws.id = wsh.tws_id
         AND c_date_worked BETWEEN wws.date_from
                               AND NVL (wws.date_to, c_date_worked)
         AND wws.id = rts.tws_id
         AND sht.id = wsh.sht_id
         AND rts.start_date = (SELECT MAX (start_date)
                                 FROM hxt_rotation_schedules
                                WHERE rtp_id = asmv.hxt_rotation_plan
                                  AND start_date <= c_date_worked);

   CURSOR g_earn_pol_details_cur (c_earn_pol_id NUMBER, c_date_worked DATE)
   IS
      SELECT fcl_earn_type, egt_id, pep_id, pip_id, hcl_id
        FROM hxt_earning_policies
       WHERE id = c_earn_pol_id
         AND c_date_worked BETWEEN effective_start_date
                               AND effective_end_date;

   CURSOR g_hol_cur (c_start_date DATE, c_end_date DATE, c_hcl_id NUMBER)
   IS
      SELECT hcl.element_type_id, hdy.hours, hdy.holiday_date
        FROM hxt_holiday_calendars hcl, hxt_holiday_days hdy
       WHERE TRUNC (hdy.holiday_date, 'DD') BETWEEN TRUNC (c_start_date, 'DD')
                                                AND TRUNC (c_end_date, 'DD')
         AND hcl.id = hdy.hcl_id
         AND hdy.holiday_date BETWEEN hcl.effective_start_date
                                  AND hcl.effective_end_date
         AND hcl.id = c_hcl_id;

   /* -------------------
    || Error variables
    --------------------*/
   e_timecard_source                VARCHAR2 (80);
   e_approver_number                VARCHAR2 (30);
   e_employee_number                VARCHAR2 (30);
   e_date_worked                    VARCHAR2 (30);
   e_start_time                     DATE;
   e_end_time                       DATE;
   e_hours                          NUMBER (7, 3);
   e_work_type                      VARCHAR2 (30);
   e_hours_type                     VARCHAR2 (80);
   e_earn_reason_code               VARCHAR2 (30);
   e_project                        VARCHAR2 (25);
   e_task_number                    VARCHAR2 (30);
   e_location_code                  VARCHAR2 (20);
   e_comment                        VARCHAR2 (255);
   e_rate_multiple                  NUMBER (15, 5);
   e_hourly_rate                    NUMBER (15, 5);
   e_amount                         NUMBER (15, 5);
   e_separate_check_flag            VARCHAR2 (30);
   e_business_group_id              NUMBER (15);
   e_concat_cost_segments           VARCHAR2 (240);
   e_cost_segment1                  VARCHAR2 (60);
   e_cost_segment2                  VARCHAR2 (60);
   e_cost_segment3                  VARCHAR2 (60);
   e_cost_segment4                  VARCHAR2 (60);
   e_cost_segment5                  VARCHAR2 (60);
   e_cost_segment6                  VARCHAR2 (60);
   e_cost_segment7                  VARCHAR2 (60);
   e_cost_segment8                  VARCHAR2 (60);
   e_cost_segment9                  VARCHAR2 (60);
   e_cost_segment10                 VARCHAR2 (60);
   e_cost_segment11                 VARCHAR2 (60);
   e_cost_segment12                 VARCHAR2 (60);
   e_cost_segment13                 VARCHAR2 (60);
   e_cost_segment14                 VARCHAR2 (60);
   e_cost_segment15                 VARCHAR2 (60);
   e_cost_segment16                 VARCHAR2 (60);
   e_cost_segment17                 VARCHAR2 (60);
   e_cost_segment18                 VARCHAR2 (60);
   e_cost_segment19                 VARCHAR2 (60);
   e_cost_segment20                 VARCHAR2 (60);
   e_cost_segment21                 VARCHAR2 (60);
   e_cost_segment22                 VARCHAR2 (60);
   e_cost_segment23                 VARCHAR2 (60);
   e_cost_segment24                 VARCHAR2 (60);
   e_cost_segment25                 VARCHAR2 (60);
   e_cost_segment26                 VARCHAR2 (60);
   e_cost_segment27                 VARCHAR2 (60);
   e_cost_segment28                 VARCHAR2 (60);
   e_cost_segment29                 VARCHAR2 (60);
   e_cost_segment30                 VARCHAR2 (60);
   e_STATE_NAME                     hxt_sum_hours_worked_f.state_name%type;
   e_COUNTY_NAME                    hxt_sum_hours_worked_f.county_name%type;
   e_CITY_NAME                      hxt_sum_hours_worked_f.city_name%type;
   e_ZIP_CODE                       hxt_sum_hours_worked_f.zip_code%type;
   /*------------------------------
   || Base Anchored Declarations
   ------------------------------*/
   project_id                       hxt_projects_v.project_id%TYPE;
   earn_pol_id                      hxt_earning_policies.id%TYPE;


/*------------------------------------
 || Public Module Declarations
 ------------------------------------*/
   FUNCTION CACHE
      RETURN BOOLEAN;

   PROCEDURE set_cache (p_cache IN BOOLEAN);


--
-- ----------------------------------------------------------------------------
-- |-------------------------------< record_time >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API provides a means for importing time entry data into the OTM
 * system.
 *
 * It will create a new OTM Timecard for a given employee/time
 * period if one does not already exist, or else adds time to an employee's
 * existing OTM Timecard (only if the Timecard was not automatically
 * generated).  The API is intended to log blocks of time worked by an
 * employee and should be called repetitively to log separate blocks of
 * time.  For example, if this API were being interfaced with a mechanical
 * time clock, it would be called on each employee's PUNCH-OUT activity
 * with both the PUNCH-IN and PUNCH-OUT times being passed as parameters.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * <P>employee_number must identify a unique (considering date effectivity)
 * person in the PER_PEOPLE_F table.
 * <P>assignment_id is currently NOT USED. Value passed may be NULL.
 * Assignment to be used for employee will be the first applicable
 * assignment to be queried from the PER_ASSIGNMENTS_F table.
 * <P>start_time will be used as the date worked for the block of time
 * being logged.  No consideration will be given to the possibility
 * that a block of time worked may span into another day.
 * <P>If adding time data to an already existing OTM Timecard, the
 * Timecard must NOT have been generated automatically by OTM (ie,
 * HXT_TIMECARDS.AUTO_GEN_FLAG must NOT equal 'A').
 * <P>The system profile, HXT_BATCH_SIZE, defines the number of OTM
 * Timecards that will be created with like BATCH_ID.  If no BATCH_ID
 * is found with fewer than HXT_BATCH_SIZE Timecards, a new BATCH_ID
 * will be created.
 *
 * <p><b>Post Success</b><br>
 * If an OTM Timecard did not previously exist for the given employee
 * during the time period covering the start time provided, one is created.
 * Otherwise, the time data is added to the appropriate existing OTM
 * Timecard, provided that Timecard was not automatically generated. The
 * OUT parameters created_tim_sum_id, otm_error, oracle_error will be set.
 *
 * <p><b>Post Failure</b><br>
 * An OTM Timecard may or may not be created or updated depending on the
 * failure circumstance.  Errors will be logged in the table
 * hxt_timeclock_errors and will be viewable on the OTM Timecard Errors
 * form regardless of whether the Timecard was created or previously
 * existed. The OUT parameters otm_error, oracle_error will be set to indicate the
 * cause of the failure.
 *
 * @param timecard_source Identifies the source of time: Autogen,
 * Autogen (changed), Manual, Time Clock, Manual (changed).
 * @param batch_ref Batch Reference used in creating
 * the batch.  If null, default name and reference generation are used.
 * @param batch_name Batch Name used in creating the batch.  If null,
 * default name and reference generation are used.
 * @param approver_number Identifies the approver, if there
 * is one, for this time information.
 * @param employee_number Identifies the employee for whom
 * time data is being logged. Verified via query of PER_PEOPLE_F table.
 * @param date_worked The day for the time information.
 * If null, date_worked is taken from start_time.  If date_worked,
 * start_time and end_time are all NULL, an exception is raised.
 * @param start_time Identifies the start date and time
 * for the time data being logged. This value will become the date worked
 * for the time data being logged.
 * @param end_time Identifies the stop date and time
 * for the time data being logged. Either date_worked is specified OR
 * start_time and end_time are specified.  start_time and end_time
 * are either both null or both not null
 * @param hours The number of hours worked.  If null,
 * it is calulated from start_time and end_time.
 * @param wage_code Wage code for employee.
 * @param earning_policy Earning Policy of employee.  If null,
 * it is derived from employee's assignment information.
 * @param hours_type The element which will be used in
 * payroll; if null, derived from earning policy.
 * @param earn_reason_code Earning reason code.
 * @param project Project for this time information.
 * @param task_number Task (should be related to specified project).  If
 * task is specified, project has to be specified.
 * @param location_code  Location.
 * @param comment Comments.
 * @param rate_multiple Rate multiple.
 * @param hourly_rate Hourly rate.
 * @param amount  Amount.
 * @param separate_check_flag Separate Check (Y/N) - if the element
 * allows for payment on separate check (i.e. the element has a separate
 * check input value).
 * @param business_group_id This is actually required, although
 * the API defaults it to null.  It is used to derive the person_id
 * from the specified employee_number, and it is required for that.
 * @param concat_cost_segments Costing information.
 * @param cost_segment1 Costing information.
 * @param cost_segment2 Costing information.
 * @param cost_segment3 Costing information.
 * @param cost_segment4 Costing information.
 * @param cost_segment5 Costing information.
 * @param cost_segment6 Costing information.
 * @param cost_segment7 Costing information.
 * @param cost_segment8 Costing information.
 * @param cost_segment9 Costing information.
 * @param cost_segment10 Costing information.
 * @param cost_segment11 Costing information.
 * @param cost_segment12 Costing information.
 * @param cost_segment13 Costing information.
 * @param cost_segment14 Costing information.
 * @param cost_segment15 Costing information.
 * @param cost_segment16 Costing information.
 * @param cost_segment17 Costing information.
 * @param cost_segment18 Costing information.
 * @param cost_segment19 Costing information.
 * @param cost_segment20 Costing information.
 * @param cost_segment21 Costing information.
 * @param cost_segment22 Costing information.
 * @param cost_segment23 Costing information.
 * @param cost_segment24 Costing information.
 * @param cost_segment25 Costing information.
 * @param cost_segment26 Costing information.
 * @param cost_segment27 Costing information.
 * @param cost_segment28 Costing information.
 * @param cost_segment29 Costing information.
 * @param cost_segment30 Costing information.
 * @param time_summary_id Time summary ID of existing time
 * information - used for updating.
 * @param tim_sum_eff_start_date Start date.
 * @param tim_sum_eff_end_date End date.
 * @param created_by Used for populating WHO column. Can
 * be anything, no validation is done.
 * @param last_updated_by Used for populating WHO column. Can
 * be anything, no validation is done.
 * @param last_update_login Used for populating WHO column. Can
 * be anything, no validation is done.
 * @param writesum_yn Y/N.  Insert the time summary
 * information - default is 'Y'.
 * @param explode_yn Y/N.  Explode the time information.
 * into details - default is 'Y'.
 * @param delete_yn Y/N.  If 'Y', if time_summary_id is
 * not null, delete the associated time summary information - default is 'N'.
 * @param dt_update_mode Date Track update Mode - CORRECTION
 * or UPDATE.  If time_summary_id is specified, this parameter CANNOT
 * be NULL.  Used for updating existing time information.
 * @param created_tim_sum_id Created time summary ID.
 * @param otm_error OTM error, if any.
 * @param oracle_error Oracle error, if any.
 * @param p_time_building_block_id Time building block id
 * @param p_time_building_block_ovn Time building block OVN
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_state_name State name
 * @param p_county_name County name
 * @param p_city_name City name
 * @param p_zip_code Zip code
 * @rep:displayname Record Time
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD
 * @rep:lifecycle active
 * @rep:scope public
 */
--
-- {End Of Comments}
--
--
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
      delete_yn                   IN              VARCHAR2 DEFAULT 'N', -- AM 001
      dt_update_mode              IN              VARCHAR2 DEFAULT NULL, --SIR290, SIR293
      created_tim_sum_id          OUT NOCOPY      NUMBER,
      otm_error                   OUT NOCOPY      VARCHAR2,
      oracle_error                OUT NOCOPY      VARCHAR2,
      p_time_building_block_id    IN              NUMBER DEFAULT NULL,
      p_time_building_block_ovn   IN              NUMBER DEFAULT NULL,
      p_validate                  IN              BOOLEAN DEFAULT FALSE,
      p_STATE_NAME                IN              VARCHAR2 DEFAULT NULL,
      p_COUNTY_NAME               IN              VARCHAR2 DEFAULT NULL,
      p_CITY_NAME                 IN              VARCHAR2 DEFAULT NULL,
      p_ZIP_CODE                  IN              VARCHAR2 DEFAULT NULL
   );

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
   );

   PROCEDURE re_explode_timecard (
      timecard_id          IN              NUMBER,
      tim_eff_start_date   IN              DATE,
      tim_eff_end_date     IN              DATE,
      dt_update_mode       IN              VARCHAR2,
      otm_error            OUT NOCOPY      VARCHAR2,
      oracle_error         OUT NOCOPY      VARCHAR2
   );


--  p_mode IN VARCHAR2 default 'INSERT');

   PROCEDURE delete_details (
      p_tim_id                 IN              NUMBER,
      p_dt_update_mode         IN              VARCHAR2,
      p_effective_start_date   IN              DATE,
      o_error_message          OUT NOCOPY      NUMBER
   );

      PROCEDURE adjust_timings (
      p_timecard_source IN              VARCHAR2,
      p_assignment_id   IN              NUMBER,
      p_person_id       IN              NUMBER,
      p_date_worked     IN              DATE,
      p_tim_id          IN              NUMBER,
      p_hours_id        IN              NUMBER,
      p_earn_pol_id     IN              NUMBER,
      p_time_in         IN OUT NOCOPY   DATE,
      p_time_out        IN OUT NOCOPY   DATE,
      p_hours           IN OUT NOCOPY   NUMBER,
      p_code               OUT NOCOPY   NUMBER,
      p_error              OUT NOCOPY   VARCHAR2,
      p_org_in          IN              DATE DEFAULT NULL,
      p_org_out         IN              DATE DEFAULT NULL,
      p_actual_time_in  IN OUT NOCOPY   DATE,
      p_actual_time_out IN OUT NOCOPY   DATE
   );

END hxt_time_collection;

 

/
