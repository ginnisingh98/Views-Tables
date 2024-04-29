--------------------------------------------------------
--  DDL for Package Body PAY_DK_ARCHIVE_EIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_ARCHIVE_EIN" AS
 /* $Header: pydkeina.pkb 120.1.12010000.29 2010/04/16 09:56:41 knadhan ship $ */

      g_debug                 BOOLEAN   :=  hr_utility.debug_enabled;
      g_package         VARCHAR2(33) := ' PAY_DK_ARCHIVE_EIN.';
      g_payroll_action_id     NUMBER ;
      g_le_assignment_action_id NUMBER ;
      g_business_group_id     NUMBER;
      g_legal_employer_id     NUMBER;
      --Create globals
      g_effective_date        DATE;
      g_start_date            VARCHAR2(30); /* 9489806 */
      g_end_date              VARCHAR2(30); /* 9489806 */
      g_payroll_type          VARCHAR2(30); /* 9489806 */
      g_payroll_id            NUMBER;
      g_payroll_period  NUMBER;
      g_test_submission VARCHAR2(1);
      g_company_terminating   VARCHAR2(1);
      g_sender_id                                VARCHAR2(8);
      g_flag                  NUMBER:=0;
      l_bincome_exception    exception;


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
  WHERE  pbt.legislation_code='DK'
  AND    pbt.balance_name = p_balance_name
  AND    pbd.legislation_code = 'DK'
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
            IF g_debug THEN
                  hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
            END IF;

            RETURN l_parameter;

       END;

      /* GET ALL PARAMETERS */
      PROCEDURE GET_ALL_PARAMETERS(
            p_payroll_action_id IN   NUMBER
            ,p_business_group_id OUT  NOCOPY NUMBER
            ,p_legal_employer_id OUT  NOCOPY  NUMBER
            ,p_effective_date OUT  NOCOPY DATE
            ,p_payroll OUT NOCOPY NUMBER
           -- ,p_payroll_period OUT NOCOPY NUMBER /* 9489806 */
	    ,p_payroll_type   OUT  NOCOPY VARCHAR2 /* 9489806 */
	    ,p_start_date     OUT  NOCOPY VARCHAR2   /* 9489806 */
            ,p_end_date       OUT  NOCOPY VARCHAR2  /* 9489806 */
            ,p_test_submission OUT NOCOPY VARCHAR2
            ,p_company_terminating OUT NOCOPY VARCHAR2
            ,p_sender_id OUT NOCOPY VARCHAR2
            ) IS

            CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
            SELECT PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_ID')
            ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'PAYROLL')
        --    ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'PAYROLL_PERIOD')
	    ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'PAYROLL_TYPE') /* 9489806 */
	    ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'START_DATE') /* 9489806 */
	    ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'END_DATE') /* 9489806 */
            ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'TEST_SUBMISSION')
            ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'COMPANY_TERMINATING')
            ,PAY_DK_ARCHIVE_EIN.GET_PARAMETER(legislative_parameters,'SENDER_ID')
            ,effective_date
            ,business_group_id
            FROM  pay_payroll_actions
            WHERE payroll_action_id = p_payroll_action_id;

            l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
            --
      BEGIN

             OPEN csr_parameter_info (p_payroll_action_id);

             FETCH csr_parameter_info
             INTO p_legal_employer_id
                        ,p_payroll
                       -- ,p_payroll_period
		        ,p_payroll_type
			,p_start_date
			,p_end_date
                        ,p_test_submission
                        ,p_company_terminating
                        ,p_sender_id
                        ,p_effective_date
                        ,p_business_group_id;
             CLOSE csr_parameter_info;
             --
hr_utility.set_location(' get paramerters:p_start_date ' || p_start_date,30);
hr_utility.set_location(' get paramerters:p_end_date ' || p_end_date,30);
hr_utility.set_location(' get paramerters:p_payroll_type ' || p_payroll_type,30);
             IF g_debug THEN
                  hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
             END IF;

       END GET_ALL_PARAMETERS;

      /* RANGE CODE */
      PROCEDURE RANGE_CODE
      (p_payroll_action_id    IN    NUMBER
      ,p_sql    OUT   NOCOPY VARCHAR2)
      IS
            l_action_info_id NUMBER;
            l_ovn NUMBER;
            l_count NUMBER := 0;
            l_business_group_id    NUMBER;
            l_test_submission  varchar2(1);
            l_company_terminating varchar2(1);
            l_emp_id        hr_organization_units.organization_id%TYPE ;
            l_le_name            hr_organization_units.name%TYPE ;
            l_business_id               hr_organization_information.org_information1%TYPE ;
            l_cvr_number        hr_organization_information.org_information1%TYPE ;
            l_sp_cvr_number        hr_organization_information.org_information1%TYPE ;
            l_org_type    hr_organization_information.org_information1%TYPE ;
            l_date VARCHAR2(100);
            l_time VARCHAR2(10);
            l_lb_num VARCHAR2(10);
            l_unique_id VARCHAR2(16);
	    l_unique_id1 VARCHAR2(16); /* 9489806 */

	    l_canonical_start_date DATE; /* 9489806 */
	    l_canonical_end_date   DATE; /* 9489806 */

            /*Cursors */

            /*Legal Employer Information*/
            Cursor csr_Legal_Emp_Details ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
            IS
            SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION2, hoi2.ORG_INFORMATION3, hoi2.ORG_INFORMATION4, hoi2.ORG_INFORMATION5, hoi2.ORG_INFORMATION6, hoi2.ORG_INFORMATION13
            FROM hr_organization_units o1
            , hr_organization_information hoi1
            , hr_organization_information hoi2
            WHERE  o1.business_group_id =l_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id =  csr_v_legal_emp_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id =hoi2.organization_id
            AND hoi2.ORG_INFORMATION_CONTEXT='DK_LEGAL_ENTITY_DETAILS' ;

            rg_Legal_Emp_Details csr_Legal_Emp_Details%rowtype;

            -- Service Provider information.
            cursor service_provider_details
            is
                  select * from hr_organization_information
                  where org_information_context = 'DK_SERVICE_PROVIDER_DETAILS'
                  and organization_id in (
                  select organization_id from hr_organization_units
                  where business_group_id= l_business_group_id);

            sp service_provider_details%rowtype;

            /* Payroll Time period */
            CURSOR csr_pay_periods(p_payroll_id NUMBER, p_payroll_period NUMBER)
            IS
            SELECT ptp.start_date, ptp.end_date, ptp.period_name,
            default_dd_date,
              decode(PERIOD_TYPE
                    ,'Calendar Month','1'
                  ,'Bi-Week'       ,'2'
                      ,'Week'          ,'3'
                    ,'Lunar Month'   ,'4')  PAYROLL_PERIOD
            from per_time_periods ptp
            WHERE payroll_id = p_payroll_id
            AND time_period_id = p_payroll_period;

            rg_csr_pay_periods csr_pay_periods%rowtype;

            /* Payroll Name */
            CURSOR csr_payroll_name(id pay_all_payrolls_f.payroll_id%type)
            IS
                    select payroll_name from pay_payrolls_f
                    where payroll_id=id;

           -- rg_csr_payroll_name csr_payroll_name%rowtype;
	   l_payroll_name VARCHAR2(100):=NULL;

	    CURSOR csr_le_payrolls is /* 9489806 */
		SELECT DISTINCT
			ppf.payroll_name,
			ppf.payroll_id,
			ptp.start_date,
			ptp.end_date,
			ptp.period_name,
			ptp.default_dd_date,
			 decode(ptp.PERIOD_TYPE
			                  ,'Calendar Month','1'
			                  ,'Bi-Week'       ,'2'
			                  ,'Week'          ,'3'
			                  ,'Lunar Month'   ,'4')  PAYROLL_PERIOD,
			ptp.TIME_PERIOD_ID
		FROM
			pay_payrolls_f ppf,
			per_assignments_f paf,
			hr_organization_units hou,
			hr_organization_information hoi,
			hr_soft_coding_keyflex scl,
			per_time_periods ptp
		WHERE hou.business_group_id = l_business_group_id
		AND hou.organization_id = g_legal_employer_id
		AND hou.organization_id = hoi.organization_id
		AND hoi.org_information_context = 'CLASS'
		AND hoi.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND paf.payroll_id = ppf.payroll_id
		AND ppf.payroll_id=NVL(g_payroll_id,ppf.payroll_id)
		AND ppf.effective_start_date <= l_canonical_start_date and ppf.effective_end_date >= l_canonical_end_date
		AND ptp.payroll_id=ppf.payroll_id
		AND ptp.end_date BETWEEN l_canonical_start_date AND l_canonical_end_date
		AND paf.SOFT_CODING_KEYFLEX_ID = scl.SOFT_CODING_KEYFLEX_ID
		AND scl.segment1 = to_char(hou.organization_id)
		AND ppf.business_group_id = l_business_group_id;

            /* End of Cursors */
            BEGIN

                 hr_utility.set_location(' Entering Procedure RANGE_CODE',1);

                  IF g_debug THEN
                        hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
                  END IF;

                  p_sql := 'SELECT DISTINCT person_id FROM  per_people_f ppf,pay_payroll_actions ppa WHERE ppa.payroll_action_id = :payroll_action_id AND ppa.business_group_id = ppf.business_group_id ORDER BY ppf.person_id';

		  g_legal_employer_id := NULL ;
                  g_effective_date   := NULL ;
		  g_start_date := NULL; /* 9489806 */
		  g_end_date :=NULL;
                  g_payroll_action_id := p_payroll_action_id ;
                  g_le_assignment_action_id   := NULL ;
                  g_payroll_id:=NULL;
                  g_payroll_period:=NULL;
                  g_test_submission:=NULL;
                  g_company_terminating:=NULL;
                  g_sender_id:=NULL;

                   hr_utility.set_location('RANGE_CODE:Before Calling all parameters',2);

                  PAY_DK_ARCHIVE_EIN.GET_ALL_PARAMETERS(
                  p_payroll_action_id
                  ,l_business_group_id
                  ,g_legal_employer_id
                  ,g_effective_date
                  ,g_payroll_id
                --  ,g_payroll_period
		  ,g_payroll_type
		  ,g_start_date
		  ,g_end_date
                  ,g_test_submission
                  ,g_company_terminating
                  ,g_sender_id) ;

		  hr_utility.set_location('RANGE_CODE:After Calling all parameters',2);

                  l_canonical_start_date := fnd_date.canonical_to_date(g_start_date);
                  l_canonical_end_date   := fnd_date.canonical_to_date(g_end_date);
                  SELECT count(*)
                  INTO l_count
                  FROM   pay_action_information
                  WHERE  action_information_category = 'EMEA REPORT DETAILS'
                  AND        action_information1             = 'PYDKEINA'
                  AND    action_context_id           = p_payroll_action_id;

--                fnd_file.put_line(fnd_file.log,'Range Code 6');

                  IF l_count < 1  then

                        hr_utility.set_location('Entered Procedure GETDATA',10);


--                      fnd_file.put_line(fnd_file.log,'g_legal_employer_id : '||g_legal_employer_id);
--                      fnd_file.put_line(fnd_file.log,'l_business_group_id : '||l_business_group_id);
                        OPEN  csr_Legal_Emp_Details(g_legal_employer_id);
                        FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;

/*                      if(csr_Legal_Emp_Details%notfound) then
                              fnd_file.put_line(fnd_file.log,'No data found for the legal emp');
                        end if;*/

                        l_le_name   := rg_Legal_Emp_Details.name ;
                        l_cvr_number   := rg_Legal_Emp_Details.ORG_INFORMATION1 ;

--                      fnd_file.put_line(fnd_file.log,'l_cvr_number : '||l_cvr_number);

                        CLOSE csr_Legal_Emp_Details;

                        /* Pick up the details belonging to Legal Employer

                        OPEN  csr_Legal_Emp_Details(g_legal_employer_id);
                        FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
                        CLOSE csr_Legal_Emp_Details;

                        l_le_name   := rg_Legal_Emp_Details.name ;
                        l_business_id           := rg_Legal_Emp_Details.ORG_INFORMATION1 ; */

                        -- date and time
                        SELECT to_char(sysdate,'yyyymmdd') INTO l_date FROM dual;
                        SELECT to_char(sysdate,'hhmiss') INTO l_time FROM dual;

                        if(g_test_submission='Y') then
                              l_test_submission:='T';
                        else
                              l_test_submission:='P';
                        end if;

                        if(g_company_terminating='Y') then
                              l_company_terminating:='A';
                        else
                              l_company_terminating:=null;
                        end if;

