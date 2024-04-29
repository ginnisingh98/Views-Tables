--------------------------------------------------------
--  DDL for Package Body PAY_SE_EMPLOYMENT_STATISTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_EMPLOYMENT_STATISTICS" AS
/* $Header: pysestsr.pkb 120.0.12000000.1 2007/04/20 09:27:37 abhgangu noship $ */
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
   g_package                 VARCHAR2 (33)  := 'PAY_SE_EMPLOYMENT_STATISTICS.';
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
    , p_LE_request   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_LU_request   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_LOCAL_UNIT_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_ACCOUNT_date               OUT NOCOPY      DATE        -- User parameter
    , p_POSTING_date                 OUT NOCOPY      DATE        -- User parameter
    , p_REPORTING_date               OUT nocopy      DATE        -- user parameter
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT  (PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'LE_REQUEST'
                                                      )
                ) LE_REQUEST
                ,(PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'LEGAL_EMPLOYER_ID'
                                                      )
                ) LEGAL_EMPLOYER_ID
              , (PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'LU_REQUEST'
                                                      )
                ) LU_REQUEST
              ,(PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'LOCAL_UNIT_ID'
                                                      )
                ) LOCAL_UNIT_ID
                ,(PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'ACCOUNT_DATE'
                                                      )
                ) ACCOUNT_DATE
                ,(PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'POSTING_DATE'
                                                      )
                ) POSTING_DATE
                ,(PAY_SE_EMPLOYMENT_STATISTICS.get_parameter
                                                      (legislative_parameters
                                                     , 'REPORTING_DATE'
                                                      )
                )REPORTING_DATE
              , effective_date effective_date, business_group_id bg_id
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


      p_LE_request := lr_parameter_info.LE_REQUEST;


      p_LU_request := lr_parameter_info.LU_REQUEST;


      p_local_unit_id := lr_parameter_info.LOCAL_UNIT_ID;


      p_ACCOUNT_DATE :=
                 fnd_date.canonical_to_date (lr_parameter_info.ACCOUNT_DATE);


      P_POSTING_DATE  :=
                   fnd_date.canonical_to_date (lr_parameter_info.POSTING_DATE);
      P_REPORTING_DATE :=
                   fnd_date.canonical_to_date (lr_parameter_info.REPORTING_DATE);
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
      l_start_date               VARCHAR2 (30);
      l_end_date                 VARCHAR2 (30);
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
      l_assignment_id            NUMBER;
      l_action_sequence          NUMBER;
      l_assact_id                NUMBER;
      l_pact_id                  NUMBER;
      l_flag                     NUMBER                               := 0;
      l_element_context          VARCHAR2 (5);

-- Archiving the data , as this will fire once
      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME legal_employer_name
              , hoi2.org_information2 org_number
              , hoi1.organization_id legal_id
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

      CURSOR csr_check_empty_le (
         csr_v_legal_employer_id      NUMBER
       , csr_v_canonical_start_date   DATE
       , csr_v_canonical_end_date     DATE
      )
      IS
         SELECT   '1'
             FROM pay_payroll_actions appa
                , pay_assignment_actions act
                , per_all_assignments_f as1
                , pay_payroll_actions ppa
            WHERE ppa.payroll_action_id = p_payroll_action_id
              AND appa.effective_date BETWEEN csr_v_canonical_start_date
                                          AND csr_v_canonical_end_date
              AND appa.action_type IN ('R', 'Q')
              -- Payroll Run or Quickpay Run
              AND act.payroll_action_id = appa.payroll_action_id
              AND act.source_action_id IS NULL                -- Master Action
              AND as1.assignment_id = act.assignment_id
              AND as1.business_group_id = g_business_group_id
              AND act.action_status = 'C'                         -- Completed
              AND act.tax_unit_id = csr_v_legal_employer_id
              AND appa.effective_date BETWEEN as1.effective_start_date
                                          AND as1.effective_end_date
              AND ppa.effective_date BETWEEN as1.effective_start_date
                                         AND as1.effective_end_date
         ORDER BY as1.person_id, act.assignment_id;

      l_le_has_employee          VARCHAR2 (2);
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
-- ********************* for cfar from lU ***********************
-- ********************* for ASIGNMENT fOR GIVEN LU ***********************
-- ********************* With group by FT,PT,FR,PR types   ****************
CURSOR CSR_PERSON_TYPES_COUNT (
         csr_local_unit_ID      NUMBER
      )
      is
SELECT
count(paa.assignment_id) TOTAL
,paa.employment_category EMP_CAT
,pap.SEX
FROM
PER_ALL_ASSIGNMENTS_F paa
,HR_SOFT_CODING_KEYFLEX scl1
,PER_ALL_PEOPLE_F pap
WHERE
    paa.person_id = pap.person_id
and paa.business_group_id = g_business_group_id
and scl1.segment2 = TO_CHAR(csr_local_unit_ID)
AND	scl1.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
and paa.employment_category in ('FR','FT')
and paa.ASSIGNMENT_STATUS_TYPE_ID = 1
and pap.SEX in('F','M')
AND paa.PRIMARY_FLAG='Y'
and g_account_date between paa.EFFECTIVE_START_DATE and paa.EFFECTIVE_END_DATE
and g_account_date between pap.EFFECTIVE_START_DATE and pap.EFFECTIVE_END_DATE
group by paa.employment_category,pap.SEX
order by paa.employment_category,pap.SEX;

LR_PERSON_TYPES_COUNT CSR_PERSON_TYPES_COUNT%ROWTYPE;
-- ********************* for ASIGNMENT fOR GIVEN LU ***********************
-- ********************* With group by FT,PT,FR,PR types   ****************
-- ********************* for ALL LU  for GIVEN LE***********************
CURSOR csr_ALL_LU_FOR_LE (
         csr_legal_employer_ID      NUMBER
      ) is
SELECT hoi_le.org_information1 local_unit_id,
                hou_lu.NAME local_unit_name,
                hoi_lu.org_information2 CFAR
           FROM hr_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_organization_units hou_lu,
                hr_organization_information hoi_lu
          WHERE hoi_le.organization_id = hou_le.organization_id
            AND hou_le.organization_id = csr_legal_employer_ID
            AND hoi_le.org_information_context = 'SE_LOCAL_UNITS'
            AND hou_lu.organization_id = hoi_le.org_information1
            AND hou_lu.organization_id = hoi_lu.organization_id
            AND hoi_lu.org_information_context = 'SE_LOCAL_UNIT_DETAILS';

-- ********************* for ALL LU  for GIVEN LE***********************
-- ********************* ALL LE  for GIVEN Business group id***********************
CURSOR csr_ALL_LE_FOR_BG is
 select o1.name legal_employer_name,hoi1.organization_id
           from hr_organization_units o1,
                hr_organization_information hoi1,
                hr_organization_information hoi2
          where o1.business_group_id = g_business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.org_information_context = 'CLASS'
            and o1.organization_id = hoi2.organization_id
            and hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';
-- ********************* ALL LE  for GIVEN Business group id***********************
/* To Get All the Persons, sex under the Local unit within the period */
CURSOR csr_person_local_unit(p_local_unit_id number) is
		SELECT DISTINCT paaf.person_id,sex
		FROM per_all_assignments_f paaf,
		per_all_people_f papf,
		hr_soft_coding_keyflex hsck
		WHERE paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
		AND hsck.segment2=to_char(p_local_unit_id)
		AND papf.person_id=paaf.person_id
		and papf.SEX in('F','M')
		AND paaf.PRIMARY_FLAG='Y'
                AND g_account_date BETWEEN paaf.effective_start_date
                AND paaf.effective_end_date
		AND g_account_date BETWEEN papf.effective_start_date
                AND papf.effective_end_date;
