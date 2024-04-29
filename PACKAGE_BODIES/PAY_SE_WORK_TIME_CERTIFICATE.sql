--------------------------------------------------------
--  DDL for Package Body PAY_SE_WORK_TIME_CERTIFICATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_WORK_TIME_CERTIFICATE" AS
/* $Header: pysewtcr.pkb 120.0.12010000.5 2010/02/02 17:52:58 vijranga ship $ */
   g_debug                   BOOLEAN        := hr_utility.debug_enabled;

   TYPE lock_rec IS RECORD (
      archive_assact_id   NUMBER
   );

   TYPE lock_table IS TABLE OF lock_rec
      INDEX BY BINARY_INTEGER;

   g_lock_table              lock_table;
   g_index                   NUMBER         := -1;
   g_index_assact            NUMBER         := -1;
   g_index_bal               NUMBER         := -1;
   g_package                 VARCHAR2 (240) := 'PAY_SE_WORK_TIME_CERTIFICATE.';
   g_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;

--  TYPE Month_value  IS TABLE OF NUMBER INDEX BY VARCHAR2(64);
   TYPE month_value IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE absval IS RECORD (
      each_month_days    month_value
     ,each_month_hours   month_value
     ,YEAR               VARCHAR2 (240)
     ,tot_addl_time_hours     month_value
     ,tot_overtime_hours      month_value
     ,tot_absence_hours       month_value
   );

   TYPE val IS TABLE OF absval
      INDEX BY BINARY_INTEGER;

   value_month_year          val;
   -- Globals to pick up all th parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_person_id               NUMBER;
   g_assignment_id           NUMBER;
   g_still_employed          VARCHAR2 (10);
   g_income_salary_year      VARCHAR2 (10);
--End of Globals to pick up all the parameter
   g_format_mask             VARCHAR2 (50);
   g_err_num                 NUMBER;
   g_errm                    VARCHAR2 (150);

   /* GET PARAMETER */
   FUNCTION get_parameter (
      p_parameter_string         IN       VARCHAR2
     ,p_token                    IN       VARCHAR2
     ,p_segment_number           IN       NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      l_parameter   pay_payroll_actions.legislative_parameters%TYPE   := NULL;
      l_start_pos   NUMBER;
      l_delimiter   VARCHAR2 (1)                                      := ' ';
      l_proc        VARCHAR2 (240)          := g_package || ' get parameter ';
   BEGIN
      --
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Function GET_PARAMETER', 10);
      END IF;

      l_start_pos :=
              INSTR (' ' || p_parameter_string, l_delimiter || p_token || '=');

      --
      IF l_start_pos = 0
      THEN
         l_delimiter := '|';
         l_start_pos :=
             INSTR (' ' || p_parameter_string, l_delimiter || p_token || '=');
      END IF;

      IF l_start_pos <> 0
      THEN
         l_start_pos := l_start_pos + LENGTH (p_token || '=');
         l_parameter :=
            SUBSTR (p_parameter_string
                   ,l_start_pos
                   ,   INSTR (p_parameter_string || ' '
                             ,l_delimiter
                             ,l_start_pos
                             )
                     - (l_start_pos)
                   );

         IF p_segment_number IS NOT NULL
         THEN
            l_parameter := ':' || l_parameter || ':';
            l_parameter :=
               SUBSTR (l_parameter
                      , INSTR (l_parameter, ':', 1, p_segment_number) + 1
                      ,   INSTR (l_parameter, ':', 1, p_segment_number + 1)
                        - 1
                        - INSTR (l_parameter, ':', 1, p_segment_number)
                      );
         END IF;
      END IF;

      --
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Function GET_PARAMETER', 20);
      END IF;

      RETURN l_parameter;
   END;

   /* GET ALL PARAMETERS */
   PROCEDURE get_all_parameters (
      p_payroll_action_id        IN       NUMBER               -- In parameter
     ,p_business_group_id        OUT NOCOPY NUMBER           -- Core parameter
     ,p_effective_date           OUT NOCOPY DATE             -- Core parameter
     ,p_person_id                OUT NOCOPY NUMBER           -- User parameter
     ,p_assignment_id            OUT NOCOPY VARCHAR2         -- User parameter
     ,p_still_employed           OUT NOCOPY VARCHAR2         -- User parameter
     ,p_income_salary_year       OUT NOCOPY VARCHAR2         -- User parameter
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT (pay_se_work_time_certificate.get_parameter
                                                      (legislative_parameters
                                                      ,'PERSON_ID'
                                                      )
                ) person_id
               , (pay_se_work_time_certificate.get_parameter
                                                      (legislative_parameters
                                                      ,'ASSIGNMENT_ID'
                                                      )
                 ) assignment_id
               , (pay_se_work_time_certificate.get_parameter
                                                      (legislative_parameters
                                                      ,'STILL_EMPLOYED'
                                                      )
                 ) still_employed
               , (pay_se_work_time_certificate.get_parameter
                                                      (legislative_parameters
                                                      ,'SALARY_YEAR'
                                                      )
                 ) income_salary_year
               ,effective_date effective_date
               ,business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                        := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN
      --logger ('Entering ', l_proc);
      --logger ('p_payroll_action_id ', p_payroll_action_id);

      OPEN csr_parameter_info (p_payroll_action_id);

      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info
       INTO lr_parameter_info;

      CLOSE csr_parameter_info;

      fnd_file.put_line (fnd_file.LOG
                        ,    'lr_parameter_info.STILL_EMPLOYED   '
                          || lr_parameter_info.still_employed
                        );
      --logger ('Entering ', l_proc);
      p_person_id := lr_parameter_info.person_id;
      --logger ('lr_parameter_info.PERSON_ID ', lr_parameter_info.person_id);
      p_assignment_id := lr_parameter_info.assignment_id;
      --logger ('lr_parameter_info.ASSIGNMENT_ID '             ,lr_parameter_info.assignment_id             );
      p_still_employed := lr_parameter_info.still_employed;
           --logger ('lr_parameter_info.still_employed '             ,lr_parameter_info.still_employed             );
      p_income_salary_year := lr_parameter_info.income_salary_year;
      --logger ('lr_parameter_info.income_salary_year '             ,lr_parameter_info.income_salary_year             );
      p_effective_date := lr_parameter_info.effective_date;
      --logger ('lr_parameter_info.effective_date '             ,lr_parameter_info.effective_date             );
      p_business_group_id := lr_parameter_info.bg_id;
      --logger ('lr_parameter_info.bg_id ', lr_parameter_info.bg_id);
      --logger ('LEAVING ', l_proc);



      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS'
                                 ,30);
      END IF;
   END get_all_parameters;

-- *****************************************************************************
  /* RANGE CODE */
-- *****************************************************************************
   PROCEDURE range_code (
      p_payroll_action_id        IN       NUMBER
     ,p_sql                      OUT NOCOPY VARCHAR2
   )
   IS
      l_action_info_id               NUMBER;
      l_ovn                          NUMBER;
      l_business_group_id            NUMBER;
      l_start_date                   VARCHAR2 (30);
      l_end_date                     VARCHAR2 (30);
      l_assignment_id                NUMBER;
-- *****************************************************************************
-- Variable Required
      l_set                          NUMBER;
      l_report_effective_date        DATE;
      l_person_number                VARCHAR2 (100);
      l_last_name                    per_all_people_f.last_name%TYPE;
      l_first_name                   per_all_people_f.first_name%TYPE;
      l_hired_from                   DATE;
      l_hired_to                     DATE;
      l_still_employed               VARCHAR2 (10);
      l_absence_from                 VARCHAR2 (100);
      l_absence_to                   VARCHAR2 (100);
      l_form_of_employment           VARCHAR2 (100);
      l_intermittent_employee        VARCHAR2 (100);   --EOY 2008
      l_work_tasks                   VARCHAR2 (240);
      l_emp_at_temp_agency           VARCHAR2 (5);
      l_emp_temp_work                VARCHAR2 (5);
      l_ending_assignment_by         VARCHAR2 (100);
      l_reason                       VARCHAR2 (100);
      l_notification_date            VARCHAR2 (100);
      l_termination_reason           VARCHAR2 (100);  --EOY 2008
      l_continuous_offer             VARCHAR2 (100);
      l_permanent_date_from          VARCHAR2 (100);
      l_permanent_date_to            VARCHAR2 (100);  --EOY 2008
      l_permanent_check_box          VARCHAR2 (100);
      l_time_limited_from            VARCHAR2 (100);
      l_time_limited_to              VARCHAR2 (100);
      l_time_limited_check_box       VARCHAR2 (100);
      l_other                        VARCHAR2 (100);
      l_other_check_box              VARCHAR2 (100);
      l_full_time                    VARCHAR2 (100);
      l_full_time_check_box          VARCHAR2 (100);
      l_part_time                    VARCHAR2 (100);
      l_part_time_check_box          VARCHAR2 (100);
      l_working_percentage           VARCHAR2 (100);
      l_various_working_time         VARCHAR2 (100);
      l_offer_accepted               VARCHAR2 (100);
      l_decline_date                 VARCHAR2 (100);
      l_aggrmnt_of_compn_signed      VARCHAR2 (100);  --EOY 2008
      l_time_worked_from             VARCHAR2 (100);
      l_time_worked_to               VARCHAR2 (100);
      l_total_worked_hours           NUMBER;
      l_paid_sick_leave_days         NUMBER;
      l_teaching_load                VARCHAR2 (100);
      l_teaching_load_check_box      VARCHAR2 (100);   --EOY 2008
      l_assign_hours_week            VARCHAR2 (100);
      l_assign_frequency             VARCHAR2 (100);
      l_assign_various_work_time     VARCHAR2 (100);
      l_assign_working_percentage    NUMBER;
      l_assign_full_time             VARCHAR2 (100);
      l_assign_part_time             VARCHAR2 (100);
      l_local_unit_id                NUMBER;
      l_salary_year                  VARCHAR2 (100);
      l_assign_salary_paid_out       VARCHAR2 (100);
      l_salary_amount                NUMBER(10,2);
--l_assign_working_percentage varchar2(100);
      l_school_holiday_pay_amount    VARCHAR2 (100);
      l_holiday_pay_amount           VARCHAR2 (100);     -- EOY 2008
      l_school_holiday_pay_box       VARCHAR2 (100);
      l_emp_with_holiday_pay         VARCHAR2 (100);
      l_no_of_paid_holiday_days      VARCHAR2 (100);
      l_paid_days_off_duty_time      VARCHAR2 (100);
      l_employed_educational_assoc   VARCHAR2 (100);
      l_holiday_duty                 VARCHAR2 (100);
      l_lay_off_period_paid_days     VARCHAR2 (100);
      l_holiday_laid_off             VARCHAR2 (100);
      l_lay_off_from                 VARCHAR2 (100);
      l_lay_off_to                   VARCHAR2 (100);
      l_other_information            VARCHAR2 (100);
      l_legal_employer_name          VARCHAR2 (100);
      l_org_number                   VARCHAR2 (100);
      l_location_id                  VARCHAR2 (100);
      l_phone_number                 VARCHAR2 (100);
      l_location_code                VARCHAR2 (100);
      l_address_line_1               VARCHAR2 (100);
      l_address_line_2               VARCHAR2 (100);
      l_address_line_3               VARCHAR2 (100);
      l_postal_code                  VARCHAR2 (100);
      l_town_or_city                 VARCHAR2 (100);
      l_region_1                     VARCHAR2 (100);
      l_region_2                     VARCHAR2 (100);
      l_territory_short_name         VARCHAR2 (100);
      l_soft_coding_keyflex_id       hr_soft_coding_keyflex.soft_coding_keyflex_id%TYPE;
      l_one_year_date                DATE;
      l_temp_start_date              DATE;
      l_temp_end_date                DATE;
      l_temp_date                    DATE;
      l_seven_year_end_date          DATE;
      l_absence_per_month            NUMBER;
      l_vacation_absence             NUMBER;
      l_legal_employer_id            NUMBER;
      l_end_loop                     NUMBER;
      l_temp_counter                 VARCHAR2 (20);
      l_total_absence_days           NUMBER;
      l_sick_pay_hours               NUMBER; -- Bug#9272420 issue#5 fix
      l_waiting_hours                NUMBER; -- Bug#9272420 issue#5 fix
      l_total_absence_hours          NUMBER;
      l_total_working_days           NUMBER;
      l_total_working_hours          NUMBER;
      l_previousyear                 NUMBER;
      l_currentyear                  NUMBER;
      l_currentmonth                 VARCHAR2 (15);
      l_count_year                   NUMBER                              := 0;
      l_annual_salary                NUMBER;
      l_return                       NUMBER;
      l_days_wth_public              NUMBER;
      l_hours_wth_public             NUMBER;
      l_each_absence                 NUMBER;
      l_first_year                   NUMBER;
      l_second_year                  NUMBER;
      l_all_sick_absence_days        NUMBER;
      l_all_worked_hours             NUMBER;
      l_start_date_for_salary        DATE;
      l_end_date_for_salary          DATE;
      l_month_between_salary_year    NUMBER;
      l_get_defined_balance_id       NUMBER;
      l_get_salary_date              DATE;
      l_curr_month_start             DATE;
      l_curr_month_end               DATE;
      l_start_assign_date            DATE;
      l_count                        NUMBER;
      l_month_start                  DATE;
      l_month_end                    DATE;
      l_salary_year_hours            NUMBER;
      l_salary_year_hours_worked     NUMBER;
      l_job_name                     VARCHAR2 (100);
      l_position_name                VARCHAR2 (100);
      l_start_time_char varchar2(5) := '00:00';
      l_end_time_char varchar2(5) := '23:59';
      l_hourly_pay_variable          VARCHAR2 (100);  --EOY 2008
      l_hourly_overtime_rate         VARCHAR2 (100);  --EOY 2008
      l_hourly_addl_suppl_time       VARCHAR2 (100);  --EOY 2008
      l_other_taxable_compensation   VARCHAR2 (100);  --EOY 2008
      l_report_start_date	     DATE;            --EOY 2008
      l_dimension	             VARCHAR2 (100);  --EOY 2008
      l_tot_overtime_hours           NUMBER;          --EOY 2008
      l_overtime_hours               NUMBER;          --EOY 2008
      l_addl_time_hours              NUMBER;          --EOY 2008
      l_tot_addl_time_hours          NUMBER;          --EOY 2008
      l_reporting_date	             DATE ;           --EOY 2008
      l_absence_percentage           VARCHAR(100);    --EOY 2008
      l_employment_end_date          VARCHAR(100);    --EOY 2008
      l_absence_hours                NUMBER;          --EOY 2008
      l_tot_absence_hours            NUMBER;          --EOY 2008

-- *****************************************************************************
-- CURSOR
      CURSOR csr_absence_details (
         csr_v_person_id                     NUMBER
        ,csr_v_start_date                    DATE
        ,csr_v_end_date                      DATE
      )
      IS
         SELECT   paa.absence_attendance_id
--         ,paa.date_start
         ,        GREATEST (paa.date_start, csr_v_start_date) startdate
                 ,paa.time_start
--        ,paa.date_end
         ,        LEAST (paa.date_end, csr_v_end_date) enddate
                 ,paa.time_end
             FROM per_absence_attendances paa
                 ,per_absence_attendance_types pat
            WHERE paa.person_id = csr_v_person_id
              AND (   paa.date_start BETWEEN csr_v_start_date AND csr_v_end_date
                   OR paa.date_end BETWEEN csr_v_start_date AND csr_v_end_date
                  )
/*    (
           (paa.date_start >=CSR_V_start_date AND ( nvl(paa.date_end,CSR_V_end_date)<=CSR_V_end_date) or (nvl(paa.date_end,CSR_V_end_date)>=CSR_V_end_date) )
             or
           ( (paa.date_start < CSR_V_start_date ) and nvl(paa.date_end,CSR_V_end_date)<=CSR_V_end_date)
        )
*/
              AND paa.absence_attendance_type_id =
                                                pat.absence_attendance_type_id
              AND pat.absence_category NOT IN ('V')
         ORDER BY paa.date_start;

      CURSOR csr_address_details (
         csr_v_location_id                   hr_locations.location_id%TYPE
      )
      IS
         SELECT hl.location_code
               ,hl.description
               ,hl.address_line_1
               ,hl.address_line_2
               ,hl.address_line_3
               ,hl.postal_code
               ,hl.town_or_city
               ,hl.region_1
               ,hl.region_2
               ,ft.territory_short_name
           FROM hr_organization_units hou
               ,hr_locations hl
               ,fnd_territories_vl ft
          WHERE hl.location_id = csr_v_location_id
            AND hl.country = ft.territory_code;

      lr_address_details             csr_address_details%ROWTYPE;

      CURSOR csr_legal_employer_details (
         csr_v_local_unit_id                 hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o.NAME
               ,hoi3.org_information2 "ORG_NUMBER"
               ,o.location_id
               ,o.organization_id
           FROM hr_all_organization_units o
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information_context = 'CLASS'
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi2.organization_id = hoi1.organization_id
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.org_information1 = csr_v_local_unit_id
            AND o.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

      lr_legal_employer_details      csr_legal_employer_details%ROWTYPE;

      CURSOR csr_contact_details (
         csr_v_legal_employer_id             hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hoi4.org_information3
           FROM hr_organization_information hoi4
          WHERE hoi4.organization_id = csr_v_legal_employer_id
            AND hoi4.org_information_context = 'SE_ORG_CONTACT_DETAILS'
            AND hoi4.org_information_id =
                   (SELECT MIN (org_information_id)
                      FROM hr_organization_information
                     WHERE organization_id = csr_v_legal_employer_id
                       AND org_information_context = 'SE_ORG_CONTACT_DETAILS'
                       AND org_information1 = 'PHONE');

      lr_contact_details             csr_contact_details%ROWTYPE;

-- To CHECK ACTIVE ASSIGNMENT OR TERMINATE
      CURSOR csr_assign_status (
         csr_v_person_id                     per_all_assignments_f.person_id%TYPE
        ,csr_v_assignment_id                 per_all_assignments_f.assignment_id%TYPE
      )
      IS
         SELECT past.per_system_status
               ,p.effective_start_date
               ,p.effective_end_date
           FROM per_all_assignments_f p
               ,per_assignment_status_types past
          WHERE p.business_group_id = g_business_group_id
            AND p.effective_start_date =
                                   (SELECT MAX (p1.effective_start_date)
                                      FROM per_all_assignments_f p1
                                      ,per_assignment_status_types past1
                                     WHERE p1.assignment_id = p.assignment_id
                                    AND past1.assignment_status_type_id = p1.assignment_status_type_id
                                    AND past1.per_system_status IN ('ACTIVE_ASSIGN' )
)
            AND p.person_id = csr_v_person_id
            AND p.assignment_id = csr_v_assignment_id
            AND past.assignment_status_type_id = p.assignment_status_type_id
            AND past.per_system_status IN ('ACTIVE_ASSIGN', 'TERM_ASSIGN');

      lr_assign_status               csr_assign_status%ROWTYPE;

      CURSOR csr_get_assign_min_start_date (
         csr_v_person_id                     per_all_assignments_f.person_id%TYPE
        ,csr_v_assignment_id                 per_all_assignments_f.assignment_id%TYPE
      )
      IS
         SELECT MIN (p.effective_start_date) min_date
           FROM per_all_assignments_f p
          WHERE p.business_group_id = g_business_group_id
            AND p.person_id = csr_v_person_id
            AND p.assignment_id = csr_v_assignment_id;

      lr_get_assign_min_start_date   csr_get_assign_min_start_date%ROWTYPE;

      CURSOR csr_person_info (
         csr_v_person_id                     per_all_people_f.person_id%TYPE
        ,csr_v_effective_date                per_all_people_f.effective_start_date%TYPE
      )
      IS
         SELECT *
           FROM per_all_people_f p
          WHERE p.business_group_id = g_business_group_id
            AND p.person_id = csr_v_person_id
            AND csr_v_effective_date BETWEEN p.effective_start_date
                                         AND p.effective_end_date;

      lr_person_info                 csr_person_info%ROWTYPE;

      CURSOR csr_assignment_info (
         csr_v_person_id                     per_all_people_f.person_id%TYPE
        ,csr_v_assignment_id                 per_all_assignments_f.person_id%TYPE
        ,csr_v_effective_date                per_all_assignments_f.effective_start_date%TYPE
      )
      IS
         SELECT *
           FROM per_all_assignments_f p
          WHERE p.business_group_id = g_business_group_id
            AND p.assignment_id = csr_v_assignment_id
            AND p.person_id = csr_v_person_id
            AND csr_v_effective_date BETWEEN p.effective_start_date
                                         AND p.effective_end_date;

      lr_assignment_info             csr_assignment_info%ROWTYPE;

      CURSOR csr_extra_assignment_info (
         csr_v_assignment_id                 per_all_assignments_f.person_id%TYPE
        ,csr_v_information_type              per_assignment_extra_info.information_type%TYPE
      )
      IS
         SELECT *
           FROM per_assignment_extra_info
          WHERE assignment_id = csr_v_assignment_id
            AND information_type = csr_v_information_type;

      lr_extra_assignment_info       csr_extra_assignment_info%ROWTYPE;

      CURSOR csr_se_wtc_time_worked_info (
         csr_v_assignment_id                 per_all_assignments_f.person_id%TYPE
        ,csr_v_year                          per_assignment_extra_info.aei_information1%TYPE
      )
      IS
         SELECT *
           FROM per_assignment_extra_info
          WHERE assignment_id = csr_v_assignment_id
            AND information_type = 'SE_WTC_TIME_WORKED_INFO'
            AND aei_information1 = csr_v_year;

      CURSOR csr_soft_coded_keyflex_info (
         csr_v_soft_coding_keyflex_id        hr_soft_coding_keyflex.soft_coding_keyflex_id%TYPE
      )
      IS
         SELECT *
           FROM hr_soft_coding_keyflex
          WHERE soft_coding_keyflex_id = csr_v_soft_coding_keyflex_id;

      lr_soft_coded_keyflex_info     csr_soft_coded_keyflex_info%ROWTYPE;
--****************************************************************************************

--**********************************************************************************
/* Cursor for Additional/Supplementary and Overtime Hours */
CURSOR csr_balance
(p_balance_category_name VARCHAR2
,p_business_group_id NUMBER)
IS
SELECT  REPLACE(UPPER(pbt.balance_name),' ' ,'_') balance_name , pbt.balance_name bname
FROM pay_balance_types pbt , pay_balance_categories_f pbc
WHERE pbc.legislation_code='SE'
AND pbt.business_group_id =p_business_group_id
AND pbt.balance_category_id = pbc.balance_category_id
AND pbc.category_name = p_balance_category_name ;


/* Cursor to retrieve Defined Balance Id */
Cursor csr_bg_get_defined_balance_id
(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE
,p_business_group_id NUMBER)
IS
SELECT   ue.creator_id
FROM    ff_user_entities  ue,
ff_database_items di
WHERE   di.user_name = csr_v_Balance_Name
AND     ue.user_entity_id = di.user_entity_id
AND     ue.legislation_code is NULL
AND     ue.business_group_id = p_business_group_id
AND     ue.creator_type = 'B';

rg_csr_bg_get_defined_bal_id  csr_bg_get_defined_balance_id%rowtype;

--***********************************************************************************




-- *****************************************************************************
/* Proc to Add the tag value and Name */
      FUNCTION check_nvl2 (
         p_value                    IN       VARCHAR2
        ,p_not_null_value           IN       VARCHAR2
        ,p_null_value               IN       VARCHAR2
      )
         RETURN VARCHAR2
      IS
      BEGIN
         IF p_value IS NOT NULL
         THEN
            RETURN p_not_null_value;
         ELSE
            RETURN p_null_value;
         END IF;
      END check_nvl2;
/* End of Proc to Add the tag value and Name */

   -- Archiving the data , as this will fire once
-- *****************************************************************************
-- *****************************************************************************
   BEGIN
-- *****************************************************************************
      fnd_file.put_line (fnd_file.LOG, 'In  RANGE_CODE 0');
      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_person_id := NULL;
      g_assignment_id := NULL;
      pay_se_work_time_certificate.get_all_parameters (p_payroll_action_id
                                                      ,g_business_group_id
                                                      ,g_effective_date
                                                      ,g_person_id
                                                      ,g_assignment_id
                                                      ,g_still_employed
                                                      ,g_income_salary_year
                                                      );
      --logger ('Range Code g_person_id', g_person_id);
      --logger ('g_assignment_id', g_assignment_id);
      --logger ('g_effective_date', g_effective_date);
      --logger ('g_business_group_id', g_business_group_id);

 -- *****************************************************************************
--START OF PICKING UP DATA
   -- TO pick up the PIN
      OPEN csr_assign_status (g_person_id, g_assignment_id);

      FETCH csr_assign_status
       INTO lr_assign_status;

      CLOSE csr_assign_status;

      IF     lr_assign_status.per_system_status = 'ACTIVE_ASSIGN'
--         AND g_still_employed = 'Y'
      and (to_char (lr_assign_status.effective_end_date, 'DD-MM-YYYY') ='31-12-4712')
      THEN
         l_report_effective_date := g_effective_date;
      ELSE
         l_report_effective_date := lr_assign_status.effective_end_date;
      END IF;

      --logger ('lr_ASSIGN_STATUS.PER_SYSTEM_STATUS'             ,lr_assign_status.per_system_status             );
      --logger ('l_report_effective_date', l_report_effective_date);

      OPEN csr_person_info (g_person_id, l_report_effective_date);

      FETCH csr_person_info
       INTO lr_person_info;

      CLOSE csr_person_info;

      l_person_number := lr_person_info.national_identifier;
      l_last_name := lr_person_info.last_name;
      l_first_name := lr_person_info.first_name;
      --logger ('l_person_number', l_person_number);
      --logger ('l_last_name', l_last_name);
      --logger ('l_first_name', l_first_name);

      OPEN csr_assignment_info (g_person_id
                               ,g_assignment_id
                               ,l_report_effective_date
                               );

      FETCH csr_assignment_info
       INTO lr_assignment_info;

      CLOSE csr_assignment_info;

      l_hired_from := lr_assignment_info.effective_start_date;
      --logger ('condition l_hired_to', to_char (lr_assignment_info.effective_end_date, 'DD-MM-YYYY'));
IF (to_char (lr_assignment_info.effective_end_date, 'DD-MM-YYYY') ='31-12-4712')
THEN
      l_hired_to := NULL;
      --logger ('Nulling l_hired_to', l_hired_to);
ELSE
      l_hired_to := lr_assignment_info.effective_end_date;
      --logger ('Passing l_hired_to', l_hired_to);
END IF;
/*
IF (TO_CHAR (lr_assignment_info.effective_end_date, 'DD-MM-YYYY') =TO_DATE('31-12-4712','DD-MM-YYYY'))
THEN
      l_hired_to := NULL;
ELSE
      l_hired_to := lr_assignment_info.effective_end_date;
END IF;
*/
      --l_still_employed := check_NVL2(lr_assignment_info.effective_end_date,'N','Y');
      l_still_employed := g_still_employed;
      l_soft_coding_keyflex_id := lr_assignment_info.soft_coding_keyflex_id;
      --logger ('l_hired_from', l_hired_from);
      --logger ('l_hired_to', l_hired_to);
      --logger ('l_SOFT_CODING_KEYFLEX_ID', l_soft_coding_keyflex_id);
      lr_extra_assignment_info := NULL;

      OPEN csr_extra_assignment_info (g_assignment_id, 'SE_WTC_EMPLOYEE_INFO');

      FETCH csr_extra_assignment_info
       INTO lr_extra_assignment_info;

      CLOSE csr_extra_assignment_info;

      l_absence_from := lr_extra_assignment_info.aei_information1;
      l_absence_to := lr_extra_assignment_info.aei_information2;
      l_absence_percentage := lr_extra_assignment_info.aei_information3;   -- EOY 2008
      --logger ('l_absence_from', l_absence_from);
      --logger ('l_absence_to', l_absence_to);
      --logger (' l_absence_percentage',  l_absence_percentage);
-- *****************************************************************************
      l_job_name := hr_general.decode_job (lr_assignment_info.job_id);
      l_position_name :=
         hr_general.decode_position_latest_name
                                      (lr_assignment_info.position_id
                                      ,lr_assignment_info.effective_start_date
                                      );
      l_form_of_employment := lr_assignment_info.EMPLOYMENT_CATEGORY;
      l_work_tasks := l_job_name || '-' || l_position_name;
      --logger ('l_form_of_employment', l_form_of_employment);
      --logger ('l_work_tasks', l_work_tasks);
--l_emp_at_temp_agency := ;
      lr_extra_assignment_info := NULL;

      OPEN csr_extra_assignment_info (g_assignment_id
                                     ,'SE_WTC_ASSIGNMENT_INFO'
                                     );

      FETCH csr_extra_assignment_info
       INTO lr_extra_assignment_info;

      CLOSE csr_extra_assignment_info;

      l_emp_at_temp_agency := lr_extra_assignment_info.aei_information1;
      l_emp_temp_work := lr_extra_assignment_info.aei_information2;
      l_ending_assignment_by := lr_extra_assignment_info.aei_information3;
      --logger ('l_emp_at_temp_agency', l_emp_at_temp_agency);
      --logger ('l_emp_temp_work', l_emp_temp_work);
      --logger ('l_ending_assignment_by', l_ending_assignment_by);

-- *****************************************************************************
-- SOFT CODED FLEX
      OPEN csr_soft_coded_keyflex_info (l_soft_coding_keyflex_id);

      FETCH csr_soft_coded_keyflex_info
       INTO lr_soft_coded_keyflex_info;

      CLOSE csr_soft_coded_keyflex_info;

      l_local_unit_id := lr_soft_coded_keyflex_info.segment2;
      l_reason :=
         hr_general.decode_lookup ('LEAV_REAS'
                                  ,lr_soft_coded_keyflex_info.segment7
                                  );
      l_notification_date := lr_soft_coded_keyflex_info.segment5;
      l_termination_reason := lr_soft_coded_keyflex_info.segment7;

      --Added the conversion from number to cannonical
      l_assign_working_percentage := fnd_number.canonical_to_number(lr_soft_coded_keyflex_info.segment9);
      --logger ('l_local_unit_id', l_local_unit_id);
      --logger ('l_reason', l_reason);
      --logger ('l_notification_date', l_notification_date);
       --logger (' l_termination_reason',  l_termination_reason);
      --logger ('l_assign_working_percentage', l_assign_working_percentage);
-- *****************************************************************************
      lr_extra_assignment_info := NULL;

      OPEN csr_extra_assignment_info (g_assignment_id
                                     ,'SE_WTC_EMPLOYMENT_INFO'
                                     );

      FETCH csr_extra_assignment_info
       INTO lr_extra_assignment_info;

      CLOSE csr_extra_assignment_info;

      l_continuous_offer := lr_extra_assignment_info.aei_information1;
      l_permanent_date_from := lr_extra_assignment_info.aei_information2;
      l_permanent_date_to   := lr_extra_assignment_info.aei_information12;
      l_permanent_check_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information2, 'Y', 'N');
      l_time_limited_from := lr_extra_assignment_info.aei_information3;
      l_time_limited_to := lr_extra_assignment_info.aei_information4;
      l_time_limited_check_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information3, 'Y', 'N');
      l_other := lr_extra_assignment_info.aei_information5;
      l_other_check_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information5, 'Y', 'N');
      l_full_time := lr_extra_assignment_info.aei_information6;
      l_full_time_check_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information6, 'Y', 'N');
      l_part_time := lr_extra_assignment_info.aei_information7;
      l_part_time_check_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information7, 'Y', 'N');
      l_working_percentage := lr_extra_assignment_info.aei_information8;
      IF l_full_time IS NOT NULL and l_part_time IS NOT NULL
      THEN
        l_various_working_time := 'Y';
      ELSE
        l_various_working_time := 'N';
      END IF;


      l_offer_accepted := lr_extra_assignment_info.aei_information9;
      l_decline_date := lr_extra_assignment_info.aei_information10;

      l_aggrmnt_of_compn_signed := lr_extra_assignment_info.aei_information11;

      --logger ('l_continuous_offer', l_continuous_offer);
      --logger ('l_permanent_date_from', l_permanent_date_from);
      --logger ('l_permanent_date_to', l_permanent_date_to);
      --logger ('l_permanent_check_box', l_permanent_check_box);
      --logger ('l_time_limited_from', l_time_limited_from);
      --logger ('l_time_limited_to', l_time_limited_to);
      --logger ('l_time_limited_check_box', l_time_limited_check_box);
      --logger ('l_other', l_other);
      --logger ('l_other_check_box', l_other_check_box);
      --logger ('l_full_time', l_full_time);
      --logger ('l_full_time_check_box', l_full_time_check_box);
      --logger ('l_part_time', l_part_time);
      --logger ('l_part_time_check_box', l_part_time_check_box);
      --logger ('l_working_percentage', l_working_percentage);
      --logger ('l_various_working_time', l_various_working_time);
      --logger ('l_offer_accepted', l_offer_accepted);
      --logger ('l_decline_date', l_decline_date);
