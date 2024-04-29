--------------------------------------------------------
--  DDL for Package Body PAY_SE_STAT_OFFICE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_STAT_OFFICE_ARCHIVE" AS
 /* $Header: pysestoa.pkb 120.0.12010000.2 2009/09/24 11:41:18 vijranga ship $ */
 --
 --
 -- -----------------------------------------------------------------------------
 -- Data types.
 -- -----------------------------------------------------------------------------
 --
 g_business_group_id  NUMBER;
 g_legal_employer_id  NUMBER;
 g_report_date        DATE;
 g_effective_date     DATE;
 g_archive            VARCHAR2(30);
 g_debug   boolean   :=  hr_utility.debug_enabled;
 g_payroll_action_id NUMBER;
 g_package            VARCHAR2(30) := 'pay_se_stat_office_archive.';
 g_version VARCHAR2(10);
 g_start_date DATE;
 g_end_date DATE;

 --
 --
 -- -----------------------------------------------------------------------------
 -- Parse out parameters from string.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_parameter
 (p_parameter_string IN VARCHAR2
 ,p_token            IN VARCHAR) RETURN VARCHAR2 IS
  --
  l_parameter pay_payroll_actions.legislative_parameters%TYPE := NULL;
  l_start_pos NUMBER;
  l_delimiter VARCHAR2(1) := ' ';
  --
 BEGIN
  --
  l_start_pos := INSTR(' ' || p_parameter_string, l_delimiter || p_token || '=');
  --
  IF l_start_pos = 0 THEN
   l_delimiter := '|';
   l_start_pos := INSTR(' ' || p_parameter_string, l_delimiter || p_token || '=');
  END IF;
  --
  IF l_start_pos <> 0 THEN
   l_start_pos := l_start_pos + LENGTH(p_token || '=');
   l_parameter := SUBSTR(p_parameter_string, l_start_pos, INSTR(p_parameter_string || ' ', l_delimiter, l_start_pos) - l_start_pos);
  END IF;
  --
  RETURN l_parameter;
  --
 END;
