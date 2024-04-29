--------------------------------------------------------
--  DDL for Package Body PAY_SE_FORA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_FORA" AS
/* $Header: pysefora.pkb 120.0.12010000.5 2010/03/22 12:32:14 vijranga ship $ */
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
    , p_YEAR               OUT NOCOPY      NUMBER         -- User parameter
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
                                                     , 'YEAR'
                                                      )
                ) L_YEAR
              , /*FND_DATE.canonical_to_date(effective_date)*/ effective_date, business_group_id bg_id
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


      p_year:=lr_parameter_info.l_year;
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

-- Cursor for getting the Insurance Number
CURSOR csr_Insurance_Number(csr_v_legal_employer_id      NUMBER) is
select /*o1.NAME LU_NAME,*/ hoi2.ORG_INFORMATION6 Insurance_Number
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = g_business_group_id --3133
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER' --'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS' --'SE_LOCAL_UNIT_DETAILS'
	and o1.organization_id = csr_v_legal_employer_id; --3134 --3135 --csr_local_unit_ID;

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

      /*CURSOR csr_employee_details(csr_v_person_id number, csr_v_end_date date)
      IS
      SELECT national_identifier, last_name || ' ' || first_name name ,DATE_OF_BIRTH
      FROM
      per_all_people_f WHERE
      BUSINESS_GROUP_ID=g_business_group_id
      AND person_id=csr_v_person_id
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      AND months_between (csr_v_end_date,DATE_OF_BIRTH) > 240;*/

     /*   CURSOR csr_employee_details(csr_v_person_id number, csr_v_start_date date date, csr_v_end_date date)
      IS
      SELECT national_identifier, last_name || ' ' || first_name name ,DATE_OF_BIRTH
      FROM
      per_all_people_f WHERE
      BUSINESS_GROUP_ID=g_business_group_id
      AND person_id=csr_v_person_id
/*      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE*/
/*       EFFECTIVE_END_DATE>=csr_v_start_date
       AND EFFECTIVE_START_DATE <=csr_v_end_date
      AND months_between (EFFECTIVE_END_DATE,DATE_OF_BIRTH) > 240;*/


        CURSOR csr_employee_details(csr_v_person_id number, csr_v_end_date date)
      IS
      SELECT national_identifier, last_name || ' ' || first_name name ,DATE_OF_BIRTH
      FROM
      per_all_people_f WHERE
      BUSINESS_GROUP_ID=g_business_group_id
      AND person_id=csr_v_person_id
      AND csr_v_end_date
      BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      --AND months_between (csr_v_end_date,DATE_OF_BIRTH) > 240 -- Bug# 9440498 fix
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
      AND EFFECTIVE_START_DATE --'31-dec-2000'
      BETWEEN csr_v_start_date  AND csr_v_end_date /*'01-jan-2000' AND csr_v_end_date '31-dec-2000'*/
      AND NOT EXISTS
      (SELECT 1 FROM per_all_people_f papf1 WHERE
      CURRENT_EMPLOYEE_FLAG='Y'
      AND person_id=papf.person_id --21257
      AND papf1.effective_start_date >papf.effective_start_date
      );
      CURSOR csr_assignment_details(csr_v_local_unit_id number, csr_v_assignment_id NUMBER, csr_v_start_date date, csr_v_end_date date)
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
      pj.JOB_INFORMATION1 job, -- Bug# 9440498 fix  old -> decode(pj.JOB_INFORMATION1,'Y','M',null)
      paaf.employee_category,
      payroll_id,
      hsck.segment2 local_unit_id
      FROM
      per_all_assignments_f paaf,
      per_jobs pj ,						 --new
      hr_soft_coding_keyflex hsck
      WHERE assignment_id=csr_v_assignment_id --21197     --21257   --21233
      AND csr_v_start_date <=paaf.EFFECTIVE_END_DATE AND
      csr_v_end_date >=paaf.EFFECTIVE_START_DATE
      AND primary_flag='Y'
      AND paaf.assignment_status_type_id <>3
      AND pj.job_id(+)=paaf.job_id
--      AND paaf.employee_category IN ('BC','WC')
      AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id    --new
      --AND hsck.segment2=to_char(csr_v_local_unit_id) --3268)	     --new
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

	CURSOR csr_person_local_unit(csr_v_business_group_id number, csr_v_local_unit_id number, csr_v_effective_date date,
	csr_v_end_date date)
	IS
	SELECT DISTINCT papf.person_id ,paaf.assignment_id
	FROM per_all_assignments_f paaf,
	per_all_people_f papf,
	hr_soft_coding_keyflex hsck
	WHERE papf.business_group_id=csr_v_business_group_id -- 3133 --paaf.assignment_id = p_assignment_id
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND papf.person_id=paaf.person_id
	AND paaf.primary_flag='Y'
	AND hsck.segment2=to_char(csr_v_local_unit_id) --3268)
       -- AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
        --AND paaf.effective_end_date
	--AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
        --AND papf.effective_end_date
	AND csr_v_end_date >= paaf.effective_start_date
	AND csr_v_effective_date <= paaf.effective_end_date
	AND csr_v_end_date >= papf.effective_start_date
	AND csr_v_effective_date <= papf.effective_end_date
        AND papf.CURRENT_EMPLOYEE_FLAG='Y'
	AND paaf.employee_category IN ('WC','BC')
	--AND ADD_MONTHS(date_of_birth,252) <= /*'31-dec-2001'*/ csr_v_end_date Bug#9440498 fix
	AND nvl(hsck.segment10,'N')='N' /* Person is not CEO */
	AND nvl(hsck.segment11,'N')='N' /* Person is not Owner/Joint Owner */
	ORDER BY papf.person_id;

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

	CURSOR csr_white_collar_from (csr_v_assignment_start_date DATE,csr_v_assignment_id NUMBER )
	IS
	SELECT min(effective_start_date)
	FROM per_all_assignments_f
	WHERE effective_start_date > csr_v_assignment_start_date --previous assignment start date
	AND employee_category='WC'
	AND assignment_id=csr_v_assignment_id;

	CURSOR csr_final_process(csr_v_person_id NUMBER, csr_v_actual_termination DATE)
	IS
	SELECT final_process_date
	FROM PER_PERIODS_OF_SERVICE
	WHERE person_id=csr_v_person_id
	AND actual_termination_date=csr_v_actual_termination;

	CURSOR csr_check_local_unit(csr_v_assignment_id NUMBER, csr_v_start_date DATE)
	IS
	SELECT hsck.segment2 FROM
	per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck
	WHERE
	paaf.assignment_id=csr_v_assignment_id
	AND paaf.effective_start_date=csr_v_start_date
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id;

	CURSOR csr_next_local_unit(csr_v_assignment_id NUMBER, csr_v_start_date DATE)
	IS
	SELECT hsck.segment2 FROM
	per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck
	WHERE
	paaf.assignment_id=csr_v_assignment_id
	AND paaf.effective_start_date=
	(SELECT min(effective_start_date)
	FROM per_all_assignments_f
	WHERE effective_start_date>csr_v_start_date
    and assignment_id=paaf.assignment_id)
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id;


L_MONTH_START_DATE DATE;
L_MONTH_END_DATE DATE;
L_LOCAL_UNIT_NAME VARCHAR2(50);
l_person_id NUMBER;
l_sex CHAR(1);
l_local_unit_id hr_organization_units.organization_id%type; --NUMBER;
l_current_local_unit_id hr_organization_units.organization_id%type;
l_next_local_unit_id hr_organization_units.organization_id%type;
l_check_local_unit_id  hr_organization_units.organization_id%type; -- NUMBER
l_assignment_category VARCHAR2(5);
l_assignment_start_date DATE;
l_assignment_end_date DATE;
l_absence_count NUMBER;
l_insurance_number varchar2(10);
l_employee_category per_all_assignments_f.employee_category%type;
l_person_number per_all_people_f.national_identifier%TYPE;
l_person_name VARCHAR2(350);
l_white_collar_from DATE;
l_terminated VARCHAR2(50);
l_painter VARCHAR2(50);
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
l_twenty_one_years DATE;
l_counter NUMBER :=0;
l_job_counter NUMBER :=0;
l_blue_max_date DATE;
l_painter_date DATE;
l_twenty_one_year DATE;
l_painter_salary NUMBER;
l_total_salary NUMBER;
l_twenty_salary NUMBER;
l_asg_start_date DATE;
l_asg_end_date date;
l_category per_all_assignments_f.employee_category%type;
l_job varchar2(5);
l_prev_job varchar2(5);
l_prev_category per_all_assignments_f.employee_category%type;
l_period_start_date date;
l_period_end_date date;
l_start_gross_salary number(17,2);
l_end_gross_salary number(17,2);
l_twenty_gross_salary number(17,2);
l_days_in_payroll NUMBER;
l_days_in_period NUMBER;
l_prev_gross_salary number(17,2):=0;
l_white_from DATE:=NULL;
l_final_process_date DATE;
l_rep_start_date DATE; -- Bug#9440498 fix

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
	l_white_from date,
	l_termination_date date -- Bug#9440498 fix
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
                                                , g_year
                                                 );

/* checking whether the archiver is run during january month */

IF to_char(g_effective_date,'MM')='01' then