-- *****************************************************************************
-- TIME WORKED SECTION
      lr_extra_assignment_info := NULL;

      OPEN csr_extra_assignment_info (g_assignment_id
                                     ,'SE_WTC_TIME_WORKED_HEADER'
                                     );

      FETCH csr_extra_assignment_info
       INTO lr_extra_assignment_info;

      CLOSE csr_extra_assignment_info;

      l_time_worked_from := lr_extra_assignment_info.aei_information1;
      l_time_worked_to := lr_extra_assignment_info.aei_information2;
      l_total_worked_hours := lr_extra_assignment_info.aei_information3;
      l_paid_sick_leave_days := lr_extra_assignment_info.aei_information4;
      l_teaching_load := lr_extra_assignment_info.aei_information5;
      l_teaching_load_check_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information5, 'Y', 'N');   -- EOY 2008
      --logger ('l_time_worked_from', l_time_worked_from);
      --logger ('l_time_worked_to', l_time_worked_to);
      --logger ('l_total_worked_hours', l_total_worked_hours);
      --logger ('l_paid_sick_leave_days', l_paid_sick_leave_days);
      --logger ('l_teaching_load', l_teaching_load);

-- Legal Employer Details
      OPEN csr_legal_employer_details (l_local_unit_id);

      FETCH csr_legal_employer_details
       INTO lr_legal_employer_details;

      CLOSE csr_legal_employer_details;

      l_legal_employer_name := lr_legal_employer_details.NAME;
      l_org_number := lr_legal_employer_details.org_number;
      l_location_id := lr_legal_employer_details.location_id;
      l_legal_employer_id := lr_legal_employer_details.organization_id;
      --logger ('l_legal_employer_name', l_legal_employer_name);
      --logger ('l_org_number', l_org_number);
      --logger ('l_location_id', l_location_id);
      l_one_year_date := ADD_MONTHS (l_report_effective_date, -12);

      fnd_file.put_line (fnd_file.LOG, 'l_legal_employer_id'||l_legal_employer_id);

/*
three conditions
one if the date is greater than the reporting date, pass reporting date
two if the date is lesser than one year reporting date, pass one year date
third if the date is in between the one year and reporting date , pass
        last_day of the month to get balance.
*/
-- *****************************************************************************
-- *****************************************************************************
      l_second_year := TO_CHAR (l_report_effective_date, 'YYYY');
      l_first_year := l_second_year - 1;
      l_previousyear := TO_CHAR (l_report_effective_date, 'YYYY');
      --logger ('l_second_year  ', l_second_year);
      --logger ('l_first_year  ', l_first_year);
      l_temp_start_date := l_report_effective_date;
      l_temp_end_date := ADD_MONTHS (l_report_effective_date, -12);
      l_seven_year_end_date := ADD_MONTHS (l_report_effective_date, -84);
      --logger ('l_temp_start_date == ', l_temp_start_date);
      --logger ('l_temp_end_date == ', l_temp_end_date);
      --logger ('l_seven_year_end_date == ', l_seven_year_end_date);
      l_temp_date := l_report_effective_date;

-- *****************************************************************************
-- SET if in EIT the values are not given
-- *****************************************************************************

      IF  l_time_worked_from IS NULL
      THEN
         l_time_worked_from := fnd_date.date_to_canonical(GREATEST(l_temp_end_date,l_hired_from));
      END IF;

      IF l_time_worked_to IS NULL
      THEN
         l_time_worked_to := fnd_date.date_to_canonical(l_temp_start_date);
      END IF;

