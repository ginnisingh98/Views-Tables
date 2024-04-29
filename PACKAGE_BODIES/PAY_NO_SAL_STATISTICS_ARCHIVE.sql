--------------------------------------------------------
--  DDL for Package Body PAY_NO_SAL_STATISTICS_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_SAL_STATISTICS_ARCHIVE" AS
 /* $Header: pynossta.pkb 120.0.12000000.1 2007/05/20 09:29:42 rlingama noship $ */
 --
 --
 -- -----------------------------------------------------------------------------
 -- Data types.
 -- -----------------------------------------------------------------------------
 --
 TYPE t_rep_code_rec IS RECORD
  (record_type    VARCHAR2(10)
  ,reporting_code VARCHAR2(10)
  ,amount         NUMBER
  ,info1          VARCHAR2(30)
  ,info2          VARCHAR2(30)
  ,info3          VARCHAR2(30)
  ,info4          VARCHAR2(30)
  ,info5          VARCHAR2(30)
  ,info6          VARCHAR2(30));
 --
 TYPE t_xml_element_rec IS RECORD
  (tagname VARCHAR2(240)
  ,tagvalue VARCHAR2(240));
 --
 TYPE t_xml_element_table IS TABLE OF t_xml_element_rec INDEX BY BINARY_INTEGER;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Global variables.
 -- -----------------------------------------------------------------------------
 --
 g_xml_element_table  t_xml_element_table;
 g_empty_rep_code_rec t_rep_code_rec;
 g_business_group_id  NUMBER;
 g_legal_employer_id  NUMBER;
 g_report_date        DATE;
 g_effective_date     DATE;
 g_archive            VARCHAR2(30);
 g_debug   boolean   :=  hr_utility.debug_enabled;
 g_payroll_action_id NUMBER;
 g_package            VARCHAR2(30) := 'pay_no_sal_statistics_archive.';
 g_version VARCHAR2(10);
 g_sp_org_id VARCHAR2(39);
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
        p_payroll_action_id IN   NUMBER    													-- In parameter
       ,p_business_group_id OUT  NOCOPY NUMBER    		-- Core parameter
       ,p_effective_date    OUT  NOCOPY Date			-- Core parameter
       ,p_name_sp	    OUT  NOCOPY NUMBER		-- Statement Provider Name
       ,p_legal_employer_id OUT  NOCOPY NUMBER      		-- User parameter
       ,p_version           OUT  NOCOPY VARCHAR2
       ,p_archive	    OUT  NOCOPY VARCHAR2  	        -- User parameter
       )
       IS
     CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
     SELECT
    get_parameter(legislative_parameters,'NAME_SP') name_sp,
    TO_NUMBER  ( GET_PARAMETER(legislative_parameters,'LE_ID') ) Legal
    ,get_parameter(legislative_parameters,'VERSION') VERSION
    ,GET_PARAMETER(legislative_parameters,'ARCHIVE') ARCHIVE_OR_NOT
    ,fnd_date.canonical_to_date(GET_PARAMETER(legislative_parameters,'DATE'))
    ,business_group_id BG_ID		 FROM  pay_payroll_actions
    		 WHERE payroll_action_id = p_payroll_action_id;

    lr_parameter_info csr_parameter_info%ROWTYPE;

    l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';

 BEGIN
			OPEN csr_parameter_info (p_payroll_action_id);

							 FETCH csr_parameter_info
							 INTO	p_name_sp
                                                                ,p_legal_employer_id
                                                                ,p_version
								,p_archive
								,p_effective_date
								,p_business_group_id;
			CLOSE csr_parameter_info;

        --fnd_file.put_line(fnd_file.log,'After  csr_parameter_info in  ' );
        --fnd_file.put_line(fnd_file.log,'After  p_legal_employer_id  in  '  || p_legal_employer_id);
        --fnd_file.put_line(fnd_file.log,'After  p_local_unit_id in  ' || p_local_unit_id  );
        --fnd_file.put_line(fnd_file.log,'After  p_archive' || p_archive  );

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
  CURSOR csr_legal_employers
          (p_legal_employer_id IN NUMBER) IS
   SELECT org.organization_id legal_employer_id
         ,org.name
	 ,org.location_id
         ,hoi1.org_information1
   FROM   hr_all_organization_units org
         ,hr_organization_information hoi1
   WHERE  org.organization_id              = p_legal_employer_id
     AND  hoi1.organization_id (+)         = org.organization_id
     AND  hoi1.org_information_context (+) = 'NO_LEGAL_EMPLOYER_DETAILS';

