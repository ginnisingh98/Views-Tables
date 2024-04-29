--------------------------------------------------------
--  DDL for Package Body PAY_CA_RL2_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_RL2_MAG" AS
 /* $Header: pycarl2mg.pkb 120.55.12010000.17 2010/02/03 10:34:12 sapalani ship $ */

   -- Name     : get_report_parameters

 -----------------------------------------------------------------------------
   --
   -- Purpose
   --   The procedure gets the 'parameter' for which the report is being
   --   run i.e., the period, state and business organization.
   --
   -- Arguments
   --	p_pactid		Payroll_action_id passed from pyugen process
   --   p_year_start		Start Date of the period for which the report
   --				has been requested
   --   p_year_end		End date of the period
   --   p_business_group_id	Business group for which the report is being run
   --   p_report_type		Type of report being run RL1
   --
   -- Notes
 ----------------------------------------------------------------------------


        PROCEDURE get_report_parameters
	(	p_pactid    		IN NUMBER,
		p_year_start		IN OUT NOCOPY	DATE,
		p_year_end		IN OUT NOCOPY	DATE,
		p_report_type		IN OUT NOCOPY	VARCHAR2,
		p_business_group_id	IN OUT NOCOPY	NUMBER,
                p_legislative_param     IN OUT NOCOPY   VARCHAR2
	) IS
	BEGIN
		--hr_utility.trace_on('Y','RL2MAG');
		hr_utility.set_location('pay_ca_rl2_mag.get_report_parameters', 10);

		SELECT  ppa.start_date,
			ppa.effective_date,
		  	ppa.business_group_id,
		  	ppa.report_type,
                        ppa.legislative_parameters
		  INTO  p_year_start,
	  		p_year_end,
			p_business_group_id,
			p_report_type,
                        p_legislative_param
		  FROM  pay_payroll_actions ppa
	 	 WHERE  payroll_action_id = p_pactid;

		hr_utility.set_location('pay_ca_rl2_mag.get_report_parameters', 20);

	END get_report_parameters;

---------------------------------------------------------------------------
  --Procedure Name : validate_transmitter_info
  --Purpose
  -- This procedure is used for checking if the correct transmitter
  -- record  details has been entered.If any of the following data
  -- Package Type,Source Of Rl2 Slip ,Transmitter Number,Transmitter Name
  -- is missing then the RL2 Electronic Interface is made to error out.
----------------------------------------------------------------------------

PROCEDURE validate_transmitter_info(p_payroll_action_id IN NUMBER,
                                    p_bg_id             IN NUMBER,
                                    p_effective_date    IN DATE) IS
BEGIN

DECLARE

  CURSOR cur_arch_pactid(p_transmitter_org_id NUMBER) IS
  SELECT
    ppa.payroll_action_id
  FROM
    pay_payroll_actions ppa
  WHERE
    ppa.business_group_id = p_bg_id AND
    ppa.report_type = 'RL2' AND
    ppa.report_qualifier = 'CAEOYRL2' AND
    ppa.report_category = 'ARCHIVE' AND
    ppa.effective_date = p_effective_date AND
    p_transmitter_org_id =
            pay_ca_rl2_mag.get_parameter('PRE_ORGANIZATION_ID',
                                         ppa.legislative_parameters);

  l_transmitter_number     VARCHAR2(30);
  l_transmitter_name       VARCHAR2(100);
  l_type_of_package        VARCHAR2(30);
  l_source_of_slips        VARCHAR2(30);
  dummy                    NUMBER;
  dummy1                   VARCHAR2(10);
  l_transmitter_org_id     NUMBER;
  l_arch_pactid            NUMBER;
  l_legislative_parameters pay_payroll_actions.legislative_parameters%TYPE;
  l_address_line1          per_addresses.address_line1%TYPE;

  CURSOR cur_ppa IS
  SELECT
    ppa.legislative_parameters
  FROM
    pay_payroll_actions ppa
  WHERE
    ppa.payroll_action_id = p_payroll_action_id;

BEGIN

  OPEN cur_ppa;
  FETCH cur_ppa
  INTO  l_legislative_parameters;
  CLOSE cur_ppa;

  l_transmitter_org_id := pay_ca_rl2_mag.get_parameter('TRANSMITTER_PRE',
                                               l_legislative_parameters);

  hr_utility.trace('l_transmitter_org_id = ' || to_char(l_transmitter_org_id));
  hr_utility.trace('p_bg_id = ' || to_char(p_bg_id));
  hr_utility.trace('p_payroll_action_id = ' || to_char(p_payroll_action_id));
  hr_utility.trace('p_effective_date = ' || to_char(p_effective_date));

  OPEN cur_arch_pactid(l_transmitter_org_id);
  FETCH cur_arch_pactid
  INTO  l_arch_pactid;
  CLOSE cur_arch_pactid;

  l_transmitter_number := pay_ca_rl2_mag.get_transmitter_item( p_bg_id,
                                                               l_arch_pactid,
                                                               'CAEOY_RL2_TRANSMITTER_NUMBER');
  l_transmitter_name   := pay_ca_rl2_mag.get_transmitter_item( p_bg_id,
                                                               l_arch_pactid,
                                                               'CAEOY_RL2_TRANSMITTER_NAME');
  BEGIN

    hr_utility.trace('l_transmitter_number = ' || l_transmitter_number);
    SELECT substr(l_transmitter_number,1,2)
    INTO dummy1
    FROM dual;

    IF (dummy1 <> 'NP' OR
       length(l_transmitter_number) <> 8) THEN
      RAISE INVALID_NUMBER;
    END IF;

    SELECT to_number(substr(l_transmitter_number,3,6))
    INTO dummy
    FROM dual;

  EXCEPTION
   WHEN INVALID_NUMBER THEN
     hr_utility.set_message(800,'PAY_CA_RL1_INVALID_TRANSMITTER');
     hr_utility.set_message_token('PRE_NAME',l_transmitter_name);
     pay_core_utils.push_message(800,'PAY_CA_RL1_INVALID_TRANSMITTER','P');
     pay_core_utils.push_token('PRE_NAME',l_transmitter_name);
     hr_utility.raise_error;
  END;

  l_type_of_package :=  pay_ca_rl2_mag.get_transmitter_item(p_bg_id,
                                                            l_arch_pactid,
                                                            'CAEOY_RL2_TRANSMITTER_PACKAGE_TYPE');

  hr_utility.trace('l_type_of_package = ' || l_type_of_package);

  IF l_type_of_package IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_TYPE_OF_PKG','P');
     hr_utility.raise_error;
  END IF;

  l_source_of_slips := pay_ca_rl2_mag.get_transmitter_item(p_bg_id,
                                                            l_arch_pactid,
                                                            'CAEOY_RL2_SOURCE_OF_SLIPS');
  hr_utility.trace('l_source_of_slips = ' || l_source_of_slips);

  IF l_source_of_slips IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_RLSLIP_SRC','P');
     hr_utility.raise_error;
  END IF;

  l_address_line1 := pay_ca_rl2_mag.get_transmitter_item(p_bg_id,
                                                            l_arch_pactid,
                                                            'CAEOY_RL2_TRANSMITTER_ADDRESS_LINE1');
  hr_utility.trace('l_address_line1 = ' || l_address_line1);

  IF l_address_line1 IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_TRNMTR_ADDR','P');
     hr_utility.raise_error;
  END IF;

END;

END validate_transmitter_info;


-----------------------------------------------------------------------------
  --Name
  --  range_cursor
  --Purpose
  --  This procedure defines a SQL statement
  --  to fetch all the people to be included in the report. This SQL statement
  --  is  used to define the 'chunks' for multi-threaded operation
  --Arguments
  --  p_pactid			payroll action id for the report
  --  p_sqlstr			the SQL statement to fetch the people
------------------------------------------------------------------------------
PROCEDURE range_cursor (
	p_pactid	IN	   NUMBER,
	p_sqlstr	OUT NOCOPY VARCHAR2
)
IS
	p_year_start			DATE;
	p_year_end			DATE;
	p_business_group_id		NUMBER;
	p_report_type			VARCHAR2(30);
        p_legislative_param             pay_payroll_actions.legislative_parameters%type;

BEGIN

	hr_utility.set_location( 'pay_ca_rl2_mag.range_cursor', 10);

	get_report_parameters(
		p_pactid,
		p_year_start,
		p_year_end,
		p_report_type,
		p_business_group_id,
                p_legislative_param
	);

	hr_utility.set_location( 'pay_ca_rl2_mag.range_cursor', 20);

	p_sqlstr := 'select /*+ leading(ppa_mag,ppa_arch,paa_arch)
                          index(emp.paa_arch,PAY_ASSIGNMENT_ACTIONS_PK)
                          use_hash(emp.ppa_arch,hoi,tran.ppa_arch)
                      */ distinct to_number(emp.person_id)
        from    pay_ca_eoy_rl2_employee_info_v emp,
    		pay_ca_eoy_rl2_trans_info_v tran,
    		pay_assignment_actions  paa_arch,
    		pay_payroll_actions     ppa_arch,
    		pay_payroll_actions     ppa_mag,
                hr_organization_information hoi
      	where  ppa_mag.payroll_action_id    = :payroll_action_id
      	and    ppa_arch.business_group_id+0 = ppa_mag.business_group_id
      	and    ppa_arch.effective_date     = ppa_mag.effective_date
      	and    ppa_arch.report_type        = ''RL2''
      	and    ppa_arch.payroll_action_id  = paa_arch.payroll_action_id
      	and    tran.reporting_year    = to_char(ppa_arch.effective_date,''YYYY'')
      	and    tran.business_group_id = ppa_arch.business_group_id
      	and    tran.reporting_year   = pay_ca_rl2_mag.get_parameter(''REPORTING_YEAR'',ppa_mag.legislative_parameters)
      	and    paa_arch.payroll_action_id  = tran.payroll_action_id
      	and    paa_arch.action_status = ''C''
      	and    paa_arch.assignment_action_id = emp.assignment_action_id
      	and    paa_arch.payroll_action_id    = emp.payroll_action_id
        and    emp.business_group_id         = ppa_arch.business_group_id
        and    decode(hoi.org_information3, ''Y'', hoi.organization_id, hoi.org_information20) =
               pycadar_pkg.get_parameter(''TRANSMITTER_PRE'', ppa_mag.legislative_parameters )
        and    hoi.org_information_context  =''Prov Reporting Est''
        and    to_char(hoi.organization_id) =
               pycadar_pkg.get_parameter(''PRE_ORGANIZATION_ID'',ppa_arch.legislative_parameters)
	order by to_number(emp.person_id)' ;

        hr_utility.set_location( 'pay_ca_rl2_mag.range_cursor',30);

END range_cursor;

  -------------------------------------------------------------------------------
  --Name
  --  create_assignment_act
  --Purpose
  --  Creates assignment actions for the payroll action associated with the
  --  report
  --Arguments
  --  p_pactid				payroll action for the report
  --  p_stperson			starting person id for the chunk
  --  p_endperson			last person id for the chunk
  --  p_chunk				size of the chunk
  --Note
  --  The procedure processes assignments in 'chunks' to facilitate
  --  multi-threaded operation. The chunk is defined by the size and the
  --  starting and ending person id. An interlock is also created against the
  --  pre-processor assignment action to prevent rolling back of the archiver.
  ------------------------------------------------------------------------------
PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson     IN NUMBER,
	p_chunk 	IN NUMBER )
IS
	-- Cursor to retrieve all the assignments for all GRE's
	-- archived in a reporting year

	CURSOR c_all_asg(p_leg_param  varchar2,
                         p_business_grpid number,
                         p_effective_dt  date) IS
    	SELECT 	paf.person_id,
      	   	paf.assignment_id,
      	   	paa_arch.tax_unit_id,
      	   	paf.effective_end_date,
      	   	paa_arch.assignment_action_id,
                ppa_arch.payroll_action_id
    	FROM  pay_payroll_actions ppa_arch,
	      pay_assignment_actions paa_arch,
	      per_all_assignments_f paf,
              hr_organization_information hoi
	WHERE ppa_arch.report_type = 'RL2'
	AND   ppa_arch.business_group_id+0 = p_business_grpid
	AND   ppa_arch.effective_date = p_effective_dt
	AND   paa_arch.payroll_action_id = ppa_arch.payroll_action_id
	AND   paa_arch.action_status = 'C'
	AND   paf.assignment_id = paa_arch.assignment_id
	AND   paf.person_id BETWEEN p_stperson AND p_endperson
	AND   paf.effective_start_date <= ppa_arch.effective_date
	AND   paf.effective_end_date >= ppa_arch.start_date
        AND   decode(hoi.org_information3, 'Y', hoi.organization_id, hoi.org_information20) =
              substr(p_leg_param, instr(p_leg_param,'TRANSMITTER_PRE=')+16)
        AND   hoi.org_information_context = 'Prov Reporting Est'
        AND   hoi.organization_id =
              substr(ppa_arch.legislative_parameters,
                     instr(ppa_arch.legislative_parameters,'PRE_ORGANIZATION_ID=')+20)
        AND   paf.effective_end_date = (SELECT max(paf1.effective_end_date)
                                        FROM per_all_assignments_f paf1
                                        WHERE paf1.assignment_id = paf.assignment_id
                                        AND   paf1.effective_start_date <= p_effective_dt);

	l_year_start DATE;
	l_year_end   DATE;
	l_effective_end_date	DATE;
	l_report_type		VARCHAR2(30);
	l_business_group_id	NUMBER;
	l_person_id		NUMBER;
	l_assignment_id		NUMBER;
	l_assignment_action_id	NUMBER;
	l_value		        NUMBER;
	l_tax_unit_id		NUMBER;
	lockingactid		NUMBER;
        /* Added by ssmukher */
        l_prev_payact           NUMBER;
        l_payroll_act           NUMBER;
        l_emplyer_name          VARCHAR2(240);
        l_quebec_no             VARCHAR2(20);
        l_file_no               VARCHAR2(10);
        l_return                NUMBER;
        l_addr_line             VARCHAR2(240);
        l_legislative_param     pay_payroll_actions.legislative_parameters%type;

BEGIN

   --     hr_utility.trace_on(NULL,'RL2MAG');
	-- Get the report parameters. These define the report being run.
        l_prev_payact := -1;
	hr_utility.set_location( 'pay_ca_rl2_mag.create_assignment_act',10);

	get_report_parameters(
		p_pactid,
		l_year_start,
		l_year_end,
		l_report_type,
		l_business_group_id,
                l_legislative_param
		);
        /* Validating Transmitter Information */
        validate_transmitter_info(p_pactid,
                                  l_business_group_id,
                                  l_year_end);

	--Open the appropriate cursor

	hr_utility.set_location( 'pay_ca_rl2_mag.create_assignment_act',20);
    hr_utility.trace('Report type '||l_report_type);
	IF l_report_type = 'RL2_XML_MAG' THEN
		OPEN c_all_asg(l_legislative_param,
                               l_business_group_id,
                               l_year_end);
		LOOP
		    FETCH c_all_asg INTO l_person_id,
		 			 l_assignment_id,
		 			 l_tax_unit_id,
		 			 l_effective_end_date,
              				 l_assignment_action_id,
                                         l_payroll_act;

       		    hr_utility.set_location('pay_ca_rl2_mag.create_assignment_act', 30);

		    EXIT WHEN c_all_asg%NOTFOUND;

		--Create the assignment action for the record

                 /* Validating QIN Number information */
                  if l_prev_payact <> l_payroll_act then

                      hr_utility.trace('The payroll action id '||l_payroll_act);

                      l_prev_payact := l_payroll_act;
                      l_emplyer_name := pay_ca_rl2_mag.get_employer_item(l_business_group_id,
                                                                         l_payroll_act,
                                                                         'CAEOY_RL2_EMPLOYER_NAME');

                       l_quebec_no := pay_ca_rl2_mag.get_employer_item(l_business_group_id,
                                                                       l_payroll_act,
                                                                       'CAEOY_RL2_QUEBEC_BN');
                      hr_utility.trace('The Quebec Number is '||l_quebec_no);
                      l_file_no     := substr(l_quebec_no,13,4);
                      l_quebec_no   := substr(l_quebec_no ,1,10);

                     /* Fix for Bug# 4038551 */
                      if (l_file_no = '0000' and l_quebec_no = '0000000000') or
                         length(l_file_no) < 4
                      then
                           pay_core_utils.push_message(801,'PAY_74156_INCORRECT_QIN_INFO','P');
                           pay_core_utils.push_token('PRE_NAME',l_emplyer_name);
                           hr_utility.raise_error;
                      end if;


                     /* Erroring out the RL2 Electronic Interface if any of the
                        mandatory information is missing i.e Address Line 1 */

                       l_addr_line := pay_ca_rl2_mag.get_employer_item(l_business_group_id,
                                                                       l_payroll_act,
                                                                       'CAEOY_RL2_EMPLOYER_ADDRESS_LINE1');
                      if l_addr_line = '                              '
                      then
                           pay_core_utils.push_message(800,'PAY_CA_RL2_MISSING_ADDRESS','P');
                           hr_utility.raise_error;
                      end if;
                      hr_utility.trace('First 10 digits of the QIN: '||l_quebec_no);
                      l_return := validate_quebec_number(l_quebec_no,l_emplyer_name);

                  end if ;
		  hr_utility.trace('Assignment Fetched  - ');
		  hr_utility.trace('Assignment Id : '|| to_char(l_assignment_id));
		  hr_utility.trace('Person Id :  '|| to_char(l_person_id));
		  hr_utility.trace('tax unit id : '|| to_char(l_tax_unit_id));
		  hr_utility.trace('Effective End Date :  '|| to_char(l_effective_end_date));

		  hr_utility.set_location('pay_ca_rl2_mag.create_assignment_act', 40);

	            SELECT pay_assignment_actions_s.nextval
		    INTO lockingactid
		    FROM dual;

	            hr_utility.set_location('pay_ca_rl2_mag.create_assignment_act', 50);
		    hr_nonrun_asact.insact(lockingactid,
                                           l_assignment_id,
                                           p_pactid,
                                           p_chunk,
                                           l_tax_unit_id);

               /* Update the serial number column with the person id
                   */

               -- hr_utility.trace('updating asg. action');

               update pay_assignment_actions aa
                  set aa.serial_number = to_char(l_person_id)
                where  aa.assignment_action_id = lockingactid;

		    hr_utility.set_location('pay_ca_rl2_mag.create_assignment_act', 60);

       		    hr_nonrun_asact.insint(lockingactid, l_assignment_action_id);

		    hr_utility.set_location('pay_ca_rl2_mag.create_assignment_act', 70);
		    hr_utility.trace('Interlock Created  - ');
		    hr_utility.trace('Locking Action : '|| to_char(lockingactid));
		    hr_utility.trace('Locked Action :  '|| to_char(l_assignment_action_id));

		END LOOP;
		CLOSE c_all_asg;

	END IF;

