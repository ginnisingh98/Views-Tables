--------------------------------------------------------
--  DDL for Package Body PAY_CA_RL2_AMEND_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_RL2_AMEND_MAG" AS
 /* $Header: pycarl2amd.pkb 120.1.12010000.11 2009/12/28 10:55:40 sapalani noship $ */

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
   --   p_report_type		Type of report being run RL2
   --
   -- Notes
/*  Version  Name     Date        Bug       Text
    -------  -------- ----------- --------  ------------------------------------
    115.0                         5551214   Created.
    115.3                                   Modified the cursor get_emplyr_info in
                                            procedure create_assignment_act to use
                                            quebec_business_number instead of
                                            transmitter_number
    115.4                                   Removed the following functions
                                            get_parameter, validate_quebec_number.
    115.5                         8316787   Enhancement.
    115.6                         8316787   Added code for missing slip number.
                                            Modified the cursor c_original_slipno
    115.7                         8316787   Removed locking of Amendment Paper
                                            Report.
                                            Reused the functions
                                            validate_quebec_number
                                            and convert_special_char defined in
                                            pay_ca_rl2_mag.
                                            Added the feature to show only those
                                            emloyees
                                            whose assignamnents got amended since
                                            the previous run of amendment mag media.
    115.9                         8932754   Modified the cursor
                                            get_latest_rl2_amend_dtls.
    115.10                        8932598   Modified procedure create_assignment_act
                                            to prevent creation of duplicate
                                            assignment actions for the same
                                            employee.
    115.11                        9041046   Added authorisation no for 2009 test
                                            file.
    115.12   sapalani 16-Nov-2009 8888411   Added new cursor c_rl2_src_income to
                                            fetch valid RL2 source of income.
                                            Added new error code for RL2 Amd.
                                            Electronic interface for invalid
                                            source of income.
                                            Modfied the logic of creating XML
                                            tags  for RL2 Footnotes for error
                                            report.
    115.13   aneghosh 20-Nov-2009 9133270   Modified the cursor
                                            get_latest_rl2_amend_dtls.
    115.14   aneghosh 25-Nov-2009 9154497   Modified the code to accept the type of
                                            package value from the transmitter details
                                            instead of harcoding it to 4.
    115.15   sapalani 23-Dec-2009 9206939   Added 2009 Certification No.
                                            RQ-09-02-019 for RL2 Amendment
                                            Electronic Interface.
*/
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
		--hr_utility.trace_on('Y','RL2AMD');
		hr_utility.set_location('pay_ca_rl2_amend_mag.get_report_parameters', 10);

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

		hr_utility.set_location('pay_ca_rl2_amend_mag.get_report_parameters', 20);

	END get_report_parameters;