--
--
-- Get All Parameters
--
--
 PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id IN   NUMBER    			-- In parameter
       ,p_business_group_id OUT  NOCOPY NUMBER    		-- Core parameter
       ,p_effective_date    OUT  NOCOPY Date			-- Core parameter
       ,p_legal_employer_id OUT  NOCOPY NUMBER      		-- User parameter
       ,p_start_date        OUT  NOCOPY DATE                    -- User Parameter
       ,p_end_date          OUT  NOCOPY DATE                    -- User Parameter
       ,p_archive	    OUT  NOCOPY VARCHAR2  	        -- User parameter
       )
       IS

  CURSOR csr_parameter_info
    (p_payroll_action_id NUMBER) IS
  SELECT
    TO_NUMBER  ( GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER') ) Legal
    ,fnd_date.canonical_to_date(get_parameter(legislative_parameters,'START_DATE')) start_date
    ,fnd_date.canonical_to_date(get_parameter(legislative_parameters,'END_DATE')) end_date
    ,GET_PARAMETER(legislative_parameters,'ARCHIVE') ARCHIVE_OR_NOT
    ,business_group_id BG_ID
    ,effective_date
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;


    lr_parameter_info csr_parameter_info%ROWTYPE;
    l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';

 BEGIN
			OPEN csr_parameter_info (p_payroll_action_id);

							 FETCH csr_parameter_info
							 INTO	p_legal_employer_id
                                                                ,p_start_date
								,p_end_date
								,p_archive
								,p_business_group_id
                                                                ,p_effective_date;
			CLOSE csr_parameter_info;


            IF g_debug THEN
                hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
            END IF;
END GET_ALL_PARAMETERS;

 --
 --
 -- -----------------------------------------------------------------------------
 -- Sets all legislative parameters as global variables for future use.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE set_parameters
 (p_payroll_action_id IN NUMBER) IS
  --
  CURSOR csr_parameters
          (p_payroll_action_id IN NUMBER) IS
   SELECT business_group_id
         ,legislative_parameters
         ,get_parameter(legislative_parameters, 'LEGAL_EMPLOYER_ID') legal_employer_id
         ,fnd_date.canonical_to_date(get_parameter(legislative_parameters, 'DATE')) report_date
   FROM   pay_payroll_actions
   WHERE  payroll_action_id = p_payroll_action_id;
  --
  l_parameter_rec csr_parameters%ROWTYPE;
  --
 BEGIN
  --
  OPEN  csr_parameters(p_payroll_action_id);
  FETCH csr_parameters INTO l_parameter_rec;
  CLOSE csr_parameters;
  --
  g_business_group_id := l_parameter_rec.business_group_id;
  g_legal_employer_id := l_parameter_rec.legal_employer_id;
  g_report_date       := l_parameter_rec.report_date;
  --
 END set_parameters;
 --
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE range_code
 (p_payroll_action_id IN NUMBER
 ,p_sql               OUT NOCOPY VARCHAR2) IS
  --
  CURSOR csr_legal_employer_details
          (p_legal_employer_id IN NUMBER) IS
   SELECT org.organization_id legal_employer_id
         ,org.name
         ,hoi1.org_information2
         ,org.location_id
   FROM   hr_all_organization_units org
         ,hr_organization_information hoi1
   WHERE  org.organization_id              = p_legal_employer_id
     AND  hoi1.organization_id (+)         = org.organization_id
     AND  hoi1.org_information_context (+) = 'SE_LEGAL_EMPLOYER_DETAILS';

  CURSOR csr_location
          (p_location_id NUMBER) IS
  SELECT rpad(Address_line_1 || ', ' || Address_line_2 ||', ' ||Address_line_3,30,' ') address,
         hr_general.DECODE_FND_COMM_LOOKUP('SE_POSTAL_CODE',postal_code) postal_code,
         hr_general.decode_territory (country) country
  FROM hr_locations
  WHERE location_id = p_location_id;

  CURSOR csr_le_contact_person
          (p_legal_employer_id IN NUMBER) IS
  SELECT substr(hoi.org_information3,1,25) contact_person
   FROM   hr_organization_information hoi
   WHERE  hoi.organization_id          = p_legal_employer_id
     AND  hoi.org_information_context  = 'SE_ORG_CONTACT_DETAILS';

  --
    l_legal_employer_details_rec csr_Legal_employer_details%ROWTYPE;
    l_location_rec               csr_location%ROWTYPE;
    l_le_contact_person_rec      csr_le_contact_person%ROWTYPE;
  --
    l_assact_id  NUMBER;
    l_ovn        NUMBER;
    l_action_info_id NUMBER;

 BEGIN
  --
  --
  -- Setup legislative parameters as global values for future use.
  --
  set_parameters(p_payroll_action_id);
  --
  --
  -- Archive report information.
  --
  --
         IF g_debug THEN
              hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
         END IF;

         p_sql := 'SELECT DISTINCT person_id
         	FROM  per_people_f ppf
         	     ,pay_payroll_actions ppa
         	WHERE ppa.payroll_action_id = :payroll_action_id
         	AND   ppa.business_group_id = ppf.business_group_id
         	ORDER BY ppf.person_id';

        g_payroll_action_id :=p_payroll_action_id;
        g_business_group_id := null;
        g_legal_employer_id := null;
	g_start_date        := null;
        g_end_date          := null;
        g_version           := null;
        g_archive           := null;


        GET_ALL_PARAMETERS
                (p_payroll_action_id
       		,g_business_group_id
       		,g_effective_date
       		,g_legal_employer_id
		,g_start_date
                ,g_end_date
       		,g_archive
        );


        IF g_archive = 'Y'
        THEN


				       OPEN csr_legal_employer_details(g_legal_employer_id);
                                       FETCH csr_legal_employer_details INTO l_legal_employer_details_rec;
                                       CLOSE csr_legal_employer_details;


                                       pay_action_information_api.create_action_information (
                                          p_action_information_id=> l_action_info_id,
                                          p_action_context_id=> p_payroll_action_id,
                                          p_action_context_type=> 'PA',
                                          p_object_version_number=> l_ovn,
                                          p_effective_date=> g_effective_date,
                                          p_source_id=> NULL,
                                          p_source_text=> NULL,
                                          p_action_information_category=> 'EMEA REPORT DETAILS',
                                          p_action_information1=> 'PYSESTOA',
                                          p_action_information2=> to_char(g_business_group_id),
                                          p_action_information3=> to_char(g_legal_employer_id),
                                          p_action_information4=> l_legal_employer_details_rec.name,
                                          p_action_information5=> fnd_date.date_to_canonical(g_effective_date),
                                          p_action_information6=> fnd_date.date_to_canonical(g_start_date),
                                          p_action_information7=> fnd_date.date_to_canonical(g_end_date),
                                          p_action_information8=> NULL,
                                          p_action_information9=> NULL,
                                          p_action_information10=> NULL,
                                          p_action_information11=> NULL,
                                          p_action_information12=> NULL,
                                          p_action_information13=> NULL,
                                          p_action_information14=> NULL,
                                          p_action_information15=> NULL,
                                          p_action_information16=> NULL,
                                          p_action_information17=> NULL,
                                          p_action_information18=> NULL,
                                          p_action_information19=> NULL,
                                          p_action_information20=> NULL,
                                          p_action_information21=> NULL,
                                          p_action_information22=> NULL,
                                          p_action_information23=> NULL,
                                          p_action_information24=> NULL,
                                          p_action_information25=> NULL,
                                          p_action_information26=> NULL,
                                          p_action_information27=> NULL,
                                          p_action_information28=> NULL,
                                          p_action_information29=> NULL,
                                          p_action_information30=> NULL
                                       );


				       OPEN csr_location(l_legal_employer_details_rec.location_id);
                                       FETCH csr_location INTO l_location_rec;
                                       CLOSE csr_location;


				       OPEN csr_le_contact_person(g_legal_employer_id);
                                       FETCH csr_le_contact_person INTO l_le_contact_person_rec;
                                       CLOSE csr_le_contact_person;

                                       pay_action_information_api.create_action_information (
                                          p_action_information_id=> l_action_info_id,
                                          p_action_context_id=> p_payroll_action_id,
                                          p_action_context_type=> 'PA',
                                          p_object_version_number=> l_ovn,
                                          p_effective_date=> g_effective_date,
                                          p_source_id=> NULL,
                                          p_source_text=> NULL,
                                          p_action_information_category=> 'EMEA REPORT INFORMATION',
                                          p_action_information1=> 'PYSESTOA',
                                          p_action_information2=> 'LE',
                                          p_action_information3=> g_legal_employer_id,
                                          p_action_information4=> l_legal_employer_details_rec.name,
                                          p_action_information5=> l_legal_employer_details_rec.ORG_INFORMATION2,
                                          p_action_information6=> l_location_rec.address,
					  -- Bug#8849455 fix Added space between 3 and 4 digits in postal code
                                          p_action_information7=> substr(l_location_rec.postal_code,1,3)||' '||substr(l_location_rec.postal_code,4,2),
                                          p_action_information8=> l_location_rec.country,
                                          p_action_information9=> l_le_contact_person_rec.contact_person,
                                          p_action_information10=> NULL,
                                          p_action_information11=> NULL,
                                          p_action_information12=> NULL,
                                          p_action_information13=> NULL,
                                          p_action_information14=> NULL,
                                          p_action_information15=> NULL,
                                          p_action_information16=> NULL,
                                          p_action_information17=> NULL,
                                          p_action_information18=> NULL,
                                          p_action_information19=> NULL,
                                          p_action_information20=> NULL,
                                          p_action_information21=> NULL,
                                          p_action_information22=> NULL,
                                          p_action_information23=> NULL,
                                          p_action_information24=> NULL,
                                          p_action_information25=> NULL,
                                          p_action_information26=> NULL,
                                          p_action_information27=> NULL,
                                          p_action_information28=> NULL,
                                          p_action_information29=> NULL,
                                          p_action_information30=> NULL
                                       );


    END IF; -- G_Archive End

         IF g_debug THEN
              hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
         END IF;  --
 END range_code;
 --
 -- ---------------------------------------------------------------------
 -- Function to get defined balance id
 -- ---------------------------------------------------------------------
 --
 FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2) RETURN NUMBER
 IS
 /* Cursor to retrieve Defined Balance Id */

 CURSOR csr_def_bal_id
        (p_user_name VARCHAR2) IS
 SELECT  u.creator_id
 FROM    ff_user_entities  u,
 	 ff_database_items d
 WHERE   d.user_name = p_user_name
   AND   u.user_entity_id = d.user_entity_id
   AND   (u.legislation_code = 'NO' )
   AND   (u.business_group_id IS NULL )
   AND   u.creator_type = 'B';

 l_defined_balance_id ff_user_entities.user_entity_id%TYPE;

 BEGIN
 IF g_debug THEN
 	hr_utility.set_location(' Entering Function GET_DEFINED_BALANCE_ID',240);
 END IF;

 	OPEN csr_def_bal_id(p_user_name);
 		FETCH csr_def_bal_id INTO l_defined_balance_id;
 	CLOSE csr_def_bal_id;

 	RETURN l_defined_balance_id;

 IF g_debug THEN
  	hr_utility.set_location(' Leaving Function GET_DEFINED_BALANCE_ID',250);
  END IF;
 END GET_DEFINED_BALANCE_ID;


 --
 -- -----------------------------------------------------------------------------
 -- Create assignment actions for all assignments to be archived.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE assignment_action_code
 (p_payroll_action_id IN NUMBER
 ,p_start_person      IN NUMBER
 ,p_end_person        IN NUMBER
 ,p_chunk             IN NUMBER) IS
  --
  CURSOR csr_element_type
          (p_element_name VARCHAR2,
           p_report_end_date DATE) IS
	SELECT element_type_id
	FROM pay_element_types_f
	WHERE element_name=p_element_name
	  AND legislation_code='SE'
          AND business_group_id IS NULL
          AND p_report_end_date BETWEEN effective_start_date
          AND effective_end_date;

  CURSOR csr_input_values
          (p_element_type_id NUMBER,
           p_report_end_date DATE,
           p_input_value VARCHAR2) IS
         SELECT input_value_id
         FROm   pay_input_values_f
         WHERE  element_type_id = p_element_type_id
           AND  p_report_end_date between effective_start_date
           AND  effective_end_date
           AND  name = p_input_value
           AND  legislation_code='SE'
           AND  business_group_id IS NULL;


  CURSOR csr_all_local_unit_details
          (p_legal_employer_id NUMBER) IS
    SELECT hoi_le.org_information1 local_unit_id,
           hou_lu.NAME local_unit_name,
           hoi_lu.org_information1,
           hou_lu.location_id
     FROM hr_all_organization_units hou_le,
          hr_organization_information hoi_le,
          hr_all_organization_units hou_lu,
          hr_organization_information hoi_lu
     WHERE hoi_le.organization_id = hou_le.organization_id
       AND hou_le.organization_id = p_legal_employer_id
       AND hoi_le.org_information_context = 'SE_LOCAL_UNITS'
       AND hou_lu.organization_id = hoi_le.org_information1
       AND hou_lu.organization_id = hoi_lu.organization_id
       AND hoi_lu.org_information_context = 'SE_LOCAL_UNIT_DETAILS';


  CURSOR csr_assignments
          (p_local_unit_id      NUMBER
          ,p_start_person       NUMBER
          ,p_end_person         NUMBER
          ,p_report_start_date  DATE
          ,p_report_end_date    DATE) IS
  SELECT  pap.person_id,
          pap.full_name,
          '19' || substr(pap.national_identifier,0,6) || substr(pap.national_identifier,8) national_identifier,
          paa.assignment_number employee_number,
          paa.assignment_id
     FROM per_all_assignments_f paa,
          per_all_people_f pap,
          HR_SOFT_CODING_KEYFLEX hsc,
          per_person_types ppt
    WHERE pap.person_id BETWEEN p_start_person AND p_end_person
      AND  pap.effective_start_date <= p_report_end_date
      AND  pap.effective_end_date >= p_report_start_date
      AND ppt.system_person_type like 'EMP%'
      AND ppt.person_type_id= pap.person_type_id
      AND  pap.person_id = paa.person_id
      AND  paa.effective_start_date <= p_report_end_date
      AND  paa.effective_end_date >= p_report_start_date
      AND  hsc.soft_coding_keyflex_id     = paa.soft_coding_keyflex_id
      AND  hsc.segment2 = to_char(p_local_unit_id)
      ORDER by assignment_id;