--	IF  g_legal_employer_id IS NOT NULL then
	/* Getting Legal employer Name */
	OPEN csr_legal_employer_details(g_legal_employer_id);
		FETCH csr_legal_employer_details  INTO l_legal_employer_name;
	CLOSE csr_legal_employer_details;


	OPEN csr_Insurance_Number(g_legal_employer_id);
		FETCH csr_Insurance_Number INTO l_insurance_number;
	CLOSE csr_Insurance_Number;

	IF g_local_unit_id IS NOT NULL THEN

		OPEN csr_local_unit_details(g_local_unit_id);
			FETCH csr_local_unit_details INTO L_LOCAL_UNIT_NAME;
		CLOSE csr_local_unit_details;

	END IF;
	l_local_unit_id:=g_local_unit_id;

	l_start_date:=to_date('01-01-' || g_year, 'dd-mm-yyyy');
	l_end_date:=to_date('31-12-' || g_year, 'dd-mm-yyyy');

	/*	OPEN csr_local_unit_details(g_local_unit_id);
			fetch  csr_local_unit_details into L_LOCAL_UNIT_NAME;
		CLOSE csr_local_unit_details;*/

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
	, p_action_information1              => 'PYSEFORA'
	, p_action_information2              => g_legal_employer_id
	, p_action_information3              => L_LEGAL_EMPLOYER_NAME
	, p_action_information4              => hr_general.decode_lookup('SE_REQUEST_LEVEL',g_LU_request)
	, p_action_information5              => g_local_unit_id
	, p_action_information6              => L_LOCAL_UNIT_NAME
	, p_action_information7              => FND_NUMBER.NUMBER_TO_CANONICAL(g_year)
	, p_action_information8              => to_char(l_insurance_number)
	);
	-- *****************************************************************************



	IF g_LU_request ='LU_SELECTED' THEN
		/* THis is for Given LOCAL UNIT */


		OPEN csr_CFAR_FROM_LU (g_local_unit_id);
			FETCH csr_CFAR_FROM_LU INTO lr_CFAR_FROM_LU;
		CLOSE csr_CFAR_FROM_LU;

		L_CFAR_NUMBER :=lr_CFAR_FROM_LU.CFAR;
		l_local_unit_name:=lr_CFAR_FROM_LU.LU_NAME;


		FOR csr_person IN csr_person_local_unit(g_business_group_id, g_local_unit_id, l_start_date,l_end_date /*g_effective_date*/) LOOP

			l_person_id:=csr_person.person_id;
			l_assignment_id:=csr_person.assignment_id;

			OPEN csr_employee_details(l_person_id,l_end_date);
				FETCH csr_employee_details INTO  l_person_number,l_person_name,l_date_birth;
			CLOSE csr_employee_details;

			/*	OPEN csr_employee_category(l_person_id, l_start_date, l_end_date);
					FETCH csr_employee_category INTO  l_employee_category;
				CLOSE csr_employee_category;*/
				/*(fnd_file.put_line(fnd_file.LOG,'l_employee_category'||l_employee_category);
				OPEN csr_white_collar(l_person_id, l_end_date );
					FETCH csr_white_collar INTO l_white_collar_from;
				CLOSE csr_white_collar;
				fnd_file.put_line(fnd_file.LOG,'l_white_collar_from'||l_white_collar_from);*/

			OPEN csr_termination(l_person_id, l_start_date,l_end_date );
				FETCH csr_termination INTO l_termination_date;
			CLOSE csr_termination;
			IF l_termination_date IS NULL THEN
				l_terminated:=null;
			ELSE
				l_terminated:='S';
			END IF;

			/*OPEN csr_painter(l_person_id, l_start_date,l_end_date);
					FETCH csr_painter INTO l_painter;
				CLOSE csr_painter;
				IF l_painter='Y' THEN
				   l_painter:='M';
				ELSE
				    l_painter:=NULL;
				END IF;*/
			/*OPEN csr_assignment_action(p_payroll_action_id);
					FETCH csr_assignment_action INTO l_assignment_action_id;
				CLOSE csr_assignment_action;*/
				/* check whether the person has crossed 21 before the start of the year itself*/
			pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id); --133942);
			pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id); --3621);
			--OPEN  csr_Get_Defined_Balance_Id( 'EMPLOYER_TAXABLE_BASE_PER_LU_YTD');
			OPEN  csr_Get_Defined_Balance_Id( 'EMPLOYER_TAXABLE_BASE_ASG_YTD');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
			CLOSE csr_Get_Defined_Balance_Id;

			l_twenty_one_years:=ADD_MONTHS(l_date_birth,252);

			IF l_person_number IS NOT NULL THEN
				FOR csr_assignments IN csr_assignment_details(g_local_unit_id,l_assignment_id,l_start_date,l_end_date) LOOP
				/*OPEN csr_termination(l_person_id, l_start_date,l_end_date );
					FETCH csr_termination INTO l_termination_date;
				CLOSE csr_termination;
				fnd_file.put_line(fnd_file.LOG,'l_termination_date'||l_termination_date);
				IF l_termination_date IS NULL THEN
					l_terminated:=null;
				ELSE
					l_terminated:='S';
				END IF;*/
					l_payroll_id:=csr_assignments.payroll_id;
					l_asg_start_date:=csr_assignments.effective_start_date;
					l_asg_end_date:=csr_assignments.effective_end_date;
					l_category:=csr_assignments.employee_category;
					l_job:=csr_assignments.job;
					l_current_local_unit_id:=csr_assignments.local_unit_id;
					/*IF l_category='WC' AND l_prev_category <> 'WC' THEN
						l_white_from:=l_asg_start_date;
					 END IF;*/
					 OPEN csr_next_local_unit(l_assignment_id, l_asg_start_date);
						FETCH csr_next_local_unit INTO l_next_local_unit_id;
					 CLOSE csr_next_local_unit;
					 /*check whether the local unit is same in assignment and next local unit is different */
					 /* In this case proration is not required */
					 IF l_current_local_unit_id=g_local_unit_id AND l_next_local_unit_id <> g_local_unit_id THEN
						l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>l_asg_end_date);
						l_counter:=l_counter+1;
						l_gross_salary:=nvl(l_value,0)-l_prev_gross_salary;
						emp_record(l_counter).l_start_date:= l_asg_start_date;
						emp_record(l_counter).l_end_date:= l_asg_end_date;
						emp_record(l_counter).l_category:=l_category;
						emp_record(l_counter).l_job:=l_job;
						emp_record(l_counter).l_gross_salary:=l_gross_salary;
						emp_record(l_counter).l_termination:=l_terminated;
						emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
						l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;
					 /* check whether the local unit is different */
					 /* no need to update the table, but calculate the balance values*/
					 ELSIF l_current_local_unit_id<>g_local_unit_id THEN
						l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>l_asg_end_date);
						/* accumulating the previous salary values*/
						l_prev_gross_salary:=/*l_prev_gross_salary+*/nvl(l_value,0);
					 /* The local unit value is not changed over here*/
					 ELSE
						/* one record which crosses the period */
						IF l_asg_end_date>=l_end_date AND l_counter=0 THEN
							/* Get the gross salary for whole year */
							/*l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
							P_ASSIGNMENT_ID =>l_assignment_id, --21348,
							P_VIRTUAL_DATE=>l_end_date/*TO_DATE('31-jan-2001')*/--);
							/*l_gross_salary:=l_value;
							fnd_file.put_line(fnd_file.LOG,'l_value'||l_value);
							fnd_file.put_line(fnd_file.LOG,'l_gross_salary'||l_gross_salary);
							l_counter:=l_counter+1;
							OPEN csr_termination(l_person_id, l_start_date,l_end_date );
								FETCH csr_termination INTO l_termination_date;
							CLOSE csr_termination;
							IF l_termination_date IS NULL THEN
								l_terminated:=null;
							ELSE
								l_terminated:='S';
							END IF;
							emp_record(l_counter).l_start_date:= l_asg_start_date;
							emp_record(l_counter).l_end_date:= l_asg_end_date;
							emp_record(l_counter).l_category:=l_category;
							emp_record(l_counter).l_job:=l_job;
							emp_record(l_counter).l_gross_salary:=l_gross_salary;
							emp_record(l_counter).l_termination:=l_terminated;
							fnd_file.put_line(fnd_file.LOG,'l_payroll_id'||l_payroll_id);
							fnd_file.put_line(fnd_file.LOG,'l_asg_start_date'||l_asg_start_date);
							fnd_file.put_line(fnd_file.LOG,'l_asg_end_date'||l_asg_end_date);
							fnd_file.put_line(fnd_file.LOG,'l_category'||l_category);
							fnd_file.put_line(fnd_file.LOG,'l_job'||l_job);
							fnd_file.put_line(fnd_file.LOG,'l_gross_salary'||l_gross_salary);
							fnd_file.put_line(fnd_file.LOG,'l_terminated'||l_terminated);*/
							/* If the age of the person crosses 21 or greater than 21 */
							--IF  l_twenty_one_years<=l_asg_end_date THEN
							IF  l_twenty_one_years<=l_start_date THEN
								/* Get the gross salary for whole year */
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>l_end_date/*TO_DATE('31-jan-2001')*/);
								l_gross_salary:=l_value;

							ELSE
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>l_end_date/*TO_DATE('31-jan-2001')*/);
								l_gross_salary:=l_value;
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>trunc(l_twenty_one_years,'MM')-1/*TO_DATE('31-jan-2001')*/);
								l_gross_salary:=l_gross_salary-l_value;

							END IF;
							l_counter:=l_counter+1;
							/*OPEN csr_termination(l_person_id, l_start_date,l_end_date );
								FETCH csr_termination INTO l_termination_date;
							CLOSE csr_termination;
							IF l_termination_date IS NULL THEN
								l_terminated:=null;
							ELSE
								l_terminated:='S';
							END IF;*/
							emp_record(l_counter).l_start_date:= l_asg_start_date;
							emp_record(l_counter).l_end_date:= l_asg_end_date;
							emp_record(l_counter).l_category:=l_category;
							emp_record(l_counter).l_job:=l_job;
							emp_record(l_counter).l_gross_salary:=l_gross_salary;
							emp_record(l_counter).l_termination:=l_terminated;
							emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
							IF l_category='BC' THEN
								OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
									FETCH csr_white_collar_from  INTO l_white_from;
								CLOSE csr_white_collar_from;
								IF l_white_from IS NOT NULL THEN
									emp_record(l_counter).l_white_from:=l_white_from;
								END IF;
							END IF;
							IF l_category='BC' THEN
								OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
									FETCH csr_white_collar_from  INTO l_white_from;
								CLOSE csr_white_collar_from;
								IF l_white_from IS NOT NULL THEN
									emp_record(l_counter).l_white_from:=l_white_from;
								END IF;
							END IF;
							/*IF l_category='WC' THEN
								fnd_file.put_line(fnd_file.LOG,'The person is white collar');
								IF l_prev_category IS NULL OR  l_prev_category <> 'WC' THEN
									fnd_file.put_line(fnd_file.LOG,'Setting the white collar');
									emp_record(l_counter).l_white_from:=l_asg_start_date;
									fnd_file.put_line(fnd_file.LOG,'emp_record(l_counter).l_white_from'||emp_record(l_counter).l_white_from);
								END IF;
							END IF;*/
						ELSE
							OPEN csr_payroll_periods(l_asg_end_date,l_payroll_id);
								FETCH csr_payroll_periods INTO l_period_start_date,l_period_end_date;
							CLOSE csr_payroll_periods;
							l_days_in_payroll:=l_period_end_date-l_period_start_date+1;
							l_days_in_period:=least(l_asg_end_date,l_period_end_date)-l_period_start_date+1;
							/* If the age of the person crosses 21 or greater than 21 */
							IF  l_twenty_one_years<=l_asg_end_date THEN
								/* checking whether the new record has been created by updation of category or job */
								IF (nvl(l_prev_job,'n') = nvl(l_job,'n') AND nvl(l_prev_category,'n') = nvl(l_category,'n')) THEN
								/*IF (l_prev_job <> l_job AND l_prev_category <> l_category) OR (l_prev_job IS NULL AND l_prev_category IS NULL) THEN*/
									emp_record(l_counter).l_end_date:= l_asg_end_date;
									l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>greatest(l_period_start_date-1,l_twenty_one_years)); /*TO_DATE('31-jan-2001'));*/
									l_start_gross_salary:=l_value;

									l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date)); /*TO_DATE('31-jan-2001'));*/
									l_end_gross_salary:=l_value;
									l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
									/*l_prev_gross_salary:=l_prev_gross_salary-emp_record(l_counter).l_gross_salary;
									fnd_file.put_line(fnd_file.LOG,'l_prev_gross_salary'||l_prev_gross_salary);
									fnd_file.put_line(fnd_file.LOG,'emp_record(l_counter).l_gross_salary'||emp_record(l_counter).l_gross_salary);*/
										/*Check whether the local unit of the assignment is the same */
										--fnd_file.put_line(fnd_file.LOG,'l_assignment_id'||l_assignment_id);
										--fnd_file.put_line(fnd_file.LOG,'l_asg_start_date'||l_asg_start_date);
										--OPEN csr_check_local_unit(l_assignment_id, l_asg_start_date);
										--FETCH csr_check_local_unit INTO l_check_local_unit_id;
										--CLOSE csr_check_local_unit;
										--fnd_file.put_line(fnd_file.LOG,'l_check_local_unit_id'||l_check_local_unit_id);
										/* check whether the local unit id is same for the current assignment */
										--IF  l_check_local_unit_id=g_local_unit_id THEN
										emp_record(l_counter).l_gross_salary:=emp_record(l_counter).l_gross_salary+l_gross_salary;
										--END IF;
									l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;
								ELSE
																	/*Check whether the local unit of the assignment is the same */
										--OPEN csr_check_local_unit(l_assignment_id, l_asg_start_date);
										--FETCH csr_check_local_unit INTO l_check_local_unit_id;
										--CLOSE csr_check_local_unit;
										--fnd_file.put_line(fnd_file.LOG,'l_check_local_unit_id'||l_check_local_unit_id);
										/* check whether the local unit id is same for the current assignment */
										--IF  l_check_local_unit_id=g_local_unit_id THEN
										--emp_record(l_counter).l_gross_salary:=emp_record(l_counter).l_gross_salary+l_gross_salary;
										l_counter:=l_counter+1;
										emp_record(l_counter).l_start_date:= l_asg_start_date;
										emp_record(l_counter).l_end_date:= l_asg_end_date;
										emp_record(l_counter).l_category:=l_category;
										emp_record(l_counter).l_job:=l_job;
										emp_record(l_counter).l_termination:=l_terminated;
										emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
										--END IF;
									/*l_counter:=l_counter+1;
									emp_record(l_counter).l_start_date:= l_asg_start_date;
									emp_record(l_counter).l_end_date:= l_asg_end_date;
									emp_record(l_counter).l_category:=l_category;
									emp_record(l_counter).l_job:=l_job;
									emp_record(l_counter).l_termination:=l_terminated;*/
									IF l_category='BC' THEN
										OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
											FETCH csr_white_collar_from  INTO l_white_from;
										CLOSE csr_white_collar_from;
										IF l_white_from IS NOT NULL THEN
											emp_record(l_counter).l_white_from:=l_white_from;
										END IF;
									END IF;
									/*IF l_category='WC' THEN
										fnd_file.put_line(fnd_file.LOG,'The person is white collar');
										IF l_prev_category IS NULL OR  l_prev_category <> 'WC' THEN
											fnd_file.put_line(fnd_file.LOG,'Setting the white collar');
											emp_record(l_counter).l_white_from:=l_asg_start_date;
											fnd_file.put_line(fnd_file.LOG,'emp_record(l_counter).l_white_from'||emp_record(l_counter).l_white_from);
										END IF;
									END IF;*/
									/*IF l_prev_category<>'WC' AND l_category='WC' THEN
										emp_record(l_counter).l_termination:=l_terminated;
									END IF;*/
									/* IF the end period exceeds the l_end_date then */
									IF l_asg_end_date>=l_end_date THEN
										l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_end_date); /*TO_DATE('31-jan-2001'));*/
										l_gross_salary:=l_value-l_prev_gross_salary;
										--IF  l_check_local_unit_id=g_local_unit_id THEN
						/*CHECK here*/				emp_record(l_counter).l_gross_salary:=l_gross_salary;
										--END IF;
										l_prev_gross_salary:=l_gross_salary;
										/*l_counter:=l_counter+1;
										emp_record(l_counter).l_start_date:= l_asg_start_date;
										emp_record(l_counter).l_end_date:= l_asg_end_date;
										emp_record(l_counter).l_category:=l_category;
										emp_record(l_counter).l_job:=l_job;
										emp_record(l_counter).l_termination:=l_terminated;
										emp_record(l_counter).l_gross_salary:=l_gross_salary;*/
									ELSE
										IF l_asg_start_date=l_period_start_date THEN
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											P_VIRTUAL_DATE=>(l_period_start_date)); /*TO_DATE('31-jan-2001'));*/
											l_start_gross_salary:=l_value;
										ELSE

											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											P_VIRTUAL_DATE=>(l_period_start_date-1)); /*TO_DATE('31-jan-2001'));*/
											l_start_gross_salary:=l_value;
										END IF;
										/* check whether the person is terminated */
										/* If terminated use the final process date to get the value of balance */
										IF l_termination_date IS NOT NULL THEN
											OPEN csr_final_process(l_person_id,l_termination_date-1);
												FETCH csr_final_process INTO l_final_process_date;
											CLOSE csr_final_process;
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											--P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date,l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
											P_VIRTUAL_DATE=>l_final_process_date);
											l_end_gross_salary:=l_value;
											l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary));
										ELSE
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											--P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date,l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
											P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date));
											l_end_gross_salary:=l_value;

											l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
										END IF;

										--l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
										l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;
										IF  l_twenty_one_years < l_asg_start_date then
											emp_record(l_counter).l_gross_salary:=l_gross_salary;
										ELSE
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											P_VIRTUAL_DATE=>LEAST((trunc(l_twenty_one_years,'MM')-1),l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
											l_twenty_gross_salary:=l_value;
											l_gross_salary:=l_start_gross_salary-NVL(l_twenty_gross_salary,0)+((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
											--IF  l_check_local_unit_id=g_local_unit_id THEN
												emp_record(l_counter).l_gross_salary:=l_gross_salary;
											--END IF;
										END IF;
									END IF;
									--	ELSE
								END IF;
								--emp_record(l_counter).l_white_from:=l_white_from;
								/*	emp_record(l_counter).l_end_date:= l_asg_end_date;
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>greatest(l_period_start_date-1,l_twenty_one_years)); /*TO_DATE('31-jan-2001'));*/
								/*	l_start_gross_salary:=l_value;
																	l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>l_period_end_date); /*TO_DATE('31-jan-2001'));*/
								/*l_end_gross_salary:=l_value;
								l_gross_salary:=l_start_gross_salary- l_prev_gross_salary + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
								emp_record(l_counter).l_gross_salary:=l_value;
								l_prev_gross_salary:=l_gross_salary;
								END IF;*/
								l_prev_job:=l_job;
								l_prev_category:=l_category;
								l_asg_start_date:=null;
								l_asg_end_date:=null;
								l_category:= null;
								l_job:= null;
								/*l_termination_date:=null;
								l_terminated:=null;*/
								l_start_gross_salary:=null;
								l_end_gross_salary:=null;
								l_twenty_gross_salary:=null;
							END IF;
						END IF;
					END IF;
					/* fnd_file.put_line(fnd_file.LOG,'Within the ');
							pay_action_information_api.create_action_information
							      (p_action_information_id              => l_action_info_id
							       , p_action_context_id                => p_payroll_action_id
							       , p_action_context_type              => 'PA'
							       , p_object_version_number            => l_ovn
							       , p_effective_date                   => g_effective_date
							       , p_source_id                        => NULL
							       , p_source_text                      => NULL
							       , p_action_information_category      => 'EMEA REPORT INFORMATION'
							       , p_action_information1              => 'PYSEFORA'
							       , p_action_information2              => 'PER'
							       , p_action_information3              => L_LEGAL_EMPLOYER_NAME
							   , p_action_information4              => l_local_unit_id
							       , p_action_information5              => l_local_unit_name --lr_CFAR_FROM_LU.LU_NAME
							       , p_action_information6              => L_CFAR_NUMBER
							       , p_action_information7              => l_person_number
							       , p_action_information8              => l_person_name
							       , p_action_information9              => emp_record(l_counter).l_category
							       , p_action_information10             => fnd_date.date_to_canonical(emp_record(l_counter).l_white_from)
							       , p_action_information11             => FND_NUMBER.NUMBER_TO_CANONICAL(emp_record(l_counter).l_gross_salary)
							       , p_action_information12             => emp_record(l_counter).l_termination
							       , p_action_information13             => emp_record(l_counter).l_job
							       );*/

					l_white_from:=null;
				END LOOP;

				FOR csr_record IN emp_record.FIRST .. emp_record.last  LOOP
					-- Bug#9440498 fix starts
					l_rep_start_date := null;
			                if emp_record(csr_record).l_start_date between l_start_date and l_end_date then
						l_rep_start_date := emp_record(csr_record).l_start_date ;
					end if;
					-- Bug#9440498 fix ends
					pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSEFORA'
					, p_action_information2              => 'PER'
					, p_action_information3              => L_LEGAL_EMPLOYER_NAME
					, p_action_information4              => l_local_unit_id
					, p_action_information5              => l_local_unit_name --lr_CFAR_FROM_LU.LU_NAME
					, p_action_information6              => L_CFAR_NUMBER
					, p_action_information7              => l_person_number
					, p_action_information8              => l_person_name
					, p_action_information9              => emp_record(csr_record).l_category
					, p_action_information10             => fnd_date.date_to_canonical(emp_record(csr_record).l_white_from)
					, p_action_information11             => FND_NUMBER.NUMBER_TO_CANONICAL(emp_record(csr_record).l_gross_salary)
					, p_action_information12             => emp_record(csr_record).l_termination
					, p_action_information13             => emp_record(csr_record).l_job
					, p_action_information14             => fnd_date.date_to_canonical(emp_record(csr_record).l_termination_date) -- Bug#9440498 fix
					, p_action_information15             => fnd_date.date_to_canonical(l_rep_start_date) -- Bug#9440498 fix
					);
					emp_record.delete(csr_record);
				END LOOP;
			END IF;
			l_counter:=0;
			l_prev_category:=NULL;
			l_prev_job:=NULL;
			l_person_number:=NULL;
			l_prev_gross_salary:=0;
			l_termination_date:=null;
			l_terminated:=null;
		END LOOP;

	ELSE
		FOR csr_local IN csr_Local_unit_Legal(g_legal_employer_id) LOOP
			l_local_unit_id:=csr_local.local_unit_id;
			OPEN csr_CFAR_FROM_LU (l_local_unit_id);
				FETCH csr_CFAR_FROM_LU INTO lr_CFAR_FROM_LU;
			CLOSE csr_CFAR_FROM_LU;

			L_CFAR_NUMBER :=lr_CFAR_FROM_LU.CFAR;
			l_local_unit_name:=lr_CFAR_FROM_LU.LU_NAME;

			FOR csr_person IN csr_person_local_unit(g_business_group_id, l_local_unit_id, l_start_date,l_end_date /*g_effective_date*/) LOOP

				l_person_id:=csr_person.person_id;
				l_assignment_id:=csr_person.assignment_id;


				OPEN csr_employee_details(l_person_id,l_end_date);
					FETCH csr_employee_details INTO  l_person_number,l_person_name,l_date_birth;
				CLOSE csr_employee_details;
				/*	OPEN csr_employee_category(l_person_id, l_start_date, l_end_date);
						FETCH csr_employee_category INTO  l_employee_category;
					CLOSE csr_employee_category;*/
					/*(fnd_file.put_line(fnd_file.LOG,'l_employee_category'||l_employee_category);
					OPEN csr_white_collar(l_person_id, l_end_date );
						FETCH csr_white_collar INTO l_white_collar_from;
					CLOSE csr_white_collar;
					fnd_file.put_line(fnd_file.LOG,'l_white_collar_from'||l_white_collar_from);*/

				OPEN csr_termination(l_person_id, l_start_date,l_end_date );
					FETCH csr_termination INTO l_termination_date;
				CLOSE csr_termination;
				IF l_termination_date IS NULL THEN
					l_terminated:=null;
				ELSE
					l_terminated:='S';
				END IF;

					/*OPEN csr_painter(l_person_id, l_start_date,l_end_date);
						FETCH csr_painter INTO l_painter;
					CLOSE csr_painter;
					IF l_painter='Y' THEN
					   l_painter:='M';
					ELSE
					    l_painter:=NULL;
					END IF;*/
	/*				OPEN csr_assignment_action(p_payroll_action_id);
						FETCH csr_assignment_action INTO l_assignment_action_id;
					CLOSE csr_assignment_action;*/
					/* check whether the person has crossed 21 before the start of the year itself*/
				pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id); --133942);
				pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id); --3621);
				OPEN  csr_Get_Defined_Balance_Id( 'EMPLOYER_TAXABLE_BASE_PER_LU_YTD');
					FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;

				l_twenty_one_years:=ADD_MONTHS(l_date_birth,252);
				IF l_person_number IS NOT NULL THEN
					FOR csr_assignments IN csr_assignment_details(l_local_unit_id,l_assignment_id,l_start_date,l_end_date) LOOP
						/*OPEN csr_termination(l_person_id, l_start_date,l_end_date );
							FETCH csr_termination INTO l_termination_date;
						CLOSE csr_termination;
						fnd_file.put_line(fnd_file.LOG,'l_termination_date'||l_termination_date);
						IF l_termination_date IS NULL THEN
							l_terminated:=null;
						ELSE
							l_terminated:='S';
						END IF; */
						l_payroll_id:=csr_assignments.payroll_id;
						l_asg_start_date:=csr_assignments.effective_start_date;
						l_asg_end_date:=csr_assignments.effective_end_date;
						l_category:=csr_assignments.employee_category;
						l_job:=csr_assignments.job;
						l_current_local_unit_id:=csr_assignments.local_unit_id;
						/*IF l_category='WC' AND l_prev_category <> 'WC' THEN
							l_white_from:=l_asg_start_date;
						END IF;*/
						OPEN csr_next_local_unit(l_assignment_id, l_asg_start_date);
						  FETCH csr_next_local_unit INTO l_next_local_unit_id;
					    CLOSE csr_next_local_unit;
					    /*check whether the local unit is same in assignment and next local unit is different */
					   /* In this case proration is not required */
					   IF l_current_local_unit_id=l_local_unit_id AND l_next_local_unit_id <> l_local_unit_id THEN
						  l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
						  P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						  P_VIRTUAL_DATE=>l_asg_end_date);
						  l_counter:=l_counter+1;
						  l_gross_salary:=nvl(l_value,0)-l_prev_gross_salary;
						  emp_record(l_counter).l_start_date:= l_asg_start_date;
						  emp_record(l_counter).l_end_date:= l_asg_end_date;
						  emp_record(l_counter).l_category:=l_category;
						  emp_record(l_counter).l_job:=l_job;
						  emp_record(l_counter).l_gross_salary:=l_gross_salary;
						  emp_record(l_counter).l_termination:=l_terminated;
						  emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
						  l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;
					      /* check whether the local unit is different */
					      /* no need to update the table, but calculate the balance values*/
					   ELSIF l_current_local_unit_id<>l_local_unit_id THEN
						  l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
						  P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						  P_VIRTUAL_DATE=>l_asg_end_date);
						  /* accumulating the previous salary values*/
						  l_prev_gross_salary:=/*l_prev_gross_salary+*/nvl(l_value,0);
					      /* The local unit value is not changed over here*/
					   ELSE
						/* one record which crosses the period */
						IF l_asg_end_date>=l_end_date AND l_counter=0 THEN
							/* If the age of the person crosses 21 or greater than 21 */
							IF  l_twenty_one_years<=l_start_date THEN
								/* Get the gross salary for whole year */
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>l_end_date/*TO_DATE('31-jan-2001')*/);
								l_gross_salary:=l_value;

							ELSE
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>l_end_date/*TO_DATE('31-jan-2001')*/);
								l_gross_salary:=l_value;
								l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
								P_ASSIGNMENT_ID =>l_assignment_id, --21348,
								P_VIRTUAL_DATE=>trunc(l_twenty_one_years,'MM')-1/*TO_DATE('31-jan-2001')*/);
								l_gross_salary:=l_gross_salary-l_value;
							END IF;
							l_counter:=l_counter+1;
							/*OPEN csr_termination(l_person_id, l_start_date,l_end_date );
								FETCH csr_termination INTO l_termination_date;
							CLOSE csr_termination;
							IF l_termination_date IS NULL THEN
								l_terminated:=null;
							ELSE
								l_terminated:='S';
							END IF;*/
							emp_record(l_counter).l_start_date:= l_asg_start_date;
							emp_record(l_counter).l_end_date:= l_asg_end_date;
							emp_record(l_counter).l_category:=l_category;
							emp_record(l_counter).l_job:=l_job;
							emp_record(l_counter).l_gross_salary:=l_gross_salary;
							emp_record(l_counter).l_termination:=l_terminated;
							emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
							IF l_category='BC' THEN
									OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
										FETCH csr_white_collar_from  INTO l_white_from;
									CLOSE csr_white_collar_from;
									IF l_white_from IS NOT NULL THEN
										emp_record(l_counter).l_white_from:=l_white_from;
									END IF;
								END IF;
							/*IF l_category='WC' THEN
								IF l_prev_category IS NULL OR  l_prev_category <> 'WC' THEN
									emp_record(l_counter).l_white_from:=l_asg_start_date;
								END IF;
							END IF;*/
						ELSE
							OPEN csr_payroll_periods(l_asg_end_date,l_payroll_id);
								FETCH csr_payroll_periods INTO l_period_start_date,l_period_end_date;
							CLOSE csr_payroll_periods;
							l_days_in_payroll:=l_period_end_date-l_period_start_date+1;
							l_days_in_period:=least(l_asg_end_date,l_end_date)-l_period_start_date+1;
							/* If the age of the person crosses 21 or greater than 21 */
							IF  l_twenty_one_years<=l_asg_end_date THEN
								/* checking whether the new record has been created by updation of category or job */
								--IF (l_prev_job = l_job AND l_prev_category = l_category) THEN
								IF (nvl(l_prev_job,'n') = nvl(l_job,'n') AND nvl(l_prev_category,'n') = nvl(l_category,'n')) THEN
									/*IF (l_prev_job <> l_job AND l_prev_category <> l_category) OR (l_prev_job IS NULL AND l_prev_category IS NULL) THEN*/
									emp_record(l_counter).l_end_date:= l_asg_end_date;
									l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>greatest(l_period_start_date-1,l_twenty_one_years)); /*TO_DATE('31-jan-2001'));*/
									l_start_gross_salary:=l_value;


									l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
									P_ASSIGNMENT_ID =>l_assignment_id, --21348,
									P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date)); /*TO_DATE('31-jan-2001'));*/
									l_end_gross_salary:=l_value;
									l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
									/*emp_record(l_counter).l_gross_salary:=l_gross_salary;
									l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;		   */
									emp_record(l_counter).l_gross_salary:=emp_record(l_counter).l_gross_salary+l_gross_salary;
									l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;
								ELSE
									/* IF the end period exceeds the l_end_date then */
									IF l_asg_end_date>=l_end_date THEN
										l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_end_date); /*TO_DATE('31-jan-2001'));*/
										l_gross_salary:=l_value-l_prev_gross_salary;

										l_prev_gross_salary:=l_gross_salary;
										l_counter:=l_counter+1;
										emp_record(l_counter).l_start_date:= l_asg_start_date;
										emp_record(l_counter).l_end_date:= l_asg_end_date;
										emp_record(l_counter).l_category:=l_category;
										emp_record(l_counter).l_job:=l_job;
										emp_record(l_counter).l_termination:=l_terminated;
										emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
										emp_record(l_counter).l_gross_salary:=l_gross_salary;
										IF l_category='BC' THEN
										OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
											FETCH csr_white_collar_from  INTO l_white_from;
										CLOSE csr_white_collar_from;
										IF l_white_from IS NOT NULL THEN
											emp_record(l_counter).l_white_from:=l_white_from;
										END IF;
									END IF;
									IF l_category='BC' THEN
										OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
											FETCH csr_white_collar_from  INTO l_white_from;
										CLOSE csr_white_collar_from;
										IF l_white_from IS NOT NULL THEN
											emp_record(l_counter).l_white_from:=l_white_from;
										END IF;
									END IF;
										/*IF l_category='WC' THEN
											IF l_prev_category IS NULL OR  l_prev_category <> 'WC' THEN
												emp_record(l_counter).l_white_from:=l_asg_start_date;
											END IF;
										END IF;	*/

									ELSE
										l_counter:=l_counter+1;
										emp_record(l_counter).l_start_date:= l_asg_start_date;
										emp_record(l_counter).l_end_date:= l_asg_end_date;
										emp_record(l_counter).l_category:=l_category;
										emp_record(l_counter).l_job:=l_job;
										emp_record(l_counter).l_termination:=l_terminated;
										emp_record(l_counter).l_termination_date:=l_termination_date; -- Bug#9440498 fix
										IF l_category='BC' THEN
											OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
												FETCH csr_white_collar_from  INTO l_white_from;
											CLOSE csr_white_collar_from;
											/*IF l_white_from IS NOT NULL THEN
												emp_record(l_counter).l_white_from:=l_white_from;
												fnd_file.put_line(fnd_file.LOG,'emp_record(l_counter).l_white_from'||emp_record(l_counter).l_white_from);
											END IF;*/
										END IF;
										IF l_category='BC' THEN
											OPEN csr_white_collar_from(l_asg_start_date,l_assignment_id);
												FETCH csr_white_collar_from  INTO l_white_from;
											CLOSE csr_white_collar_from;
											IF l_white_from IS NOT NULL THEN
												emp_record(l_counter).l_white_from:=l_white_from;
											END IF;
										END IF;
										/*IF l_category='WC' THEN
											IF l_prev_category IS NULL OR  l_prev_category <> 'WC' THEN
												emp_record(l_counter).l_white_from:=l_asg_start_date;
											END IF;
										END IF;*/
										/*IF l_prev_category<>'WC' AND l_category='WC' THEN
											emp_record(l_counter).l_termination:=l_terminated;
										END IF;*/
										IF l_asg_start_date=l_period_start_date THEN
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											P_VIRTUAL_DATE=>(l_period_start_date)); /*TO_DATE('31-jan-2001'));*/
											l_start_gross_salary:=l_value;
										ELSE
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											P_VIRTUAL_DATE=>(l_period_start_date-1)); /*TO_DATE('31-jan-2001'));*/
											l_start_gross_salary:=l_value;
										END IF;
										/* check whether the person is terminated */
										/* If terminated use the final process date to get the value of balance */
										IF l_termination_date IS NOT NULL THEN
											OPEN csr_final_process(l_person_id,l_termination_date-1);
												FETCH csr_final_process INTO l_final_process_date;
											CLOSE csr_final_process;
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											--P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date,l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
											P_VIRTUAL_DATE=>l_final_process_date);
											l_end_gross_salary:=l_value;
											l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary));
										ELSE
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											--P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date,l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
											P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date));
											l_end_gross_salary:=l_value;

											l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
										END IF;

										/*l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										--P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date,l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
										/*P_VIRTUAL_DATE=>least(l_period_end_date,l_end_date));
										l_end_gross_salary:=l_value;

										fnd_file.put_line(fnd_file.LOG,'l_end_gross_salary'||l_end_gross_salary);
										l_gross_salary:=l_start_gross_salary- NVL(l_prev_gross_salary,0) + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);*/
										l_prev_gross_salary:=l_prev_gross_salary+l_gross_salary;

										IF  l_twenty_one_years < l_asg_start_date then
											emp_record(l_counter).l_gross_salary:=l_gross_salary;
										ELSE
											l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
											P_ASSIGNMENT_ID =>l_assignment_id, --21348,
											P_VIRTUAL_DATE=>LEAST((trunc(l_twenty_one_years,'MM')-1),l_asg_end_date)); /*TO_DATE('31-jan-2001'));*/
											l_twenty_gross_salary:=l_value;
											l_gross_salary:=l_start_gross_salary-NVL(l_twenty_gross_salary,0)+((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
											emp_record(l_counter).l_gross_salary:=l_gross_salary;
										END IF;
									END IF;
								--	ELSE
								END IF;
								--emp_record(l_counter).l_white_from:=l_white_from;
									/*	emp_record(l_counter).l_end_date:= l_asg_end_date;
										l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>greatest(l_period_start_date-1,l_twenty_one_years)); /*TO_DATE('31-jan-2001'));*/
									/*	l_start_gross_salary:=l_value;

										l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
										P_ASSIGNMENT_ID =>l_assignment_id, --21348,
										P_VIRTUAL_DATE=>l_period_end_date); /*TO_DATE('31-jan-2001'));*/
										/*l_end_gross_salary:=l_value;
										l_gross_salary:=l_start_gross_salary- l_prev_gross_salary + ((l_end_gross_salary-l_start_gross_salary)*l_days_in_period/l_days_in_payroll);
										emp_record(l_counter).l_gross_salary:=l_value;
										l_prev_gross_salary:=l_gross_salary;
									END IF;*/
								l_prev_job:=l_job;
								l_prev_category:=l_category;
								l_asg_start_date:=null;
								l_asg_end_date:=null;
								l_category:= null;
								l_job:= null;
								/*l_termination_date:=null;
								l_terminated:=null;	  */
								l_start_gross_salary:=null;
								l_end_gross_salary:=null;
								l_twenty_gross_salary:=null;

							END IF;
						END IF;
                    END IF;

						l_white_from:=null;
					END LOOP;
					/*FOR csr_record IN emp_record.FIRST .. emp_record.last  LOOP
						fnd_file.put_line(fnd_file.LOG,'emp_record(csr_record).l_gross_salary '||emp_record(csr_record).l_gross_salary);
					END loop;*/
					FOR csr_record IN emp_record.FIRST .. emp_record.last  LOOP
						-- Bug#9440498 fix starts
						l_rep_start_date := null;
				                if emp_record(csr_record).l_start_date between l_start_date and l_end_date then
							l_rep_start_date := emp_record(csr_record).l_start_date ;
						end if;
						-- Bug#9440498 fix ends
						pay_action_information_api.create_action_information
						(p_action_information_id              => l_action_info_id
						, p_action_context_id                => p_payroll_action_id
						, p_action_context_type              => 'PA'
						, p_object_version_number            => l_ovn
						, p_effective_date                   => g_effective_date
						, p_source_id                        => NULL
						, p_source_text                      => NULL
						, p_action_information_category      => 'EMEA REPORT INFORMATION'
						, p_action_information1              => 'PYSEFORA'
						, p_action_information2              => 'PER'
						, p_action_information3              => L_LEGAL_EMPLOYER_NAME
						, p_action_information4              => l_local_unit_id
						, p_action_information5              => l_local_unit_name --lr_CFAR_FROM_LU.LU_NAME
						, p_action_information6              => L_CFAR_NUMBER
						, p_action_information7              => l_person_number
						, p_action_information8              => l_person_name
						, p_action_information9              => emp_record(csr_record).l_category
						, p_action_information10             => fnd_date.date_to_canonical(emp_record(csr_record).l_white_from)
						, p_action_information11             => FND_NUMBER.NUMBER_TO_CANONICAL(emp_record(csr_record).l_gross_salary)
						, p_action_information12             => emp_record(csr_record).l_termination
						, p_action_information13             => emp_record(csr_record).l_job
						, p_action_information14             => fnd_date.date_to_canonical(emp_record(csr_record).l_termination_date) -- Bug#9440498 fix
						, p_action_information15             => fnd_date.date_to_canonical(l_rep_start_date) -- Bug#9440498 fix
						);
						emp_record.delete(csr_record);
					END LOOP;
				END IF;
				l_counter:=0;
				l_prev_job:=null;
				l_prev_category:=null;
				--l_white_from:=null;
				l_prev_gross_salary:=0;
				l_person_number:=NULL;
				l_prev_gross_salary:=0;
				l_termination_date:=null;
				l_terminated:=null;
			END LOOP;
		END LOOP;


	END IF;
END IF;
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
       BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                               (' Entering Procedure ASSIGNMENT_ACTION_CODE'
                              , 60
                               );
      END IF;


      IF g_debug
      THEN
         hr_utility.set_location
                                (' Leaving Procedure ASSIGNMENT_ACTION_CODE'
                               , 70
                                );
      END IF;
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
      PAY_SE_EMPLOYMENT_STATISTICS.get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LE_request
                                                , g_LU_request
                                                , g_local_unit_id
                                                , g_account_date
                                                , g_posting_date
                                                , g_reporting_date
                                                 );

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
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure ARCHIVE_CODE', 380);
      END IF;



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
                  'LU_DETAILS',
		  'EMP_CAT_DETAILS',
                  'PER_DETAILS',
                  'END_PER_DETAILS',
                  'END_LU_DETAILS',
		  'END_EMP_CAT_DETAILS'
                  )
            THEN
               IF l_str9 IN
                     ('LU_DETAILS','PER_DETAILS','EMP_CAT_DETAILS')
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

   PROCEDURE get_xml_for_report (
      p_business_group_id   IN              NUMBER
    , p_payroll_action_id   IN              VARCHAR2
    , p_template_name       IN              VARCHAR2
    , p_xml                 OUT NOCOPY      CLOB
   )
   IS