-- *****************************************************************************
      --logger ('g_assignment_id  ', g_assignment_id);
      --logger ('l_legal_employer_id  ', l_legal_employer_id);
      --logger ('l_local_unit_id  ', l_local_unit_id);

      OPEN csr_get_assign_min_start_date (g_person_id, g_assignment_id);

      FETCH csr_get_assign_min_start_date
       INTO lr_get_assign_min_start_date;

      CLOSE csr_get_assign_min_start_date;

     --logger ('lr_get_assign_min_start_date.MIN_DATE'             ,lr_get_assign_min_start_date.min_date      );
-- *****************************************************************************
-- RESET THESE TO ZERO
-- *****************************************************************************
      l_end_loop := 0;
      l_all_sick_absence_days := 0;
      l_all_worked_hours := 0;
      l_start_assign_date := lr_get_assign_min_start_date.min_date;
      l_temp_date := TRUNC (l_temp_start_date, 'MM');
      l_month_start := l_temp_start_date;
      l_month_end := l_temp_start_date;
      l_count := 0;

-- *****************************************************************************
      WHILE ((l_end_loop <> 1) AND (l_month_start <> l_temp_end_date))
      LOOP
         --logger ('l_temp_date ', l_temp_date);
         --logger ('l_count ', l_count);
         l_month_end := LEAST (LAST_DAY (l_temp_date), l_temp_start_date);
         l_month_start :=
            GREATEST (TRUNC (l_temp_date, 'MM')
                     ,TRUNC (l_temp_end_date, 'MM')
                     ,l_start_assign_date
                     ,l_seven_year_end_date
                     );
         --logger ('l_month_start ', l_month_start);
         --logger ('l_month_end ', l_month_end);

            IF (   (TRUNC (l_seven_year_end_date, 'MM') =
                                                     TRUNC (l_temp_date, 'MM')
                   )
                               )
            THEN
               l_end_loop := 1;
         --logger ('Endign Loop for  ', l_end_loop);
         --logger ('TRUNC (l_temp_date, MM)  ', TRUNC (l_temp_date, 'MM'));
         --logger ('TRUNC (l_seven_year_end_date, MM)', TRUNC (l_seven_year_end_date, 'MM'));
            END IF;

/*IF
THEN
END IF;
*/
-- *****************************************************************************
 /*
IF l_temp_date >= l_temp_start_date
THEN
    l_temp_date := l_temp_start_date;
logger('l_temp_date 1 ',l_temp_date);
--l_temp_date := add_months(l_temp_date,-1);

ELSIF ( (l_temp_date < l_temp_start_date) and
        (l_temp_date > l_temp_end_date) and
        (l_temp_date <> l_seven_year_end_date) and
        (l_temp_date <> last_day(lr_get_assign_min_start_date.MIN_DATE))
      )
THEN
    l_temp_date := last_day(l_temp_date);
logger('l_temp_date 2 ',l_temp_date);
--l_temp_date := add_months(l_temp_date,-1);
ELSIF ((l_temp_date = l_seven_year_end_date) or
        (l_temp_date <= l_temp_end_date ) or
        (l_temp_date = last_day(lr_get_assign_min_start_date.MIN_DATE))
         )
THEN
    l_temp_date := last_day(l_temp_end_date);
logger('l_temp_date 3 ',l_temp_date);
l_end_loop :=1;
END IF;
*/

         -- *****************************************************************************
         IF l_end_loop <> 1
         THEN
--logger('l_temp_end_date == ',l_temp_end_date);
--logger('l_end       ************    ',last_day(l_temp_date));
--logger('l_start     ************    ',trunc(l_temp_date,'MM'));
-- *****************************************************************************
-- FIND FOR THE WHOLE MONTH in DAYS
-- *****************************************************************************
            l_return :=
               hr_loc_work_schedule.calc_sch_based_dur (g_assignment_id
                                                       ,'D'
                                                       ,'Y'
                                                       ,l_month_start
                                                       ,l_month_end
                                                       ,NULL
                                                       ,NULL
                                                       ,l_days_wth_public
                                                       );
-- logger('l_DAYS_WTH_PUBLIC $$$$$$$$$$$$$$$$$$$$$$ ',l_DAYS_WTH_PUBLIC);
            l_total_absence_days := 0;
            l_each_absence := 0;

-- *****************************************************************************
-- FIND FOR EACH ABSENCE FOR THIS MONTH IN DAYS
-- *****************************************************************************
            FOR lr_abs IN csr_absence_details (g_person_id
                                              ,l_month_start
                                              ,l_month_end
                                              )
            LOOP
               --logger ('lr_abs.STARTDATE ', lr_abs.startdate);
               --logger ('lr_abs.ENDDATE   ', lr_abs.enddate);
               l_return :=
                  hr_loc_work_schedule.calc_sch_based_dur (g_assignment_id
                                                          ,'D'
                                                          ,'Y'
                                                          ,lr_abs.startdate
                                                          ,lr_abs.enddate
                                                          ,replace(nvl(lr_abs.time_start,l_start_time_char),':','.')
                                                          ,replace(nvl(lr_abs.time_end,l_end_time_char),':','.')
                                                          ,l_each_absence
                                                          );
               --logger ('l_each_absence_days  @@@@@@@@@@@@@@@@@@@@@@ '                      ,l_each_absence                      );
               l_total_absence_days := l_each_absence + l_total_absence_days;
            END LOOP;

--    logger('FOR MONTH  * '||to_char(l_temp_date,'MON')||'    l_total_absence_days  ',l_total_absence_days);
--    logger('FOR MONTH  * '||to_char(l_temp_date,'MON')||'    l_total_working       ',l_DAYS_WTH_PUBLIC-l_total_absence_days);

-- *****************************************************************************
-- DAYS OVER
-- FIND FOR WHOLE MONTH IN HOURS
-- *****************************************************************************
            l_return :=
               hr_loc_work_schedule.calc_sch_based_dur (g_assignment_id
                                                       ,'H'
                                                       ,'Y'
                                                       ,l_month_start
                                                       ,l_month_end
                                                       ,NULL
                                                       ,NULL
                                                       ,l_hours_wth_public
                                                       );
-- logger('l_HOURS_WTH_PUBLIC $$$$$$$$$$$$$$$$$$$$$$ ',l_HOURS_WTH_PUBLIC);
            l_total_absence_hours := 0;
            l_each_absence := 0;

-- *****************************************************************************
   -- FIND FOR THIS MONTH  FOR ALL ABSENCES IN HOURS
-- *****************************************************************************
            FOR lr_abs IN csr_absence_details (g_person_id
                                              ,l_month_start
                                              ,l_month_end
                                              )
            LOOP
               --logger ('lr_abs.STARTDATE ', lr_abs.startdate);
               --logger ('lr_abs.ENDDATE   ', lr_abs.enddate);
               l_return :=
                  hr_loc_work_schedule.calc_sch_based_dur (g_assignment_id
                                                          ,'H'
                                                          ,'Y'
                                                          ,lr_abs.startdate
                                                          ,lr_abs.enddate
                                                          ,replace(nvl(lr_abs.time_start,l_start_time_char),':','.')
                                                          ,replace(nvl(lr_abs.time_end,l_end_time_char),':','.')
                                                          ,l_each_absence
                                                          );
               --logger ('l_each_absence_hours   @@@@@@@@@@@@@@@@@@@@@@ '                      ,l_each_absence                      );
               l_total_absence_hours := l_each_absence + l_total_absence_hours;
            END LOOP;

--    logger('FOR MONTH  * '||to_char(l_temp_date,'MON')||'    l_total_absence_hours  ',l_total_absence_hours);
--    logger('FOR MONTH  * '||to_char(l_temp_date,'MON')||'    l_total_working       ',l_HOURS_WTH_PUBLIC-l_total_absence_hours);

            -- *****************************************************************************
-- *****************************************************************************
-- RESET COUNTER FOR THE YEAR
-- *****************************************************************************
            l_currentyear := TO_CHAR (l_month_start, 'YYYY');

            IF l_currentyear <> l_previousyear
            THEN
               l_count_year := l_count_year + 1;
               l_previousyear := l_currentyear;
            END IF;

            --logger ('l_count_year     ******l_count_year******    '                   ,l_count_year                   );
-- *****************************************************************************
-- DISPLAY ALL VALUES and STORE IN RECORD
-- *****************************************************************************
            l_currentmonth := TO_CHAR (l_temp_date, 'MM');
            --logger ('l_DAYS_WTH_PUBLIC $$$$$$$$$$$$$$$$$$$$$$ '                   ,l_days_wth_public                   );
            --logger (   'FOR MONTH  * '                    || l_currentmonth                    || '    l_total_absence_days  '                   ,l_total_absence_days                   );
            --logger (   'FOR MONTH  * '                    || l_currentmonth                    || '    l_total_working_days  '                   , l_days_wth_public - l_total_absence_days                   );
            l_total_working_days := l_days_wth_public - l_total_absence_days;
            --logger ('l_HOURS_WTH_PUBLIC $$$$$$$$$$$$$$$$$$$$$$ '                   ,l_hours_wth_public                   );
            --logger (   'FOR MONTH  * '                    || l_currentmonth                    || '    l_total_absence_hours  '                   ,l_total_absence_hours                   );
            --logger (   'FOR MONTH  * '                    || l_currentmonth                    || '    l_total_working_hours  '                   , l_hours_wth_public - l_total_absence_hours                   );
            l_total_working_hours :=
                                    l_hours_wth_public - l_total_absence_hours;
            value_month_year (l_count_year).YEAR := l_currentyear;
            value_month_year (l_count_year).each_month_days (l_currentmonth) :=
                                                          l_total_working_days;
            value_month_year (l_count_year).each_month_hours (l_currentmonth) :=
                                                         l_total_working_hours;


               l_dimension:='_ASG_LE_MONTH';   --EOY 2008
------------------------------------------------------

          pay_balance_pkg.set_context ('TAX_UNIT_ID', l_legal_employer_id);

          fnd_file.put_line (fnd_file.LOG, 'set Tax unit');

          pay_balance_pkg.set_context ('LOCAL_UNIT_ID', l_local_unit_id);


	   l_report_start_date := TO_DATE('01/'||l_currentmonth||'/'||l_currentyear,'DD/MM/YYYY');

           SELECT last_day(l_report_start_date)
			INTO l_reporting_date
			FROM DUAL;

	 -- fnd_file.put_line (fnd_file.LOG, 'l_reporting_date' ||l_reporting_date);

           l_overtime_hours :=0;
           l_tot_overtime_hours :=0;

	   BEGIN
           FOR     balance_rec IN  csr_balance('Overtime - Hours' , g_business_group_id)
	   LOOP
		OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
		FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
		CLOSE csr_bg_Get_Defined_Balance_Id;
		IF  csr_balance%FOUND THEN
			l_overtime_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
			l_tot_overtime_hours := l_tot_overtime_hours + nvl(l_overtime_hours,0);
		END IF;
	   END LOOP ;

           value_month_year(l_count_year).tot_overtime_hours(l_currentmonth) := l_tot_overtime_hours;

	   -- fnd_file.put_line (fnd_file.LOG, 'l_tot_overtime_hours - First' ||l_tot_overtime_hours);

           EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error for overtime First'||substr(sqlerrm,1,30));
		null;
	   END;





	  BEGIN
	   l_addl_time_hours :=0;
	   l_tot_addl_time_hours:=0;

	   FOR     balance_rec IN  csr_balance('Additional Time - Hours' , g_business_group_id)
	   LOOP

		OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
		FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
		CLOSE csr_bg_Get_Defined_Balance_Id;

		IF  csr_balance%FOUND THEN

			l_addl_time_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
			l_tot_addl_time_hours := l_tot_addl_time_hours + nvl(l_addl_time_hours,0);
		END IF;
	   END LOOP ;

	   value_month_year(l_count_year).tot_addl_time_hours(l_currentmonth) := l_tot_addl_time_hours ;

          -- fnd_file.put_line (fnd_file.LOG, 'l_tot_addl_time_hours - First' ||l_tot_addl_time_hours);

	   EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error'||substr(sqlerrm,1,30));
		null;
           END;


	   l_absence_hours :=0;
           l_tot_absence_hours :=0;
	   value_month_year(l_count_year).tot_absence_hours(l_currentmonth) := l_tot_absence_hours;
	   BEGIN
           FOR     balance_rec IN  csr_balance('UnPaid Absence - Hours' , g_business_group_id)
	   LOOP
		OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
		FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
		CLOSE csr_bg_Get_Defined_Balance_Id;
		IF  csr_balance%FOUND THEN
			l_absence_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
			l_tot_absence_hours := l_tot_absence_hours + nvl(l_absence_hours,0);
		END IF;
	   END LOOP ;
	   -- Bug#9272420 issue#5 fix starts
	   l_sick_pay_hours := get_defined_balance_value ('TOTAL_SICK_PAY_HOURS_ASG_LE_MONTH'
                                               ,g_assignment_id
                                               ,l_reporting_date
                                               ,l_legal_employer_id
                                               ,l_local_unit_id
                                               );
	  fnd_file.put_line (fnd_file.LOG, '$$$ l_sick_pay_hours ' ||l_sick_pay_hours);
	  l_waiting_hours := get_defined_balance_value ('TOTAL_WAITING_HOURS_ASG_RUN'
                                               ,g_assignment_id
                                               ,l_reporting_date
                                               ,l_legal_employer_id
                                               ,l_local_unit_id
                                               );
	  fnd_file.put_line (fnd_file.LOG, '$$$ l_waitng_hours ' ||l_waiting_hours);

          l_tot_absence_hours := l_tot_absence_hours + nvl(l_sick_pay_hours,0)+ nvl(l_waiting_hours,0);
          -- Bug#9272420 issue#5 fix ends

           value_month_year(l_count_year).tot_absence_hours(l_currentmonth) := l_tot_absence_hours;

	 --   fnd_file.put_line (fnd_file.LOG, 'l_tot_absence_hours - First' ||l_tot_absence_hours);

           EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error for absence'||substr(sqlerrm,1,30));
		null;
	   END;


--------------------------------------------------
            l_all_sick_absence_days :=
                                l_all_sick_absence_days + l_total_absence_days;
            l_all_worked_hours := l_all_worked_hours + l_total_working_hours;

-- *****************************************************************************
-- MOVING THE START DATE BACK ONE MONTH
-- AS HOURS IS LESS THAN 70 HOURS
-- *****************************************************************************
            IF l_total_working_hours < 70
            THEN
               l_temp_end_date := ADD_MONTHS (l_temp_end_date, -1);
               --logger ('LESS THAN 70 HOURS  FOR THE MONTH  ' || l_currentmonth                      ,l_temp_end_date                      );
            ELSE
                l_count := l_count + 1;
            END IF;

-- *****************************************************************************

-- *****************************************************************************

            IF (   (TRUNC (l_start_assign_date, 'MM') =
                                                     TRUNC (l_temp_date, 'MM')
                   )
                OR (TRUNC (l_seven_year_end_date, 'MM') =
                                                     TRUNC (l_temp_date, 'MM')
                   )
                OR
                  ( l_count >= 12
                  )
               )
            THEN
               l_end_loop := 1;
         --logger ('Endign Loop for  ', l_end_loop);
         --logger ('TRUNC (l_temp_date, MM)  ', TRUNC (l_temp_date, 'MM'));
         --logger ('TRUNC (l_start_assign_date, MM)  ', TRUNC (l_start_assign_date, 'MM'));
         --logger ('TRUNC (l_seven_year_end_date, MM)', TRUNC (l_seven_year_end_date, 'MM'));

            END IF;

-- MOVING A MONTH BACK
            l_temp_date := ADD_MONTHS (l_temp_date, -1);
--            l_count := l_count + 1;
-- *********END*****************************************************************
         END IF;
      END LOOP;

-- *****************************************************************************
-- SET THE VALUE CALCULATED TO THESE VARIABLES
-- AS IN THE EIT USER NOT ENTERED THE VALUES MANUALLY
--
-- *****************************************************************************
      IF l_total_worked_hours IS NULL
      THEN
         l_total_worked_hours := l_all_worked_hours;
      END IF;
/*-- use balance to get the paid sick leaves
      IF l_paid_sick_leave_days IS NULL
      THEN
         l_paid_sick_leave_days := l_all_sick_absence_days;
      END IF;
*/
-- *****************************************************************************
-- *****************************************************************************
-- *****************************************************************************
      FOR i IN value_month_year.FIRST .. value_month_year.LAST
      LOOP
         --logger ('value_month_year    ', value_month_year (i).YEAR);
--      logger('value_month_year    ' ,value_month_year(i).year ) ;
         --logger ('  FIRST MONTH   '                ,value_month_year (i).each_month_days.FIRST                );
         --logger ('  LAST  MONTH   '                ,value_month_year (i).each_month_days.LAST);
         --logger ('MONTH' || '   DAYS', 'HOURS');
         l_temp_counter := value_month_year (i).each_month_days.FIRST;

         FOR i_i IN 01 .. 12
         LOOP
            IF value_month_year (i).each_month_days.EXISTS (i_i) = FALSE
            THEN
               value_month_year (i).each_month_days (i_i) := NULL;
               value_month_year (i).each_month_hours (i_i) := NULL;
	       value_month_year (i).tot_addl_time_hours(i_i) := NULL;
	       value_month_year (i).tot_overtime_hours(i_i) := NULL;
	       value_month_year (i).tot_absence_hours(i_i)  := NULL;
            END IF;
         END LOOP;

         WHILE l_temp_counter IS NOT NULL
         LOOP
            --logger (   l_temp_counter                    || '        '                    || value_month_year (i).each_month_days (l_temp_counter)                   ,value_month_year (i).each_month_hours (l_temp_counter)                   );
--logger( 'DAYS  MONTH '||l_TEMP_COUNTER ,to_char(value_month_year(i).EACH_MONTH_DAYS(l_TEMP_COUNTER) )) ;
--logger( 'HOURS MONTH '||l_TEMP_COUNTER ,to_char(value_month_year(i).EACH_MONTH_HOURS(l_TEMP_COUNTER) )) ;
            l_temp_counter :=
                    value_month_year (i).each_month_days.NEXT (l_temp_counter);
	   END LOOP;