-- Cursor to pick up Local Unit Details

        CURSOR csr_all_local_unit_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE )
      IS
         SELECT hoi_le.org_information1 local_unit_id,
                hou_lu.NAME local_unit_name,
                hoi_lu.org_information1,
                hoi_lu.org_information3,
                hou_lu.location_id
           FROM hr_all_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_all_organization_units hou_lu,
                hr_organization_information hoi_lu
          WHERE hoi_le.organization_id = hou_le.organization_id
            AND hou_le.organization_id = csr_v_legal_employer_id
            AND hoi_le.org_information_context = 'NO_LOCAL_UNITS'
            AND hou_lu.organization_id = hoi_le.org_information1
            AND hou_lu.organization_id = hoi_lu.organization_id
            AND hoi_lu.org_information_context = 'NO_LOCAL_UNIT_DETAILS';

       CURSOR csr_org_details (p_sp_org_id NUMBER) IS
          SELECT org.organization_id
                ,org.name
       	        ,org.location_id
                ,hoi1.org_information1 sp_org_number
          FROM   hr_all_organization_units org
                ,hr_organization_information hoi1
          WHERE  org.organization_id              = p_sp_org_id
            AND  hoi1.organization_id (+)         = org.organization_id
            AND  hoi1.org_information_context (+) = 'NO_STATEMENT_PROVIDER_DETAILS';


	CURSOR csr_location (p_location_id NUMBER) IS
	SELECT rpad(Address_line_1 || ', ' || Address_line_2 ||', ' ||Address_line_3,30,' ') address, postal_code
	FROM hr_locations
	WHERE location_id = p_location_id;

  --
  L_ACTION_INFO_ID NUMBER;
  l_ovn        NUMBER;
  l_location_rec csr_location%rowtype;
  l_legal_employer_rec csr_legal_employers%ROWTYPE;
  l_org_details_rec csr_org_details%ROWTYPE;
  --
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
        g_sp_org_id           := null;
	g_legal_employer_id := null;
        g_version           := null;
        g_archive := null;

        GET_ALL_PARAMETERS
                (p_payroll_action_id
        		,g_business_group_id
        		,g_effective_date
			,g_sp_org_id
        		,g_legal_employer_id
                        ,g_version
        		,g_archive
        );

