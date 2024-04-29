--------------------------------------------------------
--  DDL for Package Body PAY_SE_SALARY_STRUCTURE_STATS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_SALARY_STRUCTURE_STATS" AS
/* $Header: pysessst.pkb 120.1.12010000.2 2009/04/14 07:08:20 rrajaman ship $ */
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


   g_posting_date              DATE;
   g_account_date                DATE;
   g_reporting_date              DATE;
   g_report_year                 NUMBER;
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
    , p_LE_request   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_month               OUT NOCOPY      NUMBER         -- User parameter
    , p_report_year               OUT NOCOPY      NUMBER         -- User parameter
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
                                                     , 'LE_REQUEST'
                                                      )
                ) LE_REQUEST
		 ,(get_parameter
                                                      (legislative_parameters
                                                     , 'MONTH'
                                                      )
		) L_MONTH
                ,(get_parameter
                                                      (legislative_parameters
                                                     , 'REPORT_YEAR'
                                                      )
                ) L_REPORT_YEAR
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


      p_LE_request := lr_parameter_info.LE_REQUEST;




      p_month:=lr_parameter_info.l_month;
      p_report_year:=lr_parameter_info.l_report_year;
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

   /* Local Unit Details */
	CURSOR csr_local_unit_details (csr_v_local_unit_id   hr_organization_information.organization_id%TYPE)
	IS
        SELECT --o1.NAME local_unit_name,
        hoi2.org_information2 cfar_number
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

/*Salary Structure EIT Details */
	CURSOR csr_salary_structure_details(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_legal_employer_id hr_organization_units.organization_id%TYPE)
	IS
	SELECT hoi2.org_information1 Worksite_Number,
	hoi2.org_information2 Association_Number,
	hl.meaning Agreement_Code,
	hoi2.org_information4 Weekend_duty_pay
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	,hr_lookups hl
	WHERE  o1.business_group_id =csr_v_business_group_id --3133 --l_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_SALARY_STRUCTURE'
	AND hl.lookup_type(+) ='SE_AGREEMENT_CODE'
	AND hl.LOOKUP_CODE(+)=hoi2.org_information3 ;

/* Legal Employers under the Business Group */
	CURSOR csr_legal_employer(csr_v_business_group_id hr_organization_units.business_group_id%TYPE)
	IS
	SELECT o1.organization_id legal_employer_id
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	WHERE  o1.business_group_id =csr_v_business_group_id --3133
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS';

/* Legal Employer Details */
	CURSOR csr_legal_employer_details(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_legal_employer_id hr_organization_units.organization_id%TYPE)
	IS
	SELECT o1.name legal_employer,
	hoi2.org_information2 Organization_Id,
	hoi2.org_information9 Membership_Number
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =csr_v_business_group_id --3133 --l_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS';


/*Local Units under the Legal Employer*/
	CURSOR csr_local_legal_employer(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_legal_employer_id hr_organization_units.organization_id%TYPE)
	IS
	SELECT hoi2.ORG_INFORMATION1 local_unit
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =csr_v_business_group_id --3133 --l_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS';

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

CURSOR csr_sep_month (csr_v_month NUMBER)
IS
SELECT MEANING
FROM   hr_lookups
WHERE  LOOKUP_TYPE = 'HR_SE_SEPTEMBER'
AND  ENABLED_FLAG = 'Y'
AND  LOOKUP_CODE = csr_v_month; -- 01;

l_month varchar2(50);
l_worksite_number varchar2(10);
l_association_number varchar2(10);
l_legal_agreement_code varchar2(10);
l_agreement_code varchar2(10);
l_weekend_duty varchar2(10);
l_legal_employer hr_organization_units.name%TYPE;
l_organization_id varchar2(20);
l_membership_number varchar2(10);
L_CFAR_NUMBER NUMBER;
l_local_unit_id NUMBER;
l_legal_employer_id  hr_organization_units.organization_id%TYPE;

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
      g_LE_request :=null;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      g_account_date :=null;
      g_posting_date :=null;
      get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LE_request
						, g_month
                                                , g_report_year
                                                 );




	/*OPEN csr_sep_month(g_month);
		FETCH csr_sep_month INTO l_month;
	CLOSE csr_sep_month;*/
	      -- Insert the report Parameters
	OPEN csr_legal_employer_details(g_business_group_id,g_legal_employer_id);
		FETCH csr_legal_employer_details INTO l_legal_employer,l_Organization_Id,l_Membership_Number;
	CLOSE csr_legal_employer_details;

	pay_action_information_api.create_action_information
	(p_action_information_id            => l_action_info_id
	, p_action_context_id                => p_payroll_action_id
	, p_action_context_type              => 'PA'
	, p_object_version_number            => l_ovn
	, p_effective_date                   => g_effective_date
	, p_source_id                        => NULL
	, p_source_text                      => NULL
	, p_action_information_category      => 'EMEA REPORT DETAILS'
	, p_action_information1              => 'PYSESSSA'
	, p_action_information2              => hr_general.decode_lookup('SE_REQUEST_LEVEL',g_LE_request)
	, p_action_information3              => g_legal_employer_id
	, p_action_information4              => l_legal_employer
	, p_action_information5              => l_month
	, p_action_information6              => g_report_year
	);
	-- *****************************************************************************

	IF g_LE_request ='LE_SELECTED' THEN
		/*Legal Emplooyer Details*/
		OPEN csr_legal_employer_details(g_business_group_id,g_legal_employer_id);
			FETCH csr_legal_employer_details INTO l_legal_employer,l_organization_id,
			l_membership_number;
		CLOSE csr_legal_employer_details;
		/* Salary Structure EIT Details */
		OPEN csr_salary_structure_details(g_business_group_id,g_legal_employer_id);
			FETCH csr_salary_structure_details INTO l_worksite_number,l_association_number,
			l_legal_agreement_code,l_weekend_duty;
		CLOSE csr_salary_structure_details;
	        pay_action_information_api.create_action_information
		(p_action_information_id              => l_action_info_id
		, p_action_context_id                => p_payroll_action_id
		, p_action_context_type              => 'PA'
		, p_object_version_number            => l_ovn
		, p_effective_date                   => g_effective_date
		, p_source_id                        => NULL
		, p_source_text                      => NULL
		, p_action_information_category      => 'EMEA REPORT INFORMATION'
		, p_action_information1              => 'PYSESSSA'
		, p_action_information2              => 'LE'
		, p_action_information3              => g_legal_employer_id
		, p_action_information4              => l_legal_employer
		, p_action_information5              => l_organization_id
		, p_action_information6              => l_membership_number
		, p_action_information7              => l_worksite_number
		, p_action_information8              => l_association_number
		, p_action_information9              => l_legal_agreement_code
		, p_action_information10             => l_weekend_duty
		);

		FOR csr_legal_employer IN csr_local_legal_employer(g_business_group_id,g_legal_employer_id) LOOP
			l_local_unit_id:=csr_legal_employer.local_unit;
			OPEN csr_local_unit_details (l_local_unit_id);
				FETCH csr_local_unit_details INTO l_cfar_number;
			CLOSE csr_local_unit_details;
		        pay_action_information_api.create_action_information
			(p_action_information_id              => l_action_info_id
			, p_action_context_id                => p_payroll_action_id
			, p_action_context_type              => 'PA'
			, p_object_version_number            => l_ovn
			, p_effective_date                   => g_effective_date
			, p_source_id                        => NULL
			, p_source_text                      => NULL
			, p_action_information_category      => 'EMEA REPORT INFORMATION'
			, p_action_information1              => 'PYSESSSA'
			, p_action_information2              => 'LU'
			, p_action_information3              => l_local_unit_id
			, p_action_information4              => g_legal_employer_id
			, p_action_information5              => l_cfar_number
			);
		END LOOP;
	ELSE
		FOR csr_legal IN csr_legal_employer(g_business_group_id) LOOP
			 l_legal_employer_id:=csr_legal.legal_employer_id;
			/*Legal Emplooyer Details*/
			OPEN csr_legal_employer_details(g_business_group_id,l_legal_employer_id);
				FETCH csr_legal_employer_details INTO l_legal_employer,l_organization_id,
				l_membership_number;
			CLOSE csr_legal_employer_details;
			/* Salary Structure EIT Details */
			OPEN csr_salary_structure_details(g_business_group_id,g_legal_employer_id);
				FETCH csr_salary_structure_details INTO l_worksite_number,l_association_number,
				l_legal_agreement_code,l_weekend_duty;
			CLOSE csr_salary_structure_details;
			pay_action_information_api.create_action_information
			(p_action_information_id              => l_action_info_id
			, p_action_context_id                => p_payroll_action_id
			, p_action_context_type              => 'PA'
			, p_object_version_number            => l_ovn
			, p_effective_date                   => g_effective_date
			, p_source_id                        => NULL
			, p_source_text                      => NULL
			, p_action_information_category      => 'EMEA REPORT INFORMATION'
			, p_action_information1              => 'PYSESSSA'
			, p_action_information2              => 'LE'
			, p_action_information3              => l_legal_employer_id
			, p_action_information4              => l_legal_employer
			, p_action_information5              => l_organization_id
			, p_action_information6              => l_membership_number
			, p_action_information7              => l_worksite_number
			, p_action_information8              => l_association_number
			, p_action_information9              => l_legal_agreement_code
			, p_action_information10             => l_weekend_duty
			);

			FOR csr_legal_employer IN csr_local_legal_employer(g_business_group_id,l_legal_employer_id) LOOP
				l_local_unit_id:=csr_legal_employer.local_unit;
				OPEN csr_local_unit_details (l_local_unit_id);
					FETCH csr_local_unit_details INTO l_cfar_number;
				CLOSE csr_local_unit_details;
				pay_action_information_api.create_action_information
				(p_action_information_id              => l_action_info_id
				, p_action_context_id                => p_payroll_action_id
				, p_action_context_type              => 'PA'
				, p_object_version_number            => l_ovn
				, p_effective_date                   => g_effective_date
				, p_source_id                        => NULL
				, p_source_text                      => NULL
				, p_action_information_category      => 'EMEA REPORT INFORMATION'
				, p_action_information1              => 'PYSESSSA'
				, p_action_information2              => 'LU'
				, p_action_information3              => l_local_unit_id
				, p_action_information4              => l_legal_employer_id
				, p_action_information5              => l_cfar_number
				);
			END LOOP;
		END LOOP;
	END IF;



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