--Employer Level Information
                        if(rg_Legal_Emp_Details.ORG_INFORMATION3 = 'Y') then  -- if the legal emp has data supplier set to 'Y'

                            --  l_unique_id:=l_cvr_number; /* 9489806 */

                              pay_action_information_api.create_action_information (
                               p_action_information_id        => l_action_info_id
                              ,p_action_context_id            => p_payroll_action_id
                              ,p_action_context_type          => 'PA'
                              ,p_object_version_number        => l_ovn
                              ,p_effective_date               => g_effective_date
                              ,p_source_id                    => NULL
                              ,p_source_text                  => NULL
                              ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                              ,p_action_information1          => 'PYDKEINA'
                              ,p_action_information2          => p_payroll_action_id
                              ,p_action_information3        => '1000'
                              ,p_action_information4        => l_date
                              ,p_action_information5          => l_time
                              ,p_action_information6          => rg_Legal_Emp_Details.ORG_INFORMATION5 -- legal emp SE number
                              ,p_action_information7          => l_cvr_number -- legal emp CVR number
                              ,p_action_information8          => '01'   -- for Legal emp
                              ,p_action_information9          => '0'
                              ,p_action_information10         => 'Oracle Payroll'
                              ,p_action_information11         => '1'
                              ,p_action_information12         => g_sender_id  -- main sender ID
                              ,p_action_information13         => '2.0'
                              ,p_action_information14         => l_test_submission
                              ,p_action_information15         => 'E'
                              ,p_action_information16         => null
                              ,p_action_information17         => null
                              ,p_action_information18         => null
                              ,p_action_information19         => null
                              ,p_action_information20         => null
                              ,p_action_information21         => null
                              ,p_action_information22         => null
                              ,p_action_information23         => null
                              ,p_action_information24         => null
                              ,p_action_information25         => null
                              ,p_action_information26         => null
                              ,p_action_information27         => null
                              ,p_action_information28         => null
                              ,p_action_information29         => null
                              ,p_action_information30         => null);

                        else

                              open service_provider_details;
                              fetch service_provider_details into sp;
                              l_sp_cvr_number := sp.org_information1;

                              -- check the value of e-income data supplier
                              if(sp.org_information3<>'Y') then
                                    fnd_file.put_line(fnd_file.log,HR_DK_UTILITY.GET_MESSAGE('PAY','HR_377103_DK_EINCOME_STATUS'));
                                    g_flag:=1;
                              else
                                   -- l_unique_id:=l_sp_cvr_number; /* 9489806 */

                                    pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_payroll_action_id
                                    ,p_action_context_type          => 'PA'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => p_payroll_action_id
                                    ,p_action_information3        => '1000'
                                    ,p_action_information4        => l_date
                                    ,p_action_information5          => l_time  -- time
                                    ,p_action_information6          => l_sp_cvr_number -- service provider CVR number
                                    ,p_action_information7          => l_sp_cvr_number -- service provider CVR number
                                    ,p_action_information8          => '02'   -- 02 for Service provider
                                    ,p_action_information9          => '0'
                                    ,p_action_information10         => 'Oracle Payroll'
                                    ,p_action_information11         => '1'
                                    ,p_action_information12         => g_sender_id   -- main sender ID (service provider CVR number)
                                    ,p_action_information13         => '2.0'
                                    ,p_action_information14         => l_test_submission
                                    ,p_action_information15         => 'E'
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => null
                                    ,p_action_information25         => null
                                    ,p_action_information26         => null
                                    ,p_action_information27         => null
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
                              end if;
                              close service_provider_details;
                        end if;

                        if(g_flag=0) then
                              -- Record 2001
                              pay_action_information_api.create_action_information (
                               p_action_information_id        => l_action_info_id
                              ,p_action_context_id            => p_payroll_action_id
                              ,p_action_context_type          => 'PA'
                              ,p_object_version_number        => l_ovn
                              ,p_effective_date               => g_effective_date
                              ,p_source_id                    => NULL
                              ,p_source_text                  => NULL
                              ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                              ,p_action_information1          => 'PYDKEINA'
                              ,p_action_information2          => p_payroll_action_id
                              ,p_action_information3        => '2001'
                              ,p_action_information4        => l_cvr_number -- legal emp CVR number
                              ,p_action_information5          => l_company_terminating  -- is null if company termiating is 'N'
                              ,p_action_information6          => 'DKK'
                              ,p_action_information7          => null
                              ,p_action_information8          => null
                              ,p_action_information9          => null
                              ,p_action_information10         => null
                              ,p_action_information11         => null
                              ,p_action_information12         => null
                              ,p_action_information13         => null
                              ,p_action_information14         => null
                              ,p_action_information15         => null
                              ,p_action_information16         => null
                              ,p_action_information17         => null
                              ,p_action_information18         => null
                              ,p_action_information19         => null
                              ,p_action_information20         => null
                              ,p_action_information21         => null
                              ,p_action_information22         => null
                              ,p_action_information23         => null
                              ,p_action_information24         => null
                              ,p_action_information25         => null
                              ,p_action_information26         => null
                              ,p_action_information27         => null
                              ,p_action_information28         => null
                              ,p_action_information29         => null
                              ,p_action_information30         => null);




                              /* Bug fix 7579265 */
                              /* 8861878 p_payroll_action_id */
                              -- l_unique_id:=l_unique_id||lpad(nvl(substr(g_payroll_id,-4),g_payroll_id),4,'0')||to_char(rg_csr_pay_periods.start_date,'mmyy');
                              l_unique_id:=lpad(substr(to_char(p_payroll_action_id), -least(length(p_payroll_action_id),8)),8,0);
			       hr_utility.set_location('RANGE_CODE: Before loop l_unique_id '|| l_unique_id,50);
	             FOR csr_rec in csr_le_payrolls /* 9489806 */
		     LOOP
		              l_unique_id1:=l_unique_id|| lpad( substr(to_char(csr_rec.TIME_PERIOD_ID),-least(length(csr_rec.TIME_PERIOD_ID),5)),5,0) || '00'||'0'; /*  5 digits of time period id 2 digits of employemtn code, 1 digit for correcctin record , */
                              if(g_company_terminating='N') then
                                    -- Record 5000
                                    pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_payroll_action_id
                                    ,p_action_context_type          => 'PA'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => p_payroll_action_id
                                    ,p_action_information3        => '5000'
                                    ,p_action_information4        => to_char(csr_rec.start_date,'yyyymmdd')
                                    ,p_action_information5          => to_char(csr_rec.end_date,'yyyymmdd')
                                    ,p_action_information6          => to_char(csr_rec.default_dd_date,'yyyymmdd')
                                    ,p_action_information7          => 'B'
                                    ,p_action_information8          => '000'  --Greenland code
                                    ,p_action_information9          => '00' --Normal employee code
                                    ,p_action_information10         => l_unique_id1 -- should be reported in field 4 /* Bug fix 7579265 */
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => csr_rec.TIME_PERIOD_ID /* 9489806 */
                                    ,p_action_information25         => csr_rec.payroll_id /* 9489806 */
                                    ,p_action_information26         => null
                                    ,p_action_information27         => null
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
                              end if;
			      END LOOP;

                             /* 9489806QA */
			      IF g_payroll_id IS NOT NULL THEN
                              open csr_payroll_name(g_payroll_id);
                              fetch csr_payroll_name into l_payroll_name;
                              close csr_payroll_name;
			      END IF;

--                            fnd_file.put_line(fnd_file.log,'Range Code 14');
                              --Report Level Information
                              pay_action_information_api.create_action_information (
                              p_action_information_id        => l_action_info_id
                              ,p_action_context_id            => p_payroll_action_id
                              ,p_action_context_type          => 'PA'
                              ,p_object_version_number        => l_ovn
                              ,p_effective_date               => g_effective_date
                              ,p_source_id                    => NULL
                              ,p_source_text                  => NULL
                              ,p_action_information_category  => 'EMEA REPORT DETAILS'
                              ,p_action_information1          => 'PYDKEINA'
                              ,p_action_information2          => l_le_name
                              ,p_action_information3          =>  l_payroll_name     -- PAYROLL NAME if given in parameter 9489806
                              ,p_action_information4          =>  NULL               -- earlier PAYROLL PERIOD NAME now NULL
                              ,p_action_information5          => HR_GENERAL.DECODE_LOOKUP('YES_NO',g_test_submission)       -- TEST SUBMISSION
                              ,p_action_information6          => HR_GENERAL.DECODE_LOOKUP('YES_NO',g_company_terminating) -- COMPANY TERMINATING
                              ,p_action_information7          => null
                              ,p_action_information8          =>  g_start_date /* 9489806 */
                              ,p_action_information9          =>  g_end_date /* 9489806 */
                              ,p_action_information10         => null
                              ,p_action_information11         =>  null
                              ,p_action_information12         =>  null
                              ,p_action_information13         =>  null
                              ,p_action_information14         =>  null
                              ,p_action_information15         =>  null
                              ,p_action_information16         =>  null
                              ,p_action_information17         =>   null
                              ,p_action_information18         =>  null
                              ,p_action_information19         =>   null
                              ,p_action_information20         =>  null
                              ,p_action_information21         =>  null
                              ,p_action_information22         =>   null
                              ,p_action_information23         =>  null
                              ,p_action_information24         =>  null
                              ,p_action_information25         =>  null
                              ,p_action_information26         =>  null
                              ,p_action_information27         =>  null
                              ,p_action_information28         => null
                              ,p_action_information29         =>  null
                              ,p_action_information30         =>  null );

--                            fnd_file.put_line(fnd_file.log,'Range Code 15');

                        end if; -- end g_flag condition

                  END IF;

                   IF g_debug THEN
                        hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
                   END IF;

            EXCEPTION
                  WHEN others THEN
                        IF g_debug THEN
                            hr_utility.set_location('error raised assignment_action_code ',5);
                        END if;
                      RAISE;
             END RANGE_CODE;

       /* ASSIGNMENT ACTION CODE */
       PROCEDURE ASSIGNMENT_ACTION_CODE
       (p_payroll_action_id     IN NUMBER
       ,p_start_person          IN NUMBER
       ,p_end_person            IN NUMBER
       ,p_chunk                 IN NUMBER )
       IS

            l_canonical_start_date DATE;
            l_canonical_end_date    DATE;
            l_prepay_action_id     NUMBER;
            l_prev_person_id       NUMBER;
            l_prev_local_unit_id  NUMBER;
            l_actid NUMBER;


            CURSOR csr_prepaid_assignments_le(p_payroll_action_id             NUMBER,
                   p_start_person         NUMBER,
                   p_end_person         NUMBER,
                   p_legal_employer_id                NUMBER,
                   p_payroll_id NUMBER,
                   p_payroll_period NUMBER,
                   l_canonical_start_date DATE,
                   l_canonical_end_date   DATE)
             IS
            SELECT as1.person_id  person_id,
            act.assignment_id            assignment_id,
            act.assignment_action_id     run_action_id,
            act1.assignment_action_id    prepaid_action_id
            FROM   pay_payroll_actions          ppa
            ,pay_payroll_actions          appa
            ,pay_payroll_actions          appa2
            ,pay_assignment_actions       act
            ,pay_assignment_actions       act1
            ,pay_action_interlocks        pai
            ,per_all_assignments_f        as1
            WHERE  ppa.payroll_action_id        = p_payroll_action_id
            AND    appa.effective_date          BETWEEN l_canonical_start_date
            AND     l_canonical_end_date
            AND    as1.person_id                BETWEEN p_start_person
            AND     p_end_person
            AND    appa.action_type             IN ('R','Q')
            -- Payroll Run or Quickpay Run
            AND    act.payroll_action_id        = appa.payroll_action_id
--aapa table add time period check
           -- AND   appa.time_period_id         = p_payroll_period
	    AND appa.effective_date between l_canonical_start_date and l_canonical_end_date
            AND    act.source_action_id         IS NULL -- Master Action
            AND    as1.assignment_id            = act.assignment_id
-- Add payroll id
            AND   as1.payroll_id              = nvl(p_payroll_id,as1.payroll_id) /* 9489806 */
            --             Commenting Code to Include Terminated Assignments
--          AND    ppa.effective_date           BETWEEN as1.effective_start_date
--          AND     as1.effective_end_date
            AND    act.action_status            = 'C'  -- Completed
            AND    act.assignment_action_id     = pai.locked_action_id
            AND    act1.assignment_action_id    = pai.locking_action_id
            AND    act1.action_status           = 'C' -- Completed
            AND    act1.payroll_action_id     = appa2.payroll_action_id
            AND    appa2.action_type            IN ('P','U')
            AND    appa2.effective_date          BETWEEN l_canonical_start_date
            AND l_canonical_end_date
            -- Prepayments or Quickpay Prepayments
            AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
            AND   act.TAX_UNIT_ID    =  p_legal_employer_id
            ORDER BY  as1.person_id  , act.assignment_id;

            cursor csr_pay_periods(p_payroll_id NUMBER, p_payroll_period NUMBER)
            is
            select start_date, end_date from per_time_periods
            where payroll_id = p_payroll_id
            and time_period_id = p_payroll_period;

            pp csr_pay_periods%rowtype;

       BEGIN
            if(g_flag=0) then
--                fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 1');

                  IF g_debug THEN
                  hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
                  END IF;

                        PAY_DK_ARCHIVE_EIN.GET_ALL_PARAMETERS(
                        p_payroll_action_id
                        ,g_business_group_id
                        ,g_legal_employer_id
                        ,g_effective_date
                        ,g_payroll_id
                        --,g_payroll_period
			,g_payroll_type
			,g_start_date
			,g_end_date
                        ,g_test_submission
                        ,g_company_terminating
                        ,g_sender_id) ;

--                fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 2');

                  g_payroll_action_id :=p_payroll_action_id;

                  /*
		  open csr_pay_periods(g_payroll_id, g_payroll_period);
                  fetch csr_pay_periods into pp;
                  l_canonical_start_date := pp.start_date;
                  l_canonical_end_date   := pp.end_date;
		  */
		  l_canonical_start_date := fnd_date.canonical_to_date(g_start_date);
                  l_canonical_end_date   := fnd_date.canonical_to_date(g_end_date);

                  l_prepay_action_id := 0;
                  l_prev_person_id := 0;

--                fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 3');

                  FOR rec_prepaid_assignments IN csr_prepaid_assignments_le(p_payroll_action_id
                  ,p_start_person
                  ,p_end_person
                  ,g_legal_employer_id
                  ,g_payroll_id
                  ,g_payroll_period
                  ,l_canonical_start_date
                  ,l_canonical_end_date)
                  LOOP
                        IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id
                        AND l_prev_person_id <> rec_prepaid_assignments.person_id THEN

                              SELECT pay_assignment_actions_s.NEXTVAL
                              INTO   l_actid
                              FROM   dual;

                               -- Create the archive assignment action
                                  hr_nonrun_asact.insact(l_actid
                                ,rec_prepaid_assignments.assignment_id
                                ,p_payroll_action_id
                                ,p_chunk
                                ,NULL);

--                              fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 7');

                        END IF;
                        l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
                        l_prev_person_id := rec_prepaid_assignments.person_id;
                  END LOOP;

                  IF g_debug THEN
                       hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
                  END IF;
            end if; -- end g_flag condition.

      EXCEPTION
              WHEN others THEN
                  IF g_debug THEN
                      hr_utility.set_location('error raised assignment_action_code ',5);
                  END if;
                  RAISE;
      END ASSIGNMENT_ACTION_CODE;


       /* INITIALIZATION CODE */
       PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
       IS

       BEGIN
             IF g_debug THEN
                  hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
             END IF;