END create_assignment_act;

FUNCTION get_parameter(name IN varchar2, parameter_list varchar2)
RETURN varchar2 IS
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
BEGIN
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     IF end_ptr = 0 THEN
        end_ptr := length(parameter_list)+1;
     END IF;
--
     /* Did we find the token */
     IF instr(parameter_list, token_val) = 0 THEN
       par_value := NULL;
     ELSE
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     END IF;

     RETURN par_value;

END get_parameter;


FUNCTION get_transmitter_item (p_business_group_id IN number,
                               p_pact_id           IN number,
                               p_archived_item     IN varchar2)
RETURN varchar2 IS

CURSOR c_trans_info IS
SELECT nvl(transmitter_number,'        '),
       nvl(reporting_year,'0000'),
       nvl(transmitter_package_type,'0'),
       nvl(transmitter_type_indicator,'0'),
       nvl(transmitter_name,'                              '),
       nvl(source_of_slips,' '),
       nvl(transmitter_address_line1,'                              '),
       nvl(transmitter_address_line2,'                              '),
       nvl(transmitter_city,'                              '),
       nvl(transmitter_province,'                    '),
       nvl(transmitter_postal_code,'      '),
       nvl(transmitter_tech_contact_name,'                              '),
       nvl(transmitter_tech_contact_code,'000'),
       nvl(transmitter_tech_contact_phone,'0000000'),
       nvl(transmitter_tech_contact_extn,'0000'),
       nvl(transmitter_tech_contact_lang,' '),
       nvl(transmitter_acct_contact_name,'                              '),
       nvl(transmitter_acct_contact_code,'000'),
       nvl(transmitter_acct_contact_phone,'0000000'),
       nvl(transmitter_acct_contact_extn,'0000'),
       nvl(transmitter_acct_contact_lang,' ')
FROM pay_ca_eoy_rl2_trans_info_v
WHERE business_group_id = p_business_group_id
AND   payroll_action_id = p_pact_id;

l_trans_number  varchar2(240);
l_reporting_year varchar2(240);
l_trans_package_type varchar2(240);
l_trans_type_indicator varchar2(240);
l_trans_name varchar2(240);
l_source_of_slips varchar2(240);
l_trans_address_line1 varchar2(240);
l_trans_address_line2 varchar2(240);
l_trans_city varchar2(240);
l_trans_province varchar2(240);
l_trans_postal_code varchar2(240);
l_trans_tech_contact_name varchar2(240);
l_trans_tech_contact_code varchar2(240);
l_trans_tech_contact_phone varchar2(240);
l_trans_tech_contact_extn varchar2(240);
l_trans_tech_contact_lang varchar2(240);
l_trans_acct_contact_name varchar2(240);
l_trans_acct_contact_code varchar2(240);
l_trans_acct_contact_phone varchar2(240);
l_trans_acct_contact_extn varchar2(240);
l_trans_acct_contact_lang varchar2(240);

l_return_value varchar2(240);

BEGIN

     OPEN c_trans_info;
     FETCH c_trans_info
     INTO   l_trans_number,
            l_reporting_year,
            l_trans_package_type,
            l_trans_type_indicator,
            l_trans_name,
            l_source_of_slips,
            l_trans_address_line1,
            l_trans_address_line2,
            l_trans_city,
            l_trans_province,
            l_trans_postal_code,
            l_trans_tech_contact_name,
            l_trans_tech_contact_code,
            l_trans_tech_contact_phone,
            l_trans_tech_contact_extn,
            l_trans_tech_contact_lang,
            l_trans_acct_contact_name,
            l_trans_acct_contact_code,
            l_trans_acct_contact_phone,
            l_trans_acct_contact_extn,
            l_trans_acct_contact_lang;

     CLOSE c_trans_info;

     IF p_archived_item = 'CAEOY_RL2_TRANSMITTER_NUMBER' THEN
         l_return_value := l_trans_number;
     ELSIF p_archived_item = 'CAEOY_TAXATION_YEAR' THEN
         l_return_value := l_reporting_year;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_PACKAGE_TYPE' THEN
         l_return_value := l_trans_package_type;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_TYPE' THEN
         l_return_value := l_trans_type_indicator;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_NAME' THEN
         l_return_value := l_trans_name;
     ELSIF p_archived_item = 'CAEOY_RL2_SOURCE_OF_SLIPS' THEN
         l_return_value := l_source_of_slips;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_ADDRESS_LINE1' THEN
         l_return_value := l_trans_address_line1;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_ADDRESS_LINE2' THEN
         l_return_value := l_trans_address_line2;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_CITY' THEN
         l_return_value := l_trans_city;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_PROVINCE' THEN
         l_return_value := l_trans_province;
     ELSIF p_archived_item = 'CAEOY_RL2_TRANSMITTER_POSTAL_CODE' THEN
         l_return_value := l_trans_postal_code;
     ELSIF p_archived_item = 'CAEOY_RL2_TECHNICAL_CONTACT_NAME' THEN
         l_return_value := l_trans_tech_contact_name;
     ELSIF p_archived_item = 'CAEOY_RL2_TECHNICAL_CONTACT_AREA_CODE' THEN
         l_return_value := l_trans_tech_contact_code;
     ELSIF p_archived_item = 'CAEOY_RL2_TECHNICAL_CONTACT_PHONE' THEN
         l_return_value := l_trans_tech_contact_phone;
     ELSIF p_archived_item = 'CAEOY_RL2_TECHNICAL_CONTACT_EXTENSION' THEN
         l_return_value := l_trans_tech_contact_extn;
     ELSIF p_archived_item = 'CAEOY_RL2_TECHNICAL_CONTACT_LANGUAGE' THEN
         l_return_value := l_trans_tech_contact_lang;
     ELSIF p_archived_item = 'CAEOY_RL2_ACCOUNTING_CONTACT_NAME' THEN
         l_return_value := l_trans_acct_contact_name;
     ELSIF p_archived_item = 'CAEOY_RL2_ACCOUNTING_CONTACT_AREA_CODE' THEN
         l_return_value := l_trans_acct_contact_code;
     ELSIF p_archived_item = 'CAEOY_RL2_ACCOUNTING_CONTACT_PHONE' THEN
         l_return_value := l_trans_acct_contact_phone;
     ELSIF p_archived_item = 'CAEOY_RL2_ACCOUNTING_CONTACT_EXTENSION' THEN
         l_return_value := l_trans_acct_contact_extn;
     ELSIF p_archived_item = 'CAEOY_RL2_ACCOUNTING_CONTACT_LANGUAGE' THEN
         l_return_value := l_trans_acct_contact_lang;
     END IF;

     RETURN l_return_value;

END get_transmitter_item;

FUNCTION get_employer_item (p_business_group_id IN number,
                            p_pact_id           IN number,
                            p_archived_item     IN varchar2)
RETURN varchar2 IS

CURSOR c_employer_info IS
SELECT nvl(employer_name,'                              '),
       nvl(quebec_business_number,'0000000000  0000'),
       nvl(reporting_year,'0000'),
       nvl(employer_add_line1,'                              '),
       nvl(employer_add_line2,'                              '),
       nvl(employer_city,'                              '),
       nvl(employer_province,'                    '),
       nvl(employer_postal_code,'      ')
FROM pay_ca_eoy_rl2_trans_info_v
WHERE business_group_id = p_business_group_id
AND   payroll_action_id = p_pact_id;

l_employer_name  varchar2(240);
l_reporting_year varchar2(240);
l_quebec_business_number varchar2(240);
l_employer_add_line1 varchar2(240);
l_employer_add_line2 varchar2(240);
l_employer_city  varchar2(240);
l_employer_province varchar2(240);
l_employer_postal_code varchar2(240);

l_return_value varchar2(240);

BEGIN

     OPEN c_employer_info;
     FETCH c_employer_info
     INTO   l_employer_name,
            l_quebec_business_number,
            l_reporting_year,
            l_employer_add_line1,
            l_employer_add_line2,
            l_employer_city,
            l_employer_province,
            l_employer_postal_code;

     CLOSE c_employer_info;

     IF p_archived_item = 'CAEOY_RL2_QUEBEC_BN' THEN
         l_return_value := l_quebec_business_number;
     ELSIF p_archived_item = 'CAEOY_TAXATION_YEAR' THEN
         l_return_value := l_reporting_year;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYER_NAME' THEN
         l_return_value := l_employer_name;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYER_ADDRESS_LINE1' THEN
         l_return_value := l_employer_add_line1;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYER_ADDRESS_LINE2' THEN
         l_return_value := l_employer_add_line2;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYER_CITY' THEN
         l_return_value := l_employer_city;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYER_PROVINCE' THEN
         l_return_value := l_employer_province;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYER_POSTAL_CODE' THEN
         l_return_value := l_employer_postal_code;
     END IF;

     RETURN l_return_value;

END get_employer_item;


  PROCEDURE end_of_file is

  BEGIN

  DECLARE

    l_final_xml_string VARCHAR2(32000);

  BEGIN

    l_final_xml_string := '</Transmission>';
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;

  END;

 PROCEDURE xml_transmitter_record IS
 BEGIN

 DECLARE

CURSOR c_trans_info(p_business_group_id IN number,
                    p_pact_id           IN number) IS
SELECT nvl(transmitter_number,'        '),
       nvl(reporting_year,'0000'),
       nvl(transmitter_package_type,'0'),
       nvl(transmitter_type_indicator,'0'),
       nvl(transmitter_name,'                              '),
       nvl(source_of_slips,' '),
       nvl(transmitter_address_line1,'                              '),
       nvl(transmitter_address_line2,'                              '),
       nvl(transmitter_city,'                              '),
       nvl(transmitter_province,'                    '),
       nvl(transmitter_postal_code,'      '),
       nvl(transmitter_tech_contact_name,'                              '),
       nvl(transmitter_tech_contact_code,'000'),
       nvl(transmitter_tech_contact_phone,'0000000'),
       nvl(transmitter_tech_contact_extn,'0000'),
       nvl(transmitter_tech_contact_lang,' '),
       nvl(transmitter_acct_contact_name,'                              '),
       nvl(transmitter_acct_contact_code,'000'),
       nvl(transmitter_acct_contact_phone,'0000000'),
       nvl(transmitter_acct_contact_extn,'0000'),
       nvl(transmitter_acct_contact_lang,' ')
FROM pay_ca_eoy_rl2_trans_info_v
WHERE business_group_id = p_business_group_id
AND   payroll_action_id = p_pact_id;

