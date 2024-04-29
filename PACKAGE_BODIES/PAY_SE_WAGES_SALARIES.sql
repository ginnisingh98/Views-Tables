--------------------------------------------------------
--  DDL for Package Body PAY_SE_WAGES_SALARIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_WAGES_SALARIES" AS
/* $Header: pysewssa.pkb 120.0.12010000.2 2008/11/03 08:56:37 abraghun ship $ */
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
   g_package                 VARCHAR2 (33)  := 'PAY_SE_FORA.';
   g_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;
-- Globals to pick up all the parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;


   g_legal_employer_id       NUMBER;
   g_local_unit_id           NUMBER;
   g_LE_request             VARCHAR2 (240);
   g_LU_request             VARCHAR2 (240);

   g_posting_date              DATE;
   g_account_date                DATE;
   g_reporting_date              DATE;
   g_year                        NUMBER;
   g_month			 NUMBER;
   g_retroactive_payment_from	 DATE;
   g_retroactive_payment_to	 DATE;
   g_start_date              DATE;
   g_end_date                DATE;
--End of Globals to pick up all the parameter
   g_format_mask             VARCHAR2 (50);
   g_err_num                 NUMBER;
   g_errm                    VARCHAR2 (150);

    /* GET PARAMETER */


    /* GET PARAMETER */
 FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2
    , p_token              IN   VARCHAR2
    , p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      l_parameter   pay_payroll_actions.legislative_parameters%TYPE   := NULL;
      l_start_pos   NUMBER;
      l_delimiter   VARCHAR2 (1)                                      := ' ';
      l_proc        VARCHAR2 (240)           := g_package || ' get parameter ';
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
                  , l_start_pos
                  ,   INSTR (p_parameter_string || ' '
                           , l_delimiter
                           , l_start_pos
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
      p_payroll_action_id        IN              NUMBER        -- In parameter
    , p_business_group_id        OUT NOCOPY      NUMBER      -- Core parameter
    , p_effective_date           OUT NOCOPY      DATE        -- Core parameter
    , p_legal_employer_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_LU_request   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_LOCAL_UNIT_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_MONTH               OUT NOCOPY      NUMBER         -- User parameter
    , p_YEAR               OUT NOCOPY      NUMBER         -- User parameter
    , p_RETROACTIVE_PAYMENT_FROM	OUT NOCOPY	DATE
    , p_RETROACTIVE_PAYMENT_TO		OUT NOCOPY	DATE
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT  (get_parameter
                                                      (legislative_parameters
                                                     , 'LEGAL_EMPLOYER'
                                                      )
                ) LEGAL_EMPLOYER_ID
              , (get_parameter
                                                      (legislative_parameters
                                                     , 'LU_REQUEST'
                                                      )
                ) LU_REQUEST
              ,(get_parameter
                                                      (legislative_parameters
                                                     , 'LOCAL_UNIT'
                                                      )
                ) LOCAL_UNIT_ID
		 ,(get_parameter
                                                      (legislative_parameters
                                                     , 'MONTH'
                                                      )
		) L_MONTH
                ,(get_parameter
                                                      (legislative_parameters
                                                     , 'YEAR'
                                                      )
                ) L_YEAR
		,FND_DATE.canonical_to_date((get_parameter
                                                      (legislative_parameters
                                                     , 'RETROACTIVE_PAYMENT_FROM'
                                                      )
                )) L_RETROACTIVE_PAYMENT_FROM
		,FND_DATE.canonical_to_date((get_parameter
                                                      (legislative_parameters
                                                     , 'RETROACTIVE_PAYMENT_TO'
                                                      )
                )) L_RETROACTIVE_PAYMENT_TO
              , effective_date, business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                       := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN

      OPEN csr_parameter_info (p_payroll_action_id);

      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info
       INTO lr_parameter_info;

      CLOSE csr_parameter_info;

      p_legal_employer_id := lr_parameter_info.legal_employer_id;


      p_LU_request := lr_parameter_info.LU_REQUEST;


      p_local_unit_id := lr_parameter_info.LOCAL_UNIT_ID;

      p_month:=lr_parameter_info.l_month;
      p_year:=lr_parameter_info.l_year;
      p_retroactive_payment_from:=lr_parameter_info.l_retroactive_payment_from;
      p_retroactive_payment_to:=lr_parameter_info.l_retroactive_payment_to;
      p_effective_date := lr_parameter_info.effective_date;
      p_business_group_id := lr_parameter_info.bg_id;


      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS'
                                , 30);
      END IF;
   END get_all_parameters;

   /* RANGE CODE */
   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER
    , p_sql                 OUT NOCOPY      VARCHAR2
   )
   IS
      l_action_info_id           NUMBER;
      l_ovn                      NUMBER;
      l_business_group_id        NUMBER;
      --l_start_date               VARCHAR2 (30);
      --l_end_date                 VARCHAR2 (30);
      l_effective_date           DATE;
      l_consolidation_set        NUMBER;
      l_defined_balance_id       NUMBER                               := 0;
      l_count                    NUMBER                               := 0;
      l_prev_prepay              NUMBER                               := 0;
      l_canonical_start_date     DATE;
      l_canonical_end_date       DATE;
      l_payroll_id               NUMBER;
      l_prepay_action_id         NUMBER;
      l_actid                    NUMBER;
     -- l_assignment_id            NUMBER;
      l_action_sequence          NUMBER;
      l_assact_id                NUMBER;
      l_pact_id                  NUMBER;
      l_flag                     NUMBER                               := 0;
      l_element_context          VARCHAR2 (5);

-- Archiving the data , as this will fire once

-- ********************* for cfar from lU ***********************
CURSOR csr_CFAR_FROM_LU (
         csr_local_unit_ID      NUMBER
      )
      is
      select o1.NAME LU_NAME,hoi2.ORG_INFORMATION2 CFAR
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = g_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and o1.organization_id = csr_local_unit_ID;

lr_CFAR_FROM_LU csr_CFAR_FROM_LU%ROWTYPE;

      CURSOR csr_employee_details(csr_v_person_id number, csr_v_end_date date)
      IS
      SELECT national_identifier, last_name || ' ' || first_name name ,DATE_OF_BIRTH
      FROM
      per_all_people_f WHERE
      BUSINESS_GROUP_ID=g_business_group_id
      AND person_id=csr_v_person_id
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND months_between (csr_v_end_date,DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
      AND months_between (csr_v_end_date,DATE_OF_BIRTH) < 768    /* and age less than 64 */
     ORDER BY last_name || ' ' || first_name;


      CURSOR csr_white_collar(csr_v_person_id number, csr_v_end_date date)
      IS
      SELECT effective_start_date FROM per_all_assignments_f
      WHERE person_id=csr_v_person_id --21233
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND primary_flag='Y'
      AND employee_category='WC'    ;

      CURSOR csr_termination(csr_v_person_id number, csr_v_start_date date, csr_v_end_date date)
      IS
      SELECT MAX(effective_start_date) FROM per_all_people_f papf WHERE
      CURRENT_EMPLOYEE_FLAG IS NULL
      AND person_id=csr_v_person_id--21257
      AND EFFECTIVE_END_DATE --'31-dec-2000'
      BETWEEN csr_v_start_date  AND csr_v_end_date /*'01-jan-2000' AND csr_v_end_date '31-dec-2000'*/
     AND NOT EXISTS
      (SELECT 1 FROM per_all_people_f WHERE
      CURRENT_EMPLOYEE_FLAG='Y'
      AND person_id=papf.person_id --21257
      AND effective_start_date >papf.effective_start_date
      );
      CURSOR csr_assignment_details(csr_v_person_id NUMBER,csr_v_start_date date, csr_v_end_date date)
      IS
      /*SELECT effective_start_date,effective_end_date,pj.JOB_INFORMATION1,employee_category
      FROM
      per_all_people_f papf,
      per_jobs pj
      WHERE person_id=csr_v_person_id   --21257   --21233
      AND csr_v_start_date<=EFFECTIVE_END_DATE AND
      csr_v_end_date>=EFFECTIVE_START_DATE
      AND primary_flag='Y'
      AND pj.job_id=papf.job_id
      AND papf.job_id IS NOT NULL
      AND papf.emloyee_category IS NOT NULL*/

            SELECT paaf.effective_start_date,paaf.effective_end_date,
      decode(pj.JOB_INFORMATION1,'Y','M',null) job,paaf.employee_category,
      payroll_id
      FROM
      per_all_assignments_f paaf,
      per_jobs pj
      WHERE person_id=csr_v_person_id --21197     --21257   --21233
      AND csr_v_start_date <=paaf.EFFECTIVE_END_DATE AND
      csr_v_end_date >=paaf.EFFECTIVE_START_DATE
      AND primary_flag='Y'
      AND pj.job_id(+)=paaf.job_id
--      AND paaf.employee_category IN ('BC','WC')
      AND (paaf.job_id IS NOT NULL
      OR paaf.employee_category IS NOT NULL);


      /*CURSOR csr_painter(csr_v_person_id NUMBER,csr_v_start_date date, csr_v_end_date date)
      IS
      /*SELECT JOB_INFORMATION1 FROM per_jobs pj, per_roles pr
      WHERE pj.job_id=pr.job_id
      AND pj.JOB_INFORMATION_CATEGORY='SE'
      AND pr.person_id=csr_v_person_id; --21257		*/
     /*SELECT JOB_INFORMATION1,start_date, start_date+(e_date-start_date-1) end_date
      FROM
      (
            SELECT JOB_INFORMATION1,start_date,lead( start_date, 1, to_date('31-12-4713','dd-mm-yyyy') )
            over (order by start_date ASC) e_date
            FROM per_jobs pj, per_roles pr
            WHERE pj.job_id=pr.job_id
            AND pj.JOB_INFORMATION_CATEGORY='SE'
            AND pr.person_id=csr_v_person_id /*21197*/--)
      /*WHERE start_date<=csr_v_end_date --'31-dec-2005'
      AND start_date+(e_date-start_date-1)>=csr_v_start_date; /*'01-jan-2005'*/

      CURSOR csr_employee_category(csr_v_person_id number, csr_v_start_date DATE, csr_v_end_date date)
      IS
      SELECT DISTINCT employee_category ,EFFECTIVE_START_DATE
      FROM per_all_assignments_f
      WHERE person_id=csr_v_person_id   --21257   --21233
      AND csr_v_start_date<=EFFECTIVE_END_DATE AND
      csr_v_end_date>=EFFECTIVE_START_DATE
      AND primary_flag='Y'
      ORDER BY EFFECTIVE_START_DATE;

      CURSOR csr_employee_blue_max_date(csr_v_person_id number, csr_v_start_date DATE, csr_v_end_date date)
      IS
      SELECT MAX(EFFECTIVE_end_DATE) FROM
per_all_assignments_f
      WHERE person_id=csr_v_person_id   --21257   --21233
      AND csr_v_start_date<=EFFECTIVE_END_DATE AND
      csr_v_end_date>=EFFECTIVE_START_DATE
      AND employee_category='BC'
      AND primary_flag='Y';

      /*SELECT employee_category FROM per_all_assignments_f
      WHERE person_id=csr_v_person_id --21233
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND primary_flag='Y';*/

      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME legal_employer_name
             -- , hoi2.org_information2 org_number
             -- , hoi1.organization_id legal_id
           FROM hr_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_legal_employer_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

      lr_legal_employer_details   csr_legal_employer_details%ROWTYPE;
      L_LEGAL_EMPLOYER_NAME VARCHAR2(240);

	CURSOR csr_person_local_unit(csr_v_business_group_id number, csr_v_local_unit_id number, csr_v_effective_date date)
	IS
	SELECT papf.person_id --,paaf.assignment_id
	FROM per_all_assignments_f paaf,
	per_all_people_f papf,
	hr_soft_coding_keyflex hsck
	WHERE papf.business_group_id=csr_v_business_group_id -- 3133 --paaf.assignment_id = p_assignment_id
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND papf.person_id=paaf.person_id
	--AND paaf.primary_flag='Y'
	AND hsck.segment2=to_char(csr_v_local_unit_id) --3268)
        AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
        AND paaf.effective_end_date
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
        AND papf.effective_end_date
	AND months_between (csr_v_effective_date,DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
      AND months_between (csr_v_effective_date,DATE_OF_BIRTH) < 768
        AND papf.CURRENT_EMPLOYEE_FLAG='Y'
	AND paaf.employee_category IN ('WC','BC')
	AND paaf.employment_category IN ('SE_VTR','SE_HW') --add one more type
	ORDER BY papf.person_id;

	CURSOR csr_assignment_person(csr_v_person_id number, csr_v_effective_date date)
	IS
	SELECT paaf.assignment_id,
	paaf.employee_category,
	paaf.hourly_salaried_code,
	hsck.SEGMENT9 working_percentage,
	paaf.frequency,
	paaf.normal_hours
	FROM  per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck
	WHERE paaf.person_id=csr_v_person_id
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
        AND paaf.effective_end_date
	AND paaf.employee_category IN ('WC','BC')
	AND paaf.employment_category IN ('SE_VTR','SE_HW') --add one more type
	ORDER BY paaf.assignment_id;

	CURSOR csr_assignment_absence (csr_v_assignment_id number, csr_v_start_date date, csr_v_end_date date)
	is
	SELECT greatest(fnd_Date.canonical_to_date(eev1.screen_entry_value),csr_v_start_date)  start_date,
	least(fnd_Date.canonical_to_date(eev2.screen_entry_value),csr_v_end_date) end_date
	FROM   per_all_assignments_f      asg1
        ,per_all_assignments_f      asg2
        ,per_all_people_f           per
        ,pay_element_links_f        el
        ,pay_element_types_f        et
        ,pay_input_values_f         iv1
        ,pay_input_values_f         iv2
        ,pay_element_entries_f      ee
        ,pay_element_entry_values_f eev1
        ,pay_element_entry_values_f eev2
	WHERE  asg1.assignment_id    = csr_v_assignment_id
	AND csr_v_end_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND csr_v_end_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
	AND  per.person_id         = asg1.person_id
	AND  asg2.person_id        = per.person_id
	--AND  asg2.primary_flag     = 'Y'
	AND  asg1.assignment_id=asg2.assignment_id
	AND  et.element_name       = 'Sickness Details'
	AND  et.legislation_code   = 'SE'
	--OR et.business_group_id=3261      ) --checking for the business group, it should be removed
	AND  iv1.element_type_id   = et.element_type_id
	AND  iv1.name              = 'Start Date'
	AND  iv2.element_type_id   = et.element_type_id
	AND  iv2.name              = 'End Date'
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
	AND  eev2.element_entry_id = ee.element_entry_id
	AND  eev2.input_value_id   = iv2.input_value_id
	AND  ee.effective_start_date  <= csr_v_end_date
	AND  ee.effective_end_date >= csr_v_start_date
	AND  eev1.effective_start_date <= csr_v_end_date
	AND  eev1.effective_end_date >= csr_v_start_date
	AND  eev2.effective_start_date <= csr_v_end_date
	AND  eev2.effective_end_date >= csr_v_start_date;



	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
        IS
        SELECT      ue.creator_id
	FROM     ff_user_entities  ue,
        ff_database_items di
        WHERE     di.user_name = csr_v_Balance_Name
        AND     ue.user_entity_id = di.user_entity_id
        AND     ue.legislation_code = 'SE'
        AND     ue.business_group_id is NULL
        AND     ue.creator_type = 'B';

	CURSOR csr_assignment_action (csr_v_payroll_action_id
    pay_payroll_actions.payroll_action_id%type)
	IS
	SELECT MAX(assignment_action_id)
        FROM pay_Assignment_actions WHERE
        payroll_action_id=csr_v_payroll_action_id; --23

        CURSOR csr_Local_unit_Legal(csr_v_legal_unit_id
	hr_organization_units.organization_id%TYPE)
	IS
	SELECT hoi2.ORG_INFORMATION1 local_unit_id
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =g_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS';

CURSOR csr_local_unit_details (
         csr_v_local_unit_id   hr_organization_information.organization_id%TYPE
      )
      IS
               SELECT o1.NAME local_unit_name
             -- , hoi2.org_information2 org_number
             -- , hoi1.organization_id legal_id
           FROM hr_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_local_unit_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LOCAL_UNIT_DETAILS';

CURSOR csr_payroll_periods(csr_v_effective_date date,csr_v_payroll_id number)
IS
      SELECT START_DATE,end_date FROM per_time_periods WHERE payroll_id=csr_v_payroll_id --3469
      AND /*'15-jan-2005'*/ csr_v_effective_date BETWEEN START_DATE AND end_date;

CURSOR csr_month (csr_v_month NUMBER)
IS
SELECT MEANING
FROM   hr_lookups
WHERE  LOOKUP_TYPE = 'HR_SE_CALENDAR_MONTH'
AND  ENABLED_FLAG = 'Y'
AND  LOOKUP_CODE = csr_v_month; -- 01;