--          fnd_file.put_line(fnd_file.log,'INITIALIZATION_CODE 1');
              IF g_debug THEN
                  hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
             END IF;

      EXCEPTION
            WHEN others THEN
                  IF g_debug THEN
                      hr_utility.set_location('error raised initialization code ',5);
                  END if;
                  RAISE;
       END INITIALIZATION_CODE;

       /* ARCHIVE CODE */
       PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
                        ,p_effective_date    IN DATE)
       IS
            /* Cursor to retrieve Person Details */
            CURSOR csr_get_person_details(p_asg_act_id NUMBER , p_asg_effective_date DATE ) IS
            SELECT pap.national_identifier cpr , pap.person_id  , pac.assignment_id, pap.full_name, to_char(pap.date_of_birth,'yyyymmdd') dob,
            pap.first_name||' '||pap.middle_names||' '||pap.last_name pname, pap.sex, pap.start_date, pap.business_group_id,
            assign.hourly_salaried_code HOURLY_SALARIED_CODE, assign.assignment_number, assign.organization_id, assign.primary_flag,
            assign.location_id
            FROM
            pay_assignment_actions        pac,
            per_all_assignments_f             assign,
            per_all_people_f              pap
            WHERE pac.assignment_action_id = p_asg_act_id
            AND assign.assignment_id = pac.assignment_id
            AND assign.person_id = pap.person_id
            AND pap.per_information_category = 'DK'
            AND p_asg_effective_date BETWEEN assign.effective_start_date
            AND assign.effective_end_date
            AND p_asg_effective_date BETWEEN pap.effective_start_date
            AND pap.effective_end_date;

            rg_csr_get_person_details  csr_get_person_details%rowtype;

            /* Getting the latest hire date */
            /* For Bug 9011035 */
            CURSOR csr_latest_hire_date(pid per_all_people_f.person_id%type
                                       ,p_end_date DATE) IS
            SELECT MAX(date_start) lhd FROM per_periods_of_service
            WHERE person_id=pid
              AND date_start <= p_end_date;

            rg_csr_latest_hire_date csr_latest_hire_date%rowtype;

            /* Cursor to get the extra person info - Foreigner (yes/no) */
            CURSOR csr_get_extra_person_info(pid per_all_people_f.person_id%type) IS
            SELECT PEI_INFORMATION1 yes_no FROM per_people_extra_info
            WHERE person_id=pid
            AND information_type='DK_EINCOME_FORIEGN_IND';

            rg_csr_get_extra_person_info csr_get_extra_person_info%rowtype;

            /* Get the territory */
            CURSOR csr_get_territory(pid per_all_people_f.person_id%type) IS
                  SELECT *
                  FROM per_addresses_v
                  WHERE person_id =pid
                  and primary_flag='Y';

            rg_csr_get_territory csr_get_territory%rowtype;

            /* Cursor to get SE Number, PUCODE at HR Org level */

            CURSOR csr_get_hr_org_info(
             bg_id hr_organization_units.business_group_id%type
            ,hr_org_id hr_organization_information.organization_id%type) IS
            SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION2, hoi2.ORG_INFORMATION3, hoi2.ORG_INFORMATION4,
            hoi2.ORG_INFORMATION5, hoi2.ORG_INFORMATION6, hoi2.ORG_INFORMATION13
            FROM hr_organization_units o1
            , hr_organization_information hoi1
            , hr_organization_information hoi2
            WHERE  o1.business_group_id =bg_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id =   hr_org_id
            AND hoi1.org_information1 = 'HR_ORG'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id =hoi2.organization_id
            AND hoi2.ORG_INFORMATION_CONTEXT='DK_EMPLOYMENT_DEFAULTS' ;

            rg_csr_get_hr_org_info csr_get_hr_org_info%rowtype;

            /* Payroll Time period */
            CURSOR csr_pay_periods(p_payroll_id NUMBER, p_payroll_period NUMBER)
            IS
            SELECT ptp.start_date, ptp.end_date,
            default_dd_date,
              decode(PERIOD_TYPE
                    ,'Calendar Month','1'
                  ,'Bi-Week'       ,'2'
                      ,'Week'          ,'3'
                    ,'Lunar Month'   ,'4')  PAYROLL_PERIOD
            from per_time_periods ptp
            WHERE payroll_id = p_payroll_id
            AND time_period_id = p_payroll_period;

            rg_csr_pay_periods csr_pay_periods%rowtype;

            /* Cursor to get the details of the legal employer */
            Cursor csr_Legal_Emp_Details ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
            IS
            SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION2, hoi2.ORG_INFORMATION3, hoi2.ORG_INFORMATION4, hoi2.ORG_INFORMATION5, hoi2.ORG_INFORMATION6, hoi2.ORG_INFORMATION13
            FROM hr_organization_units o1
            , hr_organization_information hoi1
            , hr_organization_information hoi2
            WHERE  o1.business_group_id =g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id =  csr_v_legal_emp_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id =hoi2.organization_id
            AND hoi2.ORG_INFORMATION_CONTEXT='DK_LEGAL_ENTITY_DETAILS' ;

            rg_Legal_Emp_Details  csr_Legal_Emp_Details%rowtype;

        CURSOR csr_location_info (p_location_id hr_location_extra_info.location_id%TYPE) IS
        SELECT lei_information1
        FROM hr_location_extra_info
        WHERE location_id = p_location_id
        AND information_type='DK_LOCATION_INFO';
        /* 9489806 */
	CURSOR csr_asg_payroll
               (c_canonical_start_date DATE,
	        c_canonical_end_date DATE,
		c_assignment_id   NUMBER
	       ) IS
                SELECT DISTINCT
			ppf.payroll_id,
			ptp.time_period_id,
			ppf.payroll_name,
			ptp.period_name

		FROM
			pay_payrolls_f ppf,
			per_assignments_f paf,
			per_time_periods ptp
		WHERE paf.payroll_id = ppf.payroll_id
		AND paf.assignment_id=c_assignment_id
		AND ppf.payroll_id=NVL(g_payroll_id,ppf.payroll_id)
		AND ppf.effective_start_date <= c_canonical_start_date and ppf.effective_end_date >= c_canonical_end_date
		AND ptp.payroll_id=ppf.payroll_id
		AND ptp.end_date BETWEEN c_canonical_start_date AND c_canonical_end_date
		AND ppf.business_group_id = g_business_group_id
		AND ptp.end_date between paf.effective_start_date and paf.effective_end_date;

        rg_csr_location_info csr_location_info%ROWTYPE;

            /* Cursor to retrieve Element - Employee ATP*/
            CURSOR csr_get_atp_table_value(p_assignment_id NUMBER , p_start_date  DATE , p_end_date  DATE ) IS
            SELECT  eev1.screen_entry_value  screen_entry_value
            FROM   per_all_assignments_f      asg1
            ,per_all_people_f           per
            ,pay_element_links_f        el
            ,pay_element_types_f        et
            ,pay_input_values_f         iv1
            ,pay_element_entries_f      ee
            ,pay_element_entry_values_f eev1
            WHERE  asg1.assignment_id    = p_assignment_id
            AND  per.person_id         = asg1.person_id
            AND  et.element_name       = 'Employee ATP'
            AND  et.legislation_code   = 'DK'
            AND  iv1.element_type_id   = et.element_type_id
            AND  iv1.name              = 'ATP Table'
            AND  el.business_group_id  = per.business_group_id
            AND  el.element_type_id    = et.element_type_id
            AND  ee.element_link_id    = el.element_link_id
            AND  ee.assignment_id      = asg1.assignment_id
            AND  eev1.element_entry_id = ee.element_entry_id
            AND  eev1.input_value_id   = iv1.input_value_id
            AND  asg1.effective_end_date >= p_start_date
            AND  asg1.effective_start_date <=  p_end_date
            AND  per.effective_end_date    >= p_start_date
            AND  per.effective_start_date <=  p_end_date
            AND  ee.effective_end_date      >= p_start_date
            AND  ee.effective_start_date <=  p_end_date
            AND  ((eev1.effective_start_date <= p_start_date
            AND  eev1.effective_end_date >= p_start_date )
            OR     (eev1.effective_start_date BETWEEN  p_start_date AND p_end_date
            AND  eev1.effective_end_date >= p_end_date ));

            rg_csr_get_atp_table_value  csr_get_atp_table_value%rowtype;

            /* Cursor to retrieve Element - Tax Card*/
            CURSOR csr_get_tax_card_details(p_assignment_id NUMBER , p_start_date  DATE , p_end_date  DATE ) IS
            SELECT  ee.effective_start_date, eev1.screen_entry_value
            FROM   per_all_assignments_f      asg1
            ,per_all_people_f           per
            ,pay_element_links_f        el
            ,pay_element_types_f        et
            ,pay_input_values_f         iv1
            ,pay_element_entries_f      ee
            ,pay_element_entry_values_f eev1
            WHERE  asg1.assignment_id    = p_assignment_id
            AND  per.person_id         = asg1.person_id
            AND  et.element_name       = 'Tax Card'
            AND  et.legislation_code   = 'DK'
            AND  iv1.element_type_id   = et.element_type_id
            AND  iv1.name              = 'Tax Card Type'
            AND  el.business_group_id  = per.business_group_id
            AND  el.element_type_id    = et.element_type_id
            AND  ee.element_link_id    = el.element_link_id
            AND  ee.assignment_id      = asg1.assignment_id
            AND  eev1.element_entry_id = ee.element_entry_id
            AND  eev1.input_value_id   = iv1.input_value_id
            AND  asg1.effective_end_date >= p_start_date
            AND  asg1.effective_start_date <=  p_end_date
            AND  per.effective_end_date    >= p_start_date
            AND  per.effective_start_date <=  p_end_date
            AND  ee.effective_end_date      >= p_start_date
            AND  ee.effective_start_date <=  p_end_date
            AND  ((eev1.effective_start_date <= p_start_date
            AND  eev1.effective_end_date >= p_start_date )
            OR     (eev1.effective_start_date BETWEEN  p_start_date AND p_end_date
            AND  eev1.effective_end_date >= p_end_date ));

            rg_csr_get_tax_card_details  csr_get_tax_card_details%rowtype;

            /* Cursor to know the terminator in payroll period */
            CURSOR csr_asg_terminator
            (p_asg_act_id NUMBER
            ,p_start_date DATE
            ,p_end_date DATE
            ,p_business_group_id NUMBER) IS
            SELECT MAX( EFFECTIVE_END_DATE) EFFECTIVE_END_DATE
            FROM  per_all_assignments_f             paa
            ,pay_assignment_actions       pac
            WHERE pac.assignment_action_id = p_asg_act_id
            AND paa.assignment_id = pac.assignment_id
            AND paa.EFFECTIVE_START_DATE  <= p_end_date
            AND paa.EFFECTIVE_END_DATE > = p_start_date
            AND assignment_status_type_id IN
            (select assignment_status_type_id
            from per_assignment_status_types
            where per_system_status = 'ACTIVE_ASSIGN'
            and active_flag = 'Y'
            and (( legislation_code is null
            and business_group_id is null)
            OR (BUSINESS_GROUP_ID = p_business_group_id)));

            rg_csr_asg_terminator csr_asg_terminator%rowtype;

            CURSOR csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)    IS
            SELECT       ue.creator_id
            FROM  ff_user_entities  ue, ff_database_items di
            WHERE di.user_name = csr_v_Balance_Name
            AND   ue.user_entity_id = di.user_entity_id
            AND   ue.legislation_code = 'DK'
            AND   ue.business_group_id is NULL
            AND   ue.creator_type = 'B';
            lr_Get_Defined_Balance_Id  csr_Get_Defined_Balance_Id%rowtype;

            CURSOR csr_asg_action_id(assg_id NUMBER, pid NUMBER, tid NUMBER, le_id NUMBER) IS
            select MAX(pac.ASSIGNMENT_ACTION_ID) id
            from pay_assignment_actions pac, pay_payroll_actions ppa
            where ppa.action_type             IN ('R','Q')
            and pac.payroll_action_id   = ppa.payroll_action_id
            and pac.assignment_id= assg_id
            and ppa.payroll_id=pid
            and ppa.time_period_id=tid
            and pac.tax_unit_id=le_id;
            rg_csr_asg_action_id csr_asg_action_id%rowtype;

            --Bug 8522052 record 6003
            CURSOR csr_asg_extra_info (p_assgt_id NUMBER) IS
            SELECT *
            FROM per_assignment_extra_info
            WHERE information_type = 'DK_EINCOME_INFO'
            AND assignment_id = p_assgt_id;

            rg_csr_asg_extra_info csr_asg_extra_info%ROWTYPE;

	    CURSOR csr_prepaid_actions_present(p_payroll_action_id             NUMBER,
                                       p_legal_employer_id                NUMBER,
                                       p_payroll_id NUMBER,
                                       p_payroll_period NUMBER,
                                       l_canonical_start_date DATE,
                                       l_canonical_end_date   DATE,
				       l_assignment_id NUMBER)
             IS
            SELECT 1
            FROM   pay_payroll_actions          ppa
            ,pay_payroll_actions          appa
            ,pay_payroll_actions          appa2
            ,pay_assignment_actions       act
            ,pay_assignment_actions       act1
            ,pay_action_interlocks        pai
            ,per_all_assignments_f        as1

            WHERE  ppa.payroll_action_id        = p_payroll_action_id
            AND    appa.effective_date          BETWEEN l_canonical_start_date
            AND     l_canonical_end_date
            AND    appa.action_type             IN ('R','Q')
            AND    act.payroll_action_id        = appa.payroll_action_id
            AND   appa.time_period_id         = p_payroll_period
	    AND appa.effective_date between l_canonical_start_date and l_canonical_end_date
            AND    act.source_action_id         IS NULL -- Master Action
            AND    as1.assignment_id            = act.assignment_id
            AND   as1.payroll_id              = p_payroll_id
            AND    act.action_status            = 'C'  -- Completed
            AND    act.assignment_action_id     = pai.locked_action_id
            AND    act1.assignment_action_id    = pai.locking_action_id
            AND    act1.action_status           = 'C' -- Completed
            AND    act1.payroll_action_id     = appa2.payroll_action_id
            AND    appa2.action_type            IN ('P','U')
            AND    appa2.effective_date          BETWEEN l_canonical_start_date
            AND l_canonical_end_date
            -- Prepayments or Quickpay Prepayments
            AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
            AND   act.TAX_UNIT_ID    =  p_legal_employer_id
	    AND   as1.assignment_id  =  l_assignment_id;

            l_present_flag NUMBER:=0;
	    l_assignment_action_id NUMBER;
            l_payroll_action_id NUMBER;
	    l_ass_id  NUMBER; /* 9489806 */
	    l_payroll_id     NUMBER;
	    l_employment_type  VARCHAR2(10):='00';
	    l_green_land_code VARCHAR2(10):='000'; /* 8847591 */
	    l_period_id      NUMBER;
            l_action_context_id     NUMBER;
            l_flag NUMBER := 0;
            l_action_info_id NUMBER;
            l_ovn NUMBER;
            l_dob VARCHAR2(8);
            l_sex VARCHAR2(10);
            l_tax_card_type VARCHAR2(5);
            l_payment_type VARCHAR2(5);
            l_source_text VARCHAR2(10);
            l_source_text2 VARCHAR2(10);
            l_org_type VARCHAR2(5);
            l_country_code    varchar2(50);
            l_age_category varchar2(1);
            l_hourly_salaried varchar2(1):=null;
            l_start_date DATE;
            l_end_date DATE;
            l_assignment NUMBER:=null;
            l_primary VARCHAR2(2):=null;
            l_bal_date  DATE;
            l_assignment_id NUMBER:=0;
            l_yes_no VARCHAR2(10);
            l_style VARCHAR2(30);
            l_town_or_city VARCHAR2(30);
	    l_canonical_start_date DATE; /* 9489806 */
            l_canonical_end_date    DATE;

            l_sp_bonus        NUMBER(12,2);
            l_free_phone            NUMBER(12,2);
	    l_multimedia            NUMBER(12,2); -- bug# 9079593 fix
	    l_trivial_matter  NUMBER(12,2);  -- bug# 9169583 fix
            l_mileage         NUMBER(12,2);
      --    l_b_income        NUMBER(12,2);
            l_total_atp       NUMBER(12,2);
            l_employer_atp          NUMBER(12,2);
            l_board_lodge           NUMBER(12,2);
            l_car             NUMBER(12,2);
            /* 8861878 */
            --
            l_non_taxable_travel     NUMBER(12,2);
            l_b_income_amb           NUMBER(12,2);
            l_b_income_non_amb       NUMBER(12,2);
            l_a_non_amb_income       NUMBER(12,2);
            l_pension_sev_pay        NUMBER(12,2);
            l_physical_gift_sev_pay  NUMBER(12,2);
            --
            l_car_adj               NUMBER(12,2);
            l_amb_pay_adj NUMBER(12,2);
            l_emp_atp_adj NUMBER(12,2);
            l_sp_bonus_adj NUMBER(12,2);
            l_free_phone_adj NUMBER(12,2);
	    l_multimedia_adj NUMBER(12,2); -- bug# 9079593 fix
	    l_trivial_matter_adj  NUMBER(12,2);  -- bug# 9169583 fix
            l_mileage_adj NUMBER(12,2);
            l_empr_atp_adj NUMBER(12,2);
            l_board_lodge_adj NUMBER(12,2);
            l_a_income_adj NUMBER(12,2);
      --    l_b_income_adj NUMBER(12,2);
            l_hourly_holiday_pay_adj NUMBER(12,2);
            l_monthly_holiday_pay_adj NUMBER(12,2);
            /* 8861878 */
            --
            l_non_taxable_travel_adj     NUMBER(12,2);
            l_b_income_amb_adj           NUMBER(12,2);
            l_b_income_non_amb_adj       NUMBER(12,2);
            l_a_income_non_amb_adj       NUMBER(12,2);
            l_pension_sev_pay_adj        NUMBER(12,2);
            l_physical_gift_sev_pay_adj  NUMBER(12,2);
            --

            l_total_amb       NUMBER(12,2);
            l_hol_amb         NUMBER(12,2);
            l_hol_amb_rep           NUMBER(12,2);
            l_emp_amb         NUMBER(12,2);
            l_tax             NUMBER(12,2);
            l_emp_tax         NUMBER(12,2);
            l_holiday_tax           NUMBER(12,2);
            l_holiday_tax_pay       NUMBER(12,2);
            l_a_income        NUMBER(12,2);
            l_monthly_holiday_pay   NUMBER(12,2);
            l_hourly_holiday_pay    NUMBER(12,2);
            l_gross_income          NUMBER(12,2);
            l_emp_atp         NUMBER(12,2);
            l_amb_pay         NUMBER(12,2);
            l_amb             NUMBER(12,2);
            l_cvr_number        hr_organization_information.org_information1%TYPE ;
            l_cpr_number            VARCHAR2(15);
            l_pu_code         hr_organization_information.ORG_INFORMATION6%type;
            l_total_atp_hours       NUMBER;
            l_atp               NUMBER;
            L_6005_SIGN             VARCHAR2(1);
            l_bg_id                 NUMBER;
            l_org_id          NUMBER;
            l_hd              VARCHAR2(100);
            l_loc_id  NUMBER := NULL;
            l_pension NUMBER     := 0;

            PROCEDURE rec_6001(
             pid pay_action_information.action_information1%type
            ,aid pay_action_information.action_information1%type
            ,code pay_action_information.action_information1%type
            ,amt pay_action_information.action_information1%type
            ,sgn pay_action_information.action_information1%type
            ,corr pay_action_information.action_information1%type
	    ,p_payroll_id pay_action_information.action_information1%type
	    ,p_employment_type pay_action_information.action_information1%type
	    ,p_period_id pay_action_information.action_information1%type
	    ,p_green_land_code pay_action_information.action_information1%type /* 8847591 */
            )
            IS
                  l_sgn pay_action_information.action_information1%type:=NULL;
                  amt1 pay_action_information.action_information1%type:=NULL;
            BEGIN

                  if(sgn='-1') then
                        l_sgn:='-';
                  else
                        l_sgn:='+';
                  end if;

                  amt1:=lpad(amt,16,'0');
                  --Record - 6001
                  pay_action_information_api.create_action_information (
                   p_action_information_id        => l_action_info_id
                  ,p_action_context_id            => p_assignment_action_id
                  ,p_action_context_type          => 'AAP'
                  ,p_object_version_number        => l_ovn
                  ,p_effective_date               => g_effective_date
                  ,p_source_id                    => NULL
                  ,p_source_text                  => NULL
                  ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                  ,p_action_information1          => 'PYDKEINA'
                  ,p_action_information2          => l_payroll_action_id
                  ,p_action_information3        => '6001'
                  ,p_action_information4        => pid --rg_csr_get_person_details.PERSON_ID
                  ,p_action_information5          => aid --rg_csr_get_person_details.assignment_ID
                  ,p_action_information6          => code -- code according to the element entry reported
                  ,p_action_information7          => amt1 -- element value
                  ,p_action_information8          => l_sgn -- (+/-)
                  ,p_action_information9          => null
                  ,p_action_information10         => null
                  ,p_action_information11         => null
                  ,p_action_information12         => null
                  ,p_action_information13         => null
                  ,p_action_information14         => null
                  ,p_action_information15         => null
                  ,p_action_information16         => null
                  ,p_action_information17         => null
                  ,p_action_information18         => null
                  ,p_action_information19         => null
                  ,p_action_information20         => null
                  ,p_action_information21         => null
                  ,p_action_information22         => null
                  ,p_action_information23         => null
                  ,p_action_information24         => p_period_id /* 9489806 */
                  ,p_action_information25         => p_payroll_id /* 9489806 */
                  ,p_action_information26         => p_employment_type /* 9489806 to link respective 6000 with its 5000 rec */
                  ,p_action_information27         => p_green_land_code /* green land code  8847591 */
                  ,p_action_information28         => null
                  ,p_action_information29         => corr
                  ,p_action_information30         => null);
            END;

	    /* 9489806 */
	    PROCEDURE rec_5000(
             p_payroll_action_id NUMBER
            ,p_payroll_id pay_action_information.action_information1%type
	    ,p_employement_type pay_action_information.action_information1%type
	    ,p_period_id pay_action_information.action_information1%type
	    ,p_green_land_code pay_action_information.action_information1%type /* 8847591 */
            )
            IS
                CURSOR csr_chk_5000  IS
	            SELECT  *
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_information2 = to_char(p_payroll_action_id)
	            AND pai.action_information3 IN ('5000')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information24 =p_period_id
		    AND pai.action_information9='00'; /* 9587046 */
		    rec_csr_chk_5000 csr_chk_5000%ROWTYPE;

		CURSOR csr_chk_5000_emp  IS
	            SELECT  1
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_information2 = to_char(p_payroll_action_id)
	            AND pai.action_information3 IN ('5000')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information9 =p_employement_type
		    AND pai.action_information24 =p_period_id
		    AND pai.action_information8 =p_green_land_code; /* 8847591 */

		 l_flag NUMBER:=0;
	         l_action_info_id NUMBER;
	         l_ovn NUMBER;
		 l_unique_id VARCHAR2(16);
            BEGIN
		    hr_utility.set_location(' Entered Procedure rec_5000',500);
		    hr_utility.set_location('rec_5000:p_payroll_action_id'|| p_payroll_action_id ,501);
		    hr_utility.set_location('rec_5000:p_payroll_id'|| p_payroll_id ,501);
		    hr_utility.set_location('rec_5000:p_employement_type'|| p_employement_type ,501);
		    hr_utility.set_location('rec_5000:p_green_land_code'|| p_green_land_code ,501); /* 8847591 */
		    OPEN csr_chk_5000_emp;
		    FETCH csr_chk_5000_emp into l_flag;
		    CLOSE csr_chk_5000_emp;
    		    hr_utility.set_location('rec_5000:After fetch l_flag'|| l_flag ,501);

		    IF   l_flag<>1 THEN
		    hr_utility.set_location('rec_5000:Entered  l_flag IF'|| l_flag ,501);
			       OPEN csr_chk_5000;
			       FETCH csr_chk_5000 INTO rec_csr_chk_5000;
			       CLOSE csr_chk_5000;
			       IF p_green_land_code='000' THEN /* 8847591 */
			       l_unique_id:=substr(rec_csr_chk_5000.action_information10,1,8);
			       ELSE
                               l_unique_id:=substr(p_green_land_code,2,2)||substr(rec_csr_chk_5000.action_information10,3,6); /* in case of green land code firts 2 digits green land code..next 6 digits of payroll action id */
			       END IF;
                               l_unique_id:=l_unique_id || lpad(substr(p_period_id,-least(length(p_period_id),5)),5,0) || p_employement_type||'0';

	                        pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_payroll_action_id
                                    ,p_action_context_type          => 'PA'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => rec_csr_chk_5000.action_information2
                                    ,p_action_information3        => '5000'
                                    ,p_action_information4        => rec_csr_chk_5000.action_information4 -- to_char(csr_rec.start_date,'yyyymmdd')
                                    ,p_action_information5          => rec_csr_chk_5000.action_information5 --to_char(csr_rec.end_date,'yyyymmdd')
                                    ,p_action_information6          => rec_csr_chk_5000.action_information6 --to_char(csr_rec.default_dd_date,'yyyymmdd')
                                    ,p_action_information7          => rec_csr_chk_5000.action_information7 --'B'
                                    ,p_action_information8          => p_green_land_code -- '000'  --Greenland code /* 8847591 */
                                    ,p_action_information9          => p_employement_type  -- employee code
                                    ,p_action_information10         => l_unique_id
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => p_period_id /* 9489806 */
                                    ,p_action_information25         => rec_csr_chk_5000.action_information25  /* 9489806 */
                                    ,p_action_information26         => null
                                    ,p_action_information27         => null
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
              hr_utility.set_location('rec_5000:Last statement  l_flag IF'|| l_flag ,501);


		    END IF;
		    hr_utility.set_location(' Leaving Procedure rec_5000',500);

	    END;

	    PROCEDURE rec_5000R(
             p_payroll_action_id NUMBER
            ,p_payroll_id pay_action_information.action_information1%type
	    ,p_employement_type pay_action_information.action_information1%type
	    ,p_period_id pay_action_information.action_information1%type
	    ,p_green_land_code pay_action_information.action_information1%type /* 8847591 */
            )
            IS
                CURSOR csr_chk_5000  IS
	            SELECT  *
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_information2 = to_char(p_payroll_action_id)
	            AND pai.action_information3 IN ('5000')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information24 =p_period_id
		    AND pai.action_information9='00'; /* 9587046 */
		    rec_csr_chk_5000 csr_chk_5000%ROWTYPE;

		CURSOR csr_chk_5000_emp  IS
	            SELECT  1
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_information2 = to_char(p_payroll_action_id)
	            AND pai.action_information3 IN ('5000R')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information9 =p_employement_type
		    AND pai.action_information24 =p_period_id
		    AND pai.action_information8 =p_green_land_code; /* 8847591 */

		 l_flag NUMBER:=0;
	         l_action_info_id NUMBER;
	         l_ovn NUMBER;
		 l_unique_id VARCHAR2(16);
            BEGIN
		    hr_utility.set_location(' Entered Procedure rec_5000R',500);
		    hr_utility.set_location('rec_5000R:p_payroll_action_id'|| p_payroll_action_id ,501);
		    hr_utility.set_location('rec_5000R:p_payroll_id'|| p_payroll_id ,501);
		    hr_utility.set_location('rec_5000R:p_employement_type'|| p_employement_type ,501);
   		    hr_utility.set_location('rec_5000R:p_green_land_code'|| p_green_land_code ,501); /* 8847591 */
		    OPEN csr_chk_5000_emp;
		    FETCH csr_chk_5000_emp into l_flag;
		    CLOSE csr_chk_5000_emp;
    		    hr_utility.set_location('rec_5000R:After fetch l_flag'|| l_flag ,501);

		    IF   l_flag<>1 THEN
		    hr_utility.set_location('rec_5000:Entered  l_flag IF'|| l_flag ,501);
			       OPEN csr_chk_5000;
			       FETCH csr_chk_5000 INTO rec_csr_chk_5000;
			       CLOSE csr_chk_5000;
			       IF p_green_land_code='000' THEN /* 8847591 */
			       l_unique_id:=substr(rec_csr_chk_5000.action_information10,1,8);
			       ELSE
                               l_unique_id:=substr(p_green_land_code,2,2)||substr(rec_csr_chk_5000.action_information10,3,6); /* in case of green land code firts 2 digits green land code..next 6 digits of payroll action id */
			       END IF;

			       l_unique_id:=l_unique_id || lpad(substr(p_period_id,-least(length(p_period_id),5)),5,0) || p_employement_type||'1';
	                        pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_payroll_action_id
                                    ,p_action_context_type          => 'PA'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => rec_csr_chk_5000.action_information2
                                    ,p_action_information3        => '5000R'
                                    ,p_action_information4        => rec_csr_chk_5000.action_information4 -- to_char(csr_rec.start_date,'yyyymmdd')
                                    ,p_action_information5          => rec_csr_chk_5000.action_information5 --to_char(csr_rec.end_date,'yyyymmdd')
                                    ,p_action_information6          => rec_csr_chk_5000.action_information6 --to_char(csr_rec.default_dd_date,'yyyymmdd')
                                    ,p_action_information7          => rec_csr_chk_5000.action_information7 --'B'
                                    ,p_action_information8          => p_green_land_code -- '000'  --Greenland code /* 8847591 */
                                    ,p_action_information9          => p_employement_type  -- employee code
                                    ,p_action_information10         => l_unique_id -- should be reported in field 4 /* Bug fix 7579265 */
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => p_period_id /* 9489806 */
                                    ,p_action_information25         => rec_csr_chk_5000.action_information25  /* 9489806 */
                                    ,p_action_information26         => null
                                    ,p_action_information27         => null
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
              hr_utility.set_location('rec_5000R:Last statement  l_flag IF'|| l_flag ,501);


		    END IF;
		    hr_utility.set_location(' Leaving Procedure rec_5000R',500);

	    END;
	    PROCEDURE rec_6000R(
             p_assignment_action_id NUMBER
            ,p_payroll_id pay_action_information.action_information1%type
	    ,p_employement_type pay_action_information.action_information1%type
	    ,p_period_id pay_action_information.action_information1%type
	    ,p_assignment_id pay_action_information.action_information1%type
	    ,p_green_land_code pay_action_information.action_information1%type /* 8847591 */
            )
            IS
                CURSOR csr_chk_6000  IS
	            SELECT  *
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_context_id = to_char(p_assignment_action_id)
	            AND pai.action_information3 IN ('6000')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information24 =p_period_id;
		    rec_csr_chk_6000 csr_chk_6000%ROWTYPE;

		CURSOR csr_chk_6000_emp  IS
	            SELECT  1
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_information2 = to_char(p_assignment_action_id)
	            AND pai.action_information3 IN ('6000R')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information26 =p_employement_type /* 8847591check */
		    AND pai.action_information24 =p_period_id
                    AND pai.action_information27 =p_green_land_code; /* 8847591 */

		 l_flag NUMBER:=0;
	         l_action_info_id NUMBER;
	         l_ovn NUMBER;
            BEGIN
		    hr_utility.set_location(' Entered Procedure rec_6000R',500);
		    hr_utility.set_location('rec_6000R:p_assignment_action_id'|| p_assignment_action_id ,501);
		    hr_utility.set_location('rec_6000R:p_payroll_id'|| p_payroll_id ,501);
		    hr_utility.set_location('rec_6000R:p_employement_type'|| p_employement_type ,501);
    		    hr_utility.set_location('rec_6000R:p_green_land_code'|| p_green_land_code ,501);
		    OPEN csr_chk_6000_emp;
		    FETCH csr_chk_6000_emp into l_flag;
		    CLOSE csr_chk_6000_emp;
    		    hr_utility.set_location('rec_6000R:After fetch l_flag'|| l_flag ,501);

		    IF   l_flag<>1 THEN
		    hr_utility.set_location('rec_6000:Entered  l_flag IF'|| l_flag ,501);
			       OPEN csr_chk_6000;
			       FETCH csr_chk_6000 INTO rec_csr_chk_6000;
			       CLOSE csr_chk_6000;
	                        pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_assignment_action_id
                                    ,p_action_context_type          => 'AAP'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => rec_csr_chk_6000.action_information2
                                    ,p_action_information3        => '6000R'
                                    ,p_action_information4        => rec_csr_chk_6000.action_information4 -- to_char(csr_rec.start_date,'yyyymmdd')
                                    ,p_action_information5          => rec_csr_chk_6000.action_information5 --to_char(csr_rec.end_date,'yyyymmdd')
                                    ,p_action_information6          => rec_csr_chk_6000.action_information6 --to_char(csr_rec.default_dd_date,'yyyymmdd')
                                    ,p_action_information7          => rec_csr_chk_6000.action_information7 --'B'
                                    ,p_action_information8          => rec_csr_chk_6000.action_information8 -- '000'  --Greenland code
                                    ,p_action_information9          => rec_csr_chk_6000.action_information9  -- employee code
                                    ,p_action_information10         => rec_csr_chk_6000.action_information10 -- should be reported in field 4 /* Bug fix 7579265 */
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => rec_csr_chk_6000.action_information24 /* 9489806 */
                                    ,p_action_information25         => rec_csr_chk_6000.action_information25  /* 9489806 */
                                    ,p_action_information26         => p_employement_type /* 8847591check */
                                    ,p_action_information27         => p_green_land_code /* 8847591 */
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
              hr_utility.set_location('rec_6000R:Last statement  l_flag IF'|| l_flag ,501);


		    END IF;
		    hr_utility.set_location(' Leaving Procedure rec_6000R',500);

	    END;
	PROCEDURE rec_8001R(
             p_assignment_action_id NUMBER
            ,p_payroll_id pay_action_information.action_information1%type
	    ,p_employement_type pay_action_information.action_information1%type
	    ,p_period_id pay_action_information.action_information1%type
	    ,p_person_id pay_action_information.action_information1%type
	    ,p_green_land_code pay_action_information.action_information1%type /* 8847591 */
            )
            IS
                CURSOR csr_chk_8001  IS
	            SELECT  *
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_context_id = to_char(p_assignment_action_id)
		    AND pai.action_information4=to_char(p_person_id)
	            AND pai.action_information3 IN ('8001')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information24 =p_period_id;
		    rec_csr_chk_8001 csr_chk_8001%ROWTYPE;

		CURSOR csr_chk_8001_emp  IS
	            SELECT  1
		    FROM pay_action_information pai
	            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
	            AND pai.action_information1 = 'PYDKEINA'
	            AND pai.action_information2 = to_char(p_assignment_action_id)
	            AND pai.action_information3 IN ('8001R')
		    AND pai.action_information25 =p_payroll_id
		    AND pai.action_information26 =p_employement_type /* 8847591check */
		    AND pai.action_information24 =p_period_id
                    AND pai.action_information27 =p_green_land_code; /* 8847591 */

		 l_flag NUMBER:=0;
	         l_action_info_id NUMBER;
	         l_ovn NUMBER;
            BEGIN
		    hr_utility.set_location(' Entered Procedure rec_8001R',500);
		    hr_utility.set_location('rec_8001R:p_assignment_action_id'|| p_assignment_action_id ,501);
		    hr_utility.set_location('rec_8001R:p_payroll_id'|| p_payroll_id ,501);
		    hr_utility.set_location('rec_8001R:p_employement_type'|| p_employement_type ,501);
    		    hr_utility.set_location('rec_8001R:p_green_land_code'|| p_green_land_code ,501);
		    OPEN csr_chk_8001_emp;
		    FETCH csr_chk_8001_emp into l_flag;
		    CLOSE csr_chk_8001_emp;
    		    hr_utility.set_location('rec_8001R:After fetch l_flag'|| l_flag ,501);

		    IF   l_flag<>1 THEN
		    hr_utility.set_location('rec_8001:Entered  l_flag IF'|| l_flag ,501);
			       OPEN csr_chk_8001;
			       FETCH csr_chk_8001 INTO rec_csr_chk_8001;
			       CLOSE csr_chk_8001;
	                        pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_assignment_action_id
                                    ,p_action_context_type          => 'AAP'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => rec_csr_chk_8001.action_information2
                                    ,p_action_information3        => '8001R'
                                    ,p_action_information4        => rec_csr_chk_8001.action_information4 -- to_char(csr_rec.start_date,'yyyymmdd')
                                    ,p_action_information5          => rec_csr_chk_8001.action_information5 --to_char(csr_rec.end_date,'yyyymmdd')
                                    ,p_action_information6          => rec_csr_chk_8001.action_information6 --to_char(csr_rec.default_dd_date,'yyyymmdd')
                                    ,p_action_information7          => rec_csr_chk_8001.action_information7 --'B'
                                    ,p_action_information8          => rec_csr_chk_8001.action_information8 -- '000'  --Greenland code
                                    ,p_action_information9          => rec_csr_chk_8001.action_information9  -- employee code
                                    ,p_action_information10         => rec_csr_chk_8001.action_information10 -- should be reported in field 4 /* Bug fix 7579265 */
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => rec_csr_chk_8001.action_information24 /* 9489806 */
                                    ,p_action_information25         => rec_csr_chk_8001.action_information25  /* 9489806 */
                                    ,p_action_information26         => p_employement_type /* 8847591check */
                                    ,p_action_information27         => p_green_land_code /* 8847591 */
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
              hr_utility.set_location('rec_8001R:Last statement  l_flag IF'|| l_flag ,501);


		    END IF;
		    hr_utility.set_location(' Leaving Procedure rec_8001R',500);

	    END;






      BEGIN