l_trans_number  varchar2(240);
l_reporting_year varchar2(240);
l_trans_package_type varchar2(240);
l_trans_type_indicator varchar2(240);
l_trans_name varchar2(240);
l_source_of_slips varchar2(240);
l_trans_address_line1 varchar2(240);
l_trans_address_line2 varchar2(240);
l_trans_city varchar2(240);
l_trans_province varchar2(240);
l_trans_postal_code varchar2(240);
l_trans_tech_contact_name varchar2(240);
l_trans_tech_contact_code varchar2(240);
l_trans_tech_contact_phone varchar2(240);
l_trans_tech_contact_extn varchar2(240);
l_trans_tech_contact_lang varchar2(240);
l_trans_acct_contact_name varchar2(240);
l_trans_acct_contact_code varchar2(240);
l_trans_acct_contact_phone varchar2(240);
l_trans_acct_contact_extn varchar2(240);
l_trans_acct_contact_lang varchar2(240);

    l_final_xml_string VARCHAR2(32000);
    l_tech_accnt_info  VARCHAR2(32000);

    TYPE transmitter_info IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    tab_transmitter transmitter_info;

    lAnnee       NUMBER;
    lTypeEnvoi   NUMBER;
    lProvenance  NUMBER;
    lNo          NUMBER;
    lType        NUMBER;
    lNom1        NUMBER;
    lNom2        NUMBER;
    lLigne1      NUMBER;
    lLigne2      NUMBER;
    lVille       NUMBER;
    lProvince    NUMBER;
    lCodePostal  NUMBER;
    lNom         NUMBER;
    lIndRegional NUMBER;
    lTel         NUMBER;
    lPosteTel    NUMBER;
    lLangue      NUMBER;
    lANom        NUMBER;
    lAIndRegional NUMBER;
    lATel         NUMBER;
    lAPosteTel    NUMBER;
    lALangue      NUMBER;

    EOL                 VARCHAR2(5);
    l_transmitter_name  VARCHAR2(100);
    l_taxation_year     VARCHAR2(4);
    l_return            VARCHAR2(60);
    l_payroll_actid     NUMBER;
    l_year_start        DATE;
    l_year_end          DATE;
    l_report_type       VARCHAR2(5);
    l_business_grpid    NUMBER;
    l_legislative_param pay_payroll_actions.legislative_parameters%type;
   /* Bug 4777374 Fix */
    l_Informatique_tag  CHAR(1);
    l_Comptabilite_tag  CHAR(1);
   /* Bug 4906963 Fix */
    l_authorization_no  VARCHAR2(20);
    lNoConcepteur       NUMBER;
    l_VersionSchema     VARCHAR2(20);
  BEGIN

    hr_utility.trace('XML Transmitter');


    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lAnnee        := 1;
    lTypeEnvoi    := 2;
    lProvenance   := 3;
    lNo           := 4;
    lType         := 5;
    lNom1         := 6;
    lNom2         := 7;
    lLigne1       := 8;
    lLigne2       := 9;
    lVille        := 10;
    lProvince     := 11;
    lCodePostal   := 12;
    lNom          := 13;
    lIndRegional  := 14;
    lTel          := 15;
    lPosteTel     := 16;
    lLangue       := 17;
    lANom         := 18;
    lAIndRegional := 19;
    lATel         := 20;
    lAPosteTel    := 21;
    lALangue      := 22;
    lNoConcepteur := 23;

    l_Informatique_tag := 'N';
    l_Comptabilite_tag := 'N';

    l_taxation_year
        := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');
    l_payroll_actid
        := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');

	get_report_parameters(
		l_payroll_actid,
		l_year_start,
		l_year_end,
		l_report_type,
		l_business_grpid,
                l_legislative_param
	);


    hr_utility.trace('XML Transmitter: l_taxation_year = ' || l_taxation_year);
    hr_utility.trace('XML Transmitter: l_payroll_Action_id = ' || to_char(l_payroll_actid));

     OPEN c_trans_info(l_business_grpid,
                       l_payroll_actid);
     FETCH c_trans_info
     INTO   l_trans_number,
            l_reporting_year,
            l_trans_package_type,
            l_trans_type_indicator,
            l_trans_name,
            l_source_of_slips,
            l_trans_address_line1,
            l_trans_address_line2,
            l_trans_city,
            l_trans_province,
            l_trans_postal_code,
            l_trans_tech_contact_name,
            l_trans_tech_contact_code,
            l_trans_tech_contact_phone,
            l_trans_tech_contact_extn,
            l_trans_tech_contact_lang,
            l_trans_acct_contact_name,
            l_trans_acct_contact_code,
            l_trans_acct_contact_phone,
            l_trans_acct_contact_extn,
            l_trans_acct_contact_lang;

     CLOSE c_trans_info;
    -- Annee
    tab_transmitter(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' ||EOL;
    hr_utility.trace('tab_transmitter(lAnnee) = ' || tab_transmitter(lAnnee));

    -- TypeEnvoi
    tab_transmitter(lTypeEnvoi) := '<TypeEnvoi>' ||
         convert_special_char(l_trans_package_type) || '</TypeEnvoi>' || EOL;
    hr_utility.trace('tab_transmitter(lTypeEnvoi) = ' ||
                                           tab_transmitter(lTypeEnvoi));

    tab_transmitter(lProvenance) := '<Provenance>' ||
         convert_special_char(l_source_of_slips) || '</Provenance>' || EOL;

    hr_utility.trace('tab_transmitter(lProvenance) = ' || tab_transmitter(lProvenance));

    tab_transmitter(lNo) := '<No>' ||
        convert_special_char(l_trans_number) || '</No>' || EOL;

    hr_utility.trace('tab_transmitter(lNo) = ' || tab_transmitter(lNo));


   IF l_trans_type_indicator IS NOT NULL AND
      l_trans_type_indicator <> '0' THEN
      tab_transmitter(lType) := '<Type>' ||
        convert_special_char(l_trans_type_indicator) || '</Type>' || EOL;
   ELSE
      tab_transmitter(lType) := NULL;
   END IF;

    hr_utility.trace('tab_transmitter(lType) = ' || tab_transmitter(lType));

    tab_transmitter(lNom1) := '<Nom1>' ||
                    convert_special_char(substr(l_trans_name,1,30)) || '</Nom1>' || EOL;

    hr_utility.trace('tab_transmitter(lNom1) = ' || tab_transmitter(lNom1));

    l_return := substr(l_trans_name,31,30);
    IF l_return IS NOT NULL THEN
      tab_transmitter(lNom2) := '<Nom2>' || convert_special_char(l_return) || '</Nom2>' || EOL;
    ELSE
      tab_transmitter(lNom2) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lNom2) = ' || tab_transmitter(lNom2));


    tab_transmitter(lLigne1) := '<Ligne1>' ||
                  convert_special_char(substr(l_trans_address_line1,1,30)) || '</Ligne1>' || EOL;

    hr_utility.trace('tab_transmitter(lLigne1) = ' || tab_transmitter(lLigne1));


    IF (l_trans_address_line2 IS NOT NULL AND
        l_trans_address_line2 <> '                              ') THEN
      tab_transmitter(lLigne2) := '<Ligne2>' ||
                  convert_special_char(substr(l_trans_address_line2,1,30)) || '</Ligne2>' || EOL;
    ELSE
      tab_transmitter(lLigne2) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lLigne2) = ' || tab_transmitter(lLigne2));


    IF (l_trans_city IS NOT NULL AND
        l_trans_city <> '                              ')  THEN
      tab_transmitter(lVille) := '<Ville>' ||
                  convert_special_char(substr(l_trans_city,1,30)) || '</Ville>' || EOL;
    ELSE
      tab_transmitter(lVille) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lVille) = ' || tab_transmitter(lVille));

    IF (l_trans_province IS NOT NULL AND
        l_trans_province <> '                    ') THEN
        tab_transmitter(lProvince) := '<Province>' ||
                   convert_special_char(SUBSTR(hr_general.decode_lookup(
                   'CA_PROVINCE',l_trans_province),1,20)) || '</Province>' || EOL;
    ELSE
        tab_transmitter(lProvince) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lProvince) = ' || tab_transmitter(lProvince));

    IF (l_trans_postal_code IS NOT NULL AND
        l_trans_postal_code <> '      ') THEN
        tab_transmitter(lCodePostal) := '<CodePostal>' ||
             convert_special_char(substr(l_trans_postal_code,1,6)) || '</CodePostal>' || EOL;
    ELSE
        tab_transmitter(lCodePostal) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lCodePostal) = ' || tab_transmitter(lCodePostal));


    IF (l_trans_tech_contact_name IS NOT NULL AND
        l_trans_tech_contact_name <> '                              ' ) THEN
      l_Informatique_tag := 'Y';
      tab_transmitter(lNom) := '<Nom>' ||
             convert_special_char(substr(l_trans_tech_contact_name,1,30)) || '</Nom>' || EOL;
    ELSE
      tab_transmitter(lNom) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lNom) = ' || tab_transmitter(lNom));


    IF (l_trans_tech_contact_code IS NOT NULL AND
        l_trans_tech_contact_code <> '000' ) THEN
      l_Informatique_tag := 'Y';
      tab_transmitter(lIndRegional) := '<IndRegional>' ||
                                         convert_special_char(l_trans_tech_contact_code) || '</IndRegional>' || EOL;
    ELSE
      tab_transmitter(lIndRegional) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lIndRegional) = ' || tab_transmitter(lIndRegional));

    IF (l_trans_tech_contact_phone IS NOT NULL AND
        l_trans_tech_contact_phone <> '0000000' ) THEN
      l_Informatique_tag := 'Y';
      l_trans_tech_contact_phone := substr(l_trans_tech_contact_phone,1,3) || '-' || substr(l_trans_tech_contact_phone,4,4);
      tab_transmitter(lTel) := '<Tel>' || convert_special_char(l_trans_tech_contact_phone) || '</Tel>' || EOL;
    ELSE
      tab_transmitter(lTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lTel) = ' || tab_transmitter(lTel));


    IF (l_trans_tech_contact_extn IS NOT NULL AND
        l_trans_tech_contact_extn <> '0000' ) THEN
      l_Informatique_tag := 'Y';
      tab_transmitter(lPosteTel) := '<PosteTel>' || convert_special_char(l_trans_tech_contact_extn) ||
                                  '</PosteTel>' || EOL;
    ELSE
      tab_transmitter(lPosteTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lPosteTel) = ' ||
                            tab_transmitter(lPosteTel));


   IF (l_trans_tech_contact_lang IS NOT NULL AND
       l_trans_tech_contact_lang <> ' ' )  THEN
    l_Informatique_tag := 'Y';
    tab_transmitter(lLangue) := '<Langue>' ||convert_special_char(l_trans_tech_contact_lang) || '</Langue>' || EOL;
   ELSE
     tab_transmitter(lLangue) := NULL;
   END IF;


    IF (l_trans_acct_contact_name IS NOT NULL AND
        l_trans_acct_contact_name <> '                              ')  THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lANom) := '<Nom>' ||
             convert_special_char(substr(l_trans_acct_contact_name,1,30)) || '</Nom>' || EOL;
    ELSE
      tab_transmitter(lANom) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lANom) = ' || tab_transmitter(lANom));


    IF (l_trans_acct_contact_code IS NOT NULL AND
        l_trans_acct_contact_code <> '000' ) THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lAIndRegional) := '<IndRegional>' || convert_special_char(l_trans_acct_contact_code) ||
                                      '</IndRegional>' || EOL;
    ELSE
      tab_transmitter(lAIndRegional) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lAIndRegional) = ' || tab_transmitter(lAIndRegional));


    IF (l_trans_acct_contact_phone IS NOT NULL AND
        l_trans_acct_contact_phone <> '0000000' ) THEN
      l_Comptabilite_tag := 'Y';
      l_trans_acct_contact_phone := substr(l_trans_acct_contact_phone,1,3) || '-' || substr(l_trans_acct_contact_phone,4,4);
      tab_transmitter(lATel) := '<Tel>' || convert_special_char(l_trans_acct_contact_phone) || '</Tel>' || EOL;
    ELSE
      tab_transmitter(lATel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lATel) = ' || tab_transmitter(lATel));


    IF (l_trans_acct_contact_extn IS NOT NULL AND
        l_trans_acct_contact_extn <> '0000')  THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lAPosteTel) := '<PosteTel>' || convert_special_char(l_trans_acct_contact_extn) ||
                                     '</PosteTel>' || EOL;
    ELSE
      tab_transmitter(lAPosteTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lAPosteTel) = ' ||
                                      tab_transmitter(lAPosteTel));

    IF (l_trans_acct_contact_lang IS NOT NULL AND
        l_trans_acct_contact_lang <> ' ' ) THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lALangue) := '<Langue>' || convert_special_char(l_trans_acct_contact_lang) ||
                                   '</Langue>' || EOL;
    ELSE
      tab_transmitter(lALangue) := NULL;
    END IF;

    --- Bug 6736354
    IF ( l_reporting_year = '2006' ) then
        l_authorization_no := 'RQ-06-02-048';
    ELSIF ( l_reporting_year = '2007' ) then
        l_authorization_no := 'RQ-07-02-069';
    ELSIF (l_reporting_year = '2008' ) then
        l_authorization_no := 'RQ-08-02-048';
    ELSIF (l_reporting_year = '2009' ) then
        l_authorization_no := 'RQ-09-02-019'; -- Bug 9206939
    ELSE
        l_authorization_no := 'RQ-09-99-999'; --Bug 9041046
    END IF;
    --- End 6736354

    tab_transmitter(lNoConcepteur) := '<NoCertification>'||convert_special_char(l_authorization_no)||'</NoCertification>'||EOL;

    hr_utility.trace('tab_transmitter(lALangue) = ' || tab_transmitter(lALangue));

   IF l_Informatique_tag = 'Y' AND
      l_Comptabilite_tag = 'Y' THEN
      l_tech_accnt_info := '<Informatique>' || EOL ||
                     tab_transmitter(lNom) ||
                     tab_transmitter(lIndRegional) ||
                     tab_transmitter(lTel) ||
                     tab_transmitter(lPosteTel) ||
                     tab_transmitter(lLangue) || '</Informatique>' || EOL ||
                     '<Comptabilite>' || EOL ||
                     tab_transmitter(lANom) ||
                     tab_transmitter(lAIndRegional) ||
                     tab_transmitter(lATel) ||
                     tab_transmitter(lAPosteTel) ||
                     tab_transmitter(lALangue) || '</Comptabilite>' ;
   ELSIF l_Informatique_tag = 'Y' AND
         l_Comptabilite_tag = 'N' THEN
        l_tech_accnt_info := '<Informatique>' || EOL ||
                     tab_transmitter(lNom) ||
                     tab_transmitter(lIndRegional) ||
                     tab_transmitter(lTel) ||
                     tab_transmitter(lPosteTel) ||
                     tab_transmitter(lLangue) || '</Informatique>';
   ELSIF l_Comptabilite_tag = 'Y' AND
         l_Informatique_tag = 'N' THEN
        l_tech_accnt_info :=  '<Comptabilite>' || EOL ||
                     tab_transmitter(lANom) ||
                     tab_transmitter(lAIndRegional) ||
                     tab_transmitter(lATel) ||
                     tab_transmitter(lAPosteTel) ||
                     tab_transmitter(lALangue) || '</Comptabilite>';
   ELSE
       l_tech_accnt_info := NULL;
   END IF;

     -- Bug 7602718
    if(l_reporting_year = '2006') then
      l_VersionSchema := '2006.1.2';
    elsif(l_reporting_year = '2007') then
      l_VersionSchema := '2007.1.1';
    else
      l_VersionSchema := trim(l_reporting_year)||'.1';
    end if;
    -- End

    l_final_xml_string :=
                   '<Transmission VersionSchema="'||l_VersionSchema||'" ' ||
                   'pxmlns="http://www.mrq.gouv.qc.ca/T5">' || EOL ||
                   '<P>' || EOL ||
                   tab_transmitter(lAnnee) ||
                   tab_transmitter(lTypeEnvoi) ||
                   tab_transmitter(lProvenance) || '<Preparateur>' || EOL ||
                   tab_transmitter(lNo) ||
                   tab_transmitter(lType) ||
                   tab_transmitter(lNom1) ||
                   tab_transmitter(lNom2) || '<Adresse>' || EOL ||
                   tab_transmitter(lLigne1) ||
                   tab_transmitter(lLigne2) ||
                   tab_transmitter(lVille) ||
                   tab_transmitter(lProvince) ||
                   tab_transmitter(lCodePostal) || '</Adresse>' || EOL ||
                   '</Preparateur>' || EOL  ||
                   l_tech_accnt_info || EOL ||
                   tab_transmitter(lNoConcepteur) ||
                   '</P>' || EOL;

    --hr_utility.trace('l_final_xml_string = ' || l_final_xml_string);

      pay_core_files.write_to_magtape_lob(l_final_xml_string);
  END;
  END xml_transmitter_record;


  PROCEDURE xml_employee_record IS
  BEGIN

  DECLARE

    l_final_xml_string  VARCHAR2(32000);
    l_final_xml_string1 VARCHAR2(32000);
    l_final_xml_string2 VARCHAR2(32000);

   CURSOR c_get_payroll_asg_actid(p_payactid NUMBER) IS
   SELECT
         to_number(substr(paa.serial_number,3,14)) payactid,
         to_number(substr(paa.serial_number,17,14)) asgactid,
         paa.assignment_id asgid
   FROM
         pay_assignment_actions paa
   WHERE paa.assignment_action_id = p_payactid;

   CURSOR c_get_report_type(p_payactid NUMBER) IS
   SELECT
         ppa.report_type,
         ppa.business_group_id,
         ppa.legislative_parameters
   FROM
         pay_payroll_actions ppa
   WHERE
         ppa.payroll_action_id = p_payactid;

   CURSOR  c_get_employer_info(p_pact_id NUMBER,
                               p_business_group_id NUMBER) IS
   SELECT nvl(employer_name,'                              '),
          nvl(quebec_business_number,'0000000000  0000'),
          nvl(reporting_year,'0000'),
          nvl(employer_add_line1,'                              '),
          nvl(employer_add_line2,'                              '),
          nvl(employer_add_line3,'                              '),
          nvl(employer_city,'                              '),
          nvl(employer_province,'                    '),
          nvl(employer_country,'  '),
          nvl(employer_postal_code,'      ')
   FROM
          pay_ca_eoy_rl2_trans_info_v
   WHERE
          business_group_id = p_business_group_id
     AND  payroll_action_id = p_pact_id;

   CURSOR cur_parameters(p_mag_asg_action_id NUMBER) IS
   SELECT
         pai.locked_action_id,  -- Archiver asg_action_id
         paa.assignment_id,
         pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
         -- date_earned
   FROM
         pay_action_interlocks pai,
         pay_assignment_actions paa,
         pay_payroll_actions ppa,
         per_all_people_f ppf,
         per_all_assignments_f paf,
         pay_action_information pact
   WHERE paa.assignment_action_id = pai.locking_action_id
    AND  paa.assignment_action_id = p_mag_asg_action_id
    AND  paf.assignment_id = paa.assignment_id
    AND  ppf.person_id = paf.person_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  pai.locked_action_id = pact.action_context_id
    AND  pact.action_information_category = 'CAEOY RL2 EMPLOYEE INFO'
    AND  pact.assignment_id  = paa.assignment_id
    AND  pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
         between paf.effective_start_date and paf.effective_end_date
    AND  pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
         between ppf.effective_start_date and ppf.effective_end_date
   ORDER BY
         ppf.last_name,ppf.first_name,ppf.middle_names;

CURSOR c_employee_infor (p_asg_action_id     IN number)
IS
SELECT nvl(tran.quebec_business_number,'0000000000  0000'),
       nvl(tran.reporting_year,'0000'),
       nvl(emp.rl2_slip_number,'000000000'),
       nvl(emp.employee_sin,'000000000'),
       nvl(emp.employee_last_name,'                              '),
       nvl(emp.employee_first_name,'                              '),
       nvl(emp.employee_middle_initial,' '),
       nvl(emp.employee_address_line1,'                              '),
       nvl(emp.employee_address_line2,'                              '),
       nvl(emp.employee_address_line3,'                              '),
       nvl(emp.employee_city,'                              '),
       nvl(emp.employee_province,'                    '),
       nvl(emp.employee_postal_code,'      '),
       nvl(emp.employee_number,'                    '),
       emp.rl2_box_a,
       emp.rl2_box_b,
       emp.rl2_box_c,
       emp.rl2_box_d,
       emp.rl2_box_e,
       emp.rl2_box_f,
       emp.rl2_box_g,
       emp.rl2_box_h,
       emp.rl2_box_i,
       emp.rl2_box_j,
       emp.rl2_box_k,
       emp.rl2_box_l,
       emp.rl2_box_m,
       emp.rl2_box_n,
       emp.rl2_box_o,
       decode(substr(emp.rl2_source_of_income,1,5),'OTHER','AUTRE', emp.rl2_source_of_income),
       nvl(emp.negative_balance_flag, 'N'),
       emp.person_id
FROM pay_ca_eoy_rl2_employee_info_v emp,
     pay_ca_eoy_rl2_trans_info_v    tran
WHERE emp.assignment_action_id = p_asg_action_id
AND   emp.payroll_action_id    = tran.payroll_action_id;
/* Commented for bug 8888411
AND   nvl(emp.rl2_source_of_income,1) not in  --6525968
		(select lookup_code from hr_lookups hl, fnd_sessions fs
		 where fs.session_id = USERENV('SESSIONID')
		 and hl.lookup_type = 'PAY_CA_RL2_SOURCE_OF_INCOME'
		 and (fs.effective_date >  nvl(hl.end_date_active,to_date('31/12/4712','dd/mm/yyyy'))
		      or hl.enabled_flag='N')
		 ); --End 6525968
*/

/* Added for bug 8888411 */
CURSOR c_rl2_src_income(p_rl2_source_of_income varchar2, p_taxation_year varchar2) is
select
  'X'
from
  hr_lookups hl
where
  hl.lookup_type = 'PAY_CA_RL2_SOURCE_OF_INCOME'
  and trim(hl.lookup_code) = trim(p_rl2_source_of_income)
  and to_date('31/12/'||p_taxation_year,'dd/mm/yyyy')<= nvl(hl.end_date_active,to_date('31/12/4712','dd/mm/yyyy'))
  and hl.enabled_flag='Y';

l_quebec_business_number varchar2(240);
l_reporting_year varchar2(240);
l_rl2_slip_number varchar2(240);
l_employee_sin varchar2(240);
l_employee_sin1 varchar2(240);
l_employee_sin2 varchar2(240);
l_employee_sin3 varchar2(240);
l_employee_last_name varchar2(240);
l_employee_first_name varchar2(240);
l_employee_middle_initial varchar2(240);
l_employee_address_line1 varchar2(240);
l_employee_address_line2 varchar2(240);
l_employee_address_line3 varchar2(240);
l_employee_city varchar2(240);
l_employee_province varchar2(240);
l_employee_postal_code varchar2(240);
l_employee_number varchar2(240);
l_per_id    varchar2(50);
l_rl2_box_a varchar2(240);
l_rl2_box_b varchar2(240);
l_rl2_box_c varchar2(240);
l_rl2_box_d varchar2(240);
l_rl2_box_e varchar2(240);
l_rl2_box_f varchar2(240);
l_rl2_box_g varchar2(240);
l_rl2_box_h varchar2(240);
l_rl2_box_i varchar2(240);
l_rl2_box_j varchar2(240);
l_rl2_box_k varchar2(240);
l_rl2_box_l varchar2(240);
l_rl2_box_m varchar2(240);
l_rl2_box_n varchar2(240);
l_rl2_box_o varchar2(240);
l_rl2_source_of_income  varchar2(240);
l_negative_balance_flag varchar2(240);


    l_mag_asg_action_id   pay_assignment_actions.assignment_action_id%TYPE;
    l_arch_action_id      pay_assignment_actions.assignment_action_id%TYPE;
    l_asg_id              per_assignments_f.assignment_id%TYPE;
    l_date_earned         DATE;
    l_province            VARCHAR2(30);

    TYPE employee_info IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

    tab_employee employee_info;

    lAnnee                   NUMBER;
    lNoReleve                NUMBER;
    lNAS                     NUMBER;
    lNAS1                    NUMBER;
    lNAS2                    NUMBER;
    lNAS3                    NUMBER;
    lNo                      NUMBER;
    lNomFamille              NUMBER;
    lPrenom                  NUMBER;
    lInitiale                NUMBER;
    lLigne1                  NUMBER;
    lLigne2                  NUMBER;
    lVille                   NUMBER;
    lProvince                NUMBER;
    lCodePostal              NUMBER;
    lA_PrestRPA_RPNA         NUMBER;
    lB_PrestREER_FERR_RPDB   NUMBER;
    lC_AutrePaiement         NUMBER;
    lD_RembPrimeConjoint     NUMBER;
    lE_PrestDeces            NUMBER;
    lF_RembCotisInutilise    NUMBER;
    lG_RevocationREER_FERR   NUMBER;
    lH_AutreRevenu           NUMBER;
    lI_DroitDeduction        NUMBER;
    lJ_ImpotQueRetenuSource  NUMBER;
    lK_RevenuApresDeces      NUMBER;
    lL_RetraitREEP           NUMBER;
    lM_LibereImpot           NUMBER;
    lN_NASConjoint           NUMBER;
    lN_NASConjoint1          NUMBER;
    lN_NASConjoint2          NUMBER;
    lO_RetraitRAP            NUMBER;
    lProvenance1             VARCHAR2(10);
    lBoxA_UnregisterdPlan    NUMBER;
    lDesg_BenefitExcAmt      NUMBER;
    lBoxB_DesgBenefitTrnsAmt NUMBER;
    lBoxExcessAmt            NUMBER;
    lAmount_Transferred      NUMBER;
    lBoxC_SinglePayAccured   NUMBER;
    lBoxC_SinglePayAccUnreg  NUMBER;
    lBoxC_ExcessAmtSinPayTrans NUMBER;
    lCode_dereleve           NUMBER;

    l_person_id         per_people_f.person_id%TYPE;
    l_address_line1     per_addresses.address_line1%TYPE;
    l_address_line2     per_addresses.address_line2%TYPE;
    l_address_line3     per_addresses.address_line3%TYPE;
    l_city              per_addresses.town_or_city%TYPE;
    l_postal_code       per_addresses.postal_code%TYPE;
    l_country           VARCHAR2(60);
    l_emp_province      per_addresses.region_1%TYPE;
    EOL                 VARCHAR2(5);
    l_taxation_year     VARCHAR2(5);
    l_name              VARCHAR2(60);
    l_return            VARCHAR2(30);
    l_status            VARCHAR2(10);
    l_addr_begin_tag    VARCHAR2(10);
    l_addr_end_tag      VARCHAR2(10);
    l_formatted_box     VARCHAR2(20);
    l_boxO              VARCHAR2(10);
    l_combined_addr     VARCHAR2(500);
    l_print_instruction VARCHAR2(1);  --added for 5850067

    l_count             NUMBER;
    lBoxR_14            NUMBER;
    lErrorDetails       NUMBER;

  CURSOR cur_get_meaning(p_lookup_code VARCHAR2) IS
  SELECT
    meaning
  FROM
    hr_lookups
  WHERE
   lookup_type = 'PAY_CA_MAG_EXCEPTIONS' and
   lookup_code = p_lookup_code;

  l_meaning    hr_lookups.meaning%TYPE;
  l_msg_code   VARCHAR2(30);
  l_all_box_0  BOOLEAN;

  /* Cursor for fetching the Footnote Codes */
  CURSOR c_footnote_codes ( p_assg_actid  number) is
  SELECT hl.meaning code, fnd_number.canonical_to_number(FT.FOOTNOTE_AMOUNT) value
  FROM PAY_CA_EOY_RL2_FOOTNOTE_INFO_V FT,
       HR_LOOKUPS HL
  WHERE FT.ASSIGNMENT_ACTION_ID = p_assg_actid
  AND ((HL.LOOKUP_TYPE = 'PAY_CA_RL2_FOOTNOTES'
             AND HL.lookup_code = FT.FOOTNOTE_CODE)
         OR
       (HL.LOOKUP_TYPE = 'PAY_CA_RL2_AUTOMATIC_FOOTNOTES'
             AND HL.LOOKUP_CODE = FT.FOOTNOTE_CODE));

  /* Cursor for fetching authorisation code */
  CURSOR c_get_auth_code(p_reporting_year varchar2) IS
  SELECT meaning
  FROM hr_lookups
  WHERE trim(lookup_code) = p_reporting_year
        AND lookup_type = 'PAY_CA_RL2_PDF_AUTH'
        AND enabled_flag='Y';

  l_footnote_code VARCHAR2(100);
  l_footnote_amount NUMBER;
  l_format_mask  VARCHAR2(30);