/* To Get count of  the absences under the person, either vacation or sickness */
CURSOR csr_person_absence(p_person_id number, p_month_start_date date, p_month_end_date date, p_absence_type_id  varchar2) IS
	SELECT count(*)
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = p_person_id
	AND g_account_date BETWEEN
	paa.date_start AND paa.date_end
        /*AND paa.date_start >=p_month_start_date
--	AND least(nvl(paa.date_end,p_abs_end_date),p_abs_end_date)<=p_abs_end_date
	AND paa.date_end<=p_month_end_date  */
        AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category = p_absence_type_id --'S'
        ORDER BY paa.date_end  ;

/* To Get count of  the absences under the person, other than vacation and sickness */
CURSOR csr_person_other_absence(p_person_id number, p_month_start_date date, p_month_end_date date) IS
	SELECT count(*)
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = p_person_id
        AND g_account_date BETWEEN
	paa.date_start AND paa.date_end
	/*AND paa.date_start >=p_month_start_date
--	AND least(nvl(paa.date_end,p_abs_end_date),p_abs_end_date)<=p_abs_end_date
	AND paa.date_end<=p_month_end_date*/
        AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category NOT IN ('S','V')
        ORDER BY paa.date_end  ;

/* To Get the assignments within the accounting month period, which are new hire*/
CURSOR csr_new_assignments(p_month_start_date date, p_month_end_date date ) IS
	SELECT paaf.assignment_id,paaf.EFFECTIVE_START_DATE,paaf.employment_category
	FROM  PER_ALL_ASSIGNMENTS_F paaf,
	hr_soft_coding_keyflex hsck
	WHERE paaf.EFFECTIVE_START_DATE BETWEEN p_month_start_date
	AND p_month_end_date
	AND hsck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	AND hsck.segment2=to_char(g_local_unit_id)
	and paaf.employment_category in ('FR','FT')
	AND paaf.PRIMARY_FLAG='Y'
	and paaf.ASSIGNMENT_STATUS_TYPE_ID = 1;

/* To Get the previous assignments for the current assignment*/
CURSOR csr_prev_assignments(p_assignment_id number, p_effecive_start_date date) IS
	SELECT hsck.segment2
	FROM per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck
	WHERE hsck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	AND paaf.assignment_id=p_assignment_id
	AND paaf.EFFECTIVE_START_DATE=
	(SELECT max(EFFECTIVE_START_DATE)
	FROM per_all_assignments_f
	WHERE assignment_id=p_assignment_id
	AND EFFECTIVE_START_DATE < p_effecive_start_date);

/* To get the sex of the person, from the assignment */
CURSOR csr_person_sex(p_assignment_id number) IS
	SELECT papf.sex FROM
	per_all_assignments_f paaf,
	per_all_people_f papf
	WHERE paaf.person_id=papf.person_id
	AND paaf.assignment_id=p_assignment_id
	AND g_account_date BETWEEN paaf.effective_start_date
	AND paaf.effective_end_date
	AND g_account_date BETWEEN papf.effective_start_date
	AND papf.effective_end_date;

/* To Get the assignments within the accounting month period, which are ended in one Local Unit*/
CURSOR csr_end_assignments(p_month_start_date date, p_month_end_date date ) IS
	SELECT paaf.assignment_id,paaf.EFFECTIVE_end_DATE,paaf.employment_category
	FROM  PER_ALL_ASSIGNMENTS_F paaf,
	hr_soft_coding_keyflex hsck
	WHERE paaf.effective_end_date BETWEEN p_month_start_date
	AND p_month_end_date
	AND hsck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	AND hsck.segment2=to_char(g_local_unit_id)
	and paaf.employment_category in ('FR','FT')
	AND paaf.PRIMARY_FLAG='Y'
	and paaf.ASSIGNMENT_STATUS_TYPE_ID = 1;

	/* To Get the assignments within the accounting month period, which are terminated */
CURSOR csr_ter_assignments(p_month_start_date date, p_month_end_date date ) IS
	/*SELECT paaf.assignment_id,paaf.EFFECTIVE_START_DATE,paaf.employment_category
	FROM  PER_ALL_ASSIGNMENTS_F paaf,
	hr_soft_coding_keyflex hsck
	WHERE paaf.effective_end_date BETWEEN p_month_start_date
	AND p_month_end_date
	AND hsck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	AND hsck.segment2=to_char(g_local_unit_id)
	and paaf.employment_category in ('FR','FT')
	and paaf.ASSIGNMENT_STATUS_TYPE_ID = 3;*/
	SELECT paaf.assignment_id,paaf.EFFECTIVE_START_DATE,paaf.employment_category
	FROM
	PER_ALL_ASSIGNMENTS_F paaf,
	hr_soft_coding_keyflex hsck
	WHERE
	paaf.effective_start_date BETWEEN p_month_start_date
	AND p_month_end_date
	AND hsck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	AND hsck.segment2=to_char(g_local_unit_id)
	and paaf.employment_category in ('FR','FT')
	AND paaf.PRIMARY_FLAG='Y'
	and paaf.ASSIGNMENT_STATUS_TYPE_ID = 3;


/* To Get the next assignments for the current assignment*/
CURSOR csr_next_assignments(p_assignment_id number, p_effecive_end_date date) IS
	SELECT hsck.segment2
	FROM per_all_assignments_f paaf,
	hr_soft_coding_keyflex hsck
	WHERE hsck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	AND paaf.assignment_id=p_assignment_id
	AND paaf.effective_end_date=
	(SELECT min(effective_end_date)
	FROM per_all_assignments_f
	WHERE assignment_id=p_assignment_id
	AND effective_end_date > p_effecive_end_date);

CURSOR csr_local_unit_details(p_local_unit_id number) IS
	SELECT NAME FROM
	hr_organization_units WHERE
	organization_id=p_local_unit_id;

-- VARIABLE FOR THIS REPORET
L_DATE_OF_REPORT VARCHAR2(6);

L_FISCAL_YEAR VARCHAR2(4);
L_FISCAL_QUARTER VARCHAR2(1);
L_FISCAL_MONTH VARCHAR2(1);

L_CFAR_NUMBER VARCHAR2(8);

L_REGULAR_MEN NUMBER  := 0;
L_REGULAR_WOMEN NUMBER := 0;

L_TEMPORARY_MEN NUMBER := 0;
L_TEMPORARY_WOMEN NUMBER := 0;

L_SICK_LEAVE_MEN NUMBER  := 0;
L_SICK_LEAVE_WOMEN NUMBER  := 0;

L_HOLIDAY_LEAVE_MEN NUMBER  := 0;
L_HOLIDAY_LEAVE_WOMEN NUMBER := 0;

L_OTHER_ABSENCE_MEN NUMBER := 0;
L_OTHER_ABSENCE_WOMEN NUMBER := 0;

L_NEW_HIRES_REGULAR_MEN NUMBER := 0;
L_NEW_HIRES_REGULAR_WOMEN NUMBER := 0;

L_NEW_HIRES_TEMPORARY_MEN NUMBER := 0;
L_NEW_HIRES_TEMPORARY_WOMEN NUMBER := 0;

L_TERMINATION_REGULAR_MEN NUMBER := 0;
L_TERMINATION_REGULAR_WOMEN NUMBER := 0;

L_TERMINATION_TEMPORARY_MEN NUMBER := 0;
L_TERMINATION_TEMPORARY_WOMEN NUMBER := 0;

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

IF g_legal_employer_id IS NOT NULL
THEN
    -- TO pick up the Name of the LE
      OPEN csr_legal_employer_details (g_legal_employer_id);
      FETCH csr_legal_employer_details INTO lr_legal_employer_details;
      CLOSE csr_legal_employer_details;
      L_LEGAL_EMPLOYER_NAME := lr_legal_employer_details.legal_employer_name;