/* Local Unit Details */
	CURSOR csr_local_unit_details (csr_v_local_unit_id   hr_organization_information.organization_id%TYPE)
	IS
        SELECT --o1.NAME local_unit_name,
        hoi2.org_information2 cfar_number
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

/*Salary Structure EIT Details */
	CURSOR csr_salary_structure_details(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_legal_employer_id hr_organization_units.organization_id%TYPE)
	IS
	SELECT hoi2.org_information1 Worksite_Number,
	hoi2.org_information2 Association_Number,
	hl.meaning Agreement_Code,
	hoi2.org_information4 Weekend_duty_pay
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	,hr_lookups hl
	WHERE  o1.business_group_id =csr_v_business_group_id --3133 --l_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_SALARY_STRUCTURE'
	AND hl.lookup_type(+) ='SE_AGREEMENT_CODE'
	AND hl.LOOKUP_CODE(+)=hoi2.org_information3 ;

/* Legal Employers under the Business Group */
	CURSOR csr_legal_employer(csr_v_business_group_id hr_organization_units.business_group_id%TYPE)
	IS
	SELECT o1.organization_id legal_employer_id
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	WHERE  o1.business_group_id =csr_v_business_group_id --3133
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS';

/* Legal Employer Details */
	CURSOR csr_legal_employer_details(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_legal_employer_id hr_organization_units.organization_id%TYPE)
	IS
	SELECT o1.name legal_employer,
	hoi2.org_information2 Organization_Id,
	hoi2.org_information9 Membership_Number
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =csr_v_business_group_id --3133 --l_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS';


/*Local Units under the Legal Employer*/
	CURSOR csr_local_legal_employer(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_legal_employer_id hr_organization_units.organization_id%TYPE)
	IS
	SELECT hoi2.ORG_INFORMATION1 local_unit
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =csr_v_business_group_id --3133 --l_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS';

/* Assignment level Extra information EIT Details */
	CURSOR csr_extra_assignment(csr_v_assignment_id per_all_assignments_f.assignment_id%type)
	IS
	SELECT hl.meaning
        FROM per_assignment_extra_info,
        hr_lookups hl
        WHERE assignment_id = csr_v_assignment_id --32516 --p_assignment_id
        AND information_type = 'SE_SALARY_STRUCTURE'
        AND hl.LOOKUP_TYPE='SE_WORKING_HOUR_TYPE'
        AND hl.lookup_code=aei_information1;

/* Payroll period type */
	CURSOR csr_payroll_period(csr_v_payroll_id pay_payrolls_f.payroll_id%type)
	IS
	SELECT period_type
	FROM pay_payrolls_f
	WHERE payroll_id=csr_v_payroll_id;

/*Balances under the Balance Category*/
	CURSOR csr_balances(csr_v_business_group_id hr_organization_units.business_group_id%type,
	csr_v_category_name pay_balance_categories.category_name%type)
	IS
	SELECT balance_type_id FRoM
	pay_balance_types pbt
	WHERE (legislation_code='SE'
	OR business_group_id=csr_v_business_group_id)
	--AND pbt.balance_name LIKE 'Steering%'
	AND pbt.BALANCE_CATEGORY_ID=(SELECT
	BALANCE_CATEGORY_ID FROM
	PAY_BALANCE_CATEGORIES_F WHERE
	legislation_code='SE'
	AND category_name=csr_v_category_name/*'001- Hours worked (September)'*/);

/*Defined Balances for the balances with peson level YTD dimension */
	CURSOR csr_defined_balances(csr_v_balance_type_id pay_balance_types.balance_type_id%TYPE)
	IS
	SELECT pdb.defined_balance_id
	FROM pay_balance_types pbt,
	pay_defined_balances pdb
	WHERE pbt.balance_type_id=pdb.balance_type_id
	AND pbt.balance_type_id=csr_v_balance_type_id --10506678
	AND pdb.BALANCE_DIMENSION_ID=(SELECT
	balance_dimension_id FROM
	pay_balance_dimensions WHERE
	legislation_code='SE'
	AND DATABASE_ITEM_SUFFIX='_PER_MONTH'  );
	/* changing _PER_YTD to _PER_MONTH for bug fix 6209364 */

/*Assignment level details for the report */
	CURSOR csr_person_local_unit(csr_v_business_group_id hr_organization_units.business_group_id%TYPE,
	csr_v_local_unit_id hr_organization_units.organization_id%TYPE, csr_v_effective_date date)
	IS
	SELECT papf.person_id person_id,
	papf.national_identifier person_number,
	paaf.assignment_id,
	paaf.employee_category,
	paaf.hourly_salaried_code,
	/*nvl(substr(trim(hsck.SEGMENT3),1,4),'0000') ssyk_code,
	nvl(substr(trim(hsck.SEGMENT3),5,2),'00') association_code,*/
	hsck.SEGMENT3 ssyk_code,
	hsck.SEGMENT3 association_code,
	hsck.segment14 agreement_code,
	paaf.payroll_id
	FROM per_all_assignments_f paaf,
	per_all_people_f papf,
	hr_soft_coding_keyflex hsck
	WHERE papf.business_group_id=csr_v_business_group_id -- 3133 --paaf.assignment_id = p_assignment_id
	AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
	AND papf.person_id=paaf.person_id
	and papf.person_id between p_start_person and p_end_person
	AND paaf.primary_flag='Y'
	AND hsck.segment2=to_char(csr_v_local_unit_id) --3268)
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN paaf.effective_start_date
	AND paaf.effective_end_date
	AND csr_v_effective_date /*'01-jan-2006'*/ BETWEEN papf.effective_start_date
	AND papf.effective_end_date
	AND months_between (csr_v_effective_date,DATE_OF_BIRTH) >= 216	 /* Age greater than 18 */
	AND months_between (csr_v_effective_date,DATE_OF_BIRTH) <= 780 /* Age less than and equal to 65 */
	AND papf.CURRENT_EMPLOYEE_FLAG='Y'
	AND paaf.payroll_id IS NOT NULL
	AND hsck.segment14 IS NOT NULL /* need not archive the person if he doesnt have agreement code */
	ORDER BY papf.person_id;

	CURSOR csr_lookup_values(csr_v_lookup_type hr_lookups.lookup_type%TYPE,
	csr_v_lookup_code hr_lookups.lookup_code%TYPE)
	IS
	SELECT meaning  FROM hr_lookups WHERE
	lookup_type =csr_v_lookup_type --'SE_AGREEMENT_CODE'
	AND LOOKUP_CODE=csr_v_lookup_code ;