--          fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 1');
            /*Initializing all balance variables*/
            l_sp_bonus        :=0;
            l_free_phone            :=0;
	    l_multimedia := 0; -- bug# 9079593 fix
	    l_trivial_matter  :=0;  -- bug# 9169583 fix
            l_mileage         :=0;
      --    l_b_income        :=0;
            l_total_atp       :=0;
            l_employer_atp          :=0;
            l_board_lodge           :=0;
            l_car             :=0;
            l_car_adj       := 0;
            l_amb_pay_adj := 0;
            l_emp_atp_adj := 0;
            l_sp_bonus_adj := 0;
            l_free_phone_adj := 0;
	    l_multimedia_adj := 0; -- bug# 9079593 fix
    	    l_trivial_matter_adj := 0;  -- bug# 9169583 fix
            l_mileage_adj      := 0;
            l_empr_atp_adj := 0;
            l_board_lodge_adj := 0;
            l_a_income_adj := 0;
      --    l_b_income_adj := 0;
            l_hourly_holiday_pay_adj := 0;
            l_monthly_holiday_pay_adj      := 0;
            l_total_amb       :=0;
            l_hol_amb         :=0;
            l_emp_amb         :=0;
            l_tax             :=0;
            l_emp_tax         :=0;
            l_holiday_tax           :=0;
            l_a_income        :=0;
            l_monthly_holiday_pay   :=0;
            l_hourly_holiday_pay    :=0;
            l_gross_income          :=0;
            l_emp_atp         :=0;
            l_amb_pay         :=0;
            l_amb             :=0;
            l_bg_id                 :=0;
            l_org_id          :=0;
            l_pension      := 0;

            BEGIN

                  SELECT payroll_action_id, assignment_id
                  INTO l_payroll_action_id,l_ass_id /* 9489806 */
                  FROM pay_assignment_actions
                  WHERE assignment_action_id=p_assignment_action_id;
            END;

            IF g_debug THEN
                  hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
            END IF;

            /* Fetching report parameters */
                  PAY_DK_ARCHIVE_EIN.GET_ALL_PARAMETERS(
                   l_payroll_action_id
                  ,g_business_group_id
                  ,g_legal_employer_id
                  ,g_effective_date
                  ,g_payroll_id
                 -- ,g_payroll_period
		  ,g_payroll_type
		  ,g_start_date
		  ,g_end_date
                  ,g_test_submission
                  ,g_company_terminating
                  ,g_sender_id) ;
                  l_canonical_start_date := fnd_date.canonical_to_date(g_start_date);
                  l_canonical_end_date   := fnd_date.canonical_to_date(g_end_date);

            if(g_flag=0) then
                  if(g_company_terminating='N') then

                     fnd_file.put_line(fnd_file.log,'Fetched report parameters');

			hr_utility.set_location('ARCHIVE_CODE: l_assignment_id '|| l_ass_id,380);
		        hr_utility.set_location('ARCHIVE_CODE: Before For loop csr_asg_payroll ',380);

		       For csr_asg_payroll_rec IN csr_asg_payroll(l_canonical_start_date,l_canonical_end_date,l_ass_id)
		       LOOP
			--FETCH csr_asg_payroll INTO l_payroll_id,l_period_id;
		        --CLOSE csr_asg_payroll;
			 hr_utility.set_location('ARCHIVE_CODE: Payroll Name ' || csr_asg_payroll_rec.payroll_name,380);
		         hr_utility.set_location('ARCHIVE_CODE: l_payroll_id ' || csr_asg_payroll_rec.payroll_id,380);
			 hr_utility.set_location('ARCHIVE_CODE: Period Name  ' || csr_asg_payroll_rec.period_name,380);
		         hr_utility.set_location('ARCHIVE_CODE: time_period_id ' || csr_asg_payroll_rec.time_period_id,380);
			 l_employment_type :='00';
                         l_green_land_code :='000';
                        l_payroll_id:= csr_asg_payroll_rec.payroll_id;
			l_period_id:= csr_asg_payroll_rec.time_period_id;

                         hr_utility.set_location('ARCHIVE_CODE:After assign l_payroll_id ' || l_payroll_id,380);
			 hr_utility.set_location('ARCHIVE_CODE:After assign l_period_id ' || l_period_id,380);
			 hr_utility.set_location('ARCHIVE_CODE:p_effective_date ' || p_effective_date,380);

			OPEN csr_pay_periods(l_payroll_id,l_period_id);
                        FETCH csr_pay_periods into rg_csr_pay_periods;
                        l_bal_date:= rg_csr_pay_periods.end_date;
                        CLOSE csr_pay_periods;
			l_start_date:=rg_csr_pay_periods.start_date;
                        l_end_date:=rg_csr_pay_periods.end_date;

			hr_utility.set_location('ARCHIVE_CODE: l_bal_date ' || l_bal_date,380);
			hr_utility.set_location('ARCHIVE_CODE: l_start_date ' || l_start_date,380);
			hr_utility.set_location('ARCHIVE_CODE: l_end_date ' || l_end_date,380);


                        OPEN csr_get_person_details(p_assignment_action_id, l_end_date ); -- p_effective_date 9489806
                        FETCH csr_get_person_details into rg_csr_get_person_details;
                        CLOSE csr_get_person_details;
                        l_assignment_id:=rg_csr_get_person_details.assignment_id;
                        l_cpr_number:= rg_csr_get_person_details.cpr;
                        l_dob:=rg_csr_get_person_details.dob;
                        l_sex:=rg_csr_get_person_details.sex;
                        l_bg_id:=rg_csr_get_person_details.business_group_id;
                        l_org_id:=rg_csr_get_person_details.organization_id;
                        l_loc_id:=rg_csr_get_person_details.location_id;

                      fnd_file.put_line(fnd_file.log,'Fetched person details');






                        OPEN csr_get_extra_person_info(rg_csr_get_person_details.person_id);
                        FETCH csr_get_extra_person_info into rg_csr_get_extra_person_info;
                        IF(csr_get_extra_person_info%notfound) THEN
                              l_yes_no:='N';
                        ELSIF(csr_get_extra_person_info%found) THEN
                              l_yes_no:=rg_csr_get_extra_person_info.yes_no;
                        END IF;
                        CLOSE csr_get_extra_person_info;

                        IF(l_yes_no='Y') THEN /* This employee is a Foreigner */
                              --l_cpr_number:=NULL;
                              l_cpr_number:= '00000000000'; -- Bug 8552112
                        END IF;

                      fnd_file.put_line(fnd_file.log,'Fetched payroll period details');

                        OPEN csr_get_atp_table_value(l_assignment_id, l_start_date, l_end_date);
                        FETCH csr_get_atp_table_value into rg_csr_get_atp_table_value;
                        CLOSE csr_get_atp_table_value;

                      fnd_file.put_line(fnd_file.log,'Fetched atp table value');
                        IF l_loc_id IS NOT NULL THEN
                         OPEN csr_location_info (l_loc_id);
                         FETCH csr_location_info INTO rg_csr_location_info;
                         CLOSE csr_location_info;
                        END IF;
                      fnd_file.put_line(fnd_file.log,'bg id:'||l_bg_id);
                      fnd_file.put_line(fnd_file.log,'org id:'||l_org_id);
                        OPEN csr_get_hr_org_info(l_bg_id,l_org_id);
                        FETCH csr_get_hr_org_info into rg_csr_get_hr_org_info;
                        CLOSE csr_get_hr_org_info;


                      fnd_file.put_line(fnd_file.log,'Fetched hr org info');

                        OPEN  csr_Legal_Emp_Details(g_legal_employer_id);
                        FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
                        CLOSE csr_Legal_Emp_Details;

                      fnd_file.put_line(fnd_file.log,'Fetched legal emp details');

                        OPEN  csr_get_tax_card_details(l_assignment_id, l_start_date, l_end_date);
                        FETCH csr_get_tax_card_details INTO rg_csr_get_tax_card_details;
                        CLOSE csr_get_tax_card_details;

                        if(rg_csr_get_tax_card_details.screen_entry_value='H') then
                              l_tax_card_type:='1';
                        else
                              l_tax_card_type:='2';
                        end if;
			l_present_flag:=0;
                        hr_utility.set_location('ARCHIVE_CODE:Before fetch l_present_flag: ' || l_present_flag,380);
                        OPEN csr_prepaid_actions_present(l_payroll_action_id,
			                                 g_legal_employer_id,
							 l_payroll_id,
							 l_period_id,
							 l_start_date,
							 l_end_date,
							 l_ass_id);
                        FETCH csr_prepaid_actions_present INTO l_present_flag;
                        CLOSE csr_prepaid_actions_present;
			hr_utility.set_location('ARCHIVE_CODE:After fetch l_present_flag: ' || l_present_flag,380);
			IF (l_present_flag=1) THEN
                        -- Comment For Bug 9011035
                      /*  OPEN csr_latest_hire_date(rg_csr_get_person_details.person_id, l_end_date);
                        FETCH csr_latest_hire_date into rg_csr_latest_hire_date;
                        CLOSE csr_latest_hire_date; */


                        /* Code for getting the hire date from PER_PEOPLE_V*/