/*
        FOR l_test IN value_month_year(i).EACH_MONTH_DAYS.first .. value_month_year(i).EACH_MONTH_DAYS.LAST
        LOOP
              logger('value_month_year  MONTH   ' ,value_month_year(i).EACH_MONTH_DAYS(l_test) ) ;
              l_test := value_month_year(i).EACH_MONTH_DAYS.next(l_test);
        END LOOP;
*/
      END LOOP;

-- *****************************************************************************
-- WORKING TIME
/*
IF lr_assignment_info.EMPLOYMENT_CATEGORY in ('FR','FT','SE_FS')
THEN
    l_assign_full_time := lr_assignment_info.EMPLOYMENT_CATEGORY ;
ELSE
    l_assign_full_time := NULL;
END IF;

IF lr_assignment_info.EMPLOYMENT_CATEGORY in ('PR','PT','SE_PS')
THEN
    l_assign_part_time := lr_assignment_info.EMPLOYMENT_CATEGORY ;
ELSE
    l_assign_part_time := NULL;
END IF;
*/
      l_assign_hours_week := lr_assignment_info.normal_hours;
      l_assign_frequency := lr_assignment_info.frequency;
      l_assign_various_work_time :=
                            check_nvl2 (l_assign_working_percentage, 'Y', 'N');

      IF l_assign_working_percentage = 100 and l_assign_hours_week IS NOT NULL
      THEN
         l_assign_full_time := 'Y';
         l_assign_part_time := 'N';
         l_assign_various_work_time := 'N';
      ELSIF (    l_assign_working_percentage >= 0
             AND l_assign_working_percentage < 100
            ) and l_assign_hours_week IS NOT NULL
      THEN
         l_assign_full_time := 'N';
         l_assign_part_time := 'Y';
         l_assign_various_work_time := 'N';
      ELSIF l_assign_hours_week IS NULL
      THEN
         l_assign_full_time := 'N';
         l_assign_part_time := 'N';
         l_assign_various_work_time := 'Y';
      END IF;

      IF l_assign_frequency = 'M'
      THEN
         l_assign_hours_week := ((l_assign_hours_week * 12) / 52);
      END IF;

-- At present the variable of intermittent employee is not used
-- The check in the template is on the form of employment.
-- Any employee who is not a full-time or part-time and dont have hours/week
-- is an intermittent employee.

     IF l_assign_various_work_time = 'Y'
     THEN
     l_intermittent_employee := 'Y';
     l_form_of_employment := 'INTMT';
     ELSE
     l_intermittent_employee := 'N';
     END IF;

      --logger ('l_assign_full_time', l_assign_full_time);
      --logger ('l_assign_part_time', l_assign_part_time);
      --logger ('l_assign_hours_week', l_assign_hours_week);
      --logger ('l_assign_FREQUENCY', l_assign_frequency);
      --logger ('l_assign_various_work_time', l_assign_various_work_time);

-- Code to populate the End Date of Probationary and Time- Limited Employment EOY 2008



   l_employment_end_date := lr_assign_status.effective_end_date;


   --logger ('l_employment_end_date', l_employment_end_date);




-- *****************************************************************************
-- Income salry section
      l_salary_year := g_income_salary_year;
      l_assign_salary_paid_out := lr_assignment_info.hourly_salaried_code;
--     l_salary_amount := 1000;
-- *****************************************************************************
-- *****************************************************************************
      --logger ('lr_get_assign_min_start_date.MIN_DATE'             ,lr_get_assign_min_start_date.min_date             );

      IF g_income_salary_year >=
                       TO_CHAR (lr_get_assign_min_start_date.min_date, 'YYYY')
      THEN
         l_start_date_for_salary :=
            GREATEST (TO_DATE ('01-01-' || g_income_salary_year, 'DD-MM-YYYY')
                     ,lr_get_assign_min_start_date.min_date
                     );
         l_end_date_for_salary :=
            LEAST (TO_DATE ('31-12-' || g_income_salary_year, 'DD-MM-YYYY')
                  ,l_report_effective_date
                  );
--l_start_date_for_salary := trunc(l_end_date_for_salary,'YYYY');
         --logger ('*********************', '*********************');
         --logger ('l_start_date_for_salary', l_start_date_for_salary);
         --logger ('l_end_date_for_salary', l_end_date_for_salary);
         --logger ('*********************', '*********************');
--l_get_defined_balance_id := get_defined_balance_id('GROSS_PAY_ASG_LE_YTD');
--LOGGER('l_get_defined_balance_id',l_get_defined_balance_id);
--l_temp_date := l_start_date_for_salary;
         l_annual_salary :=
            TO_CHAR (get_defined_balance_value ('GROSS_PAY_ASG_LE_YTD'
                                               ,g_assignment_id
                                               ,l_end_date_for_salary
                                               ,l_legal_employer_id
                                               ,l_local_unit_id
                                               )
                    ,'999999999D99'
                    );
         --logger ('l_annual_salary', l_annual_salary);

      IF l_paid_sick_leave_days IS NULL
      THEN
     l_paid_sick_leave_days := TO_CHAR (get_defined_balance_value ('TOTAL_SICK_PAY_DAYS_1_TO_14_DAYS_ASG_LE_YTD'
                                               ,g_assignment_id
                                               ,l_end_date_for_salary
                                               ,l_legal_employer_id
                                               ,l_local_unit_id
                                               )
                    ,'999999999D99'
                    );
         --logger ('In Null l_paid_sick_leave_days', l_paid_sick_leave_days);
      END IF;

/*
WHILE l_temp_date <> l_end_date_for_salary
LOOP
LOGGER('l_temp_date',l_temp_date);
l_get_salary_date := least(last_day(l_temp_date),l_end_date_for_salary);
LOGGER('l_get_salary_date',l_get_salary_date);
l_temp_date := LEAST(add_months(l_temp_date,1),l_end_date_for_salary);
END LOOP;
*/
         l_salary_year_hours := 0;

-- *****************************************************************************
         IF l_assign_salary_paid_out = 'S' OR l_assign_salary_paid_out IS NULL
         THEN
            --logger ('*********************', '*********************');
            l_month_between_salary_year :=
                 TO_CHAR (l_end_date_for_salary, 'MM')
               - TO_CHAR (l_start_date_for_salary, 'MM')
               + 1;
            --logger ('l_month_between_salary_year'                   ,l_month_between_salary_year);

            IF l_annual_salary <> 0
            THEN
               l_salary_amount :=
                                l_annual_salary / l_month_between_salary_year;
            END IF;
         ELSIF l_assign_salary_paid_out = 'H'
         THEN
            --logger ('*********************', '*********************');
            l_temp_date := TRUNC (l_start_date_for_salary, 'MM');
            l_curr_month_start := l_start_date_for_salary;
            l_curr_month_end := l_start_date_for_salary;

            WHILE l_curr_month_end <> l_end_date_for_salary
            LOOP
               --logger ('l_temp_date', l_temp_date);
               l_curr_month_start :=
                      GREATEST (TRUNC (l_temp_date), l_start_date_for_salary);
               l_curr_month_end :=
                        LEAST (LAST_DAY (l_temp_date), l_end_date_for_salary);
               --logger ('l_curr_month_start', l_curr_month_start);
               --logger ('l_curr_month_end', l_curr_month_end);
-- *****************************************************************************
-- FIND FOR WHOLE MONTH IN HOURS
-- *****************************************************************************
               l_return :=
                  hr_loc_work_schedule.calc_sch_based_dur
                                                         (g_assignment_id
                                                         ,'H'
                                                         ,'Y'
                                                         ,l_curr_month_start
                                                         ,l_curr_month_end
                                                         ,NULL
                                                         ,NULL
                                                         ,l_hours_wth_public
                                                         );
               --logger ('l_HOURS_WTH_PUBLIC $$$$$$$$$$$$$$$$$$$$$$ '                      ,l_hours_wth_public                      );
               l_salary_year_hours := l_salary_year_hours + l_hours_wth_public;
-- l_total_absence_hours := 0;
               l_each_absence := 0;

-- *****************************************************************************
   -- FIND FOR THIS MONTH  FOR ALL ABSENCES IN HOURS
-- *****************************************************************************
               FOR lr_abs IN csr_absence_details (g_person_id
                                                 ,l_curr_month_start
                                                 ,l_curr_month_end
                                                 )
               LOOP
                  --logger ('lr_abs.STARTDATE ', lr_abs.startdate);
                  --logger ('lr_abs.ENDDATE   ', lr_abs.enddate);
                  l_return :=
                     hr_loc_work_schedule.calc_sch_based_dur
                                                          (g_assignment_id
                                                          ,'H'
                                                          ,'Y'
                                                          ,lr_abs.startdate
                                                          ,lr_abs.enddate
                                                          ,replace(nvl(lr_abs.time_start,l_start_time_char),':','.')
                                                          ,replace(nvl(lr_abs.time_end,l_end_time_char),':','.')
                                                          ,l_each_absence
                                                          );
                  --logger ('l_each_absence_hours   @@@@@@@@@@@@@@@@@@@@@@ '                         ,l_each_absence                         );
                  l_total_absence_hours :=
                                        l_each_absence + l_total_absence_hours;
               END LOOP;

-- *****************************************************************************
-- *****************************************************************************
               l_temp_date := ADD_MONTHS (l_temp_date, 1);
            END LOOP;

            --logger ('l_total_absence_hours   *********** '                   ,l_total_absence_hours                   );
            --logger ('l_salary_year_hours   *********** ', l_salary_year_hours);
            l_salary_year_hours_worked :=
                                   l_salary_year_hours - l_total_absence_hours;

-- *****************************************************************************
-- got teh Hours absence and Total Hours to be worked
-- subtract , will get teh total worked hours
-- divide the annual salary by this hours
-- *****************************************************************************
            IF l_annual_salary <> 0 AND l_salary_year_hours_worked <> 0
            THEN
               l_salary_amount :=
                                 l_annual_salary / l_salary_year_hours_worked;
            END IF;
-- *****************************************************************************
         END IF;
-- *****************************************************************************
      END IF;

      --logger ('l_salary_year', l_salary_year);
      --logger ('l_assign_salary_paid_out', l_assign_salary_paid_out);
      --logger ('l_salary_amount', l_salary_amount);
      lr_extra_assignment_info := NULL;

      OPEN csr_extra_assignment_info (g_assignment_id, 'SE_WTC_INCOME_INFO');

      FETCH csr_extra_assignment_info
       INTO lr_extra_assignment_info;

      CLOSE csr_extra_assignment_info;

      l_school_holiday_pay_amount := lr_extra_assignment_info.aei_information1;
      l_school_holiday_pay_box :=
              check_nvl2 (lr_extra_assignment_info.aei_information1, 'Y', 'N');
      l_no_of_paid_holiday_days := lr_extra_assignment_info.aei_information2;
      l_emp_with_holiday_pay :=
              check_nvl2 (lr_extra_assignment_info.aei_information2, 'Y', 'N');
      l_paid_days_off_duty_time := lr_extra_assignment_info.aei_information3;
      l_employed_educational_assoc :=
              check_nvl2 (lr_extra_assignment_info.aei_information3, 'Y', 'N');
      l_holiday_duty := lr_extra_assignment_info.aei_information4;
      l_lay_off_period_paid_days := lr_extra_assignment_info.aei_information5;
      l_holiday_laid_off :=
              check_nvl2 (lr_extra_assignment_info.aei_information5, 'Y', 'N');
      l_lay_off_from := lr_extra_assignment_info.aei_information6;
      l_lay_off_to := lr_extra_assignment_info.aei_information7;
      l_other_information := lr_extra_assignment_info.aei_information8;


 ----- The variables below are added w.r.t EOY changes 2008

      l_hourly_pay_variable := lr_extra_assignment_info.aei_information9;
      l_hourly_overtime_rate := lr_extra_assignment_info.aei_information10;
      l_hourly_addl_suppl_time := lr_extra_assignment_info.aei_information11;
      l_other_taxable_compensation := lr_extra_assignment_info.aei_information12;
      l_holiday_pay_amount := lr_extra_assignment_info.aei_information13;

      --logger ('l_School_Holiday_Pay_Amount', l_school_holiday_pay_amount);
      --logger ('l_School_Holiday_Pay_box', l_school_holiday_pay_box);
      --logger ('l_emp_with_holiday_pay', l_emp_with_holiday_pay);
      --logger ('l_no_of_paid_holiday_days', l_no_of_paid_holiday_days);
      --logger ('l_Paid_Days_Off_Duty_Time', l_paid_days_off_duty_time);
      --logger ('l_employed_educational_assoc', l_employed_educational_assoc);
      --logger ('l_Holiday_Duty', l_holiday_duty);
      --logger ('l_Lay_Off_Period_Paid_Days', l_lay_off_period_paid_days);
      --logger ('l_holiday_laid_off', l_holiday_laid_off);
      --logger ('l_Lay_Off_From', l_lay_off_from);
      --logger ('l_Lay_Off_To', l_lay_off_to);
      --logger ('l_Other_Information', l_other_information);
      --logger ('l_hourly_pay_variable', l_hourly_pay_variable);
      --logger ('l_hourly_overtime_rate', l_hourly_overtime_rate);
      --logger ('l_hourly_addl_suppl_time', l_hourly_addl_suppl_time);
      --logger ('l_other_taxable_compensation', l_other_taxable_compensation);
      --logger ('l_holiday_pay_amountt', l_holiday_pay_amount);

-- *****************************************************************************
-- EMployer and Signs

    --fnd_file.put_line (fnd_file.LOG, 'l_local_unit_id'||l_local_unit_id);
    --fnd_file.put_line (fnd_file.LOG, 'l_legal_employer_id'||l_legal_employer_id);

      OPEN csr_contact_details (l_legal_employer_id);

      FETCH csr_contact_details
       INTO lr_contact_details;

      CLOSE csr_contact_details;


      l_phone_number := lr_contact_details.org_information3;
      --logger ('l_phone_number', l_phone_number);
      --fnd_file.put_line (fnd_file.LOG, 'l_phone_number'||l_phone_number);

      OPEN csr_address_details (l_location_id);

      FETCH csr_address_details
       INTO lr_address_details;

      CLOSE csr_address_details;

      l_location_code := lr_address_details.location_code;
      l_address_line_1 := lr_address_details.address_line_1;
      l_address_line_2 := lr_address_details.address_line_2;
      l_address_line_3 := lr_address_details.address_line_3;
      l_postal_code := lr_address_details.postal_code;
      -- Bug#8849455 fix Added space between 3 and 4 digits in postal code
      l_postal_code := substr(l_postal_code,1,3)||' '||substr(l_postal_code,4,2);
      l_town_or_city := lr_address_details.town_or_city;
      l_region_1 := lr_address_details.region_1;
      l_region_2 := lr_address_details.region_2;
      l_territory_short_name := lr_address_details.territory_short_name;
      --logger ('l_location_code', l_location_code);
      --logger ('l_address_line_1', l_address_line_1);
      --logger ('l_address_line_2', l_address_line_2);
      --logger ('l_address_line_3', l_address_line_3);
      --logger ('l_postal_code', l_postal_code);
      --logger ('l_TOWN_OR_CITY', l_town_or_city);
      --logger ('l_REGION_1', l_region_1);
      --logger ('l_REGION_2', l_region_2);
      --logger ('l_TERRITORY_SHORT_NAME', l_territory_short_name);
