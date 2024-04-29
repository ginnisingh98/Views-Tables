--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_TEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_TEL" AS
/* $Header: pyfitela.pkb 120.16.12000000.3 2007/03/20 06:54:37 dbehera noship $ */

 g_debug   boolean   :=  hr_utility.debug_enabled;

 TYPE lock_rec IS RECORD (
      archive_assact_id    NUMBER);

 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;

 g_lock_table   		          lock_table;

 g_index          	  NUMBER := -1;
 g_index_assact   	  NUMBER := -1;
 g_index_bal	      NUMBER := -1;
 g_package        	  VARCHAR2(33) := ' PAY_FI_ARCHIVE_TEL.';
 g_payroll_action_id  NUMBER;

 g_arc_payroll_action_id NUMBER;
 -- Record for Absence
TYPE ABSENCES IS RECORD
        (
            CATEGORY VARCHAR2(240),
            START_DATE DATE,
            END_DATE DATE
        );

        TYPE ABSENCES_RECORD
        IS TABLE OF ABSENCES
        INDEX BY BINARY_INTEGER;

        ABS_RECORDS ABSENCES_RECORD;

-- Globals to pick up all the parameter
					g_business_group_id 	NUMBER;
					g_effective_date DATE;
					g_pension_provider_id NUMBER;
					g_pension_ins_num varchar2(11);
					g_legal_employer_id NUMBER;
					g_local_unit_id NUMBER;
					g_archive varchar2(20);
					g_annual_report varchar2(20);
					g_ref_date DATE;


--End of Globals to pick up all the parameter
 g_format_mask 		VARCHAR2(50);
 g_err_num 			NUMBER;
 g_errm 			VARCHAR2(150);

 /* GET PARAMETER */
 FUNCTION GET_PARAMETER(
 	 p_parameter_string IN VARCHAR2
 	,p_token            IN VARCHAR2
 	,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  VARCHAR2(1):=' ';
   l_proc VARCHAR2(40):= g_package||' get parameter ';

 BEGIN
 --
 IF g_debug THEN
     hr_utility.set_location(' Entering Function GET_PARAMETER',10);
 END IF;
 l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
 --
   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   END IF;
   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
    l_start_pos,
    instr(p_parameter_string||' ',
    l_delimiter,l_start_pos)
    - l_start_pos);
     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
      instr(l_parameter,':',1,p_segment_number)+1,
      instr(l_parameter,':',1,p_segment_number+1) -1
      - instr(l_parameter,':',1,p_segment_number));
     END IF;
   END IF;
   --
   RETURN l_parameter;
 IF g_debug THEN
      hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
 END IF;
 END;
 /* GET ALL PARAMETERS */
 PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id IN   NUMBER    													-- In parameter
       ,p_business_group_id OUT  NOCOPY NUMBER    			-- Core parameter
       ,p_effective_date	OUT  NOCOPY Date				-- Core parameter
       ,p_pension_ins_num OUT  NOCOPY VARCHAR2      		-- User parameter
       ,p_legal_employer_id OUT  NOCOPY NUMBER      		-- User parameter
       ,p_local_unit_id  	OUT  NOCOPY NUMBER     			-- User parameter
       ,p_annual_report     OUT  NOCOPY VARCHAR2            -- User parameter
       ,p_ref_date	OUT  NOCOPY Date				   -- User parameter
       ,p_archive			OUT  NOCOPY  VARCHAR2           -- User parameter
       )
       IS
     CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
     SELECT
     PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'PENSION_INS_NUM') PPID
    ,TO_NUMBER  ( PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_ID') ) Legal
    ,TO_NUMBER  (PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_ID') ) Local_unit
    ,PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'REPORT') Annual_Report
    ,FND_DATE.CANONICAL_TO_DATE(PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'REF_DATE'))
    ,PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'ARCHIVE') ARCHIVE_OR_NOT
--    ,PAY_FI_ARCHIVE_TEL.GET_PARAMETER(legislative_parameters,'TEST') TEST_OR_NOT
    ,effective_date Effective_date
    ,business_group_id BG_ID		 FROM  pay_payroll_actions
    		 WHERE payroll_action_id = p_payroll_action_id;

    lr_parameter_info csr_parameter_info%ROWTYPE;

    l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';

 BEGIN
        fnd_file.put_line(fnd_file.log,'Entering Procedure GET_ALL_PARAMETER ');
         fnd_file.put_line(fnd_file.log,'Payroill Action iD   ' || p_payroll_action_id );
			OPEN csr_parameter_info (p_payroll_action_id);
			--FETCH csr_parameter_info into lr_parameter_info;
							 FETCH csr_parameter_info
							 INTO	p_pension_ins_num
									,p_legal_employer_id
									,p_local_unit_id
									,p_annual_report
 									,p_ref_date
									,p_archive
									,p_effective_date
									,p_business_group_id;
			CLOSE csr_parameter_info;

        fnd_file.put_line(fnd_file.log,'After  csr_parameter_info in  ' );
        fnd_file.put_line(fnd_file.log,'After  p_pension_provider_id  '  || g_pension_provider_id);
        fnd_file.put_line(fnd_file.log,'After  p_legal_employer_id  in  '  || p_legal_employer_id);
        fnd_file.put_line(fnd_file.log,'After  p_local_unit_id in  ' || p_local_unit_id  );
        fnd_file.put_line(fnd_file.log,'After  p_archive' || p_archive  );

            IF g_debug THEN
                hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
            END IF;
END GET_ALL_PARAMETERS;


 /* RANGE CODE */
 PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
 		     ,p_sql    OUT   NOCOPY VARCHAR2)
 IS
     l_action_info_id NUMBER;
     l_ovn NUMBER;
     l_business_group_id NUMBER;
     l_start_date VARCHAR2(30);
     l_end_date VARCHAR2(30);
     l_effective_date DATE;
     l_consolidation_set NUMBER;
     l_defined_balance_id NUMBER := 0;
     l_count NUMBER := 0;
     l_prev_prepay		NUMBER := 0;
     l_canonical_start_date	DATE;
     l_canonical_end_date    DATE;
     l_payroll_id		NUMBER;
     l_prepay_action_id	NUMBER;
     l_actid NUMBER;
     l_assignment_id NUMBER;
     l_action_sequence NUMBER;
     l_assact_id     NUMBER;
     l_pact_id NUMBER;
     l_flag NUMBER := 0;
     l_element_context VARCHAR2(5);


-- Archiving the data , as this will fire once

	Cursor csr_pension_provider
			( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE
			 , csr_v_pension_ins_num  hr_organization_information.org_information1%TYPE
			 ,csr_v_effective_date  DATE  )
				IS
					SELECT  o1.name,
                            hoi2.ORG_INFORMATION3,
                            hoi2.ORG_INFORMATION4,
                            hoi2.ORG_INFORMATION5,
                            hoi2.ORG_INFORMATION8
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =   csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_PROVIDERS'
					AND  hoi2.org_information6=csr_v_pension_ins_num;


    lr_pension_provider csr_pension_provider%ROWTYPE;

	CURSOR csr_pension_provider_details (
    csr_v_pension_provider_id   hr_organization_information.organization_id%TYPE
		      )
			  IS
				 SELECT o1.NAME
				   FROM hr_organization_units o1
					, hr_organization_information hoi1
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_pension_provider_id
					AND hoi1.org_information_context = 'CLASS'
					AND hoi1.org_information1 = 'FR_PENSION' ;

    lr_pension_provider_details      csr_pension_provider_details%ROWTYPE;

/*
	CURSOR csr_Pension_group_code (
    csr_v_pension_provider_id   hr_organization_information.organization_id%TYPE
		      )
			  IS
				 SELECT o1.NAME,hoi2.ORG_INFORMATION2
				   FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_pension_provider_id
					AND hoi1.org_information_context = 'CLASS'
					AND hoi1.org_information1 = 'FR_PENSION'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_TYPES'
					AND hoi2.org_information1='TEL';

			      Lr_Pension_group_code      csr_Pension_group_code%ROWTYPE;

	CURSOR csr_Department_code (
    csr_v_pension_provider_id   hr_organization_information.organization_id%TYPE
		      )
			  IS
				 SELECT hoi2.ORG_INFORMATION3
				   FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_pension_provider_id
					AND hoi1.org_information_context = 'CLASS'
					AND hoi1.org_information1 = 'FR_PENSION'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_DEPARTMENT_CODES';

			      lr_Department_code      csr_Department_code%ROWTYPE;
*/
-- Cursor to pick up Local Unit Details
        Cursor csr_Local_Unit_Details ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
		IS
			SELECT o1.name , hoi2.ORG_INFORMATION1
			FROM hr_organization_units o1
			, hr_organization_information hoi1
			, hr_organization_information hoi2
			WHERE  o1.business_group_id =g_business_group_id
			AND hoi1.organization_id = o1.organization_id
			AND hoi1.organization_id =  csr_v_local_unit_id
			AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
			AND hoi1.org_information_context = 'CLASS'
			AND o1.organization_id =hoi2.organization_id
			AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNIT_DETAILS';

    lr_Local_Unit_Details  csr_Local_Unit_Details%rowtype;

        CURSOR csr_all_local_unit_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE )
      IS
         SELECT hoi_le.org_information1 local_unit_id,
                hou_lu.NAME local_unit_name,
                hoi_lu.org_information1
           FROM hr_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_organization_units hou_lu,
                hr_organization_information hoi_lu
          WHERE hoi_le.organization_id = hou_le.organization_id
            AND hou_le.organization_id = csr_v_legal_employer_id
            AND hoi_le.org_information_context = 'FI_LOCAL_UNITS'
            AND hou_lu.organization_id = hoi_le.org_information1
            AND hou_lu.organization_id = hoi_lu.organization_id
            AND hoi_lu.org_information_context = 'FI_LOCAL_UNIT_DETAILS';

        Cursor csr_lu_pp_dtls (
            csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE
			, csr_v_pension_ins_num  hr_organization_information.org_information1%TYPE)
				IS
					SELECT hoi2.ORG_INFORMATION2
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_local_unit_id
					AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_LU_PENSION_PROVIDERS'
					AND  hoi2.org_information1=csr_v_pension_ins_num ;

        lr_lu_pp_dtls  csr_lu_pp_dtls%rowtype;


         l_Insurance_pol_number  VARCHAR2(240); --Pension Insurance Number
         l_Pension_group_code    varchar2(240); --
         l_Department		    varchar2(240); --sub disbursement Number
         l_old_Department varchar2(240);