ELSE
L_LEGAL_EMPLOYER_NAME :=null;
END IF;
	OPEN csr_local_unit_details(g_local_unit_id);
		fetch  csr_local_unit_details into L_LOCAL_UNIT_NAME;
	CLOSE csr_local_unit_details;
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
        , p_action_information1              => 'PYSESTEA'
        , p_action_information2              => hr_general.decode_lookup('SE_TAX_CARD_REQUEST_LEVEL',g_LE_request)
        , p_action_information3              => g_legal_employer_id
        , p_action_information4              => L_LEGAL_EMPLOYER_NAME
        , p_action_information5              => hr_general.decode_lookup('SE_REQUEST_LEVEL',g_LU_request)
        , p_action_information6              => g_local_unit_id
        , p_action_information7              => L_LOCAL_UNIT_NAME
        , p_action_information8              => fnd_date.date_to_canonical
                                                                   (g_account_date)
        , p_action_information9              => fnd_date.date_to_canonical
                                                                 (g_posting_date)
        , p_action_information10              => fnd_date.date_to_canonical(g_reporting_date)
         );
-- *****************************************************************************



   L_FISCAL_YEAR := TO_CHAR(g_account_date,'YYYY');


   L_FISCAL_QUARTER := TO_CHAR(g_account_date,'Q');


   L_FISCAL_MONTH := MOD((TO_NUMBER(TO_CHAR(g_account_date,'MM'))),3);
   IF L_FISCAL_MONTH ='0'
   THEN
       L_FISCAL_MONTH := 3;
   END IF;


  IF g_LE_request ='REQUESTING_ORG'
  THEN
    /* THis is for Given LEGAL EMOPLYER */

      IF g_LU_request ='LU_SELECTED'
      THEN
          /* THis is for Given LOCAL UNIT */



      OPEN csr_CFAR_FROM_LU (g_local_unit_id);
      FETCH csr_CFAR_FROM_LU INTO lr_CFAR_FROM_LU;
      CLOSE csr_CFAR_FROM_LU;


   L_CFAR_NUMBER :=lr_CFAR_FROM_LU.CFAR;

    FOR REC_PERSON_TYPES_COUNT IN CSR_PERSON_TYPES_COUNT (g_local_unit_id)
    LOOP
        IF REC_PERSON_TYPES_COUNT.SEX ='M'
        THEN
            IF REC_PERSON_TYPES_COUNT.EMP_CAT ='FR'
            THEN
                L_REGULAR_MEN := REC_PERSON_TYPES_COUNT.TOTAL;

            ELSIF REC_PERSON_TYPES_COUNT.EMP_CAT ='FT'
            THEN
                L_TEMPORARY_MEN := REC_PERSON_TYPES_COUNT.TOTAL;
            END IF;


        ELSIF REC_PERSON_TYPES_COUNT.SEX ='F'
        THEN
            IF REC_PERSON_TYPES_COUNT.EMP_CAT ='FR'
            THEN
                L_REGULAR_WOMEN := REC_PERSON_TYPES_COUNT.TOTAL;
            ELSIF REC_PERSON_TYPES_COUNT.EMP_CAT ='FT'
            THEN
                L_TEMPORARY_WOMEN := REC_PERSON_TYPES_COUNT.TOTAL;
            END IF;

        END IF;

    END LOOP;

   /* getting start of the month and end of the month */
   L_MONTH_START_DATE:= trunc(g_account_date,'MM');
   L_MONTH_END_DATE:=last_day(trunc(g_account_date,'MM'));


    /* getting the person_ids who have assignments within the period under the local unit*/
/*    OPEN csr_person_local_unit(g_local_unit_id);
	FETCH csr_person_local_unit INTO l_person_id,l_sex
    CLOSE csr_person_local_unit; */

	FOR csr_person IN csr_person_local_unit(g_local_unit_id) LOOP
		l_person_id:=csr_person.person_id;
		l_sex:=csr_person.sex;
		/* Getting the count of the Sickness Absence */

		OPEN csr_person_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE, 'S');
			FETCH csr_person_absence INTO l_absence_count;
		CLOSE csr_person_absence;
		IF l_sex='M' THEN
			L_SICK_LEAVE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_SICK_LEAVE_WOMEN:=nvl(l_absence_count,0);
		END IF;

		/* Getting the count of the Vacation Absence */

		OPEN csr_person_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE, 'V');
			FETCH csr_person_absence INTO l_absence_count;
		CLOSE csr_person_absence;
		IF l_sex='M' THEN
			L_HOLIDAY_LEAVE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_HOLIDAY_LEAVE_WOMEN:=nvl(l_absence_count,0);
		END IF;

		/* Getting the count of the Other Absence */

		OPEN csr_person_other_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE);
			FETCH csr_person_other_absence INTO l_absence_count;
		CLOSE csr_person_other_absence;
		IF l_sex='M' THEN
			L_OTHER_ABSENCE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_OTHER_ABSENCE_WOMEN:=nvl(l_absence_count,0);
		END IF;

	END LOOP;
   /* need to check the absences which falls on the date of accounting */
   /* Get the start date and  the assignments that fall within the accounting month period */
	FOR csr_assignment IN csr_new_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_start_date:=csr_assignment.effective_start_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* Check for the previous assignment*/
		OPEN  csr_prev_assignments(l_assignment_id, l_assignment_start_date);
			FETCH csr_prev_assignments INTO l_local_unit_id;
		CLOSE csr_prev_assignments;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_REGULAR_MEN:=L_NEW_HIRES_REGULAR_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_REGULAR_MEN:=L_NEW_HIRES_REGULAR_MEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_TEMPORARY_MEN:=L_NEW_HIRES_TEMPORARY_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_TEMPORARY_MEN:=L_NEW_HIRES_TEMPORARY_MEN+1;
					END IF;
				END if;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_REGULAR_WOMEN:=L_NEW_HIRES_REGULAR_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_REGULAR_WOMEN:=L_NEW_HIRES_REGULAR_WOMEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_TEMPORARY_WOMEN:=L_NEW_HIRES_TEMPORARY_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_TEMPORARY_WOMEN:=L_NEW_HIRES_TEMPORARY_WOMEN+1;
					END IF;
				END IF;
			END IF;
		END IF;
		l_local_unit_id:=NULL;
	END LOOP;
	   /*cursor to get the end date, assignment id for getting the assignment ended employees */
	FOR csr_assignment IN csr_end_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE ) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_end_date:=csr_assignment.effective_end_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* Check for the previous assignment*/
		OPEN  csr_next_assignments(l_assignment_id, l_assignment_end_date);
			FETCH csr_next_assignments INTO l_local_unit_id;
		CLOSE csr_next_assignments;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
					END IF;
				END if;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
					END IF;
				END IF;
			END IF;
		END IF;
		l_local_unit_id:=NULL;
	END LOOP;

	/*cursor to get the Terminated, assignment  */
	FOR csr_assignment IN csr_ter_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE ) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
					L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
			ELSIF l_assignment_category='FT' THEN

					L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
					L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
			ELSIF l_assignment_category='FT' THEN
					L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
			END IF;
		END IF;

	END LOOP;

   /*cursor to get the start date, assignment id for getting the new hires */



         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
           , p_action_context_id                => p_payroll_action_id
           , p_action_context_type              => 'PA'
           , p_object_version_number            => l_ovn
           , p_effective_date                   => g_effective_date
           , p_source_id                        => NULL
           , p_source_text                      => NULL
           , p_action_information_category      => 'EMEA REPORT INFORMATION'
           , p_action_information1              => 'PYSESTEA'
           , p_action_information2              => 'LU'
           , p_action_information3              => L_LEGAL_EMPLOYER_NAME
           , p_action_information4              => lr_CFAR_FROM_LU.LU_NAME
           , p_action_information5              => L_CFAR_NUMBER
           , p_action_information6              => L_FISCAL_YEAR
           , p_action_information7              => L_FISCAL_QUARTER
           , p_action_information8              => L_FISCAL_MONTH
           , p_action_information9              => L_REGULAR_MEN
           , p_action_information10             => L_REGULAR_WOMEN
           , p_action_information11             => L_TEMPORARY_MEN
           , p_action_information12             => L_TEMPORARY_WOMEN
           , p_action_information13             => L_SICK_LEAVE_MEN
           , p_action_information14             => L_SICK_LEAVE_WOMEN
           , p_action_information15             => L_HOLIDAY_LEAVE_MEN
           , p_action_information16             => L_HOLIDAY_LEAVE_WOMEN
           , p_action_information17             => L_OTHER_ABSENCE_MEN
           , p_action_information18             => L_OTHER_ABSENCE_WOMEN
           , p_action_information19             => L_NEW_HIRES_REGULAR_MEN
           , p_action_information20             => L_NEW_HIRES_REGULAR_WOMEN
           , p_action_information21             => L_NEW_HIRES_TEMPORARY_MEN
           , p_action_information22             => L_NEW_HIRES_TEMPORARY_WOMEN
           , p_action_information23             => L_TERMINATION_REGULAR_MEN
           , p_action_information24             => L_TERMINATION_REGULAR_WOMEN
           , p_action_information25             => L_TERMINATION_TEMPORARY_MEN
           , p_action_information26             => L_TERMINATION_TEMPORARY_WOMEN
                       );


      ELSE
          /* THis is for ALL LOCAL UNIT */

    FOR rec_ALL_LU_FOR_LE IN csr_ALL_LU_FOR_LE (g_LEGAL_EMPLOYER_id)
    LOOP
       L_CFAR_NUMBER :=rec_ALL_LU_FOR_LE.CFAR;
       g_local_unit_id:=rec_ALL_LU_FOR_LE.local_unit_id;
         FOR REC_PERSON_TYPES_COUNT IN CSR_PERSON_TYPES_COUNT (rec_ALL_LU_FOR_LE.local_unit_id)
         LOOP
            IF REC_PERSON_TYPES_COUNT.SEX ='M'
            THEN
                IF REC_PERSON_TYPES_COUNT.EMP_CAT ='FR'
                THEN
                    L_REGULAR_MEN := REC_PERSON_TYPES_COUNT.TOTAL;

                ELSIF REC_PERSON_TYPES_COUNT.EMP_CAT ='FT'
                THEN
                    L_TEMPORARY_MEN := REC_PERSON_TYPES_COUNT.TOTAL;
                END IF;
            ELSIF REC_PERSON_TYPES_COUNT.SEX ='F'
            THEN
                IF REC_PERSON_TYPES_COUNT.EMP_CAT ='FR'
                THEN
                    L_REGULAR_WOMEN := REC_PERSON_TYPES_COUNT.TOTAL;
                ELSIF REC_PERSON_TYPES_COUNT.EMP_CAT ='FT'
                THEN
                    L_TEMPORARY_WOMEN := REC_PERSON_TYPES_COUNT.TOTAL;
                END IF;
            END IF;
        END LOOP;

    /* getting start of the month and end of the month */
   L_MONTH_START_DATE:= trunc(g_account_date,'MM');
   L_MONTH_END_DATE:=last_day(trunc(g_account_date,'MM'));


    /* getting the person_ids who have assignments within the period under the local unit*/