/* Added the following new variables for XML Paper report */
  tab_employee1 employee_info;
  tab_employee2 employee_info;
  l_rep_type  pay_report_format_mappings_f.report_type%type;
  l_rl2pap_asg_actid NUMBER;
  l_rl2pap_pay_actid NUMBER;
  l_transfer_pay_actid NUMBER;
  l_business_group_id NUMBER;

  TYPE employer_inf IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  tab_emplyr  employer_inf;
  tab_emplyr1 employer_inf;
  tab_emplyr2 employer_inf;

  l_page_break       VARCHAR2(100);
  l_full_empname     VARCHAR2(100);
  l_full_empaddr     VARCHAR2(100);
  l_empr_name        VARCHAR2(240);
  l_empr_quebec_no   VARCHAR2(240);
  l_empr_report_yr   VARCHAR2(240);
  l_empr_addr1       VARCHAR2(240);
  l_empr_addr2       VARCHAR2(240);
  l_empr_addr3       VARCHAR2(240);
  l_empr_city        VARCHAR2(240);
  l_empr_prov        VARCHAR2(240);
  l_empr_postcode    VARCHAR2(240);
  l_empr_country     VARCHAR2(240);
  l_empr_fulladdr    VARCHAR2(240);
  l_counter          NUMBER;
  l_negative_box     VARCHAR2(1);
  l_footnote_count   NUMBER;
  l_footcode         VARCHAR2(100);
  l_footamt          NUMBER;
  l_footnotecode     NUMBER;
  l_footnoteamt      NUMBER;
  l_legislative_parameters pay_payroll_actions.legislative_parameters%type;

  l_authorisation_no  NUMBER;
  l_authorisation_tag NUMBER;
  l_sequence_no       NUMBER;
  l_seq_num           NUMBER;
  l_authorization_code VARCHAR2(100);

  BEGIN
    --hr_utility.trace_on(null,'SATIRL2XML');
    hr_utility.trace('XML Employee');
    l_status := 'Success';
    l_all_box_0 := TRUE;
    l_count := 0;
    l_format_mask := '99999999999999990.99';
    l_counter :=  0;
    l_negative_box := 'N';
    l_footnote_count := 0;
    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lAnnee        := 1;
    lNoReleve     := 2;
    lNAS          := 3;
    lNo           := 4;
    lNomFamille   := 5;
    lPrenom       := 6;
    lInitiale     := 7;
    lLigne1       := 8;
    lLigne2       := 9;
    lVille        := 10;
    lProvince     := 11;
    lCodePostal   := 12;
    lA_PrestRPA_RPNA   := 13;
    lB_PrestREER_FERR_RPDB := 14;
    lC_AutrePaiement  := 15;
    lD_RembPrimeConjoint := 16;
    lE_PrestDeces := 17;
    lF_RembCotisInutilise := 18;
    lG_RevocationREER_FERR  := 19;
    lH_AutreRevenu  := 20;
    lI_DroitDeduction  := 21;
    lJ_ImpotQueRetenuSource  := 22;
    lK_RevenuApresDeces  := 23;
    lL_RetraitREEP  := 24;
    lM_LibereImpot  := 25;
    lN_NASConjoint := 26;
    lO_RetraitRAP  := 27;
    lProvenance1  := 28;
    lErrorDetails := 29;
    lBoxA_UnregisterdPlan      := 30;
    lDesg_BenefitExcAmt        := 31;
    lBoxB_DesgBenefitTrnsAmt   := 32;
    lBoxExcessAmt              := 33;
    lAmount_Transferred        := 34;
    lBoxC_SinglePayAccured     := 35;
    lBoxC_SinglePayAccUnreg    := 36;
    lBoxC_ExcessAmtSinPayTrans := 37;
    l_footnotecode   := 38;
    l_footnoteamt    := 39;
    lNAS1  := 40;
    lNAS2 := 41;
    lNAS3 := 42;
    lN_NASConjoint1 := 43;
    lN_NASConjoint2 := 44;
    lCode_dereleve  := 45;
    l_authorisation_no  := 46;
    l_authorisation_tag := 47;
    l_sequence_no       := 48;
    l_mag_asg_action_id := to_number(pay_magtape_generic.get_parameter_value
                                                 ('TRANSFER_ACT_ID'));
    l_transfer_pay_actid := to_number(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'));

    open c_get_report_type(l_transfer_pay_actid);
    fetch c_get_report_type
    into  l_rep_type,
          l_business_group_id,
          l_legislative_parameters;
    close c_get_report_type;

    if l_rep_type = 'RL2PAPERPDF' then
       open c_get_payroll_asg_actid(l_mag_asg_action_id);
       fetch c_get_payroll_asg_actid
       into  l_rl2pap_asg_actid,
             l_rl2pap_pay_actid,
             l_asg_id;
       close c_get_payroll_asg_actid;

       hr_utility.trace('The value of Payroll action id is '||l_rl2pap_pay_actid);
       hr_utility.trace('The value of Assignment action id is '||l_rl2pap_asg_actid);
       hr_utility.trace('The value of Assignment id is '||l_asg_id);

       OPEN c_get_employer_info(l_rl2pap_pay_actid,l_business_group_id);
       FETCH  c_get_employer_info
       INTO   l_empr_name  ,
              l_empr_quebec_no  ,
              l_empr_report_yr ,
              l_empr_addr1  ,
              l_empr_addr2 ,
              l_empr_addr3,
              l_empr_city ,
              l_empr_prov ,
              l_empr_country,
              l_empr_postcode;
       CLOSE  c_get_employer_info;

           l_counter :=  l_counter + 1;
           IF l_empr_name IS NOT NULL AND
              l_empr_name <> '                              ' THEN
              tab_emplyr(l_counter)  :='<Nom>'|| convert_special_char(substr(l_empr_name,1,30))||'</Nom>'||EOL;
              tab_emplyr1(l_counter) :='<Nom1>'|| convert_special_char(substr(l_empr_name,1,30))||'</Nom1>'||EOL;
              tab_emplyr2(l_counter) :='<Nom2>'|| convert_special_char(substr(l_empr_name,1,30))||'</Nom2>'||EOL;
           ELSE
              tab_emplyr(l_counter) := NULL;
              tab_emplyr1(l_counter) := NULL;
              tab_emplyr2(l_counter) := NULL;
           END IF;

           l_counter :=  l_counter + 1;
           IF l_empr_quebec_no IS NOT NULL AND
              l_empr_quebec_no <> '0000000000  0000'  THEN
              tab_emplyr(l_counter)  :='<NoDossier>'|| convert_special_char(substr(l_empr_quebec_no,1,30))||'</NoDossier>'||EOL;
              tab_emplyr1(l_counter) :='<NoDossier1>'|| convert_special_char(substr(l_empr_quebec_no,1,30))||'</NoDossier1>'||
EOL;
              tab_emplyr2(l_counter) :='<NoDossier2>'|| convert_special_char(substr(l_empr_quebec_no,1,30))||'</NoDossier2>'||
EOL;
           ELSE
              tab_emplyr(l_counter)  := NULL;
              tab_emplyr1(l_counter) := NULL;
              tab_emplyr2(l_counter) := NULL;
           END IF;

           l_counter :=  l_counter + 1;
           IF l_empr_report_yr IS NOT NULL AND
              l_empr_report_yr <> '0000' THEN
              tab_emplyr(l_counter) :='<AnneeEmplyr>'|| convert_special_char(substr(l_empr_report_yr,1,30))||'</AnneeEmplyr>'||EOL;
              tab_emplyr1(l_counter) :='<AnneeEmplyr1>'|| convert_special_char(substr(l_empr_report_yr,1,30))||'</AnneeEmplyr1>'||EOL;
              tab_emplyr2(l_counter) :='<AnneeEmplyr2>'|| convert_special_char(substr(l_empr_report_yr,1,30))||'</AnneeEmplyr2>'||EOL;

           ELSE
              tab_emplyr(l_counter)  := NULL;
              tab_emplyr1(l_counter) := NULL;
              tab_emplyr2(l_counter) := NULL;
           END IF;

           l_counter :=  l_counter + 1;
           IF l_empr_addr1 IS NOT NULL AND
              l_empr_addr1 <> '                              '  THEN
              tab_emplyr(l_counter)  :='<Ligne1Emplyr>'|| convert_special_char(substr(l_empr_addr1,1,30))||'</Ligne1Emplyr>'||EOL;
              tab_emplyr1(l_counter) :='<Ligne1Emplyr1>'|| convert_special_char(substr(l_empr_addr1,1,30))||'</Ligne1Emplyr1>'||EOL;
              tab_emplyr2(l_counter) :='<Ligne1Emplyr2>'|| convert_special_char(substr(l_empr_addr1,1,30))||'</Ligne1Emplyr2>'||EOL;
           ELSE
              tab_emplyr(l_counter)  := NULL;
              tab_emplyr1(l_counter) := NULL;
              tab_emplyr2(l_counter) := NULL;
           END IF;

            l_counter :=  l_counter + 1;
           IF (l_empr_addr2 IS NOT NULL AND
               l_empr_addr2 <> '                              ') OR
               (l_empr_addr3 IS NOT NULL AND
               l_empr_addr3 <> '                              ')  THEN
              tab_emplyr(l_counter)  :='<Ligne2Emplyr>'||
                                        convert_special_char(substr(ltrim(rtrim(l_empr_addr2))||' '||
                                        (ltrim(rtrim(l_empr_addr3))),1,30))||'</Ligne2Emplyr>'||EOL;
              tab_emplyr1(l_counter) :='<Ligne2Emplyr1>'|| convert_special_char(substr(ltrim(rtrim(l_empr_addr2))||' '||
                                        (ltrim(rtrim(l_empr_addr3))),1,30))||'</Ligne2Emplyr1>'||EOL;
              tab_emplyr2(l_counter) :='<Ligne2Emplyr2>'|| convert_special_char(substr(ltrim(rtrim(l_empr_addr2))||' '||
                                        (ltrim(rtrim(l_empr_addr3))),1,30))||'</Ligne2Emplyr2>'||EOL;
           ELSE
              tab_emplyr(l_counter)  := NULL;
              tab_emplyr1(l_counter) := NULL;
              tab_emplyr2(l_counter) := NULL;
           END IF;

            l_counter :=  l_counter + 1;
            l_empr_fulladdr := l_empr_city ||' '||l_empr_prov||' '
                                           ||l_empr_country||' '||(substr(l_empr_postcode,1,3)||' '||
                                                                   substr(l_empr_postcode,4,3));
           IF l_empr_fulladdr IS NOT NULL AND
              l_empr_city <> '                              ' AND
              tab_emplyr(l_counter-1) IS NOT NULL THEN

              tab_emplyr(l_counter) :='<VilleEmplyr>'|| convert_special_char(substr(l_empr_fulladdr,1,60))||
                                      '</VilleEmplyr>'||EOL;
              tab_emplyr1(l_counter) :='<VilleEmplyr1>'|| convert_special_char(substr(l_empr_fulladdr,1,60))||
                                       '</VilleEmplyr1>'||EOL;
              tab_emplyr2(l_counter) :='<VilleEmplyr2>'|| convert_special_char(substr(l_empr_fulladdr,1,60))||
                                       '</VilleEmplyr2>'||EOL;

           ELSIF l_empr_fulladdr IS NOT NULL AND
              l_empr_city <> '                              ' AND
              tab_emplyr(l_counter-1) IS NULL THEN
              tab_emplyr(l_counter)  :='<Ligne2Emplyr>'||convert_special_char(substr(l_empr_fulladdr,1,60))||
                                       '</Ligne2Emplyr>'||EOL;
              tab_emplyr1(l_counter) :='<Ligne2Emplyr1>'||convert_special_char(substr(l_empr_fulladdr,1,60))||
                                       '</Ligne2Emplyr1>'||EOL;
              tab_emplyr2(l_counter) :='<Ligne2Emplyr2>'||convert_special_char(substr(l_empr_fulladdr,1,60))||
                                       '</Ligne2Emplyr2>'||EOL;
           ELSE
              tab_emplyr(l_counter) := NULL;
              tab_emplyr1(l_counter) := NULL;
              tab_emplyr2(l_counter) := NULL;
           END IF;

    end if;
    hr_utility.trace('XML Employee: l_mag_asg_action_id = '
                                  || to_char(l_mag_asg_action_id));
    hr_utility.trace('XML Employee: Transfer Payroll Action Id '||to_number(pay_magtape_generic.get_parameter_value
                                                                         ('TRANSFER_PAYROLL_ACTION_ID')));
   IF l_rep_type <> 'RL2PAPERPDF' THEN
    OPEN cur_parameters(l_mag_asg_action_id);
    FETCH cur_parameters
    INTO
      l_arch_action_id,
      l_asg_id,
      l_date_earned;
    CLOSE cur_parameters;
   ELSE
     l_arch_action_id := l_rl2pap_asg_actid;
   END IF;

    hr_utility.trace('XML Employee: l_arch_action_id = '
                                  || to_char(l_arch_action_id));
    hr_utility.trace('XML Employee: l_asg_id = ' || to_char(l_asg_id));
    hr_utility.trace('XML Employee: l_date_earned = '
                                  || to_char(l_date_earned));
    hr_utility.trace('XML Employee: l_province = ' || l_province);

   if l_rep_type = 'RL2PAPERPDF' then
    l_taxation_year
        := pay_ca_rl2_mag.get_parameter('TAX_YEAR',
                                        l_legislative_parameters);
   else
     l_taxation_year := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');
   end if;

    --Annee
    tab_employee(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' || EOL;
    if l_rep_type = 'RL2PAPERPDF' then
       tab_employee1(lAnnee) := '<Annee1>' || l_taxation_year || '</Annee1>' || EOL;
       tab_employee2(lAnnee) := '<Annee2>' || l_taxation_year || '</Annee2>' || EOL;
    end if;

    /* Added by ssmukher to remove frequent function call to fetch the employee info */
    open c_employee_infor(l_arch_action_id);
    fetch c_employee_infor
    into  l_quebec_business_number,
          l_reporting_year,
          l_rl2_slip_number,
          l_employee_sin,
          l_employee_last_name,
          l_employee_first_name,
          l_employee_middle_initial,
          l_employee_address_line1,
          l_employee_address_line2,
          l_employee_address_line3,
          l_employee_city,
          l_employee_province,
          l_employee_postal_code,
          l_employee_number,
          l_rl2_box_a,
          l_rl2_box_b,
          l_rl2_box_c,
          l_rl2_box_d,
          l_rl2_box_e,
          l_rl2_box_f,
          l_rl2_box_g,
          l_rl2_box_h,
          l_rl2_box_i,
          l_rl2_box_j,
          l_rl2_box_k,
          l_rl2_box_l,
          l_rl2_box_m,
          l_rl2_box_n,
          l_rl2_box_o,
          l_rl2_source_of_income,
          l_negative_balance_flag,
          l_per_id;

     CLOSE c_employee_infor;

    IF l_rep_type = 'RL2PAPERPDF' THEN

      /* IF (l_reporting_year = '2006' ) then
          l_authorization_code := 'FS-06-02-003';
       ELSIF (l_reporting_year = '2007' ) then
          l_authorization_code := 'FS-07-02-068';  --Bug 6747924
       ELSIF (l_reporting_year = '2008' ) then
          l_authorization_code := 'FS-08-02-011';  --Bug 7503515
       END IF;   */

      open c_get_auth_code(l_reporting_year);
      fetch c_get_auth_code into l_authorization_code;
      close c_get_auth_code;

      tab_employee(l_authorisation_tag) := '<TagCertification>'||
                               convert_special_char('No d''autorisation :')||
                               '</TagCertification>';
      tab_employee(l_authorisation_no) := '<NoCertification>'||convert_special_char(l_authorization_code)
                                           ||'</NoCertification>';
      tab_employee1(l_authorisation_tag) := '<TagCertification1>'||
                               convert_special_char('No d''autorisation :')||
                               '</TagCertification1>';
      tab_employee1(l_authorisation_no) := '<NoCertification1>'||convert_special_char(l_authorization_code)
                                           || '</NoCertification1>';
      tab_employee2(l_authorisation_tag) := '<TagCertification2>'||
                               convert_special_char('No d''autorisation :')||
                               '</TagCertification2>';
      tab_employee2(l_authorisation_no) := '<NoCertification2>'||convert_special_char(l_authorization_code)
                                           || '</NoCertification2>';

      --select pay_ca_rl2_pdf_seq_s.nextval into l_seq_num from dual;

      l_seq_num := pay_ca_eoy_rl2_archive.gen_rl2_pdf_seq(l_rl2pap_asg_actid, --Bug 6768167
                                                          l_reporting_year,
                                                          'XMLPROC');

      tab_employee(l_sequence_no) := '<SequenceNum>'||l_seq_num
                                      ||'</SequenceNum>';
      tab_employee1(l_sequence_no) := '<SequenceNum1>'||l_seq_num
                                      ||'</SequenceNum1>';
      tab_employee2(l_sequence_no) := '<SequenceNum2>'||l_seq_num
                                      ||'</SequenceNum2>';
    END IF;

    --NoReleve
   /* Check for Mandatory Information RL-2 Slip Number missing */

    IF ( l_rl2_slip_number = '000000000' AND
         l_rl2_slip_number IS NOT NULL)  THEN
      l_status := 'Failed';
      l_msg_code := 'MISSING_SLIP_NO';
      tab_employee(lNoReleve) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lNoReleve) := NULL;
          tab_employee2(lNoReleve) := NULL;
      end if;
    ELSE
      tab_employee(lNoReleve) := '<NoReleve>' || convert_special_char(l_rl2_slip_number) ||
                        '</NoReleve>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
        tab_employee1(lNoReleve) := '<NoReleve1>' || convert_special_char(l_rl2_slip_number) ||
                        '</NoReleve1>' || EOL;
        tab_employee2(lNoReleve) := '<NoReleve2>' || convert_special_char(l_rl2_slip_number) ||
                        '</NoReleve2>' || EOL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lNoReleve) = ' || tab_employee(lNoReleve));

    -- NAS
   /* Bug Fix 4754891 */
    IF (l_employee_sin IS NOT NULL AND
        l_employee_sin <> '000000000')  THEN

      IF l_rep_type <> 'RL2PAPERPDF' THEN
         tab_employee(lNAS) := '<NAS>' || convert_special_char(l_employee_sin) || '</NAS>' || EOL;
      ELSE
         tab_employee(lNAS1) := '<NAS1>' || convert_special_char(substr(l_employee_sin,1,3)) || '</NAS1>' || EOL;
         tab_employee(lNAS2) := '<NAS2>' || convert_special_char(substr(l_employee_sin,4,3)) || '</NAS2>' || EOL;
         tab_employee(lNAS3) := '<NAS3>' || convert_special_char(substr(l_employee_sin,7,3)) || '</NAS3>' || EOL;

	 tab_employee1(lNAS1) := '<NAS21>' || convert_special_char(substr(l_employee_sin,1,3)) || '</NAS21>' || EOL;
         tab_employee1(lNAS2) := '<NAS22>' || convert_special_char(substr(l_employee_sin,4,3)) || '</NAS22>' || EOL;
         tab_employee1(lNAS3) := '<NAS23>' || convert_special_char(substr(l_employee_sin,7,3)) || '</NAS23>' || EOL;

	 tab_employee2(lNAS1) := '<NAS31>' || convert_special_char(substr(l_employee_sin,1,3)) || '</NAS31>' || EOL;
         tab_employee2(lNAS2) := '<NAS32>' || convert_special_char(substr(l_employee_sin,4,3)) || '</NAS32>' || EOL;
         tab_employee2(lNAS3) := '<NAS33>' || convert_special_char(substr(l_employee_sin,7,3)) || '</NAS33>' || EOL;

       END IF;
    ELSE
      l_status := 'Failed';
      l_msg_code := 'SIN';
      tab_employee(lNAS) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then

         tab_employee(lNAS1) := NULL;
         tab_employee(lNAS2) := NULL;
         tab_employee(lNAS3) := NULL;

         tab_employee1(lNAS1) := NULL;
         tab_employee1(lNAS2) := NULL;
         tab_employee1(lNAS3) := NULL;

         tab_employee2(lNAS1) := NULL;
         tab_employee2(lNAS2) := NULL;
         tab_employee2(lNAS3) := NULL;

      end if;
    END IF;
   -- hr_utility.trace('tab_employee(lNAS) = ' || tab_employee(lNAS));

    -- No
    IF (l_employee_number IS NOT NULL AND
        l_employee_number <> '                    ' )  THEN
      tab_employee(lNo) := '<No>' || convert_special_char(l_employee_number) || '</No>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lNo) := '<No1>' || convert_special_char(l_employee_number) || '</No1>' || EOL;
         tab_employee2(lNo) := '<No2>' || convert_special_char(l_employee_number) || '</No2>' || EOL;
      end if;
    ELSE
      tab_employee(lNo) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lNo) := NULL;
         tab_employee2(lNo) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lNo) = ' || tab_employee(lNo));

    -- NomFamille

    tab_employee(lNomFamille) := '<NomFamille>' ||
                        convert_special_char(substr(l_employee_last_name,1,30)) || '</NomFamille>' || EOL;
    hr_utility.trace('tab_employee(lNomFamille) = ' || tab_employee(lNomFamille));

    l_full_empname := convert_special_char(substr(l_employee_last_name,1,30));

    -- Prenom
    IF (l_employee_first_name is NOT NULL AND
        l_employee_first_name <> '                              ')  THEN
      tab_employee(lPrenom) := '<Prenom>' || convert_special_char(substr(l_employee_first_name,1,30))
                                          || '</Prenom>' || EOL;
      l_full_empname := l_full_empname ||','||convert_special_char(substr(l_employee_first_name,1,30));
    ELSE
      l_msg_code := 'MISSING_EMP_FIRST_NAME';
      l_status := 'Failed';
      tab_employee(lPrenom) := NULL;
    END IF;
    hr_utility.trace('tab_employee(lPrenom) = ' || tab_employee(lPrenom));

    -- Initiale

    IF (l_employee_middle_initial is NOT NULL AND
        l_employee_middle_initial <> ' ') THEN
      tab_employee(lInitiale) := '<Initiale>' || convert_special_char(substr(l_employee_middle_initial,1,1))
                                              || '</Initiale>' || EOL;
      l_full_empname := l_full_empname ||' '||convert_special_char(substr(l_employee_middle_initial,1,1));
    ELSE
      tab_employee(lInitiale) := NULL;
    END IF;

    if l_rep_type = 'RL2PAPERPDF' then
      tab_employee(lNomFamille)  := '<NomFamille>' ||l_full_empname || '</NomFamille>' || EOL;
      tab_employee1(lNomFamille) := '<NomFamille1>' ||l_full_empname || '</NomFamille1>' || EOL;
      tab_employee2(lNomFamille) := '<NomFamille2>' ||l_full_empname || '</NomFamille2>' || EOL;
    end if;

    hr_utility.trace('tab_employee(lInitiale) = ' || tab_employee(lInitiale));

    l_person_id := to_number(l_per_id);

   l_return := pay_ca_emp_address_dtls.get_emp_address(
                    l_person_id,
                    l_address_line1,
                    l_address_line2,
                    l_address_line3,
                    l_city,
                    l_postal_code,
                    l_country,
                    l_emp_province
                    );
    -- If Address line 1 is NULL or ' ' then the employee is missing
    -- address information - as line 1 is mandatory in the Address form.
    -- Need to check data by SS transaction /API.

      hr_utility.trace('l_person_id = ' || to_char(l_person_id));
      hr_utility.trace('l_address_line1 = ' || l_address_line1);
      hr_utility.trace('l_address_line2 = ' || l_address_line2);
      hr_utility.trace('l_postal_code = ' || l_postal_code);

  /* Bug Fix 4761782 */
    -- Address Line 1
    IF l_address_line1 IS NOT NULL AND
       l_address_line1 = ' '  THEN

       l_status := 'Failed';
       l_msg_code := 'MISSING_EMP_ADDRESS';

       l_addr_begin_tag          := NULL;
       tab_employee(lLigne1)     := NULL;
       tab_employee(lLigne2)     := NULL;
       tab_employee(lVille)      := NULL;
       tab_employee(lProvince)   := NULL;
       tab_employee(lCodePostal) := NULL;
       l_addr_end_tag            := NULL;
       if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lLigne1)     := NULL;
          tab_employee1(lLigne2)     := NULL;

          tab_employee2(lLigne1)     := NULL;
          tab_employee2(lLigne2)     := NULL;

       end if;
    ELSE

      l_addr_begin_tag := '<Adresse>';

      tab_employee(lLigne1) := '<Ligne1>' ||
                  convert_special_char(substr(l_address_line1,1,30)) || '</Ligne1>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lLigne1) := '<Ligne11>' ||
                  convert_special_char(substr(l_address_line1,1,30)) || '</Ligne11>' || EOL;
         tab_employee2(lLigne1) := '<Ligne12>' ||
                  convert_special_char(substr(l_address_line1,1,30)) || '</Ligne12>' || EOL;
      end if;
      hr_utility.trace('tab_employee(lLigne1) = ' || tab_employee(lLigne1));

      -- Address Line 2

      IF ((l_address_line2 IS NOT NULL AND
           l_address_line2 <> ' ' ) OR
          (l_address_line3 IS NOT NULL AND
           l_address_line3 <> ' ') ) THEN
        l_combined_addr := rtrim(ltrim(l_address_line2)) || rtrim(ltrim(l_address_line3));
        tab_employee(lLigne2) := '<Ligne2>' ||
                  convert_special_char(substr(l_combined_addr,1,30)) || '</Ligne2>' || EOL;
        if l_rep_type = 'RL2PAPERPDF' and  l_combined_addr is not null  then
               tab_employee1(lLigne2) := '<Ligne21>' ||
                  convert_special_char(substr(l_combined_addr,1,30)) || '</Ligne21>' || EOL;
               tab_employee2(lLigne2) := '<Ligne22>' ||
                  convert_special_char(substr(l_combined_addr,1,30)) || '</Ligne22>' || EOL;
        end if;
      ELSE
        IF l_rep_type <> 'RL2PAPERPDF' THEN
           tab_employee(lLigne2) := NULL;
        ELSE
             tab_employee(lVille)  := NULL;
             tab_employee1(lVille) := NULL;
             tab_employee2(lVille) := NULL;
        END IF;
      END IF;
      --hr_utility.trace('tab_employee(lLigne2) = ' || tab_employee(lLigne2));

      -- Ville (City)
      IF l_city IS NOT NULL AND
         l_city <> ' ' THEN
        tab_employee(lVille) := '<Ville>' ||
                  convert_special_char(substr(l_city,1,30)) || '</Ville>' || EOL;
        l_full_empaddr := convert_special_char(substr(l_city,1,30));

      ELSE
        tab_employee(lVille) := NULL;

      END IF;
      --hr_utility.trace('tab_employee(lVille) = ' || tab_employee(lVille));

      -- Province
      IF l_emp_province IS NOT NULL AND
         l_emp_province <> ' '  THEN

         IF l_country = 'CA' THEN
             tab_employee(lProvince) := '<Province>' ||
                                         convert_special_char(SUBSTR(hr_general.decode_lookup(
                                        'CA_PROVINCE',l_emp_province),1,20)) || '</Province>' || EOL;
             l_full_empaddr := l_full_empaddr ||' '||convert_special_char(l_emp_province);


         ELSIF l_country = 'US' THEN
             tab_employee(lProvince) := '<Province>' ||l_emp_province || '</Province>' || EOL;
             l_full_empaddr := l_full_empaddr ||' '||l_emp_province;

         ELSE
              tab_employee(lProvince) := '<Province>' ||l_country|| '</Province>' || EOL;
              l_full_empaddr := l_full_empaddr ||' '||l_country;

         END IF;
      ELSE
        tab_employee(lProvince) := NULL;

      END IF;
      hr_utility.trace('tab_employee(lProvince) = ' || tab_employee(lProvince));

    -- Bug# 4754743 fix
    -- Postal Code
    IF l_postal_code IS NOT NULL AND
       l_postal_code <> ' '  THEN
      tab_employee(lCodePostal) := '<CodePostal>' ||
             convert_special_char(substr(replace(l_postal_code,' '),1,6)) || '</CodePostal>' || EOL;
      l_full_empaddr := l_full_empaddr ||' '||convert_special_char(substr(replace(l_country,' '),1,6))||' '||
                                              convert_special_char(l_postal_code);

    ELSE
      tab_employee(lCodePostal) := NULL;
    END IF;

    hr_utility.trace('tab_employee(lCodePostal) = ' || tab_employee(lCodePostal));
    l_addr_end_tag := '</Adresse>';

    END IF;

    if l_rep_type = 'RL2PAPERPDF' then
         IF ((l_full_empaddr IS NOT NULL AND
             l_full_empaddr <> ' ') AND
            ((l_address_line2 IS NOT NULL AND
           l_address_line2 <> ' ' ) OR
          (l_address_line3 IS NOT NULL AND
           l_address_line3 <> ' ') ))  THEN

           tab_employee(lVille)  := '<Ville>' ||l_full_empaddr || '</Ville>' || EOL;
           tab_employee1(lVille) := '<Ville1>' ||l_full_empaddr || '</Ville1>' || EOL;
           tab_employee2(lVille) := '<Ville2>' ||l_full_empaddr || '</Ville2>' || EOL;

         ELSIF l_full_empaddr IS NOT NULL AND
               (l_postal_code IS NOT NULL OR
                l_city IS NOT NULL OR
                l_emp_province IS NOT NULL)  THEN

            tab_employee(lVille)  := NULL;
            tab_employee1(lVille) := NULL;
            tab_employee2(lVille) := NULL;

            tab_employee(lLigne2) := '<Ligne2>' ||l_full_empaddr || '</Ligne2>' || EOL;
            tab_employee1(lLigne2) := '<Ligne21>' ||l_full_empaddr || '</Ligne21>' || EOL;
            tab_employee2(lLigne2) := '<Ligne22>' ||l_full_empaddr || '</Ligne22>' || EOL;

         ELSE

            tab_employee(lVille)  := NULL;
            tab_employee1(lVille) := NULL;
            tab_employee2(lVille) := NULL;
            tab_employee(lLigne2) := NULL;
            tab_employee1(lLigne2) := NULL;
            tab_employee2(lLigne2) := NULL;

         END IF;

    end if;

    -- Summ (Box A)

    hr_utility.trace('The Value of Box A is '|| l_rl2_box_a);
    IF TO_NUMBER(l_rl2_box_a) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_a IS NOT NULL AND
       to_number(l_rl2_box_a) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_a),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;
      tab_employee(lA_PrestRPA_RPNA) := '<A_PrestRPA_RPNA>' || l_formatted_box ||
                                     '</A_PrestRPA_RPNA>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lA_PrestRPA_RPNA) := '<A_PrestRPA_RPNA1>' || l_formatted_box ||
                                     '</A_PrestRPA_RPNA1>' || EOL;
         tab_employee2(lA_PrestRPA_RPNA) := '<A_PrestRPA_RPNA2>' || l_formatted_box ||
                                     '</A_PrestRPA_RPNA2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lA_PrestRPA_RPNA ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lA_PrestRPA_RPNA ) := NULL;
         tab_employee2(lA_PrestRPA_RPNA ) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lA_PrestRPA_RPNA) = ' ||
                                     tab_employee(lA_PrestRPA_RPNA));

    -- Summ (Box B)

    IF TO_NUMBER(l_rl2_box_b) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_b IS NOT NULL AND
       to_number(l_rl2_box_b) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_b),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lB_PrestREER_FERR_RPDB) := '<B_PrestREER_FERR_RPDB>' || l_formatted_box
                                        || '</B_PrestREER_FERR_RPDB>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lB_PrestREER_FERR_RPDB) := '<B_PrestREER_FERR_RPDB1>' || l_formatted_box
                                        || '</B_PrestREER_FERR_RPDB1>' || EOL;
           tab_employee2(lB_PrestREER_FERR_RPDB) := '<B_PrestREER_FERR_RPDB2>' || l_formatted_box
                                        || '</B_PrestREER_FERR_RPDB2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE

      tab_employee(lB_PrestREER_FERR_RPDB) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lB_PrestREER_FERR_RPDB) := NULL;
          tab_employee2(lB_PrestREER_FERR_RPDB) := NULL;
      end if;

    END IF;
    hr_utility.trace('tab_employee(lB_PrestREER_FERR_RPDB) = ' ||
                                   tab_employee(lB_PrestREER_FERR_RPDB));

    -- Summ (Box C)

    IF TO_NUMBER(l_rl2_box_c) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_c IS NOT NULL AND
       to_number(l_rl2_box_c) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_c),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lC_AutrePaiement ) := '<C_AutrePaiement>' ||
                         l_formatted_box || '</C_AutrePaiement>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lC_AutrePaiement ) := '<C_AutrePaiement1>' ||
                         l_formatted_box || '</C_AutrePaiement1>' || EOL;
          tab_employee2(lC_AutrePaiement ) := '<C_AutrePaiement2>' ||
                         l_formatted_box || '</C_AutrePaiement2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lC_AutrePaiement ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lC_AutrePaiement ) := NULL;
          tab_employee2(lC_AutrePaiement ) := NULL;
      end if;
    END IF;

    hr_utility.trace('tab_employee(lC_AutrePaiement ) = ' ||
                         tab_employee(lC_AutrePaiement ));

    -- Summ (Box D)

    IF TO_NUMBER(l_rl2_box_d) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_d IS NOT NULL AND
       to_number(l_rl2_box_d) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_d),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lD_RembPrimeConjoint) := '<D_RembPrimeConjoint>' ||
                         l_formatted_box || '</D_RembPrimeConjoint>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lD_RembPrimeConjoint) := '<D_RembPrimeConjoint1>' ||
                         l_formatted_box || '</D_RembPrimeConjoint1>' || EOL;
           tab_employee2(lD_RembPrimeConjoint) := '<D_RembPrimeConjoint2>' ||
                         l_formatted_box || '</D_RembPrimeConjoint2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lD_RembPrimeConjoint) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lD_RembPrimeConjoint) := NULL;
          tab_employee2(lD_RembPrimeConjoint) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lD_RembPrimeConjoint) = ' ||
                         tab_employee(lD_RembPrimeConjoint));

    -- (Box E)

    IF TO_NUMBER(l_rl2_box_e) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_e IS NOT NULL AND
       to_number(l_rl2_box_e) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_e),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lE_PrestDeces) := '<E_PrestDeces>' ||
                         l_formatted_box || '</E_PrestDeces>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lE_PrestDeces) := '<E_PrestDeces1>' ||
                         l_formatted_box || '</E_PrestDeces1>' || EOL;
          tab_employee2(lE_PrestDeces) := '<E_PrestDeces2>' ||
                         l_formatted_box || '</E_PrestDeces2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lE_PrestDeces) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lE_PrestDeces) := NULL;
         tab_employee2(lE_PrestDeces) := NULL;
      end if;
    END IF;

    hr_utility.trace('tab_employee(lE_PrestDeces) = ' ||
                         tab_employee(lE_PrestDeces));

    -- (Box F)

    IF TO_NUMBER(l_rl2_box_f) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_f IS NOT NULL AND
       to_number(l_rl2_box_f) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_f),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lF_RembCotisInutilise) := '<F_RembCotisInutilise>' ||
                         l_formatted_box || '</F_RembCotisInutilise>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lF_RembCotisInutilise) := '<F_RembCotisInutilise1>' ||
                         l_formatted_box || '</F_RembCotisInutilise1>' || EOL;
         tab_employee2(lF_RembCotisInutilise) := '<F_RembCotisInutilise2>' ||
                         l_formatted_box || '</F_RembCotisInutilise2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lF_RembCotisInutilise) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
        tab_employee1(lF_RembCotisInutilise) := NULL;
        tab_employee2(lF_RembCotisInutilise) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lF_RembCotisInutilise) = ' ||
                         tab_employee(lF_RembCotisInutilise));

    -- (Box G)

    IF TO_NUMBER(l_rl2_box_g) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_g IS NOT NULL AND
       to_number(l_rl2_box_g) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_g),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lG_RevocationREER_FERR ) := '<G_RevocationREER_FERR>' ||
                         l_formatted_box || '</G_RevocationREER_FERR>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lG_RevocationREER_FERR ) := '<G_RevocationREER_FERR1>' ||
                         l_formatted_box || '</G_RevocationREER_FERR1>' || EOL;
         tab_employee2(lG_RevocationREER_FERR ) := '<G_RevocationREER_FERR2>' ||
                         l_formatted_box || '</G_RevocationREER_FERR2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lG_RevocationREER_FERR) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lG_RevocationREER_FERR) := NULL;
           tab_employee2(lG_RevocationREER_FERR) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lG_RevocationREER_FERR) = ' ||
                         tab_employee(lG_RevocationREER_FERR));

    -- (Box H)

    IF TO_NUMBER(l_rl2_box_h) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_h IS NOT NULL AND
       to_number(l_rl2_box_h) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_h),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lH_AutreRevenu) := '<H_AutreRevenu>' ||
                         l_formatted_box || '</H_AutreRevenu>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lH_AutreRevenu) := '<H_AutreRevenu1>' ||
                         l_formatted_box || '</H_AutreRevenu1>' || EOL;
         tab_employee2(lH_AutreRevenu) := '<H_AutreRevenu2>' ||
                         l_formatted_box || '</H_AutreRevenu2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lH_AutreRevenu) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lH_AutreRevenu) := NULL;
          tab_employee2(lH_AutreRevenu) := NULL;
      end if;
    END IF;

    hr_utility.trace('tab_employee(lH_AutreRevenu ) = ' ||
                         tab_employee(lH_AutreRevenu ));

    -- (Box I)

    IF TO_NUMBER(l_rl2_box_i) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_i IS NOT NULL AND
       to_number(l_rl2_box_i) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_i),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lI_DroitDeduction ) := '<I_DroitDeduction>' ||
                         l_formatted_box || '</I_DroitDeduction>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lI_DroitDeduction ) := '<I_DroitDeduction1>' ||
                         l_formatted_box || '</I_DroitDeduction1>' || EOL;
          tab_employee2(lI_DroitDeduction ) := '<I_DroitDeduction2>' ||
                         l_formatted_box || '</I_DroitDeduction2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lI_DroitDeduction ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lI_DroitDeduction ) := NULL;
          tab_employee2(lI_DroitDeduction ) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lI_DroitDeduction ) = ' ||
                         tab_employee(lI_DroitDeduction ));

    -- (Box J)

    IF TO_NUMBER(l_rl2_box_j) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_j IS NOT NULL AND
       to_number(l_rl2_box_j) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_j),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lJ_ImpotQueRetenuSource ) := '<J_ImpotQueRetenuSource>' ||
                         l_formatted_box || '</J_ImpotQueRetenuSource>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lJ_ImpotQueRetenuSource ) := '<J_ImpotQueRetenuSource1>' ||
                         l_formatted_box || '</J_ImpotQueRetenuSource1>' || EOL;
           tab_employee2(lJ_ImpotQueRetenuSource ) := '<J_ImpotQueRetenuSource2>' ||
                         l_formatted_box || '</J_ImpotQueRetenuSource2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lJ_ImpotQueRetenuSource ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lJ_ImpotQueRetenuSource ) := NULL;
         tab_employee2(lJ_ImpotQueRetenuSource ) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lJ_ImpotQueRetenuSource ) = ' ||
                         tab_employee(lJ_ImpotQueRetenuSource ));

    -- (Box K)

    IF TO_NUMBER(l_rl2_box_k) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_k IS NOT NULL AND
       to_number(l_rl2_box_k) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_k),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lK_RevenuApresDeces ) := '<K_RevenuApresDeces>' ||
                         l_formatted_box || '</K_RevenuApresDeces>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lK_RevenuApresDeces ) := '<K_RevenuApresDeces1>' ||
                         l_formatted_box || '</K_RevenuApresDeces1>' || EOL;
           tab_employee2(lK_RevenuApresDeces ) := '<K_RevenuApresDeces2>' ||
                         l_formatted_box || '</K_RevenuApresDeces2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lK_RevenuApresDeces ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lK_RevenuApresDeces ) := NULL;
           tab_employee2(lK_RevenuApresDeces ) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lK_RevenuApresDeces ) = ' ||
                         tab_employee(lK_RevenuApresDeces ));

    -- (Box L)

    IF TO_NUMBER(l_rl2_box_l) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_l IS NOT NULL AND
       to_number(l_rl2_box_l) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_l),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lL_RetraitREEP ) := '<L_RetraitREEP>' ||
                         l_formatted_box || '</L_RetraitREEP>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lL_RetraitREEP ) := '<L_RetraitREEP1>' ||
                         l_formatted_box || '</L_RetraitREEP1>' || EOL;
          tab_employee2(lL_RetraitREEP ) := '<L_RetraitREEP2>' ||
                         l_formatted_box || '</L_RetraitREEP2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lL_RetraitREEP ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
        tab_employee1(lL_RetraitREEP ) := NULL;
        tab_employee2(lL_RetraitREEP ) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lL_RetraitREEP ) = ' ||
                         tab_employee(lL_RetraitREEP ));

    -- (Box M)

    IF TO_NUMBER(l_rl2_box_m) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_m IS NOT NULL AND
       to_number(l_rl2_box_m) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_m),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lM_LibereImpot) := '<M_LibereImpot>' ||
                         l_formatted_box || '</M_LibereImpot>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lM_LibereImpot) := '<M_LibereImpot1>' ||
                         l_formatted_box || '</M_LibereImpot1>' || EOL;
         tab_employee2(lM_LibereImpot) := '<M_LibereImpot2>' ||
                         l_formatted_box || '</M_LibereImpot2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lM_LibereImpot) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
         tab_employee1(lM_LibereImpot) := NULL;
         tab_employee2(lM_LibereImpot) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lM_LibereImpot) = ' ||
                         tab_employee(lM_LibereImpot));

    -- (Box N)
    -- Bug 5569097 Fix.

    IF l_rl2_box_n IS NOT NULL THEN

      if l_rep_type <> 'RL2PAPERPDF' then

           tab_employee(lN_NASConjoint) := '<N_NASConjoint>' ||
                         l_rl2_box_n || '</N_NASConjoint>' || EOL;
      else
          tab_employee(lN_NASConjoint) := '<N_NASConjoint1>' ||
                         substr(l_rl2_box_n,1,3) || '</N_NASConjoint1>' || EOL;
          tab_employee(lN_NASConjoint1) := '<N_NASConjoint2>' ||
                         substr(l_rl2_box_n,4,3) || '</N_NASConjoint2>' || EOL;
          tab_employee(lN_NASConjoint2) := '<N_NASConjoint3>' ||
                         substr(l_rl2_box_n,7,3) || '</N_NASConjoint3>' || EOL;
          tab_employee1(lN_NASConjoint) := '<N_NASConjoint21>' ||
                         substr(l_rl2_box_n,1,3) || '</N_NASConjoint21>' || EOL;
          tab_employee1(lN_NASConjoint1) := '<N_NASConjoint22>' ||
                         substr(l_rl2_box_n,4,3) || '</N_NASConjoint22>' || EOL;
          tab_employee1(lN_NASConjoint2) := '<N_NASConjoint23>' ||
                         substr(l_rl2_box_n,7,3) || '</N_NASConjoint23>' || EOL;
          tab_employee2(lN_NASConjoint) := '<N_NASConjoint31>' ||
                         substr(l_rl2_box_n,1,3) || '</N_NASConjoint31>' || EOL;
          tab_employee2(lN_NASConjoint1) := '<N_NASConjoint32>' ||
                         substr(l_rl2_box_n,4,3) || '</N_NASConjoint32>' || EOL;
          tab_employee2(lN_NASConjoint2) := '<N_NASConjoint33>' ||
                         substr(l_rl2_box_n,7,3) || '</N_NASConjoint33>' || EOL;
      end if;
    ELSE
      if l_rep_type <> 'RL2PAPERPDF' then
          tab_employee(lN_NASConjoint) := NULL;
      else
         tab_employee(lN_NASConjoint) := NULL;
         tab_employee(lN_NASConjoint1) := NULL;
         tab_employee(lN_NASConjoint2) := NULL;
         tab_employee1(lN_NASConjoint) := NULL;
         tab_employee1(lN_NASConjoint1) := NULL;
         tab_employee1(lN_NASConjoint2) := NULL;
         tab_employee2(lN_NASConjoint) := NULL;
         tab_employee2(lN_NASConjoint1) := NULL;
         tab_employee2(lN_NASConjoint2) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lN_NASConjoint) = ' ||
                         tab_employee(lN_NASConjoint));

    -- Summ (Box O)

    IF TO_NUMBER(l_rl2_box_o) > 999999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_rl2_box_o IS NOT NULL AND
       to_number(l_rl2_box_o) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_rl2_box_o),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lO_RetraitRAP ) := '<O_RetraitRAP>' ||
                         l_formatted_box || '</O_RetraitRAP>' || EOL;
      if l_rep_type = 'RL2PAPERPDF' then
            tab_employee1(lO_RetraitRAP ) := '<O_RetraitRAP1>' ||
                         l_formatted_box || '</O_RetraitRAP1>' || EOL;
            tab_employee2(lO_RetraitRAP ) := '<O_RetraitRAP2>' ||
                         l_formatted_box || '</O_RetraitRAP2>' || EOL;
      end if;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lO_RetraitRAP ) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
          tab_employee1(lO_RetraitRAP ) := NULL;
          tab_employee2(lO_RetraitRAP ) := NULL;
      end if;
    END IF;
   hr_utility.trace('Value of Box O');
   hr_utility.trace('tab_employee(lO_RetraitRAP ) = ' ||
                         tab_employee(lO_RetraitRAP ));

   if l_rep_type = 'RL2PAPERPDF' then
            tab_employee(lCode_dereleve) := '<Code_De_Releve>' ||
                         'R' || '</Code_De_Releve>' || EOL;
            tab_employee1(lCode_dereleve) := '<Code_De_Releve1>' ||
                         'R' || '</Code_De_Releve1>' || EOL;
            tab_employee2(lCode_dereleve) := '<Code_De_Releve2>' ||
                         'R' || '</Code_De_Releve2>' || EOL;
   end if;
    -- Negative Balance Exists

    IF l_negative_balance_flag = 'Y' THEN
       l_negative_box := 'Y';
       l_status := 'Failed';
       l_msg_code  := 'NEG';
    END IF;

    IF l_all_box_0 THEN
       l_status := 'Failed';
       l_msg_code := 'ALL_BOXES_ZERO';
    END IF;

    -- (Provenance1)
    hr_utility.trace('The checking for Provenance value ');
    hr_utility.trace('The value of Archiver Assignment Action Id '||l_arch_action_id);
    hr_utility.trace('The Value of Assignment Id '||l_asg_id);

    hr_utility.trace('The value Of Provenenace  : '|| l_rl2_source_of_income);
    IF l_rl2_source_of_income IS NOT NULL THEN
       tab_employee(lProvenance1 ) := '<Provenance1>' ||
                         convert_special_char(l_rl2_source_of_income) || '</Provenance1>' || EOL;
       if l_rep_type = 'RL2PAPERPDF' then
           tab_employee1(lProvenance1 ) := '<Provenance11>' ||
                         convert_special_char(l_rl2_source_of_income) || '</Provenance11>' || EOL;
           tab_employee2(lProvenance1 ) := '<Provenance12>' ||
                         convert_special_char(l_rl2_source_of_income) || '</Provenance12>' || EOL;
       end if;
    ELSE
 /* Commented for Bug 6732992
      l_status := 'Failed';
      l_msg_code := 'MISSING_SOURCE_OF_INCOME';
 */
      tab_employee(lProvenance1) := NULL;
      if l_rep_type = 'RL2PAPERPDF' then
            tab_employee1(lProvenance1) := NULL;
            tab_employee2(lProvenance1) := NULL;
      end if;
    END IF;
    hr_utility.trace('tab_employee(lProvenance1) = ' ||
                         tab_employee(lProvenance1));

    /* For bug 8888411 */
    OPEN c_rl2_src_income(replace(l_rl2_source_of_income,'AUTRE','OTHER'), l_taxation_year);
    FETCH c_rl2_src_income into l_meaning;
    IF c_rl2_src_income%notfound then
       l_status := 'Failed';
       l_msg_code := 'INVALID_SOURCE_OF_INCOME';
    END IF;
    CLOSE c_rl2_src_income;
   /* End 8888411 */

    OPEN cur_get_meaning(l_msg_code);
    FETCH cur_get_meaning
    INTO  l_meaning;
    CLOSE cur_get_meaning;

  /* Bug #4747251 Fix */
  IF l_status = 'Failed' OR l_rep_type = 'RL2PAPERPDF' THEN

    tab_employee(lBoxA_UnregisterdPlan)  := NULL;
    tab_employee(lDesg_BenefitExcAmt ) := NULL;
    tab_employee(lBoxB_DesgBenefitTrnsAmt) := NULL;
    tab_employee(lBoxExcessAmt) := NULL;
    tab_employee(lAmount_Transferred) := NULL;
    tab_employee(lBoxC_SinglePayAccured) := NULL;
    tab_employee(lBoxC_SinglePayAccUnreg) := NULL;
    tab_employee(lBoxC_ExcessAmtSinPayTrans) := NULL;

    OPEN c_footnote_codes(l_arch_action_id);
    LOOP

          FETCH c_footnote_codes
          INTO  l_footnote_code,l_footnote_amount;

          EXIT WHEN c_footnote_codes%notfound ;

          l_footnote_count := l_footnote_count + 1;

          hr_utility.trace('l_footnote_code = '||l_footnote_code);
          hr_utility.trace('l_footnote_amount = '||l_footnote_amount);

          --Commented for bug 8888411
         /* IF l_footnote_code <> 'Box A - Unregistered Plan' THEN
               tab_employee(lBoxA_UnregisterdPlan) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxA_UnregisterdPlan) := '<BoxA_UnregisteredPlan>'||l_formatted_box||
                                                             '</BoxA_UnregisteredPlan>';
                   END IF;
          END IF;
          IF l_footnote_code <> 'Box B - Designated benefit, excess amount' THEN
               tab_employee(lDesg_BenefitExcAmt ) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lDesg_BenefitExcAmt ) := '<Desg_BenefitExcAmt>'||l_formatted_box||'</Desg_BenefitExcAmt>';
                   END IF;
          END IF;

          IF l_footnote_code <> 'Designated benefit, amount transferred' THEN
               tab_employee(lBoxB_DesgBenefitTrnsAmt ) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxB_DesgBenefitTrnsAmt) := '<BoxB_DesgBenefitTrnsAmt>'||l_formatted_box||
                                                               '</BoxB_DesgBenefitTrnsAmt>';
                   END IF;
          END IF;

          IF l_footnote_code <> 'Box B - Excess Amount' THEN
               tab_employee(lBoxExcessAmt ) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxExcessAmt) := '<BoxExcessAmt>'||l_formatted_box||'</BoxExcessAmt>';
                   END IF;
          END IF;

          IF l_footnote_code <> 'Amount Transferred' THEN
               tab_employee(lAmount_Transferred ) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lAmount_Transferred) := '<Amount_Transferred>'||l_formatted_box||'</Amount_Transferred>';
                   END IF;
          END IF;

          IF l_footnote_code <> 'Box C - Single payment accrued to December 31, 1971' THEN
               tab_employee(lBoxC_SinglePayAccured ) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxC_SinglePayAccured) := '<BoxC_SinglePayAccured>'||l_formatted_box||
                                                              '</BoxC_SinglePayAccured>';
                   END IF;
          END IF;

          IF l_footnote_code <> 'Box C - Single payment under an unregistered pension plan' THEN
               tab_employee(lBoxC_SinglePayAccUnreg) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxC_SinglePayAccUnreg) := '<BoxC_SinglePayAccUnreg>'||l_formatted_box||
                                                                 '</BoxC_SinglePayAccUnreg>';
                   END IF;

          END IF;

          IF l_footnote_code <> 'Box C - Excess amount of a single payment transferred' THEN
               tab_employee(lBoxC_ExcessAmtSinPayTrans) := NULL;
          ELSE
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxC_ExcessAmtSinPayTrans) := '<BoxC_ExcessAmtSinPayTrans>'||l_formatted_box||
                                                                  '</BoxC_ExcessAmtSinPayTrans>';
                   END IF;
          END IF;  */

          /* Added for bug 8888411 */
          IF l_footnote_code = 'Box A - Unregistered Plan' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxA_UnregisterdPlan) := '<BoxA_UnregisteredPlan>'||l_formatted_box||
                                                             '</BoxA_UnregisteredPlan>';
                   END IF;
          END IF;
          IF l_footnote_code = 'Box B - Designated benefit, excess amount' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lDesg_BenefitExcAmt ) := '<Desg_BenefitExcAmt>'||l_formatted_box||'</Desg_BenefitExcAmt>';
                   END IF;
          END IF;

          IF l_footnote_code = 'Designated benefit, amount transferred' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxB_DesgBenefitTrnsAmt) := '<BoxB_DesgBenefitTrnsAmt>'||l_formatted_box||
                                                               '</BoxB_DesgBenefitTrnsAmt>';
                   END IF;
          END IF;

          IF l_footnote_code = 'Box B - Excess Amount' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxExcessAmt) := '<BoxExcessAmt>'||l_formatted_box||'</BoxExcessAmt>';
                   END IF;
          END IF;

          IF l_footnote_code = 'Amount Transferred' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lAmount_Transferred) := '<Amount_Transferred>'||l_formatted_box||'</Amount_Transferred>';
                   END IF;
          END IF;

          IF l_footnote_code = 'Box C - Single payment accrued to December 31, 1971' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxC_SinglePayAccured) := '<BoxC_SinglePayAccured>'||l_formatted_box||
                                                              '</BoxC_SinglePayAccured>';
                   END IF;
          END IF;

          IF l_footnote_code = 'Box C - Single payment under an unregistered pension plan' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxC_SinglePayAccUnreg) := '<BoxC_SinglePayAccUnreg>'||l_formatted_box||
                                                                 '</BoxC_SinglePayAccUnreg>';
                   END IF;

          END IF;

          IF l_footnote_code = 'Box C - Excess amount of a single payment transferred' THEN
                   IF l_footnote_amount IS NOT NULL AND
                      l_footnote_amount <> 0 THEN

                      SELECT ltrim(rtrim(to_char(l_footnote_amount,l_format_mask)))
                      INTO   l_formatted_box
                      FROM   dual;
                      tab_employee(lBoxC_ExcessAmtSinPayTrans) := '<BoxC_ExcessAmtSinPayTrans>'||l_formatted_box||
                                                                  '</BoxC_ExcessAmtSinPayTrans>';
                   END IF;
          END IF;
          /* End 8888411 */

          l_footcode := l_footnote_code;
          l_footamt  := l_footnote_amount;
          IF l_footnote_amount < 0 THEN
               l_negative_box := 'Y';
          END IF;
    END LOOP;
    close c_footnote_codes;
 ELSE
       tab_employee(lBoxA_UnregisterdPlan)  := NULL;
       tab_employee(lDesg_BenefitExcAmt ) := NULL;
       tab_employee(lBoxB_DesgBenefitTrnsAmt) := NULL;
       tab_employee(lBoxExcessAmt) := NULL;
       tab_employee(lAmount_Transferred) := NULL;
       tab_employee(lBoxC_SinglePayAccured) := NULL;
       tab_employee(lBoxC_SinglePayAccUnreg) := NULL;
       tab_employee(lBoxC_ExcessAmtSinPayTrans) := NULL;
 END IF;

    IF l_status = 'Failed' THEN
       tab_employee(lErrorDetails) := '<ErrorDetails>' ||
                   convert_special_char(l_meaning) || '</ErrorDetails>' || EOL;
    ELSE
       tab_employee(lErrorDetails) := NULL;
    END IF;

  IF l_rep_type <> 'RL2PAPERPDF' THEN
     l_final_xml_string :=
                           '<' || l_status || '>' || EOL ||
                           '<R>' || EOL ||
                           tab_employee(lAnnee) ||
                           tab_employee(lNoReleve) || '<Beneficiaire>' || EOL ||
                           tab_employee(lNAS) ||
                           tab_employee(lNo) ||
                           tab_employee(lNomFamille) ||
                           tab_employee(lPrenom) ||
                           tab_employee(lInitiale) || l_addr_begin_tag || EOL ||
                           tab_employee(lLigne1) ||
                           tab_employee(lLigne2) ||
                           tab_employee(lVille) ||
                           tab_employee(lProvince) ||
                           tab_employee(lCodePostal) ||
                           l_addr_end_tag || EOL || '</Beneficiaire>' || EOL  ||
                           '<Montants>' || EOL ||
                         tab_employee(lA_PrestRPA_RPNA) ||
                         tab_employee(lB_PrestREER_FERR_RPDB) ||
                         tab_employee(lC_AutrePaiement) ||
                         tab_employee(lD_RembPrimeConjoint) ||
                         tab_employee(lE_PrestDeces) ||
                         tab_employee(lF_RembCotisInutilise) ||
                         tab_employee(lG_RevocationREER_FERR) ||
                         tab_employee(lH_AutreRevenu)  ||
                         tab_employee(lI_DroitDeduction ) ||
                         tab_employee(lJ_ImpotQueRetenuSource) ||
                         tab_employee(lK_RevenuApresDeces)  ||
                         tab_employee(lL_RetraitREEP)  ||
                         tab_employee(lM_LibereImpot) ||
                         tab_employee(lN_NASConjoint) ||
                         tab_employee(lO_RetraitRAP) ||
                         tab_employee(lProvenance1) ||
                         tab_employee(lBoxA_UnregisterdPlan) ||
                         tab_employee(lDesg_BenefitExcAmt) ||
                         tab_employee(lBoxB_DesgBenefitTrnsAmt) ||
                         tab_employee(lBoxExcessAmt) ||
                         tab_employee(lAmount_Transferred) ||
                         tab_employee(lBoxC_SinglePayAccured) ||
                         tab_employee(lBoxC_SinglePayAccUnreg) ||
                         tab_employee(lBoxC_ExcessAmtSinPayTrans) ||
                         tab_employee(lErrorDetails)||
                         '</Montants>' || EOL || '</R>' || EOL ||
                         '</' || l_status || '>' ;

                          hr_utility.trace('Just before Printing the file details ');
                          pay_core_files.write_to_magtape_lob(l_final_xml_string);
   ELSE

             IF l_negative_box = 'N' THEN

                  l_final_xml_string  := '<Empdata>'||EOL;
                  l_final_xml_string1 := '<Empdata>'||EOL;
                  l_final_xml_string2 := '<Empdata>'||EOL;

                  FOR i IN 1 .. l_counter LOOP
                         l_final_xml_string  := l_final_xml_string  ||tab_emplyr(i);
                         l_final_xml_string1 := l_final_xml_string1 ||tab_emplyr1(i);
                         l_final_xml_string2 := l_final_xml_string2 ||tab_emplyr2(i);
                  END LOOP;


               IF l_footnote_count > 1 THEN
                  tab_employee(l_footnotecode) := '<Footnotecode>'||'See Attached'||'</Footnotecode>';
                  tab_employee(l_footnoteamt)  := NULL;
                  tab_employee1(l_footnotecode) := '<Footnotecode1>'||'See Attached'||'</Footnotecode1>';
                  tab_employee1(l_footnoteamt)  := NULL;
                  tab_employee2(l_footnotecode) := '<Footnotecode2>'||'See Attached'||'</Footnotecode2>';
                  tab_employee2(l_footnoteamt)  := NULL;
               ELSIF l_footnote_count = 1 THEN
                  tab_employee(l_footnotecode)  := '<Footnotecode>'||l_footcode||'</Footnotecode>';
                  tab_employee(l_footnoteamt)   := '<Footnoteamt>' ||l_footamt ||'</Footnoteamt>';
                  tab_employee1(l_footnotecode) := '<Footnotecode1>'||l_footcode||'</Footnotecode1>';
                  tab_employee1(l_footnoteamt)  := '<Footnoteamt1>' ||l_footamt ||'</Footnoteamt1>';
                  tab_employee2(l_footnotecode) := '<Footnotecode2>'||l_footcode||'</Footnotecode2>';
                  tab_employee2(l_footnoteamt)  := '<Footnoteamt2>' ||l_footamt ||'</Footnoteamt2>';
               ELSE
                  tab_employee(l_footnotecode)  := NULL;
                  tab_employee(l_footnoteamt)   := NULL;
                  tab_employee1(l_footnotecode) := NULL;
                  tab_employee1(l_footnoteamt)  := NULL;
                  tab_employee2(l_footnotecode) := NULL;
                  tab_employee2(l_footnoteamt)  := NULL;
               END IF;
               l_final_xml_string :=
                         l_final_xml_string ||EOL||
                           tab_employee(lAnnee) ||
                           tab_employee(lNoReleve) ||
                           tab_employee(lNo) ||
                           tab_employee(lNomFamille) ||
                           tab_employee(lLigne1) ||
                           tab_employee(lLigne2) ||
                           tab_employee(lVille) ||
                           tab_employee(lA_PrestRPA_RPNA) ||
                           tab_employee(lB_PrestREER_FERR_RPDB) ||
                           tab_employee(lC_AutrePaiement) ||
                           tab_employee(lD_RembPrimeConjoint) ||
                           tab_employee(lE_PrestDeces) ||
                           tab_employee(lF_RembCotisInutilise) ||
                           tab_employee(lG_RevocationREER_FERR) ||
                           tab_employee(lH_AutreRevenu)  ||
                           tab_employee(lI_DroitDeduction ) ||
                           tab_employee(lJ_ImpotQueRetenuSource) ||
                           tab_employee(lK_RevenuApresDeces)  ||
                           tab_employee(lL_RetraitREEP)  ||
                           tab_employee(lM_LibereImpot) ||
                           tab_employee(lN_NASConjoint) ||
                           tab_employee(lO_RetraitRAP) ||
                           tab_employee(lProvenance1) ||
                           tab_employee(lNAS1) ||
                           tab_employee(lNAS2) ||
                           tab_employee(lNAS3) ||
                           tab_employee(lN_NASConjoint1) ||
                           tab_employee(lN_NASConjoint2) ||
			   tab_employee(lCode_dereleve) ||
                           tab_employee(l_footnotecode)||EOL||
                           tab_employee(l_footnoteamt)||EOL||
                           tab_employee(l_authorisation_tag)||EOL||
                           tab_employee(l_authorisation_no)||EOL||
			   tab_employee(l_sequence_no)||EOL||
                           '</Empdata>'||EOL;
  /* Looping the data twice to meet the template requirement */
	     l_final_xml_string1 := l_final_xml_string1 ||EOL||
                           tab_employee1(lAnnee) ||
                           tab_employee1(lNoReleve) ||
                           tab_employee1(lNo) ||
                           tab_employee1(lNomFamille) ||
                           tab_employee1(lLigne1) ||
                           tab_employee1(lLigne2) ||
                           tab_employee1(lVille) ||
                           tab_employee1(lA_PrestRPA_RPNA) ||
                           tab_employee1(lB_PrestREER_FERR_RPDB) ||
                           tab_employee1(lC_AutrePaiement) ||
                           tab_employee1(lD_RembPrimeConjoint) ||
                           tab_employee1(lE_PrestDeces) ||
                           tab_employee1(lF_RembCotisInutilise) ||
                           tab_employee1(lG_RevocationREER_FERR) ||
                           tab_employee1(lH_AutreRevenu)  ||
                           tab_employee1(lI_DroitDeduction ) ||
                           tab_employee1(lJ_ImpotQueRetenuSource) ||
                           tab_employee1(lK_RevenuApresDeces)  ||
                           tab_employee1(lL_RetraitREEP)  ||
                           tab_employee1(lM_LibereImpot) ||
                           tab_employee1(lN_NASConjoint) ||
                           tab_employee1(lO_RetraitRAP) ||
                           tab_employee1(lProvenance1) ||
                           tab_employee1(lNAS1) ||
                           tab_employee1(lNAS2) ||
                           tab_employee1(lNAS3) ||
                           tab_employee1(lN_NASConjoint1) ||
                           tab_employee1(lN_NASConjoint2) ||
			   tab_employee1(lCode_dereleve) ||
                           tab_employee1(l_footnotecode)||EOL||
                           tab_employee1(l_footnoteamt)||EOL||
                           tab_employee1(l_authorisation_tag)||EOL||
                           tab_employee1(l_authorisation_no)||EOL||
			   tab_employee1(l_sequence_no)||EOL||
                           '</Empdata>'||EOL;

             l_final_xml_string2 := l_final_xml_string2 ||EOL||
                           tab_employee2(lAnnee) ||
                           tab_employee2(lNoReleve) ||
                           tab_employee2(lNo) ||
                           tab_employee2(lNomFamille) ||
                           tab_employee2(lLigne1) ||
                           tab_employee2(lLigne2) ||
                           tab_employee2(lVille) ||
                           tab_employee2(lA_PrestRPA_RPNA) ||
                           tab_employee2(lB_PrestREER_FERR_RPDB) ||
                           tab_employee2(lC_AutrePaiement) ||
                           tab_employee2(lD_RembPrimeConjoint) ||
                           tab_employee2(lE_PrestDeces) ||
                           tab_employee2(lF_RembCotisInutilise) ||
                           tab_employee2(lG_RevocationREER_FERR) ||
                           tab_employee2(lH_AutreRevenu)  ||
                           tab_employee2(lI_DroitDeduction ) ||
                           tab_employee2(lJ_ImpotQueRetenuSource) ||
                           tab_employee2(lK_RevenuApresDeces)  ||
                           tab_employee2(lL_RetraitREEP)  ||
                           tab_employee2(lM_LibereImpot) ||
                           tab_employee2(lN_NASConjoint) ||
                           tab_employee2(lO_RetraitRAP) ||
                           tab_employee2(lProvenance1) ||
                           tab_employee2(lNAS1) ||
                           tab_employee2(lNAS2) ||
                           tab_employee2(lNAS3) ||
                           tab_employee2(lN_NASConjoint1) ||
                           tab_employee2(lN_NASConjoint2) ||
			   tab_employee2(lCode_dereleve) ||
                           tab_employee2(l_footnotecode)||EOL||
                           tab_employee2(l_footnoteamt)||EOL||
                           tab_employee2(l_authorisation_tag)||EOL||
                           tab_employee2(l_authorisation_no)||EOL||
			   tab_employee2(l_sequence_no)||EOL||
                           '</Empdata>'||EOL;

                    /* added for 5850067*/
                    l_print_instruction := pay_magtape_generic.get_parameter_value('print_instruction');

                     -- l_page_break := '<break_dummy>'||' '||'</break_dummy>'||EOL;
                     l_final_xml_string := '<RL2_PDF_ASG>'||l_final_xml_string
                                            ||l_final_xml_string1
	                                          ||l_final_xml_string2
	                                          ||'<PRINT-INSTRUCTION>'||l_print_instruction||'</PRINT-INSTRUCTION>' --Added for 5850067
                                            ||EOL||'</RL2_PDF_ASG>';

                     hr_utility.trace('Just before Printing the file details ');
                     pay_core_files.write_to_magtape_lob(l_final_xml_string);

              ELSIF l_negative_box = 'Y' THEN
              --Bug 7495973: Appended '_F' to all xml tags of failed records
                    l_final_xml_string :=
                           '<FAILED_RL2_PDFASG>' ||EOL||
                           replace(tab_emplyr(1),'Nom','Nom_F')||EOL||
                           replace(tab_employee(lNo),'No','No_F') ||
                           replace(tab_employee(lNomFamille),'NomFamille','NomFamille_F') ||
                           replace(tab_employee(lLigne1),'Ligne1','Ligne1_F') ||
                           replace(tab_employee(lLigne2),'Ligne2','Ligne2_F') ||
                           replace(tab_employee(lVille),'Ville','Ville_F') ||
                           replace(tab_employee(lA_PrestRPA_RPNA),'A_PrestRPA_RPNA','A_PrestRPA_RPNA_F') ||
                           replace(tab_employee(lB_PrestREER_FERR_RPDB),'B_PrestREER_FERR_RPDB','B_PrestREER_FERR_RPDB_F') ||
                           replace(tab_employee(lC_AutrePaiement),'C_AutrePaiement','C_AutrePaiement_F') ||
                           replace(tab_employee(lD_RembPrimeConjoint),'D_RembPrimeConjoint','D_RembPrimeConjoint_F') ||
                           replace(tab_employee(lE_PrestDeces),'E_PrestDeces','E_PrestDeces_F') ||
                           replace(tab_employee(lF_RembCotisInutilise),'F_RembCotisInutilise','F_RembCotisInutilise_F') ||
                           replace(tab_employee(lG_RevocationREER_FERR),'G_RevocationREER_FERR','G_RevocationREER_FERR_F') ||
                           replace(tab_employee(lH_AutreRevenu),'H_AutreRevenu','H_AutreRevenu_F')  ||
                           replace(tab_employee(lI_DroitDeduction ),'I_DroitDeduction','I_DroitDeduction_F') ||
                           replace(tab_employee(lJ_ImpotQueRetenuSource),'J_ImpotQueRetenuSource','J_ImpotQueRetenuSource_F') ||
                           replace(tab_employee(lK_RevenuApresDeces),'K_RevenuApresDeces','K_RevenuApresDeces_F')  ||
                           replace(tab_employee(lL_RetraitREEP),'L_RetraitREEP','L_RetraitREEP_F')  ||
                           replace(tab_employee(lM_LibereImpot),'M_LibereImpot','M_LibereImpot_F') ||
                           replace(tab_employee(lN_NASConjoint),'N_NASConjoint','N_NASConjoint_F') ||
                           replace(tab_employee(lO_RetraitRAP),'O_RetraitRAP','O_RetraitRAP_F') ||
                           replace(tab_employee(lProvenance1),'Provenance1','Provenance1_F') ||
                           replace(tab_employee(lNAS1),'NAS1','NAS1_F') ||
                           replace(tab_employee(lNAS2),'NAS2','NAS2_F') ||
                           replace(tab_employee(lNAS3),'NAS3','NAS3_F') ||
                           replace(tab_employee(lN_NASConjoint1),'N_NASConjoint1','N_NASConjoint1_F') ||
                           replace(tab_employee(lN_NASConjoint2),'N_NASConjoint2','N_NASConjoint2_F') ||
                           replace(tab_employee(lNoReleve),'NoReleve','NoReleve_F') ||
                           tab_employee(lErrorDetails)||
                           '</FAILED_RL2_PDFASG>'||EOL;

                    hr_utility.trace('Just before Printing the file details ');
                    pay_core_files.write_to_magtape_lob(l_final_xml_string);
              END IF;
   END IF;

  END;
  END xml_employee_record;

  PROCEDURE xml_report_start IS
  BEGIN

    DECLARE
     l_final_xml_string VARCHAR2(32000);

  BEGIN

    l_final_xml_string := '<RL2PAPER>';
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_report_start;

  PROCEDURE xml_report_end IS
  BEGIN

   DECLARE
     l_final_xml_string VARCHAR2(32000);

  BEGIN

    l_final_xml_string := '</RL2PAPER>';
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_report_end;


  PROCEDURE xml_employer_start IS
  BEGIN

  DECLARE

    l_final_xml_string VARCHAR2(32000);

  BEGIN

    l_final_xml_string := '<Groupe02>';
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_employer_start;