/*                      begin

                        select to_char(HIRE_DATE) into l_hd from PER_PEOPLE_V where NATIONAL_IDENTIFIER=rg_csr_get_person_details.cpr ;
                        fnd_file.put_line(fnd_file.log,'hire date from per_people_v : '||l_hd);

                        exception
                         when others then
                          null;
                        end; */

/*                      OPEN csr_latest_hire_date(rg_csr_get_person_details.person_id);
                        FETCH csr_latest_hire_date into rg_csr_latest_hire_date;
                        CLOSE csr_latest_hire_date;

                        l_cpr_number:= rg_csr_get_person_details.cpr;
                        if((rg_csr_latest_hire_date.lhd between l_start_date and l_end_date) and to_char(l_end_date,'mm')<'06' and to_char(l_end_date,'yyyy')<='2008') then
--                            fnd_file.put_line(fnd_file.log,'Inserting starters');
                              --Record - 2101
                              pay_action_information_api.create_action_information (
                               p_action_information_id        => l_action_info_id
                              ,p_action_context_id            => p_assignment_action_id
                              ,p_action_context_type          => 'AAP'
                              ,p_object_version_number        => l_ovn
                              ,p_effective_date               => g_effective_date
                              ,p_source_id                    => NULL
                              ,p_source_text                  => NULL
                              ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                              ,p_action_information1          => 'PYDKEINA'
                              ,p_action_information2          => l_payroll_action_id
                              ,p_action_information3        => '2101'
                              ,p_action_information4        => rg_csr_get_person_details.person_id
                              ,p_action_information5          => rg_csr_get_person_details.assignment_id
                              ,p_action_information6          => substr(l_cpr_number,1,6)||substr(l_cpr_number,8,4)
                              ,p_action_information7          => to_char(rg_csr_latest_hire_date.lhd,'yyyymmdd') --latest hire date
                              ,p_action_information8          => null -- no end date
                              ,p_action_information9          => l_tax_card_type -- tax card type
                              ,p_action_information10         => to_char(rg_csr_get_tax_card_details.effective_start_date,'yyyymmdd') -- effective start date
                              ,p_action_information11         => null
                              ,p_action_information12         => null
                              ,p_action_information13         => null
                              ,p_action_information14         => null
                              ,p_action_information15         => null
                              ,p_action_information16         => null
                              ,p_action_information17         => null
                              ,p_action_information18         => null
                              ,p_action_information19         => null
                              ,p_action_information20         => null
                              ,p_action_information21         => null
                              ,p_action_information22         => null
                              ,p_action_information23         => null
                              ,p_action_information24         => null
                              ,p_action_information25         => null
                              ,p_action_information26         => null
                              ,p_action_information27         => null
                              ,p_action_information28         => null
                              ,p_action_information29         => null
                              ,p_action_information30         => null);
                        end if; */

                        -- TERMINATOR RECORD
                        OPEN  csr_asg_terminator(p_assignment_action_id, l_start_date, l_end_date, g_business_group_id);
                        FETCH csr_asg_terminator INTO rg_csr_asg_terminator;
                        CLOSE csr_asg_terminator;   -- For bug 9011035

                        -- For Bug 9011035. fetch the hire date for the coresponding termination date
                        OPEN csr_latest_hire_date(rg_csr_get_person_details.person_id, rg_csr_asg_terminator.effective_end_date);
                        FETCH csr_latest_hire_date into rg_csr_latest_hire_date;
                        CLOSE csr_latest_hire_date;


                        if(rg_csr_asg_terminator.effective_end_date <= l_end_date) then
                            fnd_file.put_line(fnd_file.log,'Inserting terminators');
                              --Record - 2101
                              pay_action_information_api.create_action_information (
                               p_action_information_id        => l_action_info_id
                              ,p_action_context_id            => p_assignment_action_id
                              ,p_action_context_type          => 'AAP'
                              ,p_object_version_number        => l_ovn
                              ,p_effective_date               => g_effective_date
                              ,p_source_id                    => NULL
                              ,p_source_text                  => NULL
                              ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                              ,p_action_information1          => 'PYDKEINA'
                              ,p_action_information2          => l_payroll_action_id
                              ,p_action_information3        => '2101'
                              ,p_action_information4        => rg_csr_get_person_details.person_id
                              ,p_action_information5          => rg_csr_get_person_details.assignment_id
                              ,p_action_information6          => substr(l_cpr_number,1,6)||substr(l_cpr_number,8,4)
                              ,p_action_information7          => to_char(rg_csr_latest_hire_date.lhd,'yyyymmdd') --latest hire date
                              ,p_action_information8          => to_char(rg_csr_asg_terminator.EFFECTIVE_END_DATE,'yyyymmdd') -- end date
                              ,p_action_information9          => l_tax_card_type -- tax card type
                              ,p_action_information10         => to_char(l_start_date,'yyyymmdd') -- effective start date
                              ,p_action_information11         => null
                              ,p_action_information12         => null
                              ,p_action_information13         => null
                              ,p_action_information14         => null
                              ,p_action_information15         => null
                              ,p_action_information16         => null
                              ,p_action_information17         => null
                              ,p_action_information18         => null
                              ,p_action_information19         => null
                              ,p_action_information20         => null
                              ,p_action_information21         => null
                              ,p_action_information22         => null
                              ,p_action_information23         => null
                              ,p_action_information24         => l_period_id /* 9489806 */
                              ,p_action_information25         => null
                              ,p_action_information26         => null
                              ,p_action_information27         => null
                              ,p_action_information28         => null
                              ,p_action_information29         => null
                              ,p_action_information30         => null);
                        end if;


                      --  CLOSE csr_asg_terminator;

		      OPEN csr_asg_extra_info (l_assignment_id);
                      FETCH csr_asg_extra_info INTO rg_csr_asg_extra_info;
		      CLOSE csr_asg_extra_info;