-- Archiving the data , as this will fire once

 BEGIN

    fnd_file.put_line(fnd_file.log,'In  RANGE_CODE 0');

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
        g_effective_date := null;
        g_pension_provider_id := null;
	g_pension_ins_num := null;
        g_legal_employer_id := null;
        g_local_unit_id := null;
        g_annual_report:= null;
        g_archive := null;

        PAY_FI_ARCHIVE_TEL.GET_ALL_PARAMETERS
                (p_payroll_action_id
        		,g_business_group_id
        		,g_effective_date
        		,g_pension_ins_num
        		,g_legal_employer_id
        		,g_local_unit_id
        		,g_annual_report
			,g_ref_date
        		,g_archive
        );

		pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
		pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id);
		pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_ref_date));
		pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
		pay_balance_pkg.set_context('SOURCE_ID',NULL);
		pay_balance_pkg.set_context('TAX_GROUP',NULL);
		pay_balance_pkg.set_context('ORGANIZATION_ID',g_pension_provider_id);

        IF g_archive = 'Y'
        THEN
                 -- *****************************************************************************
                 -- TO pick up the required details for Pension Providers

                	OPEN  csr_pension_provider( g_legal_employer_id,
                                                g_pension_ins_num,
                                                g_ref_date);
                        FETCH csr_pension_provider
                        INTO lr_pension_provider;
                	CLOSE csr_pension_provider;
                -- *****************************************************************************
                /*
                	OPEN  csr_pension_group_code(g_pension_provider_id);
                        FETCH csr_pension_group_code
                        INTO lr_pension_group_code;
                	CLOSE csr_pension_group_code;
                	OPEN  csr_department_code(g_pension_provider_id);
                        FETCH csr_department_code
                        INTO lr_department_code;
                	CLOSE csr_department_code;

                        l_Insurance_pol_number  :=lr_pension_provider.ORG_INFORMATION8;
                        l_Pension_group_code    :=lr_pension_provider.ORG_INFORMATION5;
                        fnd_file.put_line(fnd_file.log,'l_Insurance_pol_number ==> '||l_Insurance_pol_number );
                        fnd_file.put_line(fnd_file.log,'l_Pension_group_code ==> '||l_Pension_group_code );
                */
                -- *****************************************************************************
                    -- To pick Up the Pension Provider Name
                	OPEN  csr_pension_provider_details(lr_pension_provider.org_information4);
                		FETCH csr_pension_provider_details INTO lr_pension_provider_details;
                	CLOSE csr_pension_provider_details;
                -- *****************************************************************************
                 -- To pick Up the Local Unit Name
                OPEN  csr_Local_Unit_Details( g_local_unit_id );
                        FETCH csr_Local_Unit_Details
                        INTO lr_Local_Unit_Details;
                CLOSE csr_Local_Unit_Details;
                -- *****************************************************************************
                -- If local Unit is given
                /*
                      IF g_local_unit_id IS NOT NULL
                      THEN
                                -- *********************************************************************
                                -- To pick up the Sub-disbursement Number for the given Local Unit
                                  OPEN  csr_Local_Unit_Details( g_local_unit_id );
                                    FETCH csr_Local_Unit_Details
                                    INTO lr_Local_Unit_Details;
                                  CLOSE csr_Local_Unit_Details;
                                -- *********************************************************************

                                              pay_action_information_api.create_action_information (
                                               p_action_information_id=> l_action_info_id,
                                               p_action_context_id=> p_payroll_action_id,
                                               p_action_context_type=> 'PA',
                                               p_object_version_number=> l_ovn,
                                               p_effective_date=> g_effective_date,
                                               p_source_id=> NULL,
                                               p_source_text=> NULL,
                                               p_action_information_category=> 'EMEA REPORT INFORMATION',
                                               p_action_information1=> 'PYFITELA',
                                               p_action_information2=> 'LU',
                                               p_action_information3=> g_local_unit_id,
                                               p_action_information4=> lr_local_unit_details.NAME,
                                               p_action_information5=> lr_local_unit_details.ORG_INFORMATION1,
                                               p_action_information6=> NULL,
                                               p_action_information7=> NULL,
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
                                -- *********************************************************************

                                fnd_file.put_line(fnd_file.log,' ================================ ' );
                                fnd_file.put_line(fnd_file.log,'Local Unit Not Null' );
                                fnd_file.put_line(fnd_file.log,'Name          ==> '||lr_local_unit_details.NAME || '  ID==> ' ||g_local_unit_id);
                                fnd_file.put_line(fnd_file.log,'sub disburse  ==> '||lr_local_unit_details.ORG_INFORMATION1 );
                                fnd_file.put_line(fnd_file.log,'acti_info_id  ==> '||l_action_info_id );
                                fnd_file.put_line(fnd_file.log,' ================================ ' );
                -- *****************************************************************************
                -- If the Local unit is not selected then pick up all the local unit details
                      ELSE
                                FOR lr_all_local_unit_details IN
                                csr_all_local_unit_details (g_legal_employer_id)
                                LOOP
                                       pay_action_information_api.create_action_information (
                                          p_action_information_id=> l_action_info_id,
                                          p_action_context_id=> p_payroll_action_id,
                                          p_action_context_type=> 'PA',
                                          p_object_version_number=> l_ovn,
                                          p_effective_date=> g_effective_date,
                                          p_source_id=> NULL,
                                          p_source_text=> NULL,
                                          p_action_information_category=> 'EMEA REPORT INFORMATION',
                                          p_action_information1=> 'PYFITELA',
                                          p_action_information2=> 'LU',
                                          p_action_information3=> lr_all_local_unit_details.local_unit_id,
                                          p_action_information4=> lr_all_local_unit_details.local_unit_name,
                                          p_action_information5=> lr_all_local_unit_details.ORG_INFORMATION1,
                                          p_action_information6=> NULL,
                                          p_action_information7=> NULL,
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
                                    END LOOP;
                        -- *****************************************************************************
                       END IF; -- END OF G_LOCAL_UNIT_ID NULL CHECK
                */
                -- *****************************************************************************
                      -- Insert the report Parameters
                          pay_action_information_api.create_action_information (
                            p_action_information_id=> l_action_info_id,
                            p_action_context_id=> p_payroll_action_id,
                            p_action_context_type=> 'PA',
                            p_object_version_number=> l_ovn,
                            p_effective_date=> g_effective_date,
                            p_source_id=> NULL,
                            p_source_text=> NULL,
                            p_action_information_category=> 'EMEA REPORT DETAILS',
                            p_action_information1=> 'PYFITELA',
                            p_action_information2=> lr_pension_provider_details.NAME,
                            p_action_information3=> lr_pension_provider.org_information4,
                            p_action_information4=> lr_pension_provider.NAME,
                            p_action_information5=> g_legal_employer_id,
                            p_action_information6=> lr_local_unit_details.NAME,
                            p_action_information7=> g_local_unit_id,
                            p_action_information8=> g_annual_report,
                            p_action_information9=> fnd_date.date_to_canonical ( g_ref_date ),
                            p_action_information10=> g_pension_ins_num,
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
                -- *****************************************************************************
                        fnd_file.put_line(fnd_file.log,' ================ ALL ================ ' );
                        fnd_file.put_line(fnd_file.log,'PENSION provider name ==> '||lr_pension_provider_details.NAME );
                        fnd_file.put_line(fnd_file.log,'PENSION provider ID   ==> '||g_pension_provider_id);
                        fnd_file.put_line(fnd_file.log,'Legal Emp Name        ==> '||lr_pension_provider.NAME);
                        fnd_file.put_line(fnd_file.log,'Legal Emp ID          ==> '||g_legal_employer_id);
                        fnd_file.put_line(fnd_file.log,'Local Unit Name       ==> '||lr_local_unit_details.NAME);
                        fnd_file.put_line(fnd_file.log,'Local Unit ID         ==> '||g_local_unit_id);
                        fnd_file.put_line(fnd_file.log,'acti_info_id          ==> '||l_action_info_id );
                        fnd_file.put_line(fnd_file.log,' ================================ ' );

                -- *****************************************************************************
                -- Information regarding the Legal Employer
                /*
                         pay_action_information_api.create_action_information (
                                  p_action_information_id=> l_action_info_id,
                                  p_action_context_id=> p_payroll_action_id,
                                  p_action_context_type=> 'PA',
                                  p_object_version_number=> l_ovn,
                                  p_effective_date=> g_effective_date,
                                  p_source_id=> NULL,
                                  p_source_text=> NULL,
                                  p_action_information_category=> 'EMEA REPORT INFORMATION',
                                  p_action_information1=> 'PYFITELA',
                                  p_action_information2=> 'LE',
                                  p_action_information3=>  g_legal_employer_id ,
                                  p_action_information4=> lr_pension_provider.NAME,
                                  p_action_information5=> lr_pension_provider.ORG_INFORMATION5,
                                  p_action_information6=> lr_pension_provider.ORG_INFORMATION6,
                                  p_action_information7=> lr_pension_provider.ORG_INFORMATION8,
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
                               */
                -- *****************************************************************************


    END IF; -- G_Archive End

         IF g_debug THEN
              hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
         END IF;
 EXCEPTION
 WHEN OTHERS
 THEN
    -- Return cursor that selects no rows
     p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
 END RANGE_CODE;


	 /* ASSIGNMENT ACTION CODE */
	 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS
		 CURSOR csr_prepaid_assignments_lu(p_payroll_action_id          	NUMBER,
			 p_start_person      	NUMBER,
			 p_end_person         NUMBER,
			 p_legal_employer_id			NUMBER,
			 p_local_unit_id				NUMBER,
			 p_pension_ins_num	 		VARCHAR2,
			 l_canonical_start_date	DATE,
			 l_canonical_end_date	DATE)
		 IS
		 SELECT act.assignment_id            assignment_id,
			act.assignment_action_id     run_action_id,
			act1.assignment_action_id    prepaid_action_id
		 FROM   pay_payroll_actions          ppa
			,pay_payroll_actions          appa
			,pay_payroll_actions          appa2
			,pay_assignment_actions       act
			,pay_assignment_actions       act1
			,pay_action_interlocks        pai
			,per_all_assignments_f        as1
			,hr_soft_coding_keyflex         hsck
			, per_all_people_f         pap
		 WHERE  ppa.payroll_action_id        = p_payroll_action_id
		 AND    appa.effective_date          BETWEEN l_canonical_start_date
			    AND     l_canonical_end_date
		 AND    as1.person_id                BETWEEN p_start_person
			    AND     p_end_person
		 AND    appa.action_type             IN ('R','Q')
			-- Payroll Run or Quickpay Run
		 AND    act.payroll_action_id        = appa.payroll_action_id
		 AND    act.source_action_id         IS NULL -- Master Action
		 AND    as1.assignment_id            = act.assignment_id
         AND     as1.person_id = pap.person_id
		 AND     pap.per_information24  = p_pension_ins_num
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
			                                 AND     as1.effective_end_date
		AND    ppa.effective_date           BETWEEN pap.effective_start_date
		 AND     pap.effective_end_date
		 AND    act.action_status            = 'C'  -- Completed
		 AND    act.assignment_action_id     = pai.locked_action_id
		 AND    act1.assignment_action_id    = pai.locking_action_id
		 AND    act1.action_status           = 'C' -- Completed
		 AND    act1.payroll_action_id     = appa2.payroll_action_id
		 AND    appa2.action_type            IN ('P','U')
		 AND    appa2.effective_date         BETWEEN l_canonical_start_date
				                                AND l_canonical_end_date
			-- Prepayments or Quickpay Prepayments
		 AND  hsck.SOFT_CODING_KEYFLEX_ID=as1.SOFT_CODING_KEYFLEX_ID
		AND   hsck.segment2 = to_char(p_local_unit_id)
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		ORDER BY act.assignment_id;

		CURSOR csr_prepaid_assignments_le(p_payroll_action_id          	NUMBER,
			 p_start_person      	NUMBER,
			 p_end_person         NUMBER,
			 p_legal_employer_id			NUMBER,
 			 p_pension_ins_num			VARCHAR2,
			 l_canonical_start_date	DATE,
			 l_canonical_end_date	DATE)
		 IS
		 SELECT act.assignment_id            assignment_id,
			act.assignment_action_id     run_action_id,
			act1.assignment_action_id    prepaid_action_id
		 FROM   pay_payroll_actions          ppa,
			pay_payroll_actions          appa,
			pay_payroll_actions          appa2,
			pay_assignment_actions       act,
			pay_assignment_actions       act1,
			pay_action_interlocks        pai,
			per_all_assignments_f        as1
			, per_all_people_f         pap
		 WHERE  ppa.payroll_action_id        = p_payroll_action_id
		 AND    appa.effective_date          BETWEEN l_canonical_start_date
			    AND     l_canonical_end_date
		 AND    as1.person_id                BETWEEN p_start_person
			    AND     p_end_person
		 AND    appa.action_type             IN ('R','Q')
			-- Payroll Run or Quickpay Run
		 AND    act.payroll_action_id        = appa.payroll_action_id
		 AND    act.source_action_id         IS NULL -- Master Action
		 AND    as1.assignment_id            = act.assignment_id
                 AND     as1.person_id = pap.person_id
		 AND     pap.per_information24  = p_pension_ins_num
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
		 AND     as1.effective_end_date
		 AND    ppa.effective_date           BETWEEN pap.effective_start_date
		 AND     pap.effective_end_date
		 AND    act.action_status            = 'C'  -- Completed
		 AND    act.assignment_action_id     = pai.locked_action_id
		 AND    act1.assignment_action_id    = pai.locking_action_id
		 AND    act1.action_status           = 'C' -- Completed
		 AND    act1.payroll_action_id       = appa2.payroll_action_id
		 AND    appa2.action_type            IN ('P','U')
		 AND    appa2.effective_date          BETWEEN l_canonical_start_date
				 AND l_canonical_end_date
			-- Prepayments or Quickpay Prepayments
		 AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		 ORDER BY act.assignment_id;

	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
				IS
					SELECT	 ue.creator_id
					FROM	ff_user_entities  ue,
							ff_database_items di
					WHERE	di.user_name = csr_v_Balance_Name
					AND	ue.user_entity_id = di.user_entity_id
					AND	ue.legislation_code = 'FI'
					AND	ue.business_group_id is NULL
					AND	ue.creator_type = 'B';

					lr_Get_Defined_Balance_Id  csr_Get_Defined_Balance_Id%rowtype;

		 l_count NUMBER := 0;
		 l_prev_prepay		NUMBER := 0;

		 l_canonical_start_date	DATE;
		 l_canonical_end_date    DATE;
		 l_pension_type  hr_organization_information.org_information1%TYPE ;


		 l_prepay_action_id	NUMBER;
		 l_actid NUMBER;
		 l_assignment_id NUMBER;
		 l_action_sequence NUMBER;
		 l_assact_id     NUMBER;
		 l_pact_id NUMBER;
		 l_flag NUMBER := 0;
		 l_defined_balance_id NUMBER :=0;
		 l_action_info_id NUMBER;
		 l_ovn NUMBER;
-- User pARAMETERS needed
        l_business_group_id	NUMBER;
        l_effective_date DATE;

        l_pension_provider_id	NUMBER;
        l_legal_employer_id	NUMBER;
        l_local_unit_id	NUMBER;
        l_archive varchar2(10);
-- End of User pARAMETERS needed

	 BEGIN
IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
			END IF;
	fnd_file.put_line(fnd_file.log,' ASSIGNMENT_ACTION_CODE ');

PAY_FI_ARCHIVE_TEL.GET_ALL_PARAMETERS
        (p_payroll_action_id
		,g_business_group_id
		,g_effective_date
		,g_pension_ins_num
		,g_legal_employer_id
		,g_local_unit_id
		,g_annual_report
		,g_ref_date
		,g_archive
);

        IF g_annual_report ='M'
        THEN
        		l_canonical_start_date :=LAST_DAY(ADD_MONTHS(g_ref_date , -1)  ) + 1 ;
		        l_canonical_end_date :=  LAST_DAY(g_ref_date);
        ELSIF g_annual_report ='Q'
        THEN
   		        l_canonical_start_date := TRUNC(g_ref_date, 'Q') ;
		        l_canonical_end_date := ADD_MONTHS(last_day(TRUNC(g_ref_date, 'Q') ), 2);
        ELSIF g_annual_report ='A'
        THEN
   		        l_canonical_start_date :=TRUNC(g_ref_date, 'Y') ;
		        l_canonical_end_date := ADD_MONTHS(last_day(TRUNC(g_ref_date, 'Y') ), 11);
        END IF;

		l_prepay_action_id := 0;

	fnd_file.put_line(fnd_file.log,' g_local_unit_id '|| g_local_unit_id);

		IF g_local_unit_id IS NOT NULL THEN
            fnd_file.put_line(fnd_file.log,' INSIDE IF LOCAL UNIT NOT NULL ');


            fnd_file.put_line(fnd_file.log,' p_payroll_action_id ==> ' || p_payroll_action_id);
            fnd_file.put_line(fnd_file.log,' g_legal_employer_id ==> ' || g_legal_employer_id);
            fnd_file.put_line(fnd_file.log,' g_local_unit_id ==> ' || g_local_unit_id);
            fnd_file.put_line(fnd_file.log,' g_pension_provider_id ==> ' || g_pension_provider_id);
            fnd_file.put_line(fnd_file.log,' g_effective_date ==> ' || g_effective_date);
            fnd_file.put_line(fnd_file.log,' l_canonical_start_date ==> ' || l_canonical_start_date);
            fnd_file.put_line(fnd_file.log,' l_canonical_end_date ==> ' || l_canonical_end_date);

            FOR rec_prepaid_assignments IN csr_prepaid_assignments_lu(p_payroll_action_id
				,p_start_person
				,p_end_person
				 ,g_legal_employer_id
				 ,g_local_unit_id
				 ,g_pension_ins_num
				,l_canonical_start_date
				,l_canonical_end_date)
				LOOP
					fnd_file.put_line(fnd_file.log,' LU Inside the Csr Prepaid Cursor ');
                    IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id THEN
						SELECT pay_assignment_actions_s.NEXTVAL
						INTO   l_actid
						FROM   dual;
						  --
						g_index_assact := g_index_assact + 1;
						g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */
					       -- Create the archive assignment action
						    hr_nonrun_asact.insact(l_actid
						  ,rec_prepaid_assignments.assignment_id
						  ,p_payroll_action_id
						  ,p_chunk
						  ,NULL);
						-- Create archive to prepayment assignment action interlock
						--
						--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
					END IF;
					-- create archive to master assignment action interlock
					--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
					l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
				END LOOP;

		ELSE
                    fnd_file.put_line(fnd_file.log,' INSIDE ELS LOCAL UNIT NULL ');
		  FOR rec_prepaid_assignments IN csr_prepaid_assignments_le(p_payroll_action_id
					,p_start_person
					,p_end_person
					 ,g_legal_employer_id
				 	 ,g_pension_ins_num
					,l_canonical_start_date
					,l_canonical_end_date)
					LOOP
                fnd_file.put_line(fnd_file.log,' LE Inside the Csr Prepaid Cursor ');
						IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id THEN
							SELECT pay_assignment_actions_s.NEXTVAL
							INTO   l_actid
							FROM   dual;
							  --
							g_index_assact := g_index_assact + 1;
							g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */
						       -- Create the archive assignment action
							    hr_nonrun_asact.insact(l_actid
							  ,rec_prepaid_assignments.assignment_id
							  ,p_payroll_action_id
							  ,p_chunk
							  ,NULL);
							-- Create archive to prepayment assignment action interlock
							--
							--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
						END IF;
						-- create archive to master assignment action interlock
						--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
						l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
					END LOOP;
		END IF;
         fnd_file.put_line(fnd_file.log,' After Ending Assignment Act Code  the Locking Cursor ');

		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
		 END IF;
	EXCEPTION
	  WHEN others THEN
		IF g_debug THEN
		    hr_utility.set_location('error raised assignment_action_code ',5);
		END if;
	    RAISE;

	END ASSIGNMENT_ACTION_CODE;
/*fffffffffffffffffffffffffff*/

 /* INITIALIZATION CODE */
 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
 IS
        l_action_info_id NUMBER;
         l_ovn NUMBER;
         l_count NUMBER := 0;
         l_business_group_id	NUMBER;
         l_start_date        VARCHAR2(20);
         l_end_date          VARCHAR2(20);
         l_effective_date	DATE;
         l_payroll_id		NUMBER;
         l_consolidation_set	NUMBER;
         l_prev_prepay		NUMBER := 0;

 BEGIN
         IF g_debug THEN
              hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
         END IF;
     fnd_file.put_line(fnd_file.log,'In INIT_CODE 0');

        g_payroll_action_id :=p_payroll_action_id;

        g_business_group_id := null;
        g_effective_date := null;
        g_pension_ins_num := null;
        g_legal_employer_id := null;
        g_local_unit_id := null;
        g_annual_report:= null;
        g_archive := null;

    	PAY_FI_ARCHIVE_TEL.GET_ALL_PARAMETERS
            (p_payroll_action_id
    		,g_business_group_id
    		,g_effective_date
    		,g_pension_ins_num
    		,g_legal_employer_id
    		,g_local_unit_id
    		,g_annual_report
		,g_ref_date
    		,g_archive
            );

     fnd_file.put_line(fnd_file.log,'In the  INITIALIZATION_CODE After Initiliazing the global parameter ' );

     IF g_debug THEN
          hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
     END IF;
 EXCEPTION
 WHEN OTHERS
 THEN
    g_err_num := SQLCODE;
         IF g_debug THEN
              hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',180);
         END IF;
 END INITIALIZATION_CODE;


 /* GET DEFINED BALANCE ID */
 FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2)
 RETURN NUMBER
 IS
 /* Cursor to retrieve Defined Balance Id */
         CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
         SELECT  u.creator_id
         FROM    ff_user_entities  u,
         	ff_database_items d
         WHERE   d.user_name = p_user_name
         AND     u.user_entity_id = d.user_entity_id
         AND     (u.legislation_code = 'FI' )
         AND     (u.business_group_id IS NULL )
         AND     u.creator_type = 'B';

     l_defined_balance_id ff_user_entities.user_entity_id%TYPE;
 BEGIN
         IF g_debug THEN
         	hr_utility.set_location(' Entering Function GET_DEFINED_BALANCE_ID',240);
         END IF;
         OPEN csr_def_bal_id(p_user_name);
         FETCH csr_def_bal_id
         INTO l_defined_balance_id;
         CLOSE csr_def_bal_id;
 RETURN l_defined_balance_id;
         IF g_debug THEN
         	hr_utility.set_location(' Leaving Function GET_DEFINED_BALANCE_ID',250);
         END IF;
 END GET_DEFINED_BALANCE_ID;


 /* ARCHIVE CODE */
 PROCEDURE ARCHIVE_CODE(
	p_assignment_action_id IN NUMBER
 	,p_effective_date      IN DATE)
 IS
