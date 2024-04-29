--------------------------------------------------------
--  DDL for Package Body PAY_SE_ARCHIVE_CWCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ARCHIVE_CWCA" AS
/* $Header: pysecwca.pkb 120.0.12010000.4 2010/01/12 10:04:12 vijranga ship $ */
   g_debug                   BOOLEAN        := hr_utility.debug_enabled;

   g_index                   NUMBER         := -1;
   g_index_assact            NUMBER         := -1;
   g_index_bal               NUMBER         := -1;
   g_package                 VARCHAR2 (240) := 'PAY_SE_ARCHIVE_CWCA.';
   g_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;

   -- Globals to pick up all th parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_person_id               NUMBER;
   g_assignment_id           NUMBER;
   g_still_employed          VARCHAR2 (10);
   g_report_start_year      VARCHAR2 (10);
   g_report_start_month      VARCHAR2 (10);

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
     ,p_report_start_year        OUT NOCOPY VARCHAR2         -- User parameter
     ,p_report_start_month       OUT NOCOPY VARCHAR2         -- User parameter
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT (PAY_SE_ARCHIVE_CWCA.get_parameter
                                                      (legislative_parameters
                                                      ,'PERSON_ID'
                                                      )
                ) person_id
               , (PAY_SE_ARCHIVE_CWCA.get_parameter
                                                      (legislative_parameters
                                                      ,'ASSIGNMENT_ID'
                                                      )
                 ) assignment_id
               , (PAY_SE_ARCHIVE_CWCA.get_parameter
                                                      (legislative_parameters
                                                      ,'STILL_EMPLOYED'
                                                      )
                 ) still_employed
               , (PAY_SE_ARCHIVE_CWCA.get_parameter
                                                      (legislative_parameters
                                                      ,'REPORT_YEAR'
                                                      )
                 ) report_year
		, (PAY_SE_ARCHIVE_CWCA.get_parameter
                                                      (legislative_parameters
                                                      ,'REPORT_MONTH'
                                                      )
                 ) report_month
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
      p_report_start_year := lr_parameter_info.report_year;
      --logger ('lr_parameter_info.report_year '             ,lr_parameter_info.report_year             );
      p_report_start_month := lr_parameter_info.report_month;
      --logger ('lr_parameter_info.report_month '             ,lr_parameter_info.report_month             );
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
      l_person_number                VARCHAR2 (100);
      l_last_name                    per_all_people_f.last_name%TYPE;
      l_first_name                   per_all_people_f.first_name%TYPE;

      l_local_unit_id                NUMBER;
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
	l_oth_comp		NUMBER;
	bname		              VARCHAR2 (100);
	l_month	              VARCHAR2 (2);
	l_year	              VARCHAR2 (4);
	l_reporting_date	DATE;
	l_tot_addl_time_hw	NUMBER;
	l_tot_relief_duty_hours	NUMBER;
	l_tot_relief_duty_hw	NUMBER;
	l_tot_overtime_hours	NUMBER;
	l_tot_overtime_hw	NUMBER;
	l_tot_addl_time_hours	NUMBER;
	l_addl_time_hw	        NUMBER;
	l_relief_duty_hours	NUMBER;
	l_relief_duty_hw	NUMBER;
	l_overtime_hours	NUMBER;
	l_overtime_hw	        NUMBER;
	l_addl_time_hours	NUMBER;
	l_legal_employer_id	NUMBER;
	l_dimension	              VARCHAR2 (100);
	l_report_start_date	DATE;
	l_report_end_date	DATE;
	l_asg_effective_start_date DATE;
	l_asg_effective_end_date DATE;


      l_get_defined_balance_id       NUMBER;
      l_count                        NUMBER;
      l_hourly_pay_variable          VARCHAR(4);    -- EOY 2008
      l_other_tax_compensation       VARCHAR(4);    -- EOY 2008
      l_overtime_mw                  NUMBER;        -- EOY 2008
      l_addl_time_mw                 NUMBER;        -- EOY 2008
      l_relief_duty_mw               NUMBER;        -- EOY 2008
      l_tot_relief_duty_mw           NUMBER;        -- EOY 2008
      count_months                   NUMBER;        -- EOY 2008
      l_days_worked                  VARCHAR(10);   -- EOY 2008
      l_artistic_work                VARCHAR(10);   -- EOY 2008

      l_sick_pay_hours               NUMBER;        -- Bug# 9222739 fix
      l_sick_pay                     NUMBER;        -- Bug# 9222739 fix