L_MONTH_START_DATE DATE;
L_MONTH_END_DATE DATE;
L_LOCAL_UNIT_NAME VARCHAR2(50);
l_person_id NUMBER;
l_sex CHAR(1);
l_local_unit_id NUMBER;
l_assignment_category VARCHAR2(5);
l_assignment_start_date DATE;
l_assignment_end_date DATE;
l_absence_count NUMBER;
l_employee_category per_all_assignments_f.employee_category%type;
l_person_number per_all_people_f.national_identifier%TYPE;
l_person_name VARCHAR2(350);

l_terminated VARCHAR2(50);

l_gross_salary number;
l_start_date date;
l_end_date date;
l_termination_date date;
lr_Get_Defined_Balance_Id pay_defined_balances.defined_balance_id%type;
l_value number;
l_assignment_id pay_Assignment_actions.assignment_id%type;
l_assignment_action_id pay_Assignment_actions.assignment_action_id%type;
L_CFAR_NUMBER NUMBER;
l_legal_employer_id NUMBER;
l_virtual_date DATE;
l_date_birth per_all_people_f.DATE_OF_BIRTH%TYPE;
l_counter NUMBER :=0;
l_total_salary NUMBER;
l_asg_start_date DATE;
l_asg_end_date date;
l_category per_all_assignments_f.employee_category%type;
l_prev_category per_all_assignments_f.employee_category%type;
l_working_percentage NUMBER;
l_asg_hour_sal per_all_assignments_f.hourly_salaried_code%type;
l_frequency per_all_assignments_f.frequency%type;
l_normal_hours per_all_assignments_f.normal_hours%type;
l_include_event char(1);
l_wrk_schd_return NUMBER;
l_wrk_duration NUMBER;
l_absence_start_date DATE;
l_absence_end_date DATE;
l_bh_worked_calendar_month NUMBER:=0;
l_bh_absence_days NUMBER:=0;
l_bh_worked_payment_period NUMBER:=0;
l_bh_total_employees NUMBER:=0;
l_bs_total_employees NUMBER:=0;
l_ws_total_employees NUMBER:=0;
l_wh_total_employees NUMBER:=0;
l_ws_full_time_employee NUMBER:=0;
l_wh_full_time_employee NUMBER:=0;
l_bs_gross_pay NUMBER:=0;
l_ws_gross_pay NUMBER:=0;
l_wh_gross_pay NUMBER:=0;
l_bh_retroactive_pay NUMBER:=0;
l_bs_retroactive_pay NUMBER:=0;
l_ws_retroactive_pay NUMBER:=0;
l_wh_retroactive_pay NUMBER:=0;
l_bh_sick_pay NUMBER:=0;
l_bs_sick_pay NUMBER:=0;
l_ws_sick_pay NUMBER:=0;
l_wh_sick_pay NUMBER:=0;
l_start_time_char Varchar2(10) :=null; -- '0';
l_end_time_char Varchar2(10) :=null; -- '23.59';
l_bs_working_agreement NUMBER:=0;
l_ws_working_agreement NUMBER:=0;
l_wh_working_agreement NUMBER:=0;
l_month varchar2(50);
TYPE emp_cat_type
IS TABLE OF VARCHAR2(10)
INDEX BY BINARY_INTEGER;
emp_cat emp_cat_type;

TYPE emp_job_record IS RECORD
(
    job VARCHAR2(5),
    end_date date
);
TYPE emp_job_type
IS TABLE OF emp_job_record
INDEX BY BINARY_INTEGER;
emp_job emp_job_type;

TYPE emp_detail_record IS RECORD
(
	l_start_date date,
	l_end_date date,
	l_category varchar2(5),
	l_job varchar2(5),
	l_gross_salary number(17,2),
	l_termination varchar2(5),
	l_white_from date
);
TYPE emp_record_type
IS TABLE OF emp_detail_record
INDEX BY BINARY_INTEGER;
emp_record emp_record_type;

-- VARIABLE FOR THIS REPORET
   BEGIN


      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure RANGE_CODE', 40);
      END IF;

      p_sql       :=
         'SELECT DISTINCT person_id
         	FROM  per_people_f ppf
         	     ,pay_payroll_actions ppa
         	WHERE ppa.payroll_action_id = :payroll_action_id
         	AND   ppa.business_group_id = ppf.business_group_id
         	ORDER BY ppf.person_id';
      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_LU_request :=null;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      g_account_date :=null;
      g_posting_date :=null;
      get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LU_request
                                                , g_local_unit_id
						, g_month
                                                , g_year
						, g_retroactive_payment_from
						, g_retroactive_payment_to
                                                 );

	OPEN csr_legal_employer_details(g_legal_employer_id);
		FETCH csr_legal_employer_details  INTO l_legal_employer_name;
	CLOSE csr_legal_employer_details;

	IF g_local_unit_id IS NOT NULL THEN

		OPEN csr_local_unit_details(g_local_unit_id);
			FETCH csr_local_unit_details INTO L_LOCAL_UNIT_NAME;
		CLOSE csr_local_unit_details;

	END IF;
	l_local_unit_id:=g_local_unit_id;


	g_start_date:=to_date('01-' || g_month || '-' || g_year, 'dd-mm-yyyy');
	g_end_date:=last_day(to_date('01-'|| g_month || '-' || g_year, 'dd-mm-yyyy'));

	/*	OPEN csr_local_unit_details(g_local_unit_id);
			fetch  csr_local_unit_details into L_LOCAL_UNIT_NAME;
		CLOSE csr_local_unit_details;*/
	OPEN csr_month(g_month);
		FETCH csr_month INTO l_month;
	CLOSE csr_month;
	      -- Insert the report Parameters
	pay_action_information_api.create_action_information
	(p_action_information_id            => l_action_info_id
	, p_action_context_id                => p_payroll_action_id
	, p_action_context_type              => 'PA'
	, p_object_version_number            => l_ovn
	, p_effective_date                   => g_effective_date
	, p_source_id                        => NULL
	, p_source_text                      => NULL
	, p_action_information_category      => 'EMEA REPORT DETAILS'
	, p_action_information1              => 'PYSEWSSA'
	, p_action_information2              => g_legal_employer_id
	, p_action_information3              => L_LEGAL_EMPLOYER_NAME
	, p_action_information4              => hr_general.decode_lookup('SE_REQUEST_LEVEL',g_LU_request)
	, p_action_information5              => g_local_unit_id
	, p_action_information6              => L_LOCAL_UNIT_NAME
	, p_action_information7              => l_month --TO_CHAR(TO_DATE(g_month,'MM'),'MONTH')
	, p_action_information8              => g_year
	, p_action_information9              => FND_DATE.DATE_TO_CANONICAL(g_retroactive_payment_from)
	, p_action_information10             => FND_DATE.DATE_TO_CANONICAL(g_retroactive_payment_to)
	);
	-- *****************************************************************************






--	END IF;
--END IF;
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure RANGE_CODE', 50);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Return cursor that selects no rows
         p_sql       :=
               'select 1 from dual where to_char(:payroll_action_id) = dummy';
   END range_code;

   /* ASSIGNMENT ACTION CODE */
   PROCEDURE assignment_action_code (
      p_payroll_action_id   IN   NUMBER
    , p_start_person        IN   NUMBER
    , p_end_person          IN   NUMBER
    , p_chunk               IN   NUMBER
   )
   IS
      CURSOR csr_CFAR_FROM_LU (
         csr_local_unit_ID      NUMBER
      )
      is
         select o1.NAME LU_NAME,hoi2.ORG_INFORMATION2 CFAR
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = g_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and o1.organization_id = csr_local_unit_ID;

lr_CFAR_FROM_LU csr_CFAR_FROM_LU%ROWTYPE;

      CURSOR csr_employee_details(csr_v_person_id number, csr_v_end_date date)
      IS
      SELECT national_identifier, last_name || ' ' || first_name name ,DATE_OF_BIRTH
      FROM
      per_all_people_f WHERE
      BUSINESS_GROUP_ID=g_business_group_id
      AND person_id=csr_v_person_id
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND months_between (csr_v_end_date,DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
      AND months_between (csr_v_end_date,DATE_OF_BIRTH) < 768    /* and age less than 64 */
      ORDER BY last_name || ' ' || first_name;


      CURSOR csr_white_collar(csr_v_person_id number, csr_v_end_date date)
      IS
      SELECT effective_start_date FROM per_all_assignments_f
      WHERE person_id=csr_v_person_id --21233
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND primary_flag='Y'
      AND employee_category='WC'    ;

      CURSOR csr_termination(csr_v_person_id number, csr_v_start_date date, csr_v_end_date date)
      IS
      SELECT MAX(effective_start_date) FROM per_all_people_f papf WHERE
      CURRENT_EMPLOYEE_FLAG IS NULL
      AND person_id=csr_v_person_id--21257
      AND EFFECTIVE_END_DATE --'31-dec-2000'
      BETWEEN csr_v_start_date  AND csr_v_end_date /*'01-jan-2000' AND csr_v_end_date '31-dec-2000'*/
      AND NOT EXISTS
      (SELECT 1 FROM per_all_people_f WHERE
      CURRENT_EMPLOYEE_FLAG='Y'
      AND person_id=papf.person_id --21257
      AND effective_start_date >papf.effective_start_date
      );
      CURSOR csr_assignment_details(csr_v_person_id NUMBER,csr_v_start_date date, csr_v_end_date date)
      IS
      /*SELECT effective_start_date,effective_end_date,pj.JOB_INFORMATION1,employee_category
      FROM
      per_all_people_f papf,
      per_jobs pj
      WHERE person_id=csr_v_person_id   --21257   --21233
      AND csr_v_start_date<=EFFECTIVE_END_DATE AND
      csr_v_end_date>=EFFECTIVE_START_DATE
      AND primary_flag='Y'
      AND pj.job_id=papf.job_id
      AND papf.job_id IS NOT NULL
      AND papf.emloyee_category IS NOT NULL*/

            SELECT paaf.effective_start_date,paaf.effective_end_date,
      decode(pj.JOB_INFORMATION1,'Y','M',null) job,paaf.employee_category,
      payroll_id
      FROM
      per_all_assignments_f paaf,
      per_jobs pj
      WHERE person_id=csr_v_person_id --21197     --21257   --21233
      AND csr_v_start_date <=paaf.EFFECTIVE_END_DATE AND
      csr_v_end_date >=paaf.EFFECTIVE_START_DATE
      AND primary_flag='Y'
      AND pj.job_id(+)=paaf.job_id
--      AND paaf.employee_category IN ('BC','WC')
      AND (paaf.job_id IS NOT NULL
      OR paaf.employee_category IS NOT NULL);


      CURSOR csr_painter(csr_v_person_id NUMBER,csr_v_start_date date, csr_v_end_date date)
      IS
      /*SELECT JOB_INFORMATION1 FROM per_jobs pj, per_roles pr
      WHERE pj.job_id=pr.job_id
      AND pj.JOB_INFORMATION_CATEGORY='SE'
      AND pr.person_id=csr_v_person_id; --21257		*/
     SELECT JOB_INFORMATION1,start_date, start_date+(e_date-start_date-1) end_date
      FROM
      (
            SELECT JOB_INFORMATION1,start_date,lead( start_date, 1, to_date('31-12-4713','dd-mm-yyyy') )
            over (order by start_date ASC) e_date
            FROM per_jobs pj, per_roles pr
            WHERE pj.job_id=pr.job_id
            AND pj.JOB_INFORMATION_CATEGORY='SE'
            AND pr.person_id=csr_v_person_id /*21197*/)
      WHERE start_date<=csr_v_end_date --'31-dec-2005'
      AND start_date+(e_date-start_date-1)>=csr_v_start_date; /*'01-jan-2005'*/

      CURSOR csr_employee_category(csr_v_person_id number, csr_v_start_date DATE, csr_v_end_date date)
      IS
      SELECT DISTINCT employee_category ,EFFECTIVE_START_DATE
      FROM per_all_assignments_f
      WHERE person_id=csr_v_person_id   --21257   --21233
      AND csr_v_start_date<=EFFECTIVE_END_DATE AND
      csr_v_end_date>=EFFECTIVE_START_DATE
      AND primary_flag='Y'
      ORDER BY EFFECTIVE_START_DATE;

      CURSOR csr_employee_blue_max_date(csr_v_person_id number, csr_v_start_date DATE, csr_v_end_date date)
      IS
      SELECT MAX(EFFECTIVE_end_DATE) FROM
per_all_assignments_f
      WHERE person_id=csr_v_person_id   --21257   --21233
      AND csr_v_start_date<=EFFECTIVE_END_DATE AND
      csr_v_end_date>=EFFECTIVE_START_DATE
      AND employee_category='BC'
      AND primary_flag='Y';

      /*SELECT employee_category FROM per_all_assignments_f
      WHERE person_id=csr_v_person_id --21233
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND primary_flag='Y';*/

      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME legal_employer_name
             -- , hoi2.org_information2 org_number
             -- , hoi1.organization_id legal_id
           FROM hr_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_legal_employer_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

      lr_legal_employer_details   csr_legal_employer_details%ROWTYPE;
      L_LEGAL_EMPLOYER_NAME VARCHAR2(240);

	CURSOR csr_person_local_unit(csr_v_business_group_id number, csr_v_local_unit_id number, csr_v_effective_date date)
	IS
	SELECT distinct papf.person_id --,paaf.assignment_id
	FROM per_all_assignments_f paaf,
	per_all_people_f papf,
	hr_soft_coding_keyflex hsck
	WHERE papf.business_group_id=csr_v_business_group_id -- 3133 --paaf.assignment_id = p_assignment_id
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND papf.person_id=paaf.person_id
	and papf.person_id between p_start_person and p_end_person
	--AND paaf.primary_flag='Y'
	AND hsck.segment2=to_char(csr_v_local_unit_id) --3268)
        AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
        AND paaf.effective_end_date
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
        AND papf.effective_end_date
	AND months_between (csr_v_effective_date,DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
        AND months_between (csr_v_effective_date,DATE_OF_BIRTH) < 768
        AND papf.CURRENT_EMPLOYEE_FLAG='Y'
	AND paaf.employee_category IN ('WC','BC')
	AND paaf.employment_category IN ('SE_VTR','SE_HW','SE_PE') --add one more type
	ORDER BY papf.person_id;

	CURSOR csr_assignment_person(csr_v_person_id number, csr_v_effective_date date)
	IS
	SELECT paaf.assignment_id,
	paaf.employee_category,
	paaf.hourly_salaried_code,
	fnd_number.canonical_to_number(hsck.SEGMENT9) working_percentage,
	paaf.frequency,
	paaf.normal_hours
	FROM  per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck
	WHERE paaf.person_id=csr_v_person_id
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
        AND paaf.effective_end_date
	AND paaf.employee_category IN ('WC','BC')
	AND paaf.employment_category IN ('SE_VTR','SE_HW','SE_PE') --add one more type
	ORDER BY paaf.assignment_id;

CURSOR csr_wage_assignment(csr_v_business_group_id number, csr_v_local_unit_id number, csr_v_effective_date date)
	IS
	SELECT paaf.assignment_id,
	paaf.employee_category,
	paaf.hourly_salaried_code,
	fnd_number.canonical_to_number(hsck.SEGMENT9) working_percentage,
	paaf.frequency,
	paaf.normal_hours,
	paaf.payroll_id
	FROM  per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck --,
--	per_all_people_f papf
	WHERE paaf.business_group_id=csr_v_business_group_id
--	papf.person_id=paaf.person_id
	and paaf.person_id between p_start_person and p_end_person
	--AND paaf.primary_flag='Y'
	AND hsck.segment2=to_char(csr_v_local_unit_id)
--	and csr_v_effective_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
--        AND papf.effective_end_date
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
        AND paaf.effective_end_date
	AND paaf.employee_category IN ('WC','BC')
	AND paaf.employment_category IN ('SE_VTR','SE_HW','SE_PE') --add one more type
	AND nvl(hsck.segment10,'N')='N' /* Person is not CEO */
	AND nvl(hsck.segment11,'N')='N' /* Person is not Owner/Joint Owner */
/*	AND months_between (csr_v_end_date,papf.DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
/*    AND months_between (csr_v_end_date,papf.DATE_OF_BIRTH) < 768
    AND papf.CURRENT_EMPLOYEE_FLAG='Y' ;*/
	ORDER BY paaf.assignment_id;

	CURSOR csr_assignment_absence (csr_v_assignment_id number, csr_v_start_date date, csr_v_end_date date)
	is
	SELECT greatest(fnd_Date.canonical_to_date(eev1.screen_entry_value),csr_v_start_date)  start_date,
	least(fnd_Date.canonical_to_date(eev2.screen_entry_value),csr_v_end_date) end_date
	FROM   per_all_assignments_f      asg1
        ,per_all_assignments_f      asg2
        ,per_all_people_f           per
        ,pay_element_links_f        el
        ,pay_element_types_f        et
        ,pay_input_values_f         iv1
        ,pay_input_values_f         iv2
        ,pay_element_entries_f      ee
        ,pay_element_entry_values_f eev1
        ,pay_element_entry_values_f eev2
	WHERE  asg1.assignment_id    = csr_v_assignment_id
	AND csr_v_end_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND csr_v_end_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
	AND  per.person_id         = asg1.person_id
	AND  asg2.person_id        = per.person_id
	--AND  asg2.primary_flag     = 'Y'
	AND  asg1.assignment_id=asg2.assignment_id
	AND  et.element_name       = 'Sickness Details'
	AND  et.legislation_code   = 'SE'
	--OR et.business_group_id=3261      ) --checking for the business group, it should be removed
	AND  iv1.element_type_id   = et.element_type_id
	AND  iv1.name              = 'Start Date'
	AND  iv2.element_type_id   = et.element_type_id
	AND  iv2.name              = 'End Date'
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
	AND  eev2.element_entry_id = ee.element_entry_id
	AND  eev2.input_value_id   = iv2.input_value_id
	AND  ee.effective_start_date  <= csr_v_end_date
	AND  ee.effective_end_date >= csr_v_start_date
	AND  eev1.effective_start_date <= csr_v_end_date
	AND  eev1.effective_end_date >= csr_v_start_date
	AND  eev2.effective_start_date <= csr_v_end_date
	AND  eev2.effective_end_date >= csr_v_start_date;



	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
        IS
        SELECT      ue.creator_id
	FROM     ff_user_entities  ue,
        ff_database_items di
        WHERE     di.user_name = csr_v_Balance_Name
        AND     ue.user_entity_id = di.user_entity_id
        AND     ue.legislation_code = 'SE'
        AND     ue.business_group_id is NULL
        AND     ue.creator_type = 'B';

	CURSOR csr_assignment_action (csr_v_payroll_action_id
    pay_payroll_actions.payroll_action_id%type)
	IS
	SELECT MAX(assignment_action_id)
        FROM pay_Assignment_actions WHERE
        payroll_action_id=csr_v_payroll_action_id; --23

        CURSOR csr_Local_unit_Legal(csr_v_legal_unit_id
	hr_organization_units.organization_id%TYPE)
	IS
	SELECT hoi2.ORG_INFORMATION1 local_unit_id
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =g_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS';