---------------------------------------------------------------------------
  --Procedure Name : validate_transmitter_info
  --Purpose
  -- This procedure is used for checking if the correct transmitter
  -- record  details has been entered.If any of the following data
  -- Package Type,Source Of RL2 Slip ,Transmitter Number,Transmitter Name
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
    ppa.report_type = 'CAEOY_RL2_AMEND_PP' AND
    ppa.report_qualifier = 'CAEOY_RL2_AMEND_PPQ' AND
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

  CURSOR get_trans_details(p_pactid NUMBER,
                           p_business_group_id NUMBER) IS
  SELECT nvl(transmitter_number,'        '),
       nvl(transmitter_name,'                              '),
       nvl(transmitter_package_type,'0'),
       nvl(source_of_slips,' '),
       nvl(transmitter_address_line1,'                              ')
  FROM pay_ca_eoy_rl2_trans_info_v
 WHERE business_group_id = p_business_group_id
   AND payroll_action_id = p_pactid;

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

  OPEN  get_trans_details(l_arch_pactid,p_bg_id);
  FETCH get_trans_details
  INTO  l_transmitter_number,
        l_transmitter_name,
	l_type_of_package,
	l_source_of_slips,
	l_address_line1;
  CLOSE get_trans_details;


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

  hr_utility.trace('l_type_of_package = ' || l_type_of_package);

  IF l_type_of_package IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_TYPE_OF_PKG','P');
     hr_utility.raise_error;
  END IF;

  hr_utility.trace('l_source_of_slips = ' || l_source_of_slips);

  IF l_source_of_slips IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_RLSLIP_SRC','P');
     hr_utility.raise_error;
  END IF;

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

	hr_utility.set_location( 'pay_ca_rl2_amend_mag.range_cursor', 10);

	get_report_parameters(
		p_pactid,
		p_year_start,
		p_year_end,
		p_report_type,
		p_business_group_id,
                p_legislative_param
	);

	hr_utility.set_location( 'pay_ca_rl2_amend_mag.range_cursor', 20);
	p_sqlstr := 'select distinct to_number(emp.person_id)
        from    pay_ca_eoy_rl2_employee_info_v emp,
    		pay_ca_eoy_rl2_trans_info_v tran,
	        pay_assignment_actions  paa_arch,
    		pay_payroll_actions     ppa_arch,
    		pay_payroll_actions     ppa_mag,
                hr_organization_information hoi
      	where  ppa_mag.payroll_action_id    = :payroll_action_id
      	and    ppa_arch.business_group_id+0 = ppa_mag.business_group_id
      	and    ppa_arch.effective_date     = ppa_mag.effective_date
      	and    ppa_arch.report_type        = ''CAEOY_RL2_AMEND_PP''
      	and    ppa_arch.payroll_action_id  = paa_arch.payroll_action_id
	and    tran.reporting_year    = to_char(ppa_arch.effective_date,''YYYY'')
      	and    tran.business_group_id = ppa_arch.business_group_id
      	and    tran.reporting_year   = pay_ca_rl2_mag.get_parameter(''REPORTING_YEAR'',ppa_mag.legislative_parameters)
      	and    paa_arch.payroll_action_id  =  tran.payroll_action_id
      	and    paa_arch.action_status = ''C''
      	and    paa_arch.assignment_action_id = emp.assignment_action_id
      	and    paa_arch.payroll_action_id    =	emp.payroll_action_id
        and    emp.business_group_id         = ppa_arch.business_group_id
        and    decode(hoi.org_information3, ''Y'', hoi.organization_id, hoi.org_information20) =
               pycadar_pkg.get_parameter(''TRANSMITTER_PRE'', ppa_mag.legislative_parameters )
        and    hoi.org_information_context  =''Prov Reporting Est''
        and    to_char(hoi.organization_id) = pycadar_pkg.get_parameter(''PRE_ORGANIZATION_ID'',ppa_arch.legislative_parameters)
	order by to_number(emp.person_id)' ;

        hr_utility.set_location( 'pay_ca_rl2_amend_mag.range_cursor',30);

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
                         p_effective_dt  date,
			 p_pactid  number) IS
    	SELECT 	paf.person_id,
      	   	paf.assignment_id,
             hoi.organization_id,
      	   	paf.effective_end_date,
      	   	max(paa_arch.assignment_action_id),
                max(ppa_arch.payroll_action_id)
    	FROM  pay_payroll_actions ppa_arch,
	      pay_assignment_actions paa_arch,
	      per_all_assignments_f paf,
              hr_organization_information hoi
	WHERE ppa_arch.report_type = 'CAEOY_RL2_AMEND_PP'
	AND   ppa_arch.business_group_id+0 = p_business_grpid
	AND   ppa_arch.effective_date = p_effective_dt
	AND   paa_arch.payroll_action_id = ppa_arch.payroll_action_id
	AND   paa_arch.action_status = 'C'
	AND   paf.assignment_id = paa_arch.assignment_id
	AND   paf.person_id BETWEEN p_stperson AND p_endperson
	AND   paf.effective_start_date <= ppa_arch.effective_date
	AND   paf.effective_end_date >= ppa_arch.start_date
  AND   decode(hoi.org_information3, 'Y', hoi.organization_id, hoi.org_information20) =
        pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa_arch.legislative_parameters)
  AND   hoi.org_information_context = 'Prov Reporting Est'
  AND   hoi.organization_id = pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa_arch.legislative_parameters)
  AND   paf.effective_end_date = (SELECT max(paf1.effective_end_date)
                                        FROM per_all_assignments_f paf1
                                        WHERE paf1.assignment_id = paf.assignment_id
                                        AND   paf1.effective_start_date <= p_effective_dt)
  AND   not exists
             ( SELECT  pail.locked_action_id
               FROM    pay_action_interlocks pail,
                       pay_payroll_actions pact,
                       pay_assignment_actions passt
               WHERE   pact.report_type = 'RL2_AMEND_MAG'
               AND     pact.payroll_action_id = passt.payroll_action_id
               AND     passt.assignment_action_id = pail.locking_action_id
               AND     pail.locked_action_id = paa_arch.assignment_action_id)
  AND   not exists
             ( SELECT  pail.locked_action_id
               FROM    pay_action_interlocks pail,
                       pay_payroll_actions pact,
                       pay_assignment_actions passt
               WHERE   pact.report_type = 'RL2_XML_MAG'
               AND     pact.payroll_action_id = passt.payroll_action_id
               AND     passt.assignment_action_id = pail.locking_action_id
               AND     pail.locked_action_id = paa_arch.assignment_action_id)
  AND   not exists
             ( SELECT  pail.locked_action_id
               FROM    pay_action_interlocks pail,
                       pay_payroll_actions pact,
                       pay_assignment_actions passt
               WHERE   pact.report_type = 'CAEOY_RL2_AMEND_PP'
               AND     pact.payroll_action_id = passt.payroll_action_id
               AND     passt.assignment_action_id = pail.locking_action_id
               AND     pail.locked_action_id = paa_arch.assignment_action_id)
        GROUP BY
	        paf.person_id,
      	   	paf.assignment_id,
            hoi.organization_id,
      	   	paf.effective_end_date;

        CURSOR get_latest_rl2_amend_dtls (cp_person_id  in number
                                      --,cp_pre_org_id in number
                                      ,cp_effective_date in date
                                      ,cp_business_group_id in number) is
        select ppa.report_type,
               paa.assignment_id,
               paa.assignment_action_id,
               pay_ca_eoy_rl1_amend_reg.get_parameter('PRE_ORGANIZATION_ID',
                                                       ppa.legislative_parameters)
        from pay_payroll_actions ppa,
             pay_assignment_actions paa
        where paa.serial_number = to_char(cp_person_id)
/*        and pay_ca_eoy_rl1_amend_reg.get_parameter('PRE_ORGANIZATION_ID',
                                   ppa.legislative_parameters) =
            nvl(cp_pre_org_id,pay_ca_eoy_rl1_amend_reg.get_parameter('PRE_ORGANIZATION_ID',
                                   ppa.legislative_parameters))*/
        and paa.action_status = 'C'
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.effective_date = cp_effective_date
        and ppa.business_group_id = cp_business_group_id
        and ppa.report_type IN ('CAEOY_RL2_AMEND_PP','RL2_XML_MAG','RL2_AMEND_MAG')
        and exists (select 1
                    from per_assignments_f paf
                    where paf.assignment_id = paa.assignment_id
                    and   paf.effective_start_date <= cp_effective_date
                    and   paf.effective_end_date   >= trunc(cp_effective_date,'Y'))
          AND   not exists
             ( SELECT  pail.locked_action_id
               FROM    pay_action_interlocks pail,
                       pay_payroll_actions pact,
                       pay_assignment_actions passt
               WHERE   pact.report_type = 'RL2_AMEND_MAG'
               AND     pact.payroll_action_id = passt.payroll_action_id
               AND     passt.assignment_action_id = pail.locking_action_id
               AND     passt.serial_number=to_char(cp_person_id)
               AND     (pail.locked_action_id = paa.assignment_action_id
               OR paa.assignment_action_id < passt.assignment_action_id))