-- *****************************************************************************
-- CURSOR

/* Cursor to retrieve Balance Types having a particular Balance Category */

	CURSOR csr_asg_effective_date (
         p_asg_id              number,
         p_end_date            date,
         p_start_date          date,
         p_business_group_id   number
	) IS
	SELECT MAX (effective_end_date) effective_date
	FROM per_all_assignments_f paa
	WHERE assignment_id = p_asg_id
	AND paa.effective_start_date <= p_end_date
	AND paa.effective_end_date > = p_start_date
	AND assignment_status_type_id
		IN
		(SELECT assignment_status_type_id
		FROM per_assignment_status_types
		WHERE per_system_status = 'ACTIVE_ASSIGN'
		AND active_flag = 'Y'
		AND ((legislation_code is null and business_group_id is null)
		OR (business_group_id = p_business_group_id)
		));

	lr_asg_effective_date             csr_asg_effective_date%ROWTYPE;

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


      CURSOR csr_soft_coded_keyflex_info (
         csr_v_soft_coding_keyflex_id        hr_soft_coding_keyflex.soft_coding_keyflex_id%TYPE
      )
      IS
         SELECT *
           FROM hr_soft_coding_keyflex
          WHERE soft_coding_keyflex_id = csr_v_soft_coding_keyflex_id;

      lr_soft_coded_keyflex_info     csr_soft_coded_keyflex_info%ROWTYPE;



-- Cursor to extract the hourly pay variables in the Completion Working report


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
        ,csr_v_year                          per_assignment_extra_info.aei_information2%TYPE
        ,csr_v_month                          per_assignment_extra_info.aei_information3%TYPE
      )
      IS
         SELECT *
           FROM per_assignment_extra_info
          WHERE assignment_id = csr_v_assignment_id
            AND information_type = 'SE_WTC_TIME_WORKED_INFO'
            AND aei_information1 = csr_v_year
	    AND aei_information2 = csr_v_month;

    lr_se_wtc_time_worked_info       csr_se_wtc_time_worked_info%ROWTYPE;
   -- Archiving the data , as this will fire once
-- *****************************************************************************
-- *****************************************************************************
   BEGIN


-- *****************************************************************************
	IF g_debug THEN
		hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
	END IF;

-- *****************************************************************************


	g_payroll_action_id := p_payroll_action_id;
	g_business_group_id := NULL;
	g_effective_date := NULL;
	g_person_id := NULL;
	g_assignment_id := NULL;

	PAY_SE_ARCHIVE_CWCA.get_all_parameters (p_payroll_action_id
                                                      ,g_business_group_id
                                                      ,g_effective_date
                                                      ,g_person_id
                                                      ,g_assignment_id
                                                      ,g_still_employed
                                                      ,g_report_start_year
						      ,g_report_start_month
                                                      );
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
--START OF PICKING UP DATA

	l_report_start_date := TO_DATE('01/'||g_report_start_month||'/'||g_report_start_year,'DD/MM/YYYY');