/* Cursor to retrieve Archive Payroll Action Id */
    	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
		IS
    			SELECT	 ue.creator_id
    			FROM	ff_user_entities  ue,
    					ff_database_items di
    			WHERE	di.user_name = csr_v_Balance_Name
    			AND	ue.user_entity_id = di.user_entity_id
    			AND	ue.legislation_code = 'FI'
    			AND	ue.business_group_id is NULL
    			AND	ue.creator_type = 'B';

            lr_Get_Defined_Balance_Id  csr_Get_Defined_Balance_Id%rowtype;

			 l_archive_payact_id NUMBER;
			 l_record_count  	NUMBER;
			 l_actid NUMBER;
			 l_end_date 	per_time_periods.end_date%TYPE;
			 l_pre_end_date  per_time_periods.end_date%TYPE;
			 l_reg_payment_date 	per_time_periods.regular_payment_date%TYPE;
			 l_pre_reg_payment_date  per_time_periods.regular_payment_date%TYPE;
			 l_date_earned 	  pay_payroll_actions.date_earned%TYPE;
			 l_pre_date_earned pay_payroll_actions.date_earned%TYPE;
			 l_effective_date 	pay_payroll_actions.effective_date%TYPE;
			 l_pre_effective_date 	pay_payroll_actions.effective_date%TYPE;
			 l_run_payact_id NUMBER;
			 l_action_context_id	NUMBER;
			 g_archive_pact		NUMBER;
			 p_assactid		NUMBER;
			 l_time_period_id	per_time_periods.time_period_id%TYPE;
			 l_pre_time_period_id	per_time_periods.time_period_id%TYPE;
			 l_start_date		per_time_periods.start_date%TYPE;
			 l_pre_start_date	per_time_periods.start_date%TYPE;
			 l_fnd_session NUMBER := 0;
			 l_prev_prepay NUMBER := 0;

             l_action_info_id pay_action_information.action_information_id%TYPE;
             l_ovn pay_action_information.object_version_number%TYPE;
             l_flag number:=0;

         -- The place for Variables which fetches the values to be archived
            l_Insurance_pol_number  VARCHAR2(240); --Pension Insurance Number
            l_Employee_Pin			VARCHAR2(240);
            l_Pension_group_code    NUMBER; --

            l_Employee_name			VARCHAR2(240);
            l_Action_id             VARCHAR2(2);
            l_Pension_Start_date	DATE;
            l_Target_year           NUMBER; -- Target year for Annual income 19YY,  20YY or blank.
            l_Income                NUMBER;
            l_Benefit_in_Kind       NUMBER;
            l_Termination_date      DATE;
            l_Cause_of_termination  VARCHAR2(240);
            l_Yearly_TEL_Income     NUMBER;
            l_Benefit_in_Kind_prior NUMBER;
            l_LEL_Employment_start_date DATE;
            l_Shift_from_another    DATE;
            l_Currency              VARCHAR2(2) := '1'; -- 1 ==> EURO
            l_Employed_or_not       varchar2(15);

            l_old_pension_group_code VARCHAR2(240);
            l_new_pension_group_code VARCHAR2(240);
            l_old_Department VARCHAR2(240);
            l_new_Department		    VARCHAR2(240); --sub disbursement Number
            l_new_policy_number VARCHAR2(240);
            l_old_policy_number VARCHAR2(240);
            l_local_unit_id_fetched NUMBER;
            l_eit_local_unit NUMBER;


    -- Temp needed Variables
            l_person_id per_all_people_f.person_id%TYPE;
            l_assignment_id per_all_assignments_f.assignment_id%TYPE;


            l_EIT_Reported_or_not per_people_extra_info.PEI_INFORMATION5%TYPE;
            l_EIT_Insert_or_Update per_people_extra_info.PEI_INFORMATION6%TYPE;
            l_EIT_Last_reported per_people_extra_info.PEI_INFORMATION4%TYPE;
            l_current_value varchar2(240);

            l_Sal_subject_pension_MTD NUMBER := 0;
            l_bik_subject_pension_MTD NUMBER := 0;
            l_tax_exp_subject_pension_MTD NUMBER := 0;
            l_Sal_subject_pension_QTD NUMBER := 0;
            l_bik_subject_pension_QTD NUMBER := 0;
            l_tax_exp_subject_pension_QTD NUMBER := 0;

            l_Sal_subject_pension_YTD NUMBER := 0;
            l_bik_subject_pension_YTD NUMBER := 0;
            l_tax_exp_subject_pension_YTD NUMBER := 0;

            l_sal_sub_pension_YTD_before NUMBER := 0;
            l_tax_exp_pension_YTD_before NUMBER :=0;
            l_bik_sub_pension_YTD_before NUMBER := 0;
        -- Temp needed Variables


 -- End of place for Variables which fetches the values to be archived