--        order by paa.assignment_action_id desc;
          group by paa.assignment_action_id,ppa.report_type,paa.assignment_id,
          pay_ca_eoy_rl1_amend_reg.get_parameter('PRE_ORGANIZATION_ID',
                                                       ppa.legislative_parameters); --Bug 9133270
      CURSOR get_yepp_pact_id(cp_bg_id number,
                              cp_pre number,
                              cp_year date) IS
      select payroll_action_id
      from pay_payroll_actions
      where business_group_id = cp_bg_id
      and report_type         = 'RL2'
      and report_qualifier    = 'CAEOYRL2'
      and action_type = 'X'
      and action_status = 'C'
      and effective_date = cp_year
      and pay_ca_eoy_rl1_amend_reg.get_parameter('PRE_ORGANIZATION_ID',
                                                 legislative_parameters) = to_char(cp_pre);

     CURSOR get_warning_dtls_for_ee(cp_person_id in number) is
     select substr(full_name,1,48), employee_number
     from per_people_f
     where person_id = cp_person_id
     order by effective_end_date desc;

     CURSOR c_get_prov_amend_flag(cp_asg_act_id  number) IS
     select action_information2
     from pay_action_information
     where action_context_id = cp_asg_act_id
     and   action_information_category = 'CAEOY RL2 EMPLOYEE INFO2'
     and   action_context_type = 'AAP'
     and   jurisdiction_code   = 'QC';

 CURSOR get_emplyr_info( p_business_group_id number,
                          p_pact_id           number) IS
   SELECT nvl(employer_name,'                              '),
          nvl(quebec_business_number,'0000000000  0000'),
          nvl(employer_add_line1,'                              ')
     FROM pay_ca_eoy_rl2_trans_info_v
    WHERE business_group_id = p_business_group_id
      AND payroll_action_id = p_pact_id;

      CURSOR c_paa_update_check (cp_locking_asg_act_id number) IS
      select assignment_action_id from
      pay_assignment_actions  where
      assignment_action_id = cp_locking_asg_act_id;

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

    ln_primary_assignment_id  NUMBER := 0;
    lv_report_type            pay_payroll_actions.report_type%TYPE ;
    ln_asg_act_to_lock        pay_assignment_actions.assignment_action_id%TYPE;
    ln_pre_id_null          number;
    ln_iteration            number := 0;
    lv_flag_count           number := 0;
    lv_employee_number        per_people_f.employee_number%type;
    lv_message                varchar2(100):= null;
    lv_full_name              per_people_f.full_name%type;
    lv_record_name            varchar2(100);
    lv_prov_of_emp      varchar2(10);
    lv_prov_amend_flag   varchar2(5);
    ln_serial_number          pay_assignment_actions.serial_number%TYPE;
    l_paa_update_check pay_assignment_actions.assignment_action_id%TYPE;

BEGIN


	-- Get the report parameters. These define the report being run.
        l_prev_payact := -1;
	hr_utility.set_location( 'pay_ca_rl2_amend_mag.create_assignment_act',10);

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

	hr_utility.set_location( 'pay_ca_rl2_amend_mag.create_assignment_act',20);
    hr_utility.trace('Report type '||l_report_type);
	IF l_report_type = 'RL2_AMEND_MAG' THEN

		OPEN c_all_asg(l_legislative_param,
                               l_business_group_id,
                               l_year_end,
                               p_pactid);
		LOOP
		    FETCH c_all_asg INTO l_person_id,
		 			 l_assignment_id,
		 			 l_tax_unit_id,
		 			 l_effective_end_date,
              				 l_assignment_action_id,
                                         l_payroll_act;

       		    hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignment_act', 30);

		    EXIT WHEN c_all_asg%NOTFOUND;

		--Create the assignment action for the record

                 /* Validating QIN Number information */
                  if l_prev_payact <> l_payroll_act and l_report_type = 'CAEOY_RL2_AMEND_PP'then

                      hr_utility.trace('The payroll action id '||l_payroll_act);

                      OPEN get_emplyr_info(l_business_group_id,l_payroll_act);
		      FETCH  get_emplyr_info
                      INTO   l_emplyer_name,
                             l_quebec_no,
                             l_addr_line;
                      CLOSE  get_emplyr_info;

                      l_prev_payact := l_payroll_act;

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

                      if l_addr_line = '                              '
                      then
                           pay_core_utils.push_message(800,'PAY_CA_RL2_MISSING_ADDRESS','P');
                           hr_utility.raise_error;
                      end if;
                      hr_utility.trace('First 10 digits of the QIN: '||l_quebec_no);
                      l_return := pay_ca_rl2_mag.validate_quebec_number(l_quebec_no,l_emplyer_name);

                  end if ;
		  hr_utility.trace('Assignment Fetched  - ');
		  hr_utility.trace('Assignment Id : '|| to_char(l_assignment_id));
		  hr_utility.trace('Person Id :  '|| to_char(l_person_id));
		  hr_utility.trace('tax unit id : '|| to_char(l_tax_unit_id));
		  hr_utility.trace('Effective End Date :  '|| to_char(l_effective_end_date));

		  hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignment_act', 40);

		                  /* Create an assignment action for this person */

                   select pay_assignment_actions_s.nextval
                   into lockingactid
                   from dual;
                   hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignement_act', 50);
                   hr_utility.trace('New RL2 Amend Action = ' ||
                                      to_char(lockingactid));

         open get_latest_rl2_amend_dtls(l_person_id,
                                        --l_tax_unit_id,
                                        l_year_end,
                                        l_business_group_id);

         loop

         fetch get_latest_rl2_amend_dtls into lv_report_type
                                     ,ln_primary_assignment_id
                                     ,ln_asg_act_to_lock
                                     ,ln_pre_id_null;

         if get_latest_rl2_amend_dtls%notfound then

           if ln_iteration = 0 then

             open get_warning_dtls_for_ee(l_person_id);
             fetch get_warning_dtls_for_ee into lv_full_name
                                               ,lv_employee_number;
             close get_warning_dtls_for_ee;

             hr_utility.trace('get_latest_rl2_amend_dtls not found');
             hr_utility.trace('p_person_id :'||to_char(l_person_id));


                lv_record_name := 'RL2 Amendment Magnetic Media';

             lv_message := 'Latest amendment details not available for this employee';

             pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','A');
             pay_core_utils.push_token('record_name',lv_record_name);
             pay_core_utils.push_token('name_or_number',lv_full_name);
             pay_core_utils.push_token('description',lv_message);

           end if;
           exit;

         end if;

         ln_iteration := ln_iteration + 1;

         if get_latest_rl2_amend_dtls%found then
         if lv_report_type='CAEOY_RL2_AMEND_PP' then
              begin

                open c_get_prov_amend_flag(ln_asg_act_to_lock);
                lv_prov_amend_flag := 'N';
                fetch c_get_prov_amend_flag into lv_prov_amend_flag;

                 hr_utility.trace('lv_prov_amend_flag : '||lv_prov_amend_flag);
                 if c_get_prov_amend_flag%FOUND then