/*    OPEN csr_person_local_unit(g_local_unit_id);
	FETCH csr_person_local_unit INTO l_person_id,l_sex
    CLOSE csr_person_local_unit; */

	FOR csr_person IN csr_person_local_unit(g_local_unit_id) LOOP
		l_person_id:=csr_person.person_id;
		l_sex:=csr_person.sex;
		/* Getting the count of the Sickness Absence */

		OPEN csr_person_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE, 'S');
			FETCH csr_person_absence INTO l_absence_count;
		CLOSE csr_person_absence;
		IF l_sex='M' THEN
			L_SICK_LEAVE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_SICK_LEAVE_WOMEN:=nvl(l_absence_count,0);
		END IF;

		/* Getting the count of the Vacation Absence */

		OPEN csr_person_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE, 'V');
			FETCH csr_person_absence INTO l_absence_count;
		CLOSE csr_person_absence;
		IF l_sex='M' THEN
			L_HOLIDAY_LEAVE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_HOLIDAY_LEAVE_WOMEN:=nvl(l_absence_count,0);
		END IF;

		/* Getting the count of the Other Absence */

		OPEN csr_person_other_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE);
			FETCH csr_person_other_absence INTO l_absence_count;
		CLOSE csr_person_other_absence;
		IF l_sex='M' THEN
			L_OTHER_ABSENCE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_OTHER_ABSENCE_WOMEN:=nvl(l_absence_count,0);
		END IF;

	END LOOP;
   /* need to check the absences which falls on the date of accounting */
   /* Get the start date and  the assignments that fall within the accounting month period */
	FOR csr_assignment IN csr_new_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_start_date:=csr_assignment.effective_start_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* Check for the previous assignment*/
		OPEN  csr_prev_assignments(l_assignment_id, l_assignment_start_date);
			FETCH csr_prev_assignments INTO l_local_unit_id;
		CLOSE csr_prev_assignments;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_REGULAR_MEN:=L_NEW_HIRES_REGULAR_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_REGULAR_MEN:=L_NEW_HIRES_REGULAR_MEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_TEMPORARY_MEN:=L_NEW_HIRES_TEMPORARY_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_TEMPORARY_MEN:=L_NEW_HIRES_TEMPORARY_MEN+1;
					END IF;
				END if;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_REGULAR_WOMEN:=L_NEW_HIRES_REGULAR_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_REGULAR_WOMEN:=L_NEW_HIRES_REGULAR_WOMEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_TEMPORARY_WOMEN:=L_NEW_HIRES_TEMPORARY_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_TEMPORARY_WOMEN:=L_NEW_HIRES_TEMPORARY_WOMEN+1;
					END IF;
				END IF;
			END IF;
		END IF;
		l_local_unit_id:=NULL;
	END LOOP;
	   /*cursor to get the end date, assignment id for getting the assignment ended employees */
	FOR csr_assignment IN csr_end_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE ) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_end_date:=csr_assignment.effective_end_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* Check for the previous assignment*/
		OPEN  csr_next_assignments(l_assignment_id, l_assignment_end_date);
			FETCH csr_next_assignments INTO l_local_unit_id;
		CLOSE csr_next_assignments;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
					END IF;
				END if;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
					END IF;
				END IF;
			END IF;
		END IF;
		l_local_unit_id:=NULL;
	END LOOP;
		/*cursor to get the Terminated, assignment  */
	FOR csr_assignment IN csr_ter_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE ) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
	--	l_assignment_end_date:=csr_assignment.effective_end_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
					L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
			ELSIF l_assignment_category='FT' THEN

					L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
					L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
			ELSIF l_assignment_category='FT' THEN
					L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
			END IF;
		END IF;

	END LOOP;

         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
           , p_action_context_id                => p_payroll_action_id
           , p_action_context_type              => 'PA'
           , p_object_version_number            => l_ovn
           , p_effective_date                   => g_effective_date
           , p_source_id                        => NULL
           , p_source_text                      => NULL
           , p_action_information_category      => 'EMEA REPORT INFORMATION'
           , p_action_information1              => 'PYSESTEA'
           , p_action_information2              => 'LU'
           , p_action_information3              => L_LEGAL_EMPLOYER_NAME
           , p_action_information4              => rec_ALL_LU_FOR_LE.local_unit_name
           , p_action_information5              => L_CFAR_NUMBER
           , p_action_information6              => L_FISCAL_YEAR
           , p_action_information7              => L_FISCAL_QUARTER
           , p_action_information8              => L_FISCAL_MONTH
           , p_action_information9              => L_REGULAR_MEN
           , p_action_information10             => L_REGULAR_WOMEN
           , p_action_information11             => L_TEMPORARY_MEN
           , p_action_information12             => L_TEMPORARY_WOMEN
           , p_action_information13             => L_SICK_LEAVE_MEN
           , p_action_information14             => L_SICK_LEAVE_WOMEN
           , p_action_information15             => L_HOLIDAY_LEAVE_MEN
           , p_action_information16             => L_HOLIDAY_LEAVE_WOMEN
           , p_action_information17             => L_OTHER_ABSENCE_MEN
           , p_action_information18             => L_OTHER_ABSENCE_WOMEN
           , p_action_information19             => L_NEW_HIRES_REGULAR_MEN
           , p_action_information20             => L_NEW_HIRES_REGULAR_WOMEN
           , p_action_information21             => L_NEW_HIRES_TEMPORARY_MEN
           , p_action_information22             => L_NEW_HIRES_TEMPORARY_WOMEN
           , p_action_information23             => L_TERMINATION_REGULAR_MEN
           , p_action_information24             => L_TERMINATION_REGULAR_WOMEN
           , p_action_information25             => L_TERMINATION_TEMPORARY_MEN
           , p_action_information26             => L_TERMINATION_TEMPORARY_WOMEN
                       );