/*  CURSOR csr_sickness_start_end_date
           (p_element_type_id NUMBER,
            p_assignment_id NUMBER,
            p_report_start_date DATE,
            p_report_end_date DATE,
            p_start_date_iv NUMBER,
            p_end_date_iv NUMBER) IS
  SELECT pee.element_entry_id,
         NVL(fnd_date.canonical_to_date(peev1.screen_entry_value), pee.effective_start_date) start_date,
         NVL(fnd_date.canonical_to_date(peev2.screen_entry_value), pee.effective_end_date) end_date
  FROM pay_element_entries_f pee ,
       pay_element_entry_values_f peev1,
       pay_element_entry_values_f peev2
  WHERE
        element_type_id= p_element_type_id
    AND assignment_id= p_assignment_id
    AND p_report_start_date < nvl(pee.effective_end_date, p_report_start_date)
    AND p_report_end_date > pee.effective_start_date
    AND pee.element_entry_id = peev1.element_entry_id
    AND p_report_start_date < nvl(peev1.effective_end_date, p_report_start_date)
    AND p_report_end_date > peev1.effective_start_date
    AND peev1.input_value_id= p_start_date_iv
    AND pee.element_entry_id = peev2.element_entry_id
    AND p_report_start_date < nvl(peev2.effective_end_date, p_report_start_date)
    AND p_report_end_date > peev2.effective_start_date
    AND peev2.input_value_id=p_end_date_iv;	*/

  CURSOR csr_sickness_start_end_date
           (p_element_type_id NUMBER,
            p_assignment_id NUMBER,
            p_report_start_date DATE,
            p_report_end_date DATE,
            p_start_date_iv NUMBER,
            p_full_day_iv NUMBER,
            p_end_date_iv NUMBER,
            p_part_day_iv NUMBER) IS
  SELECT prr.source_id,
         fnd_date.canonical_to_date(prrv1.result_value) start_date,
         prrv2.result_value full_day,
         fnd_date.canonical_to_date(prrv3.result_value) end_date,
         prrv4.result_value part_day
  FROM   pay_assignment_actions paa,
         pay_payroll_actions ppa,
         pay_run_results prr,
         pay_run_result_values prrv1,
         pay_run_result_values prrv2,
         pay_run_result_values prrv3,
         pay_run_result_values prrv4
  WHERE  ppa.effective_date BETWEEN p_report_start_date
    AND  p_report_end_date
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.assignment_id = p_assignment_id
    AND  paa.assignment_action_id = prr.assignment_action_id
    AND  prr.element_type_id = p_element_type_id
    AND  prr.run_result_id = prrv1.run_result_id
    AND  prrv1.input_value_id = p_start_date_iv
    AND  prr.run_result_id = prrv2.run_result_id
    AND  prrv2.input_value_id = p_full_day_iv
    AND  prr.run_result_id = prrv3.run_result_id
    AND  prrv3.input_value_id = p_end_date_iv
    AND  prr.run_result_id = prrv4.run_result_id
    AND  prrv4.input_value_id = p_part_day_iv
         ORDER BY prr.run_result_id;