--To make sure that only the latest amendment details are printed
                    if lv_prov_amend_flag = 'Y' AND lv_flag_count = 0 then

                    /* Insert into pay_assignment_actions. */
                    hr_nonrun_asact.insact(lockingactid
                                     ,ln_primary_assignment_id
                                     ,p_pactid
                                     ,p_chunk
                                     ,l_tax_unit_id);

                   /***********************************************************
                   ** Update the serial number column with Province_code QC,
                   ** Archiver assignment_action and Archiver Payroll_action_id
                   ** so that we need not refer back in the reports.
                   ***********************************************************/

                   update pay_assignment_actions aa
                     set aa.serial_number = to_char(l_person_id)
                   where  aa.assignment_action_id = lockingactid;

--Added to lock the Amend Archiver
                  hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignement_act', 60);
                  hr_nonrun_asact.insint(lockingactid
                                     ,ln_asg_act_to_lock);
                  hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignement_act', 70);
                  hr_utility.trace('Locking Action'||lockingactid);
                  hr_utility.trace('Locked Action = '  || to_char(ln_asg_act_to_lock));
                  hr_utility.trace('lv_flag_count = '  || to_char(lv_flag_count));
                  lv_flag_count := lv_flag_count + 1;
               end if; -- lv_prov_amend_flag = 'Y'

              end if; -- c_get_prov_amend_flag%FOUND



              close c_get_prov_amend_flag;

             end;
end if; --lv_report_type

           if lv_report_type in ('RL2_XML_MAG','RL2_AMEND_MAG') then

                   open c_paa_update_check(lockingactid);
                    fetch c_paa_update_check into l_paa_update_check;
                   hr_utility.trace('l_update_check : '||l_paa_update_check);
                    if c_paa_update_check%FOUND then

                   /***********************************************************
                   ** Update the serial number column with Province_code QC,
                   ** Archiver assignment_action and Archiver Payroll_action_id
                   ** so that we need not refer back in the reports.
                   ***********************************************************/

                   update pay_assignment_actions aa
                     set aa.serial_number = to_char(l_person_id)
                   where  aa.assignment_action_id = lockingactid;

--Added to lock the previous mag Reports
                  hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignement_act', 60);
                  hr_nonrun_asact.insint(lockingactid
                                     ,ln_asg_act_to_lock);
                  hr_utility.set_location('pay_ca_rl2_amend_mag.create_assignement_act', 70);
                  hr_utility.trace('Locking Action'||lockingactid);
                  hr_utility.trace('Locked Action = '  || to_char(ln_asg_act_to_lock));

                   end if; --c_paa_update_check%FOUND
                   close c_paa_update_check;

    end if; ---END lv_report_type

         end if; /* get_latest_rl2_amend_dtls found*/

         end loop; /* get_latest_rl2_amend_dtls loop */
         close get_latest_rl2_amend_dtls;
           lv_flag_count := 0;
		END LOOP;
		CLOSE c_all_asg;

	END IF;