fnd_file.put_line (fnd_file.LOG, 'g_assignment_id'||g_assignment_id);
fnd_file.put_line (fnd_file.LOG, 'l_report_end_date'||to_char(l_report_end_date));
fnd_file.put_line (fnd_file.LOG, 'l_report_start_date'||to_char(l_report_start_date));
fnd_file.put_line (fnd_file.LOG, 'g_business_group_id'||to_char(g_business_group_id));


	OPEN csr_asg_effective_date ( g_assignment_id, g_effective_date , l_report_start_date, g_business_group_id);
	FETCH csr_asg_effective_date INTO lr_asg_effective_date;
	CLOSE csr_asg_effective_date;

	l_asg_effective_end_date := lr_asg_effective_date.effective_date;

	IF l_asg_effective_end_date <= l_report_end_date THEN

		SELECT LAST_DAY(l_asg_effective_end_date)
		INTO l_report_end_date
		FROM DUAL;
	ELSE

		SELECT LAST_DAY(g_effective_date)
		INTO l_report_end_date
		FROM DUAL;

	END IF;

       fnd_file.put_line (fnd_file.LOG, 'l_report_end_date'||to_char(l_report_end_date));

	IF lr_asg_effective_date.effective_date IS NOT NULL THEN


	l_tot_addl_time_hw	:=0;
	l_tot_relief_duty_hours :=0;
	l_tot_relief_duty_hw	:=0;
	l_tot_overtime_hours	:=0;
	l_tot_overtime_hw	:=0;
	l_tot_addl_time_hours	:=0;
	l_addl_time_hw	        :=0;
	l_relief_duty_hours	:=0;
	l_relief_duty_hw	:=0;
	l_overtime_hours	:=0;
	l_overtime_hw	        :=0;
	l_addl_time_hours	:=0;
	l_relief_duty_mw        :=0;
	l_tot_relief_duty_mw    :=0;

	l_sick_pay_hours   := 0; -- Bug# 9222739 fix
	l_sick_pay         := 0; -- Bug# 9222739 fix



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
		,p_action_information1              => 'PYSECWCA'
		,p_action_information2              => g_person_id
		,p_action_information3              => g_assignment_id
		,p_action_information4              => g_still_employed
		,p_action_information5              => g_business_group_id
		,p_action_information6              => g_report_start_year
		,p_action_information7              => g_report_start_month
		,p_action_information8              => NULL
		,p_action_information9              => NULL
		,p_action_information10             => NULL
		);


	      OPEN csr_person_info (g_person_id, lr_asg_effective_date.effective_date);
	      FETCH csr_person_info INTO lr_person_info;
	      CLOSE csr_person_info;

	      l_person_number := lr_person_info.national_identifier;
	      l_last_name := lr_person_info.last_name;
	      l_first_name := lr_person_info.first_name;

		OPEN csr_assignment_info (g_person_id, g_assignment_id, lr_asg_effective_date.effective_date);
		FETCH csr_assignment_info INTO lr_assignment_info;
		CLOSE csr_assignment_info;
		l_soft_coding_keyflex_id := lr_assignment_info.soft_coding_keyflex_id;

		l_asg_effective_start_date := lr_assignment_info.effective_start_date;

		-- *****************************************************************************
		-- SOFT CODED FLEX
		OPEN csr_soft_coded_keyflex_info (l_soft_coding_keyflex_id);
		FETCH csr_soft_coded_keyflex_info INTO lr_soft_coded_keyflex_info;
		CLOSE csr_soft_coded_keyflex_info;

		l_local_unit_id := lr_soft_coded_keyflex_info.segment2;
		-- *****************************************************************************
		-- *****************************************************************************
		-- Legal Employer Details
		OPEN csr_legal_employer_details (l_local_unit_id);
		FETCH csr_legal_employer_details INTO lr_legal_employer_details;
		CLOSE csr_legal_employer_details;

		l_legal_employer_name := lr_legal_employer_details.NAME;
		l_org_number := lr_legal_employer_details.org_number;
		l_location_id := lr_legal_employer_details.location_id;
		l_legal_employer_id := lr_legal_employer_details.organization_id;

		-- Employer and Signature
		OPEN csr_contact_details (lr_legal_employer_details.organization_id);
		FETCH csr_contact_details INTO lr_contact_details;
		CLOSE csr_contact_details;

		l_phone_number := lr_contact_details.org_information3;

		OPEN csr_address_details (l_location_id);
		FETCH csr_address_details INTO lr_address_details;
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

		pay_action_information_api.create_action_information
		(p_action_information_id            => l_action_info_id
		,p_action_context_id                => p_payroll_action_id
		,p_action_context_type              => 'PA'
		,p_object_version_number            => l_ovn
		,p_effective_date                   => g_effective_date
		,p_source_id                        => NULL
		,p_source_text                      => NULL
		,p_action_information_category      => 'EMEA REPORT INFORMATION'
		,p_action_information1              => 'PYSECWCA'
		,p_action_information2              => 'CWC1'
		,p_action_information3              => l_person_number
		,p_action_information4              => l_last_name
		,p_action_information5              => l_first_name
		,p_action_information6              => l_legal_employer_name
		,p_action_information7              => l_org_number
		,p_action_information8             => l_location_code
                ,p_action_information9             => l_address_line_1
                ,p_action_information10             => l_address_line_2
                ,p_action_information11             => l_address_line_3
                ,p_action_information12             => l_postal_code
                ,p_action_information13             => l_town_or_city
		,p_action_information14             => l_region_1
		,p_action_information15             => l_region_2
		,p_action_information16             => l_territory_short_name
		,p_action_information17             => l_phone_number
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
		,p_action_information28             => NULL
		,p_action_information29             => NULL
		,p_action_information30             => g_person_id
		,p_assignment_id			 => g_assignment_id
		);

		l_dimension:='_ASG_LE_MONTH';


		/* Setting Context */
		BEGIN
			pay_balance_pkg.set_context('ASSIGNMENT_ID',g_assignment_id);
			pay_balance_pkg.set_context('TAX_UNIT_ID',l_legal_employer_id);
		END;