PROCEDURE xml_employer_record IS
  BEGIN

  DECLARE

    l_final_xml_string VARCHAR2(32000);

    TYPE employer_info IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    tab_employer employer_info;

    lAnnee                   NUMBER;
    lNbReleves               NUMBER;
    lNold                    NUMBER;
    lTypeDossier             NUMBER;
    lNoDossier               NUMBER;
    lNom1                    NUMBER;
    lLigne1                  NUMBER;
    lLigne2                  NUMBER;
    lVille                   NUMBER;
    lProvince                NUMBER;
    lCodePostal              NUMBER;
    l_taxation_year         varchar2(4);
    l_payroll_actid         NUMBER;
    l_year_start            DATE;
    l_year_end              DATE;
    l_report_type           VARCHAR2(5);
    l_business_grpid        NUMBER;
    l_legislative_param     pay_payroll_actions.legislative_parameters%type;
    EOL                     varchar2(5);
    l_employer_name         varchar2(100);
    l_quebec_bn             varchar2(20);
    l_address_line          per_addresses.address_line1%TYPE;
    l_address_begin_tag     varchar2(10);
    l_address_end_tag       varchar2(10);

  BEGIN
    hr_utility.trace('XML Employer');
    hr_utility.trace('XML Employer');

    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lAnnee        := 1;
    lNbReleves    := 2;
    lNold         := 3;
    lTypeDossier  := 4;
    lNoDossier    := 5;
    lNom1         := 6;
    lLigne1       := 7;
    lLigne2       := 8;
    lVille        := 9;
    lProvince     := 10;
    lCodePostal   := 11;

    l_taxation_year
        := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');
    l_payroll_actid
        := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');

    get_report_parameters(
		l_payroll_actid,
		l_year_start,
		l_year_end,
		l_report_type,
		l_business_grpid,
                l_legislative_param
	);

    tab_employer(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' || EOL;
    tab_employer(lNbReleves) := '<NbReleves>' || 'Running Total' || '</NbReleves>' || EOL;

    hr_utility.trace('The Payroll Action Id : '||l_payroll_actid);
    hr_utility.trace('The business group id : '||l_business_grpid);
    l_quebec_bn := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                       l_payroll_actid,
                                                       'CAEOY_RL2_QUEBEC_BN');
    hr_utility.trace('The Quebec Number is '||l_quebec_bn);
    tab_employer(lNold) := '<NoId>' || convert_special_char(substr(l_quebec_bn,1,10)) ||
                           '</NoId>' || EOL;
    tab_employer(lTypeDossier) := '<TypeDossier>' || 'RS' ||
                                  '</TypeDossier>' || EOL;

    tab_employer(lNoDossier) := '<NoDossier>' || convert_special_char(substr(l_quebec_bn,13,4)) ||
                                '</NoDossier>' || EOL;
    hr_utility.trace('The Employer File Number : '|| substr(l_quebec_bn,13,4));
    l_employer_name := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                           l_payroll_actid,
                                                           'CAEOY_RL2_EMPLOYER_NAME');

    tab_employer(lNom1) := '<Nom>' ||
                    convert_special_char(substr(l_employer_name,1,30)) || '</Nom>' || EOL;
    hr_utility.trace('tab_employer(lNom) = ' || tab_employer(lNom1));

    -- Address Line 1

    l_address_line := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                          l_payroll_actid,
                                                          'CAEOY_RL2_EMPLOYER_ADDRESS_LINE1');

    IF (l_address_line IS NULL AND
        l_address_line <> '                              ' ) THEN

      l_address_begin_tag       := '';
      tab_employer(lLigne1)     := NULL;
      tab_employer(lLigne2)     := NULL;
      tab_employer(lVille)      := NULL;
      tab_employer(lProvince)   := NULL;
      tab_employer(lCodePostal) := NULL;
      l_address_end_tag         := '';

    ELSE

      l_address_begin_tag       := '<Adresse>';

      tab_employer(lLigne1) := '<Ligne1>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ligne1>' || EOL;
      hr_utility.trace('tab_employer(lLigne1) = ' || tab_employer(lLigne1));


      -- Address Line 2

      l_address_line := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                            l_payroll_actid,
                                                            'CAEOY_RL2_EMPLOYER_ADDRESS_LINE2');

      IF (l_address_line IS NOT NULL AND
          l_address_line <> '                              ' ) THEN
        tab_employer(lLigne2) := '<Ligne2>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ligne2>' || EOL;
      ELSE
        tab_employer(lLigne2) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lLigne2) = ' || tab_employer(lLigne2));

      -- Ville (City)

      l_address_line := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                            l_payroll_actid,
                                                            'CAEOY_RL2_EMPLOYER_CITY');
      IF ( l_address_line IS NOT NULL AND
           l_address_line <> '                              ')  THEN
        tab_employer(lVille) := '<Ville>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ville>' || EOL;
      ELSE
        tab_employer(lVille) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lVille) = ' || tab_employer(lVille));

      -- Province

      l_address_line := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                            l_payroll_actid,
                                                            'CAEOY_RL2_EMPLOYER_PROVINCE');

      IF ( l_address_line IS NOT NULL AND
           l_address_line <> '                    ' ) THEN
        tab_employer(lProvince) := '<Province>' ||
                         convert_special_char(SUBSTR(hr_general.decode_lookup( 'CA_PROVINCE',
                         l_address_line),1,20)) || '</Province>' || EOL;
      ELSE
        tab_employer(lProvince) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lProvince) = ' || tab_employer(lProvince));

      -- Postal Code

      l_address_line := pay_ca_rl2_mag.get_employer_item(l_business_grpid,
                                                            l_payroll_actid,
                                                            'CAEOY_RL2_EMPLOYER_POSTAL_CODE');

      IF ( l_address_line IS NOT NULL AND
           l_address_line <> '      ' ) THEN
        tab_employer(lCodePostal) := '<CodePostal>' ||
             convert_special_char(substr(l_address_line,1,6)) || '</CodePostal>' || EOL;
      ELSE
        tab_employer(lCodePostal) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lCodePostal) = ' ||
                                            tab_employer(lCodePostal));

      l_address_end_tag         := '</Adresse>';

    END IF;
    l_final_xml_string := '<T>' || EOL ||
                           tab_employer(lAnnee) ||
                           tab_employer(lNbReleves)|| EOL || '<PayeurEmetteur>' || EOL ||
                           tab_employer(lNold) ||
                           tab_employer(lTypeDossier) ||
                           tab_employer(lNoDossier) ||
                           tab_employer(lNom1) || l_address_begin_tag || EOL ||
                           tab_employer(lLigne1) ||
                           tab_employer(lLigne2) ||
                           tab_employer(lVille) ||
                           tab_employer(lProvince) ||
                           tab_employer(lCodePostal) ||
                           l_address_end_tag || EOL || '</PayeurEmetteur>' || EOL ||
                           '</T>' || EOL ||
                           '</Groupe02>' || EOL;

     pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_employer_record;