/*		pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
		pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id);
		pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_ref_date));
		pay_balance_pkg.set_context('SOURCE_ID',NULL);
		pay_balance_pkg.set_context('TAX_GROUP',NULL);*/

        IF g_archive = 'Y'
        THEN

				IF nvl(g_sp_org_id,-9999) <> -9999  THEN
				       OPEN csr_org_details(g_sp_org_id);
                                       FETCH csr_org_details INTO l_org_details_rec;
                                       CLOSE csr_org_details;
				END IF;

				       OPEN csr_legal_employers(g_legal_employer_id);
                                       FETCH csr_legal_employers INTO l_legal_employer_rec;
                                       CLOSE csr_legal_employers;


                                       pay_action_information_api.create_action_information (
                                          p_action_information_id=> l_action_info_id,
                                          p_action_context_id=> p_payroll_action_id,
                                          p_action_context_type=> 'PA',
                                          p_object_version_number=> l_ovn,
                                          p_effective_date=> g_effective_date,
                                          p_source_id=> NULL,
                                          p_source_text=> NULL,
                                          p_action_information_category=> 'EMEA REPORT DETAILS',
                                          p_action_information1=> 'PYNOSSTA',
                                          p_action_information2=> to_char(g_business_group_id),
                                          p_action_information3=> to_char(g_legal_employer_id),
                                          p_action_information4=> l_legal_employer_rec.name,
                                          p_action_information5=> fnd_date.date_to_canonical(g_effective_date),
                                          p_action_information6=> g_version,
                                          p_action_information7=> g_sp_org_id,
                                          p_action_information8=> l_org_details_rec.name,
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

				IF nvl(g_sp_org_id,-9999) <> -9999  THEN
				       OPEN csr_location(l_org_details_rec.location_id);
				       FETCH csr_location INTO l_location_rec;
				       CLOSE csr_location;

				ELSE
				       OPEN csr_location(l_legal_employer_rec.location_id);
				       FETCH csr_location INTO l_location_rec;
				       CLOSE csr_location;
				END IF;
                                       pay_action_information_api.create_action_information (
                                          p_action_information_id=> l_action_info_id,
                                          p_action_context_id=> p_payroll_action_id,
                                          p_action_context_type=> 'PA',
                                          p_object_version_number=> l_ovn,
                                          p_effective_date=> g_effective_date,
                                          p_source_id=> NULL,
                                          p_source_text=> NULL,
                                          p_action_information_category=> 'EMEA REPORT INFORMATION',
                                          p_action_information1=> 'PYNOSSTA',
                                          p_action_information2=> 'LE',
                                          p_action_information3=> nvl(g_sp_org_id,g_legal_employer_id),
                                          p_action_information4=> nvl(l_org_details_rec.name,l_legal_employer_rec.name),
                                          p_action_information5=> l_legal_employer_rec.ORG_INFORMATION1,
                                          p_action_information6=> l_location_rec.address,
                                          p_action_information7=> l_location_rec.postal_code,
                                          p_action_information8=> l_org_details_rec.sp_org_number,
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


                                FOR l_all_local_unit_details_rec IN
                                csr_all_local_unit_details (g_legal_employer_id)
                                LOOP


				       OPEN csr_location(l_all_local_unit_details_rec.location_id);
				       FETCH csr_location INTO l_location_rec;
				       CLOSE csr_location;


                                       pay_action_information_api.create_action_information (
                                          p_action_information_id=> l_action_info_id,
                                          p_action_context_id=> p_payroll_action_id,
                                          p_action_context_type=> 'PA',
                                          p_object_version_number=> l_ovn,
                                          p_effective_date=> g_effective_date,
                                          p_source_id=> NULL,
                                          p_source_text=> NULL,
                                          p_action_information_category=> 'EMEA REPORT INFORMATION',
                                          p_action_information1=> 'PYNOSSTA',
                                          p_action_information2=> 'LU',
                                          p_action_information3=> to_char(l_all_local_unit_details_rec.local_unit_id),
                                          p_action_information4=> l_all_local_unit_details_rec.local_unit_name,
                                          p_action_information5=> l_all_local_unit_details_rec.ORG_INFORMATION1,
                                          p_action_information6=> l_location_rec.address,
                                          p_action_information7=> l_location_rec.postal_code,
                                          p_action_information8=> l_all_local_unit_details_rec.org_information3,
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

                                    END LOOP;

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
 CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
 SELECT  u.creator_id
 FROM    ff_user_entities  u,
 	 ff_database_items d
 WHERE   d.user_name = p_user_name
 AND     u.user_entity_id = d.user_entity_id
 AND     (u.legislation_code = 'NO' )
 AND     (u.business_group_id IS NULL )
 AND     u.creator_type = 'B';
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
  CURSOR csr_assignments
          (p_local_unit_id  NUMBER
          ,p_start_person   NUMBER
          ,p_end_person     NUMBER
          ,p_report_date    DATE) IS
SELECT  pap.person_id,
        pap.full_name,
        substr(pap.national_identifier,0,6) || substr(pap.national_identifier,8,5) national_identifier,
        paa.assignment_number employee_number,
        to_char(pap.original_date_of_hire,'YYYYMMDD') seniority,
        hsc.segment2 local_unit,
        hsc.segment3 Position_code,
        hsc.segment4 work_title,
        hsc.segment5 job_status,
        hsc.segment6 cond_of_emp,
        hsc.segment7 full_part_time,
        hsc.segment8 shift_work,
        hsc.segment9 payroll_period,
        hsc.segment10 agreed_working_hrs,
        decode(nvl(decode(hsc.segment23,'N',null,hsc.segment23),paa.hourly_salaried_code),'S',1,'H',2,3) hourly_salaried_code,
        hsc.segment20 spl_info_1,
        hsc.segment21 spl_info_2,
        hsc.segment22 spl_info_3,
        paa.assignment_id,
        paa.payroll_id
FROM per_all_assignments_f paa,
     per_all_people_f pap,
     HR_SOFT_CODING_KEYFLEX hsc,
     per_person_types ppt
WHERE pap.person_id BETWEEN p_start_person AND p_end_person
     AND  pap.effective_start_date <= p_report_date
     AND  pap.effective_end_date >= trunc(p_report_date,'Y')
     AND ppt.system_person_type like 'EMP%'
     AND ppt.person_type_id= pap.person_type_id
     AND  pap.person_id = paa.person_id
     AND  paa.effective_start_date <= p_report_date
     AND  paa.effective_end_date >= trunc(p_report_date,'Y')
     AND  hsc.soft_coding_keyflex_id     = paa.soft_coding_keyflex_id
     AND  hsc.segment2 = to_char(p_local_unit_id);


     CURSOR csr_org_emp_defaults
	IS
     select org_information1 job_status,
            org_information2 cond_of_emp,
            org_information3 full_part_time,
            org_information4 shift_work,
            org_information5 payroll_period,
            org_information6 agreed_working_hrs
     FROM hr_organization_information hoi,
          hr_organization_units hou
     WHERE hou.organization_id=g_legal_employer_id
       AND hoi.organization_id = hou.organization_id
       AND hoi.org_information_context='NO_EMPLOYMENT_DEFAULTS';



        CURSOR csr_all_local_unit_details
      IS
         SELECT hoi_le.org_information1 local_unit_id,
                hou_lu.NAME local_unit_name,
                hoi_lu.org_information1,
                hou_lu.location_id
           FROM hr_all_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_all_organization_units hou_lu,
                hr_organization_information hoi_lu
          WHERE hoi_le.organization_id = hou_le.organization_id
            AND hou_le.organization_id = g_legal_employer_id
            AND hoi_le.org_information_context = 'NO_LOCAL_UNITS'
            AND hou_lu.organization_id = hoi_le.org_information1
            AND hou_lu.organization_id = hoi_lu.organization_id
            AND hoi_lu.org_information_context = 'NO_LOCAL_UNIT_DETAILS';


CURSOR csr_period_add_info_result
	(p_assignment_id NUMBER,
	 p_ssb_code VARCHAR2,
	 p_report_date DATE)

   IS
SELECT	sum(prrv.result_value) result
FROM
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
	per_time_periods ptp,
	pay_run_results prr,
	pay_run_result_values prrv,
	pay_element_types_f pet,
	pay_element_type_extra_info pxi
WHERE
paa.assignment_id =p_assignment_id
and paa.payroll_action_id = ppa.payroll_action_id
and ptp.time_period_id = ppa.time_period_id
and p_report_date between ptp.start_date and ptp.end_date
and ppa.effective_date between ptp.start_date and ptp.end_date
and paa.assignment_action_id = prr.assignment_action_id
and prr.element_type_id = pet.element_type_id
and pet.element_type_id = pxi.element_type_id
and pxi.eei_information_category = 'NO_SSB_CODES'
and pxi.eei_information3 = 'ADD_INFO'
and pxi.eei_information2 = p_ssb_code
and to_char(prrv.input_value_id) = pxi.eei_information1
and prrv.run_result_id = prr.run_result_id
order by pxi.eei_information2;

CURSOR csr_year_add_info_result
	(p_assignment_id NUMBER,
	 p_ssb_code VARCHAR2,
	 p_report_date DATE)
   IS
SELECT	sum(prrv.result_value) result
FROM
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
	pay_run_results prr,
	pay_run_result_values prrv,
	pay_element_types_f pet,
	pay_element_type_extra_info pxi
WHERE
paa.assignment_id =p_assignment_id
and paa.payroll_action_id = ppa.payroll_action_id
and ppa.effective_date between trunc(p_report_date,'Y') and p_report_date
and paa.assignment_action_id = prr.assignment_action_id
and prr.element_type_id = pet.element_type_id
and pet.element_type_id = pxi.element_type_id
and pxi.eei_information_category = 'NO_SSB_CODES'
and pxi.eei_information3 = 'ADD_INFO'
and pxi.eei_information2 = p_ssb_code
and to_char(prrv.input_value_id) = pxi.eei_information1
and prrv.run_result_id = prr.run_result_id
order by pxi.eei_information2;

CURSOR csr_payroll_details
       (p_payroll_id NUMBER,
        p_report_date DATE)
    IS
SELECT  end_date,
        start_date
from per_time_periods
where payroll_id = p_payroll_id
and p_report_date BETWEEN start_date and end_date;

CURSOR csr_previous_period
       (p_payroll_id NUMBER,
        p_report_date DATE)
    IS
SELECT  max(end_date) prev_end_date
from per_time_periods
where payroll_id = p_payroll_id
and end_date < p_report_date;

  --
  l_csr_org_emp_defaults_rec csr_org_emp_defaults%ROWTYPE;
  l_csr_payroll_details_rec csr_payroll_details%ROWTYPE;
  l_csr_previous_period_rec csr_previous_period%ROWTYPE;
  l_all_local_unit_details_rec csr_all_local_unit_details%ROWTYPE;
  l_year_add_info_result_rec csr_year_add_info_result%ROWTYPE;
  l_period_add_info_result_rec csr_period_add_info_result%ROWTYPE;
  l_assact_id  NUMBER;
  l_person_id  NUMBER := -1;
  l_action_info_id NUMBER;
  l_ovn        NUMBER;
  l_asg_rec    csr_assignments%ROWTYPE;

  l_ssb_code_0010_ptd       NUMBER;
  l_ssb_code_0010_ytd       NUMBER;
  l_ssb_code_0020_ptd       NUMBER;
  l_ssb_code_0020_ytd       NUMBER;
  l_ssb_code_0010_hrs_ptd   NUMBER;
  l_ssb_code_0010_hrs_ytd   NUMBER;
  l_ssb_code_0030_ytd       NUMBER;
  l_ssb_code_0035_ytd       NUMBER;
  l_ssb_code_0035_hrs_ytd   NUMBER;
  l_ssb_code_0037_ytd       NUMBER;
  l_ssb_code_0038_ytd       NUMBER;
  l_ssb_code_0038_pyqtd     NUMBER;
  l_ssb_code_0040_ytd       NUMBER;
  l_ssb_code_0041_ytd       NUMBER;

  l_ptd_defined_balance_id  NUMBER;
  l_ytd_defined_balance_id  NUMBER;
  l_pyqtd_defined_balance_id NUMBER;
  l_effective_date DATE;

  --
 BEGIN
  --
  --
  -- Setup legislative parameters as global values for future use.
  --
  set_parameters(p_payroll_action_id);


        g_payroll_action_id :=p_payroll_action_id;
        g_business_group_id := null;
        g_legal_employer_id := null;
        g_sp_org_id         := null;
        g_legal_employer_id := null;
        g_version           := null;
        g_archive := null;

        GET_ALL_PARAMETERS
                (p_payroll_action_id
        		,g_business_group_id
        		,g_effective_date
			,g_sp_org_id
        		,g_legal_employer_id
                  ,g_version
        		,g_archive
        );


        IF g_archive = 'Y'
        THEN


 for l_all_local_unit_details_rec in csr_all_local_unit_details loop

  --
  FOR l_asg_rec IN csr_assignments(l_all_local_unit_details_rec.local_unit_id, p_start_person, p_end_person, g_report_date) LOOP
   --
   --
   -- Create assignment action for archive process.
   --
   OPEN CSR_PAYROLL_DETAILS (l_asg_rec.payroll_id, g_effective_date);
   FETCH CSR_PAYROLL_DETAILS INTO l_csr_payroll_details_rec;
   CLOSE CSR_PAYROLL_DETAILS;

   IF  l_csr_payroll_details_rec.end_date > g_effective_date THEN
       OPEN csr_previous_period (l_asg_rec.payroll_id, g_effective_date);
       FETCH csr_previous_period INTO l_csr_previous_period_rec;
       CLOSE csr_previous_period;

       l_effective_date := l_csr_previous_period_rec.prev_end_date;

   ELSE

       l_effective_date := g_effective_date;

   END IF;

   SELECT pay_assignment_actions_s.nextval INTO l_assact_id FROM dual;
   hr_nonrun_asact.insact
   (l_assact_id
   ,l_asg_rec.assignment_id
   ,p_payroll_action_id
   ,p_chunk
   ,NULL);
   --
   --
   -- Create assignment action archive information :-
   --
   --

   OPEN csr_org_emp_defaults;
   FETCH csr_org_emp_defaults INTO l_csr_org_emp_defaults_rec;
   CLOSE csr_org_emp_defaults;

                       pay_action_information_api.create_action_information (
                               p_action_information_id=> l_action_info_id,
                               p_action_context_id=> l_assact_id,
                               p_action_context_type=> 'AAP',
                               p_object_version_number=> l_ovn,
                               p_effective_date=> g_effective_date,
                               p_assignment_id => l_asg_rec.assignment_id,
                               p_action_information_category=> 'EMEA REPORT INFORMATION',
                               p_action_information1=> 'PYNOSSTA',
                               p_action_information2=> 'ASG',
                               p_action_information3=> l_asg_rec.local_unit,
                               p_action_information4=> to_char(l_asg_rec.person_id),
                               p_action_information5=> l_asg_rec.full_name,
                               p_action_information6=> l_asg_rec.national_identifier,
                               p_action_information7=> l_asg_rec.employee_number,
                               p_action_information8=> l_asg_rec.seniority,
                               p_action_information9=> l_asg_rec.Position_code,
                               p_action_information10=> l_asg_rec.work_title,
                               p_action_information11=> nvl(l_asg_rec.job_status,l_csr_org_emp_defaults_rec.job_status),
                               p_action_information12=> nvl(l_asg_rec.cond_of_emp,l_csr_org_emp_defaults_rec.cond_of_emp),
                               p_action_information13=> nvl(l_asg_rec.full_part_time,l_csr_org_emp_defaults_rec.full_part_time),
                               p_action_information14=> nvl(l_asg_rec.shift_work,l_csr_org_emp_defaults_rec.shift_work),
                               p_action_information15=> nvl(l_asg_rec.agreed_working_hrs,l_csr_org_emp_defaults_rec.agreed_working_hrs),
                               p_action_information16=> l_asg_rec.spl_info_1,
                               p_action_information17=> l_asg_rec.spl_info_2,
                               p_action_information18=> l_asg_rec.spl_info_3,
                               p_action_information19=> l_asg_rec.hourly_salaried_code,
                               p_action_information20=> nvl(l_asg_rec.payroll_period,l_csr_org_emp_defaults_rec.payroll_period)
                               );

--


l_ptd_defined_balance_id := get_defined_balance_id('SUMMED_RESULTS_ASG_ELE_CODE_PTD');
l_ytd_defined_balance_id := get_defined_balance_id('SUMMED_RESULTS_ASG_ELE_CODE_YTD');
l_pyqtd_defined_balance_id := get_defined_balance_id('SUMMED_RESULTS_ASG_ELE_CODE_PYLQ');

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0010');

begin
l_ssb_code_0010_ptd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ptd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

begin
l_ssb_code_0010_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0020');
begin
l_ssb_code_0020_ptd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ptd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;


begin
l_ssb_code_0020_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;


OPEN csr_period_add_info_result(l_asg_rec.assignment_id,'SSB CODE 0010',l_effective_date);
FETCH csr_period_add_info_result INTO l_ssb_code_0010_hrs_ptd;
CLOSE csr_period_add_info_result;


OPEN csr_year_add_info_result(l_asg_rec.assignment_id,'SSB CODE 0010',l_effective_date);
FETCH csr_year_add_info_result INTO l_ssb_code_0010_hrs_ytd;
CLOSE csr_year_add_info_result;


pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0030');
begin
l_ssb_code_0030_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0035');
begin
l_ssb_code_0035_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;

exception
	when no_data_found then
	null;
end;

OPEN csr_year_add_info_result(l_asg_rec.assignment_id,'SSB CODE 0035',l_effective_date);
FETCH csr_year_add_info_result INTO l_ssb_code_0035_hrs_ytd;
CLOSE csr_year_add_info_result;

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0037');
begin
l_ssb_code_0037_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0038');
begin
l_ssb_code_0038_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

begin
l_ssb_code_0038_pyqtd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_pyqtd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0040');
begin
l_ssb_code_0040_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;

pay_balance_pkg.set_context('SOURCE_TEXT','SSB CODE 0041');
begin
l_ssb_code_0041_ytd := to_char(pay_balance_pkg.get_value(p_defined_balance_id => l_ytd_defined_balance_id,
                                                         p_assignment_id      => l_asg_rec.assignment_id,
                                                         p_virtual_date       => l_effective_date),'999999999D99') ;
exception
	when no_data_found then
	null;
end;


                       pay_action_information_api.create_action_information (
                               p_action_information_id=> l_action_info_id,
                               p_action_context_id=> l_assact_id,
                               p_action_context_type=> 'AAP',
                               p_object_version_number=> l_ovn,
                               p_effective_date=> g_effective_date,
                               p_assignment_id => l_asg_rec.assignment_id,
                               p_action_information_category=> 'EMEA REPORT INFORMATION',
                               p_action_information1=> 'PYNOSSTA',
                               p_action_information2=> 'ASG SAL',
                               p_action_information3=> l_asg_rec.local_unit,
                               p_action_information4=> l_asg_rec.employee_number,
                               p_action_information5=> l_asg_rec.national_identifier,
                               p_action_information6=> nvl(l_ssb_code_0010_ptd,0),
                               p_action_information7=> nvl(l_ssb_code_0010_ytd,0),
                               p_action_information8=> nvl(l_ssb_code_0020_ptd,0),
                               p_action_information9=> nvl(l_ssb_code_0020_ytd,0),
                               p_action_information10=> round(nvl(l_ssb_code_0010_hrs_ptd,0)),
                               p_action_information11=> round(nvl(l_ssb_code_0010_hrs_ytd,0)),
                               p_action_information12=> nvl(l_ssb_code_0030_ytd,0),
                               p_action_information13=> nvl(l_ssb_code_0035_ytd,0),
                               p_action_information14=> round(nvl(l_ssb_code_0035_hrs_ytd,0)),
                               p_action_information15=> nvl(l_ssb_code_0037_ytd,0),
                               p_action_information16=> nvl(l_ssb_code_0038_ytd,0),
                               p_action_information17=> nvl(l_ssb_code_0038_pyqtd,0),
                               p_action_information18=> nvl(l_ssb_code_0040_ytd,0),
                               p_action_information19=> nvl(l_ssb_code_0041_ytd,0)
                               );

   --
  END LOOP; -- assignments within the local unit
 END LOOP; --local unit
END IF; --Archive
  --
 END assignment_action_code;
 --
 --
 -- -----------------------------------------------------------------------------
 --
 -- -----------------------------------------------------------------------------
 --
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
null;
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


       l_IANA_charset := HR_NO_UTILITY.get_IANA_charset ;
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

                                IF l_str9 IN ('STATEMENT_PROVIDER','LOCAL_UNIT','EMPLOYEE_DETAILS','EMPLOYEE',
                                              'EMPLOYEE_SALARY','LOCAL_UNIT_END','FILLER','STATEMENT_PROVIDER_END'
				               ,'END_EMPLOYEE_DETAILS','END_EMPLOYEE','END_EMPLOYEE_SALARY',
				               'END_LOCAL_UNIT_END','END_LOCAL_UNIT','END_FILLER',
				               'END_STATEMENT_PROVIDER_END','END_STATEMENT_PROVIDER'
                                              ) THEN

                                                IF l_str9 IN ('STATEMENT_PROVIDER','LOCAL_UNIT','EMPLOYEE_DETAILS',
                                                               'EMPLOYEE', 'EMPLOYEE_SALARY','LOCAL_UNIT_END','FILLER',
                                                               'STATEMENT_PROVIDER_END') THEN
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
--
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


CURSOR csr_version (p_payroll_action_id NUMBER)
IS
SELECT  fnd_date.canonical_to_date(action_information5) report_date,
      action_information6 version,
      nvl(action_information8,action_information4) name_sp
FROM pay_action_information pai
WHERE pai.action_context_id = p_payroll_action_id
AND   pai.action_context_type='PA'
AND   pai.action_information_category='EMEA REPORT DETAILS'
AND   pai.action_information1='PYNOSSTA';


CURSOR csr_legal_employer_details (p_payroll_action_id NUMBER)
IS
SELECT
      action_information1,
      action_information2,
      action_information3,
      action_information4,
      action_information5,
      action_information6,
      action_information7,
      action_information8
      FROM pay_action_information pai
WHERE pai.action_context_id = p_payroll_action_id
AND   pai.action_context_type='PA'
AND   pai.action_information_category='EMEA REPORT INFORMATION'
AND   pai.action_information1='PYNOSSTA'
AND   pai.action_information2='LE';

CURSOR csr_local_unit_details (p_payroll_action_id NUMBER)
IS
SELECT
      action_information1,
      action_information2,
      action_information3,
      action_information4,
      action_information5,
      action_information6,
      action_information7,
      action_information8
FROM pay_action_information pai
WHERE pai.action_context_id = p_payroll_action_id
AND   pai.action_context_type='PA'
AND   pai.action_information_category='EMEA REPORT INFORMATION'
AND   pai.action_information1='PYNOSSTA'
AND   pai.action_information2='LU';

CURSOR csr_get_employee_details (p_payroll_action_id NUMBER,
                                 p_local_unit_id NUMBER)
IS
	SELECT
	      pai.action_information6 national_identifier,
	      pai.action_information7 employee_number,
	      pai.action_information8 seniority,
	      pai.action_information9 position_code,
	      pai.action_information10 work_title,
	      pai.action_information11 job_status,
	      pai.action_information12 cond_of_emp,
	      pai.action_information13 full_part_time,
	      pai.action_information14 shift_work,
	      pai.action_information15 agreed_working_hrs,
	      pai.action_information16 spl_info_1,
	      pai.action_information17 spl_info_2,
	      pai.action_information18 spl_info_3,
	      pai.action_information19 hourly_salaried,
	      pai.action_information20 payroll_period,
	      pai_sal.action_information6 SSB_CODE_0010_PTD,
	      pai_sal.action_information7 SSB_CODE_0010_YTD,
	      pai_sal.action_information8 SSB_CODE_0020_PTD,
	      pai_sal.action_information9 SSB_CODE_0020_YTD,
	      pai_sal.action_information10 SSB_CODE_0010_HRS_PTD,
	      pai_sal.action_information11 SSB_CODE_0010_HRS_YTD,
	      pai_sal.action_information12 SSB_CODE_0030_YTD,
	      pai_sal.action_information13 SSB_CODE_0035_YTD,
	      pai_sal.action_information14 SSB_CODE_0035_HRS_YTD,
	      pai_sal.action_information15 SSB_CODE_0037_YTD,
	      pai_sal.action_information16 SSB_CODE_0038_YTD,
	      pai_sal.action_information17 SSB_CODE_0038_PYQTD,
	      pai_sal.action_information18 SSB_CODE_0040_YTD,
	      pai_sal.action_information19 SSB_CODE_0041_YTD
	FROM
	     pay_payroll_actions paa,
	     pay_assignment_actions assg,
	     pay_action_information pai,
	     pay_action_information pai_sal
	WHERE
	    paa.payroll_action_id = p_payroll_action_id
	AND assg.payroll_action_id = paa.payroll_action_id
	AND pai.action_context_id= assg.assignment_action_id
	AND pai.action_context_type='AAP'
	AND pai.action_information_category='EMEA REPORT INFORMATION'
	AND pai.action_information1='PYNOSSTA'
	AND pai.action_information2='ASG'
	AND pai.action_information3=p_local_unit_id
	AND pai_sal.action_context_id= assg.assignment_action_id
	AND pai_sal.action_context_type='AAP'
	AND pai_sal.action_information_category='EMEA REPORT INFORMATION'
	AND pai_sal.action_information1='PYNOSSTA'
	AND pai_sal.action_information2='ASG SAL'
	AND pai_sal.action_information3=p_local_unit_id;

l_employee_rec csr_get_employee_details%rowtype;
l_local_unit_details_rec csr_local_unit_details%rowtype;
l_legal_employer_details_rec csr_legal_employer_details%rowtype;
l_version_rec csr_version%rowtype;



l_per_lu_counter      NUMBER;
l_per_lu_counter_eft  NUMBER;
l_counter             NUMBER;
l_total               NUMBER;
l_total_eft           NUMBER;
l_count               NUMBER;
l_payroll_action_id   NUMBER;
l_lu_counter_reset    VARCHAR2(10);
l_prev_local_unit     VARCHAR2(15);


BEGIN

l_per_lu_counter:=0;
l_per_lu_counter_eft:=0;
l_total :=0;
l_total_eft :=3;
l_counter:=0;
l_prev_local_unit := '-9999';
l_lu_counter_reset := 'N';


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

        hr_utility.set_location('Entered Procedure GETDATA',10);

        OPEN csr_version(l_payroll_action_id);
        FETCH csr_version INTO l_version_rec;
        CLOSE csr_version;


        /* Get the File Header Information */
        OPEN csr_legal_employer_details(l_payroll_action_id);
        FETCH csr_legal_employer_details INTO l_legal_employer_details_rec;
        CLOSE csr_legal_employer_details;

        hr_utility.set_location('Before populating pl/sql table',20);

        xml_tab(l_counter).TagName  :='STATEMENT_PROVIDER';
        xml_tab(l_counter).TagValue :='STATEMENT_PROVIDER';
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ORG_NUMBER_SV';
        xml_tab(l_counter).TagValue := '939319891';  -- Fixed value legal entity number of Oracle.
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='RECORD_ONE';
        xml_tab(l_counter).TagValue := '1';
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='CHAR_CODE';
        xml_tab(l_counter).TagValue := '2';
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='VERSION';
        xml_tab(l_counter).TagValue := l_version_rec.version;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='DATE';
        xml_tab(l_counter).TagValue := to_char(l_version_rec.report_date,'YYYYMMDD');
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ORG_NUMBER_LE';
        xml_tab(l_counter).TagValue := nvl(l_legal_employer_details_rec.action_information8,l_legal_employer_details_rec.action_information5);
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ORG_NUMBER_SP_LE';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.action_information5;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='NAME_SP';
        xml_tab(l_counter).TagValue := nvl(l_version_rec.name_sp,l_legal_employer_details_rec.action_information4);
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='ADDRESS_SP';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.action_information6;
	l_counter:=l_counter+1;

        xml_tab(l_counter).TagName  :='POSTAL_CODE_SP';
        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.action_information7;
	l_counter:=l_counter+1;



                FOR l_local_unit_details_rec IN csr_local_unit_details(l_payroll_action_id)
                LOOP

			-- Local Unit Data
		        xml_tab(l_counter).TagName  :='LOCAL_UNIT';
		        xml_tab(l_counter).TagValue := 'LOCAL_UNIT';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUMBER_LU';
		        xml_tab(l_counter).TagValue := l_local_unit_details_rec.action_information5;
			l_counter:=l_counter+1;


		        xml_tab(l_counter).TagName  :='RECORD_TWO';
		        xml_tab(l_counter).TagValue := '2';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUMBER_LE';
		        xml_tab(l_counter).TagValue := l_legal_employer_details_rec.action_information5;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUMBER_SP';
		        xml_tab(l_counter).TagValue := nvl(l_legal_employer_details_rec.action_information8,l_legal_employer_details_rec.action_information5);
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='NAME_LU';
		        xml_tab(l_counter).TagValue := l_local_unit_details_rec.action_information4;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='CONF_CODE';
		        xml_tab(l_counter).TagValue := l_local_unit_details_rec.action_information8;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ADDRESS_LU';
		        xml_tab(l_counter).TagValue := l_local_unit_details_rec.action_information6;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='POSTAL_CODE_LU';
		        xml_tab(l_counter).TagValue := l_local_unit_details_rec.action_information7;
			l_counter:=l_counter+1;


			-- Employee Data

			l_total_eft := l_total_eft + 2;
		FOR l_get_employee_details_rec IN csr_get_employee_details(l_payroll_action_id, to_number(l_local_unit_details_rec.action_information3))
		LOOP


/* Begins Employee record*/

			IF l_prev_local_unit <> l_local_unit_details_rec.action_information3 and l_lu_counter_reset = 'N' THEN
				l_per_lu_counter_eft := 2;
				l_per_lu_counter := 0;
				l_lu_counter_reset := 'Y';
			END IF;


			l_per_lu_counter := l_per_lu_counter +1;
			l_per_lu_counter_eft := l_per_lu_counter_eft +2;
			l_total:= l_total + 1;
			l_total_eft:= l_total_eft + 2;

		        xml_tab(l_counter).TagName  :='EMPLOYEE_DETAILS';
		        xml_tab(l_counter).TagValue :='EMPLOYEE_DETAILS';
		        l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMPLOYEE';
		        xml_tab(l_counter).TagValue :='EMPLOYEE';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUMBER_LU';
		        xml_tab(l_counter).TagValue := l_local_unit_details_rec.action_information5;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='RECORD_THREE';
		        xml_tab(l_counter).TagValue := '3';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='NI';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.national_identifier;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMP_NUM';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.employee_number;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='WORK_TITLE';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.work_title;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='POSITION_CODE';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.position_code;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='JOB_STATUS';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.job_status;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='COND_OF_EMP';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.cond_of_emp;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='FULL_PART_TIME';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.full_part_time;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SHIFT_WORK';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.shift_work;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='AGREED_WORK_HRS';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.agreed_working_hrs;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='HOURLY_SALARIED';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.hourly_salaried;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='PAYROLL_PERIOD';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.payroll_period;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SENIORITY';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.seniority;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SPL_INFO_1';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.spl_info_1;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SPL_INFO_2';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.spl_info_2;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SPL_INFO_3';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.spl_info_3;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMPLOYEE';
		        xml_tab(l_counter).TagValue :='END_EMPLOYEE';
			l_counter:=l_counter+1;

/* Ends Employee record*/
/* Begins Salary record*/

		        xml_tab(l_counter).TagName  :='EMPLOYEE_SALARY';
		        xml_tab(l_counter).TagValue :='EMPLOYEE_SALARY';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUMBER_LU';
		        xml_tab(l_counter).TagValue :=l_local_unit_details_rec.action_information5;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='RECORD_FOUR';
		        xml_tab(l_counter).TagValue :='4';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='NI';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.national_identifier;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMP_NUM';
		        xml_tab(l_counter).TagValue := l_get_employee_details_rec.employee_number;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0010_PTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0010_PTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0010_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0010_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0020_PTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0020_PTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0020_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0020_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0010_HRS_PTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0010_HRS_PTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0010_HRS_PTD_EFT';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0010_HRS_PTD*10;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0010_HRS_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0010_HRS_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0010_HRS_YTD_EFT';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0010_HRS_YTD*10;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0030_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0030_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0035_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0035_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0035_HRS_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0035_HRS_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0035_HRS_YTD_EFT';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0035_HRS_YTD*10;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0037_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0037_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0038_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0038_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0038_PYQTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0038_PYQTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0040_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0040_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='SSB_CODE_0041_YTD';
		        xml_tab(l_counter).TagValue :=l_get_employee_details_rec.SSB_CODE_0041_YTD;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMPLOYEE_SALARY';
		        xml_tab(l_counter).TagValue :='END_EMPLOYEE_SALARY';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='EMPLOYEE_DETAILS';
		        xml_tab(l_counter).TagValue :='END_EMPLOYEE_DETAILS';
			l_counter:=l_counter+1;

/* Ends Salary record*/


	END LOOP; -- employee

l_prev_local_unit := l_local_unit_details_rec.action_information3;
l_lu_counter_reset := 'N' ;

		        xml_tab(l_counter).TagName  :='LOCAL_UNIT_END';
		        xml_tab(l_counter).TagValue :='LOCAL_UNIT_END';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='ORG_NUMBER_LU';
		        xml_tab(l_counter).TagValue :=l_local_unit_details_rec.action_information5;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='RECORD_FIVE';
		        xml_tab(l_counter).TagValue :='5';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='TOTAL_RECORD_LU';
		        xml_tab(l_counter).TagValue :=l_per_lu_counter;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='TOTAL_RECORD_LU_EFT';
		        xml_tab(l_counter).TagValue :=l_per_lu_counter_eft;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='LOCAL_UNIT_END';
		        xml_tab(l_counter).TagValue :='END_LOCAL_UNIT_END';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='LOCAL_UNIT';
		        xml_tab(l_counter).TagValue := 'END_LOCAL_UNIT';
			l_counter:=l_counter+1;


END LOOP; -- Local Unit


		        xml_tab(l_counter).TagName  :='FILLER';
		        xml_tab(l_counter).TagValue :='FILLER';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='RECORD_SIX';
		        xml_tab(l_counter).TagValue :='6';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='FILLER';
		        xml_tab(l_counter).TagValue := 'END_FILLER';
			l_counter:=l_counter+1;


		        xml_tab(l_counter).TagName  :='STATEMENT_PROVIDER_END';
		        xml_tab(l_counter).TagValue :='STATEMENT_PROVIDER_END';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='RECORD_SEVEN';
		        xml_tab(l_counter).TagValue :='7';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='TOTAL_RECORD_SP';
		        xml_tab(l_counter).TagValue := l_total;
			l_counter:=l_counter+1;
		        xml_tab(l_counter).TagName  :='TOTAL_RECORD_SP_EFT';
		        xml_tab(l_counter).TagValue := l_total_eft;
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='STATEMENT_PROVIDER_END';
		        xml_tab(l_counter).TagValue :='END_STATEMENT_PROVIDER_END';
			l_counter:=l_counter+1;

		        xml_tab(l_counter).TagName  :='STATEMENT_PROVIDER';
		        xml_tab(l_counter).TagValue :='END_STATEMENT_PROVIDER';
		        l_counter := l_counter + 1;


        hr_utility.set_location('After populating pl/sql table',30);
        hr_utility.set_location('Entered Procedure GETDATA',10);


        WritetoCLOB (p_xml );

END POPULATE_DATA_DETAIL;

 --
END pay_no_sal_statistics_archive;

/