--- Check for Artistic Work

		lr_extra_assignment_info := NULL;

		OPEN csr_extra_assignment_info (g_assignment_id
                                     ,'SE_WTC_TIME_WORKED_HEADER'
                                     );

		FETCH csr_extra_assignment_info
		INTO lr_extra_assignment_info;

		CLOSE csr_extra_assignment_info;

                l_artistic_work :=  lr_extra_assignment_info.aei_information6;


--- Display only 26 months

                count_months := 1;

		WHILE l_report_start_date <= l_report_end_date AND count_months < 27

                --WHILE l_report_start_date <= l_report_end_date

		--FOR i IN 1..12
		LOOP

			--SELECT last_day(l_report_start_date), LPAD(TO_CHAR(l_report_start_date,'MM'), 2,'0'),TO_CHAR(l_report_start_date,'YYYY')
			--INTO l_reporting_date, l_month, l_year
			--FROM DUAL;

			SELECT last_day(l_report_end_date), LPAD(TO_CHAR(l_report_end_date,'MM'), 2,'0'),TO_CHAR(l_report_end_date,'YYYY')
			INTO l_reporting_date, l_month, l_year
			FROM DUAL;

			IF l_artistic_work = 'Y'
			THEN
				OPEN csr_se_wtc_time_worked_info (g_assignment_id,l_year,l_month);
		                FETCH csr_se_wtc_time_worked_info INTO lr_se_wtc_time_worked_info;
		                CLOSE csr_se_wtc_time_worked_info;
			        l_days_worked := lr_se_wtc_time_worked_info.aei_information3;
                        END IF;

                 --        fnd_file.put_line (fnd_file.LOG, 'l_days_worked'||l_days_worked);

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

			EXCEPTION
				WHEN others THEN
				fnd_file.put_line (fnd_file.LOG, 'Error'||substr(sqlerrm,1,30));
				null;
			END;
			l_addl_time_hw :=0;
			l_tot_addl_time_hw :=0;
			BEGIN
				FOR     balance_rec IN  csr_balance('Additional Time - Hourly Wages' , g_business_group_id)
				LOOP
					OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
					FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
					CLOSE csr_bg_Get_Defined_Balance_Id;
					IF  csr_balance%FOUND THEN
						l_addl_time_hw :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
						l_tot_addl_time_hw := l_tot_addl_time_hw + nvl(l_addl_time_hw,0);
					END IF;
				END LOOP ;

			EXCEPTION
				WHEN others THEN
				null;
			END;
			l_relief_duty_hours :=0;
			l_tot_relief_duty_hours :=0;
			BEGIN
				FOR     balance_rec IN  csr_balance('Relief/ Duty - Hours' , g_business_group_id)
				LOOP
					OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
					FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
					CLOSE csr_bg_Get_Defined_Balance_Id;
					IF  csr_balance%FOUND THEN
						l_relief_duty_hours :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
						l_tot_relief_duty_hours := l_tot_relief_duty_hours + nvl(l_relief_duty_hours,0);
					END IF;
				END LOOP ;

		--		fnd_file.put_line (fnd_file.LOG, 'l_tot_relief_duty_hours'||l_tot_relief_duty_hours);

			EXCEPTION
				WHEN others THEN
				null;
			END;

			l_relief_duty_hw :=0;
			l_tot_relief_duty_hw :=0;
			BEGIN
				FOR     balance_rec IN  csr_balance('Relief/ Duty - Hourly Wages' , g_business_group_id)
				LOOP
					OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
					FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
					CLOSE csr_bg_Get_Defined_Balance_Id;
					IF  csr_balance%FOUND THEN
						l_relief_duty_hw :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
						l_tot_relief_duty_hw := l_tot_relief_duty_hw + nvl(l_relief_duty_hw,0);
					END IF;
				END LOOP ;

			EXCEPTION
				WHEN others THEN
				null;
			END;


                        l_relief_duty_mw :=0;
			l_tot_relief_duty_mw :=0;
			BEGIN
				FOR     balance_rec IN  csr_balance('Relief/ Duty - Monthly Wages' , g_business_group_id)
				LOOP
					OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
					FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
					CLOSE csr_bg_Get_Defined_Balance_Id;
					IF  csr_balance%FOUND THEN
						l_relief_duty_mw :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
						l_tot_relief_duty_mw := l_tot_relief_duty_mw + nvl(l_relief_duty_mw,0);
					END IF;
				END LOOP ;

			EXCEPTION
				WHEN others THEN
				null;
			END;

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

			EXCEPTION
				WHEN others THEN
				null;
			END;
			l_overtime_hw :=0;
			l_tot_overtime_hw:=0;
			BEGIN
				FOR     balance_rec IN  csr_balance('Overtime - Hourly Wages' , g_business_group_id)
				LOOP
					OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
					FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
					CLOSE csr_bg_Get_Defined_Balance_Id;
					IF  csr_balance%FOUND THEN
						l_overtime_hw :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
						l_tot_overtime_hw := l_tot_overtime_hw + nvl(l_overtime_hw,0);
					END IF;
				END LOOP ;

			EXCEPTION
				WHEN others THEN
				null;
			END;

			pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                  ,p_action_context_id                => p_payroll_action_id
                  ,p_action_context_type              => 'PA'
                  ,p_object_version_number            => l_ovn
                  ,p_effective_date                   => g_effective_date
                  ,p_source_id                        => NULL
                  ,p_source_text                      => NULL
                  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
                  ,p_action_information1              => 'PYSECWCA'
                  ,p_action_information2              => 'CWC2'
                  ,p_action_information3              => l_month
                  ,p_action_information4              => l_tot_addl_time_hw
                  ,p_action_information5              => l_tot_relief_duty_hours
                  ,p_action_information6              => l_tot_relief_duty_hw
                  ,p_action_information7              => l_tot_overtime_hours
                  ,p_action_information8              => l_tot_overtime_hw
                  ,p_action_information9              => l_tot_addl_time_hours
                  ,p_action_information10             => l_year
                  ,p_action_information11             => l_tot_relief_duty_mw  -- EOY 2008
                  ,p_action_information12             => l_days_worked         -- EOY 2008
                  ,p_action_information13             => NULL
                  ,p_action_information14             => NULL
                  ,p_action_information15             => NULL
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
                  ,p_action_information28             => NULL
                  ,p_action_information29             => NULL
                  ,p_action_information30             => g_person_id
                  ,p_assignment_id			    => g_assignment_id
                  );


      			l_overtime_hw :=0;