/* Order by in above cursor is needed to query results in order of their creation.
This is important in case same absence streches across periods*/

  CURSOR csr_total_sickness_days
           (p_element_type_id NUMBER,
            p_assignment_id NUMBER,
            p_report_start_date DATE,
            p_report_end_date DATE,
            p_full_day_iv NUMBER,
            p_source_id NUMBER) IS
  SELECT max(to_number(prrv1.result_value)) full_day
  FROM   pay_assignment_actions paa,
         pay_payroll_actions ppa,
         pay_run_results prr,
         pay_run_result_values prrv1
  WHERE  ppa.effective_date BETWEEN p_report_start_date
    AND  p_report_end_date
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.assignment_id = p_assignment_id
    AND  paa.assignment_action_id = prr.assignment_action_id
    AND  prr.element_type_id = p_element_type_id
    AND  prr.run_result_id = prrv1.run_result_id
    AND  prrv1.input_value_id = p_full_day_iv
    AND  prr.source_id = p_source_id;


  CURSOR csr_group_start_end_date
           (p_element_type_id NUMBER,
            p_assignment_id NUMBER,
            p_report_start_date DATE,
            p_report_end_date DATE,
            p_start_date_iv NUMBER,
            p_14th_date_iv NUMBER,
            p_end_date_iv NUMBER,
            p_emp_days_iv NUMBER) IS
  SELECT fnd_date.canonical_to_date(prrv1.result_value) start_date,
         fnd_date.canonical_to_date(prrv2.result_value) fourteenth_date,
         fnd_date.canonical_to_date(prrv3.result_value) end_date,
         prrv4.result_value employer_days
  FROM   pay_assignment_actions paa,
         pay_payroll_actions ppa,
         pay_run_results prr,
         pay_run_result_values prrv1,
         pay_run_result_values prrv2,
         pay_run_result_values prrv3,
         pay_run_result_values prrv4
  WHERE  ppa.effective_date BETWEEN p_report_start_date
    AND  p_report_end_date
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.assignment_id = p_assignment_id
    AND  paa.assignment_action_id = prr.assignment_action_id
    AND  prr.element_type_id = p_element_type_id
    AND  prr.run_result_id = prrv1.run_result_id
    AND  prrv1.input_value_id = p_start_date_iv
    AND  prr.run_result_id = prrv2.run_result_id
    AND  prrv2.input_value_id = p_14th_date_iv
    AND  prr.run_result_id = prrv3.run_result_id
    AND  prrv3.input_value_id = p_end_date_iv
    AND  prr.run_result_id = prrv4.run_result_id
    AND  prrv4.input_value_id = p_emp_days_iv;

    CURSOR csr_correction_data
          (p_assignment_id NUMBER) IS
    SELECT  assignment_extra_info_id,
            fnd_date.canonical_to_date(AEI_INFORMATION1) start_date,
            fnd_date.canonical_to_date(AEI_INFORMATION2) end_date,
            AEI_INFORMATION3 full_day,
            AEI_INFORMATION4 part_day
    FROM    PER_ASSIGNMENT_EXTRA_INFO
    WHERE   assignment_id=p_assignment_id
    AND     aei_information_category ='SE_SICKNESS_CORRECTION_DATA'
    AND     aei_information5='Y';

    ----
    l_element_type_rec            csr_element_type%ROWTYPE;
    l_input_values_start_rec      csr_input_values%ROWTYPE;
    l_input_values_14th_rec       csr_input_values%ROWTYPE;
    l_input_values_end_rec        csr_input_values%ROWTYPE;
    l_input_values_emplr_days_rec csr_input_values%ROWTYPE;
    l_sickness_element_type_rec   csr_element_type%ROWTYPE;
    l_sickness_start_date_rec     csr_input_values%ROWTYPE;
    l_sickness_full_day_rec       csr_input_values%ROWTYPE;
    l_sickness_part_day_rec       csr_input_values%ROWTYPE;
    l_sickness_end_date_rec       csr_input_values%ROWTYPE;
    l_all_local_unit_details_rec  csr_all_local_unit_details%ROWTYPE;
    l_assignments_rec             csr_assignments%ROWTYPE;
    l_total_sickness_days_rec     csr_total_sickness_days%ROWTYPE;
    ----
    l_assignment_id		  PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
    l_assact_id  NUMBER;
    l_ovn        NUMBER;
    l_action_info_id NUMBER;
    l_exit_flag VARCHAR2(10);
    l_sickness_end_date DATE;
    l_sickness_start_date DATE;
    l_full_day NUMBER(5);
    l_part_day NUMBER(5);
    l_employer_days NUMBER(5);
    l_total_full_day NUMBER(5);
    l_check_end_date VARCHAR2(20);
    l_check_days NUMBER(5);