-- The place for Cursor  which fetches the values to be archived

				--
	-- Cursor to pick up
	Cursor csr_pension_provider
			( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE
			  , csr_v_pension_ins_num  hr_organization_information.org_information1%TYPE
			 ,csr_v_effective_date  DATE  )
				IS
					SELECT  hoi2.ORG_INFORMATION4, hoi2.ORG_INFORMATION5, hoi2.ORG_INFORMATION8, hoi2.ORG_INFORMATION10
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =   csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_PROVIDERS'
					AND  hoi2.org_information6=csr_v_pension_ins_num
					AND csr_v_effective_date  BETWEEN fnd_date.canonical_to_date(hoi2.org_information1) AND
					nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY')) ;

		lr_pension_provider csr_pension_provider%ROWTYPE;

		/* Cursor to retrieve Person Details */
		 CURSOR csr_get_person_details(p_asg_act_id NUMBER)
         IS
    		SELECT pap.LAST_NAME,pap.PRE_NAME_ADJUNCT,pap.FIRST_NAME,
             pap.national_identifier  ,
             pap.person_id  ,
             pap.PER_INFORMATION14,
             pap.PER_INFORMATION15,
             pap.PER_INFORMATION16,
             pap.PER_INFORMATION17,
             pap.PER_INFORMATION20,
             pap.PER_INFORMATION21,
             pap.PER_INFORMATION24,
             pac.assignment_id
    		FROM
    		pay_assignment_actions      	pac,
    		per_all_assignments_f             paa,
    		per_all_people_f			pap
    		WHERE pac.assignment_action_id = p_asg_act_id
    		AND paa.assignment_id = pac.assignment_id
    		AND paa.person_id = pap.person_id
    		AND pap.per_information_category = 'FI'
    		and p_effective_date between pap.effective_Start_date AND pap.effective_end_date
    		and p_effective_date between paa.effective_Start_date AND paa.effective_end_date;