---- Check for the Other Taxable Compensation Variable in the Working Time Certificate Report


                   --  Salary Information in Working Time Certificate of Section 12
		     -- has vaiable Other Compensation
		     -- Assignment EIT of Income Info has Other Compensation marked as 'YES'

                      OPEN csr_extra_assignment_info (g_assignment_id, 'SE_WTC_INCOME_INFO');



                     FETCH csr_extra_assignment_info
                     INTO lr_extra_assignment_info;

                     CLOSE csr_extra_assignment_info;

		    l_hourly_pay_variable := lr_extra_assignment_info.aei_information9;
                    l_other_tax_compensation := lr_extra_assignment_info.aei_information12;

-- fnd_file.put_line (fnd_file.LOG, 'l_other_tax_compensation'||l_other_tax_compensation);
--fnd_file.put_line (fnd_file.LOG, 'l_reporting_date'||l_reporting_date);


                    IF l_other_tax_compensation ='Y'
		    THEN
			l_oth_comp :=0;

			BEGIN
				FOR     balance_rec IN  csr_balance('Other Compensation' , g_business_group_id)
				LOOP

					OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
					FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
					CLOSE csr_bg_Get_Defined_Balance_Id;

					IF  csr_balance%FOUND THEN

						l_oth_comp :=0;
						l_oth_comp :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