END create_assignment_act;

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
    l_report_type       VARCHAR2(20);
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

    --hr_utility.trace_on(null,'SATIRL2');
    hr_utility.trace('Inside the Transmitter record proc');
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
    pay_ca_rl2_mag.convert_special_char(l_trans_package_type) || '</TypeEnvoi>' || EOL; --Bug 9154497

    hr_utility.trace('tab_transmitter(lTypeEnvoi) = ' ||
                                           tab_transmitter(lTypeEnvoi));

    tab_transmitter(lProvenance) := '<Provenance>' ||
         pay_ca_rl2_mag.convert_special_char(l_source_of_slips) || '</Provenance>' || EOL;

    hr_utility.trace('tab_transmitter(lProvenance) = ' || tab_transmitter(lProvenance));

    tab_transmitter(lNo) := '<No>' ||
        pay_ca_rl2_mag.convert_special_char(l_trans_number) || '</No>' || EOL;

    hr_utility.trace('tab_transmitter(lNo) = ' || tab_transmitter(lNo));


   IF l_trans_type_indicator IS NOT NULL AND
      l_trans_type_indicator <> '0' THEN
      tab_transmitter(lType) := '<Type>' ||
        pay_ca_rl2_mag.convert_special_char(l_trans_type_indicator) || '</Type>' || EOL;
   ELSE
      tab_transmitter(lType) := NULL;
   END IF;

    hr_utility.trace('tab_transmitter(lType) = ' || tab_transmitter(lType));

    tab_transmitter(lNom1) := '<Nom1>' ||
                    pay_ca_rl2_mag.convert_special_char(substr(l_trans_name,1,30)) || '</Nom1>' || EOL;

    hr_utility.trace('tab_transmitter(lNom1) = ' || tab_transmitter(lNom1));

    l_return := substr(l_trans_name,31,30);
    IF l_return IS NOT NULL THEN
      tab_transmitter(lNom2) := '<Nom2>' || pay_ca_rl2_mag.convert_special_char(l_return) || '</Nom2>' || EOL;
    ELSE
      tab_transmitter(lNom2) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lNom2) = ' || tab_transmitter(lNom2));


    tab_transmitter(lLigne1) := '<Ligne1>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_trans_address_line1,1,30)) || '</Ligne1>' || EOL;

    hr_utility.trace('tab_transmitter(lLigne1) = ' || tab_transmitter(lLigne1));


    IF (l_trans_address_line2 IS NOT NULL AND
        l_trans_address_line2 <> '                              ') THEN
      tab_transmitter(lLigne2) := '<Ligne2>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_trans_address_line2,1,30)) || '</Ligne2>' || EOL;
    ELSE
      tab_transmitter(lLigne2) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lLigne2) = ' || tab_transmitter(lLigne2));


    IF (l_trans_city IS NOT NULL AND
        l_trans_city <> '                              ')  THEN
      tab_transmitter(lVille) := '<Ville>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_trans_city,1,30)) || '</Ville>' || EOL;
    ELSE
      tab_transmitter(lVille) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lVille) = ' || tab_transmitter(lVille));

    IF (l_trans_province IS NOT NULL AND
        l_trans_province <> '                    ') THEN
        tab_transmitter(lProvince) := '<Province>' ||
                   pay_ca_rl2_mag.convert_special_char(SUBSTR(hr_general.decode_lookup(
                   'CA_PROVINCE',l_trans_province),1,20)) || '</Province>' || EOL;
    ELSE
        tab_transmitter(lProvince) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lProvince) = ' || tab_transmitter(lProvince));

    IF (l_trans_postal_code IS NOT NULL AND
        l_trans_postal_code <> '      ') THEN
        tab_transmitter(lCodePostal) := '<CodePostal>' ||
             pay_ca_rl2_mag.convert_special_char(substr(l_trans_postal_code,1,6)) || '</CodePostal>' || EOL;
    ELSE
        tab_transmitter(lCodePostal) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lCodePostal) = ' || tab_transmitter(lCodePostal));


    IF (l_trans_tech_contact_name IS NOT NULL AND
        l_trans_tech_contact_name <> '                              ' ) THEN
      l_Informatique_tag := 'Y';
      tab_transmitter(lNom) := '<Nom>' ||
             pay_ca_rl2_mag.convert_special_char(substr(l_trans_tech_contact_name,1,30)) || '</Nom>' || EOL;
    ELSE
      tab_transmitter(lNom) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lNom) = ' || tab_transmitter(lNom));


    IF (l_trans_tech_contact_code IS NOT NULL AND
        l_trans_tech_contact_code <> '000' ) THEN
      l_Informatique_tag := 'Y';
      tab_transmitter(lIndRegional) := '<IndRegional>' ||
                                         pay_ca_rl2_mag.convert_special_char(l_trans_tech_contact_code) || '</IndRegional>' || EOL;
    ELSE
      tab_transmitter(lIndRegional) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lIndRegional) = ' || tab_transmitter(lIndRegional));

    IF (l_trans_tech_contact_phone IS NOT NULL AND
        l_trans_tech_contact_phone <> '0000000' ) THEN
      l_Informatique_tag := 'Y';
      l_trans_tech_contact_phone := substr(l_trans_tech_contact_phone,1,3) || '-' || substr(l_trans_tech_contact_phone,4,4);
      tab_transmitter(lTel) := '<Tel>' || pay_ca_rl2_mag.convert_special_char(l_trans_tech_contact_phone) || '</Tel>' || EOL;
    ELSE
      tab_transmitter(lTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lTel) = ' || tab_transmitter(lTel));


    IF (l_trans_tech_contact_extn IS NOT NULL AND
        l_trans_tech_contact_extn <> '0000' ) THEN
      l_Informatique_tag := 'Y';
      tab_transmitter(lPosteTel) := '<PosteTel>' || pay_ca_rl2_mag.convert_special_char(l_trans_tech_contact_extn) ||
                                  '</PosteTel>' || EOL;
    ELSE
      tab_transmitter(lPosteTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lPosteTel) = ' ||
                            tab_transmitter(lPosteTel));


   IF (l_trans_tech_contact_lang IS NOT NULL AND
       l_trans_tech_contact_lang <> ' ' )  THEN
    l_Informatique_tag := 'Y';
    tab_transmitter(lLangue) := '<Langue>' ||pay_ca_rl2_mag.convert_special_char(l_trans_tech_contact_lang) || '</Langue>' || EOL;
   ELSE
     tab_transmitter(lLangue) := NULL;
   END IF;


    IF (l_trans_acct_contact_name IS NOT NULL AND
        l_trans_acct_contact_name <> '                              ')  THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lANom) := '<Nom>' ||
             pay_ca_rl2_mag.convert_special_char(substr(l_trans_acct_contact_name,1,30)) || '</Nom>' || EOL;
    ELSE
      tab_transmitter(lANom) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lANom) = ' || tab_transmitter(lANom));


    IF (l_trans_acct_contact_code IS NOT NULL AND
        l_trans_acct_contact_code <> '000' ) THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lAIndRegional) := '<IndRegional>' || pay_ca_rl2_mag.convert_special_char(l_trans_acct_contact_code) ||
                                      '</IndRegional>' || EOL;
    ELSE
      tab_transmitter(lAIndRegional) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lAIndRegional) = ' || tab_transmitter(lAIndRegional));


    IF (l_trans_acct_contact_phone IS NOT NULL AND
        l_trans_acct_contact_phone <> '0000000' ) THEN
      l_Comptabilite_tag := 'Y';
      l_trans_acct_contact_phone := substr(l_trans_acct_contact_phone,1,3) || '-' || substr(l_trans_acct_contact_phone,4,4);
      tab_transmitter(lATel) := '<Tel>' || pay_ca_rl2_mag.convert_special_char(l_trans_acct_contact_phone) || '</Tel>' || EOL;
    ELSE
      tab_transmitter(lATel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lATel) = ' || tab_transmitter(lATel));


    IF (l_trans_acct_contact_extn IS NOT NULL AND
        l_trans_acct_contact_extn <> '0000')  THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lAPosteTel) := '<PosteTel>' || pay_ca_rl2_mag.convert_special_char(l_trans_acct_contact_extn) ||
                                     '</PosteTel>' || EOL;
    ELSE
      tab_transmitter(lAPosteTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lAPosteTel) = ' ||
                                      tab_transmitter(lAPosteTel));

    IF (l_trans_acct_contact_lang IS NOT NULL AND
        l_trans_acct_contact_lang <> ' ' ) THEN
      l_Comptabilite_tag := 'Y';
      tab_transmitter(lALangue) := '<Langue>' || pay_ca_rl2_mag.convert_special_char(l_trans_acct_contact_lang) ||
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

    tab_transmitter(lNoConcepteur) := '<NoCertification>'||pay_ca_rl2_mag.convert_special_char(l_authorization_no)||'</NoCertification>'||EOL;

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