-- *****************************************************************************
 -- *****************************************************************************
 -- *****************************************************************************

      -- Insert the report Parameters
      pay_action_information_api.create_action_information
                      (p_action_information_id            => l_action_info_id
                      ,p_action_context_id                => p_payroll_action_id
                      ,p_action_context_type              => 'PA'
                      ,p_object_version_number            => l_ovn
                      ,p_effective_date                   => g_effective_date
                      ,p_source_id                        => NULL
                      ,p_source_text                      => NULL
                      ,p_action_information_category      => 'EMEA REPORT DETAILS'
                      ,p_action_information1              => 'PYSEWTCA'
                      ,p_action_information2              => g_person_id
                      ,p_action_information3              => g_assignment_id
                      ,p_action_information4              => g_still_employed
                      ,p_action_information5              => g_business_group_id
                      ,p_action_information6              => NULL
                      ,p_action_information7              => NULL
                      ,p_action_information8              => NULL
                      ,p_action_information9              => NULL
                      ,p_action_information10             => NULL
                      );
      pay_action_information_api.create_action_information
           (p_action_information_id            => l_action_info_id
           ,p_action_context_id                => p_payroll_action_id
           ,p_action_context_type              => 'PA'
           ,p_object_version_number            => l_ovn
           ,p_effective_date                   => g_effective_date
           ,p_source_id                        => NULL
           ,p_source_text                      => NULL
           ,p_action_information_category      => 'EMEA REPORT INFORMATION'
           ,p_action_information1              => 'PYSEWTCA'
           ,p_action_information2              => 'WTC_PERSON1'
           ,p_action_information3              => l_person_number
           ,p_action_information4              => l_last_name
           ,p_action_information5              => l_first_name
           ,p_action_information6              => fnd_date.date_to_canonical
                                                                 (l_hired_from)
           ,p_action_information7              => fnd_date.date_to_canonical
                                                                   (l_hired_to)
           ,p_action_information8              => l_still_employed
           ,p_action_information9              => l_absence_from
           ,p_action_information10             => l_absence_to
           ,p_action_information11             => l_form_of_employment
           ,p_action_information12             => l_work_tasks
           ,p_action_information13             => l_emp_at_temp_agency
           ,p_action_information14             => l_emp_temp_work
           ,p_action_information15             => l_reason
           ,p_action_information16             => l_notification_date
           ,p_action_information17             => l_ending_assignment_by
           ,p_action_information18             => l_termination_reason  --EOY 2008
           ,p_action_information19             => l_absence_percentage  --EOY 2008
           ,p_action_information20             => l_employment_end_date --EOY 2008
           ,p_action_information21             => NULL
           ,p_action_information22             => NULL
           ,p_action_information23             => NULL
           ,p_action_information24             => NULL
           ,p_action_information25             => NULL
           ,p_action_information26             => NULL
           ,p_action_information27             => NULL
           ,p_action_information28             => NULL
           ,p_action_information29             => NULL
           ,p_action_information30             => g_person_id
           ,p_assignment_id                    => g_assignment_id
           );
      pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                  ,p_action_context_id                => p_payroll_action_id
                  ,p_action_context_type              => 'PA'
                  ,p_object_version_number            => l_ovn
                  ,p_effective_date                   => g_effective_date
                  ,p_source_id                        => NULL
                  ,p_source_text                      => NULL
                  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
                  ,p_action_information1              => 'PYSEWTCA'
                  ,p_action_information2              => 'WTC_PERSON2'
                  ,p_action_information3              => l_continuous_offer
                  ,p_action_information4              => l_permanent_check_box
                  ,p_action_information5              => l_permanent_date_from
                  --fnd_date.date_to_canonical(l_permanent_date)
      ,            p_action_information6              => l_time_limited_check_box
                  ,p_action_information7              => l_time_limited_from
                  --fnd_date.date_to_canonical(l_time_limited_from)
      ,            p_action_information8              => l_time_limited_to
                  --fnd_date.date_to_canonical(l_time_limited_to)
      ,            p_action_information9              => l_other_check_box
                  ,p_action_information10             => l_other
                  ,p_action_information11             => l_full_time_check_box
                  ,p_action_information12             => l_full_time
                  ,p_action_information13             => l_part_time_check_box
                  ,p_action_information14             => l_part_time
                  ,p_action_information15             => l_working_percentage
                  ,p_action_information16             => l_various_working_time
                  ,p_action_information17             => l_offer_accepted
                  ,p_action_information18             => l_decline_date
                  --fnd_date.date_to_canonical(l_decline_date)
      ,            p_action_information19             => l_time_worked_from
                  --fnd_date.date_to_canonical (l_time_worked_from)
      ,            p_action_information20             => l_time_worked_to
                  --fnd_date.date_to_canonical (l_time_worked_to)
      ,            p_action_information21             => l_total_worked_hours
                  ,p_action_information22             => l_paid_sick_leave_days
                  ,p_action_information23             => l_teaching_load
                  ,p_action_information24             => l_aggrmnt_of_compn_signed  -- EOY 2008
                  ,p_action_information25             => l_permanent_date_to        -- EOY 2008
                  ,p_action_information26             => l_teaching_load_check_box  -- EOY 2008
                  ,p_action_information27             => NULL
                  ,p_action_information28             => NULL
                  ,p_action_information29             => NULL
                  ,p_action_information30             => g_person_id
                  ,p_assignment_id                    => g_assignment_id
                  );
      pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                  ,p_action_context_id                => p_payroll_action_id
                  ,p_action_context_type              => 'PA'
                  ,p_object_version_number            => l_ovn
                  ,p_effective_date                   => g_effective_date
                  ,p_source_id                        => NULL
                  ,p_source_text                      => NULL
                  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
                  ,p_action_information1              => 'PYSEWTCA'
                  ,p_action_information2              => 'WTC_PERSON3'
                  ,p_action_information3              => l_assign_full_time
                  ,p_action_information4              => l_assign_hours_week
                  ,p_action_information5              => l_assign_frequency
                  ,p_action_information6              => l_assign_part_time
                  ,p_action_information7              => l_assign_working_percentage
                  ,p_action_information8              => l_assign_various_work_time
                  ,p_action_information9              => l_salary_year
                  ,p_action_information10             => l_assign_salary_paid_out
                  ,p_action_information11             => l_salary_amount
                  ,p_action_information12             => l_school_holiday_pay_amount
                  ,p_action_information13             => l_school_holiday_pay_box
                  ,p_action_information14             => l_no_of_paid_holiday_days
                  ,p_action_information15             => l_emp_with_holiday_pay
                  ,p_action_information16             => l_paid_days_off_duty_time
                  ,p_action_information17             => l_employed_educational_assoc
                  ,p_action_information18             => l_holiday_pay_amount           -- EOY 2008
                  ,p_action_information19             => NULL
                  ,p_action_information20             => NULL
                  ,p_action_information21             => NULL
                  ,p_action_information22             => NULL
                  ,p_action_information23             => NULL
                  ,p_action_information24             => NULL
                  ,p_action_information25             => NULL
                  ,p_action_information26             => NULL
                  ,p_action_information27             => NULL
                  ,p_action_information28             => NULL
                  ,p_action_information29             => NULL
                  ,p_action_information30             => g_person_id
                  ,p_assignment_id                    => g_assignment_id
                  );
      pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                  ,p_action_context_id                => p_payroll_action_id
                  ,p_action_context_type              => 'PA'
                  ,p_object_version_number            => l_ovn
                  ,p_effective_date                   => g_effective_date
                  ,p_source_id                        => NULL
                  ,p_source_text                      => NULL
                  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
                  ,p_action_information1              => 'PYSEWTCA'
                  ,p_action_information2              => 'WTC_PERSON4'
                  ,p_action_information3              => l_holiday_duty
                  ,p_action_information4              => l_lay_off_period_paid_days
                  ,p_action_information5              => l_holiday_laid_off
                  ,p_action_information6              => l_lay_off_from
                  ,p_action_information7              => l_lay_off_to
                  ,p_action_information8              => l_other_information
                  ,p_action_information9              => l_legal_employer_name
                  ,p_action_information10             => l_org_number
                  ,p_action_information11             => l_phone_number
                  ,p_action_information12             => l_location_code
                  ,p_action_information13             => l_address_line_1
                  ,p_action_information14             => l_address_line_2
                  ,p_action_information15             => l_address_line_3
                  ,p_action_information16             => l_postal_code
                  ,p_action_information17             => l_town_or_city
                  ,p_action_information18             => l_region_1
                  ,p_action_information19             => l_region_2
                  ,p_action_information20             => l_territory_short_name
                  ,p_action_information21             => l_hourly_pay_variable         -- EOY 2008
                  ,p_action_information22             => l_hourly_overtime_rate        -- EOY 2008
                  ,p_action_information23             => l_hourly_addl_suppl_time       -- EOY 2008
                  ,p_action_information24             => l_other_taxable_compensation    --EOY 2008
                  ,p_action_information25             => NULL
                  ,p_action_information26             => NULL
                  ,p_action_information27             => NULL
                  ,p_action_information28             => NULL
                  ,p_action_information29             => NULL
                  ,p_action_information30             => g_person_id
                  ,p_assignment_id                    => g_assignment_id
                  );
      l_set := 0;

      FOR i IN value_month_year.FIRST .. value_month_year.LAST
      LOOP
         --logger ('value_month_year    ', value_month_year (i).YEAR);
         ----logger ('  1 MONTH   ', value_month_year (i).each_month_days ('01'));
         --logger ('  2  MONTH   '                ,value_month_year (i).each_month_days ('02'));
         --logger ('  3  MONTH   '                ,value_month_year (i).each_month_days ('03'));
         --logger ('  4  MONTH   '                ,value_month_year (i).each_month_days ('04'));
         --logger ('  5  MONTH   '                ,value_month_year (i).each_month_days ('05'));
         --logger ('  6  MONTH   '                ,value_month_year (i).each_month_days ('06'));
         --logger ('  7  MONTH   '                ,value_month_year (i).each_month_days ('07'));
         --logger ('  8  MONTH   '                ,value_month_year (i).each_month_days ('08'));
         --logger ('  9  MONTH   '                ,value_month_year (i).each_month_days ('09'));
         --logger ('  10  MONTH   '               ,value_month_year (i).each_month_days ('10')   );
         --logger ('  11  MONTH   '                ,value_month_year (i).each_month_days ('11'));
         --logger ('  12  MONTH   '                ,value_month_year (i).each_month_days ('12'));
         --logger ('  value in eit  for ', value_month_year (i).YEAR);


         FOR lr_se_wtc_time_worked_info IN
            csr_se_wtc_time_worked_info (g_assignment_id
                                        ,value_month_year (i).YEAR
                                        )
         LOOP
            --logger ('  Year ', lr_se_wtc_time_worked_info.aei_information1);
            --logger ('  MONT ', lr_se_wtc_time_worked_info.aei_information2);
            --logger ('  DAYS ', lr_se_wtc_time_worked_info.aei_information3);
            ----logger ('  HOUR ', lr_se_wtc_time_worked_info.aei_information4);
            --logger               ('  value in PLtable was '               ,value_month_year (i).each_month_days                                  (lr_se_wtc_time_worked_info.aei_information2)               );
            value_month_year (i).each_month_days
                                  (lr_se_wtc_time_worked_info.aei_information2) :=
                                   lr_se_wtc_time_worked_info.aei_information3;



            --logger               ('  value in PLtable IS '               ,value_month_year (i).each_month_days                                  (lr_se_wtc_time_worked_info.aei_information2)               );
            --logger               ('  value in PLtable was '               ,value_month_year (i).each_month_hours                                  (lr_se_wtc_time_worked_info.aei_information2)               );
            value_month_year (i).each_month_hours
                                  (lr_se_wtc_time_worked_info.aei_information2) :=
                                   lr_se_wtc_time_worked_info.aei_information4;
            --logger               ('  value in PLtable IS '               ,value_month_year (i).each_month_hours                                  (lr_se_wtc_time_worked_info.aei_information2)               );



---------------------------------------------------------------------------------------------------------------------
--Added the code for the Overtime and the Addl/Suppl Time Hours -- EOY 2008
-------------------------------------------------------------------------------------------------------------------



	   l_report_start_date := TO_DATE('01/'||lr_se_wtc_time_worked_info.aei_information2||'/'||lr_se_wtc_time_worked_info.aei_information1,'DD/MM/YYYY');

           SELECT last_day(l_report_start_date)
			INTO l_reporting_date
			FROM DUAL;

          fnd_file.put_line (fnd_file.LOG, 'l_reporting_date'||l_reporting_date);

	   l_overtime_hours :=0;
           l_tot_overtime_hours :=0;
	   value_month_year(i).tot_overtime_hours(lr_se_wtc_time_worked_info.aei_information2) := l_tot_overtime_hours;
	   BEGIN
           FOR     balance_rec IN  csr_balance('Overtime - Hours' , g_business_group_id)
	   LOOP
		OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
		FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
		CLOSE csr_bg_Get_Defined_Balance_Id;
		IF  csr_balance%FOUND THEN
			l_overtime_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
			l_tot_overtime_hours := l_tot_overtime_hours + nvl(l_overtime_hours,0);
		END IF;
	   END LOOP ;

           value_month_year(i).tot_overtime_hours(lr_se_wtc_time_worked_info.aei_information2) := l_tot_overtime_hours;

	--    fnd_file.put_line (fnd_file.LOG, 'l_tot_overtime_hours' ||l_tot_overtime_hours);

           EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error for overtime'||substr(sqlerrm,1,30));
		null;
	   END;



	   BEGIN
	   l_addl_time_hours :=0;
	   l_tot_addl_time_hours:=0;
	   value_month_year(i).tot_addl_time_hours(lr_se_wtc_time_worked_info.aei_information2) := l_tot_addl_time_hours ;
	   FOR     balance_rec IN  csr_balance('Additional Time - Hours' , g_business_group_id)
	   LOOP

		OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
		FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
		CLOSE csr_bg_Get_Defined_Balance_Id;

		IF  csr_balance%FOUND THEN

			l_addl_time_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
			l_tot_addl_time_hours := l_tot_addl_time_hours + nvl(l_addl_time_hours,0);
		END IF;
	   END LOOP ;

	   value_month_year(i).tot_addl_time_hours(lr_se_wtc_time_worked_info.aei_information2) := l_tot_addl_time_hours ;


	 --    fnd_file.put_line (fnd_file.LOG, 'l_tot_addl_time_hours' ||l_tot_addl_time_hours);
	   EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error'||substr(sqlerrm,1,30));
		null;
           END;


	   l_absence_hours :=0;
           l_tot_absence_hours :=0;
	   value_month_year(i).tot_absence_hours(lr_se_wtc_time_worked_info.aei_information2) := l_tot_absence_hours;
	   BEGIN
           FOR     balance_rec IN  csr_balance('UnPaid Absence - Hours' , g_business_group_id)
	   LOOP
		OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
		FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
		CLOSE csr_bg_Get_Defined_Balance_Id;
		IF  csr_balance%FOUND THEN
			l_absence_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
			l_tot_absence_hours := l_tot_absence_hours + nvl(l_absence_hours,0);
		END IF;
	   END LOOP ;
	   -- Bug#9272420 issue#5 fix
	   l_sick_pay_hours := get_defined_balance_value ('TOTAL_SICK_PAY_HOURS_ASG_LE_MONTH'
                                               ,g_assignment_id
                                               ,l_reporting_date
                                               ,l_legal_employer_id
                                               ,l_local_unit_id
                                               );
	   fnd_file.put_line (fnd_file.LOG, '$$$ l_sick_pay_hours ' ||l_sick_pay_hours);
	   l_waiting_hours := get_defined_balance_value ('TOTAL_WAITING_HOURS_ASG_RUN'
                                               ,g_assignment_id
                                               ,l_reporting_date
                                               ,l_legal_employer_id
                                               ,l_local_unit_id
                                               );
	  fnd_file.put_line (fnd_file.LOG, '$$$ l_waitng_hours ' ||l_waiting_hours);

          l_tot_absence_hours := l_tot_absence_hours + nvl(l_sick_pay_hours,0)+ nvl(l_waiting_hours,0);
	  -- Bug#9272420 issue#5 fix

           value_month_year(i).tot_absence_hours(lr_se_wtc_time_worked_info.aei_information2) := l_tot_absence_hours;

	--    fnd_file.put_line (fnd_file.LOG, 'l_tot_absence_hours' ||l_tot_absence_hours);

           EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error for absence'||substr(sqlerrm,1,30));
		null;
	   END;



--------------------------------------------------------------------------------------------------------------------

	 END LOOP;

         IF (MOD (i, 2) = 0)
         THEN
            l_set := l_set + 1;
         END IF;


         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_payroll_action_id
            ,p_action_context_type              => 'PA'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => g_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEWTCA'
            ,p_action_information2              => 'WTC_PERSON5'
            ,p_action_information3              => value_month_year (i).each_month_days
                                                                         ('01')
            ,p_action_information4              => value_month_year (i).each_month_days
                                                                         ('02')
            ,p_action_information5              => value_month_year (i).each_month_days
                                                                         ('03')
            ,p_action_information6              => value_month_year (i).each_month_days
                                                                         ('04')
            ,p_action_information7              => value_month_year (i).each_month_days
                                                                         ('05')
            ,p_action_information8              => value_month_year (i).each_month_days
                                                                         ('06')
            ,p_action_information9              => value_month_year (i).each_month_days
                                                                         ('07')
            ,p_action_information10             => value_month_year (i).each_month_days
                                                                         ('08')
            ,p_action_information11             => value_month_year (i).each_month_days
                                                                         ('09')
            ,p_action_information12             => value_month_year (i).each_month_days
                                                                         ('10')
            ,p_action_information13             => value_month_year (i).each_month_days
                                                                         ('11')
            ,p_action_information14             => value_month_year (i).each_month_days
                                                                         ('12')
            ,p_action_information15             => value_month_year (i).YEAR
            ,p_action_information16             => value_month_year (i).each_month_hours
                                                                         ('01')
            ,p_action_information17             => value_month_year (i).each_month_hours
                                                                         ('02')
            ,p_action_information18             => value_month_year (i).each_month_hours
                                                                         ('03')
            ,p_action_information19             => value_month_year (i).each_month_hours
                                                                         ('04')
            ,p_action_information20             => value_month_year (i).each_month_hours
                                                                         ('05')
            ,p_action_information21             => value_month_year (i).each_month_hours
                                                                         ('06')
            ,p_action_information22             => value_month_year (i).each_month_hours
                                                                         ('07')
            ,p_action_information23             => value_month_year (i).each_month_hours
                                                                         ('08')
            ,p_action_information24             => value_month_year (i).each_month_hours
                                                                         ('09')
            ,p_action_information25             => value_month_year (i).each_month_hours
                                                                         ('10')
            ,p_action_information26             => value_month_year (i).each_month_hours
                                                                         ('11')
            ,p_action_information27             => value_month_year (i).each_month_hours
                                                                         ('12')
            ,p_action_information28             => l_set
            ,p_action_information29             => NULL
            ,p_action_information30             => g_person_id
            ,p_assignment_id                    => g_assignment_id
            );



------------------------------ Archive for Addl/Suplementary Hrs and Overtime Hours --------------
            pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_payroll_action_id
            ,p_action_context_type              => 'PA'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => g_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEWTCA'
            ,p_action_information2              => 'WTC_PERSON6'
            ,p_action_information3              => value_month_year (i).tot_addl_time_hours('01')
            ,p_action_information4              => value_month_year (i).tot_addl_time_hours('02')

            ,p_action_information5              => value_month_year (i).tot_addl_time_hours('03')

            ,p_action_information6              => value_month_year (i).tot_addl_time_hours('04')

            ,p_action_information7              => value_month_year (i).tot_addl_time_hours('05')

            ,p_action_information8              => value_month_year (i).tot_addl_time_hours('06')

            ,p_action_information9              => value_month_year (i).tot_addl_time_hours('07')

            ,p_action_information10             => value_month_year (i).tot_addl_time_hours('08')

            ,p_action_information11             => value_month_year (i).tot_addl_time_hours('09')

            ,p_action_information12             => value_month_year (i).tot_addl_time_hours('10')

            ,p_action_information13             => value_month_year (i).tot_addl_time_hours('11')

            ,p_action_information14             => value_month_year (i).tot_addl_time_hours('12')

            ,p_action_information15             => value_month_year (i).YEAR
            ,p_action_information16             => value_month_year (i).tot_overtime_hours('01')

            ,p_action_information17             => value_month_year (i).tot_overtime_hours('02')

            ,p_action_information18             => value_month_year (i).tot_overtime_hours('03')

            ,p_action_information19             => value_month_year (i).tot_overtime_hours('04')

            ,p_action_information20             => value_month_year (i).tot_overtime_hours('05')

            ,p_action_information21             => value_month_year (i).tot_overtime_hours('06')

            ,p_action_information22             => value_month_year (i).tot_overtime_hours('07')

            ,p_action_information23             => value_month_year (i).tot_overtime_hours('08')

            ,p_action_information24             => value_month_year (i).tot_overtime_hours('09')

            ,p_action_information25             => value_month_year (i).tot_overtime_hours('10')

            ,p_action_information26             => value_month_year (i).tot_overtime_hours('11')

            ,p_action_information27             => value_month_year (i).tot_overtime_hours('12')

            ,p_action_information28             => l_set
            ,p_action_information29             => NULL
            ,p_action_information30             => g_person_id
            ,p_assignment_id                    => g_assignment_id
            );