L_REGULAR_MEN:=0;
L_REGULAR_WOMEN:=0;
L_TEMPORARY_MEN:=0;
L_TEMPORARY_WOMEN:=0;
L_SICK_LEAVE_MEN:=0;
L_SICK_LEAVE_WOMEN:=0;
L_HOLIDAY_LEAVE_MEN:=0;
L_HOLIDAY_LEAVE_WOMEN:=0;
L_OTHER_ABSENCE_MEN:=0;
L_OTHER_ABSENCE_WOMEN:=0;
L_NEW_HIRES_REGULAR_MEN:=0;
L_NEW_HIRES_REGULAR_WOMEN:=0;
L_NEW_HIRES_TEMPORARY_MEN:=0;
L_NEW_HIRES_TEMPORARY_WOMEN:=0;
L_TERMINATION_REGULAR_MEN:=0;
L_TERMINATION_REGULAR_WOMEN:=0;
L_TERMINATION_TEMPORARY_MEN:=0;
L_TERMINATION_TEMPORARY_WOMEN:=0;
g_local_unit_id:=NULL;
    END LOOP;


      END IF;


  ELSE
  /* THis is for ALL LEGAL EMOPLYER */



    FOR REC_ALL_LE_FOR_BG IN csr_ALL_LE_FOR_BG ()
    LOOP
        L_LEGAL_EMPLOYER_NAME :=REC_ALL_LE_FOR_BG.LEGAL_EMPLOYER_NAME;

        FOR rec_ALL_LU_FOR_LE IN csr_ALL_LU_FOR_LE (REC_ALL_LE_FOR_BG.ORGANIZATION_ID)
        LOOP
       L_CFAR_NUMBER :=rec_ALL_LU_FOR_LE.CFAR;
       g_local_unit_id:=rec_ALL_LU_FOR_LE.local_unit_id;
         FOR REC_PERSON_TYPES_COUNT IN CSR_PERSON_TYPES_COUNT (rec_ALL_LU_FOR_LE.local_unit_id)
         LOOP
            IF REC_PERSON_TYPES_COUNT.SEX ='M'
            THEN
                IF REC_PERSON_TYPES_COUNT.EMP_CAT ='FR'
                THEN
                    L_REGULAR_MEN := REC_PERSON_TYPES_COUNT.TOTAL;

                ELSIF REC_PERSON_TYPES_COUNT.EMP_CAT ='FT'
                THEN
                    L_TEMPORARY_MEN := REC_PERSON_TYPES_COUNT.TOTAL;
                END IF;
            ELSIF REC_PERSON_TYPES_COUNT.SEX ='F'
            THEN
                IF REC_PERSON_TYPES_COUNT.EMP_CAT ='FR'
                THEN
                    L_REGULAR_WOMEN := REC_PERSON_TYPES_COUNT.TOTAL;
                ELSIF REC_PERSON_TYPES_COUNT.EMP_CAT ='FT'
                THEN
                    L_TEMPORARY_WOMEN := REC_PERSON_TYPES_COUNT.TOTAL;
                END IF;
            END IF;
        END LOOP;

	  /* getting start of the month and end of the month */
   L_MONTH_START_DATE:= trunc(g_account_date,'MM');
   L_MONTH_END_DATE:=last_day(trunc(g_account_date,'MM'));


    /* getting the person_ids who have assignments within the period under the local unit*/