l_ovn NUMBER;
l_action_info_id NUMBER;
L_MONTH_START_DATE DATE;
L_MONTH_END_DATE DATE;
L_LOCAL_UNIT_NAME VARCHAR2(50);
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
L_CFAR_NUMBER NUMBER;
l_legal_employer_id  hr_organization_units.organization_id%TYPE;
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
l_type varchar2(50);

l_valid_person number;
l_check_insert number;
l_worksite_number varchar2(10);
l_association_number varchar2(10);
l_legal_agreement_code varchar2(10);
l_agreement_code hr_lookups.meaning%TYPE;
l_agreement hr_lookups.lookup_code%TYPE;
l_asg_agreement_code hr_lookups.meaning%TYPE;
l_weekend_duty varchar2(10);
l_legal_employer hr_organization_units.name%TYPE;
l_organization_id varchar2(20);
l_membership_number varchar2(10);
l_assignment_id per_all_assignments_f.assignment_id%TYPE;
l_person_id per_all_people_f.person_id%TYPE;
l_ssyk hr_lookups.lookup_code%TYPE;
l_ssyk_code hr_lookups.meaning%TYPE;
l_association_code varchar2(10);
l_payroll_id pay_payrolls_f.payroll_id%TYPE;
l_work_type varchar2(250);
l_salary_type Number(1);
l_payroll_type pay_payrolls_f.payroll_type%TYPE;


l_001_steering_code NUMBER:=0;
l_002_steering_code NUMBER:=0;
l_003_steering_code NUMBER:=0;
l_004_steering_code NUMBER:=0;
l_051_steering_code NUMBER:=0;
l_052_steering_code NUMBER:=0;
l_053_steering_code NUMBER:=0;
l_054_steering_code NUMBER:=0;
l_055_steering_code NUMBER:=0;
l_056_steering_code NUMBER:=0;
l_058_steering_code NUMBER:=0;
l_600_steering_code NUMBER:=0;
l_601_steering_code NUMBER:=0;
l_810_steering_code NUMBER:=0;
l_800_steering_code NUMBER:=0;
l_801_steering_code NUMBER:=0;
l_802_steering_code NUMBER:=0;
l_803_steering_code NUMBER:=0;
l_804_steering_code NUMBER:=0;
l_805_steering_code NUMBER:=0;
l_806_steering_code NUMBER:=0;
l_808_steering_code NUMBER:=0;
 l_hour_sal CHAR(1);


l_balance_type_id pay_balance_types.balance_type_id%TYPE;
l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;

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
--The codes used in the package
/*
001- Hours worked (September)
002-Paid Overtime (September)
003-Working Hours per week
004-Working Hours week-full
051-Monthly, weekly pay
052-Over-time allowance
053-Comp. for Over-time
054-Comp. for shift work
055-comp. duty, relief work
056-Comp. for danger,dirt
058-Incentive pay (bonus)
600-Holiday days Entitlement
601-Salary for hours worked
810-Job Status
800-Comp. type of shift
801-Comp. post and position
802-Comp. for calving
803-Comp. for delegation
804-Comp. County, Municipal
805-Comp. for Per Diem
806-Comp. for Travel Expenses
808-Comp. for Official Duty
*/

      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_LE_request :=null;
      g_legal_employer_id := NULL;
      get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LE_request
						, g_month
                                                , g_report_year
						);