CURSOR csr_local_unit_details (
         csr_v_local_unit_id   hr_organization_information.organization_id%TYPE
      )
      IS
               SELECT o1.NAME local_unit_name
             -- , hoi2.org_information2 org_number
             -- , hoi1.organization_id legal_id
           FROM hr_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_local_unit_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LOCAL_UNIT_DETAILS';

	CURSOR csr_payroll_periods(csr_v_effective_date date,csr_v_payroll_id number)
	IS
	SELECT START_DATE,end_date FROM per_time_periods WHERE payroll_id=csr_v_payroll_id --3469
	AND /*'15-jan-2005'*/ csr_v_effective_date BETWEEN START_DATE AND end_date;

	CURSOR csr_element_types(csr_v_assignment_id  number, csr_v_start_date date, csr_v_end_date date,
	csr_v_element_type_id number, csr_v_input_value_id number)
	IS
	SELECT SUM(RESULT_VALUE) total  --prrv1.* ,paa.assignment_id
        FROM   pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_run_results prr,
        pay_run_result_values prrv1,
        pay_input_values_f pivf,
        pay_element_types_f petf
/*      pay_run_result_values prrv2,
        pay_run_result_values prrv3*/
	WHERE  ppa.effective_date BETWEEN csr_v_start_date --'01-feb-2000' --p_group_start_date --'01-jun-1999' --p_report_start_date
	AND csr_v_end_date --'28-feb-2000'
	/* AND  p_group_end_date /*'01-jun-2000' */--p_report_end_date
	AND  ppa.payroll_action_id = paa.payroll_action_id
	AND  paa.assignment_id =csr_v_assignment_id --32488 --p_assignment_id --21035 --p_assignment_id
	AND  paa.assignment_action_id = prr.assignment_action_id
	AND  prr.element_type_id = petf.element_type_id  --62358 -- p_element_type_id
	AND  petf.element_type_id=csr_v_element_type_id --'Sick Pay 1 to 14 days' --p_element_name	--'Sick Pay 1 to 14 days'
	AND  petf.element_type_id=pivf.element_type_id
	AND  pivf.element_type_id=prr.element_type_id
	AND  prr.run_result_id = prrv1.run_result_id
	AND  prrv1.input_value_id =pivf.input_value_id --139722 --p_input_value_id;
	AND  pivf.Input_value_id=csr_v_input_value_id; --'Sick Hours'  --p_input_name; --'Waiting Day'*/

	cursor csr_wages_details (csr_v_organization_id NUMBER, csr_v_category VARCHAR2, csr_v_display_name VARCHAR2)
	IS
	SELECT org_information3 Type, org_information4 Element_Type_Id, org_information5 Input_value_Id,
	org_information6 Balance_Type_Id,org_information7 Balance_Dimension_Id
	FROM hr_organization_information hoi
	WHERE hoi.organization_id=csr_v_organization_id --3134
	AND hoi.org_information_context='SE_WAGES_SALARY_DETAILS'
	AND hoi.org_information1=csr_v_category --'BH'
	AND hoi.org_information2=csr_v_display_name;--'CCD'

	cursor csr_get_defined_balance(csr_v_balance_type_id NUMBER, csr_v_balance_dimension_id NUMBER)
	is
	SELECT defined_balance_id FROM pay_defined_balances
	WHERE
	balance_type_id=csr_v_balance_type_id --10504412
	AND balance_dimension_id=csr_v_balance_dimension_id; --5525498

    cursor csr_person_assignment(csr_v_assignment_id number, csr_v_start_date date,csr_v_end_date date)
    is
    select 1 from
    per_all_people_f papf,
    per_all_assignments_f paaf
    where papf.person_id=paaf.person_id
    and paaf.assignment_id=csr_v_assignment_id
    and csr_v_end_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
    AND papf.effective_end_date
    and csr_v_end_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
    AND papf.effective_end_date
    AND months_between (csr_v_end_date,DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
    AND months_between (csr_v_end_date,DATE_OF_BIRTH) < 768
    AND papf.CURRENT_EMPLOYEE_FLAG='Y' ;

    cursor csr_category_insert(csr_v_payroll_action_id number, csr_v_category varchar2, csr_v_local_unit_id number )
    is
    select 1 from pay_action_information
    where action_context_id=csr_v_payroll_action_id --45446
    and action_information2=csr_v_category --'BH'
    AND action_information3=csr_v_local_unit_id;

    cursor csr_local_unit_insert(csr_v_payroll_action_id number, csr_v_category varchar2, csr_v_local_unit_id number )
    is
    select 1 from pay_action_information
    where action_context_id=csr_v_payroll_action_id --45446
    and action_information2=csr_v_category --'BH'
    and action_information3=csr_v_local_unit_id;

    CURSOR csr_payroll_period(csr_v_payroll_id number, csr_v_start_date DATE, csr_v_end_date DATE)
    IS
    SELECT papf.period_type, min(ptp.start_date),min(ptp.end_date)
    FROM per_time_periods ptp,
    pay_all_payrolls_f papf
    WHERE ptp.payroll_id=csr_v_payroll_id --4337 --3469
    AND ptp.payroll_id=papf.payroll_id
    AND /*'15-jan-2005'*/ ptp.START_DATE >=csr_v_start_date
    AND ptp.end_date <=csr_v_end_date
    AND csr_v_end_date between papf.EFFECTIVE_START_DATE
    AND papf.EFFECTIVE_end_DATE
    GROUP BY papf.period_type;

    /*CURSOR csr_payroll(csr_v_assignment_id NUMBER, csr_v_start_date DATE, csr_v_end_date DATE)
    IS
    SELECT payroll_id
    FROM per_all_assignments_f
    WHERE assignment_id=csr_v_assignment_id
    AND csr_v_end_date BETWEEN effective_start_date AND
    effective_end_date*/

l_ovn NUMBER;
l_action_info_id NUMBER;
L_MONTH_START_DATE DATE;
L_MONTH_END_DATE DATE;
L_LOCAL_UNIT_NAME VARCHAR2(50);
l_person_id NUMBER;
l_sex CHAR(1);
l_local_unit_id NUMBER;
l_assignment_category VARCHAR2(5);
l_assignment_start_date DATE;
l_assignment_end_date DATE;
l_absence_count NUMBER;
l_employee_category per_all_assignments_f.employee_category%type;
l_person_number per_all_people_f.national_identifier%TYPE;
l_person_name VARCHAR2(350);

l_terminated VARCHAR2(50);

l_gross_salary number;
--l_start_date date;
--l_end_date date;
l_termination_date date;
lr_Get_Defined_Balance_Id pay_defined_balances.defined_balance_id%type;
l_value number;
l_assignment_id pay_Assignment_actions.assignment_id%type;
l_assignment_action_id pay_Assignment_actions.assignment_action_id%type;
L_CFAR_NUMBER NUMBER;
l_legal_employer_id NUMBER;
l_virtual_date DATE;
l_date_birth per_all_people_f.DATE_OF_BIRTH%TYPE;
l_counter NUMBER :=0;
l_total_salary NUMBER;
l_asg_start_date DATE;
l_asg_end_date date;
l_category per_all_assignments_f.employee_category%type;
l_prev_category per_all_assignments_f.employee_category%type;
l_working_percentage NUMBER;
l_asg_hour_sal per_all_assignments_f.hourly_salaried_code%type;
l_frequency per_all_assignments_f.frequency%type;
l_normal_hours per_all_assignments_f.normal_hours%type;
l_include_event char(1);
l_wrk_schd_return NUMBER;
l_wrk_duration NUMBER;
l_absence_start_date DATE;
l_absence_end_date DATE;
l_bh_worked_calendar_month NUMBER:=0;
l_bh_absence_days NUMBER:=0;
l_bh_worked_payment_period NUMBER:=0;
l_bh_total_employees NUMBER:=0;
l_bs_total_employees NUMBER:=0;
l_ws_total_employees NUMBER:=0;
l_wh_total_employees NUMBER:=0;
l_ws_full_time_employee NUMBER:=0;
l_wh_full_time_employee NUMBER:=0;
l_bs_gross_pay NUMBER:=0;
l_ws_gross_pay NUMBER:=0;
l_wh_gross_pay NUMBER:=0;
l_bh_retroactive_pay NUMBER:=0;
l_bs_retroactive_pay NUMBER:=0;
l_ws_retroactive_pay NUMBER:=0;
l_wh_retroactive_pay NUMBER:=0;
l_bh_sick_pay NUMBER:=0;
l_bs_sick_pay NUMBER:=0;
l_ws_sick_pay NUMBER:=0;
l_wh_sick_pay NUMBER:=0;
l_start_time_char Varchar2(10) :=NULL; -- '0';
l_end_time_char Varchar2(10) :=NULL; -- '23.59';
l_bs_working_agreement NUMBER:=0;
l_ws_working_agreement NUMBER:=0;
l_wh_working_agreement NUMBER:=0;
l_type varchar2(50);

l_bh_pbt_value NUMBER:=0;
l_bh_pcow_value NUMBER:=0;
l_bh_nha_value NUMBER:=0;
l_bh_nho_value NUMBER:=0;
l_bh_ppo_value NUMBER:=0;


l_bs_tcdp_value	NUMBER:=0;
l_bs_tcow_value NUMBER:=0;
l_bs_nha_value NUMBER:=0;
l_bs_nho_value NUMBER:=0;
l_bs_ppo_value NUMBER:=0;

l_ws_tcdp_value NUMBER:=0;
l_ws_tcow_value NUMBER:=0;
l_ws_nha_value NUMBER:=0;
l_ws_nho_value NUMBER:=0;
l_ws_ppo_value NUMBER:=0;

l_wh_tcdp_value NUMBER:=0;
l_wh_ppo_value NUMBER:=0;
l_valid_person number;
l_check_insert number;

l_element_type_id pay_element_types_f.element_type_id%TYPE;
l_input_value_id pay_input_values_f.input_value_id%TYPE;
l_balance_type_id pay_balance_types.balance_type_id%TYPE;
l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE;
l_period per_time_period_types.period_type%TYPE;
l_period_start per_time_periods.start_date%TYPE;
l_period_end per_time_periods.end_date%TYPE;
l_bh_worked_period NUMBER:=0;
l_work_hours_days char(1):='D';
l_payroll_id per_all_assignments_f.payroll_id%TYPE;

TYPE emp_cat_type
IS TABLE OF VARCHAR2(10)
INDEX BY BINARY_INTEGER;
emp_cat emp_cat_type;

TYPE emp_job_record IS RECORD
(
    job VARCHAR2(5),
    end_date date
);
TYPE emp_job_type
IS TABLE OF emp_job_record
INDEX BY BINARY_INTEGER;
emp_job emp_job_type;

TYPE emp_detail_record IS RECORD
(
	l_start_date date,
	l_end_date date,
	l_category varchar2(5),
	l_job varchar2(5),
	l_gross_salary number(17,2),
	l_termination varchar2(5),
	l_white_from date
);
TYPE emp_record_type
IS TABLE OF emp_detail_record
INDEX BY BINARY_INTEGER;
emp_record emp_record_type;
--------------

   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure ARCHIVE_CODE', 380);
      END IF;

/*    TCDP	-->	Total of variable add.pay excl. of comp for on-call duties and payment in kind (SEK)
      TCOW	-->	Total variable, compensation for overtime worked (SEK)
      CCD	-->	Compensation for on-call duties and payment in kind (SEK)
      PBT	-->	Paid out salaries (for hours worked) before tax deduction (gross pay)
      PCOW	-->	Paid out compensation for overtime worked (SEK)
      NHA	-->	Number of Hours worked in the actual payment period
      NHO	-->	Number of Hours, number of hours overtime worked(hours)
      PPO	-->	Varaiable add. payments from previous payments periods (SEK)*/

      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_LU_request :=null;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      g_account_date :=null;
      g_posting_date :=null;
      get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LU_request
                                                , g_local_unit_id
						, g_month
                                                , g_year
						, g_retroactive_payment_from
						, g_retroactive_payment_to
                                         );
	g_start_date:=to_date('01-' || g_month || '-' || g_year, 'dd-mm-yyyy');
	--g_end_date:=to_date('31-'|| g_month || '-' || g_year, 'dd-mm-yyyy');
	g_end_date:=last_day(to_date('01-'|| g_month || '-' || g_year, 'dd-mm-yyyy'));



	OPEN csr_legal_employer_details(g_legal_employer_id);
		FETCH csr_legal_employer_details  INTO l_legal_employer_name;
	CLOSE csr_legal_employer_details;

	IF g_local_unit_id IS NOT NULL THEN

		OPEN csr_local_unit_details(g_local_unit_id);
			FETCH csr_local_unit_details INTO L_LOCAL_UNIT_NAME;
		CLOSE csr_local_unit_details;

	END IF;
	l_local_unit_id:=g_local_unit_id;

       	IF g_LU_request ='LU_SELECTED' THEN
		/* THis is for Given LOCAL UNIT */


		OPEN csr_CFAR_FROM_LU (g_local_unit_id);
			FETCH csr_CFAR_FROM_LU INTO lr_CFAR_FROM_LU;
		CLOSE csr_CFAR_FROM_LU;

		L_CFAR_NUMBER :=lr_CFAR_FROM_LU.CFAR;
		l_local_unit_name:=lr_CFAR_FROM_LU.LU_NAME;

		/* check whether record has been inserted for White Collar Hourly Employee */
                open csr_local_unit_insert(p_payroll_action_id,'LU',g_local_unit_id);
			fetch csr_local_unit_insert into l_check_insert;
                close csr_local_unit_insert;
		if l_check_insert is null then
		      pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'LU'
					, p_action_information3              => g_local_unit_id
					, p_action_information4              => l_local_unit_name --lr_CFAR_FROM_LU.LU_NAME
					, p_action_information5              => null --L_CFAR_NUMBER
					, p_action_information6              => NULL
					, p_action_information7              => NULL
					);
		end if;