CURSOR  c_original_slipno (p_person IN VARCHAR,p_tax_year IN VARCHAR,p_trans_id IN NUMBER) IS
SELECT  pei_information7
FROM    per_people_extra_info pei,
        per_people_f ppf
WHERE   ppf.person_id = to_number(p_person)
AND     pei_information6=to_char(p_trans_id)
AND     substr(pei_information5,1,4)=p_tax_year
AND     to_number(pei.person_id) = ppf.person_id
AND     pei.information_type = 'PAY_CA_RL2_FORM_NO';

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

    l_count             NUMBER;
    lBoxR_14            NUMBER;
    lErrorDetails       NUMBER;
    l_origi_slipno      NUMBER;

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
  l_footcode      VARCHAR2(100);
  l_footnotecode  NUMBER;
  l_footnoteamt   NUMBER;
  l_footnote_amount NUMBER;
  l_footamt         NUMBER;
  l_format_mask  VARCHAR2(30);
  l_original_slpno  VARCHAR2(150);
  l_authorisation_no  NUMBER;
  l_authorisation_tag NUMBER;
  l_sequence_no       NUMBER;
  l_seq_num           NUMBER;
  l_authorization_code VARCHAR2(100);
  l_legislative_parameters pay_payroll_actions.legislative_parameters%type;
  l_transmitter_org_id NUMBER;
  BEGIN
    --hr_utility.trace_on(null,'SATIRL2XML');
    hr_utility.trace('Inside the Employee record proc');
    l_status := 'Success';
    l_all_box_0 := TRUE;
    l_count := 0;
    l_format_mask := '99999999999999990.99';
    l_counter :=  0;
    l_negative_box := 'N';
    l_footnote_count := 0;
    l_original_slpno := '0';
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
    l_footnotecode  :=  38;
    l_footnoteamt  :=  39;

    lNAS1  := 40;
    lNAS2 := 41;
    lNAS3 := 42;
    lN_NASConjoint1 := 43;
    lN_NASConjoint2 := 44;
    lCode_dereleve  := 45;
    l_authorisation_no  := 46;
    l_authorisation_tag := 47;
    l_sequence_no       := 48;
    l_origi_slipno := 49;


    l_mag_asg_action_id := to_number(pay_magtape_generic.get_parameter_value
                                                 ('TRANSFER_ACT_ID'));
    l_transfer_pay_actid := to_number(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'));

    open c_get_report_type(l_transfer_pay_actid);
    fetch c_get_report_type
    into  l_rep_type,
          l_business_group_id,
          l_legislative_parameters;
    close c_get_report_type;

    hr_utility.trace('XML Employee: l_mag_asg_action_id = '
                                  || to_char(l_mag_asg_action_id));
    hr_utility.trace('XML Employee: Transfer Payroll Action Id '||to_number(pay_magtape_generic.get_parameter_value
                                                                         ('TRANSFER_PAYROLL_ACTION_ID')));

    OPEN cur_parameters(l_mag_asg_action_id);
    FETCH cur_parameters
    INTO
      l_arch_action_id,
      l_asg_id,
      l_date_earned;
--    CLOSE cur_parameters;
    if cur_parameters%found then

    hr_utility.trace('XML Employee: l_arch_action_id = '
                                  || to_char(l_arch_action_id));
    hr_utility.trace('XML Employee: l_asg_id = ' || to_char(l_asg_id));
    hr_utility.trace('XML Employee: l_date_earned = '
                                  || to_char(l_date_earned));
    hr_utility.trace('XML Employee: l_province = ' || l_province);

    l_taxation_year := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');

    --Annee
    tab_employee(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' || EOL;


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




    --NoReleve
   /* Check for Mandatory Information RL-2 Slip Number missing */

    IF ( l_rl2_slip_number = '000000000' AND
         l_rl2_slip_number IS NOT NULL)  THEN
      l_status := 'Failed';
      l_msg_code := 'MISSING_SLIP_NO';
      tab_employee(lNoReleve) := NULL;

    ELSE
      tab_employee(lNoReleve) := '<NoReleve>' || pay_ca_rl2_mag.convert_special_char(l_rl2_slip_number) ||
                        '</NoReleve>' || EOL;

    END IF;
    hr_utility.trace('tab_employee(lNoReleve) = ' || tab_employee(lNoReleve));

    -- NAS
   /* Bug Fix 4754891 */
    IF (l_employee_sin IS NOT NULL AND
        l_employee_sin <> '000000000')  THEN


         tab_employee(lNAS) := '<NAS>' || pay_ca_rl2_mag.convert_special_char(l_employee_sin) || '</NAS>' || EOL;

    ELSE
      l_status := 'Failed';
      l_msg_code := 'SIN';
      tab_employee(lNAS) := NULL;

    END IF;
   -- hr_utility.trace('tab_employee(lNAS) = ' || tab_employee(lNAS));

    -- No
    IF (l_employee_number IS NOT NULL AND
        l_employee_number <> '                    ' )  THEN
      tab_employee(lNo) := '<No>' || pay_ca_rl2_mag.convert_special_char(l_employee_number) || '</No>' || EOL;

    ELSE
      tab_employee(lNo) := NULL;

    END IF;
    hr_utility.trace('tab_employee(lNo) = ' || tab_employee(lNo));

    -- NomFamille

    tab_employee(lNomFamille) := '<NomFamille>' ||
                        pay_ca_rl2_mag.convert_special_char(substr(l_employee_last_name,1,30)) || '</NomFamille>' || EOL;
    hr_utility.trace('tab_employee(lNomFamille) = ' || tab_employee(lNomFamille));
l_full_empname := pay_ca_rl2_mag.convert_special_char(substr(l_employee_last_name,1,30));
    -- Prenom
    IF (l_employee_first_name is NOT NULL AND
        l_employee_first_name <> '                              ')  THEN
      tab_employee(lPrenom) := '<Prenom>' || pay_ca_rl2_mag.convert_special_char(substr(l_employee_first_name,1,30))
                                          || '</Prenom>' || EOL;
     l_full_empname := l_full_empname ||','||pay_ca_rl2_mag.convert_special_char(substr(l_employee_first_name,1,30));
    ELSE
      l_msg_code := 'MISSING_EMP_FIRST_NAME';
      l_status := 'Failed';
      tab_employee(lPrenom) := NULL;
    END IF;
    hr_utility.trace('tab_employee(lPrenom) = ' || tab_employee(lPrenom));

    -- Initiale

    IF (l_employee_middle_initial is NOT NULL AND
        l_employee_middle_initial <> ' ') THEN
      tab_employee(lInitiale) := '<Initiale>' || pay_ca_rl2_mag.convert_special_char(substr(l_employee_middle_initial,1,1))
                                              || '</Initiale>' || EOL;
l_full_empname := l_full_empname ||' '||pay_ca_rl2_mag.convert_special_char(substr(l_employee_middle_initial,1,1));
    ELSE
      tab_employee(lInitiale) := NULL;
    END IF;


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

    ELSE

      l_addr_begin_tag := '<Adresse>';

      tab_employee(lLigne1) := '<Ligne1>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_address_line1,1,30)) || '</Ligne1>' || EOL;

      hr_utility.trace('tab_employee(lLigne1) = ' || tab_employee(lLigne1));

      -- Address Line 2

      IF ((l_address_line2 IS NOT NULL AND
           l_address_line2 <> ' ' ) OR
          (l_address_line3 IS NOT NULL AND
           l_address_line3 <> ' ') ) THEN
        l_combined_addr := rtrim(ltrim(l_address_line2)) || rtrim(ltrim(l_address_line3));
        tab_employee(lLigne2) := '<Ligne2>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_combined_addr,1,30)) || '</Ligne2>' || EOL;

      ELSE

           tab_employee(lLigne2) := NULL;

      END IF;
      --hr_utility.trace('tab_employee(lLigne2) = ' || tab_employee(lLigne2));

      -- Ville (City)
      IF l_city IS NOT NULL AND
         l_city <> ' ' THEN
        tab_employee(lVille) := '<Ville>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_city,1,30)) || '</Ville>' || EOL;
       l_full_empaddr := pay_ca_rl2_mag.convert_special_char(substr(l_city,1,30));

      ELSE
        tab_employee(lVille) := NULL;

      END IF;
      --hr_utility.trace('tab_employee(lVille) = ' || tab_employee(lVille));

      -- Province
      IF l_emp_province IS NOT NULL AND
         l_emp_province <> ' '  THEN

         IF l_country = 'CA' THEN
             tab_employee(lProvince) := '<Province>' ||
                                         pay_ca_rl2_mag.convert_special_char(SUBSTR(hr_general.decode_lookup(
                                        'CA_PROVINCE',l_emp_province),1,20)) || '</Province>' || EOL;
             l_full_empaddr := l_full_empaddr ||' '||pay_ca_rl2_mag.convert_special_char(l_emp_province);


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
             pay_ca_rl2_mag.convert_special_char(substr(replace(l_postal_code,' '),1,6)) || '</CodePostal>' || EOL;
      l_full_empaddr := l_full_empaddr ||' '||pay_ca_rl2_mag.convert_special_char(substr(replace(l_country,' '),1,6))||' '||
                                              pay_ca_rl2_mag.convert_special_char(l_postal_code);

    ELSE
      tab_employee(lCodePostal) := NULL;
    END IF;

    hr_utility.trace('tab_employee(lCodePostal) = ' || tab_employee(lCodePostal));
    l_addr_end_tag := '</Adresse>';

    END IF;



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
    l_all_box_0 := FALSE;
    ELSE
      tab_employee(lA_PrestRPA_RPNA ) := NULL;

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
    l_all_box_0 := FALSE;
    ELSE

      tab_employee(lB_PrestREER_FERR_RPDB) := NULL;


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
     l_all_box_0 := FALSE;
    ELSE
      tab_employee(lC_AutrePaiement ) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lD_RembPrimeConjoint) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lE_PrestDeces) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lF_RembCotisInutilise) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lG_RevocationREER_FERR) := NULL;
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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lH_AutreRevenu) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lI_DroitDeduction ) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lJ_ImpotQueRetenuSource ) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lK_RevenuApresDeces ) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lL_RetraitREEP ) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lM_LibereImpot) := NULL;

    END IF;
    hr_utility.trace('tab_employee(lM_LibereImpot) = ' ||
                         tab_employee(lM_LibereImpot));

    -- (Box N)
    -- Bug 5569097 Fix.

    IF l_rl2_box_n IS NOT NULL THEN



           tab_employee(lN_NASConjoint) := '<N_NASConjoint>' ||
                         l_rl2_box_n || '</N_NASConjoint>' || EOL;

    ELSE

          tab_employee(lN_NASConjoint) := NULL;

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

      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lO_RetraitRAP ) := NULL;

    END IF;
   hr_utility.trace('Value of Box O');
   hr_utility.trace('tab_employee(lO_RetraitRAP ) = ' ||
                         tab_employee(lO_RetraitRAP ));


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
                         pay_ca_rl2_mag.convert_special_char(l_rl2_source_of_income) || '</Provenance1>' || EOL;

    ELSE
 /* Commented for Bug 6732992
      l_status := 'Failed';
      l_msg_code := 'MISSING_SOURCE_OF_INCOME';
 */
      tab_employee(lProvenance1) := NULL;

    END IF;
    hr_utility.trace('tab_employee(lProvenance1) = ' ||
                         tab_employee(lProvenance1));
    l_transmitter_org_id := pay_ca_rl2_mag.get_parameter('TRANSMITTER_PRE',
                                               l_legislative_parameters);

    /* For bug 8888411 */
    OPEN c_rl2_src_income(replace(l_rl2_source_of_income,'AUTRE','OTHER'), l_taxation_year);
    FETCH c_rl2_src_income into l_meaning;
    IF c_rl2_src_income%notfound then
       l_status := 'Failed';
       l_msg_code := 'INVALID_SOURCE_OF_INCOME';
    END IF;
    CLOSE c_rl2_src_income;
   /* End 8888411 */

