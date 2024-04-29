--------------------------------------------------------
--  DDL for Package HXT_BATCH_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_BATCH_VAL" AUTHID CURRENT_USER AS
/* $Header: hxtbtval.pkh 120.3.12010000.3 2009/06/17 08:19:54 asrajago ship $ */
   c_39315_max_hrs_exceeded       CONSTANT fnd_lookup_values.lookup_code%TYPE
            := '24_HOUR_EDIT';
   c_39260_abs_not_asg_to_acrl    CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'ABS_NOT_ASG_TO_ACRL';
   c_39509_accrual_exceeded       CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'ACCRUAL_EXCEEDED';
   c_39332_day_on_hol_cal         CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'DAY_IS_HOLIDAY';
   c_39333_hol_not_valid_on_cal   CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'HOLIDAY_NOT_VAL';
   c_39334_hrs_chged_ne_cal_hrs   CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'HOURS_NOT_EQUAL';
   c_39338_ins_error_occ          CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'INSERT_ERRORS';
   c_39316_person_nf              CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'PERSON_NOT_IN_DB';
   c_39335_exceeded_accrued_hrs   CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'PTO_CHG_ACCRUED';
   c_39336_errs_in_batch          CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'TIMECARD_ERRORS';
   c_39317_empl_inactive          CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'TIMECARD_INACTIVE';
   c_39337_timecard_not_apprved   CONSTANT fnd_lookup_values.lookup_code%TYPE
            := 'TIMECARD_NOT_APPROVED';


   -- Bug 8584436
   -- Added the following data structures to hold token values and error messages
   -- Values once obtained for the tokens are saved in the Assoc Arrays, so there is
   -- no repeated querying on the tables.

   TYPE ERRORREC IS RECORD
   ( errmsg   VARCHAR2(1000),
     errtype  VARCHAR2(20));

   TYPE ERRORTAB          IS TABLE OF ERRORREC      INDEX BY VARCHAR2(50);

   g_errtab  ERRORTAB;


   TYPE VARCHARASSOCARRAY IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;

   g_name_tab         VARCHARASSOCARRAY;
   g_accrual_plan     VARCHARASSOCARRAY;
   g_holiday_calendar VARCHARASSOCARRAY;
   g_period_end_date  VARCHARASSOCARRAY;
   g_assig_tab        VARCHARASSOCARRAY;


   FUNCTION error_level
      RETURN NUMBER;

   PROCEDURE set_error_level (p_valid IN VARCHAR, p_msg_level IN VARCHAR2);

   PROCEDURE reset_error_level;

   PROCEDURE delete_prev_val_errors (p_tim_id IN hxt_timecards_f.id%TYPE);

   FUNCTION errors_exist (p_tim_id IN hxt_timecards.id%TYPE)
      RETURN BOOLEAN;

   FUNCTION timecard_end_date (p_tim_id IN hxt_timecards_f.id%TYPE)
      RETURN per_time_periods.end_date%TYPE;

   FUNCTION person_effective_at_tc_end (
      p_person_id   IN   per_people_f.person_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   )
      RETURN BOOLEAN;

   PROCEDURE record_error (
      p_batch_id     IN   NUMBER,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_error_code   IN   VARCHAR2
   );

   PROCEDURE person_validation (
      p_batch_id    IN   NUMBER,
      p_person_id   IN   hxt_timecards.for_person_id%TYPE,
      p_period_id   IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   );

   PROCEDURE excess_pto (
      p_batch_id    IN   NUMBER,
      p_calculation_date IN hxt_sum_hours_worked_x.date_worked%TYPE,
      p_person_id   IN   hxt_timecards.for_person_id%TYPE,
      p_period_id   IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   );

   FUNCTION primary_assignment_id (
      p_person_id        IN   per_people_f.person_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN per_all_assignments_f.assignment_id%TYPE;

   FUNCTION holiday_calendar_id (
      p_person_id        IN   per_people_f.person_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN hxt_holiday_calendars.id%TYPE;

   FUNCTION holiday_calendar_id (
      p_assignment_id    IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN hxt_holiday_calendars.id%TYPE;

   FUNCTION holiday_element_id (p_hol_cal_id IN hxt_holiday_calendars.id%TYPE)
      RETURN hxt_holiday_calendars.element_type_id%TYPE;

   FUNCTION day_is_holiday (
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE,
      p_day          IN   DATE
   )
      RETURN BOOLEAN;

   FUNCTION timecard_approved (
      p_tim_id        IN   hxt_holiday_calendars.id%TYPE,
      p_approver_id   IN   hxt_timecards_f.approv_person_id%TYPE,
      p_source_flag   IN   hxt_timecards_f.auto_gen_flag%TYPE
   )
      RETURN BOOLEAN;

   PROCEDURE tcard_approved (
      p_batch_id      IN   NUMBER,
      p_person_id     IN   hxt_timecards.for_person_id%TYPE,
      p_period_id     IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id        IN   hxt_timecards.id%TYPE,
      p_approver_id   IN   hxt_timecards_f.approv_person_id%TYPE,
      p_source_flag   IN   hxt_timecards_f.auto_gen_flag%TYPE
   );

   FUNCTION legislation_code (
      p_bg_id   IN   per_business_groups.business_group_id%TYPE
   )
      RETURN VARCHAR2; -- per_business_groups.legislation_code%TYPE;

   FUNCTION legislation_code (
      p_asg_id           IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN per_business_groups.legislation_code%TYPE;

   FUNCTION assignment_is_active (
      p_asg_id           IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN BOOLEAN;

   PROCEDURE inactive_emp_tcard (
      p_batch_id        IN   NUMBER,
      p_person_id       IN   hxt_timecards.for_person_id%TYPE,
      p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
      p_period_id       IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id          IN   hxt_timecards.id%TYPE,
      p_day             IN   DATE
   );

   PROCEDURE get_holiday_info (
      p_day                   IN              DATE,
      p_hol_cal_id            IN              hxt_holiday_calendars.id%TYPE,
      p_hol_hours             OUT NOCOPY      hxt_holiday_days.hours%TYPE,
      p_hol_element_type_id   OUT NOCOPY      hxt_holiday_calendars.element_type_id%TYPE
   );

   PROCEDURE get_holiday_info (
      p_person_id             IN              per_people_f.person_id%TYPE,
      p_day                   IN              DATE,
      p_effective_date        IN              DATE,
      p_hol_hours             OUT NOCOPY      hxt_holiday_days.hours%TYPE,
      p_hol_element_type_id   OUT NOCOPY      hxt_holiday_calendars.element_type_id%TYPE
   );

   FUNCTION sum_unexploded_hours (
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   hxt_det_hours_worked_f.date_worked%TYPE,
      p_hours_type   IN   hxt_det_hours_worked_f.hours%TYPE DEFAULT NULL
   )
      RETURN NUMBER;

   PROCEDURE holiday_mismatch (
      p_batch_id     IN   NUMBER,
      p_person_id    IN   hxt_timecards.for_person_id%TYPE,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   DATE,
      p_hours_type   IN   hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
   );

   PROCEDURE holiday_valid (
      p_batch_id     IN   NUMBER,
      p_person_id    IN   hxt_timecards.for_person_id%TYPE,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   DATE,
      p_hours_type   IN   hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
   );

   FUNCTION element_link (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_assignment_id     IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date    IN   DATE
   )
      RETURN pay_element_links_f.element_link_id%TYPE;

   FUNCTION element_linked (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_assignment_id     IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date    IN   DATE
   )
      RETURN BOOLEAN;

   FUNCTION valid_for_summing (
      p_element_id          IN   pay_element_types_f.element_type_id%TYPE,
      p_earnings_category   IN   hxt_add_elem_info_f.earning_category%TYPE,
      p_day                 IN   DATE,
      p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE,
      p_hol_cal_id          IN   hxt_holiday_calendars.id%TYPE,
      p_valid_earn_cat1     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat2     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat3     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat4     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat5     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat6     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat7     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL
   )
      RETURN BOOLEAN;

   FUNCTION sum_valid_det_hours (
      p_tim_id          IN   hxt_timecards.id%TYPE,
      p_day             IN   DATE,
      p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
      p_hol_cal_id      IN   hxt_holiday_calendars.id%TYPE
   )
      RETURN NUMBER;

   PROCEDURE day_over_24 (
      p_batch_id        IN   NUMBER,
      p_person_id       IN   hxt_timecards.for_person_id%TYPE,
      p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
      p_period_id       IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id          IN   hxt_timecards.id%TYPE,
      p_day             IN   DATE,
      p_hol_cal_id      IN   hxt_holiday_calendars.id%TYPE
   );

   PROCEDURE holiday_as_reg (
      p_batch_id     IN   NUMBER,
      p_person_id    IN   hxt_timecards.for_person_id%TYPE,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   DATE,
      p_hours_type   IN   hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
   );

   PROCEDURE validate_tc (
      p_batch_id           IN              NUMBER,
      p_tim_id             IN              hxt_timecards.id%TYPE,
      p_person_id          IN              hxt_timecards.for_person_id%TYPE,
      p_period_id          IN              hxt_timecards.time_period_id%TYPE,
      p_approv_person_id   IN              hxt_timecards.approv_person_id%TYPE,
      p_auto_gen_flag      IN              hxt_timecards.auto_gen_flag%TYPE,
      p_error_level        IN OUT NOCOPY   NUMBER
   );

   PROCEDURE val_batch (
      p_batch_id         IN              NUMBER,
      p_time_period_id   IN              NUMBER,
      p_valid_retcode    IN OUT NOCOPY   NUMBER,
      p_merge_flag	 IN		 VARCHAR2 DEFAULT '0',
      p_merge_batches    OUT NOCOPY      HXT_BATCH_PROCESS.MERGE_BATCHES_TYPE_TABLE
   );


   -- Bug 8584436
   -- Added the following functions to return required values for the respective token ids.

   FUNCTION person_name      ( p_person_id  IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION holiday_calendar_name    ( p_hcl_id   IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION assignment(p_person_id IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION period_end_date(p_period_id IN NUMBER)
   RETURN VARCHAR2;


END hxt_batch_val;

/