--		FOR csr_person IN csr_person_local_unit(g_business_group_id, g_local_unit_id, g_end_date /*g_effective_date*/) LOOP
		--l_person_id:=csr_person.person_id;
		--fnd_file.put_line(fnd_file.LOG,'l_person_id'||l_person_id);
		pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id); --133942);
		pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id); --3621);
		FOR csr_assignment IN csr_wage_assignment(g_business_group_id, g_local_unit_id, g_end_date)  LOOP
			l_assignment_id:=csr_assignment.assignment_id;
			l_working_percentage:=csr_assignment.working_percentage;
			l_asg_hour_sal:=csr_assignment.hourly_salaried_code;
			l_employee_category:=csr_assignment.employee_category;
			l_frequency:=csr_assignment.frequency;
			l_normal_hours:=csr_assignment.normal_hours;
			l_payroll_id:=csr_assignment.payroll_id;
			/* Calculating the number of days actually worked */
			/* Blue Collar Hourly Employee */
			open csr_person_assignment(l_assignment_id,g_start_date,g_end_date);
			    fetch csr_person_assignment into l_valid_person;
			close csr_person_assignment;
			IF l_valid_person is not null THEN
				/* Getting the payroll period and payroll details */
				OPEN csr_payroll_period(l_payroll_id,g_start_Date, g_end_date);
					FETCH csr_payroll_period INTO l_period,l_period_start,l_period_end;
				CLOSE csr_payroll_period;

				IF l_employee_category='BC' AND l_asg_hour_sal='H' THEN
					l_include_event:='Y';
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( l_assignment_id, l_work_hours_days, l_include_event,
								g_start_Date, g_end_date,l_start_time_char,
								l_end_time_char, l_wrk_duration
								);
					l_bh_worked_calendar_month:=l_wrk_duration;
					--l_bh_worked_calendar_month:=l_bh_worked_calendar_month+l_wrk_duration;
					l_wrk_duration:=0;
					IF l_period_end IS NOT NULL THEN
						FOR csr_absence IN csr_assignment_absence(l_assignment_id, l_period_start, l_period_end) LOOP
							l_absence_start_date:= csr_absence.start_date;
							l_absence_end_date:= csr_absence.end_date;
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
									( l_assignment_id, l_work_hours_days, l_include_event,
									l_absence_start_date, l_absence_end_date,l_start_time_char,
									l_end_time_char, l_wrk_duration
									);
							l_bh_absence_days:= l_bh_absence_days+l_wrk_duration;
							l_wrk_duration:=0;
						END LOOP;
						/* To get the working days within the period */
						l_include_event:='Y';
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
									( l_assignment_id, l_work_hours_days, l_include_event,
									l_period_start, l_period_end,l_start_time_char,
									l_end_time_char, l_wrk_duration
									);
						l_bh_worked_period:=l_wrk_duration;
						l_bh_worked_period:=l_bh_worked_period-l_bh_absence_days;
						IF l_period='Week' THEN
							l_bh_worked_payment_period:=l_bh_worked_payment_period+round(l_bh_worked_period*2);
						ELSIF l_period='Calendar Month' THEN
							l_bh_worked_payment_period:=l_bh_worked_payment_period+ round(l_bh_worked_period/2);
						END IF;
						--l_bh_absence_days:=0;
						/* PBT Value */
						FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'PBT') LOOP
							l_type:=csr_wages.Type;
							l_element_type_id:=csr_wages.Element_Type_Id;
							l_input_value_id:=csr_wages.Input_value_Id;
							l_balance_type_id:=csr_wages.Balance_Type_Id;
							l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

							/* check whether value has been entered in EIT*/
							IF l_type IS NOT NULL THEN
								/* If element is selected */
								IF l_type='ELEMENT' THEN
									OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
										FETCH csr_element_types INTO l_value;
									CLOSE csr_element_types;

								ELSE
									OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
										FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
									CLOSE csr_get_defined_balance;

									l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
								END IF;
								IF l_period='Week' THEN
									l_value:=l_value*2;
								ELSIF l_period='Calendar Month' THEN
									l_value:=l_value/2;
								END IF;
								--l_bh_pbt_value:=l_value;
								l_bh_pbt_value:=l_bh_pbt_value+round(nvl(l_value,0));
								l_value:=NULL;
								l_type:=NULL;

							END IF;
						END LOOP;
						/* PCOW Value */
						FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'PCOW') LOOP
							l_type:=csr_wages.Type;
							l_element_type_id:=csr_wages.Element_Type_Id;
							l_input_value_id:=csr_wages.Input_value_Id;
							l_balance_type_id:=csr_wages.Balance_Type_Id;
							l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

							/* check whether value has been entered in EIT*/
							IF l_type IS NOT NULL THEN
								/* If element is selected */
								IF l_type='ELEMENT' THEN
									OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
										FETCH csr_element_types INTO l_value;
									CLOSE csr_element_types;

								ELSE
									OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
										FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
									CLOSE csr_get_defined_balance;

									l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
								END IF;
								IF l_period='Week' THEN
									l_value:=l_value*2;
								ELSIF l_period='Calendar Month' THEN
									l_value:=l_value/2;
								END IF;
									--l_bh_pcow_value:=l_value;
									l_bh_pcow_value:=l_bh_pcow_value+round(nvl(l_value,0));
									l_value:=NULL;
									l_type:=NULL;
							END IF;
						END LOOP;
						/* NHA Value */
						FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'NHA') LOOP
							l_type:=csr_wages.Type;
							l_element_type_id:=csr_wages.Element_Type_Id;
							l_input_value_id:=csr_wages.Input_value_Id;
							l_balance_type_id:=csr_wages.Balance_Type_Id;
							l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

							/* check whether value has been entered in EIT*/
							IF l_type IS NOT NULL THEN
								/* If element is selected */
								IF l_type='ELEMENT' THEN
									OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
										FETCH csr_element_types INTO l_value;
									CLOSE csr_element_types;

								ELSE
									OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
										FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
									CLOSE csr_get_defined_balance;

									l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
								END IF;
								IF l_period='Week' THEN
									l_value:=l_value*2;
								ELSIF l_period='Calendar Month' THEN
									l_value:=l_value/2;
								END IF;
									--l_bh_nha_value:=l_value;
									l_bh_nha_value:=l_bh_nha_value+round(nvl(l_value,0));
									l_value:=NULL;
									l_type:=NULL;
							END IF;
						END LOOP;
						/* NHO Value */
						FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'NHO') LOOP
							l_type:=csr_wages.Type;
							l_element_type_id:=csr_wages.Element_Type_Id;
							l_input_value_id:=csr_wages.Input_value_Id;
							l_balance_type_id:=csr_wages.Balance_Type_Id;
							l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

							/* check whether value has been entered in EIT*/
							IF l_type IS NOT NULL THEN
								/* If element is selected */
								IF l_type='ELEMENT' THEN
									OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
										FETCH csr_element_types INTO l_value;
									CLOSE csr_element_types;

								ELSE
									OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
										FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
									CLOSE csr_get_defined_balance;

									l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
								END IF;
								IF l_period='Week' THEN
									l_value:=l_value*2;
								ELSIF l_period='Calendar Month' THEN
									l_value:=l_value/2;
								END IF;
								--l_bh_nho_value:=l_value;
								l_bh_nho_value:=l_bh_nho_value+round(nvl(l_value,0));
								l_value:=NULL;
								l_type:=NULL;
							END IF;
						END LOOP;
						/*Retroactive payment _ASG_LU_PTD */
						pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
						OPEN  csr_Get_Defined_Balance_Id( 'RETROSPECTIVE_PAYMENTS_ASG_LU_PTD');
							FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;
						l_value:=nvl(pay_balance_pkg.get_value
						 (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
						  P_ASSIGNMENT_ID =>l_assignment_id, --32488,
						  P_VIRTUAL_DATE =>l_period_end--  '31-jan-2000'
						  ),0);
						--l_bh_retroactive_pay:=l_value;
						IF l_period='Week' THEN
							l_value:=l_value*2;
						ELSIF l_period='Calendar Month' THEN
							l_value:=l_value/2;
						END IF;
						l_bh_retroactive_pay:=l_bh_retroactive_pay+round(nvl(l_value,0));
						l_value:=NULL;
						l_type:=NULL;
						/* PPO Value */
						FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'PPO') LOOP
							l_type:=csr_wages.Type;
							l_element_type_id:=csr_wages.Element_Type_Id;
							l_input_value_id:=csr_wages.Input_value_Id;
							l_balance_type_id:=csr_wages.Balance_Type_Id;
							l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

							/* check whether value has been entered in EIT*/
							IF l_type IS NOT NULL THEN
								/* If element is selected */
								IF l_type='ELEMENT' THEN
									OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
										FETCH csr_element_types INTO l_value;
									CLOSE csr_element_types;

								ELSE
									OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
										FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
									CLOSE csr_get_defined_balance;

									l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
								END IF;
								IF l_period='Week' THEN
									l_value:=l_value*2;
								ELSIF l_period='Calendar Month' THEN
									l_value:=l_value/2;
								END IF;
								--l_bh_ppo_value:=l_value;
								l_bh_ppo_value:=l_bh_ppo_value+round(nvl(l_value,0));
								l_value:=NULL;
								l_type:=NULL;
							END IF;
						END LOOP;

						/*Total Sick Pay _ASG_LU_PTD */
						pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
						OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SICK_PAY_ASG_LU_PTD');
							FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;
						l_value:=nvl(pay_balance_pkg.get_value
						 (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
						  P_ASSIGNMENT_ID =>l_assignment_id, --32488,
						  P_VIRTUAL_DATE =>l_period_end--  '31-jan-2000'
						  ),0);
						--l_bh_sick_pay:=l_value;
						IF l_period='Week' THEN
							l_value:=l_value*2;
						ELSIF l_period='Calendar Month' THEN
							l_value:=l_value/2;
						END IF;
						l_bh_sick_pay:=l_bh_sick_pay+round(nvl(l_value,0));
						l_value:=NULL;
						l_type:=NULL;
					END IF;
					/*Total count of the employees*/
					l_bh_total_employees:=l_bh_total_employees+1;

				/* Blue Collar Salaried Employee */
				ELSIF l_employee_category='BC' AND l_asg_hour_sal='S' THEN
					/*Gross Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'GROSS_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
					  ),0);
					--l_bs_gross_pay:=l_value;
					l_bs_gross_pay:=l_bs_gross_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/*Total Working hours agreement */
					/*IF l_frequency='M' THEN
						l_bs_working_agreement:=l_bs_working_agreement+l_normal_hours;
					END IF;*/
					IF l_frequency='W' THEN
						l_normal_hours:=l_normal_hours*4.3;
					END IF;
					l_bs_working_agreement:=l_bs_working_agreement+round(l_normal_hours);
					/* TCDP Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'TCDP') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;
						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_tcdp_value:=l_value;
							l_bs_tcdp_value:=l_bs_tcdp_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* TCOW Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'TCOW') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_tcow_value:=l_value;
							l_bs_tcow_value:=l_bs_tcow_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* NHA Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'NHA') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;
						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;
							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;
								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_nha_value:=l_value;
							l_bs_nha_value:=l_bs_nha_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
				        /* NHO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'NHO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;
						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;
							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_nho_value:=l_value;
							l_bs_nho_value:=l_bs_nho_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
							lr_Get_Defined_Balance_Id:=NULL;

						END IF;
					END LOOP;
					/*Retroactive payment _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'RETROSPECTIVE_PAYMENTS_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_bs_retroactive_pay:=l_value;
					l_bs_retroactive_pay:=l_bs_retroactive_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/* PPO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'PPO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;
						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_ppo_value:=l_value;
							l_bs_ppo_value:=l_bs_ppo_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/*Total Sick Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SICK_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_bs_sick_pay:=l_value;
					l_bs_sick_pay:=l_bs_sick_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/*Total count of the employees*/
					l_bs_total_employees:=l_bs_total_employees+1;

				/*White Collar Salaried Employee */
				ELSIF l_employee_category='WC' AND l_asg_hour_sal='S' THEN
					/* Number of Full Time Employees */
					--IF l_working_percentage=100 THEN

						l_ws_full_time_employee:=l_ws_full_time_employee+round(nvl(l_working_percentage,100)/100,2);
					--END IF;

					/*Gross Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'GROSS_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_ws_gross_pay:=l_value;
					l_ws_gross_pay:=l_ws_gross_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/*Total Working hours agreement */
					IF l_frequency='W' THEN
						l_normal_hours:=l_normal_hours*4.3;
					END IF;
					l_ws_working_agreement:=l_ws_working_agreement+round(l_normal_hours);


					/* TCDP Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'TCDP') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_tcdp_value:=l_value;
							l_ws_tcdp_value:=l_ws_tcdp_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* TCOW Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'TCOW') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_tcow_value:=l_value;
							l_ws_tcow_value:=l_ws_tcow_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* NHA Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'NHA') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_nha_value:=l_value;
							l_ws_nha_value:=l_ws_nha_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
				        /* NHO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'NHO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_nho_value:=l_value;
							l_ws_nho_value:=l_ws_nho_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/*Retroactive payment _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'RETROSPECTIVE_PAYMENTS_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_ws_retroactive_pay:=l_value;
					l_ws_retroactive_pay:=l_ws_retroactive_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;

					/* PPO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'PPO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
								--l_ws_ppo_value:=l_value;
								l_ws_ppo_value:=l_ws_ppo_value+round(nvl(l_value,0));
								l_value:=NULL;
								l_type:=NULL;
							END IF;
						END IF;
					END LOOP;
					/*Total Sick Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SICK_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_ws_sick_pay:=l_value;
					l_ws_sick_pay:=l_ws_sick_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;

					/*Total count of the employees*/
					l_ws_total_employees:=l_ws_total_employees+1;
				END IF;
				l_type:=NULL;
				l_element_type_id:=NULL;
				l_input_value_id:=NULL;
				l_balance_type_id:=NULL;
				l_balance_dimension_id:=NULL;
				l_period:=NULL;
				l_period_start:=NULL;
				l_period_end:=NULL;
			END IF;
			l_valid_person:=null;
		END LOOP;
	    /* check whether there are Blue collar Hourly Employees on current Local unit*/
	    IF l_bh_total_employees<>0 THEN
	    /* check whether record has been inserted for Blue Collar Hourly Employee */
            open csr_category_insert(p_payroll_action_id,'BH',l_local_unit_id);
                fetch csr_category_insert into l_check_insert;
            --close csr_category_insert;
            --if l_check_insert is null then
	    IF csr_category_insert%NOTFOUND THEN
            /*Insert the record*/
            pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'BH'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => l_bh_worked_calendar_month
					, p_action_information5              => l_bh_worked_payment_period
					, p_action_information6              => NULL
					, p_action_information7              => NULL
					, p_action_information8              => NULL
					, p_action_information9              => NULL
					, p_action_information10             => NULL
					, p_action_information11             => NULL
					, p_action_information12             => l_bh_pbt_value
					, p_action_information13             => l_bh_pcow_value
					, p_action_information14             => l_bh_nha_value
					, p_action_information15             => l_bh_nho_value
					, p_action_information16             => l_bh_retroactive_pay
					, p_action_information17             => l_bh_ppo_value
					, p_action_information18             => l_bh_sick_pay
					, p_action_information19             => l_bh_total_employees
					);
            else
            /*update the record*/
                    update pay_action_information set
                    --action_information4=action_information4+l_bh_worked_calendar_month,
                    action_information5=action_information5+l_bh_worked_payment_period,
                    action_information12=action_information12+l_bh_pbt_value,
                    action_information13=action_information13+l_bh_pcow_value,
                    action_information14=action_information14+l_bh_nha_value,
                    action_information15=action_information15+l_bh_nho_value,
                    action_information16=action_information16+l_bh_retroactive_pay,
                    action_information17=action_information17+l_bh_ppo_value,
                    action_information18=action_information18+l_bh_sick_pay,
                    action_information19=action_information19+l_bh_total_employees
                    where action_context_id=p_payroll_action_id
                    and action_information2='BH'
      		    AND action_information3=l_local_unit_id;

            end if;
	    close csr_category_insert;
            l_check_insert:=null;
	    END IF;
	    /* check whether there are Blue collar Salaried Employees on current Local unit*/
	    IF l_bs_total_employees<>0 THEN
            /* check whether record has been inserted for Blue Collar Salaried Employee */
            open csr_category_insert(p_payroll_action_id,'BS',l_local_unit_id);
                fetch csr_category_insert into l_check_insert;
            --close csr_category_insert;
            --if l_check_insert is null then
	    IF csr_category_insert%NOTFOUND THEN
            /*Insert the record*/
            pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'BS'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => null
					, p_action_information5              => null
					, p_action_information6              => null
					, p_action_information7              => l_bs_gross_pay
					, p_action_information8              => l_bs_working_agreement
					, p_action_information9              => l_bs_tcdp_value
					, p_action_information10             => l_bs_tcow_value
					, p_action_information11             => NULL
					, p_action_information12             => NULL
					, p_action_information13             => NULL
					, p_action_information14             => l_bs_nha_value
					, p_action_information15             => l_bs_nho_value
					, p_action_information16             => l_bs_retroactive_pay
					, p_action_information17             => l_bs_ppo_value
					, p_action_information18             => l_bs_sick_pay
					, p_action_information19             => l_bs_total_employees
					);
            else
            /*update the record*/
                    update pay_action_information set
                    action_information7=action_information7+l_bs_gross_pay,
                    action_information8=action_information8+l_bs_working_agreement,
                    action_information9=action_information9+l_bs_tcdp_value,
                    action_information10=action_information10+l_bs_tcow_value,
                    action_information14=action_information14+l_bs_nha_value,
                    action_information15=action_information15+l_bs_nho_value,
                    action_information16=action_information16+l_bs_retroactive_pay,
                    action_information17=action_information17+l_bs_ppo_value,
                    action_information18=action_information18+l_bs_sick_pay,
                    action_information19=action_information19+l_bs_total_employees
                    where action_context_id=p_payroll_action_id
                    and action_information2='BS'
       		    AND action_information3=l_local_unit_id;

            end if;
	    close csr_category_insert;
            l_check_insert:=null;
	    END IF;
	    /* check whether there are White collar Salaried Employees on current Local unit*/
	    IF l_ws_total_employees<>0 THEN
            /* check whether record has been inserted for White Collar Salaried Employee */
            open csr_category_insert(p_payroll_action_id,'WS',l_local_unit_id);
                fetch csr_category_insert into l_check_insert;
            --close csr_category_insert;
            --if l_check_insert is null then
	    IF csr_category_insert%NOTFOUND THEN
            /*Insert the record*/
            pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'WS'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => null
					, p_action_information5              => null
					, p_action_information6              => l_ws_full_time_employee
					, p_action_information7              => l_ws_gross_pay
					, p_action_information8              => l_ws_working_agreement
					, p_action_information9              => l_ws_tcdp_value
					, p_action_information10             => l_ws_tcow_value
					, p_action_information11             => NULL
					, p_action_information12             => NULL
					, p_action_information13             => NULL
					, p_action_information14             => l_ws_nha_value
					, p_action_information15             => l_ws_nho_value
					, p_action_information16             => l_ws_retroactive_pay
					, p_action_information17             => l_ws_ppo_value
					, p_action_information18             => l_ws_sick_pay
					, p_action_information19             => l_ws_total_employees
					);
            else
            /*update the record*/
                    update pay_action_information set
                    action_information6=action_information6+l_ws_full_time_employee,
                    action_information7=action_information7+l_ws_gross_pay,
                    action_information8=action_information8+l_ws_working_agreement,
                    action_information9=action_information9+l_ws_tcdp_value,
                    action_information10=action_information10+l_ws_tcow_value,
                    action_information14=action_information14+l_ws_nha_value,
                    action_information15=action_information15+l_ws_nho_value,
                    action_information16=action_information16+l_ws_retroactive_pay,
                    action_information17=action_information17+l_ws_ppo_value,
                    action_information18=action_information18+l_ws_sick_pay,
                    action_information19=action_information19+l_ws_total_employees
                    where action_context_id=p_payroll_action_id
                    and action_information2='WS'
       		    AND action_information3=l_local_unit_id;

            end if;
	    close csr_category_insert;
            l_check_insert:=null;
	    END IF;
    ELSE
    /* if all the local units under the legal employer is selected */
        for csr_local in csr_Local_unit_Legal(g_legal_employer_id ) loop
		l_local_unit_id:=csr_local.local_unit_id;

		OPEN csr_CFAR_FROM_LU (l_local_unit_id);
			FETCH csr_CFAR_FROM_LU INTO lr_CFAR_FROM_LU;
		CLOSE csr_CFAR_FROM_LU;

		L_CFAR_NUMBER :=lr_CFAR_FROM_LU.CFAR;
		l_local_unit_name:=lr_CFAR_FROM_LU.LU_NAME;

		/* check whether record has been inserted for White Collar Hourly Employee */
		open csr_local_unit_insert(p_payroll_action_id,'LU',l_local_unit_id);
			fetch csr_local_unit_insert into l_check_insert;
		close csr_local_unit_insert;
		if l_check_insert is null then
		      pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'LU'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => l_local_unit_name --lr_CFAR_FROM_LU.LU_NAME
					, p_action_information5              => null --L_CFAR_NUMBER
					, p_action_information6              => NULL
					, p_action_information7              => NULL
					);
		end if;