BEGIN

l_assignment_id:=0;
l_exit_flag := 'N';
l_total_full_day :=0;
l_full_day := 0;

        g_payroll_action_id :=p_payroll_action_id;
        g_business_group_id := null;
        g_legal_employer_id := null;
        g_start_date        := null;
        g_end_date          := null;
        g_version           := null;
        g_archive           := null;


        GET_ALL_PARAMETERS
                (p_payroll_action_id
       		,g_business_group_id
       		,g_effective_date
       		,g_legal_employer_id
       		,g_start_date
                  ,g_end_date
       		,g_archive
        );


        IF g_archive = 'Y'
        THEN

/* Get Input value ids for input values for Sick Pay 1 to 14 days element*/

        OPEN csr_element_type ('Sick Pay 1 to 14 days',g_end_date);
        FETCH csr_element_type INTO l_element_type_rec;
        CLOSE csr_element_type;

        OPEN csr_input_values(l_element_type_rec.element_type_id, g_end_date, 'Start Date');
        FETCH csr_input_values INTO l_input_values_start_rec;
        CLOSE csr_input_values;

        OPEN csr_input_values(l_element_type_rec.element_type_id, g_end_date, 'Fourteenth Date');
        FETCH csr_input_values INTO l_input_values_14th_rec;
        CLOSE csr_input_values;


        OPEN csr_input_values(l_element_type_rec.element_type_id, g_end_date, 'End Date');
        FETCH csr_input_values INTO l_input_values_end_rec;
        CLOSE csr_input_values;


        OPEN csr_input_values(l_element_type_rec.element_type_id, g_end_date, 'Full Days');
        FETCH csr_input_values INTO l_input_values_emplr_days_rec;
        CLOSE csr_input_values;

/* Get Input value ids for input values for Sickness Details element*/

        OPEN csr_element_type ('Sickness Details',g_end_date);
        FETCH csr_element_type INTO l_sickness_element_type_rec;
        CLOSE csr_element_type;

        OPEN csr_input_values(l_sickness_element_type_rec.element_type_id, g_end_date, 'Start Date');
        FETCH csr_input_values INTO l_sickness_start_date_rec;
        CLOSE csr_input_values;

        OPEN csr_input_values(l_sickness_element_type_rec.element_type_id, g_end_date, 'Full Time Sickness Days');
        FETCH csr_input_values INTO l_sickness_full_day_rec;
        CLOSE csr_input_values;

        OPEN csr_input_values(l_sickness_element_type_rec.element_type_id, g_end_date, 'Part Time Sickness Days');
        FETCH csr_input_values INTO l_sickness_part_day_rec;
        CLOSE csr_input_values;

        OPEN csr_input_values(l_sickness_element_type_rec.element_type_id, g_end_date, 'End Date');
        FETCH csr_input_values INTO l_sickness_end_date_rec;
        CLOSE csr_input_values;

        FOR l_all_local_unit_details_rec IN csr_all_local_unit_details (g_legal_employer_id) LOOP

	    FOR l_assignments_rec IN csr_assignments( l_all_local_unit_details_rec.local_unit_id
                                                      ,p_start_person
                                                      ,p_end_person
                                                      ,g_start_date
                                                      ,g_end_date) LOOP

              IF l_assignment_id <> l_assignments_rec.assignment_id THEN
			l_assignment_id := l_assignments_rec.assignment_id;


	      SELECT pay_assignment_actions_s.nextval INTO l_assact_id FROM dual;
	         hr_nonrun_asact.insact
	         (l_assact_id
	         ,l_assignments_rec.assignment_id
	         ,p_payroll_action_id
	         ,p_chunk
	         ,NULL);


              l_employer_days:=0;

	        FOR l_sickness_group IN csr_group_start_end_date (l_element_type_rec.element_type_id
                                                            ,l_assignments_rec.assignment_id
                                                            ,g_start_date
                                                            ,g_end_date
                                                            ,l_input_values_start_rec.input_value_id
                                                            ,l_input_values_14th_rec.input_value_id
                                                            ,l_input_values_end_rec.input_value_id
                                                            ,l_input_values_emplr_days_rec.input_value_id) LOOP

                      l_exit_flag := 'N';
                      l_total_full_day :=0;
                      l_full_day := 0;
                      l_part_day := 0;
                      l_employer_days := l_sickness_group.employer_days;

	        FOR l_start_end_date IN csr_sickness_start_end_date (l_sickness_element_type_rec.element_type_id
                                                            ,l_assignments_rec.assignment_id
                                                            ,g_start_date
                                                            ,g_end_date
                                                            ,l_sickness_start_date_rec.input_value_id
                                                            ,l_sickness_full_day_rec.input_value_id
                                                            ,l_sickness_end_date_rec.input_value_id
                                                            ,l_sickness_part_day_rec.input_value_id) LOOP




		IF l_start_end_date.start_date BETWEEN
               l_sickness_group.start_date AND nvl(l_sickness_group.fourteenth_date,l_sickness_group.end_date ) THEN

				l_sickness_end_date := least(l_sickness_group.fourteenth_date,l_start_end_date.end_date);
			BEGIN
                       SELECT action_information8,
                              action_information10
                       INTO l_check_end_date,
                            l_check_days
                       FROM pay_action_information
                       WHERE action_context_id = l_assact_id
                       AND action_information13 = l_start_end_date.source_id;