lr_get_person_details csr_get_person_details%ROWTYPE;

    -- Cursor to pick up segment2
	cursor csr_get_Segment2
	is
    	SELECT scl.segment2,scl.segment8
    	FROM 	PER_ALL_ASSIGNMENTS_F paa
    			  ,HR_SOFT_CODING_KEYFLEX scl
    			  ,pay_assignment_actions pasa
            WHERE	pasa.ASSIGNMENT_ACTION_ID    = p_assignment_action_id
            AND     pasa.ASSIGNMENT_ID = paa.ASSIGNMENT_ID
            AND     scl.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
 	    AND     paa.primary_flag='Y'
            AND     p_effective_date between paa.effective_Start_date AND paa.effective_end_date;


    lr_get_Segment2 csr_get_Segment2%ROWTYPE;

-- Cursor to pick up Local Unit Details
        Cursor csr_Local_Unit_Details ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name , hoi2.ORG_INFORMATION1
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_local_unit_id
					AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNIT_DETAILS';

			lr_Local_Unit_Details  csr_Local_Unit_Details%rowtype;

				           	     -- End of Cursors

        CURSOR CSR_PERSON_EIT (
                 CSR_V_PERSON_ID per_all_people_f.person_id%TYPE,
                 CSR_V_COLUMN_NAME per_people_extra_info.PEI_INFORMATION3%TYPE )
            IS
                select PERSON_EXTRA_INFO_ID,
                        object_version_number,
                        person_id,
                        information_type,
                        pei_information_category,
                        pei_information1,
                        pei_information2,
                        pei_information3,
                        pei_information4,
                        pei_information5,
                        pei_information6,
                        pei_information7
                 from per_people_extra_info
                where information_type='FI_PENSION'
                AND PEI_INFORMATION_CATEGORY='FI_PENSION'
                AND PEI_INFORMATION3=CSR_V_COLUMN_NAME
                AND PERSON_ID = CSR_V_PERSON_ID;

            LR_PERSON_EIT CSR_PERSON_EIT%ROWTYPE;

        CURSOR CSR_PERSON_ALL_EIT (
               CSR_V_PERSON_ID per_all_people_f.person_id%TYPE )
        IS
            select PERSON_EXTRA_INFO_ID,
                    object_version_number,
                    person_id,
                    information_type,
                    pei_information_category,
                    pei_information1,
                    pei_information2,
                    pei_information3,
                    pei_information4,
                    pei_information5,
                    pei_information6,
                    pei_information7
             from per_people_extra_info
            where information_type='FI_PENSION'
            AND PEI_INFORMATION_CATEGORY='FI_PENSION'
            AND PERSON_ID = CSR_V_PERSON_ID;