--	g_start_date:=to_date('01-' || g_month || '-' || g_year, 'dd-mm-yyyy');
	--g_end_date:=to_date('31-'|| g_month || '-' || g_year, 'dd-mm-yyyy');
	g_end_date:=last_day(to_date('01-09'|| '-' || g_report_year, 'dd-mm-yyyy'));


	IF g_LE_request ='LE_SELECTED' THEN
		FOR csr_legal_employer IN csr_local_legal_employer(g_business_group_id,g_legal_employer_id) LOOP
			l_local_unit_id:=csr_legal_employer.local_unit;
			/* Salary Structure EIT Details */
			OPEN csr_salary_structure_details(g_business_group_id,g_legal_employer_id);
				FETCH csr_salary_structure_details INTO l_worksite_number,l_association_number,
				l_legal_agreement_code,l_weekend_duty;
			CLOSE csr_salary_structure_details;
			FOR csr_person IN csr_person_local_unit(g_business_group_id,l_local_unit_id,g_end_date)LOOP
				l_person_id:=csr_person.person_id;
				l_hour_sal:=csr_person.hourly_salaried_code;
				l_person_number:=csr_person.person_number;
				l_assignment_id:=csr_person.assignment_id;
				l_employee_category:=csr_person.employee_category;
				l_ssyk:=csr_person.ssyk_code;
				--l_association_code:=csr_person.association_code;
				l_payroll_id:=csr_person.payroll_id;
				l_agreement:=csr_person.agreement_code;
				OPEN csr_lookup_values('SE_SKILLS_LEVEL_CODE',l_ssyk);
					FETCH csr_lookup_values INTO l_ssyk_code;
					l_association_code:=nvl(substr(trim(l_ssyk_code),5,2),'00');
					l_ssyk_code:=nvl(substr(trim(l_ssyk_code),1,4),'0000');
				CLOSE csr_lookup_values;
				OPEN csr_lookup_values('SE_AGREEMENT_CODE',l_agreement);
					FETCH csr_lookup_values INTO l_asg_agreement_code;
				CLOSE csr_lookup_values;
				l_agreement_code:=l_asg_agreement_code;
				OPEN csr_payroll_period(l_payroll_id);
					FETCH csr_payroll_period INTO l_payroll_type;
				CLOSE csr_payroll_period;
				/*IF l_payroll_type='Calendar Month' THEN
					l_salary_type:=1;
				ELSIF l_payroll_type='Week' THEN
					l_salary_type:=2;
				END IF;*/
				IF l_payroll_type='Calendar Month' THEN
					IF l_hour_sal='H' THEN
						l_salary_type:=3;
					ELSE
						l_salary_type:=1;
					END IF;
				ELSIF l_payroll_type='Week' THEN
					IF l_hour_sal='H' THEN
						l_salary_type:=3;
					ELSE
						l_salary_type:=2;
					END if;
				ELSIF l_payroll_type='Bi-Week' THEN
					IF l_hour_sal='H' THEN
						l_salary_type:=3;
					ELSE
						l_salary_type:=1;
					END IF;
				END IF;


				OPEN csr_extra_assignment(l_assignment_id);
					FETCH csr_extra_assignment INTO l_work_type;
				CLOSE csr_extra_assignment;
				pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id); --133942);
				pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id); --3621);

				FOR csr_balance IN csr_balances(g_business_group_id,'001- Hours worked (September)') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;

					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;

					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);

					l_001_steering_code:=l_001_steering_code+l_value;

				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'002-Paid Overtime (September)') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_002_steering_code:=l_002_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'003-Working Hours per week') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_003_steering_code:=l_003_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'004-Working Hours week-full') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_004_steering_code:=l_004_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'051-Monthly, weekly pay') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_051_steering_code:=l_051_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'052-Over-time allowance') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_052_steering_code:=l_052_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'053-Comp. for Over-time') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_053_steering_code:=l_053_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'054-Comp. for shift work') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_054_steering_code:=l_054_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'055-comp. duty, relief work') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_055_steering_code:=l_055_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'056-Comp. for danger,dirt') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_056_steering_code:=l_056_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'058-Incentive pay (bonus)') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_058_steering_code:=l_058_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'600-Holiday days Entitlement') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_600_steering_code:=l_600_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'601-Salary for hours worked') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_601_steering_code:=l_601_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'810-Job Status') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_810_steering_code:=l_810_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'800-Comp. type of shift') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_800_steering_code:=l_800_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'801-Comp. post and position') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_801_steering_code:=l_801_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'802-Comp. for calving') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_802_steering_code:=l_802_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'803-Comp. for delegation') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_803_steering_code:=l_803_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'804-Comp. County, Municipal') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_804_steering_code:=l_804_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'805-Comp. for Per Diem') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_805_steering_code:=l_805_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'806-Comp. for Travel Expenses') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_806_steering_code:=l_806_steering_code+l_value;
				END LOOP;
				FOR csr_balance IN csr_balances(g_business_group_id,'808-Comp. for Official Duty') LOOP

					l_balance_type_id:=csr_balance.balance_type_id;
					OPEN csr_defined_balances(l_balance_type_id);
						FETCH csr_defined_balances INTO l_defined_balance_id;
					CLOSE csr_defined_balances;
					l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
					P_ASSIGNMENT_ID =>l_assignment_id, --21348,
					P_VIRTUAL_DATE=>g_end_date),0);
					l_808_steering_code:=l_808_steering_code+l_value;
				END LOOP;

				pay_action_information_api.create_action_information
				(p_action_information_id             => l_action_info_id
				, p_action_context_id                => p_payroll_action_id
				, p_action_context_type              => 'PA'
				, p_object_version_number            => l_ovn
				, p_effective_date                   => g_effective_date
				, p_source_id                        => NULL
				, p_source_text                      => NULL
				, p_action_information_category      => 'EMEA REPORT INFORMATION'
				, p_action_information1              => 'PYSESSSA'
				, p_action_information2              => 'PER1'
				, p_action_information3              => l_person_id
				, p_action_information4              => l_person_number
				, p_action_information5              => l_local_unit_id
				, p_action_information6              => l_cfar_number
				, p_action_information7              => l_employee_category
				, p_action_information8              => l_work_type
				, p_action_information9              => l_agreement_code
				, p_action_information10             => l_ssyk_code
				, p_action_information11             => l_association_code
				, p_action_information12             => l_salary_type
				, p_action_information13             => l_001_steering_code
				, p_action_information14             => l_002_steering_code
				, p_action_information15             => l_003_steering_code
				, p_action_information16             => l_004_steering_code
				, p_action_information17             => l_051_steering_code
				, p_action_information18             => l_052_steering_code
				, p_action_information19             => l_053_steering_code
				, p_action_information20             => l_054_steering_code
				, p_action_information21             => l_055_steering_code
				, p_action_information22             => l_056_steering_code
				, p_action_information23             => l_058_steering_code
				, p_action_information24             => l_600_steering_code
				, p_action_information25             => l_601_steering_code
				, p_action_information26             => l_810_steering_code
				);

				pay_action_information_api.create_action_information
				(p_action_information_id             => l_action_info_id
				, p_action_context_id                => p_payroll_action_id
				, p_action_context_type              => 'PA'
				, p_object_version_number            => l_ovn
				, p_effective_date                   => g_effective_date
				, p_source_id                        => NULL
				, p_source_text                      => NULL
				, p_action_information_category      => 'EMEA REPORT INFORMATION'
				, p_action_information1              => 'PYSESSSA'
				, p_action_information2              => 'PER2'
				, p_action_information3              => l_person_id
				, p_action_information4              => l_local_unit_id
				, p_action_information5              => l_800_steering_code
				, p_action_information6              => l_801_steering_code
				, p_action_information7              => l_802_steering_code
				, p_action_information8              => l_803_steering_code
				, p_action_information9              => l_804_steering_code
				, p_action_information10             => l_805_steering_code
				, p_action_information11             => l_806_steering_code
				, p_action_information12             => l_808_steering_code
				);
				l_001_steering_code:=0;
				l_002_steering_code:=0;
				l_003_steering_code:=0;
				l_004_steering_code:=0;
				l_051_steering_code:=0;
				l_052_steering_code:=0;
				l_053_steering_code:=0;
				l_054_steering_code:=0;
				l_055_steering_code:=0;
				l_056_steering_code:=0;
				l_058_steering_code:=0;
				l_600_steering_code:=0;
				l_601_steering_code:=0;
				l_810_steering_code:=0;
				l_800_steering_code:=0;
				l_801_steering_code:=0;
				l_802_steering_code:=0;
				l_803_steering_code:=0;
				l_804_steering_code:=0;
				l_805_steering_code:=0;
				l_806_steering_code:=0;
				l_808_steering_code:=0;

			END LOOP;


		END LOOP;
        ELSE
		FOR csr_legal IN csr_legal_employer(g_business_group_id) LOOP
			l_legal_employer_id:=csr_legal.legal_employer_id;
			/* Salary Structure EIT Details */
			OPEN csr_salary_structure_details(g_business_group_id,g_legal_employer_id);
				FETCH csr_salary_structure_details INTO l_worksite_number,l_association_number,
				l_legal_agreement_code,l_weekend_duty;
			CLOSE csr_salary_structure_details;
			FOR csr_legal_employer IN csr_local_legal_employer(g_business_group_id,l_legal_employer_id) LOOP
				l_local_unit_id:=csr_legal_employer.local_unit;
				FOR csr_person IN csr_person_local_unit(g_business_group_id,l_local_unit_id,g_end_date)LOOP
					l_person_id:=csr_person.person_id;
					l_person_number:=csr_person.person_number;
					l_hour_sal:=csr_person.hourly_salaried_code;
					l_assignment_id:=csr_person.assignment_id;
					l_employee_category:=csr_person.employee_category;
					l_ssyk:=csr_person.ssyk_code;
					l_association_code:=csr_person.association_code;
					l_payroll_id:=csr_person.payroll_id;
					l_agreement:=csr_person.agreement_code;
					OPEN csr_lookup_values('SE_SKILLS_LEVEL_CODE',l_ssyk);
						FETCH csr_lookup_values INTO l_ssyk_code;
						l_association_code:=nvl(substr(trim(l_ssyk_code),5,2),'00');
						l_ssyk_code:=nvl(substr(trim(l_ssyk_code),1,4),'0000');
					CLOSE csr_lookup_values;
					OPEN csr_lookup_values('SE_AGREEMENT_CODE',l_agreement);
						FETCH csr_lookup_values INTO l_asg_agreement_code;
					CLOSE csr_lookup_values;
					l_agreement_code:=l_asg_agreement_code;
					OPEN csr_payroll_period(l_payroll_id);
						FETCH csr_payroll_period INTO l_payroll_type;
					CLOSE csr_payroll_period;
					IF l_payroll_type='Calendar Month' THEN
						IF l_hour_sal='H' THEN
							l_salary_type:=3;
						ELSE
							l_salary_type:=1;
						END IF;
					ELSIF l_payroll_type='Week' THEN
						IF l_hour_sal='H' THEN
							l_salary_type:=3;
						ELSE
							l_salary_type:=2;
						END if;
					ELSIF l_payroll_type='Bi-Week' THEN
						IF l_hour_sal='H' THEN
							l_salary_type:=3;
						ELSE
							l_salary_type:=1;
						END IF;
					END IF;

					OPEN csr_extra_assignment(l_assignment_id);
						FETCH csr_extra_assignment INTO l_work_type;
					CLOSE csr_extra_assignment;
					pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id); --133942);
					pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id); --3621);

					FOR csr_balance IN csr_balances(g_business_group_id,'001- Hours worked (September)') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;

						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;

						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);

						l_001_steering_code:=l_001_steering_code+l_value;

					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'002-Paid Overtime (September)') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_002_steering_code:=l_002_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'003-Working Hours per week') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_003_steering_code:=l_003_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'004-Working Hours week-full') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_004_steering_code:=l_004_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'051-Monthly, weekly pay') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_051_steering_code:=l_051_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'052-Over-time allowance') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_052_steering_code:=l_052_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'053-Comp. for Over-time') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_053_steering_code:=l_053_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'054-Comp. for shift work') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_054_steering_code:=l_054_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'055-comp. duty, relief work') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_055_steering_code:=l_055_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'056-Comp. for danger,dirt') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_056_steering_code:=l_056_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'058-Incentive pay (bonus)') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_058_steering_code:=l_058_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'600-Holiday days Entitlement') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_600_steering_code:=l_600_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'601-Salary for hours worked') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_601_steering_code:=l_601_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'810-Job Status') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_810_steering_code:=l_810_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'800-Comp. type of shift') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_800_steering_code:=l_800_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'801-Comp. post and position') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_801_steering_code:=l_801_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'802-Comp. for calving') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_802_steering_code:=l_802_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'803-Comp. for delegation') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_803_steering_code:=l_803_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'804-Comp. County, Municipal') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_804_steering_code:=l_804_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'805-Comp. for Per Diem') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_805_steering_code:=l_805_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'806-Comp. for Travel Expenses') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_806_steering_code:=l_806_steering_code+l_value;
					END LOOP;
					FOR csr_balance IN csr_balances(g_business_group_id,'808-Comp. for Official Duty') LOOP

						l_balance_type_id:=csr_balance.balance_type_id;
						OPEN csr_defined_balances(l_balance_type_id);
							FETCH csr_defined_balances INTO l_defined_balance_id;
						CLOSE csr_defined_balances;
						l_value:=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>l_defined_balance_id,
						P_ASSIGNMENT_ID =>l_assignment_id, --21348,
						P_VIRTUAL_DATE=>g_end_date),0);
						l_808_steering_code:=l_808_steering_code+l_value;
					END LOOP;

					pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSESSSA'
					, p_action_information2              => 'PER1'
					, p_action_information3              => l_person_id
					, p_action_information4              => l_person_number
					, p_action_information5              => l_local_unit_id
					, p_action_information6              => l_cfar_number
					, p_action_information7              => l_employee_category
					, p_action_information8              => l_work_type
					, p_action_information9              => l_agreement_code
					, p_action_information10              => l_ssyk_code
					, p_action_information11             => l_association_code
					, p_action_information12             => l_salary_type
					, p_action_information13             => l_001_steering_code
					, p_action_information14             => l_002_steering_code
					, p_action_information15             => l_003_steering_code
					, p_action_information16             => l_004_steering_code
					, p_action_information17             => l_051_steering_code
					, p_action_information18             => l_052_steering_code
					, p_action_information19             => l_053_steering_code
					, p_action_information20             => l_054_steering_code
					, p_action_information21             => l_055_steering_code
					, p_action_information22             => l_056_steering_code
					, p_action_information23             => l_058_steering_code
					, p_action_information24             => l_600_steering_code
					, p_action_information25             => l_601_steering_code
					, p_action_information26             => l_810_steering_code
					);

					pay_action_information_api.create_action_information
					(p_action_information_id              => l_action_info_id
					, p_action_context_id                => p_payroll_action_id
					, p_action_context_type              => 'PA'
					, p_object_version_number            => l_ovn
					, p_effective_date                   => g_effective_date
					, p_source_id                        => NULL
					, p_source_text                      => NULL
					, p_action_information_category      => 'EMEA REPORT INFORMATION'
					, p_action_information1              => 'PYSESSSA'
					, p_action_information2              => 'PER2'
					, p_action_information3              => l_person_id
					, p_action_information4              => l_local_unit_id
					, p_action_information5              => l_800_steering_code
					, p_action_information6              => l_801_steering_code
					, p_action_information7              => l_802_steering_code
					, p_action_information8              => l_803_steering_code
					, p_action_information9              => l_804_steering_code
					, p_action_information10             => l_805_steering_code
					, p_action_information11             => l_806_steering_code
					, p_action_information12             => l_808_steering_code
					);
					l_001_steering_code:=0;
					l_002_steering_code:=0;
					l_003_steering_code:=0;
					l_004_steering_code:=0;
					l_051_steering_code:=0;
					l_052_steering_code:=0;
					l_053_steering_code:=0;
					l_054_steering_code:=0;
					l_055_steering_code:=0;
					l_056_steering_code:=0;
					l_058_steering_code:=0;
					l_600_steering_code:=0;
					l_601_steering_code:=0;
					l_810_steering_code:=0;
					l_800_steering_code:=0;
					l_801_steering_code:=0;
					l_802_steering_code:=0;
					l_803_steering_code:=0;
					l_804_steering_code:=0;
					l_805_steering_code:=0;
					l_806_steering_code:=0;
					l_808_steering_code:=0;

				END LOOP;


			END LOOP;

		END LOOP;

        END IF;

   /*EXCEPTION
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('error raised assignment_action_code '
                                   , 5
                                    );
         END IF;

         RAISE;*/
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
         || '"?> <ROOT><SSST>';
      l_str2      := '<';
      l_str3      := '>';
      l_str4      := '</';
      l_str5      := '>';
      l_str6      := '</SSST></ROOT>';
      l_str7      :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT></ROOT>';
      l_str10     := '<SSST>';
      l_str11     := '</SSST>';
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
                  'SSST_DETAILS',
                  'END_SSST_DETAILS'
                  )
            THEN
               IF l_str9 IN
                     ('SSST_DETAILS')
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