/* Added by ssmukher for Bug 4030973 */
/* The check digit calculated by the method below
must be the same as the 10th digit of the
identification number or the number is invalid.

Example of the modulus 11 method:
The identification number is 2345678908.
Use the first nine digits to validate the identification number.
The tenth digit is the check digit (in this case 8).

Formula:
Beginning with the ninth digit (extreme right), multiply each digit by the
factor indicated.
The factors form a circular sequence of the values 2 through 7, beginning on
the right.
First nine digits of the identification number 2 3 4 5 6 7 8 9 0
Multiply each digit by the factor indicated. x 4 x 3 x 2 x 7 x 6 x 5 x 4 x 3
x 2
Results 8 9 8 35 36 35 32 27 0
Add the results
(8 + 9 + 8 + 35 + 36 + 35 + 32 + 27 + 0). = 190
Divide the result by 11 (190/11). = 17 remainder 3
If the remainder is 0, the check digit is 1. If the remainder is 1, the check
digit is 0.
For any other remainder obtained, the check digit is the difference between
11 and that remainder.
Subtract the remainder obtained from 11 (11 -  3) = 8
*/

FUNCTION validate_quebec_number (p_quebec_no IN VARCHAR2,p_qin_name varchar2)
RETURN NUMBER IS

l_quebec	 NUMBER;
l_rem		 NUMBER;
i		 NUMBER;
l_max		 NUMBER;
l_total		 NUMBER;
l_min		 NUMBER;
l_modulus	 NUMBER;
l_chk_digit	 NUMBER;
l_act_chk_number NUMBER;