/*
If more than one results exist for the same entry
*/


                    IF l_check_end_date <> fnd_date.date_to_canonical(l_sickness_end_date) THEN
        			OPEN csr_total_sickness_days(l_sickness_element_type_rec.element_type_id
                                                    ,l_assignments_rec.assignment_id
                                                    ,g_start_date
                                                    ,g_end_date
                                                    ,l_sickness_full_day_rec.input_value_id
                                                    ,l_start_end_date.source_id);
                        FETCH csr_total_sickness_days INTO l_total_sickness_days_rec;
                        CLOSE csr_total_sickness_days;

                       UPDATE pay_action_information
                       set action_information8 = fnd_date.date_to_canonical(greatest(l_sickness_end_date,fnd_date.canonical_to_date(l_check_end_date))),
                           action_information10 = least(l_total_sickness_days_rec.full_day,l_employer_days)
                       WHERE action_context_id = l_assact_id
                       AND action_information13 = l_start_end_date.source_id;
                       l_total_full_day:= nvl(least(l_total_sickness_days_rec.full_day,l_employer_days),0) + nvl(l_total_full_day,0)
                                            + nvl(l_start_end_date.part_day,0);
                    ELSE
                       l_total_full_day:= nvl(l_start_end_date.full_day,0) + nvl(l_total_full_day,0)
                                            + nvl(l_start_end_date.part_day,0);
                    END IF;

                  EXCEPTION
                      WHEN NO_DATA_FOUND THEN

/*
1) In normal cases sickness group end date and fouteenth date will be same as sickness end date
2) When sickness crosses 14 days then fourteenth date will be less than or equal to group end date.
3) In case of change in pay period when sickness is across period border fourteenth date and
   group end date both will have period end date.
*/

/*                 IF l_sickness_group.fourteenth_date IS NOT NULL AND l_sickness_group.fourteenth_date
                     between l_start_end_date.start_date and ( l_start_end_date.end_date -1 )
                     and l_sickness_group.fourteenth_date  <> l_sickness_group.end_date THEN
                         l_exit_flag := 'Y';
				 if nvl(l_start_end_date.full_day,0) > 0 then
	                         l_full_day := l_employer_days - l_total_full_day;
				 elsif nvl(l_start_end_date.part_day,0) > 0 then
	                         l_part_day := l_employer_days - l_total_full_day;
                         end if;

                         l_sickness_end_date :=l_sickness_group.fourteenth_date;
                  ELSIF l_sickness_group.fourteenth_date IS NOT NULL AND l_sickness_group.fourteenth_date
                     between l_start_end_date.start_date and ( l_start_end_date.end_date -1 )
                     and l_sickness_group.fourteenth_date  = l_sickness_group.end_date THEN

                         l_full_day := l_start_end_date.full_day;
                         l_part_day := l_start_end_date.part_day;
                         l_sickness_end_date :=l_sickness_group.fourteenth_date;

                  ELSE

                         l_full_day :=  l_start_end_date.full_day;
                         l_part_day :=  l_start_end_date.part_day;
                         l_sickness_end_date :=l_start_end_date.end_date;
                  END IF;*/

				 l_sickness_end_date := LEAST(l_start_end_date.end_date, l_sickness_group.fourteenth_date );
				 IF l_sickness_group.fourteenth_date < l_start_end_date.end_date THEN

fnd_file.put_line(fnd_file.log,'location: 1 l_total_full_day: '||l_total_full_day);
fnd_file.put_line(fnd_file.log,'location: 1 l_start_end_date.end_date : '||l_start_end_date.end_date );

                               l_exit_flag := 'Y';
					 if nvl(l_start_end_date.full_day,0) > 0 then
		                         l_full_day := l_employer_days - l_total_full_day;
					 elsif nvl(l_start_end_date.part_day,0) > 0 then
	            	             l_part_day := l_employer_days - l_total_full_day;
                        	 end if;
                         ELSE
					 if nvl(l_start_end_date.full_day,0) > 0 then
		                         l_full_day := least (l_start_end_date.full_day,l_employer_days);
					 elsif nvl(l_start_end_date.part_day,0) > 0 then
	      	                   l_part_day := least (l_start_end_date.part_day,l_employer_days);
					 end if;
				 END IF;


                         l_total_full_day:= nvl(l_start_end_date.full_day,0) + nvl(l_total_full_day,0)
                                            + nvl(l_start_end_date.part_day,0);