-- Original Slip Number

     OPEN c_original_slipno(l_per_id,l_reporting_year,l_transmitter_org_id);
     FETCH c_original_slipno
     INTO  l_original_slpno;
     CLOSE c_original_slipno;

    IF l_original_slpno = '0' THEN
        tab_employee(l_origi_slipno) := NULL;
      l_status := 'Failed';
      l_msg_code := 'MISSING_SLIP_NO';
    ELSE
        tab_employee(l_origi_slipno) := '<NoReleveDerniereTrans>' ||l_original_slpno|| '</NoReleveDerniereTrans>'||EOL;
    END IF;


    OPEN cur_get_meaning(l_msg_code);
    FETCH cur_get_meaning
    INTO  l_meaning;
    CLOSE cur_get_meaning;

  /* Bug #4747251 Fix */
  IF l_status = 'Failed' THEN


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
          END IF; */

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
                   pay_ca_rl2_mag.convert_special_char(l_meaning) || '</ErrorDetails>' || EOL;
    ELSE
       tab_employee(lErrorDetails) := NULL;
    END IF;

     l_final_xml_string :=
                           '<' || l_status || '>' || EOL ||
                           '<A>' || EOL ||
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
                         '</Montants>' || EOL ||
                         tab_employee(l_origi_slipno)|| '</A>' || EOL ||
                         '</' || l_status || '>' ;

                          hr_utility.trace('Just before Printing the file details ');
                          pay_core_files.write_to_magtape_lob(l_final_xml_string);
  end if; --if cur_parameters%found
  CLOSE cur_parameters;

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
        hr_utility.trace('Inside the Employer Start record proc');
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
    l_report_type           VARCHAR2(20);
    l_business_grpid        NUMBER;
    l_legislative_param     pay_payroll_actions.legislative_parameters%type;
    EOL                     varchar2(5);
    l_employer_name         varchar2(100);
    l_quebec_bn             varchar2(20);
    l_address_line1         per_addresses.address_line1%TYPE;
    l_address_line2         per_addresses.address_line2%TYPE;
    l_city                  per_addresses.town_or_city%TYPE;
    l_province              VARCHAR2(100);
    l_postal_code           per_addresses.postal_code%TYPE;
    l_address_begin_tag     varchar2(10);
    l_address_end_tag       varchar2(10);

 CURSOR get_employer_info( p_business_group_id number,
                          p_pact_id           number) IS
   SELECT nvl(employer_name,'                              '),
          nvl(quebec_business_number,'0000000000  0000'),
          nvl(reporting_year,'0000'),
          nvl(employer_add_line1,'                              '),
          nvl(employer_add_line2,'                              '),
          nvl(employer_city,'                              '),
          nvl(employer_province,'                    '),
          nvl(employer_postal_code,'      ')
   FROM   pay_ca_eoy_rl2_trans_info_v
   WHERE  business_group_id = p_business_group_id
     AND  payroll_action_id = p_pact_id;

  BEGIN
    hr_utility.trace('XML Employer');
    hr_utility.trace('Inside the Employer Main Record proc');

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


    OPEN get_employer_info(l_business_grpid,
                           l_payroll_actid);
    FETCH get_employer_info
    INTO  l_employer_name,
          l_quebec_bn,
          l_taxation_year,
	  l_address_line1,
          l_address_line2,
          l_city,
	  l_province,
	  l_postal_code;

    hr_utility.trace('The Quebec Number is '||l_quebec_bn);
    tab_employer(lNold) := '<NoId>' || pay_ca_rl2_mag.convert_special_char(substr(l_quebec_bn,1,10)) ||
                           '</NoId>' || EOL;
    tab_employer(lTypeDossier) := '<TypeDossier>' || 'RS' ||
                                  '</TypeDossier>' || EOL;

    tab_employer(lNoDossier) := '<NoDossier>' || pay_ca_rl2_mag.convert_special_char(substr(l_quebec_bn,13,4)) ||
                                '</NoDossier>' || EOL;
    hr_utility.trace('The Employer File Number : '|| substr(l_quebec_bn,13,4));

    tab_employer(lNom1) := '<Nom>' ||
                    pay_ca_rl2_mag.convert_special_char(substr(l_employer_name,1,30)) || '</Nom>' || EOL;
    hr_utility.trace('tab_employer(lNom) = ' || tab_employer(lNom1));

    IF (l_address_line1 IS NULL AND
        l_address_line1 <> '                              ' ) THEN

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
                  pay_ca_rl2_mag.convert_special_char(substr(l_address_line1,1,30)) || '</Ligne1>' || EOL;
      hr_utility.trace('tab_employer(lLigne1) = ' || tab_employer(lLigne1));


      -- Address Line 2

      IF (l_address_line2 IS NOT NULL AND
          l_address_line2 <> '                              ' ) THEN
        tab_employer(lLigne2) := '<Ligne2>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_address_line2,1,30)) || '</Ligne2>' || EOL;
      ELSE
        tab_employer(lLigne2) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lLigne2) = ' || tab_employer(lLigne2));

      -- Ville (City)

      IF ( l_city IS NOT NULL AND
           l_city <> '                              ')  THEN
        tab_employer(lVille) := '<Ville>' ||
                  pay_ca_rl2_mag.convert_special_char(substr(l_city,1,30)) || '</Ville>' || EOL;
      ELSE
        tab_employer(lVille) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lVille) = ' || tab_employer(lVille));

      -- Province

      IF ( l_province IS NOT NULL AND
           l_province <> '                    ' ) THEN
        tab_employer(lProvince) := '<Province>' ||
                         pay_ca_rl2_mag.convert_special_char(SUBSTR(hr_general.decode_lookup( 'CA_PROVINCE',
                         l_province),1,20)) || '</Province>' || EOL;
      ELSE
        tab_employer(lProvince) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lProvince) = ' || tab_employer(lProvince));

      -- Postal Code

      IF ( l_postal_code IS NOT NULL AND
           l_postal_code <> '      ' ) THEN
        tab_employer(lCodePostal) := '<CodePostal>' ||
             pay_ca_rl2_mag.convert_special_char(substr(l_postal_code,1,6)) || '</CodePostal>' || EOL;
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

END pay_ca_rl2_amend_mag;

/