--fnd_file.put_line (fnd_file.LOG, 'l_oth_comp' ||l_oth_comp);

						IF l_oth_comp > 0 THEN

							pay_action_information_api.create_action_information
							  (p_action_information_id            => l_action_info_id
							  ,p_action_context_id                => p_payroll_action_id
							  ,p_action_context_type              => 'PA'
							  ,p_object_version_number            => l_ovn
							  ,p_effective_date                   => g_effective_date
							  ,p_source_id                        => NULL
							  ,p_source_text                      => NULL
							  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
							  ,p_action_information1              => 'PYSECWCA'
							  ,p_action_information2              => 'CWC3'
							  ,p_action_information3              => l_month
							  ,p_action_information4              =>  balance_rec.bname
							  ,p_action_information5              => l_oth_comp
							  ,p_action_information6              => NULL
							  ,p_action_information7              => NULL
							  ,p_action_information8              => NULL
							  ,p_action_information9              => NULL
							  ,p_action_information10             => l_year
							  ,p_action_information11             => NULL
							  ,p_action_information12             => NULL
							  ,p_action_information13             => NULL
							  ,p_action_information14             => NULL
							  ,p_action_information15             => NULL
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
							  ,p_action_information28             => NULL
							  ,p_action_information29             => NULL
							  ,p_action_information30             => g_person_id
							  ,p_assignment_id			    => g_assignment_id
							  );

						  END IF;

					END IF;
				END LOOP ;

				-- Bug# 9222739 fix starts

				fnd_file.put_line (fnd_file.LOG, '$$$ l_reporting_date'||l_reporting_date);
				fnd_file.put_line (fnd_file.LOG, '$$$ l_month'||l_month);

				l_sick_pay_hours := GET_DEFINED_BALANCE_VALUE(g_assignment_id, 'Total Sick Pay Hours','_ASG_LE_MONTH',l_reporting_date);
				l_sick_pay       := GET_DEFINED_BALANCE_VALUE(g_assignment_id, 'Total Sick Pay','_ASG_LE_MONTH',l_reporting_date);
				fnd_file.put_line (fnd_file.LOG, '$$$ l_sick_pay_hours'||l_sick_pay_hours);
				fnd_file.put_line (fnd_file.LOG, '$$$ l_sick_pay'||l_sick_pay);

				IF l_sick_pay_hours > 0 THEN
					pay_action_information_api.create_action_information
						(p_action_information_id            => l_action_info_id
				           	 ,p_action_context_id                => p_payroll_action_id
						 ,p_action_context_type              => 'PA'
						 ,p_object_version_number            => l_ovn
						 ,p_effective_date                   => g_effective_date
						 ,p_source_id                        => NULL
						 ,p_source_text                      => NULL
						 ,p_action_information_category      => 'EMEA REPORT INFORMATION'
						 ,p_action_information1              => 'PYSECWCA'
						 ,p_action_information2              => 'CWC6'
						 ,p_action_information3              => l_month
						 ,p_action_information4              => l_sick_pay_hours
						 ,p_action_information5              => l_sick_pay
						 ,p_action_information6              => NULL
						 ,p_action_information7              => NULL
						 ,p_action_information8              => NULL
						 ,p_action_information9              => NULL
						 ,p_action_information10             => l_year
						 ,p_action_information11             => NULL
						 ,p_action_information12             => NULL
						 ,p_action_information13             => NULL
						 ,p_action_information14             => NULL
						 ,p_action_information15             => NULL
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
						 ,p_action_information28             => NULL
						 ,p_action_information29             => NULL
						 ,p_action_information30             => g_person_id
						 ,p_assignment_id		     => g_assignment_id
						);

				END IF;
				-- Bug# 9222739 fix ends

			EXCEPTION
				WHEN others THEN
				fnd_file.put_line (fnd_file.LOG, 'Error in Other Compensation'||substr(sqlerrm,1,30));
			END;

		     END IF; --- End of Validation for Other Tax Compensation in Assignment EIT