fnd_file.put_line(fnd_file.log,'location: 2 l_total_full_day: '||l_total_full_day);
fnd_file.put_line(fnd_file.log,'location: 2 l_exit_flag: '||l_exit_flag);
fnd_file.put_line(fnd_file.log,'location: 2 l_start_end_date.full_day: '||l_start_end_date.full_day);
fnd_file.put_line(fnd_file.log,'location: 2 l_start_end_date.part_day: '||l_start_end_date.part_day);
fnd_file.put_line(fnd_file.log,'location: 2 l_start_end_date.end_date : '||l_start_end_date.end_date );
fnd_file.put_line(fnd_file.log,'location: 2 l_sickness_group.end_date  : '||l_sickness_group.end_date  );
fnd_file.put_line(fnd_file.log,'in assignment_action_code total full day ' || to_char(l_total_full_day));

			     IF l_start_end_date.start_date < g_start_date THEN
                          l_sickness_start_date := g_start_date;
                       ELSE
                          l_sickness_start_date := l_start_end_date.start_date;
                       END IF;

                       pay_action_information_api.create_action_information (
                               p_action_information_id=> l_action_info_id,
                               p_action_context_id=> l_assact_id,
                               p_action_context_type=> 'AAP',
                               p_object_version_number=> l_ovn,
                               p_effective_date=> g_effective_date,
                               p_assignment_id => l_assignments_rec.assignment_id,
                               p_action_information_category=> 'EMEA REPORT INFORMATION',
                               p_action_information1=> 'PYSESTOA',
                               p_action_information2=> 'ASG',
                               p_action_information3=> g_legal_employer_id,
                               p_action_information4=> l_assignments_rec.national_identifier,
                               p_action_information5=> l_assignments_rec.full_name,
                               p_action_information6=> l_assignments_rec.employee_number,
                               p_action_information7=> fnd_date.date_to_canonical(l_sickness_start_date ),
                               p_action_information8=> fnd_date.date_to_canonical(l_sickness_end_date),
                               p_action_information9=> to_char(l_assignments_rec.person_id),
                               p_action_information10=> l_full_day,
                               p_action_information11=> l_part_day, -- part day balance to be added
                               p_action_information12=> NULL, -- correction
                               p_action_information13=> l_start_end_date.source_id,
                               p_action_information14=> NULL,
                               p_action_information15=> NULL,
                               p_action_information16=> NULL,
                               p_action_information17=> NULL,
                               p_action_information18=> NULL,
                               p_action_information19=> NULL,
                               p_action_information20=> NULL
                               );
                    END;
			END IF;

                IF l_exit_flag = 'Y' THEN

                      l_total_full_day :=0;
                      l_exit_flag := 'N';
                      l_full_day := 0;
                      l_part_day := 0;

                      EXIT;
                END IF;
             END LOOP; -- sickness results


            END LOOP; -- group results



            FOR l_csr_correction_data IN csr_correction_data (l_assignments_rec.assignment_id) LOOP

	IF l_csr_correction_data.start_date >= g_start_date and l_csr_correction_data.start_date <= g_end_date THEN
                       pay_action_information_api.create_action_information (
                               p_action_information_id=> l_action_info_id,
                               p_action_context_id=> l_assact_id,
                               p_action_context_type=> 'AAP',
                               p_object_version_number=> l_ovn,
                               p_effective_date=> g_effective_date,
                               p_assignment_id => l_assignments_rec.assignment_id,
                               p_action_information_category=> 'EMEA REPORT INFORMATION',
                               p_action_information1=> 'PYSESTOA',
                               p_action_information2=> 'ASG',
                               p_action_information3=> g_legal_employer_id,
                               p_action_information4=> l_assignments_rec.national_identifier,
                               p_action_information5=> l_assignments_rec.full_name,
                               p_action_information6=> l_assignments_rec.employee_number,
                               p_action_information7=> fnd_date.date_to_canonical(l_csr_correction_data.start_date),
                               p_action_information8=> fnd_date.date_to_canonical(l_csr_correction_data.end_date),
                               p_action_information9=> to_char(l_assignments_rec.person_id),
                               p_action_information10=> l_csr_correction_data.full_day,
                               p_action_information11=> l_csr_correction_data.part_day,
                               p_action_information12=> '1',
                               p_action_information13=> NULL,
                               p_action_information14=> NULL,
                               p_action_information15=> NULL,
                               p_action_information16=> NULL,
                               p_action_information17=> NULL,
                               p_action_information18=> NULL,
                               p_action_information19=> NULL,
                               p_action_information20=> NULL
                               );


				update PER_ASSIGNMENT_EXTRA_INFO
                        set aei_information5='N'
                        where assignment_extra_info_id = l_csr_correction_data.assignment_extra_info_id;
                     END IF;

		END LOOP; -- Correction Loop;

            END IF; -- if assignment is same

        END LOOP; -- Assignment

   END LOOP; -- Local Unit

  END IF; -- g_archive = 'Y'

END;


 PROCEDURE initialization_code
 (p_payroll_action_id IN NUMBER) IS
 BEGIN
  NULL;
 END initialization_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Create archive information for individual assignment actions.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE archive_code
 (p_assignment_action_id IN NUMBER
 ,p_effective_date       IN DATE) IS
  --
  --
 BEGIN
  --
  --
NULL;
END archive_code;

 --
 --
 -- -----------------------------------------------------------------------------
 -- Assemble XML for reporting.
 -- -----------------------------------------------------------------------------
 --

PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB) is
l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(240);
l_str9 varchar2(240);
l_str10 varchar2(20);
l_str11 varchar2(20);
l_IANA_charset VARCHAR2 (50);

current_index pls_integer;

BEGIN

hr_utility.set_location('Entering WritetoCLOB ',10);


       l_IANA_charset := HR_SE_UTILITY.get_IANA_charset ;
        l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><PAACR>';
        l_str2 := '<';
        l_str3 := '>';
        l_str4 := '</';
        l_str5 := '>';
        l_str6 := '</PAACR></ROOT>';
        l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
        l_str10 := '<PAACR>';
        l_str11 := '</PAACR>';


        dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

        current_index := 0;

              IF xml_tab.count > 0 THEN

                        dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


                        FOR table_counter IN xml_tab.FIRST .. xml_tab.LAST LOOP

                                l_str8 := xml_tab(table_counter).TagName;
                                l_str9 := xml_tab(table_counter).TagValue;

                                IF l_str9 IN ('ORG_DETAILS','EMP_DETAILS','END_ORG_DETAILS','END_EMP_DETAILS'
                                              ) THEN

                                                IF l_str9 IN ('ORG_DETAILS','EMP_DETAILS') THEN
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                                ELSE
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
                                                END IF;

                                ELSE

                                         if l_str9 is not null then

                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str9), l_str9);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
                                         else

                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);

                                         end if;

                                END IF;

                        END LOOP;

                        dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6 );

                ELSE
                        dbms_lob.writeAppend(l_xfdf_string, length(l_str7), l_str7 );
                END IF;

                p_xfdf_clob := l_xfdf_string;

                hr_utility.set_location('Leaving WritetoCLOB ',20);

        EXCEPTION
                WHEN OTHERS then
                HR_UTILITY.TRACE('sqlerrm ' || SQLERRM);
                HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;