/*    OPEN csr_person_local_unit(g_local_unit_id);
	FETCH csr_person_local_unit INTO l_person_id,l_sex
    CLOSE csr_person_local_unit; */

	FOR csr_person IN csr_person_local_unit(g_local_unit_id) LOOP
		l_person_id:=csr_person.person_id;
		l_sex:=csr_person.sex;
		/* Getting the count of the Sickness Absence */

		OPEN csr_person_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE, 'S');
			FETCH csr_person_absence INTO l_absence_count;
		CLOSE csr_person_absence;
		IF l_sex='M' THEN
			L_SICK_LEAVE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_SICK_LEAVE_WOMEN:=nvl(l_absence_count,0);
		END IF;

		/* Getting the count of the Vacation Absence */

		OPEN csr_person_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE, 'V');
			FETCH csr_person_absence INTO l_absence_count;
		CLOSE csr_person_absence;
		IF l_sex='M' THEN
			L_HOLIDAY_LEAVE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_HOLIDAY_LEAVE_WOMEN:=nvl(l_absence_count,0);
		END IF;

		/* Getting the count of the Other Absence */

		OPEN csr_person_other_absence(l_person_id, L_MONTH_START_DATE, L_MONTH_END_DATE);
			FETCH csr_person_other_absence INTO l_absence_count;
		CLOSE csr_person_other_absence;
		IF l_sex='M' THEN
			L_OTHER_ABSENCE_MEN:=nvl(l_absence_count,0);
		ELSIF l_sex='F' THEN
			L_OTHER_ABSENCE_WOMEN:=nvl(l_absence_count,0);
		END IF;

	END LOOP;
   /* need to check the absences which falls on the date of accounting */
   /* Get the start date and  the assignments that fall within the accounting month period */
	FOR csr_assignment IN csr_new_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_start_date:=csr_assignment.effective_start_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* Check for the previous assignment*/
		OPEN  csr_prev_assignments(l_assignment_id, l_assignment_start_date);
			FETCH csr_prev_assignments INTO l_local_unit_id;
		CLOSE csr_prev_assignments;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_REGULAR_MEN:=L_NEW_HIRES_REGULAR_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_REGULAR_MEN:=L_NEW_HIRES_REGULAR_MEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_TEMPORARY_MEN:=L_NEW_HIRES_TEMPORARY_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_TEMPORARY_MEN:=L_NEW_HIRES_TEMPORARY_MEN+1;
					END IF;
				END if;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_REGULAR_WOMEN:=L_NEW_HIRES_REGULAR_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_REGULAR_WOMEN:=L_NEW_HIRES_REGULAR_WOMEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_NEW_HIRES_TEMPORARY_WOMEN:=L_NEW_HIRES_TEMPORARY_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_NEW_HIRES_TEMPORARY_WOMEN:=L_NEW_HIRES_TEMPORARY_WOMEN+1;
					END IF;
				END IF;
			END IF;
		END IF;
		l_local_unit_id:=NULL;
	END LOOP;
	   /*cursor to get the end date, assignment id for getting the assignment ended employees */
	FOR csr_assignment IN csr_end_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE ) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
		l_assignment_end_date:=csr_assignment.effective_end_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* Check for the previous assignment*/
		OPEN  csr_next_assignments(l_assignment_id, l_assignment_end_date);
			FETCH csr_next_assignments INTO l_local_unit_id;
		CLOSE csr_next_assignments;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
					END IF;
				END if;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
					END IF;
				END if;
			ELSIF l_assignment_category='FT' THEN
				IF l_local_unit_id IS NULL THEN
					L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
				ELSE
					IF l_local_unit_id<>g_local_unit_id THEN
						L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
					END IF;
				END IF;
			END IF;
		END IF;
		l_local_unit_id:=NULL;
	END LOOP;

		/*cursor to get the Terminated, assignment  */
	FOR csr_assignment IN csr_ter_assignments(L_MONTH_START_DATE, L_MONTH_END_DATE ) LOOP
		l_assignment_id:=csr_assignment.assignment_id;
	--	l_assignment_end_date:=csr_assignment.effective_end_date;
		l_assignment_category:=csr_assignment.employment_category;
		/*Get the sex of the person */
		OPEN csr_person_sex(l_assignment_id);
			FETCH csr_person_sex INTO l_sex;
		CLOSE csr_person_sex;
		/* check for the sex */
		IF l_sex='M' THEN
			/* check for the category */
			IF l_assignment_category='FR' THEN
					L_TERMINATION_REGULAR_MEN:=L_TERMINATION_REGULAR_MEN+1;
			ELSIF l_assignment_category='FT' THEN

					L_TERMINATION_TEMPORARY_MEN:=L_TERMINATION_TEMPORARY_MEN+1;
			END if;
		ELSIF l_sex='F' THEN
			/* If there is no previous record, then only one record, so increase the count by 1 */
			/* check for the category */
			IF l_assignment_category='FR' THEN
					L_TERMINATION_REGULAR_WOMEN:=L_TERMINATION_REGULAR_WOMEN+1;
			ELSIF l_assignment_category='FT' THEN
					L_TERMINATION_TEMPORARY_WOMEN:=L_TERMINATION_TEMPORARY_WOMEN+1;
			END IF;
		END IF;

	END LOOP;

         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
           , p_action_context_id                => p_payroll_action_id
           , p_action_context_type              => 'PA'
           , p_object_version_number            => l_ovn
           , p_effective_date                   => g_effective_date
           , p_source_id                        => NULL
           , p_source_text                      => NULL
           , p_action_information_category      => 'EMEA REPORT INFORMATION'
           , p_action_information1              => 'PYSESTEA'
           , p_action_information2              => 'LU'
           , p_action_information3              => L_LEGAL_EMPLOYER_NAME
           , p_action_information4              => rec_ALL_LU_FOR_LE.local_unit_name
           , p_action_information5              => L_CFAR_NUMBER
           , p_action_information6              => L_FISCAL_YEAR
           , p_action_information7              => L_FISCAL_QUARTER
           , p_action_information8              => L_FISCAL_MONTH
           , p_action_information9              => L_REGULAR_MEN
           , p_action_information10             => L_REGULAR_WOMEN
           , p_action_information11             => L_TEMPORARY_MEN
           , p_action_information12             => L_TEMPORARY_WOMEN
           , p_action_information13             => L_SICK_LEAVE_MEN
           , p_action_information14             => L_SICK_LEAVE_WOMEN
           , p_action_information15             => L_HOLIDAY_LEAVE_MEN
           , p_action_information16             => L_HOLIDAY_LEAVE_WOMEN
           , p_action_information17             => L_OTHER_ABSENCE_MEN
           , p_action_information18             => L_OTHER_ABSENCE_WOMEN
           , p_action_information19             => L_NEW_HIRES_REGULAR_MEN
           , p_action_information20             => L_NEW_HIRES_REGULAR_WOMEN
           , p_action_information21             => L_NEW_HIRES_TEMPORARY_MEN
           , p_action_information22             => L_NEW_HIRES_TEMPORARY_WOMEN
           , p_action_information23             => L_TERMINATION_REGULAR_MEN
           , p_action_information24             => L_TERMINATION_REGULAR_WOMEN
           , p_action_information25             => L_TERMINATION_TEMPORARY_MEN
           , p_action_information26             => L_TERMINATION_TEMPORARY_WOMEN
                       );
L_REGULAR_MEN:=0;
L_REGULAR_WOMEN:=0;
L_TEMPORARY_MEN:=0;
L_TEMPORARY_WOMEN:=0;
L_SICK_LEAVE_MEN:=0;
L_SICK_LEAVE_WOMEN:=0;
L_HOLIDAY_LEAVE_MEN:=0;
L_HOLIDAY_LEAVE_WOMEN:=0;
L_OTHER_ABSENCE_MEN:=0;
L_OTHER_ABSENCE_WOMEN:=0;
L_NEW_HIRES_REGULAR_MEN:=0;
L_NEW_HIRES_REGULAR_WOMEN:=0;
L_NEW_HIRES_TEMPORARY_MEN:=0;
L_NEW_HIRES_TEMPORARY_WOMEN:=0;
L_TERMINATION_REGULAR_MEN:=0;
L_TERMINATION_REGULAR_WOMEN:=0;
L_TERMINATION_TEMPORARY_MEN:=0;
L_TERMINATION_TEMPORARY_WOMEN:=0;

    END LOOP;
    g_local_unit_id:=NULL;
    END LOOP;


  END IF;