--                      fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 2');
                        IF l_loc_id IS NOT NULL AND rg_csr_location_info.lei_information1 IS NOT NULL THEN
                          l_pu_code :=rg_csr_location_info.lei_information1; -- Location EIT Prod Unit Code
                        ELSE
                            l_pu_code :=rg_csr_get_hr_org_info.ORG_INFORMATION6; -- HR-ORG Production Unit Code
                            if(l_pu_code IS NULL) then
                                l_pu_code:=rg_Legal_Emp_Details.ORG_INFORMATION6;
                            end if;
                        END IF;



--                      fnd_file.put_line(fnd_file.log,'PU code:'||l_pu_code);



                              /* bug fix 7613211 */
                              -- Record - 8001


                           fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 4');

                              fnd_file.put_line(fnd_file.log,'p_assignment_action_id:'||p_assignment_action_id);
                              fnd_file.put_line(fnd_file.log,'l_bal_date:'||l_bal_date);

                                        -- Record 6001
                              l_amb_pay_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'AMBable Pay Adjustment','_ASG_PTD',l_bal_date);
                              l_amb_pay := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'AMBable Pay','_ASG_PTD',l_bal_date)
                                 - l_amb_pay_adj;

                                 /* 8861878 */
                              --
                                        l_b_income_amb_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total B Income Subject to AMB Adjustment','_ASG_PTD' ,l_bal_date);
                                  l_b_income_amb := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total B Income Subject to AMB','_ASG_PTD' ,l_bal_date)
                                                          - l_b_income_amb_adj;
                              /* 9289006 */
			      IF(l_b_income_amb_adj<>0 and l_amb_pay_adj<>0 ) THEN
                                        l_amb_pay_adj:= l_amb_pay_adj - l_b_income_amb_adj;
			      END IF;
			      IF(l_b_income_amb<>0 and l_amb_pay<>0) THEN
                              l_amb_pay    := l_amb_pay     - l_b_income_amb;
			      END IF;
                              --

                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 4.5');
                              l_emp_atp := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Employee ATP Deductions','_ASG_PTD' ,l_bal_date);
                              l_pension := nvl(GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Employee Pension Deductions','_ASG_PTD' ,l_bal_date),0)
                                           + nvl(GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Rate Pension Deduction','_ASG_PTD' ,l_bal_date),0);
			      /* 9136987 */
			      --
			      l_a_income_non_amb_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total A Income Not AMBable Adjustment','_ASG_PTD' ,l_bal_date);
                              l_a_non_amb_income := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total A Income Not AMBable','_ASG_PTD' ,l_bal_date)
                                                              - l_a_income_non_amb_adj;
                              --
                              l_gross_income := l_amb_pay + l_emp_atp + l_a_non_amb_income + l_pension; /* 9136987 */



                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 5');
                    l_hourly_holiday_pay_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Holiday Accrual Pay Adjustment','_ASG_PTD' ,l_bal_date);
                              l_hourly_holiday_pay := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Holiday Accrual Pay','_ASG_PTD' ,l_bal_date)
                                            - l_hourly_holiday_pay_adj;

                              l_monthly_holiday_pay := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Holiday Allowance Paid','_ASG_PTD' ,l_bal_date);

                              l_hourly_salaried :=rg_csr_get_person_details.HOURLY_SALARIED_CODE;
                              if(l_hourly_salaried IS null) then
                                    if (rg_csr_pay_periods.PAYROLL_PERIOD=1) then
                                          l_hourly_salaried:='S';
                                    else
                                          l_hourly_salaried := 'H';
                                    end if;
                              end if;



                    l_a_income_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'AMBable Pay Adjustment','_ASG_PTD' ,l_bal_date);
                              l_a_income := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'AMBable Pay','_ASG_PTD' ,l_bal_date)
                                  - l_a_income_adj;

                                /* 8861878 */
                              --
			      /* 9289006 */
			      IF(l_b_income_amb_adj<>0 and l_a_income_adj<>0 ) THEN
                                        l_a_income_adj := l_a_income_adj - l_b_income_amb_adj;
			      END IF;
                              IF(l_b_income_amb_adj<>0 and l_a_income<>0 ) THEN
                                        l_a_income     := l_a_income     - l_b_income_amb;
			      END IF;
                                        --

                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 6');
                                        /* 8861878 */
                              --
			      /* moved these balance fetches to top as these figures shoudl be included in gros income  9136987 */
			      /*
                              l_a_income_non_amb_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total A Income Not AMBable Adjustment','_ASG_PTD' ,l_bal_date);
                              l_a_non_amb_income := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total A Income Not AMBable','_ASG_PTD' ,l_bal_date)
                                                              - l_a_income_non_amb_adj; */


                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 6.5');
                                        --

                              OPEN csr_asg_action_id(rg_csr_get_person_details.assignment_id,l_payroll_id,l_period_id,g_legal_employer_id);
                              FETCH csr_asg_action_id into rg_csr_asg_action_id;
                              CLOSE csr_asg_action_id;

                              --OPEN  csr_Get_Defined_Balance_Id('HOURLY_HOLIDAY_TAX_PAYMENTS');  --9014232
					OPEN  csr_Get_Defined_Balance_Id('HOURLY_HOLIDAY_TAX_ASG_PTD');  --9014232
                              FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
                              CLOSE csr_Get_Defined_Balance_Id;

                              l_emp_tax := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Employee Tax','_ASG_PTD' ,l_bal_date);
--                            l_holiday_tax := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Holiday Tax','_ASG_PTD' ,l_bal_date);
                              l_holiday_tax_pay := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id, rg_csr_asg_action_id.id);
--                            fnd_file.put_line(fnd_file.log,'Hourly Holiday Tax_Payments : '||l_holiday_tax_pay);
                              l_tax := FLOOR(l_emp_tax)+FLOOR(l_holiday_tax_pay);



                              OPEN  csr_Get_Defined_Balance_Id('HOLIDAY_AMB_REPORTING_ASG_PTD');      --8858949
                              FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
                              CLOSE csr_Get_Defined_Balance_Id;

                              l_emp_amb := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Employee AMB Deduction','_ASG_PTD' ,l_bal_date);
--                            l_hol_amb := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Holiday AMB','_ASG_PTD' ,l_bal_date);
                              l_hol_amb_rep := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id, rg_csr_asg_action_id.id);
--                            fnd_file.put_line(fnd_file.log,'Holiday AMB Reporting (ASG RUN) : '||l_hol_amb_rep);
                              l_total_amb := FLOOR(l_emp_amb)+FLOOR(l_hol_amb_rep);



                    l_car_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Taxable Car Adjustment','_ASG_PTD' ,l_bal_date);
                              l_car := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Taxable Car Amount','_ASG_PTD' ,l_bal_date)
                             - l_car_adj;


--                            fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 8');
                    l_board_lodge_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Board and Lodge Adjustment','_ASG_PTD' ,l_bal_date);
                              l_board_lodge := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Board and Lodge Amount','_ASG_PTD' ,l_bal_date)
                                               - l_board_lodge_adj;


                              /* 8861878 */
                              --
                                     --   l_b_income_amb_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total B Income Subject to AMB Adjustment','_ASG_PTD' ,l_bal_date);
                               --   l_b_income_amb := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total B Income Subject to AMB','_ASG_PTD' ,l_bal_date)
                                     --                     - l_b_income_amb_adj;


                                        fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 8.2');
                              -- B-Income
                                  l_b_income_non_amb_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total B Income Not Subject to AMB Adjustment','_ASG_PTD' ,l_bal_date);
                                  l_b_income_non_amb := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total B Income Not Subject to AMB','_ASG_PTD' ,l_bal_date)
                                                              - l_b_income_non_amb_adj;

                                        --

                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 9');

                              l_employer_atp := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Employer ATP Deductions','_ASG_PTD' ,l_bal_date);
                              l_total_atp := l_emp_atp+l_employer_atp;


                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 10');
                                        /* 8861878 */
                              --
                              l_non_taxable_travel_adj:= GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Non Taxable Travel and Per Diem Adjustment','_ASG_PTD' ,l_bal_date);
                              l_non_taxable_travel:= GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Non Taxable Travel and Per Diem','_ASG_PTD' ,l_bal_date)
                                           - l_non_taxable_travel_adj;
                                        --
                    l_mileage_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Mileage Claimed Adjustment','_ASG_PTD' ,l_bal_date);
                              l_mileage := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Mileage Claimed Paid','_ASG_PTD' ,l_bal_date)
                                           - l_mileage_adj;
                                        /* 8861878 */
                              --
                                        l_mileage_adj := l_mileage_adj + l_non_taxable_travel_adj;
                                        l_mileage := l_mileage + l_non_taxable_travel;

                              --



                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 11');
                    l_free_phone_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Taxable Phone Adjustment','_ASG_PTD' ,l_bal_date);
                              l_free_phone := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Taxable Phone Amount','_ASG_PTD' ,l_bal_date)
                                              - l_free_phone_adj;


			      /* Bug# 9079593 fix starts */
                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 11.1 Multimedia');
                              l_multimedia_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Multimedia Tax Adjustment','_ASG_PTD' ,l_bal_date);
                              l_multimedia := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Multimedia Tax Amount','_ASG_PTD' ,l_bal_date)
                                              - l_multimedia_adj;

			     /* Bug# 9079593 fix ends */

			     /* Bug# 9169583 fix starts */
                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 11.2 BIK Trivial');
                              l_trivial_matter_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Trivial Matter BIK Adjustment','_ASG_PTD' ,l_bal_date);
                              l_trivial_matter := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total Trivial Matter BIK Amount','_ASG_PTD' ,l_bal_date)
                                              - l_trivial_matter_adj;

			     /* Bug# 9169583 fix ends */

                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 12');
                              l_sp_bonus_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Special Pay Adjustment','_ASG_PTD' ,l_bal_date);
                              l_sp_bonus := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Special Pay','_ASG_PTD' ,l_bal_date)
                                  - l_sp_bonus_adj;

                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 13');

                              /* 8861878 */
                              --
                              l_pension_sev_pay_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Pension Special Bonus Severance Pay Adjustment','_ASG_PTD' ,l_bal_date);
                              l_pension_sev_pay := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Pension Special Bonus Severance Pay','_ASG_PTD' ,l_bal_date)
                                                            - l_pension_sev_pay_adj;

                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 14');

                              l_physical_gift_sev_pay_adj := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Physical Gifts and Severance Pay Adjustment','_ASG_PTD' ,l_bal_date);
                              l_physical_gift_sev_pay := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Physical Gifts and Severance Pay','_ASG_PTD' ,l_bal_date)
                                                                  - l_physical_gift_sev_pay_adj;


			      /*
			         For Normal Employement
			           l_employment_type ='00'
			         For B Incoem Employee
                                   l_employment_type ='05'
			         For Foriegn Employees
			           l_employment_type ='09'
			      */
                             IF( l_b_income_amb<>0 OR l_b_income_amb_adj<>0 OR l_b_income_non_amb<>0 OR l_b_income_non_amb_adj<>0) THEN
                                 l_employment_type :='05';
			     END IF;

			      IF(l_yes_no='Y') THEN /* This employee is a Foreigner */
                                   l_employment_type :='09';
			     END IF;

			     IF( rg_csr_asg_extra_info.aei_information2 is not null ) THEN
			           l_employment_type :='03';
                                   l_green_land_code :=rg_csr_asg_extra_info.aei_information2;
		             END IF;

			     l_cvr_number:= rg_Legal_Emp_Details.ORG_INFORMATION1;