BEGIN
     i        := 1;
     l_min    := 2;
     l_max    := 7;
     l_total  := 0;
     l_quebec := to_number(substr(p_quebec_no,1,9));
     l_act_chk_number := to_number(substr(p_quebec_no,10,1));

     if TRANSLATE(substr(p_quebec_no,1,9),'0123456789','9999999999') = '999999999' then

        loop
            if i > 9 then
               exit;
            end if;

	    if l_min > l_max then
	       l_min := 2;
	    end if;

	    l_rem    := mod(l_quebec,10);
	    l_total  := l_total + (l_min * l_rem);
            l_min    := l_min + 1;
	    l_quebec := ((l_quebec - l_rem)/10);
	    i        := i+ 1;

        end loop;

        l_modulus := mod(l_total, 11);
        if l_modulus = 0 then
           l_chk_digit := 1;
        elsif l_modulus = 1 then
           l_chk_digit := 0;
        else
           l_chk_digit := 11 - l_modulus;
        end if;

        if  l_chk_digit <> l_act_chk_number then
          hr_utility.set_message(801,'PAY_74156_INCORRECT_QIN_INFO');
          hr_utility.set_message_token('PRE_NAME',p_qin_name);
          pay_core_utils.push_message(801,'PAY_74156_INCORRECT_QIN_INFO','P');
          pay_core_utils.push_token('PRE_NAME',p_qin_name);
          hr_utility.raise_error;
        end if;
     else

          hr_utility.set_message(801,'PAY_74156_INCORRECT_QIN_INFO');
          hr_utility.set_message_token('PRE_NAME',p_qin_name);
          pay_core_utils.push_message(801,'PAY_74156_INCORRECT_QIN_INFO','P');
          pay_core_utils.push_token('PRE_NAME',p_qin_name);
          hr_utility.raise_error;

     end if;

     return l_chk_digit;