/*
-- *****************************************************************************
 -- TO pick up the Name of the LE
      OPEN csr_legal_employer_details (g_legal_employer_id);

      FETCH csr_legal_employer_details
       INTO l_legal_employer_details;

      CLOSE csr_legal_employer_details;

-- *****************************************************************************
      fnd_file.put_line (fnd_file.LOG
                       ,    'After CURSOR Legal Emp DETAILS         ==> '
                         || g_legal_employer_id
                        );
-- *****************************************************************************
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
        , p_action_information1              => 'PYSEHPDA'
        , p_action_information2              => l_legal_employer_details.legal_employer_name
        , p_action_information3              => g_legal_employer_id
        , p_action_information4              => g_LE_request
        , p_action_information5              => fnd_date.date_to_canonical
                                                                 (g_posting_date)
        , p_action_information6              => fnd_date.date_to_canonical
                                                                   (g_account_date)
        , p_action_information7              => NULL
        , p_action_information8              => NULL
        , p_action_information9              => NULL
        , p_action_information10             => NULL
         );
-- *****************************************************************************
      fnd_file.put_line (fnd_file.LOG
                       , ' ================ ALL ================ '
                        );
      --fnd_file.put_line(fnd_file.log,'PENSION provider name ==> '||lr_pension_provider_details.NAME );
      --fnd_file.put_line(fnd_file.log,'PENSION provider ID   ==> '||g_pension_provider_id);
      fnd_file.put_line (fnd_file.LOG
                       ,    'Legal Emp Name        ==> '
                         || l_legal_employer_details.legal_employer_name
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'Legal Emp ID          ==> ' || g_legal_employer_id
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'g_request_for      ==> ' || g_LE_request
                        );
      --fnd_file.put_line(fnd_file.log,'Local Unit ID         ==> '||g_local_unit_id);
      --fnd_file.put_line(fnd_file.log,'acti_info_id          ==> '||l_action_info_id );
      fnd_file.put_line (fnd_file.LOG, ' ================================ ');

-- *****************************************************************************
      IF g_LE_request = 'REQUESTING_ORG'
      THEN
         -- Information regarding the Legal Employer
         OPEN csr_legal_employer_details (g_legal_employer_id);

         FETCH csr_legal_employer_details
          INTO l_legal_employer_details;

         CLOSE csr_legal_employer_details;

         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
           , p_action_context_id                => p_payroll_action_id
           , p_action_context_type              => 'PA'
           , p_object_version_number            => l_ovn
           , p_effective_date                   => g_effective_date
           , p_source_id                        => NULL
           , p_source_text                      => NULL
           , p_action_information_category      => 'EMEA REPORT INFORMATION'
           , p_action_information1              => 'PYSEHPDA'
           , p_action_information2              => 'LE'
           , p_action_information3              => g_legal_employer_id
           , p_action_information4              => l_legal_employer_details.legal_employer_name
           , p_action_information5              => l_legal_employer_details.org_number
           , p_action_information6              => NULL
           , p_action_information7              => NULL
           , p_action_information8              => NULL
           , p_action_information9              => NULL
           , p_action_information10             => NULL
            );
-- *****************************************************************************
      ELSE
-- *****************************************************************************
         FOR rec_legal_employer_details IN csr_legal_employer_details (NULL)
         LOOP
            OPEN csr_check_empty_le (rec_legal_employer_details.legal_id
                                   , g_start_date
                                   , g_end_date
                                    );

            FETCH csr_check_empty_le
             INTO l_le_has_employee;

            CLOSE csr_check_empty_le;

            IF l_le_has_employee = '1'
            THEN
               pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                 , p_action_context_id                => p_payroll_action_id
                 , p_action_context_type              => 'PA'
                 , p_object_version_number            => l_ovn
                 , p_effective_date                   => g_effective_date
                 , p_source_id                        => NULL
                 , p_source_text                      => NULL
                 , p_action_information_category      => 'EMEA REPORT INFORMATION'
                 , p_action_information1              => 'PYSEHPDA'
                 , p_action_information2              => 'LE'
                 , p_action_information3              => rec_legal_employer_details.legal_id
                 , p_action_information4              => rec_legal_employer_details.legal_employer_name
                 , p_action_information5              => rec_legal_employer_details.org_number
                 , p_action_information6              => NULL
                 , p_action_information7              => NULL
                 , p_action_information8              => NULL
                 , p_action_information9              => NULL
                 , p_action_information10             => NULL
                  );
            END IF;
         END LOOP;
      END IF;                                          -- FOR G_LEGAL_EMPLOYER

*/
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
                  'END_LU_DETAILS'
                  )
            THEN
               IF l_str9 IN
                     ('LU_DETAILS')
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
         p_xml                   OUT NOCOPY CLOB)
IS


/* Cursor to fetch Header Information */


CURSOR csr_local_unit_details (p_payroll_action_id NUMBER)
IS
SELECT
pai1.action_information3 Legal_Employer,
pai1.action_information4 Local_Unit,
pai.ACTION_INFORMATION9 Report_Date,
--'0000000SCB',
pai1.action_information6 Fiscal_Year,
pai1.action_information7 Fiscal_Quarter,
pai1.action_information8 Fiscal_Month,
pai1.ACTION_INFORMATION5 CFAR_Number,
pai1.action_information9 Regular_Men,
pai1.action_information10 Regular_Women,
pai1.action_information11 Temporary_Men,
pai1.action_information12 Temporary_Women,
pai1.action_information13 Sick_Men,
pai1.action_information14 Sick_Women,
pai1.action_information15 Holiday_Men,
pai1.action_information16 Holiday_Women,
pai1.action_information17 Other_Men,
pai1.action_information18 Other_Women,
pai1.action_information19 New_Regular_Men,
pai1.action_information20 New_Regular_Women,
pai1.action_information21 New_Temporary_Men,
pai1.action_information22 New_Temporary_women,
pai1.action_information23 Terminate_Regular_Men,
pai1.action_information24 Terminate_Regular_Women,
pai1.action_information25 Terminate_Temporary_Men,
pai1.action_information26 Terminate_Temporary_Women
FROM
pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1
WHERE
pai.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =p_payroll_action_id --20162 --20264 --20165
AND pai.action_context_id = pai1.action_context_id
AND pai1.action_context_id= ppa.payroll_action_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSESTEA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSESTEA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
order BY pai1.ACTION_INFORMATION3,pai1.ACTION_INFORMATION2;

/*CURSOR csr_legal_employer_details (p_payroll_action_id NUMBER, p_legal_employer varchar2 )
IS
SELECT SUM(pai1.action_information9) Regular_Men,
sum(pai1.action_information10) Regular_Women,
sum(pai1.action_information11) Temporary_Men,
sum(pai1.action_information12) Temporary_Women
FROM
pay_payroll_actions ppa,
pay_action_information pai1
WHERE
pai1.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =p_payroll_action_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'LU'
AND pai1.action_information1 = 'PYSESTEA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.action_information3=p_legal_employer;*/

CURSOR csr_legal_employer /*(p_payroll_action_id NUMBER, */(p_legal_employer varchar2 )
IS
SELECT
count(paa.assignment_id) TOTAL
,paa.employment_category EMP_CAT
,pap.SEX
FROM
hr_all_organization_units hou_le,
hr_organization_information hoi_le,
hr_all_organization_units hou_lu,
hr_organization_information hoi_lu,
PER_ALL_ASSIGNMENTS_F paa
,HR_SOFT_CODING_KEYFLEX scl1
,PER_ALL_PEOPLE_F pap
WHERE
hoi_le.organization_id = hou_le.organization_id
AND hou_le.name =p_legal_employer
AND hoi_le.org_information_context = 'SE_LOCAL_UNITS'
AND hou_lu.organization_id = hoi_le.org_information1
AND hou_lu.organization_id = hoi_lu.organization_id
AND hoi_lu.org_information_context = 'SE_LOCAL_UNIT_DETAILS'
AND paa.person_id = pap.person_id
and paa.business_group_id = g_business_group_id
and scl1.segment2 = TO_CHAR(hoi_le.org_information1)
AND	scl1.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
and paa.employment_category in ('FR','FT')
and paa.ASSIGNMENT_STATUS_TYPE_ID = 1
and pap.SEX in('F','M')
and g_account_date between paa.EFFECTIVE_START_DATE and paa.EFFECTIVE_END_DATE
and g_account_date between pap.EFFECTIVE_START_DATE and pap.EFFECTIVE_END_DATE
group by paa.employment_category,pap.SEX
order by paa.employment_category,pap.SEX;


l_local_unit_details_rec csr_local_unit_details%rowtype;



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

BEGIN

l_counter:=0;

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
                                                , g_LE_request
                                                , g_LU_request
                                                , g_local_unit_id
                                                , g_account_date
                                                , g_posting_date
                                                , g_reporting_date
                                                 );

        hr_utility.set_location('Entered Procedure GETDATA',10);

	/*	xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='LU_DETAILS';*/