----- If the Over Time and Additional Pay are Variables then we insert the following cases...


		     --  Salary Information in Working Time Certificate of Section 12
		     -- has vaiable Additional and Overtime Pay
		     -- Assignment EIT of Income Info has Hourly Pay Variable marked as 'YES'

--fnd_file.put_line (fnd_file.LOG, 'l_hourly_pay_variable'||l_hourly_pay_variable);

                 IF l_hourly_pay_variable = 'Y'
		 THEN

                       l_overtime_mw :=0;

		       BEGIN

			FOR     balance_rec IN  csr_balance('Overtime - Monthly Wages' , g_business_group_id)
			LOOP

				OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
				FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
				CLOSE csr_bg_Get_Defined_Balance_Id;

				IF  csr_balance%FOUND THEN
				l_overtime_mw := 0;
				l_overtime_mw :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
--fnd_file.put_line (fnd_file.LOG, 'l_overtime_mw' ||l_overtime_mw);
     					IF l_overtime_mw > 0 THEN

							pay_action_information_api.create_action_information
							  (p_action_information_id            => l_action_info_id
							  ,p_action_context_id                => p_payroll_action_id
							  ,p_action_context_type              => 'PA'
							  ,p_object_version_number            => l_ovn
							  ,p_effective_date                   => g_effective_date
							  ,p_source_id                        => NULL
							  ,p_source_text                      => NULL
							  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
							  ,p_action_information1              => 'PYSECWCA'
							  ,p_action_information2              => 'CWC4'
							  ,p_action_information3              => l_month
							  ,p_action_information4              =>  balance_rec.bname
							  ,p_action_information5              => l_overtime_mw
							  ,p_action_information6              => NULL
							  ,p_action_information7              => NULL
							  ,p_action_information8              => NULL
							  ,p_action_information9              => NULL
							  ,p_action_information10             => l_year
							  ,p_action_information11             => NULL
							  ,p_action_information12             => NULL
							  ,p_action_information13             => NULL
							  ,p_action_information14             => NULL
							  ,p_action_information15             => NULL
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
							  ,p_action_information28             => NULL
							  ,p_action_information29             => NULL
							  ,p_action_information30             => g_person_id
							  ,p_assignment_id			    => g_assignment_id
							  );

						  END IF;

					END IF;
				END LOOP ;


			EXCEPTION
				WHEN others THEN
				fnd_file.put_line (fnd_file.LOG, 'Error in Overtime'||substr(sqlerrm,1,30));
			END;  -- End of Begin for Overtime Variable Pay


------------------------------------Additional/Supplementary hours - if variable ---




                       BEGIN
			l_addl_time_mw :=0;

			FOR     balance_rec IN  csr_balance('Additional Time -Monthly Wages' , g_business_group_id)
			LOOP

				OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension,g_business_group_id);
				FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
				CLOSE csr_bg_Get_Defined_Balance_Id;
--fnd_file.put_line (fnd_file.LOG, 'check_addtional' ||l_addl_time_mw);

				IF  csr_balance%FOUND THEN

					l_addl_time_mw :=0;
					l_addl_time_mw :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ID =>g_assignment_id, P_VIRTUAL_DATE =>l_reporting_date ) ;