END;


FUNCTION convert_special_char( p_data varchar2)
RETURN varchar2 IS
   l_data VARCHAR2(2000);
   l_output varchar2(2000);
cursor c_uppercase(p_input_string varchar2) is
select
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(convert(p_input_string,'UTF8'),
           utl_raw.cast_to_varchar2(hextoraw('C380')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38A')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C387')),'C'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C389')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39C')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C399')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39B')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C394')),'O'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38F')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38E')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C388')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38B')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C382')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C592')),'OE'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C386')),'AE'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C3A9')),'e'
          )
from dual;

BEGIN
      l_data := trim(p_data);
      l_data := REPLACE(l_data, '&' , '&' || 'amp;');
      l_data := REPLACE(l_data, '<'     , '&' || 'lt;');
      l_data := REPLACE(l_data, '>'     , '&' || 'gt;');
      l_data := REPLACE(l_data, ''''    , '&' || 'apos;');
      l_data := REPLACE(l_data, '"'     , '&' || 'quot;');

      open c_uppercase(l_data);
      fetch c_uppercase into l_output;
      if c_uppercase%NOTFOUND then
          l_output := l_data;
      end if;
  close c_uppercase;

   RETURN l_output;
END;


FUNCTION get_employee_item (p_asg_action_id     IN number,
                            p_assignment_id     IN number,
                            p_archived_item     IN varchar2)
RETURN varchar2 IS

CURSOR c_employee_info IS
SELECT nvl(tran.quebec_business_number,'0000000000  0000'),
       nvl(tran.reporting_year,'0000'),
       nvl(emp.rl2_slip_number,'000000000'),
       nvl(emp.employee_sin,'000000000'),
       nvl(emp.employee_last_name,'                              '),
       nvl(emp.employee_first_name,'                              '),
       nvl(emp.employee_middle_initial,' '),
       nvl(emp.employee_address_line1,'                              '),
       nvl(emp.employee_address_line2,'                              '),
       nvl(emp.employee_address_line3,'                              '),
       nvl(emp.employee_city,'                              '),
       nvl(emp.employee_province,'                    '),
       nvl(emp.employee_postal_code,'      '),
       nvl(emp.employee_number,'                    '),
       emp.rl2_box_a,
       emp.rl2_box_b,
       emp.rl2_box_c,
       emp.rl2_box_d,
       emp.rl2_box_e,
       emp.rl2_box_f,
       emp.rl2_box_g,
       emp.rl2_box_h,
       emp.rl2_box_i,
       emp.rl2_box_j,
       emp.rl2_box_k,
       emp.rl2_box_l,
       emp.rl2_box_m,
       emp.rl2_box_n,
       emp.rl2_box_o,
       decode(substr(emp.rl2_source_of_income,1,5),'OTHER','AUTRE', emp.rl2_source_of_income),
       nvl(emp.negative_balance_flag, 'N'),
       emp.person_id
FROM pay_ca_eoy_rl2_employee_info_v emp,
     pay_ca_eoy_rl2_trans_info_v    tran
WHERE emp.assignment_action_id = p_asg_action_id
AND   emp.assignment_id        = p_assignment_id
AND   emp.payroll_action_id    = tran.payroll_action_id;

l_quebec_business_number varchar2(240);
l_reporting_year varchar2(240);
l_rl2_slip_number varchar2(240);
l_employee_sin varchar2(240);
l_employee_last_name varchar2(240);
l_employee_first_name varchar2(240);
l_employee_middle_initial varchar2(240);
l_employee_address_line1 varchar2(240);
l_employee_address_line2 varchar2(240);
l_employee_address_line3 varchar2(240);
l_employee_city varchar2(240);
l_employee_province varchar2(240);
l_employee_postal_code varchar2(240);
l_employee_number varchar2(240);
l_person_id   varchar2(50);
l_rl2_box_a varchar2(240);
l_rl2_box_b varchar2(240);
l_rl2_box_c varchar2(240);
l_rl2_box_d varchar2(240);
l_rl2_box_e varchar2(240);
l_rl2_box_f varchar2(240);
l_rl2_box_g varchar2(240);
l_rl2_box_h varchar2(240);
l_rl2_box_i varchar2(240);
l_rl2_box_j varchar2(240);
l_rl2_box_k varchar2(240);
l_rl2_box_l varchar2(240);
l_rl2_box_m varchar2(240);
l_rl2_box_n varchar2(240);
l_rl2_box_o varchar2(240);
l_rl2_source_of_income  varchar2(240);
l_negative_balance_flag varchar2(240);

l_return_value varchar2(240);

BEGIN

     OPEN c_employee_info;
     FETCH c_employee_info
     INTO l_quebec_business_number,
          l_reporting_year,
          l_rl2_slip_number,
          l_employee_sin,
          l_employee_last_name,
          l_employee_first_name,
          l_employee_middle_initial,
          l_employee_address_line1,
          l_employee_address_line2,
          l_employee_address_line3,
          l_employee_city,
          l_employee_province,
          l_employee_postal_code,
          l_employee_number,
          l_rl2_box_a,
          l_rl2_box_b,
          l_rl2_box_c,
          l_rl2_box_d,
          l_rl2_box_e,
          l_rl2_box_f,
          l_rl2_box_g,
          l_rl2_box_h,
          l_rl2_box_i,
          l_rl2_box_j,
          l_rl2_box_k,
          l_rl2_box_l,
          l_rl2_box_m,
          l_rl2_box_n,
          l_rl2_box_o,
          l_rl2_source_of_income,
          l_negative_balance_flag,
          l_person_id;

     CLOSE c_employee_info;

     IF p_archived_item = 'CAEOY_RL2_QUEBEC_BN' THEN
         l_return_value := l_quebec_business_number;
     ELSIF p_archived_item = 'CAEOY_TAXATION_YEAR' THEN
         l_return_value := l_reporting_year;
     ELSIF p_archived_item = 'CAEOY_RL2_SLIP_NUMBER' THEN
         l_return_value := l_rl2_slip_number;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_SIN' THEN
         l_return_value := l_employee_sin;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_LAST_NAME' THEN
         l_return_value := l_employee_last_name;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_FIRST_NAME' THEN
         l_return_value := l_employee_first_name;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_INITIAL' THEN
         l_return_value := l_employee_middle_initial;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_ADDRESS_LINE1' THEN
         l_return_value := l_employee_address_line1;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_ADDRESS_LINE2' THEN
         l_return_value := l_employee_address_line2;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_ADDRESS_LINE3' THEN
         l_return_value := l_employee_address_line3;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_CITY' THEN
         l_return_value := l_employee_city;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_PROVINCE' THEN
         l_return_value := l_employee_province;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_POSTAL_CODE' THEN
         l_return_value := l_employee_postal_code;
     ELSIF p_archived_item = 'CAEOY_RL2_EMPLOYEE_NUMBER' THEN
         l_return_value := l_employee_number;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_A' THEN
         l_return_value := l_rl2_box_a;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_B' THEN
         l_return_value := l_rl2_box_b;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_C' THEN
         l_return_value := l_rl2_box_c;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_D' THEN
         l_return_value := l_rl2_box_d;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_E' THEN
         l_return_value := l_rl2_box_e;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_F' THEN
         l_return_value := l_rl2_box_f;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_G' THEN
         l_return_value := l_rl2_box_g;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_H' THEN
         l_return_value := l_rl2_box_h;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_I' THEN
         l_return_value := l_rl2_box_i;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_J' THEN
         l_return_value := l_rl2_box_j;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_K' THEN
         l_return_value := l_rl2_box_k;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_L' THEN
         l_return_value := l_rl2_box_l;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_M' THEN
         l_return_value := l_rl2_box_m;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_N' THEN
         l_return_value := l_rl2_box_n;
     ELSIF p_archived_item = 'CAEOY_RL2_BOX_O' THEN
         l_return_value := l_rl2_box_o;
     ELSIF p_archived_item = 'CAEOY_RL2_SOURCE_OF_INCOME' THEN
         l_return_value := l_rl2_source_of_income;
     ELSIF p_archived_item = 'CAEOY_RL2_NEGATIVE_BALANCE' THEN
         l_return_value := l_negative_balance_flag;
     ELSIF p_archived_item = 'CAEOY_PERSON_ID' THEN
         l_return_value := l_person_id;
     END IF;

     RETURN l_return_value;

END get_employee_item;


PROCEDURE archive_ca_deinit (p_pactid IN NUMBER) IS

   CURSOR  c_get_report_type ( p_pactid number) IS
   SELECT  report_type
   FROM    pay_payroll_actions
   WHERE   payroll_action_id = p_pactid;

   l_report_type pay_payroll_actions.report_type%type;

BEGIN

    open c_get_report_type(p_pactid);
    fetch c_get_report_type
    into  l_report_type;
    close c_get_report_type;

    IF l_report_type = 'RL2PAPERPDF' THEN
        pay_ca_payroll_utils.delete_actionid(p_pactid);
    END IF;

END archive_ca_deinit;

/* Commented for bug 8500723
FUNCTION getnext_seq_num (p_curr_seq IN NUMBER)
RETURN NUMBER IS
  l_seq_number   number;
  l_check_number number;
BEGIN

     l_check_number := mod(p_curr_seq,7);
     hr_utility.trace('l_check_number ='|| l_check_number);
     l_seq_number := (p_curr_seq * 10) + l_check_number;
     hr_utility.trace('l_seq_number ='|| l_seq_number);
     return l_seq_number;
END; */

END pay_ca_rl2_mag;

/