l_employee_category hr_lookups.meaning%type;
l_weekend_pay_duty hr_lookups.meaning%type;
l_working_hour_code hr_lookups.lookup_code%type;
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





CURSOR csr_report_year(csr_v_payroll_action_id number)
IS
SELECT pai.action_information6 Report_Year
FROM
pay_action_information pai,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id--175110 --csr_v_payroll_action_id
AND ppa.payroll_action_id=pai.action_context_id
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSESSSA'
AND pai.action_information_category = 'EMEA REPORT DETAILS';

CURSOR csr_salary_statistics(csr_v_payroll_action_id number)
IS
SELECT pai1.action_information3 legal_employer_id,
pai2.action_information3 local_unit_id,
pai3.action_information3 person_id,
pai1.action_information6 Membership_Number,
pai1.action_information7 Working_Site_Number,
pai1.action_information5 Organization_Id,
pai1.action_information8 Association_Number,
pai3.action_information9 Agreement_Code,
pai3.action_information4 Person_Number,
pai3.action_information7 Employee_Category,
pai3.action_information8 Working_Hours_Type,
pai3.action_information10 SSYK_Code,
pai3.action_information11 Association_Code,
pai3.action_information12 Salary_Type,
pai2.action_information5 CFAR_Number,
pai1.action_information10 Weekend_Pay_Duty,
decode(nvl(pai3.action_information13,0) ,0,'0000000',pai3.action_information13) Steering_Code_001,
decode(nvl(pai3.action_information14,0) ,0,'0000000',pai3.action_information14) Steering_Code_002,
decode(nvl(pai3.action_information15,0) ,0,'0000000',pai3.action_information15) Steering_Code_003,
decode(nvl(pai3.action_information16,0) ,0,'0000000',pai3.action_information16) Steering_Code_004,
decode(nvl(pai3.action_information17,0) ,0,'0000000',pai3.action_information17) Steering_Code_051,
decode(nvl(pai3.action_information18,0) ,0,'0000000',pai3.action_information18) Steering_Code_052,
decode(nvl(pai3.action_information19,0) ,0,'0000000',pai3.action_information19) Steering_Code_053,
decode(nvl(pai3.action_information20,0) ,0,'0000000',pai3.action_information20) Steering_Code_054,
decode(nvl(pai3.action_information21,0) ,0,'0000000',pai3.action_information21) Steering_Code_055,
decode(nvl(pai3.action_information22,0) ,0,'0000000',pai3.action_information22) Steering_Code_056,
decode(nvl(pai3.action_information23,0) ,0,'0000000',pai3.action_information23) Steering_Code_058,
decode(nvl(pai3.action_information24,0) ,0,'0000000',pai3.action_information24) Steering_Code_600,
decode(nvl(pai3.action_information25,0) ,0,'0000000',pai3.action_information25) Steering_Code_601,
decode(nvl(pai3.action_information26,0) ,0,'0000000',pai3.action_information26) Steering_Code_810,
decode(nvl(pai4.action_information5,0) ,0,'0000000',pai4.action_information5) Steering_Code_800,
decode(nvl(pai4.action_information6,0) ,0,'0000000',pai4.action_information6) Steering_Code_801,
decode(nvl(pai4.action_information7,0) ,0,'0000000',pai4.action_information7) Steering_Code_802,
decode(nvl(pai4.action_information8,0) ,0,'0000000',pai4.action_information8) Steering_Code_803,
decode(nvl(pai4.action_information9,0) ,0,'0000000',pai4.action_information9) Steering_Code_804,
decode(nvl(pai4.action_information10,0) ,0,'0000000',pai4.action_information10) Steering_Code_805,
decode(nvl(pai4.action_information11,0) ,0,'0000000',pai4.action_information11) Steering_Code_806,
decode(nvl(pai4.action_information12,0) ,0,'0000000',pai4.action_information12) Steering_Code_808
FROM
pay_action_information pai1,
pay_action_information pai2,
pay_action_information pai3,
pay_action_information pai4,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id --175110 --175079 --175068 --csr_v_payroll_action_id
AND ppa.payroll_action_id=pai1.action_context_id
AND pai1.action_context_id=pai2.action_context_id
AND pai2.action_context_id=pai3.action_context_id
and pai3.action_context_id=pai4.action_context_id
and pai4.action_context_id=ppa.payroll_action_id
--AND pai1.action_information3=to_char(csr_v_local_unit_id ) --csr_v_local_unit_id
AND pai1.action_context_type='PA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai1.action_information1 = 'PYSESSSA'
--AND pai1.action_information_id=csr_v_action_information_id
AND pai1.action_information2='LE'
AND pai1.action_information3=pai2.action_information4
AND pai2.action_context_type='PA'
AND pai2.action_information2 = 'LU'
AND pai2.action_information1 = 'PYSESSSA'
AND pai2.action_information_category = 'EMEA REPORT INFORMATION'
AND pai2.action_information3=pai3.action_information5
AND pai3.action_context_type='PA'
AND pai3.action_information2 = 'PER1'
AND pai3.action_information1 = 'PYSESSSA'
AND pai3.action_information_category = 'EMEA REPORT INFORMATION'
AND pai2.action_information3=pai4.action_information4
AND pai3.action_information5=pai4.action_information4
AND pai3.action_information3=pai4.action_information3
/* Bug Fix 6209364 */
AND pai3.action_information9  IN (SELECT
	hl.meaning Agreement_Code
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	,hr_lookups hl
	WHERE  o1.business_group_id =g_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =pai1.action_information3
	AND hoi1.ORG_INFORMATION_CONTEXT='SE_SALARY_STRUCTURE'
	AND hl.lookup_type ='SE_AGREEMENT_CODE'
	AND hl.LOOKUP_CODE=hoi1.org_information3 )