CURSOR csr_Department_code (
    csr_v_pension_provider_id   hr_organization_information.organization_id%TYPE,
    csr_v_Local_unit_id   hr_organization_information.ORG_INFORMATION2%TYPE
		      )
			  IS
				 SELECT hoi2.ORG_INFORMATION3
				   FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =g_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_pension_provider_id
					AND hoi1.org_information_context = 'CLASS'
					AND hoi1.org_information1 = 'FR_PENSION'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_DEPARTMENT_CODES'
					AND hoi2.ORG_INFORMATION1 = g_legal_employer_id
					AND hoi2.ORG_INFORMATION2 = csr_v_Local_unit_id;


			      lr_Department_code      csr_Department_code%ROWTYPE;
    --#########################################
    -- Cursor to pick up the Absence details
        cursor csr_absence_details
				( CSR_V_PERSON_ID per_all_people_f.person_id%TYPE
				,csr_v_start_effective_date  DATE
				,csr_v_end_effective_date  DATE)
	   is

	        SELECT * FROM (
			SELECT PAA.DATE_START,PAA.DATE_END,PAAT.INFORMATION1
			FROM PER_ABSENCE_ATTENDANCES PAA,PER_ABSENCE_ATTENDANCE_TYPES PAAT
			WHERE PAA.BUSINESS_GROUP_ID         = g_business_group_id
			AND PAA.PERSON_ID                   = CSR_V_PERSON_ID
			AND PAAT.BUSINESS_GROUP_ID          = g_business_group_id
			AND PAAT.INFORMATION_CATEGORY       = 'FI'
			AND PAAT.ABSENCE_ATTENDANCE_TYPE_ID = PAA.ABSENCE_ATTENDANCE_TYPE_ID
			AND PAAT.DATE_EFFECTIVE <= csr_v_start_effective_date
			AND PAA.DATE_START BETWEEN csr_v_start_effective_date
								AND    csr_v_end_effective_date
			ORDER BY PAA.DATE_START DESC )
			WHERE ROWNUM <4;


    lr_absence_details csr_absence_details%ROWTYPE;

    l_period_start_date DATE;
    l_period_end_date DATE;
    l_absence_count number;

    l_first_category varchar2(240);
    l_first_start_date date;
    l_first_end_date date;
    l_second_category varchar2(240);
    l_second_start_date date;
    l_second_end_date date;
    l_third_category varchar2(240);
    l_third_start_date date;
    l_third_end_date date;

    -- Cursor to pick up the Absence details
    --#########################################

 -- End of place for Cursor  which fetches the values to be archived

 BEGIN
    IF g_debug THEN
		hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
	END IF;

    fnd_file.put_line(fnd_file.log,'Entering  ARCHIVE_CODE  ' );
    IF g_archive ='Y'
    THEN
        -- *****************************************************************************
        -- TO pick up the PIN
        	OPEN  csr_get_person_details(p_assignment_action_id);
        		FETCH csr_get_person_details
                INTO lr_get_person_details;
        	CLOSE csr_get_person_details;


        l_Employee_Pin  :=lr_get_person_details.national_identifier;
        IF lr_get_person_details.PRE_NAME_ADJUNCT IS NULL
        THEN
        	l_Employee_name :=lr_get_person_details.LAST_NAME
        						||' '||lr_get_person_details.FIRST_NAME;
        ELSE
        	l_Employee_name :=lr_get_person_details.PRE_NAME_ADJUNCT||
        						' '|| lr_get_person_details.LAST_NAME||
        						' '|| lr_get_person_details.FIRST_NAME;
        END IF;


        fnd_file.put_line(fnd_file.log,' ==============PERSON================== ' );
        fnd_file.put_line(fnd_file.log,'l_Employee_Pin     ==> '||l_Employee_Pin );
        fnd_file.put_line(fnd_file.log,'l_Employee_name    ==> '||l_Employee_name );

        fnd_file.put_line(fnd_file.log,' ================================ ' );

        -- *****************************************************************************
        -- TO pick up the Local Unit  Sub-disbursement Number

            OPEN  csr_get_Segment2( );
                FETCH csr_get_Segment2
                INTO lr_get_Segment2;
            CLOSE csr_get_Segment2;
            l_Employed_or_not :=lr_get_Segment2.segment8;
            l_local_unit_id_fetched := lr_get_Segment2.segment2;
        -- Used to display Record 5 , if value is 2 [Not employed ] then report as 5 else NULL
        fnd_file.put_line(fnd_file.log,'l_Employed_or_not  ==> '||l_Employed_or_not );

        -- TO pick up the Local Unit  Sub-disbursement Number
        -- TO pick up New SUb-disburesement number
            -- From the assignment local unit, go to legal employer,
            -- then Pension provider EIT,
            -- pick up the org_information1 that is SUB_DISBURSEMENT NUMBER
            /*OPEN  csr_Local_Unit_Details( to_number(lr_get_Segment2.segment2));
                FETCH csr_Local_Unit_Details
                INTO lr_Local_Unit_Details;
            CLOSE csr_Local_Unit_Details;*/

	OPEN  csr_pension_provider(g_legal_employer_id ,g_pension_ins_num,g_effective_date);
                FETCH csr_pension_provider
                INTO lr_pension_provider;
            CLOSE csr_pension_provider;

	g_pension_provider_id:= lr_pension_provider.ORG_INFORMATION4;

            OPEN  csr_Department_code( g_pension_provider_id,to_number(lr_get_Segment2.segment2));
                FETCH csr_Department_code
                INTO lr_Department_code;
            CLOSE csr_Department_code;


        l_new_Department    :=	lr_Department_code.ORG_INFORMATION3; -- NEW Department code
        fnd_file.put_line(fnd_file.log,'l_new_Department       ==> '||l_new_Department );
        -- TO pick up New SUb-disburesement number
        -- *****************************************************************************


        -- *****************************************************************************
            -- Pick up Person ID
        l_person_id := lr_get_person_details.person_id;
        fnd_file.put_line(fnd_file.log,'l_person_id        ==> '||l_person_id );
        -- *****************************************************************************

        -- *****************************************************************************
            -- TO pick up the Start Date [ Pension Hire date stored at person level. ]

        l_Pension_Start_date  := fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION14);

        fnd_file.put_line(fnd_file.log,'Pension_Start_date ==> '||l_Pension_Start_date );

           -- *****************************************************************************
            -- Pick up the Balance value
            l_assignment_id :=lr_get_person_details.assignment_id;
            fnd_file.put_line(fnd_file.log,'l_assignment_id    ==> '||l_assignment_id );
        	BEGIN
        		pay_balance_pkg.set_context('ASSIGNMENT_ID',l_assignment_id);

        		pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
        		pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id);
        		pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_ref_date));
        		pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
        		pay_balance_pkg.set_context('SOURCE_ID',NULL);
        		pay_balance_pkg.set_context('TAX_GROUP',NULL);
        		pay_balance_pkg.set_context('ORGANIZATION_ID',g_pension_provider_id);

        	END;
        -- *****************************************************************************
            -- IF local unit selected then pick up the Local Unit context Balance
        IF g_local_unit_id is NOT NULL
        THEN
                -- *****************************************************************************
        		OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LU_MONTH');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

        	   l_Sal_subject_pension_MTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LU_MONTH ==> '||l_Sal_subject_pension_MTD );
                -- *****************************************************************************

        		OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LU_MONTH');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> '||lr_Get_Defined_Balance_Id.creator_id );
        		l_bik_subject_pension_MTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LU_MONTH ==> '||l_bik_subject_pension_MTD );
                -- *****************************************************************************

        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LU_MONTH');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
        		l_tax_exp_subject_pension_MTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LU_MONTH ==> '||l_tax_exp_subject_pension_MTD );
                -- *****************************************************************************
                -- QTD START
                -- *****************************************************************************
                --Salary QTD
        		OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LU_QUARTER');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

        	   l_Sal_subject_pension_QTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LU_QUARTER ==> '||l_Sal_subject_pension_QTD );
                -- *****************************************************************************
                -- BIK QTD

        		OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LU_QUARTER');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> '||lr_Get_Defined_Balance_Id.creator_id );
        		l_bik_subject_pension_QTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LU_QUARTER ==> '||l_bik_subject_pension_QTD );
                -- *****************************************************************************
                --EXPENSE QTD

        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LU_QUARTER');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
        		l_tax_exp_subject_pension_QTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LU_QUARTER ==> '||l_tax_exp_subject_pension_QTD );
                -- *****************************************************************************
				-- MONTH  QTD END
                -- Salary YTD
                OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LU_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

               fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

        	   l_Sal_subject_pension_YTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;

                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LU_YEAR ==> '||l_Sal_subject_pension_YTD );
                -- *****************************************************************************

                -- Salary Balance value before termination date

                IF lr_get_person_details.PER_INFORMATION20 IS NOT NULL
                THEN
            	   l_sal_sub_pension_YTD_before :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE => fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20)  ),'999999999D99') ;
                ELSE
                    l_sal_sub_pension_YTD_before := 0;
                END IF;
                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LU_YEAR_BEFORE ==> '||l_sal_sub_pension_YTD_before );
                -- *****************************************************************************
                -- Salary YTD
                -- BIK YTD

        		OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LU_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
        		l_bik_subject_pension_YTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;

                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LU_YEAR ==> '||l_bik_subject_pension_YTD );
                -- *****************************************************************************
                -- Balance value before termination date
                IF lr_get_person_details.PER_INFORMATION20 IS NOT NULL
                THEN
            		l_bik_sub_pension_YTD_before :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE => fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20)  ),'999999999D99') ;
                ELSE
                    l_bik_sub_pension_YTD_before := 0;
                END IF;
                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LU_YEAR_before ==> '||l_bik_sub_pension_YTD_before );

                -- *****************************************************************************

                -- BIK YTD
                -- TAXABLE EXPENSES YTD
        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LU_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_tax_exp_subject_pension_YTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;

                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LU_YEAR ==> '||l_tax_exp_subject_pension_YTD );
                -- *****************************************************************************
                -- Taxable Expenses Balance value before termination date

        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LU_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                IF lr_get_person_details.PER_INFORMATION20 IS NOT NULL
                THEN
        		  l_tax_exp_pension_YTD_before :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE => fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20)  ),'999999999D99') ;
                ELSE
                    l_tax_exp_pension_YTD_before := 0;
                END IF;
                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LU_YEAR_BEFORE ==> '||l_tax_exp_pension_YTD_before );
            -- TAXABLE EXPENSES YTD
            -- *****************************************************************************
            -- IF the Local unit is not selected then pick up LE context Balance values
        -- *****************************************************************************
        ELSE
        		--SALARY LE MTD
        		OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LE_MONTH');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> '||lr_Get_Defined_Balance_Id.creator_id );
                fnd_file.put_line(fnd_file.log,'g_effective_date   ==> '||g_effective_date );

        	   l_Sal_subject_pension_MTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LE_MONTH ==> '||l_Sal_subject_pension_MTD );
                -- *****************************************************************************
        		OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LE_MONTH');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_bik_subject_pension_MTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LE_MONTH ==> '||l_bik_subject_pension_MTD );

                -- *****************************************************************************

        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LE_MONTH');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_tax_exp_subject_pension_MTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LE_MONTH ==> '||l_tax_exp_subject_pension_MTD );
                -- *****************************************************************************
                --SALARY LE QTD
        		OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LE_QUARTER');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> '||lr_Get_Defined_Balance_Id.creator_id );
                fnd_file.put_line(fnd_file.log,'g_effective_date   ==> '||g_effective_date );

        	   l_Sal_subject_pension_QTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LE_QUARTER ==> '||l_Sal_subject_pension_QTD );
                -- *****************************************************************************
                --BIK QTD
        		OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LE_QUARTER');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_bik_subject_pension_QTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LE_QUARTER ==> '||l_bik_subject_pension_QTD );

                -- *****************************************************************************
                -- EXPENSE QTD

        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LE_QUARTER');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_tax_exp_subject_pension_QTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;


                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LE_QUARTER ==> '||l_tax_exp_subject_pension_QTD );
                -- *****************************************************************************

                -- END OF MTD  QTD

                OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LE_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> '  ||lr_Get_Defined_Balance_Id.creator_id );
                fnd_file.put_line(fnd_file.log,'g_effective_date   ==> '  ||g_effective_date );

        	   l_Sal_subject_pension_YTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;

                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LE_YEAR ==> '||l_Sal_subject_pension_YTD );
                -- *****************************************************************************

                -- Salary Balance value before termination date

                IF lr_get_person_details.PER_INFORMATION20 IS NOT NULL
                THEN
            	   l_sal_sub_pension_YTD_before :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE => fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20)  ),'999999999D99') ;
                ELSE
                    l_sal_sub_pension_YTD_before := 0;
                END IF;
                fnd_file.put_line(fnd_file.log,'l_Sal_subject_pension_PER_PENSION_LE_YEAR_BEFORE ==> '||l_sal_sub_pension_YTD_before );
                -- *****************************************************************************


        		OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LE_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_bik_subject_pension_YTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;

                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LE_YEAR ==> '||l_bik_subject_pension_YTD );
                -- *****************************************************************************
		        -- Balance value before termination date
                IF lr_get_person_details.PER_INFORMATION20 IS NOT NULL
                THEN
            		l_bik_sub_pension_YTD_before :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE => fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20)  ),'999999999D99') ;
                ELSE
                    l_bik_sub_pension_YTD_before := 0;
                END IF;
                fnd_file.put_line(fnd_file.log,'l_bik_subject_pension_PER_PENSION_LE_YEAR_before ==> '||l_bik_sub_pension_YTD_before );

                -- *****************************************************************************

                OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LE_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;

        		l_tax_exp_subject_pension_YTD :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_ref_date ),'999999999D99') ;

                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LE_YEAR ==> '||l_tax_exp_subject_pension_YTD );
        -- *****************************************************************************
        		OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LE_YEAR');
        		FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
        		CLOSE csr_Get_Defined_Balance_Id;
  				-- Taxable Expenses Balance value before termination date
                IF lr_get_person_details.PER_INFORMATION20 IS NOT NULL
                THEN
        		  l_tax_exp_pension_YTD_before :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE => fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20)  ),'999999999D99') ;
                ELSE
                    l_tax_exp_pension_YTD_before := 0;
                END IF;
                fnd_file.put_line(fnd_file.log,'l_tax_exp_subject_pension_PER_PENSION_LE_YEAR_BEFORE ==> '||l_tax_exp_pension_YTD_before );

        END IF; -- END OF G_LOCAL_UNIT_ID NULL CHECK

            -- *****************************************************************************
            -- Pick up Termiantion date form person table
             l_Termination_date :=  fnd_date.canonical_to_date(lr_get_person_details.PER_INFORMATION20);
            fnd_file.put_line(fnd_file.log,'l_Termination_date  ==> '||l_Termination_date );
            -- *****************************************************************************
            -- Pick up the Cause of termination
            -- from person record

            l_Cause_of_termination := lr_get_person_details.PER_INFORMATION21;

            fnd_file.put_line(fnd_file.log,'Cause  termination ==> '||l_Cause_of_termination );
            -- *****************************************************************************
        -- to find the old group code
        -- Go to Person EIT , find the record for the "  Pension Group ", if available
        -- Then pick up the value PEI_INFORMATION4 <=> Pension Group Code

            OPEN  CSR_PERSON_EIT(l_person_id,'Pension Group');
                FETCH CSR_PERSON_EIT
                INTO LR_PERSON_EIT;
            CLOSE CSR_PERSON_EIT;
            l_old_pension_group_code :=LR_PERSON_EIT.pei_information4;
	     fnd_file.put_line(fnd_file.log,'Old Group Code ==> '||LR_PERSON_EIT.pei_information4);
	    -- to find the old group code
        -- *****************************************************************************
        -- *****************************************************************************
        -- Go to Person EIT , find the record for the " Local Unit ", if available
        -- Then pick up the value PEI_INFORMATION4 <=> Local Unit Id
        -- Finding the OLD INSURANCE POLICY NUMBER
            OPEN  CSR_PERSON_EIT(l_person_id,'Local Unit');
                FETCH CSR_PERSON_EIT
                INTO LR_PERSON_EIT;
            CLOSE CSR_PERSON_EIT;
	    l_eit_local_unit := LR_PERSON_EIT.pei_information4;
        -- *****************************************************************************
        -- Using the Above Local unit ID
        -- Pick up the SUB-DISBURSEMENT NUMBER from Local Unit Details
        -- this SUB-DISBURSEMENT NUMBER  is which is Last reported SUB-DISBURSEMENT
        -- to find the old Department
            /*OPEN  csr_Local_Unit_Details(to_number(LR_PERSON_EIT.pei_information4 ));
                FETCH csr_Local_Unit_Details
                INTO lr_Local_Unit_Details;
            CLOSE csr_Local_Unit_Details;*/
           OPEN  csr_Department_code( g_pension_provider_id,to_number(LR_PERSON_EIT.pei_information4 ));
                FETCH csr_Department_code
                INTO lr_Department_code;
            CLOSE csr_Department_code;

        l_old_Department    :=	lr_Department_code.ORG_INFORMATION3; -- OLD Department Code

        fnd_file.put_line(fnd_file.log,'l_old_Department   ==> '||l_old_Department );
        -- *****************************************************************************
        -- to find the old Department END
        -- Using the Above Local unit ID find the legal employer , Pension Provider,
        -- Then select the pension policy Number for this Local Unit
        -- which is Last reported Policy Number
        -- to find the old Department
        -- Finding the OLD INSURANCE POLICY NUMBER
	  OPEN  CSR_PERSON_EIT(l_person_id,'Insurance Number');
                FETCH CSR_PERSON_EIT
                INTO LR_PERSON_EIT;
            CLOSE CSR_PERSON_EIT;
            l_old_policy_number :=LR_PERSON_EIT.pei_information4;

        -- Finding the OLD INSURANCE POLICY NUMBER END
        -- *****************************************************************************
        -- TO pick up new pension group code
        -- Pick the Current Pension Group Code from the Person Record
            l_new_pension_group_code :=lr_get_person_details.PER_INFORMATION16;
        fnd_file.put_line(fnd_file.log,'New Group Code ==> '||lr_get_person_details.PER_INFORMATION16);
        -- TO pick up new pension group code
        -- *****************************************************************************
        -- *****************************************************************************
        -- Finding the new INSURANCE POLICY NUMBER
       -- Pick the Current INSURANCE POLICY NUMBER from the Person Record
	   l_new_policy_number := lr_get_person_details.PER_INFORMATION24;
        fnd_file.put_line(fnd_file.log,'New Policy Number ==> '||lr_get_person_details.PER_INFORMATION24);

        -- Finding the new INSURANCE POLICY NUMBER
        -- *****************************************************************************

        -- End of Pickingup the Data

         BEGIN
        						 SELECT 1 INTO l_flag
        						 FROM   pay_action_information
        						 WHERE  action_information_category = 'EMEA REPORT DETAILS'
        						 AND 	action_information1 		= 'PYFITELA'
        						 AND    action_context_id           = p_assignment_action_id;

         EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
        fnd_file.put_line(fnd_file.log,'Not found  In Archive record ' );
        fnd_file.put_line(fnd_file.log,'g_payroll_action_id ' || g_payroll_action_id);
 pay_action_information_api.create_action_information (
        							p_action_information_id        => l_action_info_id
        							,p_action_context_id            => p_assignment_action_id
        							,p_action_context_type          => 'AAP'
        							,p_object_version_number        => l_ovn
        							,p_effective_date               => l_effective_date
        							,p_source_id                    => NULL
        							,p_source_text                  => NULL
        							,p_action_information_category  => 'EMEA REPORT INFORMATION'
        							,p_action_information1          => 'PYFITELA'
        							,p_action_information2           => 'PER'
        							,p_action_information3           => g_payroll_action_id
        							,p_action_information4           => l_old_policy_number
        							,p_action_information5           => l_Employee_Pin
        							,p_action_information6           => l_old_pension_group_code
        							,p_action_information7           => l_old_Department
        							,p_action_information8           => l_Employee_name
        							,p_action_information9           => fnd_date.date_to_canonical(l_Pension_Start_date)
        							,p_action_information10          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Sal_subject_pension_MTD)
        							,p_action_information11          => FND_NUMBER.NUMBER_TO_CANONICAL(l_bik_subject_pension_MTD)
        							,p_action_information12          => FND_NUMBER.NUMBER_TO_CANONICAL(l_tax_exp_subject_pension_MTD)
        							,p_action_information13          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Sal_subject_pension_YTD)
        							,p_action_information14          => FND_NUMBER.NUMBER_TO_CANONICAL(l_bik_subject_pension_YTD)
        							,p_action_information15          => FND_NUMBER.NUMBER_TO_CANONICAL(l_tax_exp_subject_pension_YTD)
        							,p_action_information16          => fnd_date.date_to_canonical(l_Termination_date)
        							,p_action_information17          => l_Cause_of_termination
        							,p_action_information18          => FND_NUMBER.NUMBER_TO_CANONICAL(l_sal_sub_pension_YTD_before)
        							,p_action_information19          => FND_NUMBER.NUMBER_TO_CANONICAL(l_tax_exp_pension_YTD_before)
        							,p_action_information20          => FND_NUMBER.NUMBER_TO_CANONICAL(l_bik_sub_pension_YTD_before)
        							,p_action_information21          => l_new_policy_number
        							,p_action_information22          => l_new_Department
        							,p_action_information23          => l_new_pension_group_code
        							,p_action_information24          => l_Employed_or_not
        							,p_action_information25          => l_Currency
        							,p_action_information26          => lr_get_person_details.PER_INFORMATION15
        							,p_action_information27          => lr_get_person_details.PER_INFORMATION16
        							,p_action_information28          => l_local_unit_id_fetched
        							,p_action_information29          => lr_pension_provider.ORG_INFORMATION10
        							,p_action_information30          => l_person_id
                                    ,p_assignment_id                 => l_assignment_id   );

        fnd_file.put_line(fnd_file.log,'l_action_info_id ==> '||l_action_info_id );
        fnd_file.put_line(fnd_file.log,'l_action_info_id ==> '||l_person_id );