--		FOR csr_person IN csr_person_local_unit(g_business_group_id, g_local_unit_id, g_end_date /*g_effective_date*/) LOOP
		--l_person_id:=csr_person.person_id;
		--fnd_file.put_line(fnd_file.LOG,'l_person_id'||l_person_id);
		pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id); --133942);
		pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id); --3621);
		FOR csr_assignment IN csr_wage_assignment(g_business_group_id, l_local_unit_id, g_end_date)  LOOP
			l_assignment_id:=csr_assignment.assignment_id;
			l_working_percentage:=csr_assignment.working_percentage;
			l_asg_hour_sal:=csr_assignment.hourly_salaried_code;
			l_employee_category:=csr_assignment.employee_category;
			l_frequency:=csr_assignment.frequency;
			l_normal_hours:=csr_assignment.normal_hours;
			l_payroll_id:=csr_assignment.payroll_id;
			/* Calculating the number of days actually worked */
			/* Blue Collar Hourly Employee */
			open csr_person_assignment(l_assignment_id,g_start_date,g_end_date);
			    fetch csr_person_assignment into l_valid_person;
			close csr_person_assignment;
			IF l_valid_person IS NOT NULL THEN
				/* Getting the payroll period and payroll details */
				OPEN csr_payroll_period(l_payroll_id,g_start_Date, g_end_date);
					FETCH csr_payroll_period INTO l_period,l_period_start,l_period_end;
				CLOSE csr_payroll_period;

					IF l_employee_category='BC' AND l_asg_hour_sal='H' THEN
						l_include_event:='Y';
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
									( l_assignment_id, l_work_hours_days, l_include_event,
									g_start_Date, g_end_date,l_start_time_char,
									l_end_time_char, l_wrk_duration
									);
						l_bh_worked_calendar_month:=l_wrk_duration;
						--l_bh_worked_calendar_month:=l_bh_worked_calendar_month+l_wrk_duration;
						l_wrk_duration:=0;
						IF l_period_end IS NOT NULL THEN
							FOR csr_absence IN csr_assignment_absence(l_assignment_id, l_period_start, l_period_end) LOOP
								l_absence_start_date:= csr_absence.start_date;
								l_absence_end_date:= csr_absence.end_date;
								l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
										( l_assignment_id, l_work_hours_days, l_include_event,
										l_absence_start_date, l_absence_end_date,l_start_time_char,
										l_end_time_char, l_wrk_duration
										);
								l_bh_absence_days:= l_bh_absence_days+l_wrk_duration;
								l_wrk_duration:=0;
							END LOOP;
							/* To get the working days within the period */
							l_include_event:='Y';
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
										( l_assignment_id, l_work_hours_days, l_include_event,
										l_period_start, l_period_end,l_start_time_char,
										l_end_time_char, l_wrk_duration
										);
							l_bh_worked_period:=l_wrk_duration;
							l_bh_worked_period:=l_bh_worked_period-l_bh_absence_days;
							IF l_period='Week' THEN
								l_bh_worked_payment_period:=l_bh_worked_payment_period+round(l_bh_worked_period*2);
							ELSIF l_period='Calendar Month' THEN
								l_bh_worked_payment_period:=l_bh_worked_payment_period+round(l_bh_worked_period/2);
							END IF;
							--l_bh_absence_days:=0;
							/* PBT Value */
							FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'PBT') LOOP
								l_type:=csr_wages.Type;
								l_element_type_id:=csr_wages.Element_Type_Id;
								l_input_value_id:=csr_wages.Input_value_Id;
								l_balance_type_id:=csr_wages.Balance_Type_Id;
								l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

								/* check whether value has been entered in EIT*/
								IF l_type IS NOT NULL THEN
									/* If element is selected */
									IF l_type='ELEMENT' THEN
										OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
											FETCH csr_element_types INTO l_value;
										CLOSE csr_element_types;

									ELSE
										OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
											FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
										CLOSE csr_get_defined_balance;

										l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
									END IF;
									IF l_period='Week' THEN
										l_value:=l_value*2;
									ELSIF l_period='Calendar Month' THEN
										l_value:=l_value/2;
									END IF;
									--l_bh_pbt_value:=l_value;
									l_bh_pbt_value:=l_bh_pbt_value+round(nvl(l_value,0));
									l_value:=NULL;
									l_type:=NULL;

								END IF;
							END LOOP;
							/* PCOW Value */
							FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'PCOW') LOOP
								l_type:=csr_wages.Type;
								l_element_type_id:=csr_wages.Element_Type_Id;
								l_input_value_id:=csr_wages.Input_value_Id;
								l_balance_type_id:=csr_wages.Balance_Type_Id;
								l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

								/* check whether value has been entered in EIT*/
								IF l_type IS NOT NULL THEN
									/* If element is selected */
									IF l_type='ELEMENT' THEN
										OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
											FETCH csr_element_types INTO l_value;
										CLOSE csr_element_types;

									ELSE
										OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
											FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
										CLOSE csr_get_defined_balance;

										l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
									END IF;
									IF l_period='Week' THEN
										l_value:=l_value*2;
									ELSIF l_period='Calendar Month' THEN
										l_value:=l_value/2;
									END IF;
										--l_bh_pcow_value:=l_value;
										l_bh_pcow_value:=l_bh_pcow_value+round(nvl(l_value,0));
										l_value:=NULL;
										l_type:=NULL;
								END IF;
							END LOOP;
							/* NHA Value */
							FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'NHA') LOOP
								l_type:=csr_wages.Type;
								l_element_type_id:=csr_wages.Element_Type_Id;
								l_input_value_id:=csr_wages.Input_value_Id;
								l_balance_type_id:=csr_wages.Balance_Type_Id;
								l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

								/* check whether value has been entered in EIT*/
								IF l_type IS NOT NULL THEN
									/* If element is selected */
									IF l_type='ELEMENT' THEN
										OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
											FETCH csr_element_types INTO l_value;
										CLOSE csr_element_types;

									ELSE
										OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
											FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
										CLOSE csr_get_defined_balance;

										l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
									END IF;
									IF l_period='Week' THEN
										l_value:=l_value*2;
									ELSIF l_period='Calendar Month' THEN
										l_value:=l_value/2;
									END IF;
										--l_bh_nha_value:=l_value;
										l_bh_nha_value:=l_bh_nha_value+round(nvl(l_value,0));
										l_value:=NULL;
										l_type:=NULL;
								END IF;
							END LOOP;
							/* NHO Value */
							FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'NHO') LOOP
								l_type:=csr_wages.Type;
								l_element_type_id:=csr_wages.Element_Type_Id;
								l_input_value_id:=csr_wages.Input_value_Id;
								l_balance_type_id:=csr_wages.Balance_Type_Id;
								l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

								/* check whether value has been entered in EIT*/
								IF l_type IS NOT NULL THEN
									/* If element is selected */
									IF l_type='ELEMENT' THEN
										OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
											FETCH csr_element_types INTO l_value;
										CLOSE csr_element_types;

									ELSE
										OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
											FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
										CLOSE csr_get_defined_balance;

										l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
									END IF;
									IF l_period='Week' THEN
										l_value:=l_value*2;
									ELSIF l_period='Calendar Month' THEN
										l_value:=l_value/2;
									END IF;
									--l_bh_nho_value:=l_value;
									l_bh_nho_value:=l_bh_nho_value+round(nvl(l_value,0));
									l_value:=NULL;
									l_type:=NULL;
								END IF;
							END LOOP;
							/*Retroactive payment _ASG_LU_PTD */
							pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
							OPEN  csr_Get_Defined_Balance_Id( 'RETROSPECTIVE_PAYMENTS_ASG_LU_PTD');
								FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
							CLOSE csr_Get_Defined_Balance_Id;
							l_value:=nvl(pay_balance_pkg.get_value
							 (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
							  P_ASSIGNMENT_ID =>l_assignment_id, --32488,
							  P_VIRTUAL_DATE =>l_period_end--  '31-jan-2000'
							  ),0);
							--l_bh_retroactive_pay:=l_value;
							IF l_period='Week' THEN
								l_value:=l_value*2;
							ELSIF l_period='Calendar Month' THEN
								l_value:=l_value/2;
							END IF;
							l_bh_retroactive_pay:=l_bh_retroactive_pay+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
							/* PPO Value */
							FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BH', 'PPO') LOOP
								l_type:=csr_wages.Type;
								l_element_type_id:=csr_wages.Element_Type_Id;
								l_input_value_id:=csr_wages.Input_value_Id;
								l_balance_type_id:=csr_wages.Balance_Type_Id;
								l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

								/* check whether value has been entered in EIT*/
								IF l_type IS NOT NULL THEN
									/* If element is selected */
									IF l_type='ELEMENT' THEN
										OPEN csr_element_types(l_assignment_id, l_period_start, l_period_end, l_element_type_id, l_input_value_id);
											FETCH csr_element_types INTO l_value;
										CLOSE csr_element_types;

									ELSE
										OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
											FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
										CLOSE csr_get_defined_balance;

										l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_period_end/*TO_DATE('31-jan-2001')*/),0);
									END IF;
									IF l_period='Week' THEN
										l_value:=l_value*2;
									ELSIF l_period='Calendar Month' THEN
										l_value:=l_value/2;
									END IF;
									--l_bh_ppo_value:=l_value;
									l_bh_ppo_value:=l_bh_ppo_value+round(nvl(l_value,0));
									l_value:=NULL;
									l_type:=NULL;
								END IF;
							END LOOP;

							/*Total Sick Pay _ASG_LU_PTD */
							pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
							OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SICK_PAY_ASG_LU_PTD');
								FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
							CLOSE csr_Get_Defined_Balance_Id;
							l_value:=nvl(pay_balance_pkg.get_value
							 (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
							  P_ASSIGNMENT_ID =>l_assignment_id, --32488,
							  P_VIRTUAL_DATE =>l_period_end--  '31-jan-2000'
							  ),0);
							--l_bh_sick_pay:=l_value;
							IF l_period='Week' THEN
								l_value:=l_value*2;
							ELSIF l_period='Calendar Month' THEN
								l_value:=l_value/2;
							END IF;
							l_bh_sick_pay:=l_bh_sick_pay+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
						/*Total count of the employees*/
						l_bh_total_employees:=l_bh_total_employees+1;

				/* Blue Collar Salaried Employee */
				ELSIF l_employee_category='BC' AND l_asg_hour_sal='S' THEN
					/*Gross Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',l_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'GROSS_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
					  ),0);
					--l_bs_gross_pay:=l_value;
					l_bs_gross_pay:=l_bs_gross_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/*Total Working hours agreement */
					IF l_frequency='W' THEN
						l_normal_hours:=l_normal_hours*4.3;
					END IF;
					l_bs_working_agreement:=l_bs_working_agreement+round(l_normal_hours);
					/* TCDP Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'TCDP') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_tcdp_value:=l_value;
							l_bs_tcdp_value:=l_bs_tcdp_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* TCOW Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'TCOW') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_tcow_value:=l_value;
							l_bs_tcow_value:=l_bs_tcow_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* NHA Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'NHA') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;
						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;
							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;
								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_nha_value:=l_value;
							l_bs_nha_value:=l_bs_nha_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
				        /* NHO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'NHO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;
						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;
							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
								--l_bs_nho_value:=l_value;
								l_bs_nho_value:=l_bs_nho_value+round(nvl(l_value,0));
								l_value:=NULL;
								l_type:=NULL;
								lr_Get_Defined_Balance_Id:=NULL;
							END IF;
						END IF;
					END LOOP;
					/*Retroactive payment _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',l_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'RETROSPECTIVE_PAYMENTS_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_bs_retroactive_pay:=l_value;
					l_bs_retroactive_pay:=l_bs_retroactive_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/* PPO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'BS', 'PPO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_bs_ppo_value:=l_value;
							l_bs_ppo_value:=l_bs_ppo_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/*Total Sick Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',l_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SICK_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_bs_sick_pay:=l_value;
					l_bs_sick_pay:=l_bs_sick_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/*Total count of the employees*/
					l_bs_total_employees:=l_bs_total_employees+1;

				/*White Collar Salaried Employee */
				ELSIF l_employee_category='WC' AND l_asg_hour_sal='S' THEN
					/* Number of Full Time Employees */
					l_ws_full_time_employee:=l_ws_full_time_employee+round(nvl(l_working_percentage,100)/100,2);
					--IF l_working_percentage=100 THEN
						--l_ws_full_time_employee:=l_ws_full_time_employee+round(nvl(l_working_percentage,100)* nvl(l_normal_hours,0)/100,2);
					--END IF;

					/*Gross Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',l_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'GROSS_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_ws_gross_pay:=l_value;
					l_ws_gross_pay:=l_ws_gross_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;
					/*Total Working hours agreement */
					IF l_frequency='W' THEN
						l_normal_hours:=l_normal_hours*4.3;
					END IF;
					l_ws_working_agreement:=l_ws_working_agreement+round(l_normal_hours);
					/*IF l_frequency='M' THEN
						l_ws_working_agreement:=l_ws_working_agreement+round(l_normal_hours);
					END IF;	*/

					/* TCDP Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'TCDP') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_tcdp_value:=l_value;
							l_ws_tcdp_value:=l_ws_tcdp_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* TCOW Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'TCOW') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_tcow_value:=l_value;
							l_ws_tcow_value:=l_ws_tcow_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/* NHA Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'NHA') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_nha_value:=l_value;
							l_ws_nha_value:=l_ws_nha_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
				        /* NHO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'NHO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
							END IF;
							--l_ws_nho_value:=l_value;
							l_ws_nho_value:=l_ws_nho_value+round(nvl(l_value,0));
							l_value:=NULL;
							l_type:=NULL;
						END IF;
					END LOOP;
					/*Retroactive payment _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',l_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'RETROSPECTIVE_PAYMENTS_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_ws_retroactive_pay:=l_value;
					l_ws_retroactive_pay:=l_ws_retroactive_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;

					/* PPO Value */
					FOR csr_wages IN csr_wages_details (g_legal_employer_id, 'WS', 'PPO') LOOP
						l_type:=csr_wages.Type;
						l_element_type_id:=csr_wages.Element_Type_Id;
						l_input_value_id:=csr_wages.Input_value_Id;
						l_balance_type_id:=csr_wages.Balance_Type_Id;
						l_balance_dimension_id:=csr_wages.Balance_Dimension_Id;

						/* check whether value has been entered in EIT*/
						IF l_type IS NOT NULL THEN
							/* If element is selected */
							IF l_type='ELEMENT' THEN
								OPEN csr_element_types(l_assignment_id, g_start_date, g_end_date, l_element_type_id, l_input_value_id);
									FETCH csr_element_types INTO l_value;
								CLOSE csr_element_types;

							ELSE
								OPEN csr_get_defined_balance(l_balance_type_id, l_balance_dimension_id);
									FETCH csr_get_defined_balance INTO lr_Get_Defined_Balance_Id;
								CLOSE csr_get_defined_balance;

								l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>g_end_date/*TO_DATE('31-jan-2001')*/),0);
								--l_ws_ppo_value:=l_value;
								l_ws_ppo_value:=l_ws_ppo_value+round(nvl(l_value,0));
								l_value:=NULL;
								l_type:=NULL;
							END IF;
						END IF;
					END LOOP;
					/*Total Sick Pay _ASG_LU_MONTH */
					pay_balance_pkg.set_context ('LOCAL_UNIT_ID',g_local_unit_id);
					OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SICK_PAY_ASG_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_value:=nvl(pay_balance_pkg.get_value
                                         (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
                                          P_ASSIGNMENT_ID =>l_assignment_id, --32488,
                                          P_VIRTUAL_DATE =>g_end_date--  '31-jan-2000'
                                          ),0);
					--l_ws_sick_pay:=l_value;
					l_ws_sick_pay:=l_ws_sick_pay+round(nvl(l_value,0));
					l_value:=NULL;
					l_type:=NULL;

					/*Total count of the employees*/
					l_ws_total_employees:=l_ws_total_employees+1;
				END IF;
				l_type:=NULL;
				l_element_type_id:=NULL;
				l_input_value_id:=NULL;
				l_balance_type_id:=NULL;
				l_balance_dimension_id:=NULL;
				l_period:=NULL;
				l_period_start:=NULL;
				l_period_end:=NULL;
			END IF;
			l_valid_person:=NULL;
		END LOOP;

	    /* check whether there are Blue collar Hourly Employees on current Local unit*/
	    IF l_bh_total_employees<>0 THEN
	    /* check whether record has been inserted for Blue Collar Hourly Employee */
            open csr_category_insert(p_payroll_action_id,'BH',l_local_unit_id);
                fetch csr_category_insert into l_check_insert;