/*		l_counter:=l_counter+1;*/

        /* Get the File Header Information */
         hr_utility.set_location('Before populating pl/sql table',20);
	FOR csr_local IN csr_local_unit_details(p_payroll_action_id) loop

       	xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='LU_DETAILS';
   		l_counter:=l_counter+1;


        hr_utility.set_location('Entered Procedure GETDATA',10);

        xml_tab(l_counter).TagName  :='LEGAL_EMPLOYER';
		xml_tab(l_counter).TagValue := csr_local.Legal_Employer;
		l_counter:=l_counter+1;

		l_legal_employer:=csr_local.Legal_Employer;


		xml_tab(l_counter).TagName  :='LOCAL_UNIT';
		xml_tab(l_counter).TagValue := csr_local.Local_Unit;
		l_counter:=l_counter+1;

		/*xml_tab(l_counter).TagName  :='LOCAL_UNIT';
		xml_tab(l_counter).TagValue := csr_local.Local_Unit;
		l_counter:=l_counter+1;*/

		xml_tab(l_counter).TagName  :='REP_DATE';
		xml_tab(l_counter).TagValue := to_char(g_posting_date,'YYYY-MM-DD');
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='ACC_DATE';
		xml_tab(l_counter).TagValue := to_char(g_account_date,'YYYY-MM-DD');
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='MONTH';
		xml_tab(l_counter).TagValue := to_char(g_account_date,'MONTH');
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='YEAR';
		xml_tab(l_counter).TagValue := to_char(g_account_date,'YYYY');
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='REPORT_DATE';
		--l_report_date:=csr_local.Report_Date;

		xml_tab(l_counter).TagValue :=to_char(g_reporting_date,'YYMMDD'); --to_char(l_local_unit_details_rec.Report_Date,'YYYYMMDD');
		l_counter:=l_counter+1;



		xml_tab(l_counter).TagName  :='SCB';
		xml_tab(l_counter).TagValue := 0;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='FISCAL_YEAR';
		xml_tab(l_counter).TagValue := csr_local.Fiscal_Year;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='FISCAL_MONTH';
		xml_tab(l_counter).TagValue := csr_local.Fiscal_Month;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='FISCAL_QUARTER';
		xml_tab(l_counter).TagValue := csr_local.Fiscal_Quarter;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='CFAR_NUMBER';
		xml_tab(l_counter).TagValue := csr_local.CFAR_Number;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ACCOUNT_NUM';
		xml_tab(l_counter).TagValue := 0;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ACTIVE_MEN';
		xml_tab(l_counter).TagValue := 0;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ACTIVE_WOMEN';
		xml_tab(l_counter).TagValue := 0;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='REG_MEN';
		xml_tab(l_counter).TagValue := csr_local.Regular_Men;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='REG_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Regular_Women;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='TEMP_MEN';
		xml_tab(l_counter).TagValue := csr_local.Temporary_Men;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='TEMP_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Temporary_Women;
		l_counter:=l_counter+1;

		l_total_lu_emp:=csr_local.Regular_Men+csr_local.Regular_Women+csr_local.Temporary_Men+csr_local.Temporary_Women;

		xml_tab(l_counter).TagName  :='TOTAL_LU_EMP';
		xml_tab(l_counter).TagValue := l_total_lu_emp;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='SICK_MEN';
		xml_tab(l_counter).TagValue := csr_local.Sick_Men;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='SICK_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Sick_Women;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='FILLER';
		xml_tab(l_counter).TagValue := 0;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='HOLI_MEN';
		xml_tab(l_counter).TagValue := csr_local.Holiday_Men;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='HOLI_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Holiday_Women;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='OTH_MEN';
		xml_tab(l_counter).TagValue := csr_local.Other_Men;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='OTH_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Other_Women;
		l_counter:=l_counter+1;

		l_total_absence:=csr_local.Sick_Men+csr_local.Sick_Women+csr_local.Holiday_Men
		                 +csr_local.Holiday_Women+csr_local.Other_Men+csr_local.Other_Women;

		xml_tab(l_counter).TagName  :='TOTAL_ABSENCE';
		xml_tab(l_counter).TagValue := l_total_absence;
		l_counter:=l_counter+1;

        l_total_sick:=csr_local.Sick_Men+csr_local.Sick_Women;

        xml_tab(l_counter).TagName  :='TOTAL_SICK';
		xml_tab(l_counter).TagValue := l_total_sick;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='NEW_REGULAR_MEN';
		xml_tab(l_counter).TagValue := csr_local.New_Regular_Men;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='NEW_REGULAR_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.New_Regular_Women;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='NEW_TEMP_MEN';
		xml_tab(l_counter).TagValue := csr_local.New_Temporary_Men;
		l_counter:=l_counter+1;


		xml_tab(l_counter).TagName  :='NEW_TEMP_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.New_Temporary_Women;
		l_counter:=l_counter+1;

        l_total_hire:=csr_local.New_Regular_Men+csr_local.New_Regular_Women+
                      csr_local.New_Temporary_Men+csr_local.New_Temporary_Women;

        xml_tab(l_counter).TagName  :='NEW_HIRE';
		xml_tab(l_counter).TagValue := l_total_hire;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='TER_REG_MEN';
		xml_tab(l_counter).TagValue := csr_local.Terminate_Regular_Men;
		l_counter:=l_counter+1;


		xml_tab(l_counter).TagName  :='TER_REG_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Terminate_Regular_Women;
		l_counter:=l_counter+1;

		xml_tab(l_counter).TagName  :='TER_TEMP_MEN';
		xml_tab(l_counter).TagValue := csr_local.Terminate_Temporary_Men;
		l_counter:=l_counter+1;


		xml_tab(l_counter).TagName  :='TER_TEMP_WOMEN';
		xml_tab(l_counter).TagValue := csr_local.Terminate_Temporary_Women;
		l_counter:=l_counter+1;

        l_total_termination:=csr_local.Terminate_Regular_Men+csr_local.Terminate_Regular_Women+
                             csr_local.Terminate_Temporary_Men+csr_local.Terminate_Temporary_Women;

        xml_tab(l_counter).TagName  :='TOTAL_TERM';
		xml_tab(l_counter).TagValue := l_total_termination;
		l_counter:=l_counter+1;

		/*OPEN csr_legal_employer_details(p_payroll_action_id,l_legal_employer);
		     FETCH csr_legal_employer_details INTO l_regular_men,l_regular_women,l_temp_men,l_temp_women;
		CLOSE csr_legal_employer_details;*/

		FOR csr_legal IN csr_legal_employer(l_legal_employer) --(g_local_unit_id)
		    LOOP
			IF csr_legal.SEX ='M'
			THEN
			    IF csr_legal.EMP_CAT ='FR'
			    THEN
				l_regular_men := csr_legal.TOTAL;

			    ELSIF csr_legal.EMP_CAT ='FT'
			    THEN
				l_temp_men := csr_legal.TOTAL;
			    END IF;


			ELSIF csr_legal.SEX ='F'
			THEN
			    IF csr_legal.EMP_CAT ='FR'
			    THEN
				l_regular_women := csr_legal.TOTAL;
			    ELSIF csr_legal.EMP_CAT ='FT'
			    THEN
				l_temp_women := csr_legal.TOTAL;
			    END IF;

			END IF;

		    END LOOP;

		l_regular_men:=NVL(l_regular_men,0);
		l_regular_women:=NVL(l_regular_women,0);
		l_temp_men:=NVL(l_temp_men,0);
		l_temp_women:=NVL(l_temp_women,0);

        xml_tab(l_counter).TagName  :='LE_REG_MEN';
		xml_tab(l_counter).TagValue := l_regular_men;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='LE_REG_WOMEN';
		xml_tab(l_counter).TagValue := l_regular_women;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='LE_TEMP_MEN';
		xml_tab(l_counter).TagValue := l_temp_men;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='LE_TEMP_WOMEN';
		xml_tab(l_counter).TagValue := l_temp_women;
		l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='TOTAL_LE_EMP';
		xml_tab(l_counter).TagValue := l_regular_men+l_regular_women+l_temp_men+l_temp_women;
		l_counter:=l_counter+1;

		hr_utility.set_location('After populating pl/sql table',30);
		hr_utility.set_location('Entered Procedure GETDATA',10);

        xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='END_LU_DETAILS';
		l_counter := l_counter + 1;
	END LOOP;
	    /*xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='END_LU_DETAILS';*/
		/*l_counter := l_counter + 1;*/

        WritetoCLOB (p_xml );



END POPULATE_DATA_DETAIL;

  END PAY_SE_EMPLOYMENT_STATISTICS;


/