fnd_file.put_line(fnd_file.log,'g_annual_report ==> '||g_annual_report );
        IF g_annual_report ='M'
        THEN
        		l_period_start_date :=LAST_DAY(ADD_MONTHS(g_ref_date , -1)  ) + 1 ;
		        l_period_end_date :=  LAST_DAY(g_ref_date);
        ELSIF g_annual_report ='Q'
        THEN
   		        l_period_start_date := TRUNC(g_ref_date, 'Q') ;
		        l_period_end_date := ADD_MONTHS(last_day(TRUNC(g_ref_date, 'Q') ), 2);
        ELSIF g_annual_report ='A'
        THEN
   		        l_period_start_date :=TRUNC(g_ref_date, 'Y') ;
		        l_period_end_date := ADD_MONTHS(last_day(TRUNC(g_ref_date, 'Y') ), 11);
        END IF;
				l_absence_count := 0;

         FOR lr_absence_details IN
                    csr_absence_details(l_person_id,l_period_start_date,l_period_end_date)
                    LOOP

                    	IF l_absence_count = 3
                    	THEN
                    		EXIT;
                    	END IF;
                    	IF lr_absence_details.INFORMATION1 ='4'     -- Sick Leave Without Pay
                    	  or lr_absence_details.INFORMATION1 ='2'   -- Lay-off
                    	  or lr_absence_details.INFORMATION1 ='5'   -- Company Specific Leave
                    	  or lr_absence_details.INFORMATION1 ='7'   -- Study Leave
                    	THEN
                    		IF MONTHS_BETWEEN(lr_absence_details.DATE_END,lr_absence_details.DATE_START) >= 2
                    		THEN
                    		fnd_file.put_line(fnd_file.log,'Cursor Looping IF count==> '||l_absence_count );
								fnd_file.put_line(fnd_file.log,'START==> '||lr_absence_details.DATE_START );
								fnd_file.put_line(fnd_file.log,'END==> '||lr_absence_details.DATE_END );


                    			ABS_RECORDS(l_absence_count).CATEGORY := lr_absence_details.INFORMATION1;
                    			ABS_RECORDS(l_absence_count).START_DATE := lr_absence_details.DATE_START ;
                    			ABS_RECORDS(l_absence_count).END_DATE := lr_absence_details.DATE_END;
                    			l_absence_count := l_absence_count + 1;
							END IF;