--            close csr_category_insert;
            --if l_check_insert is null then
	    IF csr_category_insert%NOTFOUND THEN
            /*Insert the record*/
            pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'BH'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => l_bh_worked_calendar_month
					, p_action_information5              => l_bh_worked_payment_period
					, p_action_information6              => NULL
					, p_action_information7              => NULL
					, p_action_information8              => NULL
					, p_action_information9              => NULL
					, p_action_information10             => NULL
					, p_action_information11             => NULL
					, p_action_information12             => l_bh_pbt_value
					, p_action_information13             => l_bh_pcow_value
					, p_action_information14             => l_bh_nha_value
					, p_action_information15             => l_bh_nho_value
					, p_action_information16             => l_bh_retroactive_pay
					, p_action_information17             => l_bh_ppo_value
					, p_action_information18             => l_bh_sick_pay
					, p_action_information19             => l_bh_total_employees
					);
            else
            /*update the record*/
                    update pay_action_information set
                    --action_information4=action_information4+l_bh_worked_calendar_month,
                    action_information5=action_information5+l_bh_worked_payment_period,
                    action_information12=action_information12+l_bh_pbt_value,
                    action_information13=action_information13+l_bh_pcow_value,
                    action_information14=action_information14+l_bh_nha_value,
                    action_information15=action_information15+l_bh_nho_value,
                    action_information16=action_information16+l_bh_retroactive_pay,
                    action_information17=action_information17+l_bh_ppo_value,
                    action_information18=action_information18+l_bh_sick_pay,
                    action_information19=action_information19+l_bh_total_employees
                    where action_context_id=p_payroll_action_id
                    and action_information2='BH'
       		    AND action_information3=l_local_unit_id;

            end if;
	    close csr_category_insert;
            l_check_insert:=null;
	    END IF;
	    /* check whether there are Blue collar Salaried Employees on current Local unit*/
	    IF l_bs_total_employees<>0 THEN
            /* check whether record has been inserted for Blue Collar Salaried Employee */
            open csr_category_insert(p_payroll_action_id,'BS',l_local_unit_id);
                fetch csr_category_insert into l_check_insert;
            --close csr_category_insert;
            --if l_check_insert is null then
	    IF csr_category_insert%NOTFOUND THEN
            /*Insert the record*/
            pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'BS'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => null
					, p_action_information5              => null
					, p_action_information6              => null
					, p_action_information7              => l_bs_gross_pay
					, p_action_information8              => l_bs_working_agreement
					, p_action_information9              => l_bs_tcdp_value
					, p_action_information10             => l_bs_tcow_value
					, p_action_information11             => NULL
					, p_action_information12             => NULL
					, p_action_information13             => NULL
					, p_action_information14             => l_bs_nha_value
					, p_action_information15             => l_bs_nho_value
					, p_action_information16             => l_bs_retroactive_pay
					, p_action_information17             => l_bs_ppo_value
					, p_action_information18             => l_bs_sick_pay
					, p_action_information19             => l_bs_total_employees
					);
            else
            /*update the record*/
                    update pay_action_information set
                    action_information7=action_information7+l_bs_gross_pay,
                    action_information8=action_information8+l_bs_working_agreement,
                    action_information9=action_information9+l_bs_tcdp_value,
                    action_information10=action_information10+l_bs_tcow_value,
                    action_information14=action_information14+l_bs_nha_value,
                    action_information15=action_information15+l_bs_nho_value,
                    action_information16=action_information16+l_bs_retroactive_pay,
                    action_information17=action_information17+l_bs_ppo_value,
                    action_information18=action_information18+l_bs_sick_pay,
                    action_information19=action_information19+l_bs_total_employees
                    where action_context_id=p_payroll_action_id
                    and action_information2='BS'
       		    AND action_information3=l_local_unit_id;

            end if;
	    close csr_category_insert;
            l_check_insert:=null;
	    END IF;
	     /* check whether there are White collar Salaried Employees on current Local unit*/
	    IF l_ws_total_employees<>0 THEN
            /* check whether record has been inserted for White Collar Salaried Employee */
            open csr_category_insert(p_payroll_action_id,'WS',l_local_unit_id);
                fetch csr_category_insert into l_check_insert;
            --close csr_category_insert;
            --if l_check_insert is null then
	    IF csr_category_insert%NOTFOUND THEN
            /*Insert the record*/
            pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEWSSA'
					, p_action_information2              => 'WS'
					, p_action_information3              => l_local_unit_id
					, p_action_information4              => null
					, p_action_information5              => null
					, p_action_information6              => l_ws_full_time_employee
					, p_action_information7              => l_ws_gross_pay
					, p_action_information8              => l_ws_working_agreement
					, p_action_information9              => l_ws_tcdp_value
					, p_action_information10             => l_ws_tcow_value
					, p_action_information11             => NULL
					, p_action_information12             => NULL
					, p_action_information13             => NULL
					, p_action_information14             => l_ws_nha_value
					, p_action_information15             => l_ws_nho_value
					, p_action_information16             => l_ws_retroactive_pay
					, p_action_information17             => l_ws_ppo_value
					, p_action_information18             => l_ws_sick_pay
					, p_action_information19             => l_ws_total_employees
					);
            else
            /*update the record*/
                    update pay_action_information set
                    action_information6=action_information6+l_ws_full_time_employee,
                    action_information7=action_information7+l_ws_gross_pay,
                    action_information8=action_information8+l_ws_working_agreement,
                    action_information9=action_information9+l_ws_tcdp_value,
                    action_information10=action_information10+l_ws_tcow_value,
                    action_information14=action_information14+l_ws_nha_value,
                    action_information15=action_information15+l_ws_nho_value,
                    action_information16=action_information16+l_ws_retroactive_pay,
                    action_information17=action_information17+l_ws_ppo_value,
                    action_information18=action_information18+l_ws_sick_pay,
                    action_information19=action_information19+l_ws_total_employees
                    where action_context_id=p_payroll_action_id
                    and action_information2='WS'
       		    AND action_information3=l_local_unit_id;

            end if;
	    close csr_category_insert;
            l_check_insert:=null;
	    END IF;
		/* Initializing all the variables for next local unit */
		l_bh_worked_calendar_month:=0;
	        l_bh_worked_payment_period:=0;
		l_bh_pbt_value:=0;
		l_bh_pcow_value:=0;
		l_bh_nha_value:=0;
		l_bh_nho_value:=0;
		l_bh_retroactive_pay:=0;
		l_bh_ppo_value:=0;
		l_bh_sick_pay:=0;
		l_bh_total_employees:=0;
		l_bs_gross_pay:=0;
		l_bs_working_agreement:=0;
		l_bs_tcdp_value:=0;
		l_bs_tcow_value:=0;
		l_bs_nha_value:=0;
		l_bs_nho_value:=0;
		l_bs_retroactive_pay:=0;
		l_bs_ppo_value:=0;
		l_bs_sick_pay:=0;
		l_bs_total_employees:=0;
		l_ws_full_time_employee:=0;
		l_ws_gross_pay:=0;
		l_ws_working_agreement:=0;
		l_ws_tcdp_value:=0;
		l_ws_tcow_value:=0;
		l_ws_nha_value:=0;
		l_ws_nho_value:=0;
		l_ws_retroactive_pay:=0;
		l_ws_ppo_value:=0;
		l_ws_sick_pay:=0;
		l_ws_total_employees:=0;
		l_wh_full_time_employee:=0;
		l_wh_gross_pay:=0;
		l_wh_working_agreement:=0;
		l_wh_tcdp_value:=0;
		l_wh_retroactive_pay:=0;
		l_wh_ppo_value:=0;
		l_wh_sick_pay:=0;
		l_wh_total_employees:=0;

		END LOOP;
	END IF;

 /*      BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                               (' Entering Procedure ASSIGNMENT_ACTION_CODE'
                              , 60
                               );
      END IF;

      fnd_file.put_line(fnd_file.LOG,'I am assignment here');

      IF g_debug
      THEN
         hr_utility.set_location
                                (' Leaving Procedure ASSIGNMENT_ACTION_CODE'
                               , 70
                                );
      END IF;*/
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('error raised assignment_action_code '
                                   , 5
                                    );
         END IF;

         RAISE;
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
                                , 80
                                 );
      END IF;


      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_LE_request := NULL;
      g_LU_request :=null;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      g_account_date :=null;
      g_posting_date :=null;


      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure INITIALIZATION_CODE'
                                , 90
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_err_num   := SQLCODE;

         IF g_debug
         THEN
            hr_utility.set_location (   'ORA_ERR: '
                                     || g_err_num
                                     || 'In INITIALIZATION_CODE'
                                   , 180
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
           FROM ff_user_entities u, ff_database_items d
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
                               , 240
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
                                , 250
                                 );
      END IF;
   END get_defined_balance_id;

   FUNCTION get_defined_balance_value (
      p_user_name          IN   VARCHAR2
    , p_in_assignment_id   IN   NUMBER
    , p_in_virtual_date    IN   DATE
   )
      RETURN NUMBER
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_def_bal_id (p_user_name VARCHAR2)
      IS
         SELECT u.creator_id
           FROM ff_user_entities u, ff_database_items d
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
                            , 240
                             );
      END IF;

      OPEN csr_def_bal_id (p_user_name);

      FETCH csr_def_bal_id
       INTO l_defined_balance_id;

      CLOSE csr_def_bal_id;

      l_return_balance_value :=
         TO_CHAR
            (pay_balance_pkg.get_value
                                (p_defined_balance_id      => l_defined_balance_id
                               , p_assignment_id           => p_in_assignment_id
                               , p_virtual_date            => p_in_virtual_date
                                )
           , '999999999D99'
            );
      RETURN l_return_balance_value;

      IF g_debug
      THEN
         hr_utility.set_location
                              (' Leaving Function GET_DEFINED_BALANCE_VALUE'
                             , 250
                              );
      END IF;
   END get_defined_balance_value;

   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER
    , p_effective_date         IN   DATE
   )
   IS
   begin

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure ARCHIVE_CODE', 390);
      END IF;
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

  --    hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1      :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT><HPDR>';
      l_str2      := '<';
      l_str3      := '>';
      l_str4      := '</';
      l_str5      := '>';
      l_str6      := '</HPDR></ROOT>';
      l_str7      :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT></ROOT>';
      l_str10     := '<HPDR>';
      l_str11     := '</HPDR>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

      IF xml_tab.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);

         FOR table_counter IN xml_tab.FIRST .. xml_tab.LAST
         LOOP
            l_str8      := xml_tab (table_counter).tagname;
            l_str9      := xml_tab (table_counter).tagvalue;



            IF l_str9 IN
                  (
                  'CAT_DETAILS',
                  'END_CAT_DETAILS'
                  )
            THEN
               IF l_str9 IN
                     ('CAT_DETAILS')
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str2)
                                      , l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                      , l_str3);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str4)
                                      , l_str4
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                      , l_str5);
               END IF;
            ELSE
               IF l_str9 IS NOT NULL
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str2)
                                      , l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                      , l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9)
                                      , l_str9);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                      , l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                      , l_str5);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str2)
                                      , l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                      , l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                      , l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                      , l_str5);
               END IF;
            END IF;
         END LOOP;

         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;
      p_xfdf_clob := l_xfdf_string;
 --     hr_utility.set_location ('Leaving WritetoCLOB ', 40);
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE ('sqlerrm ' || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;

   -----------------------------------------------------------------------------------
-- POPULATE_DATA_DETAIL generates xml for the reports.
-----------------------------------------------------------------------------------
--
--
PROCEDURE POPULATE_DATA_DETAIL
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB)
IS


/* Cursor to fetch Header Information */

l_employee_category per_all_assignments_f.employee_category%type;
l_lu_salary NUMBER;
l_salary NUMBER:=0;
l_grand_salary NUMBER:=0;
l_legal_employer hr_organization_units.name%type;
l_local_unit hr_organization_units.name%type;
l_action_information_id pay_action_information.action_information_id%TYPE;
l_month varchar2(20);
l_year NUMBER;
l_retroactive_date_from	DATE;
l_retroactive_date_to DATE;
l_bh_worked_calendar_month NUMBER;
l_bh_worked_payment_period NUMBER;
l_bh_pbt_value NUMBER;
l_bh_pcow_value NUMBER;
l_bh_nha_value NUMBER;
l_bh_nho_value NUMBER;
l_bh_retroactive_pay NUMBER;
l_bh_ppo_value NUMBER;
l_bh_sick_pay NUMBER;
l_bh_total_employees NUMBER;
l_bs_gross_pay NUMBER;
l_bs_working_agreement NUMBER;
l_bs_tcdp_value NUMBER;
l_bs_tcow_value NUMBER;
l_bs_nha_value NUMBER;
l_bs_nho_value NUMBER;
l_bs_retroactive_pay NUMBER;
l_bs_ppo_value NUMBER;
l_bs_sick_pay NUMBER;
l_bs_total_employees NUMBER;
l_ws_full_time_employee NUMBER;
l_ws_gross_pay NUMBER;
l_ws_working_agreement NUMBER;
l_ws_tcdp_value NUMBER;
l_ws_tcow_value NUMBER;
l_ws_nha_value NUMBER;
l_ws_nho_value NUMBER;
l_ws_retroactive_pay NUMBER;
l_ws_ppo_value NUMBER;
l_ws_sick_pay NUMBER;
l_ws_total_employees NUMBER;
l_wh_full_time_employee NUMBER;
l_wh_gross_pay NUMBER;
l_wh_working_agreement NUMBER;
l_wh_tcdp_value NUMBER;
l_wh_retroactive_pay NUMBER;
l_wh_ppo_value NUMBER;
l_wh_sick_pay NUMBER;
l_wh_total_employees NUMBER;