--=pai1.action_information9 /*linking the agreement code b/w assignment and Legal employer */
AND pai4.action_context_type='PA'
AND pai4.action_information2 = 'PER2'
AND pai4.action_information1 = 'PYSESSSA'
AND pai4.action_information_category = 'EMEA REPORT INFORMATION'
ORDER BY pai1.action_information3,
pai2.action_information3,
pai3.action_information9,
pai3.action_information3;

CURSOR csr_local_unit_count(csr_v_payroll_action_id number, csr_v_CFAR_Number VARCHAR2)
IS
SELECT nvl(COUNT(*),0)  Local_Unit_Count
FROM
pay_action_information pai,
pay_action_information pai1,
pay_payroll_actions ppa
WHERE
ppa.payroll_action_id=csr_v_payroll_action_id --175110 --csr_v_payroll_action_id
AND ppa.payroll_action_id=pai.action_context_id
AND pai.action_context_id=pai1.action_context_id
AND pai1.action_context_id=ppa.payroll_action_id
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSESSSA'
AND pai.action_information2 = 'LU'
AND pai.action_information_category = 'EMEA REPORT INFORMATION'
AND pai.action_information5=csr_v_CFAR_Number --312
AND pai.action_information3= pai1.action_information5
AND pai1.action_context_type = 'PA'
AND pai1.action_information1 = 'PYSESSSA'
AND pai1.action_information2 = 'PER1'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION';

CURSOR csr_lookup_values(csr_v_lookup_type varchar2, csr_v_lookup_code varchar2)
IS
SELECT meaning FROM
hr_lookups WHERE lookup_type =csr_v_lookup_type-- 'EMPLOYEE_CATG'
AND lookup_code=csr_v_lookup_code; -- 'WC'

CURSOR csr_lookup_code(csr_v_lookup_type varchar2, csr_v_lookup_meaning varchar2)
IS
SELECT lookup_code FROM
hr_lookups WHERE lookup_type =csr_v_lookup_type-- 'EMPLOYEE_CATG'
AND meaning=csr_v_lookup_meaning; -- 'WC'

CURSOR csr_agreement_legal (csr_v_legal_employer NUMBER, csr_v_agreement VARCHAR2 )
IS
  SELECT
  hoi1.ORG_INFORMATION1 Working_Site_Number,
  hoi1.ORG_INFORMATION2 Association_Number,
  hoi1.ORG_INFORMATION4 Weekend_Pay_Duty
  FROM hr_organization_units o1
  , hr_organization_information hoi1
  ,hr_lookups hl
  WHERE  o1.business_group_id =g_business_group_id --3133  --3133 --csr_v_business_group_id --3133 --l_business_group_id
  AND hoi1.organization_id = o1.organization_id
  AND hoi1.organization_id =csr_v_legal_employer --3134 --pai1.action_information3  --csr_v_legal_employer_id --3134 --csr_v_legal_unit_id
  AND hoi1.ORG_INFORMATION_CONTEXT='SE_SALARY_STRUCTURE'
  AND hl.lookup_type ='SE_AGREEMENT_CODE'
  AND hl.MEANING=csr_v_agreement --'333'
  AND hl.lookup_code=hoi1.ORG_INFORMATION3;



l_counter             NUMBER:=0;
l_total               NUMBER;
l_total_eft           NUMBER;
l_count               NUMBER;
l_payroll_action_id   NUMBER;
l_lu_counter_reset    VARCHAR2(10);
l_prev_local_unit     VARCHAR2(15);
l_report_date         DATE;
l_person_number VARCHAR2(50);
l_local_unit_id hr_organization_units.organization_id%type;
l_period varchar2(50);
l_report_year number(4);
l_local_count NUMBER;
l_CFAR_Number NUMBER;
l_legal_employer_id hr_organization_units.organization_id%TYPE;
l_working_hour_meaning hr_lookups.meaning%type;
l_association_number varchar2(10);
l_worksite_number varchar2(10);
l_agreement_code hr_lookups.meaning%TYPE;


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

      get_all_parameters (l_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_LE_request
						, g_month
                                                , g_report_year
                                                 );


        hr_utility.set_location('Entered Procedure GETDATA',10);

	/*	xml_tab(l_counter).TagName  :='LU_DETAILS';
		xml_tab(l_counter).TagValue :='LU_DETAILS';*/