/*						ELSIF lr_absence_details.ABSENCE_CATEGORY = 'FI_MNM'
						   or lr_absence_details.ABSENCE_CATEGORY = 'FI_NL'
						   or lr_absence_details.ABSENCE_CATEGORY = 'FI_SAL'
						   or lr_absence_details.ABSENCE_CATEGORY = 'M'
						THEN
*/						ELSE   -- For all others, even if user adds his own code
						fnd_file.put_line(fnd_file.log,'Cursor Looping Else count==> '||l_absence_count );
						fnd_file.put_line(fnd_file.log,'START==> '||lr_absence_details.DATE_START );
						fnd_file.put_line(fnd_file.log,'END==> '||lr_absence_details.DATE_END );


                    			ABS_RECORDS(l_absence_count).CATEGORY := lr_absence_details.INFORMATION1;
                    			ABS_RECORDS(l_absence_count).START_DATE := lr_absence_details.DATE_START ;
                    			ABS_RECORDS(l_absence_count).END_DATE := lr_absence_details.DATE_END;
                    			l_absence_count := l_absence_count + 1;
						END IF;
        			END LOOP;
    l_first_category  := null;
    l_first_start_date :=null;
    l_first_end_date := null;
    l_second_category := null;
    l_second_start_date := null;
    l_second_end_date := null;
    l_third_category := null;
    l_third_start_date := null;
    l_third_end_date := null;

IF l_absence_count = 1
THEN
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).CATEGORY ==> '||ABS_RECORDS(0).CATEGORY );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).START_DATE ==> '||ABS_RECORDS(0).START_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).END_DATE ==> '||ABS_RECORDS(0).END_DATE );
    l_first_category  :=ABS_RECORDS(0).CATEGORY;
    l_first_start_date :=ABS_RECORDS(0).START_DATE;
    l_first_end_date :=ABS_RECORDS(0).END_DATE ;
    l_second_category := null;
    l_second_start_date := null;
    l_second_end_date := null;
    l_third_category := null;
    l_third_start_date := null;
    l_third_end_date := null;

ELSIF l_absence_count = 2
THEN
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).CATEGORY ==> '||ABS_RECORDS(0).CATEGORY );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).START_DATE ==> '||ABS_RECORDS(0).START_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).END_DATE ==> '||ABS_RECORDS(0).END_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(1)CATEGORY ==> '||ABS_RECORDS(1).CATEGORY );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(1)START_DATE ==> '||ABS_RECORDS(1).START_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(1) END_DATE==> '||ABS_RECORDS(1).END_DATE );

    l_first_category  :=ABS_RECORDS(0).CATEGORY;
    l_first_start_date :=ABS_RECORDS(0).START_DATE;
    l_first_end_date :=ABS_RECORDS(0).END_DATE ;
    l_second_category  :=ABS_RECORDS(1).CATEGORY;
    l_second_start_date :=ABS_RECORDS(1).START_DATE;
    l_second_end_date :=ABS_RECORDS(1).END_DATE ;
    l_third_category :=null;
    l_third_start_date :=null;
    l_third_end_date :=null;
ELSIF l_absence_count = 3
THEN
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).CATEGORY ==> '||ABS_RECORDS(0).CATEGORY );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).START_DATE ==> '||ABS_RECORDS(0).START_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(0).END_DATE ==> '||ABS_RECORDS(0).END_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(1)CATEGORY ==> '||ABS_RECORDS(1).CATEGORY );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(1)START_DATE ==> '||ABS_RECORDS(1).START_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(1) END_DATE==> '||ABS_RECORDS(1).END_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(2)CATEGORY ==> '||ABS_RECORDS(2).CATEGORY );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(2) START_DATE==> '||ABS_RECORDS(2).START_DATE );
fnd_file.put_line(fnd_file.log,'ABS_RECORDS(2) END_DATE==> '||ABS_RECORDS(2).END_DATE );
    l_first_category  :=ABS_RECORDS(0).CATEGORY;
    l_first_start_date :=ABS_RECORDS(0).START_DATE;
    l_first_end_date :=ABS_RECORDS(0).END_DATE ;
    l_second_category  :=ABS_RECORDS(1).CATEGORY;
    l_second_start_date :=ABS_RECORDS(1).START_DATE;
    l_second_end_date :=ABS_RECORDS(1).END_DATE;
    l_third_category  :=ABS_RECORDS(2).CATEGORY;
    l_third_start_date :=ABS_RECORDS(2).START_DATE;
    l_third_end_date :=ABS_RECORDS(2).END_DATE;
ELSE

    l_first_category  := null;
    l_first_start_date :=null;
    l_first_end_date := null;
    l_second_category := null;
    l_second_start_date := null;
    l_second_end_date := null;
    l_third_category := null;
    l_third_start_date := null;
    l_third_end_date := null;
END IF;
fnd_file.put_line(fnd_file.log,'FINALLY+++++++++++++');
fnd_file.put_line(fnd_file.log,'(0).CATEGORY ==> '|| l_first_category);
fnd_file.put_line(fnd_file.log,'(0).START_DATE ==> '||l_first_start_date );
fnd_file.put_line(fnd_file.log,'(0).END_DATE ==> '|| l_first_end_date);
fnd_file.put_line(fnd_file.log,'(1)CATEGORY ==> '||l_second_category );
fnd_file.put_line(fnd_file.log,'(1)START_DATE ==> '||l_second_start_date );
fnd_file.put_line(fnd_file.log,'(1) END_DATE==> '|| l_second_end_date);
fnd_file.put_line(fnd_file.log,'(2)CATEGORY ==> '||l_third_category );
fnd_file.put_line(fnd_file.log,'(2) START_DATE==> '|| l_third_start_date);
fnd_file.put_line(fnd_file.log,'(2) END_DATE==> '|| l_third_end_date);



								pay_action_information_api.create_action_information (
								p_action_information_id        => l_action_info_id
								,p_action_context_id            => p_assignment_action_id
								,p_action_context_type          => 'AAP'
								,p_object_version_number        => l_ovn
								,p_effective_date               => l_effective_date
								,p_source_id                    => NULL
								,p_source_text                  => NULL
								,p_action_information_category  => 'EMEA REPORT INFORMATION'
								,p_action_information1          => 'PYFITELA'
								,p_action_information2           => 'PER1'
								,p_action_information3           => g_payroll_action_id
								,p_action_information4           => l_first_category
								,p_action_information5           => fnd_date.date_to_canonical(l_first_start_date)
								,p_action_information6           => fnd_date.date_to_canonical(l_first_end_date)
								,p_action_information7           => l_second_category
								,p_action_information8           => fnd_date.date_to_canonical(l_second_start_date)
								,p_action_information9           => fnd_date.date_to_canonical(l_second_end_date)
								,p_action_information10          => l_third_category
								,p_action_information11          => fnd_date.date_to_canonical(l_third_start_date)
								,p_action_information12          => fnd_date.date_to_canonical(l_third_end_date)
								,p_action_information13          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Sal_subject_pension_QTD)
								,p_action_information14          => FND_NUMBER.NUMBER_TO_CANONICAL(l_bik_subject_pension_QTD)
								,p_action_information15          => FND_NUMBER.NUMBER_TO_CANONICAL(l_tax_exp_subject_pension_QTD)
								,p_action_information16          => null
								,p_action_information17          => null
								,p_action_information18          => null
								,p_action_information19          => null
								,p_action_information20          => null
								,p_action_information21          => null
								,p_action_information22          => null
								,p_action_information23          => null
								,p_action_information24          => null
								,p_action_information25          => null
								,p_action_information26          => null
								,p_action_information27          => null
								,p_action_information28          => null
								,p_action_information29          => null
								,p_action_information30          => l_person_id
								,p_assignment_id                 => l_assignment_id   );



         FOR l_PERSON_ALL_EIT IN
                        CSR_PERSON_ALL_EIT (l_person_id)
                    LOOP
                       pay_action_information_api.create_action_information (
                          p_action_information_id   => l_action_info_id,
                          p_action_context_id       => p_assignment_action_id,
                          p_action_context_type     => 'AAP',
                          p_object_version_number   => l_ovn,
                          p_effective_date          => l_effective_date,
                          p_source_id               => NULL,
                          p_source_text             => NULL,
                          p_action_information_category=> 'EMEA REPORT INFORMATION',
                          p_action_information1     => 'PYFITELA',
                          p_action_information2     => 'PERSON_EIT',
                          p_action_information3     => g_payroll_action_id,
                          p_action_information4     => l_PERSON_ALL_EIT.PERSON_EXTRA_INFO_ID,
                          p_action_information5     => l_PERSON_ALL_EIT.PEI_INFORMATION2,
                          p_action_information6     => l_PERSON_ALL_EIT.PEI_INFORMATION3,
                          p_action_information7     => l_PERSON_ALL_EIT.PEI_INFORMATION4,
                          p_action_information8     => l_PERSON_ALL_EIT.PEI_INFORMATION5,
                          p_action_information9     => l_PERSON_ALL_EIT.PEI_INFORMATION6,
                          p_action_information10    => l_PERSON_ALL_EIT.PEI_INFORMATION7,
                          p_action_information11    => NULL,
                          p_action_information12    => NULL,
                          p_action_information13    => NULL,
                          p_action_information14    => NULL,
                          p_action_information15    => NULL,
                          p_action_information16    => NULL,
                          p_action_information17    => NULL,
                          p_action_information18    => NULL,
                          p_action_information19    => NULL,
                          p_action_information20    => NULL,
                          p_action_information21    => NULL,
                          p_action_information22    => NULL,
                          p_action_information23    => NULL,
                          p_action_information24    => NULL,
                          p_action_information25    => NULL,
                          p_action_information26    => NULL,
                          p_action_information27    => NULL,
                          p_action_information28    => NULL,
                          p_action_information29    => NULL,
                          p_action_information30    => l_person_id,
                          p_assignment_id           => l_assignment_id
                       );
           fnd_file.put_line(fnd_file.log,'End of a person ==> '||l_action_info_id );
                    END LOOP;

         WHEN OTHERS
         THEN
             NULL;
         END;
END IF;
                fnd_file.put_line(fnd_file.log,'Leaving Procedure ARCHIVE_CODE');
             IF g_debug THEN
             		hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
             END IF;

 END ARCHIVE_CODE;
 END PAY_FI_ARCHIVE_TEL;

/