--Variables needed for the report
      l_counter             NUMBER                                       := 0;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;

--Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id   pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3, action_information4
              , action_information5
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEHPDA'
            AND action_information2 = 'LE';

      CURSOR csr_report_details (
         csr_v_pa_id   pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT TO_CHAR
                   (fnd_date.canonical_to_date (action_information5)
                  , 'YYYYMMDD'
                   ) period_from
              , TO_CHAR
                   (fnd_date.canonical_to_date (action_information6)
                  , 'YYYYMMDD'
                   ) period_to
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT DETAILS'
            AND action_information1 = 'PYSEHPDA';

      lr_report_details     csr_report_details%ROWTYPE;

      CURSOR csr_all_employees_under_le (
         csr_v_pa_id   pay_action_information.action_information3%TYPE
       , csr_v_le_id   pay_action_information.action_information15%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEHPDA'
              AND action_information3 = csr_v_pa_id
              AND action_information2 = 'PER'
              AND action_information15 = csr_v_le_id
         ORDER BY action_information30;

/* End of declaration*/
/* Proc to Add the tag value and Name */
      PROCEDURE add_tag_value (p_tag_name IN VARCHAR2, p_tag_value IN VARCHAR2)
      IS
      BEGIN
         ghpd_data (l_counter).tagname := p_tag_name;
         ghpd_data (l_counter).tagvalue := p_tag_value;
         l_counter   := l_counter + 1;
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
                 , fnd_conc_req_summary_v fcrs
                 , fnd_conc_req_summary_v fcrs1
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

         add_tag_value ('PERIOD_FROM', lr_report_details.period_from);
         add_tag_value ('PERIOD_TO', lr_report_details.period_to);

         FOR rec_all_le IN csr_all_legal_employer (l_payroll_action_id)
         LOOP
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER');
            add_tag_value ('LE_DETAILS', 'LE_DETAILS');
            add_tag_value ('LE_NAME', rec_all_le.action_information4);
            add_tag_value ('LE_ORG_NUM', rec_all_le.action_information5);
            add_tag_value ('LE_DETAILS', 'LE_DETAILS_END');
            add_tag_value ('EMPLOYEES', 'EMPLOYEES');

            FOR rec_all_emp_under_le IN
               csr_all_employees_under_le (l_payroll_action_id
                                         , rec_all_le.action_information3
                                          )
            LOOP

               add_tag_value ('PERSON', 'PERSON');
               add_tag_value ('EMPLOYEE_CODE'
                            , rec_all_emp_under_le.action_information4
                             );
               add_tag_value ('EMPLOYEE_NUMBER'
                            , rec_all_emp_under_le.action_information5
                             );
               add_tag_value ('EMPLOYEE_NAME'
                            , rec_all_emp_under_le.action_information6
                             );
               add_tag_value
                  ('HOLIDAY_PAY_PER_DAY'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                     (rec_all_emp_under_le.action_information7)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_PAID_DAYS'
                            , rec_all_emp_under_le.action_information8
                             );
               add_tag_value
                  ('TOTAL_PAID_DAYS_AMOUNT'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                     (rec_all_emp_under_le.action_information9)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_SAVED_DAYS'
                            , rec_all_emp_under_le.action_information10
                             );
               add_tag_value
                  ('TOTAL_SAVED_DAYS_AMOUNT'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                    (rec_all_emp_under_le.action_information11)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_EARNED_DAYS'
                            , rec_all_emp_under_le.action_information12
                             );
               add_tag_value
                  ('TOTAL_EARNED_DAYS_AMOUNT'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                    (rec_all_emp_under_le.action_information13)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('PERSON', 'PERSON_END');
            END LOOP;                                  /* For all EMPLOYEES */


            add_tag_value ('EMPLOYEES', 'EMPLOYEES_END');
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER_END');
         END LOOP;                                 /* For all LEGAL_EMPLYER */
      END IF;                            /* for p_payroll_action_id IS NULL */

      writetoclob (p_xml);
   END get_xml_for_report;

   -----------------------------------------------------------------------------------
-- POPULATE_DATA_DETAIL generates xml for the reports.
-----------------------------------------------------------------------------------
--
--
PROCEDURE POPULATE_DATA_DETAIL
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_employee_category     IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB)
IS


/* Cursor to fetch Header Information */

l_employee_category per_all_assignments_f.employee_category%type;
l_lu_salary NUMBER;
l_salary NUMBER:=0;
l_grand_salary NUMBER:=0;

CURSOR csr_local_unit_level_details (p_payroll_action_id NUMBER)
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
FROM
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
FROM
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
AND pai1.ACTION_INFORMATION9 =l_employee_category --IN ('BC','WC')
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
pai1.ACTION_INFORMATION13 Coll_Agreement, -- Bug#9440498 fix
pai1.ACTION_INFORMATION14 Termination_Date, -- Bug#9440498 fix
pai1.ACTION_INFORMATION15 Start_Date -- Bug#9440498 fix
FROM
--pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1
WHERE
pai1.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =p_payroll_action_id --27021  --20162 --20264 --20165
/*AND pai.action_context_id = pai1.action_context_id*/
AND pai1.action_context_id= ppa.payroll_action_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'PER'
AND pai1.action_information1 = 'PYSEFORA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.ACTION_INFORMATION9=l_employee_category
AND pai1.ACTION_INFORMATION4=local_unit_id
/*AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSEFORA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'*/
ORDER BY pai1.ACTION_INFORMATION8;
--pai1.ACTION_INFORMATION4,--pai1.ACTION_INFORMATION8 ;





l_local_unit_details_rec csr_local_unit_level_details%rowtype;



l_counter             NUMBER;
l_total               NUMBER;
l_total_eft           NUMBER;
l_count               NUMBER;
l_payroll_action_id   NUMBER;
l_lu_counter_reset    VARCHAR2(10);
l_prev_local_unit     VARCHAR2(15);
l_report_date         DATE;
l_total_termination NUMBER;
l_total_hire NUMBER;
l_total_absence NUMBER;
l_total_sick NUMBER;
l_total_lu_emp NUMBER;
l_total_le_emp NUMBER;
l_legal_employer VARCHAR2(80);
l_regular_men NUMBER;
l_regular_women NUMBER;
l_temp_men NUMBER;
l_temp_women NUMBER;
l_person_number VARCHAR2(50);
l_local_unit_id hr_organization_units.organization_id%type;
l_end_date DATE; -- Bug#9440498 fix

TYPE emp_cat_type IS VARRAY(10) OF CHAR(2);
emp_cat emp_cat_type;
l_local_unit hr_organization_units.name%TYPE;

BEGIN

l_counter:=0;
IF p_employee_category='B' THEN
l_employee_category:='BC';
ELSIF p_employee_category='W' THEN
l_employee_category:='WC';
END IF;

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
                                                , g_year
                                                 );

        hr_utility.set_location('Entered Procedure GETDATA',10);

	/*	xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='LU_DETAILS';*/
/*		l_counter:=l_counter+1;*/

        /* Get the File Header Information */
         hr_utility.set_location('Before populating pl/sql table',20);
         l_lu_salary:=0;
	 IF p_employee_category IN ('B','W') THEN
			xml_tab(l_counter).TagName  :='EMP_CAT_DETAILS';
			xml_tab(l_counter).TagValue :='EMP_CAT_DETAILS';
			l_counter:=l_counter+1;
		FOR csr_local IN csr_local_unit_level_details(p_payroll_action_id) loop


			xml_tab(l_counter).TagName  :='LU_DETAILS';
			xml_tab(l_counter).TagValue :='LU_DETAILS';
			l_counter:=l_counter+1;
	      --  fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);

		hr_utility.set_location('Entered Procedure GETDATA',10);

			xml_tab(l_counter).TagName  :='LEGAL_EMPLOYER';
			xml_tab(l_counter).TagValue := csr_local.Legal_Employer;
			l_counter:=l_counter+1;

		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

			l_legal_employer:=csr_local.Legal_Employer;
		l_local_unit:=csr_local.Local_unit;

		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
		fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

			xml_tab(l_counter).TagName  :='LOCAL_UNIT';
			xml_tab(l_counter).TagValue := csr_local.Local_Unit;
			l_counter:=l_counter+1;

			l_local_unit_id:=csr_local.Local_Unit_Id;
		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

			/*xml_tab(l_counter).TagName  :='LOCAL_UNIT';
			xml_tab(l_counter).TagValue := csr_local.Local_Unit;
			l_counter:=l_counter+1;*/



		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
		IF l_employee_category='BC' THEN
		      xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
			      xml_tab(l_counter).TagValue := 'Blue Collar';
			      l_counter:=l_counter+1;
		ELSIF l_employee_category='WC' THEN
		      xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
			      xml_tab(l_counter).TagValue := 'White Collar';
			      l_counter:=l_counter+1;
		END IF;

		/*IF p_employee_category IN ('B','W') THEN */
			FOR csr_person IN csr_person_level_details (p_payroll_action_id,l_local_unit_id ) loop

				xml_tab(l_counter).TagName  :='PER_DETAILS';
				xml_tab(l_counter).TagValue :='PER_DETAILS';
				l_counter:=l_counter+1;

				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
			       xml_tab(l_counter).TagName  :='REPORTING_YEAR';
			xml_tab(l_counter).TagValue := csr_local.Reporting_Year;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='REPORT_YEAR';
			xml_tab(l_counter).TagValue := substr(csr_local.Reporting_Year,3,2);
			l_counter:=l_counter+1;
			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

			xml_tab(l_counter).TagName  :='INSURANCE_NUMBER';
			xml_tab(l_counter).TagValue := csr_local.Insurance_Number;
			l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='CFAR_NUMBER';
				xml_tab(l_counter).TagValue := csr_person.Cfar_Number;
				l_counter:=l_counter+1;

				l_person_number:=REPLACE(csr_person.Person_Number,'-');
				l_person_number:=REPLACE(l_person_number,' ');

				xml_tab(l_counter).TagName  :='PER_NUMBER';
				xml_tab(l_counter).TagValue := l_person_number;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='PERSON_NUMBER';
				xml_tab(l_counter).TagValue := csr_person.Person_Number;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='NAME';
				xml_tab(l_counter).TagValue := csr_person.Name;
				l_counter:=l_counter+1;
				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				xml_tab(l_counter).TagName  :='WHITE_FROM';
				xml_tab(l_counter).TagValue := FND_DATE.canonical_to_date(csr_person.White_Collar);
				l_counter:=l_counter+1;
				xml_tab(l_counter).TagName  :='WHITE_COL_FROM';
				xml_tab(l_counter).TagValue :=to_char(FND_DATE.canonical_to_date(csr_person.White_Collar),'YYMMDD');
			--FND_DATE.date_to_displayDT(csr_person.White_Collar,'YYMMDD');-- to_char(FND_DATE.date_to_canonical(csr_person.White_Collar),'YYMMDD');
				--to_char(csr_person.White_Collar,'YYMMDD');
				l_counter:=l_counter+1;
				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
				xml_tab(l_counter).TagName  :='SALARY';
				xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(round(csr_person.Gross_Salary));
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='SAL';
				xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(round(csr_person.Gross_Salary));
				l_counter:=l_counter+1;
				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
				l_salary:=fnd_number.canonical_to_number(round(csr_person.Gross_Salary));
				l_lu_salary:=l_lu_salary+l_salary;
				l_grand_salary:=l_grand_salary+l_salary;
				xml_tab(l_counter).TagName  :='TERMINATED';
				xml_tab(l_counter).TagValue := csr_person.Terminated;
				l_counter:=l_counter+1;

				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				xml_tab(l_counter).TagName  :='COLL_AGREEMENT'; -- Bug#9440498 fix
				xml_tab(l_counter).TagValue := csr_person.Coll_Agreement; -- Bug#9440498 fix
				l_counter:=l_counter+1;

				/* Bug#9440498 fix starts */
				xml_tab(l_counter).TagName  :='START_DATE';
				xml_tab(l_counter).TagValue := FND_DATE.canonical_to_date(csr_person.Start_Date);
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='START_DT';
				xml_tab(l_counter).TagValue :=to_char(FND_DATE.canonical_to_date(csr_person.Start_Date),'YYMMDD');
				l_counter:=l_counter+1;

				l_end_date := FND_DATE.canonical_to_date(NVL(csr_person.Termination_Date, csr_person.White_Collar));
				xml_tab(l_counter).TagName  :='END_DATE';
				xml_tab(l_counter).TagValue := l_end_date;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='END_DT';
				xml_tab(l_counter).TagValue :=to_char(l_end_date,'YYMMDD');
				l_counter:=l_counter+1;
				/* Bug#9440498 fix ends */

				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				xml_tab(l_counter).TagName  :='PER_DETAILS';
				xml_tab(l_counter).TagValue :='END_PER_DETAILS';
				l_counter := l_counter + 1;

				/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				END LOOP;

			xml_tab(l_counter).TagName  :='LU_SALARY';
			xml_tab(l_counter).TagValue :=fnd_number.canonical_to_number(l_lu_salary);
			l_counter := l_counter + 1;
		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
		fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

			l_lu_salary:=0;

			hr_utility.set_location('After populating pl/sql table',30);
			hr_utility.set_location('Entered Procedure GETDATA',10);

			xml_tab(l_counter).TagName  :='LU_DETAILS';
			xml_tab(l_counter).TagValue :='END_LU_DETAILS';
			l_counter := l_counter + 1;


		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
		fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
		END LOOP;
		xml_tab(l_counter).TagName  :='EMP_CAT_DETAILS';
		xml_tab(l_counter).TagValue :='END_EMP_CAT_DETAILS';
		l_counter:=l_counter+1;
	ELSE
		emp_cat:= emp_cat_type();
		emp_cat.EXTEND;
		emp_cat(1):='BC';
		emp_cat.EXTEND;
		emp_cat(2):='WC';
		FOR csr_emp IN emp_cat.FIRST ..emp_cat.LAST LOOP
			l_employee_category:=emp_cat(csr_emp);
			xml_tab(l_counter).TagName  :='EMP_CAT_DETAILS';
			xml_tab(l_counter).TagValue :='EMP_CAT_DETAILS';
			l_counter:=l_counter+1;
			IF l_employee_category='BC' THEN
				xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
				xml_tab(l_counter).TagValue := 'Blue Collar';
				l_counter:=l_counter+1;
			ELSIF l_employee_category='WC' THEN
				xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
				xml_tab(l_counter).TagValue := 'White Collar';
				l_counter:=l_counter+1;
			END IF;


				FOR csr_local IN csr_all_local_unit_details(p_payroll_action_id) loop

				xml_tab(l_counter).TagName  :='LU_DETAILS';
				xml_tab(l_counter).TagValue :='LU_DETAILS';
				l_counter:=l_counter+1;
		      --  fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);

			hr_utility.set_location('Entered Procedure GETDATA',10);

				xml_tab(l_counter).TagName  :='LEGAL_EMPLOYER';
				xml_tab(l_counter).TagValue := csr_local.Legal_Employer;
				l_counter:=l_counter+1;

			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				l_legal_employer:=csr_local.Legal_Employer;
			l_local_unit:=csr_local.Local_unit;

			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				xml_tab(l_counter).TagName  :='LOCAL_UNIT';
				xml_tab(l_counter).TagValue := csr_local.Local_Unit;
				l_counter:=l_counter+1;

				l_local_unit_id:=csr_local.Local_Unit_Id;
			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				/*xml_tab(l_counter).TagName  :='LOCAL_UNIT';
				xml_tab(l_counter).TagValue := csr_local.Local_Unit;
				l_counter:=l_counter+1;*/


				/*IF csr_local.Employee_Category='BC' THEN*/
				   l_employee_category:=csr_local.Employee_Category;
				/*ELSIF
				   l_employee_category:='WC';
				END IF;*/
			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
			IF l_employee_category='BC' THEN
			      xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
				      xml_tab(l_counter).TagValue := 'Blue Collar';
				      l_counter:=l_counter+1;
			ELSIF l_employee_category='WC' THEN
			      xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
				      xml_tab(l_counter).TagValue := 'White Collar';
				      l_counter:=l_counter+1;
			END IF;

			/*IF p_employee_category IN ('B','W') THEN */
				FOR csr_person IN csr_person_level_details (p_payroll_action_id,l_local_unit_id ) loop

					xml_tab(l_counter).TagName  :='PER_DETAILS';
					xml_tab(l_counter).TagValue :='PER_DETAILS';
					l_counter:=l_counter+1;

					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					-- Bug# 9440498 fix  starts
					xml_tab(l_counter).TagName  :='REPORTING_YEAR';
					xml_tab(l_counter).TagValue := csr_local.Reporting_Year;
					l_counter:=l_counter+1;

					xml_tab(l_counter).TagName  :='REPORT_YEAR';
					xml_tab(l_counter).TagValue := substr(csr_local.Reporting_Year,3,2);
					l_counter:=l_counter+1;
					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					xml_tab(l_counter).TagName  :='INSURANCE_NUMBER';
					xml_tab(l_counter).TagValue := csr_local.Insurance_Number;
					l_counter:=l_counter+1;
					-- Bug# 9440498 fix ends

					xml_tab(l_counter).TagName  :='CFAR_NUMBER';
					xml_tab(l_counter).TagValue := csr_person.Cfar_Number;
					l_counter:=l_counter+1;

					l_person_number:=REPLACE(csr_person.Person_Number,'-');
					l_person_number:=REPLACE(l_person_number,' ');

					xml_tab(l_counter).TagName  :='PER_NUMBER';
					xml_tab(l_counter).TagValue := l_person_number;
					l_counter:=l_counter+1;

					xml_tab(l_counter).TagName  :='PERSON_NUMBER';
					xml_tab(l_counter).TagValue := csr_person.Person_Number;
					l_counter:=l_counter+1;

					xml_tab(l_counter).TagName  :='NAME';
					xml_tab(l_counter).TagValue := csr_person.Name;
					l_counter:=l_counter+1;
					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					xml_tab(l_counter).TagName  :='WHITE_FROM';
					xml_tab(l_counter).TagValue := FND_DATE.canonical_to_date(csr_person.White_Collar);
					l_counter:=l_counter+1;
					xml_tab(l_counter).TagName  :='WHITE_COL_FROM';
					xml_tab(l_counter).TagValue :=to_char(FND_DATE.canonical_to_date(csr_person.White_Collar),'YYMMDD');
				--FND_DATE.date_to_displayDT(csr_person.White_Collar,'YYMMDD');-- to_char(FND_DATE.date_to_canonical(csr_person.White_Collar),'YYMMDD');
					--to_char(csr_person.White_Collar,'YYMMDD');
					l_counter:=l_counter+1;
					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					xml_tab(l_counter).TagName  :='SALARY';
					xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(round(csr_person.Gross_Salary));
					l_counter:=l_counter+1;

					xml_tab(l_counter).TagName  :='SAL';
					xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(round(csr_person.Gross_Salary));
					l_counter:=l_counter+1;

					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
					l_salary:=fnd_number.canonical_to_number(round(csr_person.Gross_Salary));
					l_lu_salary:=l_lu_salary+l_salary;
					l_grand_salary:=l_grand_salary+l_salary;
					xml_tab(l_counter).TagName  :='TERMINATED';
					xml_tab(l_counter).TagValue := csr_person.Terminated;
					l_counter:=l_counter+1;

					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					xml_tab(l_counter).TagName  :='COLL_AGREEMENT'; -- Bug#9440498 fix
					xml_tab(l_counter).TagValue := csr_person.Coll_Agreement; -- Bug#9440498 fix
					l_counter:=l_counter+1;

					/* Bug#9440498 fix starts */
					xml_tab(l_counter).TagName  :='START_DATE';
					xml_tab(l_counter).TagValue := FND_DATE.canonical_to_date(csr_person.Start_Date);
					l_counter:=l_counter+1;

					xml_tab(l_counter).TagName  :='START_DT';
					xml_tab(l_counter).TagValue :=to_char(FND_DATE.canonical_to_date(csr_person.Start_Date),'YYMMDD');
					l_counter:=l_counter+1;

					l_end_date := FND_DATE.canonical_to_date(NVL(csr_person.Termination_Date, csr_person.White_Collar));
					xml_tab(l_counter).TagName  :='END_DATE';
					xml_tab(l_counter).TagValue := l_end_date;
					l_counter:=l_counter+1;

					xml_tab(l_counter).TagName  :='END_DT';
					xml_tab(l_counter).TagValue :=to_char(l_end_date,'YYMMDD');
					l_counter:=l_counter+1;

					/* Bug#9440498 fix ends */

					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					xml_tab(l_counter).TagName  :='PER_DETAILS';
					xml_tab(l_counter).TagValue :='END_PER_DETAILS';
					l_counter := l_counter + 1;

					/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
				fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

					END LOOP;

				xml_tab(l_counter).TagName  :='LU_SALARY';
				xml_tab(l_counter).TagValue :=fnd_number.canonical_to_number(l_lu_salary);
				l_counter := l_counter + 1;
			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/

				l_lu_salary:=0;

				hr_utility.set_location('After populating pl/sql table',30);
				hr_utility.set_location('Entered Procedure GETDATA',10);

				xml_tab(l_counter).TagName  :='LU_DETAILS';
				xml_tab(l_counter).TagValue :='END_LU_DETAILS';
				l_counter := l_counter + 1;

			/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
			fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
			END LOOP;
			xml_tab(l_counter).TagName  :='EMP_CAT_DETAILS';
			xml_tab(l_counter).TagValue :='END_EMP_CAT_DETAILS';
			l_counter := l_counter + 1;
		END LOOP;
	END if;

		xml_tab(l_counter).TagName  :='GRAND_SALARY';
		xml_tab(l_counter).TagValue :=TO_CHAR(fnd_number.canonical_to_number(l_grand_salary), '999999990D99');
		l_counter := l_counter + 1;
		/*fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagName'||xml_tab(l_counter).TagName);
        fnd_file.put_line(fnd_file.LOG,'xml_tab(l_counter).TagValue'||xml_tab(l_counter).TagValue);*/
	    /*xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='END_LU_DETAILS';*/
		/*l_counter := l_counter + 1;*/
--        INSERT INTO raaj VALUES (p_xml);
        WritetoCLOB (p_xml );



END POPULATE_DATA_DETAIL;

END PAY_SE_FORA;


/