/*CURSOR csr_local_unit_level_details (p_payroll_action_id NUMBER)
IS
SELECT distinct
pai.ACTION_INFORMATION7 Reporting_Year,
pai1.ACTION_INFORMATION3 Legal_Employer,
pai1.ACTION_INFORMATION4 Local_unit_id,
pai1.ACTION_INFORMATION5 Local_unit,
pai.ACTION_INFORMATION8 Insurance_Number--,
/*pai1.ACTION_INFORMATION6 Cfar_Number,
pai1.ACTION_INFORMATION7 Name,
pai1.ACTION_INFORMATION8 Employee_Category,
pai1.ACTION_INFORMATION9 White_Collar,
pai1.ACTION_INFORMATION10 Gross_Salary,
pai1.ACTION_INFORMATION11 Terminated,
pai1.ACTION_INFORMATION12 Painter*/
/*FROM
pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1
WHERE
pai.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =p_payroll_action_id --27021  --20162 --20264 --20165
AND pai.action_context_id = pai1.action_context_id
AND pai1.action_context_id= ppa.payroll_action_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'PER'
AND pai1.action_information1 = 'PYSEFORA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.ACTION_INFORMATION9=l_employee_category
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSEFORA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
ORDER BY --pai1.ACTION_INFORMATION3,
pai1.ACTION_INFORMATION4 ;--pai1.ACTION_INFORMATION8 ;

CURSOR csr_all_local_unit_details (p_payroll_action_id NUMBER)
IS
SELECT distinct
pai.ACTION_INFORMATION7 Reporting_Year,
pai1.ACTION_INFORMATION3 Legal_Employer,
pai1.ACTION_INFORMATION4 Local_unit_id,
pai1.ACTION_INFORMATION5 Local_unit,
pai.ACTION_INFORMATION8 Insurance_Number,
pai1.ACTION_INFORMATION9 Employee_Category
/*pai1.ACTION_INFORMATION6 Cfar_Number,
pai1.ACTION_INFORMATION7 Name,
pai1.ACTION_INFORMATION8 Employee_Category,
pai1.ACTION_INFORMATION9 White_Collar,
pai1.ACTION_INFORMATION10 Gross_Salary,
pai1.ACTION_INFORMATION11 Terminated,
pai1.ACTION_INFORMATION12 Painter*/
/*FROM
pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1
WHERE
pai.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =p_payroll_action_id --27021  --20162 --20264 --20165
AND pai.action_context_id = pai1.action_context_id
AND pai1.action_context_id= ppa.payroll_action_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'PER'
AND pai1.action_information1 = 'PYSEFORA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.ACTION_INFORMATION9 IN ('BC','WC')
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSEFORA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
ORDER BY --pai1.ACTION_INFORMATION3,
pai1.ACTION_INFORMATION9, pai1.ACTION_INFORMATION4 ;--pai1.ACTION_INFORMATION8 ;


CURSOR csr_person_level_details (p_payroll_action_id NUMBER,local_unit_id varchar2)
IS
SELECT
pai1.ACTION_INFORMATION6 Cfar_Number,
pai1.ACTION_INFORMATION7 Person_Number,
pai1.ACTION_INFORMATION8 Name,
pai1.ACTION_INFORMATION9 Employee_Category,
pai1.ACTION_INFORMATION10 White_Collar,
nvl(pai1.ACTION_INFORMATION11,0) Gross_Salary,
pai1.ACTION_INFORMATION12 Terminated,
pai1.ACTION_INFORMATION13 Painter
FROM
--pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1
WHERE
pai1.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =p_payroll_action_id --27021  --20162 --20264 --20165
/*AND pai.action_context_id = pai1.action_context_id*/
/*AND pai1.action_context_id= ppa.payroll_action_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'PER'
AND pai1.action_information1 = 'PYSEFORA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.ACTION_INFORMATION9=l_employee_category
AND pai1.ACTION_INFORMATION4=local_unit_id
/*AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSEFORA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'*/
/*ORDER BY pai1.ACTION_INFORMATION8;
--pai1.ACTION_INFORMATION4,--pai1.ACTION_INFORMATION8 ;	       */

CURSOR csr_local_unit(csr_v_payroll_action_id number)
IS
SELECT action_information3 local_unit_id
FROM pay_action_information pai
WHERE pai.action_context_id=  csr_v_payroll_action_id
AND pai.action_context_type='PA'
AND pai.action_information2 = 'LU'
AND pai.action_information1 = 'PYSEWSSA'
AND pai.action_information_category = 'EMEA REPORT INFORMATION'
GROUP BY action_information3;



/*CURSOR csr_emp_cat(csr_v_payroll_action_id number, csr_v_local_unit_id number )
IS
SELECT pai.action_information3 legal_employer,
pai1.action_information4 local_unit,
pai.action_information7 month,
pai.action_information8 year,
fnd_date.canonical_to_date(pai.action_information9) retroactive_date_from,
fnd_date.canonical_to_date(pai.action_information10) retroactive_date_to,
decode(pai2.action_information4,0,NULL,pai2.action_information4)  bh_worked_calendar_month,
decode(pai2.action_information5,0,NULL,pai2.action_information5) bh_worked_payment_period,
decode(pai2.action_information12,0,NULL,pai2.action_information12) bh_pbt_value,
decode(pai2.action_information13,0,NULL,pai2.action_information13) bh_pcow_value,
decode(pai2.action_information14,0,NULL,pai2.action_information14) bh_nha_value,
decode(pai2.action_information15,0,NULL,pai2.action_information15) bh_nho_value,
decode(pai2.action_information16,0,NULL,pai2.action_information16) bh_retroactive_pay,
decode(pai2.action_information17,0,NULL,pai2.action_information17) bh_ppo_value,
decode(pai2.action_information18,0,NULL,pai2.action_information18) bh_sick_pay,
decode(pai2.action_information19,0,NULL,pai2.action_information19) bh_total_employees,
decode(pai3.action_information7,0,NULL,pai3.action_information7) bs_gross_pay,
decode(pai3.action_information8,0,NULL,pai3.action_information8) bs_working_agreement,
decode(pai3.action_information9,0,NULL,pai3.action_information9) bs_tcdp_value,
decode(pai3.action_information10,0,NULL,pai3.action_information10) bs_tcow_value,
decode(pai3.action_information14,0,NULL,pai3.action_information14) bs_nha_value,
decode(pai3.action_information15,0,NULL,pai3.action_information15) bs_nho_value,
decode(pai3.action_information16,0,NULL,pai3.action_information16) bs_retroactive_pay,
decode(pai3.action_information17,0,NULL,pai3.action_information17) bs_ppo_value,
decode(pai3.action_information18,0,NULL,pai3.action_information18) bs_sick_pay,
decode(pai3.action_information19,0,NULL,pai3.action_information19) bs_total_employees,
decode(pai4.action_information6,0,NULL,pai4.action_information6) ws_full_time_employee,
decode(pai4.action_information7,0,NULL,pai4.action_information7) ws_gross_pay,
decode(pai4.action_information8,0,NULL,pai4.action_information8) ws_working_agreement,
decode(pai4.action_information9,0,NULL,pai4.action_information9) ws_tcdp_value,
decode(pai4.action_information10,0,NULL,pai4.action_information10) ws_tcow_value,
decode(pai4.action_information14,0,NULL,pai4.action_information14) ws_nha_value,
decode(pai4.action_information15,0,NULL,pai4.action_information15) ws_nho_value,
decode(pai4.action_information16,0,NULL,pai4.action_information16) ws_retroactive_pay,
decode(pai4.action_information17,0,NULL,pai4.action_information17) ws_ppo_value,
decode(pai4.action_information18,0,NULL,pai4.action_information18) ws_sick_pay,
decode(pai4.action_information19,0,NULL,pai4.action_information19) ws_total_employees,
decode(pai5.action_information6,0,NULL,pai5.action_information6) wh_full_time_employee,
decode(pai5.action_information7,0,NULL,pai5.action_information7) wh_gross_pay,
decode(pai5.action_information8,0,NULL,pai5.action_information8) wh_working_agreement,
decode(pai5.action_information9,0,NULL,pai5.action_information9) wh_tcdp_value,
decode(pai5.action_information16,0,NULL,pai5.action_information16) wh_retroactive_pay,
decode(pai5.action_information17,0,NULL,pai5.action_information17) wh_ppo_value,
decode(pai5.action_information18,0,NULL,pai5.action_information18) wh_sick_pay,
decode(pai5.action_information19,0,NULL,pai5.action_information19) wh_total_employees
FROM
pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1,
pay_action_information pai2,
pay_action_information pai3,
pay_action_information pai4,
pay_action_information pai5
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id --45660 --p_payroll_action_id
AND ppa.payroll_action_id=pai.action_context_id
AND pai.action_context_id=pai1.action_context_id
AND pai1.action_context_id=pai2.action_context_id
AND pai2.action_context_id=pai3.action_context_id
AND pai3.action_context_id=pai4.action_context_id
AND pai4.action_context_id=pai5.action_context_id
and pai5.action_context_id=ppa.payroll_action_id
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSEWSSA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai2.action_context_type='PA'
AND pai2.action_information2 = 'BH'
AND pai2.action_information1 = 'PYSEWSSA'
AND pai2.action_information_category = 'EMEA REPORT INFORMATION'
AND pai3.action_context_type='PA'
AND pai3.action_information2 = 'BH'
AND pai3.action_information1 = 'PYSEWSSA'
AND pai3.action_information_category = 'EMEA REPORT INFORMATION'
AND pai4.action_context_type='PA'
AND pai4.action_information2 = 'BS'
AND pai4.action_information1 = 'PYSEWSSA'
AND pai4.action_information_category = 'EMEA REPORT INFORMATION'
AND pai5.action_context_type='PA'
AND pai5.action_information2 = 'WH'
AND pai5.action_information1 = 'PYSEWSSA'
AND pai5.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.action_information3=csr_v_local_unit_id --3135 --csr_v_local_unit_id
AND pai1.action_information3=pai2.action_information3
AND pai2.action_information3=pai3.action_information3
AND pai3.action_information3=pai4.action_information3
AND pai4.action_information3=pai5.action_information3
AND pai5.action_information3=pai1.action_information3
ORDER BY pai1.action_information3;	 */
CURSOR csr_emp_cat(csr_v_payroll_action_id number, csr_v_local_unit_id number )
IS
SELECT pai.action_information3 legal_employer,
pai1.action_information4 local_unit,
pai.action_information7 || ' ' || pai.action_information8 period,-- month,
--pai.action_information8 year,
fnd_date.canonical_to_date(pai.action_information9) retroactive_date_from,
fnd_date.canonical_to_date(pai.action_information10) retroactive_date_to
FROM
pay_action_information pai,
pay_action_information pai1,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id
AND ppa.payroll_action_id=pai.action_context_id
AND pai.action_context_id=pai1.action_context_id
AND pai1.action_context_id=ppa.payroll_action_id
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSEWSSA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information3=csr_v_local_unit_id;

CURSOR csr_blue_hour(csr_v_payroll_action_id number, csr_v_local_unit_id number, csr_v_action_information_id number )
IS
SELECT
--decode(sum(pai2.action_information4),0,NULL,sum(pai2.action_information4))  bh_worked_calendar_month,
decode(sum(pai2.action_information5),0,NULL,sum(pai2.action_information5)) bh_worked_payment_period,
decode(sum(pai2.action_information12),0,NULL,sum(pai2.action_information12)) bh_pbt_value,
decode(sum(pai2.action_information13),0,NULL,sum(pai2.action_information13)) bh_pcow_value,
decode(sum(pai2.action_information14),0,NULL,sum(pai2.action_information14)) bh_nha_value,
decode(sum(pai2.action_information15),0,NULL,sum(pai2.action_information15)) bh_nho_value,
decode(sum(pai2.action_information16),0,NULL,sum(pai2.action_information16)) bh_retroactive_pay,
decode(sum(pai2.action_information17),0,NULL,sum(pai2.action_information17)) bh_ppo_value,
decode(sum(pai2.action_information18),0,NULL,sum(pai2.action_information18)) bh_sick_pay,
decode(sum(pai2.action_information19),0,NULL,sum(pai2.action_information19)) bh_total_employees
FROM
pay_action_information pai1,
pay_action_information pai2,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id
AND ppa.payroll_action_id=pai1.action_context_id
AND pai1.action_context_id=pai2.action_context_id
AND pai2.action_context_id=ppa.payroll_action_id
AND pai1.action_information3=to_char(csr_v_local_unit_id /*3135*/) --csr_v_local_unit_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information_id=csr_v_action_information_id
AND pai1.action_information3=pai2.action_information3
AND pai2.action_context_type='PA'
AND pai2.action_information2 = 'BH'
AND pai2.action_information1 = 'PYSEWSSA'
AND pai2.action_information_category = 'EMEA REPORT INFORMATION';

CURSOR csr_blue_hour_calendar(csr_v_payroll_action_id number, csr_v_local_unit_id number, csr_v_action_information_id number )
IS SELECT pai2.action_information4 bh_worked_calendar_month
FROM
pay_action_information pai1,
pay_action_information pai2,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id
AND ppa.payroll_action_id=pai1.action_context_id
AND pai1.action_context_id=pai2.action_context_id
AND pai2.action_context_id=ppa.payroll_action_id
AND pai1.action_information3=to_char(csr_v_local_unit_id /*3135*/) --csr_v_local_unit_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information_id=csr_v_action_information_id
AND pai1.action_information3=pai2.action_information3
AND pai2.action_context_type='PA'
AND pai2.action_information2 = 'BH'
AND pai2.action_information1 = 'PYSEWSSA'
AND pai2.action_information_category = 'EMEA REPORT INFORMATION'
AND ROWNUM <2;

CURSOR csr_blue_salary(csr_v_payroll_action_id number, csr_v_local_unit_id number, csr_v_action_information_id number )
IS
SELECT
decode(sum(pai3.action_information7),0,NULL,sum(pai3.action_information7)) bs_gross_pay,
decode(sum(pai3.action_information8),0,NULL,sum(pai3.action_information8)) bs_working_agreement,
decode(sum(pai3.action_information9),0,NULL,sum(pai3.action_information9)) bs_tcdp_value,
decode(sum(pai3.action_information10),0,NULL,sum(pai3.action_information10)) bs_tcow_value,
decode(sum(pai3.action_information14),0,NULL,sum(pai3.action_information14)) bs_nha_value,
decode(sum(pai3.action_information15),0,NULL,sum(pai3.action_information15)) bs_nho_value,
decode(sum(pai3.action_information16),0,NULL,sum(pai3.action_information16)) bs_retroactive_pay,
decode(sum(pai3.action_information17),0,NULL,sum(pai3.action_information17)) bs_ppo_value,
decode(sum(pai3.action_information18),0,NULL,sum(pai3.action_information18)) bs_sick_pay,
decode(sum(pai3.action_information19),0,NULL,sum(pai3.action_information19)) bs_total_employees
FROM
pay_action_information pai1,
pay_action_information pai3,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id
AND ppa.payroll_action_id=pai1.action_context_id
AND pai1.action_context_id=pai3.action_context_id
AND pai3.action_context_id=ppa.payroll_action_id
AND pai1.action_information3=to_char(csr_v_local_unit_id ) --csr_v_local_unit_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information_id=csr_v_action_information_id
AND pai1.action_information3=pai3.action_information3
AND pai3.action_context_type='PA'
AND pai3.action_information2 = 'BS'
AND pai3.action_information1 = 'PYSEWSSA'
AND pai3.action_information_category = 'EMEA REPORT INFORMATION';

CURSOR csr_white_salary(csr_v_payroll_action_id number, csr_v_local_unit_id number, csr_v_action_information_id number )
IS
SELECT
decode(sum(pai4.action_information6),0,NULL,sum(pai4.action_information6)) ws_full_time_employee,
decode(sum(pai4.action_information7),0,NULL,sum(pai4.action_information7)) ws_gross_pay,
decode(sum(pai4.action_information8),0,NULL,sum(pai4.action_information8)) ws_working_agreement,
decode(sum(pai4.action_information9),0,NULL,sum(pai4.action_information9)) ws_tcdp_value,
decode(sum(pai4.action_information10),0,NULL,sum(pai4.action_information10)) ws_tcow_value,
decode(sum(pai4.action_information14),0,NULL,sum(pai4.action_information14)) ws_nha_value,
decode(sum(pai4.action_information15),0,NULL,sum(pai4.action_information15)) ws_nho_value,
decode(sum(pai4.action_information16),0,NULL,sum(pai4.action_information16)) ws_retroactive_pay,
decode(sum(pai4.action_information17),0,NULL,sum(pai4.action_information17)) ws_ppo_value,
decode(sum(pai4.action_information18),0,NULL,sum(pai4.action_information18)) ws_sick_pay,
decode(sum(pai4.action_information19),0,NULL,sum(pai4.action_information19)) ws_total_employees
FROM
pay_action_information pai1,
pay_action_information pai4,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id
AND ppa.payroll_action_id=pai1.action_context_id
AND pai1.action_context_id=pai4.action_context_id
AND pai4.action_context_id=ppa.payroll_action_id
AND pai1.action_information3=to_char(csr_v_local_unit_id ) --csr_v_local_unit_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information3=pai4.action_information3
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information_id=csr_v_action_information_id
AND pai4.action_context_type='PA'
AND pai4.action_information2 = 'WS'
AND pai4.action_information1 = 'PYSEWSSA'
AND pai4.action_information_category = 'EMEA REPORT INFORMATION';