---------------------- Populate Absence Fields ---------------------------------------------
	pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_payroll_action_id
            ,p_action_context_type              => 'PA'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => g_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEWTCA'
            ,p_action_information2              => 'WTC_PERSON7'
            ,p_action_information3              => value_month_year (i).tot_absence_hours('01')
            ,p_action_information4              => value_month_year (i).tot_absence_hours('02')

            ,p_action_information5              => value_month_year (i).tot_absence_hours('03')

            ,p_action_information6              => value_month_year (i).tot_absence_hours('04')

            ,p_action_information7              => value_month_year (i).tot_absence_hours('05')

            ,p_action_information8              => value_month_year (i).tot_absence_hours('06')

            ,p_action_information9              => value_month_year (i).tot_absence_hours('07')

            ,p_action_information10             => value_month_year (i).tot_absence_hours('08')

            ,p_action_information11             => value_month_year (i).tot_absence_hours('09')

            ,p_action_information12             => value_month_year (i).tot_absence_hours('10')

            ,p_action_information13             => value_month_year (i).tot_absence_hours('11')

            ,p_action_information14             => value_month_year (i).tot_absence_hours('12')

            ,p_action_information15             => value_month_year (i).YEAR
            ,p_action_information16             => NULL

            ,p_action_information17             => NULL

            ,p_action_information18             => NULL

            ,p_action_information19             => NULL

            ,p_action_information20             => NULL

            ,p_action_information21             => NULL

            ,p_action_information22             => NULL

            ,p_action_information23             => NULL

            ,p_action_information24             => NULL

            ,p_action_information25             => NULL

            ,p_action_information26             => NULL

            ,p_action_information27             => NULL

            ,p_action_information28             => l_set
            ,p_action_information29             => NULL
            ,p_action_information30             => g_person_id
            ,p_assignment_id                    => g_assignment_id
            );





      END LOOP;

-- *****************************************************************************
-- *****************************************************************************

      --END OF PICKING UP DATA
-- *****************************************************************************
      p_sql :=
            'SELECT DISTINCT person_id
         	FROM  per_people_f ppf
         	     ,pay_payroll_actions ppa
         	WHERE ppa.payroll_action_id = :payroll_action_id
         	AND   ppa.business_group_id = ppf.business_group_id
         	AND   ppf.person_id = '''
         || g_person_id
         || '''
         	ORDER BY ppf.person_id';

-- *****************************************************************************
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure RANGE_CODE', 50);
      END IF;
      EXCEPTION
		WHEN others THEN
		fnd_file.put_line (fnd_file.LOG, 'Error for archive'||substr(sqlerrm,1,30));
		null;
 /*  EXCEPTION
      WHEN OTHERS
      THEN
         -- Return cursor that selects no rows
         p_sql :=
               'select 1 from dual where to_char(:payroll_action_id) = dummy'; */
   END range_code;

   /* ASSIGNMENT ACTION CODE */
   PROCEDURE assignment_action_code (
      p_payroll_action_id        IN       NUMBER
     ,p_start_person             IN       NUMBER
     ,p_end_person               IN       NUMBER
     ,p_chunk                    IN       NUMBER
   )
   IS
-- End of User pARAMETERS needed
   BEGIN
      NULL;
   END assignment_action_code;

/*fffffffffffffffffffffffffff*/

   /* INITIALIZATION CODE */
   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER)
   IS
      l_action_info_id      NUMBER;
      l_ovn                 NUMBER;
      l_count               NUMBER        := 0;
      l_business_group_id   NUMBER;
      l_start_date          VARCHAR2 (20);
      l_end_date            VARCHAR2 (20);
      l_effective_date      DATE;
      l_payroll_id          NUMBER;
      l_consolidation_set   NUMBER;
      l_prev_prepay         NUMBER        := 0;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure INITIALIZATION_CODE'
                                 ,80
                                 );
      END IF;

      fnd_file.put_line (fnd_file.LOG, 'In INIT_CODE 0');
      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_person_id := NULL;
      g_assignment_id := NULL;
      pay_se_work_time_certificate.get_all_parameters (p_payroll_action_id
                                                      ,g_business_group_id
                                                      ,g_effective_date
                                                      ,g_person_id
                                                      ,g_assignment_id
                                                      ,g_still_employed
                                                      ,g_income_salary_year
                                                      );
      fnd_file.put_line
         (fnd_file.LOG
         ,'In the  INITIALIZATION_CODE After Initiliazing the global parameter '
         );

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure INITIALIZATION_CODE'
                                 ,90
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_err_num := SQLCODE;

         IF g_debug
         THEN
            hr_utility.set_location (   'ORA_ERR: '
                                     || g_err_num
                                     || 'In INITIALIZATION_CODE'
                                    ,180
                                    );
         END IF;
   END initialization_code;

   /* GET DEFINED BALANCE ID */
   FUNCTION get_defined_balance_id (p_user_name IN VARCHAR2)
      RETURN NUMBER
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_def_bal_id (p_user_name VARCHAR2)
      IS
         SELECT u.creator_id
           FROM ff_user_entities u
               ,ff_database_items d
          WHERE d.user_name = p_user_name
            AND u.user_entity_id = d.user_entity_id
            AND (u.legislation_code = 'SE')
            AND (u.business_group_id IS NULL)
            AND u.creator_type = 'B';

      l_defined_balance_id   ff_user_entities.user_entity_id%TYPE;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                                (' Entering Function GET_DEFINED_BALANCE_ID'
                                ,240
                                );
      END IF;

      OPEN csr_def_bal_id (p_user_name);

      FETCH csr_def_bal_id
       INTO l_defined_balance_id;

      CLOSE csr_def_bal_id;

      RETURN l_defined_balance_id;

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Function GET_DEFINED_BALANCE_ID'
                                 ,250
                                 );
      END IF;
   END get_defined_balance_id;

   FUNCTION get_defined_balance_value (
      p_user_name                IN       VARCHAR2
     ,p_in_assignment_id         IN       NUMBER
     ,p_in_virtual_date          IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_local_unit_id            IN       NUMBER
   )
      RETURN NUMBER
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_def_bal_id (p_user_name VARCHAR2)
      IS
         SELECT u.creator_id
           FROM ff_user_entities u
               ,ff_database_items d
          WHERE d.user_name = p_user_name
            AND u.user_entity_id = d.user_entity_id
            AND (u.legislation_code = 'SE')
            AND (u.business_group_id IS NULL)
            AND u.creator_type = 'B';

      l_defined_balance_id     ff_user_entities.user_entity_id%TYPE;
      l_return_balance_value   NUMBER;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                             (' Entering Function GET_DEFINED_BALANCE_VALUE'
                             ,240
                             );
      END IF;

      OPEN csr_def_bal_id (p_user_name);

      FETCH csr_def_bal_id
       INTO l_defined_balance_id;

      CLOSE csr_def_bal_id;

--      pay_balance_pkg.set_context ('SOURCE_TEXT', NULL);
      pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);

      fnd_file.put_line (fnd_file.LOG, 'p_tax_unit_id'||p_tax_unit_id);

      pay_balance_pkg.set_context ('LOCAL_UNIT_ID', p_local_unit_id);
      l_return_balance_value :=
         TO_CHAR
            (pay_balance_pkg.get_value
                                (p_defined_balance_id      => l_defined_balance_id
                                ,p_assignment_id           => p_in_assignment_id
                                ,p_virtual_date            => p_in_virtual_date
                                )
            ,'999999999D99'
            );
      RETURN l_return_balance_value;

      IF g_debug
      THEN
         hr_utility.set_location
                              (' Leaving Function GET_DEFINED_BALANCE_VALUE'
                              ,250
                              );
      END IF;
   END get_defined_balance_value;

   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id     IN       NUMBER
     ,p_effective_date           IN       DATE
   )
   IS
   -- End of place for Cursor  which fetches the values to be archived
   BEGIN
      NULL;
   END archive_code;

   --- Report XML generating code
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
   IS
      l_xfdf_string    CLOB;
      l_str1           VARCHAR2 (1000);
      l_str2           VARCHAR2 (20);
      l_str3           VARCHAR2 (20);
      l_str4           VARCHAR2 (20);
      l_str5           VARCHAR2 (20);
      l_str6           VARCHAR2 (30);
      l_str7           VARCHAR2 (1000);
      l_str8           VARCHAR2 (240);
      l_str9           VARCHAR2 (240);
      l_str10          VARCHAR2 (20);
      l_str11          VARCHAR2 (20);
      current_index    PLS_INTEGER;
      l_iana_charset   VARCHAR2 (50);
   BEGIN
      l_iana_charset := hr_se_utility.get_iana_charset;
      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1 :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT><WTCR>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</WTCR></ROOT>';
      l_str7 :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT></ROOT>';
      l_str10 := '<WTCR>';
      l_str11 := '</WTCR>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

      IF gplsqltable.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);

         FOR table_counter IN gplsqltable.FIRST .. gplsqltable.LAST
         LOOP
            l_str8 := gplsqltable (table_counter).tagname;
            l_str9 := gplsqltable (table_counter).tagvalue;

            IF l_str9 IN
                  ('PERSON'
                  ,'LE_ADDRESS_END'
                  ,'PERSON_END'
                  ,'LE_ADDRESS'
                  ,'REPORTINGYEAR'
                  ,'REPORTINGYEAR_END'
                  ,'OTHERYEAR'
                  ,'OTHERYEAR_END'
                  ,'FIRSTYEAR'
                  ,'FIRSTYEAR_END'
                  ,'SECONDYEAR_END'
                  ,'SECONDYEAR'
                  )
            THEN
               IF l_str9 IN
                     ('LE_ADDRESS'
                     ,'PERSON'
                     ,'REPORTINGYEAR'
                     ,'OTHERYEAR'
                     ,'FIRSTYEAR'
                     ,'SECONDYEAR'
                     )
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str2)
                                       ,l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                       ,l_str3);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str4)
                                       ,l_str4
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                       ,l_str5);
               END IF;
            ELSE
               IF l_str9 IS NOT NULL
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str2)
                                       ,l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                       ,l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9)
                                       ,l_str9);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                       ,l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                       ,l_str5);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str2)
                                       ,l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                       ,l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                       ,l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                       ,l_str5);
               END IF;
            END IF;
         END LOOP;

         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;

      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 40);
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE ('sqlerrm ' || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;

-----------------------------------------------------------------------------------------------------------------
--Procedure to Break the digits of a Person Number

PROCEDURE get_digit_breakup(
      p_number IN NUMBER,
      p_digit1 OUT NOCOPY NUMBER,
      p_digit2 OUT NOCOPY NUMBER,
      p_digit3 OUT NOCOPY NUMBER,
      p_digit4 OUT NOCOPY NUMBER,
      p_digit5 OUT NOCOPY NUMBER,
      p_digit6 OUT NOCOPY NUMBER,
      p_digit7 OUT NOCOPY NUMBER,
      p_digit8 OUT NOCOPY NUMBER,
      p_digit9 OUT NOCOPY NUMBER,
      p_digit10 OUT NOCOPY NUMBER
   )
   IS

   TYPE digits IS
      TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
     l_digit digits;
     l_count NUMBER :=1;
     l_number number(10);
   BEGIN
   l_number:=floor(p_number);
   FOR I in 1..10 loop
    l_digit(I):=null;
   END loop;

   WHILE l_number >= 1  LOOP

	SELECT mod(l_number,10) INTO l_digit(l_count) from dual;
	l_number:=floor(l_number/10);
	l_count:=l_count+1;
   END LOOP;

   SELECT floor(l_number) INTO l_digit(l_number) from dual;
	p_digit1:=l_digit(1);
	p_digit2:=l_digit(2);
	p_digit3:=l_digit(3);
	p_digit4:=l_digit(4);
	p_digit5:=l_digit(5);
	p_digit6:=l_digit(6);
	p_digit7:=l_digit(7);
	p_digit8:=l_digit(8);
	p_digit9:=l_digit(9);
	p_digit10:=l_digit(10);
   END get_digit_breakup;

   --------------------------------------------------------------------------------------------------------------------


   PROCEDURE get_xml_for_report (
      p_business_group_id        IN       NUMBER
     ,p_payroll_action_id        IN       VARCHAR2
     ,p_template_name            IN       VARCHAR2
     ,p_xml                      OUT NOCOPY CLOB
   )
   IS
--Variables needed for the report
      l_counter                NUMBER                                    := 0;
      l_payroll_action_id      pay_action_information.action_information1%TYPE;
   --- Digits added for Break-up of Person Number and Date
      l_digit1                 NUMBER(1);
      l_digit2                 NUMBER(1);
      l_digit3                 NUMBER(1);
      l_digit4                 NUMBER(1);
      l_digit5                 NUMBER(1);
      l_digit6                 NUMBER(1);
      l_digit7                 NUMBER(1);
      l_digit8                 NUMBER(1);
      l_digit9                 NUMBER(1);
      l_digit10                NUMBER(1);
      continuous_offer_from    NUMBER;
      continuous_offer_to      NUMBER;
      until_further_notice     VARCHAR(10) := 'N';
      time_limited_check_box   VARCHAR(10) := 'N';


--Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3
               ,action_information4
               ,action_information5
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCR'
            AND action_information2 = 'LE';

      CURSOR csr_wtc_person1 (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3 person_number
               ,action_information4 emp_last_name
               ,action_information5 emp_first_name
-- ,ACTION_INFORMATION6 HIRED_FROM
-- ,ACTION_INFORMATION7 HIRED_TO
--,TO_CHAR (fnd_date.canonical_to_date (action_information6)
--,'YYYY-MM-DD'
-- ) hired_from

              ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information6),'YYYYMMDD')) hired_from
              ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information7),'YYYYMMDD')) hired_to

-- ,TO_CHAR (fnd_date.canonical_to_date (action_information7)
-- ,'YYYY-MM-DD'
-- ) hired_to

	      ,action_information8 still_employed

--,TO_CHAR (fnd_date.canonical_to_date (action_information9)
-- ,'YYYY-MM-DD'
--) absence_from
-- ,TO_CHAR (fnd_date.canonical_to_date (action_information10)
--,'YYYY-MM-DD'
--) absence_to
               ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information9),'YYYYMMDD')) absence_from
	       ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information10),'YYYYMMDD')) absence_to

               ,action_information11 form_of_employment
               ,action_information12 work_taks
               ,action_information13 employed_temp_agency
               ,action_information14 employed_temp_work
               ,action_information15 reason

--,ACTION_INFORMATION16 NOTIFICATION_DATE
--,fnd_date.canonical_to_date(ACTION_INFORMATION16) NOTIFICATION_DATE
--,TO_CHAR (fnd_date.canonical_to_date (action_information16)
--,'YYYY-MM-DD'
--) notification_date

              ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information16),'YYYYMMDD')) notification_date

              ,action_information17 employees_request
	      ,action_information18 termination_reason
	      ,action_information19 absence_percentage
	      ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information20),'YYYYMMDD'))employment_end_date
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON1';

      CURSOR csr_wtc_person2 (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3 continuous_offer
               ,action_information4 permanent_check
-- ,ACTION_INFORMATION5 PERMANENT_DATE
--,TO_CHAR (fnd_date.canonical_to_date (action_information5)
--,'YYYY-MM-DD'
--) permanent_date

                ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information5),'YYYYMMDD')) permanent_date_from
		 ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information25),'YYYYMMDD')) permanent_date_to
                ,action_information6 time_limited_check

-- ,ACTION_INFORMATION7 TIME_LIMITED_FROM
-- ,ACTION_INFORMATION8 TIME_LIMITED_TO
--,TO_CHAR (fnd_date.canonical_to_date (action_information7)
--,'YYYY-MM-DD'
--) time_limited_from
--,TO_CHAR (fnd_date.canonical_to_date (action_information8)
--,'YYYY-MM-DD'
--) time_limited_to

               ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information7),'YYYYMMDD')) time_limited_from
               ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information8),'YYYYMMDD')) time_limited_to

               ,action_information9 other_check
               ,action_information10 other
               ,action_information11 full_time_check
               ,action_information12 full_time
               ,action_information13 part_time_check
               ,action_information14 part_time
               ,action_information15 working_percentage
               ,action_information16 various_working_time
               ,action_information17 offer_accepted