/*		l_counter:=l_counter+1;*/

        /* Get the File Header Information */
	 OPEN csr_report_year(l_payroll_action_id);
		FETCH csr_report_year INTO l_report_year;
	 CLOSE csr_report_year;

         hr_utility.set_location('Before populating pl/sql table',20);
	 FOR csr_salary IN csr_salary_statistics(l_payroll_action_id) LOOP

			xml_tab(l_counter).TagName  :='SSST_DETAILS';
			xml_tab(l_counter).TagValue :='SSST_DETAILS';
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='REPORT_YEAR';
			xml_tab(l_counter).TagValue :=l_report_year; --csr_cat.legal_employer;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='MEMBERSHIP_NUMBER';
			xml_tab(l_counter).TagValue :=csr_salary.Membership_Number; --csr_cat.local_unit;
			l_counter:=l_counter+1;
			l_legal_employer_id:=csr_salary.legal_employer_id;
		        l_agreement_code:=csr_salary.Agreement_Code;

			OPEN  csr_agreement_legal (l_legal_employer_id , l_agreement_code);
		            FETCH csr_agreement_legal INTO l_worksite_number,l_association_number,l_weekend_pay_duty;
			CLOSE csr_agreement_legal;
			xml_tab(l_counter).TagName  :='WORKING_SITE_NUMBER';
			xml_tab(l_counter).TagValue :=l_worksite_number; --csr_salary.Working_Site_Number; --csr_cat.month;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ORGANIZATION_ID';
			xml_tab(l_counter).TagValue :=csr_salary.Organization_Id; --csr_cat.retroactive_date_from;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ASSOCIATION_NUMBER';
			xml_tab(l_counter).TagValue :=l_association_number; --csr_salary.Association_Number; --csr_cat.retroactive_date_to;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='AGREEMENT_CODE';
			xml_tab(l_counter).TagValue :=csr_salary.Agreement_Code; --csr_cat.bh_worked_calendar_month;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='PERSON_NUMBER';
			xml_tab(l_counter).TagValue :=csr_salary.Person_Number; --csr_cat.bh_worked_payment_period;
			l_counter:=l_counter+1;

			l_employee_category:=csr_salary.Employee_Category;
			xml_tab(l_counter).TagName  :='EMPLOYEE_CATG';

			IF l_employee_category='BC' THEN
				xml_tab(l_counter).TagValue :=1; --csr_salary.Employee_Category; --csr_cat.bh_pbt_value;
			ELSIF l_employee_category='WC' THEN
				xml_tab(l_counter).TagValue :=2;
			END IF;
			l_counter:=l_counter+1;
			OPEN csr_lookup_values('EMPLOYEE_CATG',l_employee_category );
				FETCH csr_lookup_values INTO l_employee_category;
			CLOSE csr_lookup_values;

			xml_tab(l_counter).TagName  :='EMPLOYEE_CATEGORY';
			xml_tab(l_counter).TagValue :=l_employee_category; --csr_salary.Employee_Category; --csr_cat.bh_pbt_value;
			l_counter:=l_counter+1;

			l_working_hour_code:=csr_salary.Working_Hours_Type;

			OPEN csr_lookup_code('SE_WORKING_HOUR_TYPE', l_working_hour_code);
				FETCH csr_lookup_code INTO l_working_hour_code;
			CLOSE csr_lookup_code;

			xml_tab(l_counter).TagName  :='WORKING_HOURS';
			xml_tab(l_counter).TagValue :=l_working_hour_code;-- csr_salary.Working_Hours_Type; --csr_cat.bh_pcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='WORKING_HOURS_TYPE';
			xml_tab(l_counter).TagValue :=csr_salary.Working_Hours_Type; --csr_cat.bh_pcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='SSYK_CODE';
			xml_tab(l_counter).TagValue :=csr_salary.SSYK_Code; --csr_cat.bh_nha_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ASSOCIATION_CODE';
			xml_tab(l_counter).TagValue :=csr_salary.Association_Code; --csr_cat.bh_nho_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='SALARY_TYPE';
			xml_tab(l_counter).TagValue :=csr_salary.Salary_Type; --csr_cat.bh_retroactive_pay;
			l_counter:=l_counter+1;

			l_CFAR_Number:=csr_salary.CFAR_Number;

			open csr_local_unit_count(l_payroll_action_id, l_CFAR_Number);
				FETCH csr_local_unit_count INTO l_local_count;
			CLOSE csr_local_unit_count;

			xml_tab(l_counter).TagName  :='LOCAL_COUNT';
			xml_tab(l_counter).TagValue :=l_local_count; --csr_cat.bh_ppo_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='CFAR_NUMBER';
			xml_tab(l_counter).TagValue :=csr_salary.CFAR_Number; --csr_cat.bh_sick_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='WEEKEND_PAY';
			IF /*csr_salary.Weekend_Pay_Duty*/l_weekend_pay_duty='Y'  THEN
				xml_tab(l_counter).TagValue :=1;-- csr_salary.Weekend_Pay_Duty; --csr_cat.bh_total_employees;
			ELSE
				xml_tab(l_counter).TagValue :=2;
			END IF;
			l_counter:=l_counter+1;

			--l_weekend_pay_duty:=csr_salary.Weekend_Pay_Duty;

			OPEN csr_lookup_values('YES_NO',l_weekend_pay_duty );
				FETCH csr_lookup_values INTO l_weekend_pay_duty;
			CLOSE csr_lookup_values;

			xml_tab(l_counter).TagName  :='WEEKEND_PAY_DUTY';
			xml_tab(l_counter).TagValue :=l_weekend_pay_duty; --csr_salary.Weekend_Pay_Duty; --csr_cat.bh_total_employees;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='ZERO_FILLING';
			xml_tab(l_counter).TagValue :='000000';
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_001';
			xml_tab(l_counter).TagValue :='001'; --csr_cat.bs_gross_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_001';
			xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_001,2); --csr_cat.bs_gross_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_VALUE_001';
			xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_001,2); --csr_cat.bs_gross_pay;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_002';
			xml_tab(l_counter).TagValue :='002'; --csr_cat.bs_working_agreement;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_002';
			xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_002,2); --csr_cat.bs_working_agreement;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_VALUE_002';
			xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_002,2); --csr_cat.bs_working_agreement;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_003';
			xml_tab(l_counter).TagValue :='003'; --csr_cat.bs_tcdp_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_003';
			xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_003,2); --csr_cat.bs_tcdp_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_VALUE_003';
			xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_003,2); --csr_cat.bs_tcdp_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_004';
			xml_tab(l_counter).TagValue :='004';
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_004';
			xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_004,2); --csr_cat.bs_tcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_VALUE_004';
			xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_004,2); --csr_cat.bs_tcow_value;
			l_counter:=l_counter+1;

			xml_tab(l_counter).TagName  :='STEERING_CODE_051';
			xml_tab(l_counter).TagValue :='051'; --csr_cat.bs_nha_value;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_051';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_051,2); --csr_cat.bs_nha_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_051';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_051,2); --csr_cat.bs_nha_value;
				l_counter:=l_counter+1;
			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_051';
				IF csr_salary.Steering_Code_051 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_051); --csr_cat.bs_nha_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_051;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_051';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_051); --csr_cat.bs_nha_value;
				l_counter:=l_counter+1;
			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_052';
			xml_tab(l_counter).TagValue :='052'; --csr_cat.bs_nho_value;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_052';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_052,2); --csr_cat.bs_nho_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_052';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_052,2); --csr_cat.bs_nho_value;
				l_counter:=l_counter+1;

			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_052';
				IF csr_salary.Steering_Code_052 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_052); --csr_cat.bs_nho_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_052; --csr_cat.bs_nho_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_052';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_052); --csr_cat.bs_nho_value;
				l_counter:=l_counter+1;
			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_053';
			xml_tab(l_counter).TagValue :='053'; --csr_cat.bs_retroactive_pay;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_053';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_053,2); --csr_cat.bs_retroactive_pay;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_053';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_053,2); --csr_cat.bs_retroactive_pay;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_053';
				IF csr_salary.Steering_Code_053 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_053); --csr_cat.bs_retroactive_pay;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_053; --csr_cat.bs_retroactive_pay;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_053';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_053); --csr_cat.bs_retroactive_pay;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_054';
			xml_tab(l_counter).TagValue :='054'; --csr_cat.bs_ppo_value;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_054';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_054,2); --csr_cat.bs_ppo_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_054';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_054,2); --csr_cat.bs_ppo_value;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_054';
				IF csr_salary.Steering_Code_054 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_054); --csr_cat.bs_ppo_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_054; --csr_cat.bs_ppo_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_054';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_054); --csr_cat.bs_ppo_value;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_055';
			xml_tab(l_counter).TagValue :='055'; --csr_cat.bs_sick_pay;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_055';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_055,2); --csr_cat.bs_sick_pay;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_055';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_055,2); --csr_cat.bs_sick_pay;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_055';
				IF csr_salary.Steering_Code_055 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_055); --csr_cat.bs_sick_pay;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_055; --csr_cat.bs_sick_pay;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_055';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_055); --csr_cat.bs_sick_pay;
				l_counter:=l_counter+1;

			END IF;


			xml_tab(l_counter).TagName  :='STEERING_CODE_056';
			xml_tab(l_counter).TagValue :='056'; --csr_cat.bs_total_employees;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_056';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_056,2); --csr_cat.bs_total_employees;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_056';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_056,2); --csr_cat.bs_total_employees;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_056';
				IF csr_salary.Steering_Code_056 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_056); --csr_cat.bs_total_employees;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_056; --csr_cat.bs_total_employees;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_056';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_056); --csr_cat.bs_total_employees;
				l_counter:=l_counter+1;

			END IF;
			xml_tab(l_counter).TagName  :='STEERING_CODE_058';
			xml_tab(l_counter).TagValue :='058'; --round(csr_cat.ws_full_time_employee,2);
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_058';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_058,2); --round(csr_cat.ws_full_time_employee,2);
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_058';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_058,2); --round(csr_cat.ws_full_time_employee,2);
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_058';
				IF csr_salary.Steering_Code_058 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_058); --round(csr_cat.ws_full_time_employee,2);
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_058; --round(csr_cat.ws_full_time_employee,2);
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_058';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_058); --round(csr_cat.ws_full_time_employee,2);
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_600';
			xml_tab(l_counter).TagValue :='600'; --csr_cat.ws_gross_pay;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_600';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_600,2); --csr_cat.ws_gross_pay;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_600';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_600,2); --csr_cat.ws_gross_pay;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_600';
				IF csr_salary.Steering_Code_600 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_600); --csr_cat.ws_gross_pay;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_600; --csr_cat.ws_gross_pay;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_600';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_600); --csr_cat.ws_gross_pay;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_601';
			xml_tab(l_counter).TagValue :='601'; --csr_cat.ws_working_agreement;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_601';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_601,2); --csr_cat.ws_working_agreement;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_601';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_601,2); --csr_cat.ws_working_agreement;
				l_counter:=l_counter+1;

			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_601';
				IF csr_salary.Steering_Code_601 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_601); --csr_cat.ws_working_agreement;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_601; --csr_cat.ws_working_agreement;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_601';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_601); --csr_cat.ws_working_agreement;
				l_counter:=l_counter+1;
			END IF;
			xml_tab(l_counter).TagName  :='STEERING_CODE_810';
			xml_tab(l_counter).TagValue :='810'; --csr_cat.ws_tcdp_value;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_810';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_810,2); --csr_cat.ws_tcdp_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_810';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_810,2); --csr_cat.ws_tcdp_value;
				l_counter:=l_counter+1;

			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_810';
				IF csr_salary.Steering_Code_810 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_810); --csr_cat.ws_tcdp_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_810; --csr_cat.ws_tcdp_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_810';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_810); --csr_cat.ws_tcdp_value;
				l_counter:=l_counter+1;
			END IF;
			xml_tab(l_counter).TagName  :='STEERING_CODE_800';
			xml_tab(l_counter).TagValue :='800'; --csr_cat.ws_tcow_value;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_800';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_800,2); --csr_cat.ws_tcow_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_800';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_800,2); --csr_cat.ws_tcow_value;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_800';
				IF csr_salary.Steering_Code_800 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_800); --csr_cat.ws_tcow_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_800; --csr_cat.ws_tcow_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_800';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_800); --csr_cat.ws_tcow_value;
				l_counter:=l_counter+1;

			END IF;
			xml_tab(l_counter).TagName  :='STEERING_CODE_801';
			xml_tab(l_counter).TagValue :='801'; --csr_cat.ws_nha_value;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_801';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_801,2); --csr_cat.ws_nha_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_801';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_801,2); --csr_cat.ws_nha_value;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_801';
				IF csr_salary.Steering_Code_801 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_801); --csr_cat.ws_nha_value;
				ELSE
					xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_801,2); --csr_cat.ws_nha_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_801';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_801); --csr_cat.ws_nha_value;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_802';
			xml_tab(l_counter).TagValue :='802'; --csr_cat.ws_nho_value;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_802';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_802,2); --csr_cat.ws_nho_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_802';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_802,2); --csr_cat.ws_nho_value;
				l_counter:=l_counter+1;

			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_802';
				IF csr_salary.Steering_Code_802 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_802); --csr_cat.ws_nho_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_802; --csr_cat.ws_nho_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_802';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_802); --csr_cat.ws_nho_value;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_803';
			xml_tab(l_counter).TagValue :='803'; --csr_cat.ws_retroactive_pay;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_803';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_803,2); --csr_cat.ws_retroactive_pay;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_803';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_803,2); --csr_cat.ws_retroactive_pay;
				l_counter:=l_counter+1;

			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_803';
				IF csr_salary.Steering_Code_803 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_803); --csr_cat.ws_retroactive_pay;
				ELSE
				        xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_803; --csr_cat.ws_retroactive_pay;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_803';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_803); --csr_cat.ws_retroactive_pay;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_804';
			xml_tab(l_counter).TagValue :='804'; --csr_cat.ws_ppo_value;
			l_counter:=l_counter+1;

			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_804';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_804,2); --csr_cat.ws_ppo_value;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_804';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_804,2); --csr_cat.ws_ppo_value;
				l_counter:=l_counter+1;

			ELSE
				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_804';
				IF csr_salary.Steering_Code_804 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_804); --csr_cat.ws_ppo_value;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_804; --csr_cat.ws_ppo_value;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_804';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_804); --csr_cat.ws_ppo_value;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_805';
			xml_tab(l_counter).TagValue :='805'; --csr_cat.ws_sick_pay;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_805';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_805,2); --csr_cat.ws_sick_pay;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_805';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_805,2); --csr_cat.ws_sick_pay;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_805';
				IF csr_salary.Steering_Code_804 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_805); --csr_cat.ws_sick_pay;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_805; --csr_cat.ws_sick_pay;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_805';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_805); --csr_cat.ws_sick_pay;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_806';
			xml_tab(l_counter).TagValue :='806'; --csr_cat.ws_total_employees;
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_806';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_806,2); --csr_cat.ws_total_employees;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_806';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_806,2); --csr_cat.ws_total_employees;
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_806';
				IF csr_salary.Steering_Code_806 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_806); --csr_cat.ws_total_employees;
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_806; --csr_cat.ws_total_employees;
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_806';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_806); --csr_cat.ws_total_employees;
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='STEERING_CODE_808';
			xml_tab(l_counter).TagValue :='808'; --round(csr_cat.wh_full_time_employee,2);
			l_counter:=l_counter+1;
			IF  csr_salary.Salary_Type=3 THEN

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_808';
				xml_tab(l_counter).TagValue :=round(csr_salary.Steering_Code_808,2); --round(csr_cat.wh_full_time_employee,2);
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_808';
				xml_tab(l_counter).TagValue :=100*round(csr_salary.Steering_Code_808,2); --round(csr_cat.wh_full_time_employee,2);
				l_counter:=l_counter+1;

			ELSE

				xml_tab(l_counter).TagName  :='STEERING_CODE_VALUE_808';
				IF csr_salary.Steering_Code_808 > 0 THEN
					xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_808); --round(csr_cat.wh_full_time_employee,2);
				ELSE
					xml_tab(l_counter).TagValue :=csr_salary.Steering_Code_808; --round(csr_cat.wh_full_time_employee,2);
				END IF;
				l_counter:=l_counter+1;

				xml_tab(l_counter).TagName  :='STEERING_VALUE_808';
				xml_tab(l_counter).TagValue :=ceil(csr_salary.Steering_Code_808); --round(csr_cat.wh_full_time_employee,2);
				l_counter:=l_counter+1;

			END IF;

			xml_tab(l_counter).TagName  :='SSST_DETAILS';
			xml_tab(l_counter).TagValue :='END_SSST_DETAILS';
			l_counter := l_counter + 1;

			l_worksite_number:=NULL;
			l_association_number:=NULL;
			l_weekend_pay_duty:=NULL;


	 END LOOP;



        WritetoCLOB (p_xml );
	--INSERT INTO raaj VALUES (p_xml);
--       fnd_file.put_line(fnd_file.LOG,'p_xml'||p_xml);


END POPULATE_DATA_DETAIL;

END PAY_SE_SALARY_STRUCTURE_STATS;


/