--
--
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


CURSOR csr_legal_employer_details (p_payroll_action_id NUMBER)
IS
SELECT
      action_information3 legal_employer_id,
      action_information4 name,
      action_information5 org_num,
      action_information6 address,
      action_information7 postal_code,
      action_information8 country,
      action_information9 contact_person,
      effective_date
FROM pay_action_information pai
WHERE pai.action_context_id = p_payroll_action_id
AND   pai.action_context_type='PA'
AND   pai.action_information_category='EMEA REPORT INFORMATION'
AND   pai.action_information1='PYSESTOA'
AND   pai.action_information2='LE';

CURSOR csr_employee_details (p_payroll_action_id NUMBER,
                                 p_legal_employer_id NUMBER)
IS
	SELECT
	      pai.action_information4 national_identifier,
	      pai.action_information5 full_name,
	      fnd_date.canonical_to_date(pai.action_information7) start_date,
	      fnd_date.canonical_to_date(pai.action_information8) end_date,
	      pai.action_information10 full_day,
	      pai.action_information11 part_day,
	      pai.action_information12 correction
	FROM
	     pay_payroll_actions paa,
	     pay_assignment_actions assg,
	     pay_action_information pai
	WHERE
	    paa.payroll_action_id = p_payroll_action_id
	AND assg.payroll_action_id = paa.payroll_action_id
	AND pai.action_context_id= assg.assignment_action_id
	AND pai.action_context_type='AAP'
	AND pai.action_information_category='EMEA REPORT INFORMATION'
	AND pai.action_information1='PYSESTOA'
	AND pai.action_information2='ASG'
	AND pai.action_information3=p_legal_employer_id;

l_legal_employer_details_rec csr_legal_employer_details%rowtype;
l_employee_details_rec csr_employee_details%rowtype;


l_counter             NUMBER;
l_total               NUMBER;
l_total_eft           NUMBER;
l_count               NUMBER;
l_payroll_action_id   NUMBER;
l_lu_counter_reset    VARCHAR2(10);
l_prev_local_unit     VARCHAR2(15);


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
        g_business_group_id := null;
        g_legal_employer_id := null;
        g_start_date        := null;
        g_end_date          := null;
        g_version           := null;
        g_archive           := null;


        GET_ALL_PARAMETERS
                (l_payroll_action_id
       		,g_business_group_id
       		,g_effective_date
       		,g_legal_employer_id
       		,g_start_date
                  ,g_end_date
       		,g_archive
        );

        hr_utility.set_location('Entered Procedure GETDATA',10);


        /* Get the File Header Information */
        OPEN csr_legal_employer_details(l_payroll_action_id);
        FETCH csr_legal_employer_details INTO l_legal_employer_details_rec;
        CLOSE csr_legal_employer_details;

        hr_utility.set_location('Before populating pl/sql table',20);

        xml_tab(l_counter).TagName  :='ORG_DETAILS';
        xml_tab(l_counter).TagValue :='ORG_DETAILS';
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ORG_NAME';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.NAME;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ORG_NUM';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.org_num;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ADDRESS';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.address;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='START_DATE';
        xml_tab(l_counter).TagValue := to_char(g_start_date,'YYYYMMDD');
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='END_DATE';
        xml_tab(l_counter).TagValue := to_char(g_end_date,'YYYYMMDD');
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='POSTAL_CODE';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.postal_code;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='COUNTRY';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.country;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='CONTACT_PERSON';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.CONTACT_PERSON;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='REPORT_DATE';
        xml_tab(l_counter).TagValue := to_char(l_legal_employer_details_rec.effective_date,'YYYYMMDD');
	l_counter:=l_counter+1;

			-- Employee Data

		FOR l_employee_details_rec IN csr_employee_details(l_payroll_action_id, to_number(l_legal_employer_details_rec.legal_employer_id))
		LOOP


/* Begins Employee record*/


		        xml_tab(l_counter).TagName  :='EMP_DETAILS';
		        xml_tab(l_counter).TagValue :='EMP_DETAILS';
		        l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUM';
		        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.org_num;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='NATIONAL_IDENTIFIER';
		        xml_tab(l_counter).TagValue := l_employee_details_rec.national_identifier;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='FULL_NAME';
		        xml_tab(l_counter).TagValue := l_employee_details_rec.full_name;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='START_DATE';
		        xml_tab(l_counter).TagValue := to_char(l_employee_details_rec.start_date,'YYYYMMDD');
			l_counter:=l_counter+1;


		        xml_tab(l_counter).TagName  :='END_DATE';
		        xml_tab(l_counter).TagValue := to_char(l_employee_details_rec.end_date,'YYYYMMDD');
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='FULL_DAY';
		        xml_tab(l_counter).TagValue := l_employee_details_rec.full_day;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='PART_DAY';
		        xml_tab(l_counter).TagValue := l_employee_details_rec.part_day;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='CORRECTION';
		        xml_tab(l_counter).TagValue := l_employee_details_rec.correction;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMP_DETAILS';
		        xml_tab(l_counter).TagValue :='END_EMP_DETAILS';
		        l_counter:=l_counter+1;

	END LOOP; -- employee

		        xml_tab(l_counter).TagName  :='ORG_DETAILS';
		        xml_tab(l_counter).TagValue :='END_ORG_DETAILS';
		        l_counter := l_counter + 1;


        hr_utility.set_location('After populating pl/sql table',30);
        hr_utility.set_location('Entered Procedure GETDATA',10);


        WritetoCLOB (p_xml );

END POPULATE_DATA_DETAIL;

END pay_se_stat_office_archive;

/