-- ,ACTION_INFORMATION18 DECLINE_DATE
-- ,ACTION_INFORMATION19 TIME_WORKED_FROM
-- ,ACTION_INFORMATION20 TIME_WORKED_TO
--, TO_CHAR (fnd_date.canonical_to_date (NVL(action_information18,NULL))
--,'YYYY-MM-DD'
--) decline_date
--,TO_CHAR (fnd_date.canonical_to_date (NVL(action_information19,NULL))
--,'YYYY-MM-DD'
--) time_worked_from
--,TO_CHAR (fnd_date.canonical_to_date (NVL(action_information20,NULL))
--,'YYYY-MM-DD'
--) time_worked_to

                ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information18),'YYYYMMDD')) decline_date
		,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information19),'YYYYMMDD')) time_worked_from
		,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information20),'YYYYMMDD')) time_worked_to

                ,action_information21 total_worked_hours
                ,action_information22 paid_sick_leave_days
                ,action_information23 teaching_load
		,action_information24 aggrmnt_of_compn_signed  --EOY 2008
		,action_information26 teaching_load_check_box      -- EOY 2008
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON2';

      CURSOR csr_wtc_person3 (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3 assign_full_time
               ,action_information4 assign_hours_week
               ,action_information5 assign_frequency
               ,action_information6 assign_part_time
               ,action_information7 assign_working_percentage
               ,action_information8 assign_various_work_time
               ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(action_information9)) salary_year
               ,action_information10 assign_salary_paid_out
               ,action_information11 salary_amount
               ,action_information12 school_holiday_pay_amount
               ,action_information13 school_holiday_pay_box
               ,action_information14 no_of_paid_holiday_days
               ,action_information15 emp_with_holiday_pay
               ,action_information16 paid_days_off_duty_time
               ,action_information17 employed_educational_assoc
	       ,action_information18 holiday_pay_amount
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON3';

      CURSOR csr_wtc_person4 (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3 holiday_duty
               ,action_information4 lay_off_period_paid_days
               ,action_information5 holiday_laid_off

--,TO_CHAR (fnd_date.canonical_to_date (action_information6)
--,'YYYY-MM-DD'
--) lay_off_from
--,TO_CHAR (fnd_date.canonical_to_date (action_information7)
--,'YYYY-MM-DD'
--) lay_off_to
-- ,ACTION_INFORMATION6 LAY_OFF_FROM
-- ,ACTION_INFORMATION7 LAY_OFF_TO

               ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information6),'YYYYMMDD')) lay_off_from
               ,FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(action_information7),'YYYYMMDD')) lay_off_to


               ,action_information8 other_information
               ,action_information9 legal_employer_name
               ,action_information10 org_number
               ,action_information11 phone_number
               ,action_information12 location_code
               ,action_information13 address_line_1
               ,action_information14 address_line_2
               ,action_information15 address_line_3
               ,action_information16 postal_code
               ,action_information17 town_or_city
               ,action_information18 region_1
               ,action_information19 region_2
               ,action_information20 territory_short_name
               ,action_information21 hourly_pay_variable
	       ,action_information22 hourly_overtime_rate
	       ,action_information23 hourly_addl_suppl_time
	       ,action_information24 other_taxable_compensation
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON4';

      CURSOR csr_wtc_get_group (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT   action_information28 GROUP_ID
             FROM pay_action_information
            WHERE action_context_type = 'PA'
              AND action_context_id = csr_v_pa_id
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEWTCA'
              AND action_information2 = 'WTC_PERSON5'
         GROUP BY action_information28;

      CURSOR csr_wtc_get_month_value (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
        ,csr_v_group_id                      pay_action_information.action_information28%TYPE
      )
      IS
         SELECT ROWNUM
               ,action_information3 jan_days
               ,action_information4 feb_days
               ,action_information5 mar_days
               ,action_information6 apr_days
               ,action_information7 may_days
               ,action_information8 jun_days
               ,action_information9 jul_days
               ,action_information10 aug_days
               ,action_information11 sep_days
               ,action_information12 oct_days
               ,action_information13 nov_days
               ,action_information14 dec_days
               ,action_information15 YEAR
               ,action_information16 jan_hours
               ,action_information17 feb_hours
               ,action_information18 mar_hours
               ,action_information19 apr_hours
               ,action_information20 may_hours
               ,action_information21 jun_hours
               ,action_information22 jul_hours
               ,action_information23 aug_hours
               ,action_information24 sep_hours
               ,action_information25 oct_hours
               ,action_information26 nov_hours
               ,action_information27 dec_hours
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON5'
            AND action_information28 = csr_v_group_id;

      CURSOR csr_report_details (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information2 rpt_person_id
               ,action_information3 rpt_assignment_id
               ,action_information4 rpt_still_employed
               ,action_information5 rpt_business_group_id
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT DETAILS'
            AND action_information1 = 'PYSEWTCA';

      lr_report_details        csr_report_details%ROWTYPE;
      lr_wtc_person1           csr_wtc_person1%ROWTYPE;
      lr_wtc_person2           csr_wtc_person2%ROWTYPE;
      lr_wtc_person3           csr_wtc_person3%ROWTYPE;
      lr_wtc_person4           csr_wtc_person4%ROWTYPE;
      lr_wtc_get_group         csr_wtc_get_group%ROWTYPE;
      lr_wtc_get_month_value   csr_wtc_get_month_value%ROWTYPE;

      CURSOR csr_all_employees_under_le (
         csr_v_pa_id                         pay_action_information.action_information3%TYPE
        ,csr_v_le_id                         pay_action_information.action_information15%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEWTCR'
              AND action_information3 = csr_v_pa_id
              AND action_information2 = 'PER'
              AND action_information15 = csr_v_le_id
         ORDER BY action_information30;





-- *****************************************************************************
-- Add Individual Months Overtime and Addl/Supplemtary hours
-- *****************************************************************************
CURSOR csr_wtc_get_ovr_addl_val (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
        ,csr_v_group_id                      pay_action_information.action_information28%TYPE
      )
      IS
         SELECT ROWNUM
               ,action_information3 jan_addl_time
               ,action_information4 feb_addl_time
               ,action_information5 mar_addl_time
               ,action_information6 apr_addl_time
               ,action_information7 may_addl_time
               ,action_information8 jun_addl_time
               ,action_information9 jul_addl_time
               ,action_information10 aug_addl_time
               ,action_information11 sep_addl_time
               ,action_information12 oct_addl_time
               ,action_information13 nov_addl_time
               ,action_information14 dec_addl_time
               ,action_information15 YEAR
               ,action_information16 jan_overtime
               ,action_information17 feb_overtime
               ,action_information18 mar_overtime
               ,action_information19 apr_overtime
               ,action_information20 may_overtime
               ,action_information21 jun_overtime
               ,action_information22 jul_overtime
               ,action_information23 aug_overtime
               ,action_information24 sep_overtime
               ,action_information25 oct_overtime
               ,action_information26 nov_overtime
               ,action_information27 dec_overtime
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON6'
            AND action_information28 = csr_v_group_id;




-- *****************************************************************************
-- Add Individual Months Absence hours
-- *****************************************************************************
CURSOR csr_wtc_get_absence_val (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
        ,csr_v_group_id                      pay_action_information.action_information28%TYPE
      )
      IS
         SELECT ROWNUM
               ,action_information3 jan_absence_time
               ,action_information4 feb_absence_time
               ,action_information5 mar_absence_time
               ,action_information6 apr_absence_time
               ,action_information7 may_absence_time
               ,action_information8 jun_absence_time
               ,action_information9 jul_absence_time
               ,action_information10 aug_absence_time
               ,action_information11 sep_absence_time
               ,action_information12 oct_absence_time
               ,action_information13 nov_absence_time
               ,action_information14 dec_absence_time
               ,action_information15 YEAR
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEWTCA'
            AND action_information2 = 'WTC_PERSON7'
            AND action_information28 = csr_v_group_id;

/* End of declaration*/
/* Proc to Add the tag value and Name */
      PROCEDURE add_tag_value (p_tag_name IN VARCHAR2, p_tag_value IN VARCHAR2)
      IS
      BEGIN
         gplsqltable (l_counter).tagname := p_tag_name;
         gplsqltable (l_counter).tagvalue := p_tag_value;
         l_counter := l_counter + 1;
      END add_tag_value;
/* End of Proc to Add the tag value and Name */
/* Start of GET_HPD_XML */
   BEGIN
      IF p_payroll_action_id IS NULL
      THEN
         BEGIN
            SELECT payroll_action_id
              INTO l_payroll_action_id
              FROM pay_payroll_actions ppa
                  ,fnd_conc_req_summary_v fcrs
                  ,fnd_conc_req_summary_v fcrs1
             WHERE fcrs.request_id = fnd_global.conc_request_id
               AND fcrs.priority_request_id = fcrs1.priority_request_id
               AND ppa.request_id BETWEEN fcrs1.request_id AND fcrs.request_id
               AND ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;
      End if;  --issue#4 Fix that will give data for request set run and when no archieve id is choosen
         fnd_file.put_line (fnd_file.LOG, 'Entered Reporting');
         fnd_file.put_line (fnd_file.LOG
                           , 'p_payroll_action_id  ' || p_payroll_action_id
                           );

/* Structure of Xml should look like this
<LE>
    <DETAILS>
    </DETAILS>
    <EMPLOYEES>
        <PERSON>
        </PERSON>
    </EMPLOYEES>
</LE>
*/

        OPEN csr_report_details (l_payroll_action_id);
        FETCH csr_report_details
          INTO lr_report_details;

         CLOSE csr_report_details;

         --logger ('After', 'csr_REPORT_DETAILS');
         --logger ('lr_report_details.RPT_PERSON_ID'                ,lr_report_details.rpt_person_id                );
         --logger ('lr_report_details.RPT_ASSIGNMENT_ID'                ,lr_report_details.rpt_assignment_id                );
         --logger ('lr_report_details.RPT_STILL_EMPLOYED'                ,lr_report_details.rpt_still_employed                );
         --logger ('lr_report_details.RPT_BUSINESS_GROUP_ID'                ,lr_report_details.rpt_business_group_id                );
         add_tag_value ('PERSON', 'PERSON');

         OPEN csr_wtc_person1 (l_payroll_action_id);

         FETCH csr_wtc_person1
          INTO lr_wtc_person1;

         CLOSE csr_wtc_person1;

	 OPEN csr_wtc_person2 (l_payroll_action_id);

         FETCH csr_wtc_person2
          INTO lr_wtc_person2;

         CLOSE csr_wtc_person2;

	 OPEN csr_wtc_person3 (l_payroll_action_id);

         FETCH csr_wtc_person3
          INTO lr_wtc_person3;

         CLOSE csr_wtc_person3;

	 fnd_file.put_line (fnd_file.LOG, 'lr_wtc_person1.person_number'||lr_wtc_person1.person_number);
---------------------------------------------------------------------------------------------------------------
--New Format of Person Number (of Ten Digits)
---------------------------------------------------------------------------------------------------------------
--add_tag_value ('PERSON_NUMBER', lr_wtc_person1.person_number);

	 get_digit_breakup(replace(nvl(lr_wtc_person1.person_number,0),'-',''),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'PN1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PN9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'PN10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;
------------------------------------------------------------------------------------------------------------------

         add_tag_value ('EMP_LAST_NAME', lr_wtc_person1.emp_last_name);
         add_tag_value ('EMP_FIRST_NAME', lr_wtc_person1.emp_first_name);

	 fnd_file.put_line (fnd_file.LOG, 'lr_wtc_person1.emp_first_name'||lr_wtc_person1.emp_first_name);
	   fnd_file.put_line (fnd_file.LOG, 'l_digit10'||l_digit10);

 ---------------------------------------------------------------------------------------------------------------
 -- Change the  date format for hired_from (YYYYMMDD)
 ----------------------------------------------------------------------------------------------------------------
--add_tag_value ('HIRED_FROM', lr_wtc_person1.hired_from);

	 get_digit_breakup(nvl(lr_wtc_person1.hired_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'HF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'HF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

	fnd_file.put_line (fnd_file.LOG, 'lr_wtc_person1.hired_to'||lr_wtc_person1.hired_to);

 ---------------------------------------------------------------------------------------------------------------
 -- Change the  date format for hired_to (YYYYMMDD)
 ----------------------------------------------------------------------------------------------------------------
-- add_tag_value ('HIRED_TO', lr_wtc_person1.hired_to);

	 get_digit_breakup(nvl(lr_wtc_person1.hired_to,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'HT1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'HT9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'HT10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------


	 add_tag_value ('STILL_EMPLOYED', lr_wtc_person1.still_employed);

	  add_tag_value ('WORK_TAKS', lr_wtc_person1.work_taks);


---------------------------------------------------------------------------------------------------------------
-- Change the  date format for absence_from (YYYYMMDD)
----------------------------------------------------------------------------------------------------------------
-- add_tag_value ('ABSENCE_FROM', lr_wtc_person1.absence_from);

	 get_digit_breakup(nvl(lr_wtc_person1.absence_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'AF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'AF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------
-- Change the  date format for absence_to (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
-- add_tag_value ('ABSENCE_TO', lr_wtc_person1.absence_to);

	 get_digit_breakup(nvl(lr_wtc_person1.absence_to,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'AT1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'AT9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'AT10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------


         add_tag_value ('ABSENCE_PERCENTAGE',lr_wtc_person1.absence_percentage);

         add_tag_value ('FORM_OF_EMPLOYMENT'
                       ,lr_wtc_person1.form_of_employment
                       );


		IF lr_wtc_person1.form_of_employment <> 'FR' AND
		     lr_wtc_person1.form_of_employment <> 'PR' AND
		       lr_wtc_person1.form_of_employment <> 'SE_PE' AND
		        lr_wtc_person1.form_of_employment <>'INTMT'
		THEN
		time_limited_check_box := 'Y';
		ELSE
		time_limited_check_box := 'N';

	        END IF ;


	 fnd_file.put_line (fnd_file.LOG, 'time_limited_check_box'||time_limited_check_box);
	 fnd_file.put_line (fnd_file.LOG, ' lr_wtc_person1.employment_end_date'|| lr_wtc_person1.employment_end_date);


         add_tag_value ('TIME_LIMITED_CHECK_BOX', time_limited_check_box);




 ------------------------------------------------------------------------------------------------------------------
-- Change the  date format for employment_end_date (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--  add_tag_value ('EMPLOYMENT_END_DATE', lr_wtc_person1.employment_end_date);

	 get_digit_breakup(nvl(lr_wtc_person1.employment_end_date,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'EED1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EED9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'EED10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------



         add_tag_value ('ASSIGN_FULL_TIME', lr_wtc_person3.assign_full_time);
         add_tag_value ('ASSIGN_HOURS_WEEK', lr_wtc_person3.assign_hours_week);
         add_tag_value ('ASSIGN_FREQUENCY', lr_wtc_person3.assign_frequency);
         add_tag_value ('ASSIGN_PART_TIME', lr_wtc_person3.assign_part_time);
         add_tag_value ('ASSIGN_WORKING_PERCENTAGE'
                       ,lr_wtc_person3.assign_working_percentage
                       );
         add_tag_value ('ASSIGN_VARIOUS_WORK_TIME'
                       ,lr_wtc_person3.assign_various_work_time
                       );


	 add_tag_value ('EMPLOYED_TEMP_AGENCY'
                       ,lr_wtc_person1.employed_temp_agency
                       );
         add_tag_value ('EMPLOYED_TEMP_WORK'
                       ,lr_wtc_person1.employed_temp_work
                       );








------------------------------------------------------------------------------------------------------------------
-- Change the  date format for notification_date (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--  add_tag_value ('NOTIFICATION_DATE', lr_wtc_person1.notification_date);

	 get_digit_breakup(nvl(lr_wtc_person1.notification_date,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'ND1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'ND9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'ND10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------


         add_tag_value ('EMPLOYEES_REQUEST', lr_wtc_person1.employees_request);

	 add_tag_value ('TERMINATION_REASON',lr_wtc_person1.termination_reason);

	  add_tag_value ('REASON', lr_wtc_person1.reason);

	  add_tag_value ('AGG_OF_COMPENSATION_SIGNED', lr_wtc_person2.aggrmnt_of_compn_signed);   -- EOY 2008




	 --logger ('PERSON_NUMBER', lr_wtc_person1.person_number);
         --logger ('EMP_LAST_NAME', lr_wtc_person1.emp_last_name);
         --logger ('EMP_FIRST_NAME', lr_wtc_person1.emp_first_name);
         --logger ('HIRED_FROM', lr_wtc_person1.hired_from);
         --logger ('HIRED_TO', lr_wtc_person1.hired_to);
         --logger ('STILL_EMPLOYED', lr_wtc_person1.still_employed);
         --logger ('ABSENCE_FROM', lr_wtc_person1.absence_from);
         --logger ('ABSENCE_TO', lr_wtc_person1.absence_to);
         --logger ('FORM_OF_EMPLOYMENT', lr_wtc_person1.form_of_employment);
         --logger ('WORK_TAKS', lr_wtc_person1.work_taks);
         --logger ('EMPLOYED_TEMP_AGENCY', lr_wtc_person1.employed_temp_agency);
         --logger ('EMPLOYED_TEMP_WORK', lr_wtc_person1.employed_temp_work);
         --logger ('REASON', lr_wtc_person1.reason);
         --logger ('NOTIFICATION_DATE', lr_wtc_person1.notification_date);
         --logger ('EMPLOYEES_REQUEST', lr_wtc_person1.employees_request);
	 --logger ('TERMINATION_REASON',lr_wtc_person1.termination_reason);
         --logger ('Before csr_wtc_person2', l_payroll_action_id);


         --logger ('after csr_wtc_person2', l_payroll_action_id);
         add_tag_value ('CONTINUOUS_OFFER', lr_wtc_person2.continuous_offer);
         add_tag_value ('PERMANENT_CHECK', lr_wtc_person2.permanent_check);

  --------------------------------------------------------------------------------------------------------
  -- The code changes below are added w.r.t the change in the
  --format of Template from 2008
  --------------------------------------------------------------------------------------------------------
      IF lr_wtc_person2.permanent_check = 'Y'
      THEN
	continuous_offer_from := lr_wtc_person2.permanent_date_from;
	continuous_offer_to := lr_wtc_person2.permanent_date_to;

      ELSIF lr_wtc_person2.time_limited_check = 'Y'
      THEN
	continuous_offer_from := lr_wtc_person2.time_limited_from ;
	continuous_offer_to := lr_wtc_person2.time_limited_to ;
      END IF;

      IF (lr_wtc_person2.continuous_offer = 'Y') and (continuous_offer_to IS NULL)
      THEN
	until_further_notice := 'Y';
      ELSE
	until_further_notice := 'N';
      END IF;

         add_tag_value ('UNTIL_FURTHER_NOTICE', until_further_notice);
------------------------------------------------------------------------------------------------------------------
-- Change the  date format for continuous_offer_from (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------

	 get_digit_breakup(nvl(continuous_offer_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'COF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'COF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------
-- Change the  date format for continuous_offer_to (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------

	 get_digit_breakup(nvl(continuous_offer_to,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'COT1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'COT9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'COT10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------
-- Change the  date format for permanent_date_from (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--  add_tag_value ('PERMANENT_DATE', lr_wtc_person2.permanent_date_from);

	 get_digit_breakup(nvl(lr_wtc_person2.permanent_date_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'PDF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'PDF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'PDF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------



         add_tag_value ('TIME_LIMITED_CHECK'
                       ,lr_wtc_person2.time_limited_check
                       );



------------------------------------------------------------------------------------------------------------------
-- Change the  date format for time_limited_from (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--  add_tag_value ('TIME_LIMITED_FROM', lr_wtc_person2.time_limited_from);

	 get_digit_breakup(nvl(lr_wtc_person2.time_limited_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'TLF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TLF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------
-- Change the  date format for time_limited_to (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--   add_tag_value ('TIME_LIMITED_TO', lr_wtc_person2.time_limited_to);

	 get_digit_breakup(nvl(lr_wtc_person2.time_limited_to,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'TLT1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TLT9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TLT10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------


         add_tag_value ('OTHER_CHECK', lr_wtc_person2.other_check);
         add_tag_value ('OTHER', lr_wtc_person2.other);
         add_tag_value ('FULL_TIME_CHECK', lr_wtc_person2.full_time_check);
         add_tag_value ('FULL_TIME', lr_wtc_person2.full_time);
         add_tag_value ('PART_TIME_CHECK', lr_wtc_person2.part_time_check);
         add_tag_value ('PART_TIME', lr_wtc_person2.part_time);
         add_tag_value ('WORKING_PERCENTAGE'
                       ,lr_wtc_person2.working_percentage
                       );
         add_tag_value ('VARIOUS_WORKING_TIME'
                       ,lr_wtc_person2.various_working_time
                       );
         add_tag_value ('OFFER_ACCEPTED', lr_wtc_person2.offer_accepted);



------------------------------------------------------------------------------------------------------------------
-- Change the  date format for decline_date (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--   add_tag_value ('DECLINE_DATE', lr_wtc_person2.decline_date);

	 get_digit_breakup(nvl(lr_wtc_person2.decline_date,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'DD1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'DD9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'DD10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------
-- Change the  date format for time_worked_from (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--   add_tag_value ('TIME_WORKED_FROM', lr_wtc_person2.time_worked_from);

	 get_digit_breakup(nvl(lr_wtc_person2.time_worked_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'TWF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TWF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------
-- Change the  date format for time_worked_to (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--add_tag_value ('TIME_WORKED_TO', lr_wtc_person2.time_worked_to);

	 get_digit_breakup(nvl(lr_wtc_person2.time_worked_to,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'TWT1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'TWT9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TWT10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------




         add_tag_value ('TOTAL_WORKED_HOURS'
                       ,lr_wtc_person2.total_worked_hours
                       );
         add_tag_value ('PAID_SICK_LEAVE_DAYS'
                       ,lr_wtc_person2.paid_sick_leave_days
                       );
         add_tag_value ('TEACHING_LOAD', lr_wtc_person2.teaching_load);

         add_tag_value ('TEACHING_LOAD_CHECK_BOX', lr_wtc_person2.teaching_load_check_box);

         --logger ('Before csr_wtc_person3', l_payroll_action_id);





------------------------------------------------------------------------------------------------------------------
-- Change the  date format for salary_year (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--  add_tag_value ('SALARY_YEAR', lr_wtc_person3.salary_year);

	 get_digit_breakup(nvl(lr_wtc_person3.salary_year,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'SY1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SY2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SY3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SY4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;

------------------------------------------------------------------------------------------------------------------



         add_tag_value ('ASSIGN_SALARY_PAID_OUT'
                       ,lr_wtc_person3.assign_salary_paid_out
                       );
         add_tag_value ('SALARY_AMOUNT', lr_wtc_person3.salary_amount);
         add_tag_value ('SCHOOL_HOLIDAY_PAY_AMOUNT'
                       ,lr_wtc_person3.school_holiday_pay_amount
                       );
         add_tag_value ('SCHOOL_HOLIDAY_PAY_BOX'
                       ,lr_wtc_person3.school_holiday_pay_box
                       );
         add_tag_value ('NO_OF_PAID_HOLIDAY_DAYS'
                       ,lr_wtc_person3.no_of_paid_holiday_days
                       );
         add_tag_value ('EMP_WITH_HOLIDAY_PAY'
                       ,lr_wtc_person3.emp_with_holiday_pay
                       );
         add_tag_value ('PAID_DAYS_OFF_DUTY_TIME'
                       ,lr_wtc_person3.paid_days_off_duty_time
                       );
         add_tag_value ('HOLIDAY_PAY_AMOUNT'
                       ,lr_wtc_person3.holiday_pay_amount);         -- EOY 2008

         add_tag_value ('EMPLOYED_EDUCATIONAL_ASSOC'
                       ,lr_wtc_person3.employed_educational_assoc
                       );

         OPEN csr_wtc_person4 (l_payroll_action_id);

         FETCH csr_wtc_person4
          INTO lr_wtc_person4;

         CLOSE csr_wtc_person4;

         add_tag_value ('HOLIDAY_DUTY', lr_wtc_person4.holiday_duty);
         add_tag_value ('LAY_OFF_PERIOD_PAID_DAYS'
                       ,lr_wtc_person4.lay_off_period_paid_days
                       );
         add_tag_value ('HOLIDAY_LAID_OFF', lr_wtc_person4.holiday_laid_off);


------------------------------------------------------------------------------------------------------------------
-- Change the  date format for lay_off_from (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--add_tag_value ('LAY_OFF_FROM', lr_wtc_person4.lay_off_from);

	 get_digit_breakup(nvl(lr_wtc_person4.lay_off_from,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'LOF1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOF9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'LOF10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;


------------------------------------------------------------------------------------------------------------------
-- Change the  date format for lay_off_to (YYYYMMDD)
------------------------------------------------------------------------------------------------------------------
--add_tag_value ('LAY_OFF_TO', lr_wtc_person4.lay_off_to);

	 get_digit_breakup(nvl(lr_wtc_person4.lay_off_to,0),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gplsqltable (l_counter).tagname := 'LOT1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'LOT9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'LOT10';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;
------------------------------------------------------------------------------------------------------------------


         add_tag_value ('OTHER_INFORMATION', lr_wtc_person4.other_information);

         add_tag_value ('HOURLY_PAY_VARIABLE', lr_wtc_person4.hourly_pay_variable);            --EOY 2008
	 add_tag_value ('HOURLY_OVERTIME_RATE', lr_wtc_person4.hourly_overtime_rate);          --EOY 2008
	 add_tag_value ('HOURLY_ADDL_SUP_TIME', lr_wtc_person4.hourly_addl_suppl_time);        --EOY 2008
	 add_tag_value ('OTHER_TAX_COMPENSATION', lr_wtc_person4.other_taxable_compensation);  --EOY 2008

	 add_tag_value ('LEGAL_EMPLOYER_NAME'
                       ,lr_wtc_person4.legal_employer_name
                       );
         add_tag_value ('ORG_NUMBER', lr_wtc_person4.org_number);
         add_tag_value ('PHONE_NUMBER', lr_wtc_person4.phone_number);
         add_tag_value ('LE_ADDRESS', 'LE_ADDRESS');
         add_tag_value ('LOCATION_CODE', lr_wtc_person4.location_code);
         add_tag_value ('ADDRESS_LINE_1', lr_wtc_person4.address_line_1);
         add_tag_value ('ADDRESS_LINE_2', lr_wtc_person4.address_line_2);
         add_tag_value ('ADDRESS_LINE_3', lr_wtc_person4.address_line_3);
         add_tag_value ('POSTAL_CODE', lr_wtc_person4.postal_code);
         add_tag_value ('TOWN_OR_CITY', lr_wtc_person4.town_or_city);
         add_tag_value ('REGION_1', lr_wtc_person4.region_1);
         add_tag_value ('REGION_2', lr_wtc_person4.region_2);
         add_tag_value ('TERRITORY_SHORT_NAME'
                       ,lr_wtc_person4.territory_short_name
                       );
         add_tag_value ('LE_ADDRESS', 'LE_ADDRESS_END');

-- *****************************************************************************
-- For each group we get two record
-- for the first group we put differnt tag from all other groups
-- *****************************************************************************
         FOR rec_get_group IN csr_wtc_get_group (l_payroll_action_id)
         LOOP
-- *****************************************************************************
            IF rec_get_group.GROUP_ID = '1'
            THEN
               add_tag_value ('REPORTINGYEAR', 'REPORTINGYEAR');
            ELSE
               add_tag_value ('OTHERYEAR', 'OTHERYEAR');
            END IF;

-- *****************************************************************************
-- Add code to put individual month value
-- for each group id we will get two years value i.e.. two rows
-- *****************************************************************************
            FOR rec_wtc_get_month_value IN
               csr_wtc_get_month_value (l_payroll_action_id
                                       ,rec_get_group.GROUP_ID
                                       )
            LOOP
-- *****************************************************************************
-- again to differntiate teh first year and second year condition using ROWNUM
-- *****************************************************************************
               IF rec_wtc_get_month_value.ROWNUM = '1'
               THEN
                  add_tag_value ('FIRSTYEAR', 'FIRSTYEAR');
               ELSE
                  add_tag_value ('SECONDYEAR', 'SECONDYEAR');
               END IF;

-- *****************************************************************************
-- Add Individual Months days and hours
-- *****************************************************************************
               add_tag_value ('YEAR', rec_wtc_get_month_value.YEAR);
               add_tag_value ('JAN_DAYS', rec_wtc_get_month_value.jan_days);
               add_tag_value ('FEB_DAYS', rec_wtc_get_month_value.feb_days);
               add_tag_value ('MAR_DAYS', rec_wtc_get_month_value.mar_days);
               add_tag_value ('APR_DAYS', rec_wtc_get_month_value.apr_days);
               add_tag_value ('MAY_DAYS', rec_wtc_get_month_value.may_days);
               add_tag_value ('JUN_DAYS', rec_wtc_get_month_value.jun_days);
               add_tag_value ('JUL_DAYS', rec_wtc_get_month_value.jul_days);
               add_tag_value ('AUG_DAYS', rec_wtc_get_month_value.aug_days);
               add_tag_value ('SEP_DAYS', rec_wtc_get_month_value.sep_days);
               add_tag_value ('OCT_DAYS', rec_wtc_get_month_value.oct_days);
               add_tag_value ('NOV_DAYS', rec_wtc_get_month_value.nov_days);
               add_tag_value ('DEC_DAYS', rec_wtc_get_month_value.dec_days);
               add_tag_value ('JAN_HOURS', rec_wtc_get_month_value.jan_hours);
               add_tag_value ('FEB_HOURS', rec_wtc_get_month_value.feb_hours);
               add_tag_value ('MAR_HOURS', rec_wtc_get_month_value.mar_hours);
               add_tag_value ('APR_HOURS', rec_wtc_get_month_value.apr_hours);
               add_tag_value ('MAY_HOURS', rec_wtc_get_month_value.may_hours);
               add_tag_value ('JUN_HOURS', rec_wtc_get_month_value.jun_hours);
               add_tag_value ('JUL_HOURS', rec_wtc_get_month_value.jul_hours);
               add_tag_value ('AUG_HOURS', rec_wtc_get_month_value.aug_hours);
               add_tag_value ('SEP_HOURS', rec_wtc_get_month_value.sep_hours);
               add_tag_value ('OCT_HOURS', rec_wtc_get_month_value.oct_hours);
               add_tag_value ('NOV_HOURS', rec_wtc_get_month_value.nov_hours);
               add_tag_value ('DEC_HOURS', rec_wtc_get_month_value.dec_hours);

-- *****************************************************************************
-- to differntiate teh first year and second year end case condition using ROWNUM
-- *****************************************************************************
               IF rec_wtc_get_month_value.ROWNUM = '1'
               THEN
                  add_tag_value ('FIRSTYEAR', 'FIRSTYEAR_END');
               ELSE
                  add_tag_value ('SECONDYEAR', 'SECONDYEAR_END');
               END IF;
-- *****************************************************************************
            END LOOP;

-- *****************************************************************************
--------------Code for EOY 2008 changes
-- *****************************************************************************
-- Add code to put individual month value for absence
-- for each group id we will get two years value i.e.. two rows
-- *****************************************************************************
            FOR rec_wtc_get_ovr_addl_val IN
               csr_wtc_get_ovr_addl_val (l_payroll_action_id
                                       ,rec_get_group.GROUP_ID
                                       )
            LOOP
-- *****************************************************************************
-- again to differntiate the first year and second year condition using ROWNUM
-- *****************************************************************************
               IF rec_wtc_get_ovr_addl_val.ROWNUM = '1'
               THEN
                  add_tag_value ('FIRSTYEAR', 'FIRSTYEAR');
               ELSE
                  add_tag_value ('SECONDYEAR', 'SECONDYEAR');
               END IF;

-- *****************************************************************************
-- Add Individual Months days and hours
-- *****************************************************************************
               add_tag_value ('YEAR', rec_wtc_get_ovr_addl_val.YEAR);
               add_tag_value ('JAN_ADDL', rec_wtc_get_ovr_addl_val.jan_addl_time);
               add_tag_value ('FEB_ADDL', rec_wtc_get_ovr_addl_val.feb_addl_time);
               add_tag_value ('MAR_ADDL', rec_wtc_get_ovr_addl_val.mar_addl_time);
               add_tag_value ('APR_ADDL', rec_wtc_get_ovr_addl_val.apr_addl_time);
               add_tag_value ('MAY_ADDL', rec_wtc_get_ovr_addl_val.may_addl_time);
               add_tag_value ('JUN_ADDL', rec_wtc_get_ovr_addl_val.jun_addl_time);
               add_tag_value ('JUL_ADDL', rec_wtc_get_ovr_addl_val.jul_addl_time);
               add_tag_value ('AUG_ADDL', rec_wtc_get_ovr_addl_val.aug_addl_time);
               add_tag_value ('SEP_ADDL', rec_wtc_get_ovr_addl_val.sep_addl_time);
               add_tag_value ('OCT_ADDL', rec_wtc_get_ovr_addl_val.oct_addl_time);
               add_tag_value ('NOV_ADDL', rec_wtc_get_ovr_addl_val.nov_addl_time);
               add_tag_value ('DEC_ADDL', rec_wtc_get_ovr_addl_val.dec_addl_time);
               add_tag_value ('JAN_OVERTIME', rec_wtc_get_ovr_addl_val.jan_overtime);
               add_tag_value ('FEB_OVERTIME', rec_wtc_get_ovr_addl_val.feb_overtime);
               add_tag_value ('MAR_OVERTIME', rec_wtc_get_ovr_addl_val.mar_overtime);
               add_tag_value ('APR_OVERTIME', rec_wtc_get_ovr_addl_val.apr_overtime);
               add_tag_value ('MAY_OVERTIME', rec_wtc_get_ovr_addl_val.may_overtime);
               add_tag_value ('JUN_OVERTIME', rec_wtc_get_ovr_addl_val.jun_overtime);
               add_tag_value ('JUL_OVERTIME', rec_wtc_get_ovr_addl_val.jul_overtime);
               add_tag_value ('AUG_OVERTIME', rec_wtc_get_ovr_addl_val.aug_overtime);
               add_tag_value ('SEP_OVERTIME', rec_wtc_get_ovr_addl_val.sep_overtime);
               add_tag_value ('OCT_OVERTIME', rec_wtc_get_ovr_addl_val.oct_overtime);
               add_tag_value ('NOV_OVERTIME', rec_wtc_get_ovr_addl_val.nov_overtime);
               add_tag_value ('DEC_OVERTIME', rec_wtc_get_ovr_addl_val.dec_overtime);

-- *****************************************************************************
-- to differntiate teh first year and second year end case condition using ROWNUM
-- *****************************************************************************
               IF rec_wtc_get_ovr_addl_val.ROWNUM = '1'
               THEN
                  add_tag_value ('FIRSTYEAR', 'FIRSTYEAR_END');
               ELSE
                  add_tag_value ('SECONDYEAR', 'SECONDYEAR_END');
               END IF;
-- *****************************************************************************
            END LOOP;
-- *****************************************************************************
-- Add code to put individual month value
-- for each group id we will get two years value i.e.. two rows
-- *****************************************************************************
            FOR rec_wtc_get_absence_val IN
               csr_wtc_get_absence_val (l_payroll_action_id
                                       ,rec_get_group.GROUP_ID
                                       )
            LOOP
-- *****************************************************************************
-- again to differntiate teh first year and second year condition using ROWNUM
-- *****************************************************************************
               IF rec_wtc_get_absence_val.ROWNUM = '1'
               THEN
                  add_tag_value ('FIRSTYEAR', 'FIRSTYEAR');
               ELSE
                  add_tag_value ('SECONDYEAR', 'SECONDYEAR');
               END IF;

-- *****************************************************************************
-- Add Individual Months days and hours
-- *****************************************************************************
               add_tag_value ('YEAR', rec_wtc_get_absence_val.YEAR);
               add_tag_value ('JAN_ABSENCE', rec_wtc_get_absence_val.jan_absence_time);
               add_tag_value ('FEB_ABSENCE', rec_wtc_get_absence_val.feb_absence_time);
               add_tag_value ('MAR_ABSENCE', rec_wtc_get_absence_val.mar_absence_time);
               add_tag_value ('APR_ABSENCE', rec_wtc_get_absence_val.apr_absence_time);
               add_tag_value ('MAY_ABSENCE', rec_wtc_get_absence_val.may_absence_time);
               add_tag_value ('JUN_ABSENCE', rec_wtc_get_absence_val.jun_absence_time);
               add_tag_value ('JUL_ABSENCE', rec_wtc_get_absence_val.jul_absence_time);
               add_tag_value ('AUG_ABSENCE', rec_wtc_get_absence_val.aug_absence_time);
               add_tag_value ('SEP_ABSENCE', rec_wtc_get_absence_val.sep_absence_time);
               add_tag_value ('OCT_ABSENCE', rec_wtc_get_absence_val.oct_absence_time);
               add_tag_value ('NOV_ABSENCE', rec_wtc_get_absence_val.nov_absence_time);
               add_tag_value ('DEC_ABSENCE', rec_wtc_get_absence_val.dec_absence_time);


-- *****************************************************************************
-- to differntiate teh first year and second year end case condition using ROWNUM
-- *****************************************************************************
               IF rec_wtc_get_absence_val.ROWNUM = '1'
               THEN
                  add_tag_value ('FIRSTYEAR', 'FIRSTYEAR_END');
               ELSE
                  add_tag_value ('SECONDYEAR', 'SECONDYEAR_END');
               END IF;
-- *****************************************************************************
            END LOOP;


--**********************************************************************************
            IF rec_get_group.GROUP_ID = '1'
            THEN
               add_tag_value ('REPORTINGYEAR', 'REPORTINGYEAR_END');
            ELSE
               add_tag_value ('OTHERYEAR', 'OTHERYEAR_END');
            END IF;
-- *****************************************************************************
         END LOOP;

         add_tag_value ('PERSON', 'PERSON_END');
      -- END IF;                            /* for p_payroll_action_id IS NULL */

      --logger ('Write TO clob ', 'started');
      writetoclob (p_xml);
--      INSERT INTO clob_table           VALUES (p_xml            );      COMMIT;
      --logger ('Write TO clob ', 'complete');
   END get_xml_for_report;

   -- *****************************************************************************
/* Proc to Add the tag value and Name */
   PROCEDURE logger (p_display IN VARCHAR2, p_value IN VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.LOG
                        , p_display || '          ==> ' || p_value
                        );
   END logger;
/* End of Proc to Add the tag value and Name */
 -- *****************************************************************************
END pay_se_work_time_certificate;

/