--fnd_file.put_line (fnd_file.LOG, 'l_addl_time_mw' ||l_addl_time_mw);
     					IF l_addl_time_mw > 0 THEN

							pay_action_information_api.create_action_information
							  (p_action_information_id            => l_action_info_id
							  ,p_action_context_id                => p_payroll_action_id
							  ,p_action_context_type              => 'PA'
							  ,p_object_version_number            => l_ovn
							  ,p_effective_date                   => g_effective_date
							  ,p_source_id                        => NULL
							  ,p_source_text                      => NULL
							  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
							  ,p_action_information1              => 'PYSECWCA'
							  ,p_action_information2              => 'CWC5'
							  ,p_action_information3              => l_month
							  ,p_action_information4              =>  balance_rec.bname
							  ,p_action_information5              => l_addl_time_mw
							  ,p_action_information6              => NULL
							  ,p_action_information7              => NULL
							  ,p_action_information8              => NULL
							  ,p_action_information9              => NULL
							  ,p_action_information10             => l_year
							  ,p_action_information11             => NULL
							  ,p_action_information12             => NULL
							  ,p_action_information13             => NULL
							  ,p_action_information14             => NULL
							  ,p_action_information15             => NULL
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
							  ,p_action_information28             => NULL
							  ,p_action_information29             => NULL
							  ,p_action_information30             => g_person_id
							  ,p_assignment_id			    => g_assignment_id
							  );

						  END IF;

					END IF;
				END LOOP ;


				EXCEPTION
					WHEN others THEN
				fnd_file.put_line (fnd_file.LOG, 'Error in Additional'||substr(sqlerrm,1,30));
				END;  -- End of Begin for Additional Time monthly Wage

			END IF;   --- End of IF condition for hourly pay variable

                        --l_report_start_date := ADD_MONTHS(l_report_start_date,1);
			l_report_end_date := ADD_MONTHS(l_report_end_date,-1);
			count_months := count_months + 1;

		END LOOP;

	END IF;

	IF g_debug   THEN
		hr_utility.set_location (' Leaving Procedure RANGE_CODE', 50);
	END IF;
EXCEPTION
WHEN OTHERS THEN
         -- Return cursor that selects no rows
         p_sql :=
               'select 1 from dual where to_char(:payroll_action_id) = dummy';
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

	     IF g_debug THEN
		      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
		 END IF;

	    	  IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
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

   PROCEDURE DEINITIALIZATION_CODE
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type) is

BEGIN
	 IF g_debug THEN
		hr_utility.set_location(' Entering Procedure DEINITIALIZATION_CODE',380);
	 END IF;

	IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure DEINITIALIZATION_CODE',390);
	END IF;

EXCEPTION
  WHEN others THEN
	IF g_debug THEN
	    hr_utility.set_location('error raised in DEINITIALIZATION_CODE ',5);
	END if;
    RAISE;
 END;

-- Bug# 9222739 fix starts
FUNCTION GET_DEFINED_BALANCE_VALUE
  (p_assignment_id              IN NUMBER
  ,p_balance_name               IN VARCHAR2
  ,p_balance_dim                IN VARCHAR2
  ,p_virtual_date               IN DATE) RETURN NUMBER IS

  l_context1 PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
  l_value    NUMBER;


  CURSOR get_dbal_id(p_balance_name VARCHAR2 , p_balance_dim VARCHAR2) IS
  SELECT pdb.defined_balance_id
  FROM   pay_defined_balances  pdb
        ,pay_balance_types  pbt
        ,pay_balance_dimensions  pbd
  WHERE  pbt.legislation_code='SE'
  AND    pbt.balance_name = p_balance_name
  AND    pbd.legislation_code = 'SE'
  AND    pbd.database_item_suffix = p_balance_dim
  AND    pdb.balance_type_id = pbt.balance_type_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id;

BEGIN

  OPEN get_dbal_id(p_balance_name, p_balance_dim);
  FETCH get_dbal_id INTO l_context1;
  CLOSE get_dbal_id;

  l_value := nvl(pay_balance_pkg.get_value(l_context1,p_assignment_id,p_virtual_date), 0);

  RETURN l_value;

END GET_DEFINED_BALANCE_VALUE ;

-- Bug# 9222739 fix ends

END PAY_SE_ARCHIVE_CWCA;

/