CURSOR csr_white_hour(csr_v_payroll_action_id number, csr_v_local_unit_id number, csr_v_action_information_id number )
IS
SELECT
decode(sum(pai5.action_information6),0,NULL,sum(pai5.action_information6)) wh_full_time_employee,
decode(sum(pai5.action_information7),0,NULL,sum(pai5.action_information7)) wh_gross_pay,
decode(sum(pai5.action_information8),0,NULL,sum(pai5.action_information8)) wh_working_agreement,
decode(sum(pai5.action_information9),0,NULL,sum(pai5.action_information9)) wh_tcdp_value,
decode(sum(pai5.action_information16),0,NULL,sum(pai5.action_information16)) wh_retroactive_pay,
decode(sum(pai5.action_information17),0,NULL,sum(pai5.action_information17)) wh_ppo_value,
decode(sum(pai5.action_information18),0,NULL,sum(pai5.action_information18)) wh_sick_pay,
decode(sum(pai5.action_information19),0,NULL,sum(pai5.action_information19)) wh_total_employees
FROM
pay_action_information pai1,
pay_action_information pai5,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id
AND ppa.payroll_action_id=pai1.action_context_id
AND pai1.action_context_id=pai5.action_context_id
AND pai5.action_context_id=ppa.payroll_action_id
AND pai1.action_information3=to_char(csr_v_local_unit_id ) --csr_v_local_unit_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSEWSSA'
AND pai1.action_information_id=csr_v_action_information_id
AND pai1.action_information3=pai5.action_information3
AND pai5.action_context_type='PA'
AND pai5.action_information2 = 'WH'
AND pai5.action_information1 = 'PYSEWSSA'
AND pai5.action_information_category = 'EMEA REPORT INFORMATION';



CURSOR csr_unique_local_unit(csr_v_payroll_action_id number, csr_v_local_unit_id number )
IS
SELECT MIN(action_information_id)
FROM pay_action_information pai
WHERE pai.action_context_id=  csr_v_payroll_action_id
AND pai.action_context_type='PA'
AND pai.action_information2 = 'LU'
AND pai.action_information1 = 'PYSEWSSA'
AND pai.action_information3=to_char(csr_v_local_unit_id)
AND pai.action_information_category = 'EMEA REPORT INFORMATION';


--l_local_unit_details_rec csr_local_unit_level_details%rowtype;



l_counter             NUMBER:=0;
l_total               NUMBER;
l_total_eft           NUMBER;
l_count               NUMBER;
l_payroll_action_id   NUMBER;
l_lu_counter_reset    VARCHAR2(10);
l_prev_local_unit     VARCHAR2(15);
l_report_date         DATE;
/*l_total_termination NUMBER;
l_total_hire NUMBER;
l_total_absence NUMBER;
l_total_sick NUMBER;
l_total_lu_emp NUMBER;
l_total_le_emp NUMBER;
l_legal_employer VARCHAR2(80);
l_regular_men NUMBER;
l_regular_women NUMBER;
l_temp_men NUMBER;
l_temp_women NUMBER;*/
l_person_number VARCHAR2(50);
l_local_unit_id hr_organization_units.organization_id%type;
l_period varchar2(50);

--l_local_unit hr_organization_units.name%TYPE;

BEGIN


IF p_payroll_action_id  IS NULL THEN
        BEGIN
                SELECT payroll_action_id
                INTO  l_payroll_action_id
                FROM pay_payroll_actions ppa,
                fnd_conc_req_summary_v fcrs,
                fnd_conc_req_summary_v fcrs1
                WHERE  fcrs.request_id = fnd_global.conc_request_id
                AND fcrs.priority_request_id = fcrs1.priority_request_id
                AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
                AND ppa.request_id = fcrs1.request_id;
        EXCEPTION
        WHEN OTHERS THEN
        NULL;
        END ;
        ELSE
                l_payroll_action_id  := p_payroll_action_id;
        END IF;
        g_payroll_action_id :=p_payroll_action_id;
       /* g_business_group_id := null;
        g_legal_employer_id := null;
        g_start_date        := null;
        g_end_date          := null;
        g_version           := null;
        g_archive           := null;*/

      get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LU_request
                                                , g_local_unit_id
						, g_month
                                                , g_year
						, g_retroactive_payment_from
						, g_retroactive_payment_to
                                                 );


        hr_utility.set_location('Entered Procedure GETDATA',10);

	/*	xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='LU_DETAILS';*/
/*		l_counter:=l_counter+1;*/

        /* Get the File Header Information */
         hr_utility.set_location('Before populating pl/sql table',20);
         l_lu_salary:=0;
	 FOR csr_local IN csr_local_unit(p_payroll_action_id) LOOP

		l_local_unit_id:=csr_local.local_unit_id;
		OPEN csr_unique_local_unit(p_payroll_action_id,l_local_unit_id);
			FETCH csr_unique_local_unit INTO l_action_information_id;
		CLOSE csr_unique_local_unit;
	--	FOR csr_cat IN csr_emp_cat(p_payroll_action_id, l_local_unit_id) LOOP
			OPEN csr_emp_cat(p_payroll_action_id, l_local_unit_id);
				FETCH csr_emp_cat INTO l_legal_employer,l_local_unit,l_period,
				l_retroactive_date_from,l_retroactive_date_to;
			CLOSE csr_emp_cat;
			xml_tab(l_counter).TagName  :='CAT_DETAILS';
			xml_tab(l_counter).TagValue :='CAT_DETAILS';
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='legal_employer';
			xml_tab(l_counter).TagValue :=l_legal_employer; --csr_cat.legal_employer;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='local_unit';
			xml_tab(l_counter).TagValue :=l_local_unit; --csr_cat.local_unit;
			l_counter:=l_counter+1;

			/*xml_tab(l_counter).TagName  :='local_unit';
			xml_tab(l_counter).TagValue :=csr_cat.local_unit;
			l_counter:=l_counter+1;*/

			xml_tab(l_counter).TagName  :='period';
			xml_tab(l_counter).TagValue :=l_period; --csr_cat.month;
			l_counter:=l_counter+1;

			/*xml_tab(l_counter).TagName  :='month';
			xml_tab(l_counter).TagValue :=l_month; --csr_cat.month;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='year';
			xml_tab(l_counter).TagValue :=l_year; --csr_cat.year;
			l_counter:=l_counter+1;*/

			xml_tab(l_counter).TagName  :='retroactive_date_from';
			xml_tab(l_counter).TagValue :=l_retroactive_date_from; --csr_cat.retroactive_date_from;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='retroactive_date_to';
			xml_tab(l_counter).TagValue :=l_retroactive_date_to; --csr_cat.retroactive_date_to;
			l_counter:=l_counter+1;
			OPEN csr_blue_hour(p_payroll_action_id, l_local_unit_id,l_action_information_id);
				FETCH csr_blue_hour INTO /*l_bh_worked_calendar_month,*/l_bh_worked_payment_period,
				l_bh_pbt_value,l_bh_pcow_value,l_bh_nha_value,l_bh_nho_value,l_bh_retroactive_pay,
				l_bh_ppo_value,l_bh_sick_pay,l_bh_total_employees;
			CLOSE csr_blue_hour;
			OPEN csr_blue_hour_calendar(p_payroll_action_id, l_local_unit_id,l_action_information_id);
				FETCH csr_blue_hour_calendar INTO l_bh_worked_calendar_month;
			CLOSE csr_blue_hour_calendar;
			xml_tab(l_counter).TagName  :='bh_worked_calendar_month';
			xml_tab(l_counter).TagValue :=l_bh_worked_calendar_month; --csr_cat.bh_worked_calendar_month;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_worked_payment_period';
			xml_tab(l_counter).TagValue :=l_bh_worked_payment_period; --csr_cat.bh_worked_payment_period;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_pbt_value';
			xml_tab(l_counter).TagValue :=l_bh_pbt_value; --csr_cat.bh_pbt_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_pcow_value';
			xml_tab(l_counter).TagValue :=l_bh_pcow_value; --csr_cat.bh_pcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_nha_value';
			xml_tab(l_counter).TagValue :=l_bh_nha_value; --csr_cat.bh_nha_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_nho_value';
			xml_tab(l_counter).TagValue :=l_bh_nho_value; --csr_cat.bh_nho_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_retroactive_pay';
			xml_tab(l_counter).TagValue :=l_bh_retroactive_pay; --csr_cat.bh_retroactive_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_ppo_value';
			xml_tab(l_counter).TagValue :=l_bh_ppo_value; --csr_cat.bh_ppo_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_sick_pay';
			xml_tab(l_counter).TagValue :=l_bh_sick_pay; --csr_cat.bh_sick_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bh_total_employees';
			xml_tab(l_counter).TagValue :=l_bh_total_employees; --csr_cat.bh_total_employees;
			l_counter:=l_counter+1;

			OPEN csr_blue_salary(p_payroll_action_id, l_local_unit_id,l_action_information_id);
				FETCH csr_blue_salary INTO l_bs_gross_pay,l_bs_working_agreement,l_bs_tcdp_value,
				l_bs_tcow_value,l_bs_nha_value,l_bs_nho_value,l_bs_retroactive_pay,l_bs_ppo_value,
				l_bs_sick_pay,l_bs_total_employees;
			CLOSE csr_blue_salary;

			xml_tab(l_counter).TagName  :='bs_gross_pay';
			xml_tab(l_counter).TagValue :=l_bs_gross_pay; --csr_cat.bs_gross_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_working_agreement';
			xml_tab(l_counter).TagValue :=l_bs_working_agreement; --csr_cat.bs_working_agreement;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_tcdp_value';
			xml_tab(l_counter).TagValue :=l_bs_tcdp_value; --csr_cat.bs_tcdp_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_tcow_value';
			xml_tab(l_counter).TagValue :=l_bs_tcow_value; --csr_cat.bs_tcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_nha_value';
			xml_tab(l_counter).TagValue :=l_bs_nha_value; --csr_cat.bs_nha_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_nho_value';
			xml_tab(l_counter).TagValue :=l_bs_nho_value; --csr_cat.bs_nho_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_retroactive_pay';
			xml_tab(l_counter).TagValue :=l_bs_retroactive_pay; --csr_cat.bs_retroactive_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_ppo_value';
			xml_tab(l_counter).TagValue :=l_bs_ppo_value; --csr_cat.bs_ppo_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_sick_pay';
			xml_tab(l_counter).TagValue :=l_bs_sick_pay; --csr_cat.bs_sick_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='bs_total_employees';
			xml_tab(l_counter).TagValue :=l_bs_total_employees; --csr_cat.bs_total_employees;
			l_counter:=l_counter+1;

			OPEN csr_white_salary(p_payroll_action_id, l_local_unit_id,l_action_information_id);
				FETCH csr_white_salary INTO l_ws_full_time_employee,l_ws_gross_pay,l_ws_working_agreement,
				l_ws_tcdp_value,l_ws_tcow_value,l_ws_nha_value,l_ws_nho_value,l_ws_retroactive_pay,
				l_ws_ppo_value,l_ws_sick_pay,l_ws_total_employees;
			CLOSE csr_white_salary;

			xml_tab(l_counter).TagName  :='ws_full_time_employee';
			xml_tab(l_counter).TagValue :=l_ws_full_time_employee; --round(csr_cat.ws_full_time_employee,2);
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_gross_pay';
			xml_tab(l_counter).TagValue :=l_ws_gross_pay; --csr_cat.ws_gross_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_working_agreement';
			xml_tab(l_counter).TagValue :=l_ws_working_agreement; --csr_cat.ws_working_agreement;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_tcdp_value';
			xml_tab(l_counter).TagValue :=l_ws_tcdp_value; --csr_cat.ws_tcdp_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_tcow_value';
			xml_tab(l_counter).TagValue :=l_ws_tcow_value; --csr_cat.ws_tcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_nha_value';
			xml_tab(l_counter).TagValue :=l_ws_nha_value; --csr_cat.ws_nha_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_nho_value';
			xml_tab(l_counter).TagValue :=l_ws_nho_value; --csr_cat.ws_nho_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_retroactive_pay';
			xml_tab(l_counter).TagValue :=l_ws_retroactive_pay; --csr_cat.ws_retroactive_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_ppo_value';
			xml_tab(l_counter).TagValue :=l_ws_ppo_value; --csr_cat.ws_ppo_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_sick_pay';
			xml_tab(l_counter).TagValue :=l_ws_sick_pay; --csr_cat.ws_sick_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ws_total_employees';
			xml_tab(l_counter).TagValue :=l_ws_total_employees; --csr_cat.ws_total_employees;
			l_counter:=l_counter+1;

			OPEN csr_white_hour(p_payroll_action_id, l_local_unit_id,l_action_information_id);
				FETCH csr_white_hour INTO l_wh_full_time_employee,l_wh_gross_pay,l_wh_working_agreement,l_wh_tcdp_value,
				l_wh_retroactive_pay,l_wh_ppo_value,l_wh_sick_pay,l_wh_total_employees;
			CLOSE csr_white_hour;

			xml_tab(l_counter).TagName  :='wh_full_time_employee';
			xml_tab(l_counter).TagValue :=l_wh_full_time_employee; --round(csr_cat.wh_full_time_employee,2);
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_gross_pay';
			xml_tab(l_counter).TagValue :=l_wh_gross_pay; --csr_cat.wh_gross_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_working_agreement';
			xml_tab(l_counter).TagValue :=l_wh_working_agreement; --csr_cat.wh_working_agreement;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_tcdp_value';
			xml_tab(l_counter).TagValue :=l_wh_tcdp_value; --csr_cat.wh_tcdp_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_retroactive_pay';
			xml_tab(l_counter).TagValue :=l_wh_retroactive_pay; --csr_cat.wh_retroactive_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_ppo_value';
			xml_tab(l_counter).TagValue :=l_wh_ppo_value; --csr_cat.wh_ppo_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_sick_pay';
			xml_tab(l_counter).TagValue :=l_wh_sick_pay; --csr_cat.wh_sick_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='wh_total_employees';
			xml_tab(l_counter).TagValue :=l_wh_total_employees; --csr_cat.wh_total_employees;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='CAT_DETAILS';
			xml_tab(l_counter).TagValue :='END_CAT_DETAILS';
			l_counter := l_counter + 1;


			l_legal_employer:=NULL;
			l_local_unit:=NULL;
			l_month:=NULL;
			l_year:=NULL;
			l_retroactive_date_from:=NULL;
			l_retroactive_date_to:=NULL;
			l_bh_worked_calendar_month:=NULL;
			l_bh_worked_payment_period:=NULL;
			l_bh_pbt_value:=NULL;
			l_bh_pcow_value:=NULL;
			l_bh_nha_value:=NULL;
			l_bh_nho_value:=NULL;
			l_bh_retroactive_pay:=NULL;
			l_bh_ppo_value:=NULL;
			l_bh_sick_pay:=NULL;
			l_bh_total_employees:=NULL;
			l_bs_gross_pay:=NULL;
			l_bs_working_agreement:=NULL;
			l_bs_tcdp_value:=NULL;
			l_bs_tcow_value:=NULL;
			l_bs_nha_value:=NULL;
			l_bs_nho_value:=NULL;
			l_bs_retroactive_pay:=NULL;
			l_bs_ppo_value:=NULL;
			l_bs_sick_pay:=NULL;
			l_bs_total_employees:=NULL;
			l_ws_full_time_employee:=NULL;
			l_ws_gross_pay:=NULL;
			l_ws_working_agreement:=NULL;
			l_ws_tcdp_value:=NULL;
			l_ws_tcow_value:=NULL;
			l_ws_nha_value:=NULL;
			l_ws_nho_value:=NULL;
			l_ws_retroactive_pay:=NULL;
			l_ws_ppo_value:=NULL;
			l_ws_sick_pay:=NULL;
			l_ws_total_employees:=NULL;
			l_wh_full_time_employee:=NULL;
			l_wh_gross_pay:=NULL;
			l_wh_working_agreement:=NULL;
			l_wh_tcdp_value:=NULL;
			l_wh_retroactive_pay:=NULL;
			l_wh_ppo_value:=NULL;
			l_wh_sick_pay:=NULL;
			l_wh_total_employees:=NULL;
			l_action_information_id:=NULL;
		--END LOOP;
	 END LOOP;


--        INSERT INTO raaj VALUES (p_xml);
        WritetoCLOB (p_xml );



END POPULATE_DATA_DETAIL;

END PAY_SE_WAGES_SALARIES;


/