--                      fnd_file.put_line(fnd_file.log,'Person name : '||rg_csr_get_person_details.full_name);

                              --Record - 6000
                              pay_action_information_api.create_action_information (
                               p_action_information_id        => l_action_info_id
                              ,p_action_context_id            => p_assignment_action_id
                              ,p_action_context_type          => 'AAP'
                              ,p_object_version_number        => l_ovn
                              ,p_effective_date               => g_effective_date
                              ,p_source_id                    => NULL
                              ,p_source_text                  => NULL
                              ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                              ,p_action_information1          => 'PYDKEINA'
                              ,p_action_information2          => l_payroll_action_id
                              ,p_action_information3        => '6000'
                              ,p_action_information4        => rg_csr_get_person_details.person_id
                              ,p_action_information5          => rg_csr_get_person_details.assignment_id
                              ,p_action_information6          => l_cvr_number  --cvr number
                              ,p_action_information7          => substr(l_cpr_number,1,6)||substr(l_cpr_number,8,4)
                              ,p_action_information8          => rg_csr_get_person_details.assignment_number -- assignment number
                              ,p_action_information9          => '0000'
                              ,p_action_information10         => l_pu_code --DK production unit code
                              ,p_action_information11         => null
                              ,p_action_information12         => null
                              ,p_action_information13         => null
                              ,p_action_information14         => null
                              ,p_action_information15         => null
                              ,p_action_information16         => null
                              ,p_action_information17         => null
                              ,p_action_information18         => null
                              ,p_action_information19         => null
                              ,p_action_information20         => null
                              ,p_action_information21         => null
                              ,p_action_information22         => null
                              ,p_action_information23         => null
                              ,p_action_information24         => l_period_id /* 9489806 */
                              ,p_action_information25         => l_payroll_id  -- 9489806
                              ,p_action_information26         => l_employment_type
                              ,p_action_information27         => l_green_land_code /* 8847591 */
                              ,p_action_information28         => null
                              ,p_action_information29         => null
                              ,p_action_information30         => null);



			     IF(l_yes_no='Y') THEN /* This employee is a Foreigner */
                                    OPEN csr_get_territory(rg_csr_get_person_details.person_id);
                                    FETCH csr_get_territory INTO rg_csr_get_territory;
                                    CLOSE csr_get_territory;

                                    l_style:=rg_csr_get_territory.style;
                                    if(l_style = 'DK') then
                                          l_town_or_city := rg_csr_get_territory.postal_code;
                                    elsif(l_style = 'DK_GLB') then
                                          l_town_or_city := rg_csr_get_territory.town_or_city;
                                    end if;

                                    select DECODE(l_sex,'M','1','F','2','3') into l_sex from dual;

                                    pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_assignment_action_id
                                    ,p_action_context_type          => 'AAP'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => l_payroll_action_id
                                    ,p_action_information3        => '8001'
                                    ,p_action_information4        => rg_csr_get_person_details.person_id
                                    ,p_action_information5          => rg_csr_get_person_details.assignment_id
                                    ,p_action_information6          => NVL(l_dob,'00000000')  --date of birth
                                    ,p_action_information7          => l_sex -- gender
                                    ,p_action_information8          => rg_csr_get_territory.country    -- Territory code
                                    ,p_action_information9          => rg_csr_get_person_details.pname -- name
                                    ,p_action_information10         => rg_csr_get_territory.address_line1 --address
                                    ,p_action_information11         => rg_csr_get_territory.postal_code   -- postal code
                                    ,p_action_information12         => l_town_or_city    -- town or city
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => l_period_id /* 9489806 */
                                    ,p_action_information25         => l_payroll_id -- 9489806
                                    ,p_action_information26         => l_employment_type -- 9489806
                                    ,p_action_information27         => l_green_land_code /* 8847591 */
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
                              END IF;

			      rec_5000(l_payroll_action_id,l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
			      --
			      if(l_gross_income>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0200',abs(l_gross_income)*1000000,SIGN(l_gross_income),
				    'N',l_payroll_id,l_employment_type,l_period_id,l_green_land_code);  /* 8847591 */
                              elsif(l_gross_income<0 AND (l_gross_income+l_amb_pay_adj + l_a_income_non_amb_adj) <> 0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0200',abs(l_gross_income+l_amb_pay_adj + l_a_income_non_amb_adj)*1000000
				    ,SIGN(l_gross_income+l_amb_pay_adj + l_a_income_non_amb_adj), 'Y',l_payroll_id,l_employment_type,l_period_id,l_green_land_code);
                              end if;
                              --If gross income < 0 then we bring the -ve amount to the correction section. While doing this we also add any adjustment amounts to the same record
                              -- So gross income < 0 case already handles AMB adjustment. The following is for remaining cases only
                              IF (l_amb_pay_adj + l_a_income_non_amb_adj <> 0 AND l_gross_income>=0) THEN /* 9489806 */
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0200',abs(l_amb_pay_adj + l_a_income_non_amb_adj)*1000000,
				    SIGN(l_amb_pay_adj + l_a_income_non_amb_adj), 'Y',l_payroll_id,l_employment_type,l_period_id,l_green_land_code);
                              END IF;
			      --

			      --
			      if(l_hourly_salaried='S' and l_monthly_holiday_pay>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0201',abs(l_monthly_holiday_pay)*1000000,SIGN(l_monthly_holiday_pay), 'N'
				    ,l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              elsif(l_hourly_salaried='S' and l_monthly_holiday_pay<0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0201',abs(l_monthly_holiday_pay)*1000000,SIGN(l_monthly_holiday_pay), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              elsif(l_hourly_salaried='H' and l_hourly_holiday_pay<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0201',abs(l_hourly_holiday_pay)*1000000,SIGN(l_hourly_holiday_pay), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              IF (l_hourly_salaried='H' AND l_hourly_holiday_pay_adj<>0) THEN
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0201',abs(l_hourly_holiday_pay_adj)*1000000,SIGN(l_hourly_holiday_pay_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              END IF;
			      --

			      --
			      if(l_a_income<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0013',abs(l_a_income)*1000000,SIGN(l_a_income), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_a_income_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0013',abs(l_a_income_adj)*1000000,SIGN(l_a_income_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_a_non_amb_income<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0014',abs(l_a_non_amb_income)*1000000,SIGN(l_a_non_amb_income), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_a_income_non_amb_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0014',abs(l_a_income_non_amb_adj)*1000000,SIGN(l_a_income_non_amb_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_tax>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0015',abs(l_tax)*1000000,SIGN(l_tax), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              elsif(l_tax<0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0015',abs(l_tax)*1000000,SIGN(l_tax), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_total_amb>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0016',abs(l_total_amb)*1000000,SIGN(l_total_amb), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              elsif(l_total_amb<0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID, '0016',abs(l_total_amb)*1000000,SIGN(l_total_amb), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_car<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0019',abs(l_car)*1000000,SIGN(l_car), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_car_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0019',abs(l_car_adj)*1000000,SIGN(l_car_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_board_lodge<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0021',abs(l_board_lodge)*1000000,SIGN(l_board_lodge), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_board_lodge_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0021',abs(l_board_lodge_adj)*1000000,SIGN(l_board_lodge_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_b_income_amb<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0036',abs(l_b_income_amb)*1000000,SIGN(l_b_income_amb), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                               if(l_b_income_amb_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0036',abs(l_b_income_amb_adj)*1000000,SIGN(l_b_income_amb_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_b_income_non_amb<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0038',abs(l_b_income_non_amb)*1000000,SIGN(l_b_income_non_amb), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_b_income_non_amb_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0038',abs(l_b_income_non_amb_adj)*1000000,SIGN(l_b_income_non_amb_adj), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_total_atp>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0046',abs(l_total_atp)*1000000,SIGN(l_total_atp), 'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              elsif(l_total_atp<0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0046',abs(l_total_atp)*1000000,SIGN(l_total_atp), 'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_mileage<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0048',abs(l_mileage)*1000000,SIGN(l_mileage),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_mileage_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0048',abs(l_mileage_adj)*1000000,SIGN(l_mileage_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_free_phone<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0054',abs(l_free_phone)*1000000,SIGN(l_free_phone),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_free_phone_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0054',abs(l_free_phone_adj)*1000000,SIGN(l_free_phone_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_multimedia<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0020',abs(l_multimedia)*1000000,SIGN(l_multimedia),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_multimedia_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0020',abs(l_multimedia_adj)*1000000,SIGN(l_multimedia_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_trivial_matter<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0055',abs(l_trivial_matter)*1000000,SIGN(l_trivial_matter),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_trivial_matter_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0055',abs(l_trivial_matter_adj)*1000000,SIGN(l_trivial_matter_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

			      --
			      if(l_sp_bonus<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0069',abs(l_sp_bonus)*1000000,SIGN(l_sp_bonus),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_sp_bonus_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0069',abs(l_sp_bonus_adj)*1000000,SIGN(l_sp_bonus_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --

                              --
			      if(l_pension_sev_pay<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0070',abs(l_pension_sev_pay)*1000000,SIGN(l_pension_sev_pay),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_pension_sev_pay_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0070',abs(l_pension_sev_pay_adj)*1000000,SIGN(l_pension_sev_pay_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              --
			      --
			      if(l_physical_gift_sev_pay<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0071',abs(l_physical_gift_sev_pay)*1000000,SIGN(l_physical_gift_sev_pay),'N',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
                              if(l_physical_gift_sev_pay_adj<>0) then
                                    REC_6001(rg_csr_get_person_details.PERSON_ID, rg_csr_get_person_details.assignment_ID,'0071',abs(l_physical_gift_sev_pay_adj)*1000000,SIGN(l_physical_gift_sev_pay_adj),'Y',
				    l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
                              end if;
			      --
			      /* if any of the adjustment balances are not null go create a 6000 record for this employee */
			      IF ((l_physical_gift_sev_pay_adj<>0) OR
			           (l_pension_sev_pay_adj<>0) OR
				   (l_sp_bonus_adj<>0) OR
				   (l_trivial_matter_adj<>0) OR
				   (l_multimedia_adj<>0) OR
				   (l_free_phone_adj<>0) OR
				   (l_mileage_adj<>0)  OR
				   (l_total_atp<0) OR
				   (l_b_income_non_amb_adj<>0) OR
				   (l_b_income_amb_adj<>0) OR
				   (l_board_lodge_adj<>0) OR
				   (l_car_adj<>0) OR
				   (l_total_amb<0) OR
				   (l_tax<0) OR
				   (l_a_income_non_amb_adj<>0)  OR
				   (l_a_income_adj<>0) OR
				   ( (l_hourly_salaried='H' AND l_hourly_holiday_pay_adj<>0) ) OR
				   ((l_hourly_salaried='S' and l_monthly_holiday_pay<0) ) OR
				   ( (l_gross_income<0 AND (l_gross_income+l_amb_pay_adj + l_a_income_non_amb_adj) <> 0))
				   ) THEN

				   rec_5000R(l_payroll_action_id,l_payroll_id,l_employment_type,l_period_id,l_green_land_code); /* 8847591 */
				   rec_6000R(p_assignment_action_id,l_payroll_id,l_employment_type,l_period_id,l_ass_id,l_green_land_code); /* 8847591 */
                                   rec_8001R(p_assignment_action_id,l_payroll_id,l_employment_type,l_period_id,rg_csr_get_person_details.PERSON_ID,l_green_land_code);

				   END IF;





                              fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 15');
                                        --


                                  IF (l_yes_no='N') THEN /* Employee is not a foreigner */
                                    --Record - 6002
                                    pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_assignment_action_id
                                    ,p_action_context_type          => 'AAP'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => l_payroll_action_id
                                    ,p_action_information3        => '6002'
                                    ,p_action_information4        => rg_csr_get_person_details.PERSON_ID
                                    ,p_action_information5          => rg_csr_get_person_details.assignment_ID
                                    ,p_action_information6          => '0500'
                                    ,p_action_information7          => '6750000005'
                                    ,p_action_information8          => null
                                    ,p_action_information9          => null
                                    ,p_action_information10         => null
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => l_period_id /* 9489806 */
                                    ,p_action_information25         => l_payroll_id  -- 9489806
                                    ,p_action_information26         => l_employment_type  -- 9489806
                                    ,p_action_information27         => l_green_land_code /* 8847591 */
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
				    fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 16: Inserted 6002');


                              IF rg_csr_asg_extra_info.aei_information1='Y' THEN
                                 pay_action_information_api.create_action_information (
                                        p_action_information_id        => l_action_info_id
                                       ,p_action_context_id            => p_assignment_action_id
                                       ,p_action_context_type          => 'AAP'
                                       ,p_object_version_number        => l_ovn
                                       ,p_effective_date               => g_effective_date
                                       ,p_source_id                    => NULL
                                       ,p_source_text                  => NULL
                                       ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                       ,p_action_information1          => 'PYDKEINA'
                                       ,p_action_information2          => l_payroll_action_id
                                       ,p_action_information3           => '6003'
                                       ,p_action_information4           => rg_csr_get_person_details.PERSON_ID
                                       ,p_action_information5          => rg_csr_get_person_details.assignment_ID
                                       ,p_action_information6          => '0011'
                                       ,p_action_information7          => 'X'
                                       ,p_action_information8          => null
                                       ,p_action_information9          => null
                                       ,p_action_information10         => null
                                       ,p_action_information11         => null
                                       ,p_action_information12         => null
                                       ,p_action_information13         => null
                                       ,p_action_information14         => null
                                       ,p_action_information15         => null
                                       ,p_action_information16         => null
                                       ,p_action_information17         => null
                                       ,p_action_information18         => null
                                       ,p_action_information19         => null
                                       ,p_action_information20         => null
                                       ,p_action_information21         => null
                                       ,p_action_information22         => null
                                       ,p_action_information23         => null
                                       ,p_action_information24         => l_period_id  /* 9489806 */
                                       ,p_action_information25         => l_payroll_id -- 9489806
                                       ,p_action_information26         => l_employment_type  -- 9489806
                                       ,p_action_information27         => l_green_land_code /* 8847591 */
                                       ,p_action_information28         => null
                                       ,p_action_information29         => null
                                       ,p_action_information30         => null);
				       fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 17: Inserted 6003');
                              END IF;


      --                      fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 14');
                                    --Record - 6004
                              IF (l_total_atp <> 0) THEN
                                    pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_assignment_action_id
                                    ,p_action_context_type          => 'AAP'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => l_payroll_action_id
                                    ,p_action_information3        => '6004'
                                    ,p_action_information4        => rg_csr_get_person_details.PERSON_ID
                                    ,p_action_information5          => rg_csr_get_person_details.assignment_ID
                                    ,p_action_information6          => '0045'
                                    ,p_action_information7          => rg_csr_get_atp_table_value.screen_entry_value -- Input Value(atp table) of Employee ATP
                                    ,p_action_information8          => null
                                    ,p_action_information9          => null
                                    ,p_action_information10         => null
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => l_period_id /* 9489806 */
                                    ,p_action_information25         => l_payroll_id -- 9489806
                                    ,p_action_information26         => l_employment_type  -- 9489806
                                    ,p_action_information27         => l_green_land_code /* 8847591 */
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
				    fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 18: Inserted 6004');

                                    l_total_atp_hours := GET_DEFINED_BALANCE_VALUE(l_assignment_id, 'Total ATP Hours','_ASG_PTD' ,l_bal_date);
                                    l_total_atp_hours := ROUND(l_total_atp_hours,2);  -- rounding to 2 decimals

      --                      fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 15');
                                    --Record - 6005
                                    pay_action_information_api.create_action_information (
                                     p_action_information_id        => l_action_info_id
                                    ,p_action_context_id            => p_assignment_action_id
                                    ,p_action_context_type          => 'AAP'
                                    ,p_object_version_number        => l_ovn
                                    ,p_effective_date               => g_effective_date
                                    ,p_source_id                    => NULL
                                    ,p_source_text                  => NULL
                                    ,p_action_information_category  => 'EMEA REPORT INFORMATION'
                                    ,p_action_information1          => 'PYDKEINA'
                                    ,p_action_information2          => l_payroll_action_id
                                    ,p_action_information3        => '6005'
                                    ,p_action_information4        => rg_csr_get_person_details.PERSON_ID
                                    ,p_action_information5          => rg_csr_get_person_details.assignment_ID
                                    ,p_action_information6          => '0200'
                                    ,p_action_information7          => lpad((l_total_atp_hours*100),8,0)
                                    ,p_action_information8          => '+'
                                    ,p_action_information9          => null
                                    ,p_action_information10         => null
                                    ,p_action_information11         => null
                                    ,p_action_information12         => null
                                    ,p_action_information13         => null
                                    ,p_action_information14         => null
                                    ,p_action_information15         => null
                                    ,p_action_information16         => null
                                    ,p_action_information17         => null
                                    ,p_action_information18         => null
                                    ,p_action_information19         => null
                                    ,p_action_information20         => null
                                    ,p_action_information21         => null
                                    ,p_action_information22         => null
                                    ,p_action_information23         => null
                                    ,p_action_information24         => l_period_id /* 9489806 */
                                    ,p_action_information25         => l_payroll_id -- 9489806
                                    ,p_action_information26         => l_employment_type  -- 9489806
                                    ,p_action_information27         => l_green_land_code /* 8847591 */
                                    ,p_action_information28         => null
                                    ,p_action_information29         => null
                                    ,p_action_information30         => null);
				    fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 19: Inserted 6005');
                              END IF;
                        END IF; -- end l_yes_no is 'Y'
		       END IF; --l_present_flag
		    END LOOP;
                  end if; -- end company terminating check condition.
            end if; -- g_flag

--          fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 16');
                  IF g_debug THEN
                  hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
                  END IF;

--          fnd_file.put_line(fnd_file.log,'ARCHIVE CODE END');

      EXCEPTION
        WHEN others THEN
            IF g_debug THEN
                hr_utility.set_location('error raised in archive code ',5);
            END if;
          RAISE;
      END ARCHIVE_CODE;

      PROCEDURE DEINITIALIZATION_CODE
      (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type) is

      /* Cursors to fetch data for record numbering*/

            CURSOR csr_all_rec ( p_payroll_action_id NUMBER) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
          --  AND pai.action_information3 IN ('1000','2001','2101','5000','6000')
	    AND pai.action_information3 IN ('1000','2001','2101','5000') -- 9489806
            ORDER BY pai.action_information3,action_context_id DESC
            FOR UPDATE;

            /* 9489806 */
            CURSOR csr_all_rec_6000 ( p_payroll_action_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER ) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
	    AND pai.action_information3 IN ('6000')
	    AND pai.action_information25=to_char(p_payroll_id)
	    AND pai.action_information26=p_employement_type
	    AND pai.action_information24=p_time_period_id
	    AND pai.action_information27=p_green_land_code /* 8847591 */
            ORDER BY pai.action_information3,action_context_id DESC
            FOR UPDATE;

	    /* 9587046 */
	    CURSOR csr_all_rec_6000R ( p_payroll_action_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER ) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
	    AND pai.action_information3 IN ('6000R')
	    AND pai.action_information25=to_char(p_payroll_id)
	    AND pai.action_information26=p_employement_type
	    AND pai.action_information24=p_time_period_id
	    AND pai.action_information27=p_green_land_code /* 8847591 */
            ORDER BY pai.action_information3,action_context_id DESC
            FOR UPDATE;

            CURSOR csr_asg_all_rec ( p_payroll_action_id NUMBER,p_person_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
            AND pai.action_information4 = to_char(p_person_id)
            AND pai.action_information3 IN ('6001','6002','6003','6004','6005')
            AND nvl(pai.action_information29, 'N') <> 'Y'
            AND pai.action_information25=to_char(p_payroll_id)
	    AND pai.action_information26=p_employement_type
	    AND pai.action_information24=p_time_period_id
	    AND pai.action_information27=p_green_land_code /* 8847591 */
            ORDER BY pai.action_information3,action_context_id,pai.action_information6 DESC
            FOR UPDATE;

            /* 8616718 */

            CURSOR csr_asg_all_rec_corr ( p_payroll_action_id NUMBER,p_person_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
            AND pai.action_information4 = to_char(p_person_id)
            AND pai.action_information3 IN ('6001')
            AND nvl(pai.action_information29, 'N') = 'Y'
	    AND pai.action_information25=to_char(p_payroll_id)
	    AND pai.action_information26=p_employement_type
	    AND pai.action_information24=p_time_period_id
	    AND pai.action_information27=p_green_land_code /* 8847591 */
            ORDER BY pai.action_information3,action_context_id,pai.action_information6 DESC
            FOR UPDATE;

            /* bug 7613211*/
            CURSOR csr_asg_8001 (p_payroll_action_id NUMBER,p_person_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
            AND pai.action_information4 = to_char(p_person_id)
            AND pai.action_information3 = '8001'
	    AND pai.action_information25=to_char(p_payroll_id)
	    AND pai.action_information26=p_employement_type
            AND pai.action_information24=p_time_period_id
	    AND pai.action_information27=p_green_land_code /* 8847591 */
            FOR UPDATE;

	    /* 9587046R */
	    CURSOR csr_asg_8001R (p_payroll_action_id NUMBER,p_person_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS
            SELECT  *
            FROM pay_action_information pai
            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
            AND pai.action_information1 = 'PYDKEINA'
            AND pai.action_information2 = to_char(p_payroll_action_id)
            AND pai.action_information4 = to_char(p_person_id)
            AND pai.action_information3 = '8001R'
	    AND pai.action_information25=to_char(p_payroll_id)
	    AND pai.action_information26=p_employement_type
            AND pai.action_information24=p_time_period_id
	    AND pai.action_information27=p_green_land_code /* 8847591 */
            FOR UPDATE;


            l_action_info_id NUMBER;
            l_ovn             NUMBER;
            l_end_code        NUMBER;
            /* 8616718 */
                l_bincome_flag          varchar2(1):='N';
            l_other_flag            varchar2(1):='N';

	   /* 9001660 */
	   l_foreign_flag          varchar2(1):='N';
	   l_foreign_count  NUMBER:=0;
	   l_6000_count  NUMBER:=0;
	   l_5000_updated   VARCHAR2(1):='N';
	   l_5000R_updated  VARCHAR2(1):='N';
	   l_6000R_updated   VARCHAR2(1):='N';   /* 9587046R */

      BEGIN
            l_end_code:=0 ;
            if(g_flag=0) then
                fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 1');

                  FOR rg_csr_all_rec IN csr_all_rec( p_payroll_action_id)
                  LOOP
                        IF rg_csr_all_rec.action_information3 in ('1000','2001','2101') THEN
			l_end_code:=l_end_code + 1  ;
                      fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 2');

                        UPDATE pay_action_information pai
                        SET pai.action_information30 =LPAD(l_end_code,7,'0')
                        WHERE CURRENT OF csr_all_rec;

			END IF;

                      fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 3');
                        fnd_file.put_line(fnd_file.log,'payroll action id:'||p_payroll_action_id);
                        fnd_file.put_line(fnd_file.log,'action info 4:'||rg_csr_all_rec.action_information4);
                        hr_utility.set_location('DEINIT:rg_csr_all_rec.action_information3: ' || rg_csr_all_rec.action_information3,390);
                        hr_utility.set_location('DEINIT:rg_csr_all_rec.action_information25: ' || rg_csr_all_rec.action_information25,390);

			IF rg_csr_all_rec.action_information3='5000' THEN
                        l_5000_updated:='N';
			FOR rg_csr_all_rec_6000 IN csr_all_rec_6000(p_payroll_action_id,rg_csr_all_rec.action_information25,rg_csr_all_rec.action_information9,rg_csr_all_rec.action_information24,rg_csr_all_rec.action_information8)
			LOOP
			       IF l_5000_updated='N' THEN
			       l_end_code:=l_end_code + 1  ;
                               UPDATE pay_action_information pai
                               SET pai.action_information30 =LPAD(l_end_code,7,'0')
                               WHERE CURRENT OF csr_all_rec;
                               l_5000_updated:='Y';
			       END IF;

			       l_end_code:=l_end_code + 1  ;
			       UPDATE pay_action_information pai
                               SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                WHERE CURRENT OF csr_all_rec_6000;
			       hr_utility.set_location('DEINIT:entered csr_all_rec_6000: ' || rg_csr_all_rec_6000.action_information4,390);
                              /* bug 7613211 start*/
			      /* 9001660 */
			      l_6000_count:=l_6000_count+1;
			      fnd_file.put_line(fnd_file.log,'l_foreign_flag :'|| l_foreign_flag);
                              FOR rg_csr_asg_8001 IN csr_asg_8001( p_payroll_action_id,to_number(rg_csr_all_rec_6000.action_information4),rg_csr_all_rec.action_information25
			                              ,rg_csr_all_rec.action_information9,rg_csr_all_rec.action_information24,rg_csr_all_rec.action_information8)
                              LOOP
			            l_end_code:=l_end_code + 1  ;
                                    UPDATE pay_action_information pai
                                    SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                    WHERE CURRENT OF csr_asg_8001;
                                     fnd_file.put_line(fnd_file.log,'rg_csr_all_rec_6000.action_information7:'|| rg_csr_all_rec_6000.action_information7);

				    /* 9001660 */
				    l_foreign_count:=l_foreign_count+1;
                                    IF rg_csr_all_rec_6000.action_information7='0000000000' THEN
                                       l_foreign_flag:='Y';
				    END IF;
				     fnd_file.put_line(fnd_file.log,'l_foreign_flag :'|| l_foreign_flag);
--                                  fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 4');
                              END LOOP;
                              /* bug 7613211 end*/

                              FOR rg_csr_asg_all_rec IN csr_asg_all_rec( p_payroll_action_id,to_number(rg_csr_all_rec_6000.action_information4),rg_csr_all_rec.action_information25
			                                                 ,rg_csr_all_rec.action_information9,rg_csr_all_rec.action_information24,rg_csr_all_rec.action_information8) /* 8847591 */
                              LOOP
                                    l_end_code:=l_end_code + 1  ;
                                    UPDATE pay_action_information pai
                                    SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                    WHERE CURRENT OF csr_asg_all_rec;
--                                  fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 4');

                                     IF (rg_csr_asg_all_rec.action_information6='0038' or rg_csr_asg_all_rec.action_information6='0036') and rg_csr_asg_all_rec.action_information3='6001' THEN /* 8616718 */
                                                 l_bincome_flag:='Y';
                                     ELSIF rg_csr_asg_all_rec.action_information3='6001' and rg_csr_asg_all_rec.action_information6 <> '0016' THEN /* 8861878 */
                                     l_other_flag:='Y';
                                     END IF;
                                     fnd_file.put_line(fnd_file.log,'Pay Type code :'|| rg_csr_asg_all_rec.action_information6);
                                     fnd_file.put_line(fnd_file.log,'l_bincome_flag'|| l_bincome_flag);
                                     fnd_file.put_line(fnd_file.log,'l_other_flag'|| l_other_flag);


                              END LOOP;
			END LOOP; -- record 6000 loop
                              /* 8616718 */
                                        fnd_file.put_line(fnd_file.log,'before correctl_bincome_flag'|| l_bincome_flag);
                                  fnd_file.put_line(fnd_file.log,'before correct l_other_flag'|| l_other_flag);
				  l_5000R_updated:='N';
FOR rg_csr_all_rec_6000 IN csr_all_rec_6000R(p_payroll_action_id,rg_csr_all_rec.action_information25,rg_csr_all_rec.action_information9,rg_csr_all_rec.action_information24,rg_csr_all_rec.action_information8)
			LOOP
			l_6000R_updated:='N';  /* 9587046R */
FOR rg_csr_asg_all_rec IN csr_asg_all_rec_corr( p_payroll_action_id,to_number(rg_csr_all_rec_6000.action_information4),rg_csr_all_rec.action_information25
                                                ,rg_csr_all_rec.action_information9,rg_csr_all_rec.action_information24,rg_csr_all_rec.action_information8) /* 8847591 */
                              LOOP
			             fnd_file.put_line(fnd_file.log,'before payroll_id'|| rg_csr_all_rec.action_information25);
				     fnd_file.put_line(fnd_file.log,'before time period id '|| rg_csr_all_rec.action_information24);
			             IF l_5000R_updated='N' THEN
				     			             fnd_file.put_line(fnd_file.log,'entered iff l_5000R_updated');
				          l_end_code:=l_end_code + 1  ;
                                          UPDATE pay_action_information pai
                                          SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                          WHERE pai.action_information3 = '5000R'
					     AND pai.action_information2= to_char(p_payroll_action_id)
					     AND pai.action_information9=rg_csr_all_rec.action_information9
					     AND pai.action_information8=rg_csr_all_rec.action_information8 /* 9587046 */
                                             AND  pai.action_information25=rg_csr_all_rec.action_information25
					     AND pai.action_information24=rg_csr_all_rec.action_information24;

					     l_5000R_updated:='Y';
				      END IF; /* 9587046R */
                                      IF l_6000R_updated='N' THEN
			                  l_end_code:=l_end_code + 1  ;
                                          UPDATE pay_action_information pai
                                          SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                          WHERE pai.action_information3 = '6000R'
					     AND pai.action_information2 = to_char(p_payroll_action_id)
                                             AND pai.action_information4 = to_char(rg_csr_all_rec_6000.action_information4)
					     AND pai.action_information25=rg_csr_all_rec_6000.action_information25
					     AND pai.action_information27=rg_csr_all_rec_6000.action_information27  /* 9587046 */
                                             AND  pai.action_information26=rg_csr_all_rec_6000.action_information26
					     AND pai.action_information24=rg_csr_all_rec_6000.action_information24;
					     l_6000R_updated:='Y';
					     /* 9587046R */
					     FOR rg_csr_asg_8001 IN csr_asg_8001R( p_payroll_action_id,to_number(rg_csr_all_rec_6000.action_information4),rg_csr_all_rec.action_information25
			                              ,rg_csr_all_rec.action_information9,rg_csr_all_rec.action_information24,rg_csr_all_rec.action_information8)
                                             LOOP
			                           l_end_code:=l_end_code + 1  ;
                                                   UPDATE pay_action_information pai
                                                   SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                                   WHERE CURRENT OF csr_asg_8001R;
                                             END LOOP;

			             END IF;
			             fnd_file.put_line(fnd_file.log,'l_5000R_updated'|| l_5000R_updated);
				     l_end_code:=l_end_code + 1  ;
                                    UPDATE pay_action_information pai
                                    SET pai.action_information30 =LPAD(l_end_code,7,'0')
                                    WHERE CURRENT OF csr_asg_all_rec_corr;

                                     IF (rg_csr_asg_all_rec.action_information6='0038' or rg_csr_asg_all_rec.action_information6='0036') and rg_csr_asg_all_rec.action_information3='6001' THEN /* 8616718 */
                                                 l_bincome_flag:='Y';
                                     ELSIF rg_csr_asg_all_rec.action_information3='6001' and rg_csr_asg_all_rec.action_information6 <> '0016'  THEN /* 8861878 */
                                     l_other_flag:='Y';
                                     END IF;
                                     fnd_file.put_line(fnd_file.log,'Pay Type code in corrected record :'|| rg_csr_asg_all_rec.action_information6);

                              END LOOP;
                        fnd_file.put_line(fnd_file.log,'after correctl_bincome_flag'|| l_bincome_flag);
                  fnd_file.put_line(fnd_file.log,'after correct l_other_flag'|| l_other_flag);
		         END LOOP; -- for 5000
                        END IF;
--                      fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 5');
                  END LOOP;
                  l_end_code:=l_end_code + 1  ;
                  fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 6');
		  /* 9001660 */
                   IF l_foreign_flag='Y' THEN
		   /*
                            UPDATE pay_action_information pai
                            SET pai.action_information9='09'
                            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
                              AND pai.action_information1 = 'PYDKEINA'
                              AND pai.action_information2 = to_char(p_payroll_action_id)
                              AND pai.action_information3 ='5000'; */

--
                  fnd_file.put_line(fnd_file.log,'l_foreign_count :'||l_foreign_count);
		  fnd_file.put_line(fnd_file.log,'l_6000_count :'|| l_6000_count);
		       IF l_foreign_count<>l_6000_count THEN
                        -- Raise l_bincome_exception;
			NULL;
                       END IF;
                  END IF;
                        /* 8616718 */
                  IF l_bincome_flag='Y' THEN
                          /*  UPDATE pay_action_information pai
                             SET pai.action_information9='05'
                            WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
                          AND pai.action_information1 = 'PYDKEINA'
                          AND pai.action_information2 = to_char(p_payroll_action_id)
                          AND pai.action_information3 ='5000'; */
			  NULL;
                        IF l_other_flag='Y' THEN
                          -- Raise l_bincome_exception;
			  NULL;
                        END IF;
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
                  p_action_information1=> 'PYDKEINA',
                  p_action_information2=>  p_payroll_action_id,
                  p_action_information3=> '9999',
                  p_action_information4=> l_end_code,
                  p_action_information5=> NULL,
                  p_action_information6=>  NULL,
                  p_action_information7=>  NULL,
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
                  p_action_information30=> LPAD(l_end_code,7,'0')
                  );

            end if; -- g_flag
--          fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 7');
            IF g_debug THEN
                  hr_utility.set_location(' Leaving Procedure DEINITIALIZATION_CODE',390);
            END IF;

--          fnd_file.put_line(fnd_file.log,'DE-INITIALIZATION CODE 8');
EXCEPTION
  WHEN l_bincome_exception THEN
  /* 9001660 */
 /* fnd_file.put_line(fnd_file.log,'Error raised in DEINITIALIZATION_CODE : The Payroll used for processing normal employees must not be used for processing employees with only B income.
Please process the employees with only B Income on a different Payroll.');
*/
fnd_file.put_line(fnd_file.log,'Error raised in DEINITIALIZATION_CODE :'|| fnd_message.get_string('PER','HR_377071_DK_FORIEGN_BINCOME'));
RAISE;
  WHEN others THEN
      IF g_debug THEN
          hr_utility.set_location('error raised in DEINITIALIZATION_CODE ',5);
      END if;
    RAISE;
 END;

BEGIN

      g_payroll_action_id           :=NULL;
      g_le_assignment_action_id     :=NULL;
      g_business_group_id           :=NULL;
      g_legal_employer_id           :=NULL;
      g_effective_date        :=NULL;
      g_payroll_id                  :=NULL;
      g_payroll_period        :=NULL;
      g_test_submission       :=NULL;
      g_company_terminating         :=NULL;
                          g_sender_id                                                        :=NULL;

END PAY_DK_ARCHIVE_EIN;

/
