--------------------------------------------------------
--  DDL for Package Body PAY_US_MMREF_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMREF_REPORTING" AS
/* $Header: pyusmmye.pkb 120.18.12010000.5 2008/11/06 06:53:34 svannian ship $ */
/*REM +======================================================================+
REM |                Copyright (c) 1997 Oracle Corporation                 |
REM |                   Redwood Shores, California, USA                    |
REM |                        All rights reserved.                          |
REM +======================================================================+
REM Package Body Name : pay_us_mmref_reporting
REM Package File Name : pay_us_mmref_reporting.pkb
REM Description : This package declares functions and procedures to support
REM the genration of magnetic W2 reports for US legislative requirements
REM incorporating magtape resilience and the new end-of-year processing.
REM
REM Change List:
REM ------------
REM
REM Name        Date       Version Bug         Text
REM ---------   ---------- ------- ----------- ------------------------------
REM djoshi      24-aug-2001 40.01               Created
REM djoshi      20-sep-2001 40.02               Modified the files to
REM                                             use Core Message Functions
REM djoshi      16-nov-2001 115.3               Made changes for YE 2001
REM djoshi                                            Phase II
REM djoshi      03-dec-2001 115.5               changed to code for dbdrv
REM djoshi      05-dec-2001 115.6               Added the Check for State
REM                                             tax rules Checking
REM djoshi      17-jan-2002 115.7  2190825      Changed the code for bug
REM djoshi      21-jan-2002 115.8               Added checkfile:
REM fusman      02-jul-2002 115.6  2296797      Added legislation Code
REM asasthan    11-NOV-2002 115.12 2586041      Added Index hint
REM                                             INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1)
REM djoshi	13-nov-2002 115.13              Changed the local variable to be char
REM                                             to overcome convertion problems in
REM                                             9i database.
REM ppanda      02-DEC-2002 115.14                 Nocopy hint added to OUT and IN OUT parameters
REM ppanda      20-Jan-2003 115.15 2736928      For PuertoRico a validation added in Preprocess to check
REM                                             whether Control Number defined or not. If Control number
REM                                             not defined process will Error out
REM ppanda      22-Jan-2003 115.16              For PuertoRico a separate cursor added to create assignment
REM ppanda      20-Oct-2003 115.18 3069840      Federal/State W-2 Mag tapes should issue warning if GRE
REM                                             is not archived
REM tmehra      10-Nov-2003 115.19 2778457      Federal Mag not picking up
REM                                             the employees with 0 gorss.
REM                                             Added check for SS Medicare
REM                                             and FIT balances.
REM tmehra      26-Nov-2003 115.20 2219097      Added a new function for Govt
REM                                             Employer W2 changes
REM                                                - get_report_category
REM tmehra      01-Dec-2003 115.21 2219097      Added the new category 'RG'
REM                                             to the cursor c_transmitter
REM ppanda      14-DEC-2003 115.22 2778457      A_GROSS_EARNINGS_PER_GRE_YTD was added
REM                                             to csr_get_fed_Wages cursor as fix for this
REM                                             bug was breaking FED W-2. This cursor is used for
REM                                             checking balances for creating assignment for FED W-2
REM tmehra      29-DEC-2003 115.23 2778457      Added FIT Subject balance
REM                                             check and removed the
REM                                             Gross Earnings check from
REM                                             Fed Mag Tape.
REM asasthan    30-JUL-2004 115.25 3343633      Part of preprocess check was
REM                                                                        removed earlier but the cursors
REM                                                                        c_gre_fed, c_gre_state were
REM                                                                        not removed and resulted
REM                                                                        in 11510 bug on performance.
REM                                                                        These cursors are now being
REM                                                                        removed.
REM asasthan    30-JUL-2004 115.26 3343633      Removed +0 from c_get_gre(bgid)
REM pragupta    22-JUL-2005 115.27 4344872      cursor c_person_in_state removed. It was a redundant
REM                                                                         cursor and was not used any where in the package.
REM pragupta    36-OCT-2005 115.28 4490252    Commented out the code for checking highly paid
REM                                                                        person in the create_assignment_act procedure.
REM
REM djoshi        14-feb-2005 115.29  5009863         Changed state and federal Cursor
REM                                                                         to join paa.serial_number
REM ppanda      31-JUL-2006 115.30                     Federal W-2 Mag tapes to support multi thread architecture
REM                                                                         A new function get_report_category_multi_thread would be
REM                                                                         used to derive the report category for the new concurrent
REM                                                                         program.
REM ppanda      28-AUG-2006 115.31                   Three New formula function added to the package
REM                                                                    for   Federal W-2 Magnetic Media MultiThread process
REM
REM sudedas     08-NOV-2006  115.32  5099892   range_cursor and create_assignment_act
REM                                            has been changed for State of Indiana
REM                                            so that EE is eligible to be included
REM                                            in Tape when County Withheld is non-zero
REM                                            even when State Wage is zero.
REM                                  5630156   Removed the check of State Code
REM                                            in pay_us_state_tax_info_f within
REM                                            cursor c_state of create_assignment_act
REM                                            due to Performance Issue.
REM sudedas     13-NOV-2006  115.33  5648738   range_cursor and create_assignment_act
REM                                            has been changed for State of Ohio
REM                                            to include EE with non-zero School Withheld.
REM                                            Also corrected jurisdiction_level for IN
REM ppanda	   12-DEC-2006   115.35      Federal W-2 Multithread ver was resulting
REM                                                             decimal values in RT due to rounding issues.
REM							      function get_w2_er_arch_bal modified for rounding
REM				                             Bug # 5711922 fixed to resolve the RT record
REM ppanda       13-DEC-2006  115.36      Function modified b  adding additional parameters
REM							     assignment_action_id, p_tax_jd_code, p_tax_unit_info1 and , p_tax_unit_info2
REM                                                             This is to fix Bug # 5709609
REM ppanda	     14-DEC-2006 115.38      Function get_w2_er_arch_bal changed for rounding the values
REM ppanda        14-DEC-2006 115.39      Function get_w2_er_arch_bal modified to count Error out RW record
REM
REM ppanda        15-DEC-2006 115.40      Function get_w2_er_arch_bal modified for SS Wages
REM							     and Non-qualified Plan Not Section 457 Distributions
REM sudedas       02-Jan-2007 115.41  5739737   Changed range_cursor and create_assignment_act
REM                                             for Indiana and Ohio to pass correct Jurisdiction
REM                                             Context.
REM ppanda        11-JAN-2007 115.42            For erroring out employee and moving employee details to a02
REM                                             a new parameter added to set_application_error
REM                                             The new parameter is Assingnment_action_id
REM tclewis       14-dec-2007 115.43  6695132   Type cast the numeric varisables p_stperson and p_endperson
REM                                             in the cursors create_assignment_act procedure.
REM svannian      02-jan-2008 115.44  6712859   Remove the Type cast since Federal W2 Magnetic Media
REM                                             did not have correct income numbers.
REM svannian      20-feb-2008 115.45  6809739   state w2 to pick up employees when
REM                                             either sit wages or sit tax is greater than zero.
REM svannian      22-mar-2008 115.46  6868340   federal w2 to pick up employees when
REM                                             either fit wages or fit tax is greater than zero.
REM svannian      29-may-2008 114.47  7109106   PR GTL amount should not be included in RT record.
REM ========================================================================
REM

  -----------------------------------------------------------------------------
  --   Name       : bal_db_item
  --   Purpose    : Given the name of a balance DB item as would be seen in a
  --                fast formula it returns the defined_balance_id of the
  --                  balance it represents.
  --   Arguments
  --       INPUT  : p_db_item_name
  --      returns : l_defined_balance_id
  --   Notes
  --                A defined_balance_id is required by the PLSQL balance function.
  -----------------------------------------------------------------------------
*/
FUNCTION bal_db_item
       ( p_db_item_name VARCHAR2
       ) RETURN NUMBER IS
	-- Get the defined_balance_id for the specified balance DB item.
	CURSOR csr_defined_balance IS
	  SELECT TO_NUMBER(UE.creator_id)
	    FROM ff_database_items DI,
	         ff_user_entities UE
	   WHERE DI.user_name = p_db_item_name
	     AND UE.user_entity_id = DI.user_entity_id
	     AND UE.creator_type = 'B'
             AND UE.legislation_code = 'US'; /* Bug:2296797 */
	l_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;
BEGIN
	hr_utility.set_location
	           ('pay_us_mmref_reporting.bal_db_item - opening cursor', 10);
        -- Open the cursor
	OPEN csr_defined_balance;
        -- Fetch the value
	FETCH  csr_defined_balance
	 INTO  l_defined_balance_id;
 	IF csr_defined_balance%NOTFOUND THEN
		CLOSE csr_defined_balance;
		hr_utility.set_location
		('pay_us_mmref_reporting.bal_db_item - no rows found from cursor', 20);
		hr_utility.raise_error;
	ELSE
		hr_utility.set_location
		('pay_us_mmref_reporting.bal_db_item - fetched from cursor', 30);
		CLOSE csr_defined_balance;
	END IF;
        /* Return the value to the call */
	RETURN (l_defined_balance_id);
END bal_db_item;
 -----------------------------------------------------------------------------
   -- Name     : :get_report_parameters
   --
   -- Purpose
   --   The procedure gets the 'parameter' for which the report is being
   --   run i.e., the period, state and business organization.
   --
   -- Arguments
   --   p_year_start		Start Date of the period for which the report
   --				has been requested
   --   p_year_end		End date of the period
   --   p_business_group_id	Business group for which the report is being run
   --   p_state_abbrev		Two digit state abbreviation (or 'FED' for federal
   --				report)
   --   p_state_code		State code (NULL for federal)
   --   p_report_type		Type of report being run (FEDW2, STW2, 1099R ...)
   --
   -- Notes
 ----------------------------------------------------------------------------

        PROCEDURE get_report_parameters
	(	p_pactid    		IN		NUMBER,
		p_year_start		IN OUT	nocopy DATE,
		p_year_end		IN OUT	nocopy DATE,
		p_state_abbrev		IN OUT	nocopy VARCHAR2,
		p_state_code		IN OUT	nocopy VARCHAR2,
		p_report_type		IN OUT	nocopy VARCHAR2,
		p_business_group_id	IN OUT	nocopy NUMBER
	) IS
	BEGIN
		hr_utility.set_location
		('pay_us_mmref_reporting.get_report_parameters', 10);
		SELECT  ppa.start_date,
			ppa.effective_date,
		  	ppa.business_group_id,
		  	ppa.report_qualifier,
		  	ppa.report_type
		  INTO  p_year_start,
	  		p_year_end,
			p_business_group_id,
			p_state_abbrev,
			p_report_type
		  FROM  pay_payroll_actions ppa
	 	 WHERE  payroll_action_id = p_pactid;
	 	IF p_state_abbrev <> 'FED' THEN
			SELECT state_code
			INTO p_state_code
			FROM pay_us_states
			WHERE state_abbrev = p_state_abbrev;
			hr_utility.set_location
			('pay_us_mmref_reporting.get_report_parameters', 20);
		ELSE
			p_state_code := '';
			hr_utility.set_location
			('pay_us_mmref_reporting.get_report_parameters', 30);
		END IF;
		IF p_state_abbrev = 'FED' AND p_report_type = 'W2' THEN
			p_report_type := 'FEDW2';
		ELSIF p_report_type = 'W2' THEN
			p_report_type := 'STW2';
		END IF;
		hr_utility.set_location
		('pay_us_mmref_reporting.get_report_parameters', 40);
	END get_report_parameters;
        -------------------------------------------------------------------------
        --  Name     :  get_balance_value
        --
        --Purpose
        --  Get the value of the specified balance item
        --Arguments
        --  p_balance_name 			Name of the balnce
        --  p_tax_unit_id			GRE name for the context
        --  p_state_code			State for context
        --  p_assignment_id			Assignment for whom the balance is to be
        --					retrieved
        --  p_effective_date			effective_date
        --Note
        --  This procedure set is a wrapper for setting the GRE/Jurisdiction context
        --  needed by the pay_balance_pkg.get_value to get the actual balance
        -------------------------------------------------------------------------
	FUNCTION get_balance_value (
		p_balance_name		VARCHAR2,
		p_tax_unit_id		NUMBER,
		p_state_abbrev		VARCHAR2,
		p_assignment_id		NUMBER,
		p_effective_date	DATE
	) RETURN NUMBER IS
		l_jurisdiction_code		VARCHAR2(20);
	BEGIN
	hr_utility.set_location
		('pay_us_mmref_reporting.get_balance_value', 10);
		pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
	IF p_state_abbrev <> 'FED' THEN
			SELECT jurisdiction_code
			  INTO l_jurisdiction_code
			  FROM pay_state_rules
		  	 WHERE state_code = p_state_abbrev;
     			hr_utility.set_location
			('pay_us_mmref_reporting.get_balance_value', 15);
			pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction_code);
	END IF;
	hr_utility.trace(p_balance_name);
	hr_utility.trace('Context');
	hr_utility.trace('Tax Unit Id:	'|| p_tax_unit_id);
	hr_utility.trace('Jurisdiction:	'|| l_jurisdiction_code);
	hr_utility.set_location
		('pay_us_mmref_reporting.get_balance_value', 20);
	RETURN pay_balance_pkg.get_value(bal_db_item(p_balance_name),
			p_assignment_id, p_effective_date);
	END get_balance_value;
        --------------------------------------------------------------------------
        --Name
        --  preprocess_check
        --Purpose
        --  This function checks if the year end preprocessor has been run for the
        --  GREs involved in the W2 report. It also checks if any of the assignments
        --  have errored out or have been marked for retry.
        --
        --Arguments
        --  p_pactid		   payroll_action_id for the report
        --  p_year_start	   start date of the period for which the report
        --			   has been requested
        --  p_year_end	   end date of the period
        --  p_business_group_id  business group for which the report is being run
        --  p_state_abbrev	   two digit state abbreviation (or 'FED' for federal
        --		   	   report)
        --  p_state_code	   state code (NULL for federal)
        --  p_report_type	   type of report being run (W2, 1099R ...)
        --
        --Notes
        --  The check for 'errored'/'marked for retry'assignments can be bypassed by
        --  setting the parameter 'FORCE_MAG_REPORT' to 'E' and 'M' respectively. In
        --  such cases the report will ignore the assignments in question.
        -----------------------------------------------------------------------------
        FUNCTION preprocess_check
        (
           p_pactid 			NUMBER,
           p_year_start		        DATE,
           p_year_end			DATE,
           p_business_group_id	        NUMBER,
           p_state_abbrev		VARCHAR2,
           p_state_code		        VARCHAR2,
           p_report_type		VARCHAR2
        )
        RETURN BOOLEAN IS
        -- Cursor to get all the GREs belonging to the given business group
        CURSOR 	c_get_gre IS
        SELECT 	hou.organization_id gre
          FROM 	hr_organization_information hoi,
                hr_all_organization_units hou
         WHERE	hou.business_group_id = p_business_group_id AND
                hoi.organization_id = hou.organization_id AND
                hoi.org_information_context = 'CLASS' AND
                hoi.org_information1 = 'HR_LEGAL' AND
         NOT EXISTS (
             SELECT  'Y'
               FROM hr_organization_information
              WHERE organization_id = hou.organization_id
                AND org_information_context = '1099R Magnetic Report Rules');

           --    Check if the GRE needs to be archived.
           -- Cursor to fetch people in a given GRE with earnings in the given state to

          CURSOR c_tax_ein
              IS
          SELECT  user_entity_id  from ff_user_entities
           WHERE user_entity_name =  'A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER';



          -- Cursor to fetch people from the GRE belonging to the business group



        -- Cursor to get payroll_action_ids of the pre-process for the given GRE.
        -- This will also serve as a check to make sure that all GREs have been
        -- archived
        CURSOR c_gre_payroll_action (cp_gre NUMBER)
            IS
        SELECT payroll_action_id
          FROM pay_payroll_actions
         WHERE report_type = 'YREND'
           AND effective_date = p_year_end
           AND start_date = p_year_start
           AND business_group_id+0 = p_business_group_id
           AND SUBSTR(legislative_parameters,
               INSTR(legislative_parameters, 'TRANSFER_GRE=') +
               LENGTH('TRANSFER_GRE=')) = TO_CHAR(cp_gre)
                -- ADDED FOLLOWING CHECK CONDITION
           AND action_status = 'C';

          --Cursor for checking if any of the the archiver has errored for
      	  --any of the assignments for federal W

          CURSOR c_arch_errored_asg (cp_payroll_action_id NUMBER) IS
          SELECT '1'
            FROM dual
           WHERE EXISTS  (SELECT '1'
                            FROM pay_assignment_actions paa
                           WHERE paa.payroll_action_id =  cp_payroll_action_id
                             AND paa.action_status = 'E'
                          )
           AND NOT EXISTS ( SELECT '1'
                              FROM pay_action_parameters
                             WHERE parameter_name = 'FORCE_MAG_REPORT'
                               AND INSTR(parameter_value, 'E') > 0
                           );
	--Cursor for checking if any of the assignments have been marked for retry

        CURSOR c_arch_retry_pending (cp_payroll_action_id NUMBER) IS
        SELECT '1'
          FROM dual
         WHERE EXISTS  (SELECT '1'
                          FROM pay_assignment_actions paa
                         WHERE paa.payroll_action_id = cp_payroll_action_id
                          AND paa.action_status = 'M')
           AND NOT EXISTS (SELECT '1'
                             FROM pay_action_parameters
                            WHERE parameter_name = 'FORCE_MAG_REPORT'
                              AND INSTR(parameter_value, 'R') > 0
                          );

       /* cursor to get user_entity_id */
        CURSOR c_user_entity_id_of_bal
            IS
        SELECT user_entity_id
          FROM  ff_database_items fdi
         WHERE user_name = 'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD' ;


      /* cursor to get_context_of_tax_unit_id */
         CURSOR c_context_tax_unit_id
             IS
         SELECT context_id
           FROM ff_contexts
          WHERE context_name = 'TAX_UNIT_ID';

         /* cursor to get context of jurisdiction */
        CURSOR c_context_jurisdiction
            IS
        SELECT context_id
          FROM ff_contexts
         WHERE context_name = 'JURISDICTION_CODE';

        /* cursor to check if the state tax Rules have been added or Not. */
        CURSOR c_chk_archive_state_code(cp_tax_unit_id number,cp_payroll_action_id number)
            IS
        SELECT 'Y'
          FROM ff_archive_item_contexts con3,
               ff_archive_item_contexts con2,
               ff_contexts fc3,
               ff_contexts fc2,
               ff_archive_items target,
               ff_database_items fdi
         WHERE target.context1 = to_char(cp_payroll_action_id)
                  /* context of payroll_action_id */
           AND fdi.user_name = 'A_FIPS_CODE_JD'
           AND target.user_entity_id = fdi.user_entity_id
           AND fc2.context_name = 'TAX_UNIT_ID'
           AND con2.archive_item_id = target.archive_item_id
           AND con2.context_id = fc2.context_id
           AND ltrim(rtrim(con2.context)) = to_char(cp_tax_unit_id)
           AND fc3.context_name = 'JURISDICTION_CODE'
           AND con3.archive_item_id = target.archive_item_id
           AND con3.context_id = fc3.context_id
           AND substr(ltrim(rtrim(con3.context)),1,2) = p_state_code;
                                /* jurisdiction code of the state */

       /* cursor to get if transmitter has been been archived */

        CURSOR c_transmitter IS
        SELECT  SUBSTR(legislative_parameters,INSTR(legislative_parameters, 'TRANSFER_TRANS_LEGAL_CO_ID=')
                + LENGTH('TRANSFER_TRANS_LEGAL_CO_ID='),
                (INSTR(legislative_parameters, 'TRANSFER_DATE=')
                 - INSTR(legislative_parameters, 'TRANSFER_TRANS_LEGAL_CO_ID=')
                 - LENGTH('TRANSFER_TRANS_LEGAL_CO_ID=')-1 ))
          FROM pay_payroll_actions
         WHERE report_type = 'W2'
           AND effective_date = p_year_end
           AND report_qualifier = p_state_abbrev
          AND business_group_id = p_business_group_id
          AND report_category IN ('RG', 'RM', 'MT') ;


       /* LoCal variables used for processing */
        message_text                          VARCHAR2(32000);
        message_preprocess                   varchar2(2000);
       	l_gre				      NUMBER(15);
	l_person			      NUMBER(15);
	l_assignment		   	      NUMBER(15);
	l_asg_effective_dt		      DATE;
	l_payroll_action_id		      NUMBER(15);
	l_asg_errored			      VARCHAR2(1);
	l_asg_retry_pend		      VARCHAR2(1);
	l_balance_exists 		      NUMBER(1) := 0;
	l_no_of_gres_picked		      NUMBER(15) := 0;
        l_transmitter                         NUMBER(15) :=0;
        l_state_tax_rules_exist   CHAR(1);
        l_person_in_state         CHAR(1);
        l_user_entity_id          number;
        l_context_jursidiction    number;
        l_context_tax_unit_id     number; --ff_contexts.context_id%type;
        l_package_error_status    char(1) := 'N';
        l_ein                     number;
        l_ein_result              varchar2(30);
        BEGIN

        /* One Time Setting of Pre-Process Message */
          message_preprocess := 'Pre-Process check';

        /* GET the Employer EIN */
        OPEN c_tax_ein;
         FETCH c_tax_ein INTO l_ein;
         IF c_tax_ein%NOTFOUND THEN
            CLOSE c_tax_ein;
            l_package_error_status := 'Y';
            hr_utility.trace('A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER missing ');
            message_text := 'EIN ID missing ';
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',message_preprocess);
            pay_core_utils.push_token('description',message_text);
            hr_utility.raise_error;
         ELSE
              CLOSE c_tax_ein;
         END IF;


        /* GET the context and user entity id */
         OPEN  c_user_entity_id_of_bal;
         FETCH c_user_entity_id_of_bal INTO l_user_entity_id;
         IF c_user_entity_id_of_bal%NOTFOUND THEN
                 CLOSE c_user_entity_id_of_bal;
              l_package_error_status := 'Y';
              /* message to user -  Database item missing */
              hr_utility.trace('Database item for balacne missing ');
              message_text := '-Database item missing ';
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',message_preprocess);
              pay_core_utils.push_token('description',message_text);
              hr_utility.raise_error;
         ELSE
              CLOSE c_user_entity_id_of_bal;
         END IF;

         OPEN  c_context_tax_unit_id;
         FETCH c_context_tax_unit_id INTO l_context_tax_unit_id;
         IF c_context_tax_unit_id%NOTFOUND THEN
              CLOSE c_context_tax_unit_id;
              /* message to user -- unable to find the context_id for tax_unit_id */
              message_text := 'Context_id value for tax_unit_id missing';
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',message_preprocess);
              pay_core_utils.push_token('description',message_text);
              hr_utility.raise_error;
         ELSE
                     CLOSE c_context_tax_unit_id;
         END IF;

         OPEN  c_context_jurisdiction;
         FETCH c_context_jurisdiction INTO l_context_jursidiction;
         IF    c_context_jurisdiction%NOTFOUND THEN
                 CLOSE c_context_jurisdiction;
                 /* message to User -- Unable to find to context_id for jurisdiction */

                 message_text := 'Context_id value for jurisdiction  missing';
                 hr_utility.trace('Contxt_id value for jurisdction_id missing');
                 pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                 pay_core_utils.push_token('record_name',message_preprocess);
                 pay_core_utils.push_token('description',message_text);
                 hr_utility.raise_error;
         ELSE
              CLOSE c_context_jurisdiction;
         eND IF;
         /* Get the Tranmitter id of the Current Mag. W2. and check if it has
            archived or Not for the year End process
            Get the transmitter for the Mag. W2. Process. */
         OPEN c_transmitter;
         FETCH c_transmitter INTO l_transmitter;
         IF c_transmitter%NOTFOUND THEN
               CLOSE c_transmitter;
                /* message to user -- transmitter has not been defined for the gre */
                    message_text := 'Transmitter Not denfined';
                 pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                 pay_core_utils.push_token('record_name',message_preprocess);
                 pay_core_utils.push_token('description',message_text);
                 hr_utility.raise_error;
         ELSE
              CLOSE c_transmitter;
         END IF;

         hr_utility.trace('Transmetter Setting is ' || to_char(l_transmitter));
         hr_utility.trace('Start date ' || to_char(p_year_start));
         hr_utility.trace('End date '   || to_char(p_year_end));
         hr_utility.trace('Bussiness_group id ' || to_char(p_business_group_id));


          /* Check if Archiver has been run for Transmitter */
          OPEN c_gre_payroll_action (l_transmitter);
          FETCH c_gre_payroll_action INTO l_payroll_action_id;

	   IF c_gre_payroll_action%NOTFOUND THEN
               hr_utility.trace('Transmitter not Archvied ');
              CLOSE c_gre_payroll_action;
               /* message to user -- Transmitter has not been archived */
              message_text := 'Transmitter not Archived';
              hr_utility.trace('Transmitter has not been archived');
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',message_preprocess);
              pay_core_utils.push_token('description',message_text);
                 -- hr_utility.raise_error;
           END IF;
                 CLOSE c_gre_payroll_action;

         /* end of Transmitter Checking */

        hr_utility.set_location('pay_us_mmref_reporting.preprocess_check', 10);

       FOR gre_rec IN c_get_gre LOOP
           /* set l_gre to gre Fethched */

           l_gre := gre_rec.gre;

           /* Get the payroll_action_id of the archvier for given GRE */

           OPEN c_gre_payroll_action (l_gre);
           FETCH c_gre_payroll_action INTO l_payroll_action_id;

           /* Check for the Gre That have been Archived */

	   IF c_gre_payroll_action%FOUND THEN

              /* Check if any of the payroll_action_id has errored out or Not */

              OPEN  c_arch_errored_asg (l_payroll_action_id);
              FETCH c_arch_errored_asg
                 INTO l_asg_errored;

              IF c_arch_errored_asg%FOUND THEN
                  message_text := 'Assignment in Error Conditon for GRE:= ' || to_char(l_gre);
                  pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                  pay_core_utils.push_token('record_name',message_preprocess);
                  pay_core_utils.push_token('description',message_text);
                    --Some of the assignments have Errored
                  l_package_error_status := 'Y';
                  /* message to user --  assignment has errored out  */
                    --
                    -- hr_utility.raise_error;
              END IF;
              CLOSE c_arch_errored_asg;

              /* Checking for Retry */

              OPEN c_arch_retry_pending (l_payroll_action_id);
              FETCH c_arch_retry_pending INTO l_asg_retry_pend;
              IF c_arch_retry_pending%FOUND THEN
                 --Some of the assignments have been marked for retry
                  message_text := 'Assignment Marked for Retry: GRE_ID := ' || to_char(l_gre);
                  pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                  pay_core_utils.push_token('record_name',message_preprocess);
                  pay_core_utils.push_token('description',message_text);
                  l_package_error_status := 'Y';
                  --  hr_utility.raise_error;

              END IF;

              CLOSE c_arch_retry_pending;

              hr_utility.trace('GRE:' || TO_CHAR(l_gre));
	      hr_utility.trace('Payroll_action_id - '|| to_char(l_payroll_action_id));
	      hr_utility.trace('No. of GREs picked so far - '|| to_char(l_no_of_gres_picked));

              l_no_of_gres_picked := l_no_of_gres_picked + 1;
              /* All the condition have been met  so it is safe to make Arhive
                 Call
              */

                IF p_report_type = 'FEDW2' THEN --federal W2
                   archive_eoy_data(l_payroll_action_id,l_gre);
                ELSE
                   hr_utility.trace('Federal smart archive call');
                   archive_eoy_data(l_payroll_action_id,l_gre);
                   hr_utility.trace('State Code :- ' || p_state_code);
                   hr_utility.trace('GRE - ' || to_char(l_gre));
                   hr_utility.trace('Before calling Smart State Archive');
                   archive_state_eoy_data(l_payroll_action_id,l_gre,p_state_code);
                   hr_utility.trace('After call to state Archive');
                END IF;

                   hr_utility.trace('After Call to smart Archive ');

                   /* Check EIN for the Employee */

                IF p_report_type = 'FEDW2' THEN --federal W2
                   /* Check for Federal Data */
                   l_ein_result := check_er_data(l_payroll_action_id,l_gre);

                   IF l_ein_result = 'N'THEN
                      message_text := 'EIN for GRE:= ' || to_char(l_gre)  || 'Not Set';
                      pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                      pay_core_utils.push_token('record_name',message_preprocess);
                      pay_core_utils.push_token('description',message_text);
                      l_package_error_status := 'Y';
                   END IF;
                ELSE
                  /* If Report type is not Fed so state */
                  /* Check for State  */
                    --   OPEN c_chk_archive_state_code (l_gre,l_payroll_action_id);
                    --   FETCH c_chk_archive_state_code INTO l_state_tax_rules_exist;
                   --    IF c_chk_archive_state_code%NOTFOUND THEN
                   --       hr_utility.trace('State Tax Rules not Found ');
                   --       /*  state Tax Rules have not been Defined  */
                   --       message_text :=   'State Tax Rules not Defind for GRE '
                   --                   || to_char(l_gre) || ' for ' || P_state_abbrev;
                   --        pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                   --        pay_core_utils.push_token('record_name',message_preprocess);
                   --        pay_core_utils.push_token('description',message_text);
                   --        l_package_error_status := 'Y';
                   --      END IF; /* Missing State Tax Rules */
                   --
                   --      close c_chk_archive_state_code;

                    /* Do check_er_data only if Record exist */
                    /* Add those checks for current Year */
                       hr_utility.trace('Check the State ER data ');
                  -- l_ein_result := check_state_er_data(l_payroll_action_id,l_gre,p_state_code);
                  -- hr_utility.trace('return value for check_state_er_data ' || l_ein_result );
                   /* EIN check Failed  */
                  -- IF l_ein_result = 'N'THEN
                  --   hr_utility.trace('ID missing in State Tax Rules' || to_char(l_gre));
                  --   message_text := 'Missing ID in State Tax Rules for GRE:= '|| to_char(l_gre);
                  --   pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                  --   pay_core_utils.push_token('record_name',message_preprocess);
                  --   pay_core_utils.push_token('description',message_text);
                  --    l_package_error_status := 'Y';
                 --  END IF;
                END IF;

           ELSE
             /* The GRE has not been archived so check for valid Persons in the GRE
                who have been paid for the run YEAR
                Open Cursor as per your Report type to check if GRE needs to be archived
                or Not */
       /*  Federal/State W2 Mag tapes should issue warning if GRE is not archived
           Bug # 3069840
           This is No loger an Pre-precess check Error. Pre-process check shuld log a
           Warning an proceed to genrate W2 Mag Tape
       */


       /* Code commented to fix Bug # 3069840

                IF p_report_type = 'FEDW2' THEN    --federal W2
                    hr_utility.set_location('pay_us_mmref_reporting.preprocess_check', 99);
		            OPEN c_gre_fed(gre_rec.gre);
                ELSIF   p_report_type = 'STW2' THEN --state W2
 		            OPEN c_gre_state(gre_rec.gre);
                END IF;

                -- For GRE Find_out if any person has balance greater then Zero

                LOOP  --Main Loop
	            IF p_report_type = 'FEDW2' THEN
                       --  Start feching Persons for GRE
	            FETCH c_gre_fed INTO l_person
	                            ,l_assignment
 	                            ,l_asg_effective_dt;
                   hr_utility.set_location('pay_us_mmref_reporting.preprocess_check',20);
                   hr_utility.trace('GRE:' || TO_CHAR(l_gre));
                   hr_utility.trace('Assignment ID:' || TO_CHAR(l_assignment));
                   hr_utility.trace('Person ID:' || TO_CHAR(l_person));
                   hr_utility.trace('Effective Date:' || TO_CHAR(l_asg_effective_dt));
                       IF c_gre_fed%NOTFOUND THEN
                       -- get out of the Main Loop if You have reached No person Found
                             EXIT;
                       END IF;
	            END IF;     -- report type = 'FEDW2'

                    IF p_report_type = 'STW2' THEN
                         FETCH c_gre_state INTO l_person
                                               ,l_assignment
                                               ,l_asg_effective_dt;

                          hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 40);
                          hr_utility.trace('GRE:' || TO_CHAR(l_gre));
                          hr_utility.trace('Assignment ID:' || TO_CHAR(l_assignment));
                          hr_utility.trace('Person ID:' || TO_CHAR(l_person));
                          hr_utility.trace('Effective Date:' || TO_CHAR(l_asg_effective_dt));
                          -- No Person Was found for the State So Exit
                          IF c_gre_state%NOTFOUND THEN
                              EXIT;
                          END IF;
                    END IF; -- report type = 'STW2' and etc


                    hr_utility.trace('pay_us_mmref_reporting.preprocess_check');
                    hr_utility.trace('GRE - '||to_char(l_gre));

                    -- get the balance for person

                    IF p_report_type = 'FEDW2' THEN
                         IF get_balance_value('GROSS_EARNINGS_PER_GRE_YTD',
                                        l_gre, p_state_abbrev, l_assignment,
                                        LEAST(p_year_end, l_asg_effective_dt)) > 0 THEN
                                  l_balance_exists := 1;
                          END IF;
                    END IF; -- End of report_type 'FEDW2'


                    IF p_report_type = 'STW2' THEN
                         IF get_balance_value('GROSS_EARNINGS_PER_GRE_YTD',
                                        l_gre, p_state_abbrev, l_assignment,
                                        LEAST(p_year_end, l_asg_effective_dt)) > 0 AND
                            get_balance_value('SIT_GROSS_PER_JD_GRE_YTD',
                                          l_gre, p_state_abbrev, l_assignment,
                                          LEAST(p_year_end, l_asg_effective_dt)) > 0 THEN
                            l_balance_exists := 1;
                         END IF; -- balance Greater then Zero Exist
                END IF;


                    IF l_balance_exists = 1 then
                              --It means that no archived GRE was
		              --found for the GRE. This is an error.
                         IF  p_report_type = 'FEDW2' THEN

                             close c_gre_fed;
                         ELSE
                             close c_gre_state;
                         END IF; -- End Of Report_type 'FEDW2'
                         hr_utility.trace('Archive_Gre ' || to_char(l_gre));
                         -- Person Found with Balance for given GRE
                         message_text := 'GRE_ID := ' || to_char(l_gre)
                                                      || ' has People with Balnace > 0';
                         pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                         pay_core_utils.push_token('record_name',message_preprocess);
                         pay_core_utils.push_token('description',message_text);

                         message_text := 'Please Archive GRE With ID := ' || to_char(l_gre) ;
                         pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
                         pay_core_utils.push_token('record_name',message_preprocess);
                         l_package_error_status := 'Y';
                    END IF;
                          l_balance_exists := 0;

                END LOOP;  --Main Loop
                -- You have checked that We dont have any person with
                -- balance greater then Zero
                --
                      IF  p_report_type = 'FEDW2' THEN
                          close c_gre_fed;
                      ELSE
                          close c_gre_state;
                       END if;
        -- End of Comment for Bug # 3069840
        */

        /*  A warning is logged if GRE is not archived  Buug # 3069840 */
                    l_package_error_status := 'N';
                    message_text := 'Please Archive GRE With ID := ' || to_char(l_gre) ;
                    pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA_WARNING','P');
                    pay_core_utils.push_token('record_name',message_preprocess);
                    pay_core_utils.push_token('description',message_text);

           END IF;  --end if for checking of person balance if the GRE has
                    --not been archived.

           CLOSE c_gre_payroll_action;

	END LOOP;  /* end of for statement */

    IF l_package_error_status = 'Y' THEN
              hr_utility.trace('Error Condition Found');
              message_text := 'Error Condition detected ' ;
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',message_preprocess);
              pay_core_utils.push_token('description',message_text);

              message_text := 'Pay Message line  and log have more Details' ;
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',message_preprocess);
              pay_core_utils.push_token('description',message_text);
              hr_utility.raise_error;
     END IF;

     IF l_no_of_gres_picked = 0 THEN
           --It means that no archived GRE was
           --found for the Organization. This is an error.

              message_text := 'No GRE was picked for Magnetic Tape';
              pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
              pay_core_utils.push_token('record_name',message_preprocess);
              pay_core_utils.push_token('description',message_text);
              hr_utility.raise_error;
     END IF;

	RETURN TRUE;
        hr_utility.trace('Succesful - Return True ');
exception
   when others then
              -- add message for this
                 message_text := message_text || '+  Exception';
                 hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
                 hr_utility.set_message_token('MESSAGE', message_text);
                 hr_utility.raise_error;

END preprocess_check;
--
  ----------------------------------------------------------------------------
  --Name
  --  range_cursor
  --Purpose
  --  This procedure calls a function to check if the pre-processor has been
  --  run for all the GREs and assignments. It then defines a SQL statement
  --  to fetch all the people to be included in the report. This SQL statement
  --  is  used to define the 'chunks' for multi-threaded operation
  --Arguments
  --  p_pactid			payroll action id for the report
  --  p_sqlstr			the SQL statement to fetch the people
------------------------------------------------------------------------------
PROCEDURE range_cursor (
	p_pactid	IN	   NUMBER,
	p_sqlstr	OUT nocopy VARCHAR2
)
IS
	p_year_start			DATE;
	p_year_end				DATE;
	p_business_group_id		NUMBER;
	p_state_abbrev			VARCHAR2(3);
	p_state_code			VARCHAR2(2);
	p_report_type			VARCHAR2(30);
BEGIN

	hr_utility.set_location( 'pay_us_mmref_reporting.range_cursor', 10);
	get_report_parameters(
		p_pactid,
		p_year_start,
		p_year_end,
		p_state_abbrev,
		p_state_code,
		p_report_type,
		p_business_group_id
	);
	hr_utility.set_location( 'pay_us_mmref_reporting.range_cursor', 20);
	IF preprocess_check(p_pactid,
		p_year_start,
		p_year_end,
		p_business_group_id,
		p_state_abbrev,
		p_state_code,
		p_report_type
	) THEN
		IF p_report_type = 'FEDW2' THEN
			p_sqlstr := '
				SELECT DISTINCT paf.person_id
				 FROM per_all_assignments_f paf,
				      pay_assignment_actions paa,
				      pay_payroll_actions ppa,
				      pay_payroll_actions ppa1
				WHERE ppa1.payroll_action_id = :payroll_action_id
				  AND ppa.report_type = ''YREND''
				  AND ppa.business_group_id+0 = ppa1.business_group_id
				  AND ppa.effective_date = ppa1.effective_date
				  AND ppa.start_date = ppa1.start_date
				  AND paa.payroll_action_id = ppa.payroll_action_id
				  AND paa.action_status = ''C''
				  AND paf.assignment_id = paa.assignment_id
				  AND paf.effective_start_date <= ppa.effective_date
				  AND paf.effective_end_date >= ppa.start_date
				  AND paf.assignment_type = ''E''
			  	  AND not exists (
					SELECT ''x''
					FROM hr_organization_information hoi
					WHERE hoi.organization_id = paa.tax_unit_id
                                          and hoi.org_information_context =
						''1099R Magnetic Report Rules'')
				ORDER BY paf.person_id
			';
			hr_utility.set_location( 'pay_us_mmref_reporting.range_cursor',
					30);
		ELSIF p_report_type = 'STW2' and p_state_abbrev = 'IN' THEN
		      p_sqlstr :=  'SELECT DISTINCT '||
                                   'to_number(paa.serial_number) '||
                              'FROM ff_archive_item_contexts faic, '||
                                   'ff_archive_items fai, '||
                                   'ff_database_items fdi, '||
                                   'pay_assignment_actions paa, '||
                                   'pay_payroll_actions ppa, '||
                                   'per_all_assignments_f  paf, '||
                                   'pay_payroll_actions ppa1 '||
                             'WHERE ppa1.payroll_action_id = :payroll_action_id '||
            			       'AND ppa.business_group_id+0 = ppa1.business_group_id '||
                               'AND ppa1.effective_date = ppa.effective_date '||
                               'AND ppa.report_type = ''YREND'' '||
                               'AND ppa.payroll_action_id = paa.payroll_action_id '||
                               'AND paf.assignment_id = paa.assignment_id '||
                               'AND paf.assignment_type = ''E'' '||
                               'AND fdi.user_name = ''A_STATE_ABBREV'' '||
                               'AND fdi.user_entity_id = fai.user_entity_id '||
                               'AND fai.archive_item_id = faic.archive_item_id '||
                               'AND fai.context1 = paa.assignment_action_id '||
                               'AND fai.value = ppa1.report_qualifier '||
                               'AND paf.effective_start_date <= ppa.effective_date '||
                               'AND paf.effective_end_date >= ppa.start_date '||
                               'AND paa.action_status = ''C'' '||
                               'AND ( '||
			                        'nvl(hr_us_w2_rep.get_w2_arch_bal( '||
                                               'paa.assignment_action_id, '||
                                               '''A_W2_STATE_WAGES'', '||
                                               'paa.tax_unit_id, '||
                                               'faic.context , 2),0) > 0 '||
			                        'OR '||
                                    'exists (select ''x'' '||
                                      'from ff_contexts fc1, '||
                                           'ff_archive_items fai1, '||
                                           'ff_archive_item_contexts faic1, '||
                                           'ff_database_items fdi1 '||
                                      'where fc1.context_name = ''JURISDICTION_CODE'' '||
                                      'and fc1.context_id = faic1.context_id '||
                                      'and fdi1.user_name = ''A_COUNTY_WITHHELD_PER_JD_GRE_YTD'' '||
                                      'and fdi1.user_entity_id = fai1.user_entity_id '||
                                      'and fai1.context1 = paa.assignment_action_id '||
                                      'and fai1.archive_item_id = faic1.archive_item_id '||
                                      'and substr(faic1.context,1,2) = substr(faic.context,1,2) '||
                                      'and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id, '||
                                                                '''A_COUNTY_WITHHELD_PER_JD_GRE_YTD'', '||
                                                                 'paa.tax_unit_id, '||
                                                                 'faic1.context , 6),0) > 0) '||
                                   ') '||

                               'AND EXISTS ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */  '||
                                    'select ''x'' '||
                                      'from pay_us_state_tax_info_f pustif '||
                                     'where substr(faic.context,1,2) = pustif.state_code '||
                                       'and ppa.effective_date between pustif.effective_start_date '||
                                                                  'and pustif.effective_end_date '||
                                       'and pustif.sit_exists = ''Y'') '||

                                'AND not exists ( '||
                                    'SELECT ''x'' '||
                                      'FROM hr_organization_information hoi '||
                                     'WHERE hoi.organization_id = paa.tax_unit_id '||
                                       'and hoi.org_information_context = '||
                                                                  '''1099R Magnetic Report Rules'' '||
                                                     ') '||
                             'order by to_number(paa.serial_number)';
			hr_utility.set_location( 'pay_us_mmref_reporting.range_cursor',
				40);
        ELSIF p_report_type = 'STW2' and  p_state_abbrev = 'OH' THEN
		      p_sqlstr :=  'SELECT DISTINCT '||
                                   'to_number(paa.serial_number) '||
                              'FROM ff_archive_item_contexts faic, '||
                                   'ff_archive_items fai, '||
                                   'ff_database_items fdi, '||
                                   'pay_assignment_actions paa, '||
                                   'pay_payroll_actions ppa, '||
                                   'per_all_assignments_f  paf, '||
                                   'pay_payroll_actions ppa1 '||
                             'WHERE ppa1.payroll_action_id = :payroll_action_id '||
            			       'AND ppa.business_group_id+0 = ppa1.business_group_id '||
                               'AND ppa1.effective_date = ppa.effective_date '||
                               'AND ppa.report_type = ''YREND'' '||
                               'AND ppa.payroll_action_id = paa.payroll_action_id '||
                               'AND paf.assignment_id = paa.assignment_id '||
                               'AND paf.assignment_type = ''E'' '||
                               'AND fdi.user_name = ''A_STATE_ABBREV'' '||
                               'AND fdi.user_entity_id = fai.user_entity_id '||
                               'AND fai.archive_item_id = faic.archive_item_id '||
                               'AND fai.context1 = paa.assignment_action_id '||
                               'AND fai.value = ppa1.report_qualifier '||
                               'AND paf.effective_start_date <= ppa.effective_date '||
                               'AND paf.effective_end_date >= ppa.start_date '||
                               'AND paa.action_status = ''C'' '||
                               'AND ( '||
			                        'nvl(hr_us_w2_rep.get_w2_arch_bal( '||
                                               'paa.assignment_action_id, '||
                                               '''A_W2_STATE_WAGES'', '||
                                               'paa.tax_unit_id, '||
                                               'faic.context , 2),0) > 0 '||
			                        'OR '||
                                    'exists (select ''x'' '||
                                      'from ff_contexts fc1, '||
                                           'ff_archive_items fai1, '||
                                           'ff_archive_item_contexts faic1, '||
                                           'ff_database_items fdi1 '||
                                      'where fc1.context_name = ''JURISDICTION_CODE'' '||
                                      'and fc1.context_id = faic1.context_id '||
                                      'and fdi1.user_name = ''A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'' '||
                                      'and fdi1.user_entity_id = fai1.user_entity_id '||
                                      'and fai1.context1 = paa.assignment_action_id '||
                                      'and fai1.archive_item_id = faic1.archive_item_id '||
                                      'and substr(faic1.context,1,2) = substr(faic.context,1,2) '||
                                      'and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id, '||
                                                                '''A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'', '||
                                                                 'paa.tax_unit_id, '||
                                                                 'faic1.context , 8),0) > 0) '||
                                   ') '||

                               'AND EXISTS ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */  '||
                                    'select ''x'' '||
                                      'from pay_us_state_tax_info_f pustif '||
                                     'where substr(faic.context,1,2) = pustif.state_code '||
                                       'and ppa.effective_date between pustif.effective_start_date '||
                                                                  'and pustif.effective_end_date '||
                                       'and pustif.sit_exists = ''Y'') '||

                                'AND not exists ( '||
                                    'SELECT ''x'' '||
                                      'FROM hr_organization_information hoi '||
                                     'WHERE hoi.organization_id = paa.tax_unit_id '||
                                       'and hoi.org_information_context = '||
                                                                  '''1099R Magnetic Report Rules'' '||
                                                     ') '||
                             'order by to_number(paa.serial_number)';
			hr_utility.set_location( 'pay_us_mmref_reporting.range_cursor',
				40);

		ELSIF p_report_type = 'STW2' THEN
			p_sqlstr := '
                            SELECT DISTINCT
                                   to_number(paa.serial_number)
                              FROM ff_archive_item_contexts faic,
                                   ff_archive_items fai,
                                   ff_database_items fdi,
                                   pay_assignment_actions paa,
                                   pay_payroll_actions ppa,
                                   per_all_assignments_f  paf,
                                   pay_payroll_actions ppa1
                             WHERE
                                   ppa1.payroll_action_id = :payroll_action_id
			       AND ppa.business_group_id+0 = ppa1.business_group_id
                               AND ppa1.effective_date = ppa.effective_date
                               AND ppa.report_type = ''YREND''
                               AND ppa.payroll_action_id = paa.payroll_action_id
                               and paf.assignment_id = paa.assignment_id
                               AND paf.assignment_type = ''E''
                               AND fdi.user_name = ''A_STATE_ABBREV''
                               AND fdi.user_entity_id = fai.user_entity_id
                               AND fai.archive_item_id = faic.archive_item_id
                               AND fai.context1 = paa.assignment_action_id
                               AND fai.value = ppa1.report_qualifier
                               AND paf.effective_start_date <= ppa.effective_date
                               AND paf.effective_end_date >= ppa.start_date
                               AND paa.action_status = ''C''
                               AND nvl(hr_us_w2_rep.get_w2_arch_bal(
                                               paa.assignment_action_id,
                                               ''A_W2_STATE_WAGES'',
                                               paa.tax_unit_id,
                                               faic.context , 2),0) > 0
                               AND EXISTS ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */
                                    select ''x''
                                      from pay_us_state_tax_info_f pustif
                                     where substr(faic.context,1,2) = pustif.state_code
                                       and ppa.effective_date between pustif.effective_start_date
                                                                  and pustif.effective_end_date
                                       and pustif.sit_exists = ''Y'')
                                AND not exists (
                                    SELECT ''x''
                                      FROM hr_organization_information hoi
                                     WHERE hoi.organization_id = paa.tax_unit_id
                                       and hoi.org_information_context =
                                                                  ''1099R Magnetic Report Rules''
                                                     )
                             order by to_number(paa.serial_number)';
			hr_utility.set_location( 'pay_us_mmref_reporting.range_cursor',
				40);
		END IF;
	END IF;
END range_cursor;
--
  -----------------------------------------------------------------------------
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
  ----------------------------------------------------------------------------
--
PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson IN NUMBER,
	p_chunk 	IN NUMBER )
IS
        -- This Cursor is Speific to PuertoRico State
        -- Cursor to get the assignments for state W2. Gets only those employees
        -- which have wages for the specified state.This cursor excludes the
        -- 1099R GREs.
        CURSOR c_pr_state IS
           SELECT
                  to_number(paa.serial_number),
                  paf.assignment_id,
                  paa.tax_unit_id,
                  paf.effective_end_date,
                  paa.assignment_action_id,
                  nvl(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0)
             FROM ff_archive_item_contexts faic,
                  ff_archive_items fai,
                  ff_database_items fdi,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_all_assignments_f  paf,
                  pay_payroll_actions ppa1
            WHERE
                  ppa1.payroll_action_id = p_pactid
              and ppa.business_group_id+0 = ppa1.business_group_id
              and ppa1.effective_date = ppa.effective_date
              and ppa.report_type = 'YREND'
              and ppa.payroll_action_id = paa.payroll_action_id
              and paf.assignment_id = paa.assignment_id
              and paf.assignment_type = 'E'
              and fdi.user_name = 'A_STATE_ABBREV'
              and fdi.user_entity_id = fai.user_entity_id
              and fai.archive_item_id = faic.archive_item_id
              and fai.context1 = paa.assignment_action_id
              and fai.value = ppa1.report_qualifier
              and paf.effective_start_date <= ppa.effective_date
              and paf.effective_end_date >= ppa.start_date
              and paa.action_status = 'C'
              --and paa.serial_number BETWEEN to_char(p_stperson) AND to_char(p_endperson)
	      and to_number(paa.serial_number) BETWEEN p_stperson AND p_endperson  /* 6712859  */
              and paf.person_id BETWEEN p_stperson AND p_endperson
              and ( ( nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0 )
						     or
                     ( nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_SIT_WITHHELD_PER_JD_GRE_YTD', /* 6809739 */
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0) )

              and exists ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */
                           select 'x'
                             from pay_us_state_tax_info_f pustif
                            where substr(faic.context,1,2) = pustif.state_code
                              and ppa.effective_date between pustif.effective_start_date
                                                         and pustif.effective_end_date
                              and pustif.sit_exists = 'Y'
                           )
              and exists (select 'x'
                            from hr_organization_information hou
                           where hou.organization_id = paa.tax_unit_id
                             and hou.org_information16 = 'P'
                             and hou.org_information_context = 'W2 Reporting Rules')
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             where hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )
               ORDER BY 1, 3, 4 DESC, 2
               FOR UPDATE OF paf.assignment_id;
	-- Cursor to get the assignments for state W2. Gets only those employees
	-- which have wages for the specified state.This cursor excludes the
	-- 1099R GREs.
	CURSOR c_state IS
  	   SELECT
                  to_number(paa.serial_number),
                  paf.assignment_id,
                  paa.tax_unit_id,
                  paf.effective_end_date,
                  paa.assignment_action_id,
                  nvl(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0)
             FROM ff_archive_item_contexts faic,
                  ff_archive_items fai,
                  ff_database_items fdi,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_all_assignments_f  paf,
                  pay_payroll_actions ppa1
            WHERE
                  ppa1.payroll_action_id = p_pactid
	      and ppa.business_group_id+0 = ppa1.business_group_id
              and ppa1.effective_date = ppa.effective_date
              and ppa.report_type = 'YREND'
              and ppa.payroll_action_id = paa.payroll_action_id
              and paf.assignment_id = paa.assignment_id
              and paf.assignment_type = 'E'
              and fdi.user_name = 'A_STATE_ABBREV'
              and fdi.user_entity_id = fai.user_entity_id
              and fai.archive_item_id = faic.archive_item_id
              and fai.context1 = paa.assignment_action_id
              and fai.value = ppa1.report_qualifier
              and paf.effective_start_date <= ppa.effective_date
              and paf.effective_end_date >= ppa.start_date
              and paa.action_status = 'C'
              and paf.person_id BETWEEN p_stperson AND p_endperson
              and (( nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0 )
						     or
		    (nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,   /* 6809739 */
                                                    'A_SIT_WITHHELD_PER_JD_GRE_YTD',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0))
              /* Commenting it due to Performance Issue Bug# 5630156 */
              -- and exists ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */
                           /* select 'x'
                             from pay_us_state_tax_info_f pustif
                            where substr(faic.context,1,2) = pustif.state_code
                              and ppa.effective_date between pustif.effective_start_date
                                                         and pustif.effective_end_date
                              and pustif.sit_exists = 'Y'
                           )
              */
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             WHERE hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )
               ORDER BY 1, 3, 4 DESC, 2 ;
               /* Commenting for Performance Issue Bug# 5630156
               FOR UPDATE OF paf.assignment_id; */


       -- Introduced this cursor for State of Indiana for Bug# 5099892
       -- In case of Indiana, Assignment Actions need to created
       -- [ Employee to be included in Tape ] if non-zero County Withheld is
       -- there evenif the State Wages is zero.

	   CURSOR c_state_indiana IS
  	   SELECT
                  to_number(paa.serial_number),
                  paf.assignment_id,
                  paa.tax_unit_id,
                  paf.effective_end_date,
                  paa.assignment_action_id,
                  nvl(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0)
             FROM ff_archive_item_contexts faic,
                  ff_archive_items fai,
                  ff_database_items fdi,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_all_assignments_f  paf,
                  pay_payroll_actions ppa1
            WHERE
                  ppa1.payroll_action_id = p_pactid
	          and ppa.business_group_id+0 = ppa1.business_group_id
              and ppa1.effective_date = ppa.effective_date
              and ppa.report_type = 'YREND'
              and ppa.payroll_action_id = paa.payroll_action_id
              and paf.assignment_id = paa.assignment_id
              and paf.assignment_type = 'E'
              and fdi.user_name = 'A_STATE_ABBREV'
              and fdi.user_entity_id = fai.user_entity_id
              and fai.archive_item_id = faic.archive_item_id
              and fai.context1 = paa.assignment_action_id
              and fai.value = ppa1.report_qualifier
              and paf.effective_start_date <= ppa.effective_date
              and paf.effective_end_date >= ppa.start_date
              and paa.action_status = 'C'
              and paf.person_id BETWEEN p_stperson AND p_endperson
              and ( ((
	           nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0 )

                  or
                  (
	           nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id, /* 6809739 */
                                                    'A_SIT_WITHHELD_PER_JD_GRE_YTD',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0))
	           OR
                    exists (select 'x'
                          from ff_contexts fc1,
                               ff_archive_items fai1,
                               ff_archive_item_contexts faic1,
                               ff_database_items fdi1
                          where fc1.context_name = 'JURISDICTION_CODE'
                          and fc1.context_id = faic1.context_id
                          and fdi1.user_name = 'A_COUNTY_WITHHELD_PER_JD_GRE_YTD'
                          and fdi1.user_entity_id = fai1.user_entity_id
                          and fai1.context1 = paa.assignment_action_id
                          and fai1.archive_item_id = faic1.archive_item_id
                          and substr(faic1.context,1,2) = substr(faic.context,1,2)
                          and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_COUNTY_WITHHELD_PER_JD_GRE_YTD',
                                                     paa.tax_unit_id,
                                                     faic1.context , 6),0) > 0)
                  )
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             WHERE hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )
               ORDER BY 1, 3, 4 DESC, 2 ;

       -- Introduced this cursor for State of Ohio for Bug# 5648738
       -- In case of Ohio, Assignment Actions need to created
       -- [ Employee to be included in Tape ] in presence of  non-zero School Withheld

	   CURSOR c_state_ohio IS
  	   SELECT
                  to_number(paa.serial_number),
                  paf.assignment_id,
                  paa.tax_unit_id,
                  paf.effective_end_date,
                  paa.assignment_action_id,
                  nvl(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0)
             FROM ff_archive_item_contexts faic,
                  ff_archive_items fai,
                  ff_database_items fdi,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_all_assignments_f  paf,
                  pay_payroll_actions ppa1
            WHERE
                  ppa1.payroll_action_id = p_pactid
	      and ppa.business_group_id+0 = ppa1.business_group_id
              and ppa1.effective_date = ppa.effective_date
              and ppa.report_type = 'YREND'
              and ppa.payroll_action_id = paa.payroll_action_id
              and paf.assignment_id = paa.assignment_id
              and paf.assignment_type = 'E'
              and fdi.user_name = 'A_STATE_ABBREV'
              and fdi.user_entity_id = fai.user_entity_id
              and fai.archive_item_id = faic.archive_item_id
              and fai.context1 = paa.assignment_action_id
              and fai.value = ppa1.report_qualifier
              and paf.effective_start_date <= ppa.effective_date
              and paf.effective_end_date >= ppa.start_date
              and paa.action_status = 'C'
              and paf.person_id BETWEEN p_stperson AND p_endperson
              and ( ((
	           nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0 )
                   or
                  (
	           nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id, /* 6809739 */
                                                    'A_SIT_WITHHELD_PER_JD_GRE_YTD',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0) )
	           OR
                    exists (select 'x'
                          from ff_contexts fc1,
                               ff_archive_items fai1,
                               ff_archive_item_contexts faic1,
                               ff_database_items fdi1
                          where fc1.context_name = 'JURISDICTION_CODE'
                          and fc1.context_id = faic1.context_id
                          and fdi1.user_name = 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'
                          and fdi1.user_entity_id = fai1.user_entity_id
                          and fai1.context1 = paa.assignment_action_id
                          and fai1.archive_item_id = faic1.archive_item_id
                          and substr(faic1.context,1,2) = substr(faic.context,1,2)
                          and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD',
                                                     paa.tax_unit_id,
                                                     faic1.context , 8),0) > 0)
                  )
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             WHERE hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )
               ORDER BY 1, 3, 4 DESC, 2 ;

	-- Cursor to get the assignments for federal W2. Excludes 1099R GREs.
	CURSOR c_federal IS
          SELECT paf.person_id,
                 paf.assignment_id,
                 Paa.tax_unit_id, --TO_NUMBER(hsck.segment1),
                 paf.effective_end_date,
                 paa.assignment_action_id
	    FROM pay_payroll_actions ppa,
	         pay_assignment_actions paa,
	         per_all_assignments_f paf,
                 pay_payroll_actions ppa1
	WHERE ppa1.payroll_action_id = p_pactid
	  AND ppa.report_type = 'YREND'
	  AND ppa.business_group_id+0 = ppa1.business_group_id
	  AND ppa.effective_date = ppa1.effective_date
	  AND ppa.start_date = ppa1.start_date
	  AND paa.payroll_action_id = ppa.payroll_action_id
	  AND paa.action_status = 'C'
	  AND paf.assignment_id = paa.assignment_id
          --AND paa.serial_number between to_char(p_stperson) AND to_char(p_endperson)
	  AND to_number(paa.serial_number) BETWEEN p_stperson AND p_endperson /* 6712859 */
	  AND paf.person_id BETWEEN p_stperson AND p_endperson
	  AND paf.assignment_type = 'E'
	  AND paf.effective_start_date <= ppa.effective_date
	  AND paf.effective_end_date >= ppa.start_date
	  AND not exists (
	 	SELECT 'x'
	 	FROM hr_organization_information hoi
	  	WHERE hoi.organization_id = paa.tax_unit_id
                  and hoi.org_information_context = '1099R Magnetic Report Rules')
        ORDER BY 1, 3, 4 DESC, 2
	FOR UPDATE OF paf.assignment_id;
        cursor csr_get_fed_wages(p_user_name            varchar2,
                                 p_assignment_action_id number,
                                 p_tax_unit_id          number) is
        select to_number(fai.value) value
        from ff_archive_item_contexts faic,
             ff_archive_items         fai,
             ff_contexts              fc,
             ff_database_items        fdi
        where fdi.user_name   = p_user_name
        and   fc.context_name = 'TAX_UNIT_ID'
        and   fai.context1 = to_char(p_assignment_action_id)
        and   fai.user_entity_id = fdi.user_entity_id
        and   faic.archive_item_id = fai.archive_item_id
        and   faic.context_id = fc.context_id
        and   faic.context = to_char(p_tax_unit_id)
        and   faic.sequence_no = 1;

        cursor csr_get_fit_sub_wages(p_assignment_action_id number,
                                     p_tax_unit_id          number) is
        select to_number(fai.value) value
        from ff_archive_item_contexts faic,
             ff_archive_items         fai,
             ff_contexts              fc,
             ff_database_items        fdi
        where fdi.user_name   IN ('A_REGULAR_EARNINGS_PER_GRE_YTD',
                                  'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD',
                                  'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD',
                                  'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD',
                                  'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD')
        and   fc.context_name = 'TAX_UNIT_ID'
        and   fai.context1 = to_char(p_assignment_action_id)
        and   fai.user_entity_id = fdi.user_entity_id
        and   faic.archive_item_id = fai.archive_item_id
        and   faic.context_id = fc.context_id
        and   faic.context = to_char(p_tax_unit_id)
        and   faic.sequence_no = 1;

	--local variables
	l_year_start            DATE;
	l_year_end              DATE;
	l_effective_end_date	DATE;
	l_state_abbrev 		VARCHAR2(3);
	l_state_code 		VARCHAR2(2);
	l_report_type		VARCHAR2(30);
	l_business_group_id	NUMBER;
	l_person_id		NUMBER;
	l_prev_person_id	NUMBER;
	l_assignment_id		NUMBER;
	l_assignment_action_id	NUMBER;
	l_value		        NUMBER;
	l_tax_unit_id		NUMBER;
	l_prev_tax_unit_id	NUMBER;
	lockingactid		NUMBER;
	l_group_by_gre		BOOLEAN;
	l_w2_box17 		NUMBER; --SIT Wages
        l_gre_id                NUMBER;
        l_error_flag            VARCHAR2(10);
BEGIN
        -- Set the local variable to correct Value

         l_gre_id := -1;
         l_error_flag := 'N';

	-- Get the report parameters. These define the report being run.
	hr_utility.set_location( 'pay_us_mmref_reporting.create_assignement_act',
		10);
	get_report_parameters(
		p_pactid,
		l_year_start,
		l_year_end,
		l_state_abbrev,
		l_state_code,
		l_report_type,
		l_business_group_id
	);
	--Currently all reports group by GRE
	l_group_by_gre := TRUE;
	--Open the appropriate cursor
	hr_utility.set_location( 'pay_us_mmref_reporting.create_assignement_act',
		20);
	IF l_report_type = 'FEDW2' THEN
		OPEN c_federal;
--
-- This was added specifically to have PuertoRico GRE employees for assignment creation
--
    ELSIF l_report_type = 'STW2' and l_state_abbrev = 'PR' THEN
        	OPEN c_pr_state;
     /* Added for Bug# 5099892 */
    ELSIF l_report_type = 'STW2' and l_state_abbrev = 'IN' THEN
	        OPEN c_state_indiana ;
    /* Added for Bug# 5648738 */
    ELSIF l_report_type = 'STW2' and l_state_abbrev = 'OH' THEN
	        OPEN c_state_ohio ;
	ELSIF l_report_type = 'STW2' THEN
		OPEN c_state;
	END IF;
	LOOP
		IF l_report_type = 'FEDW2' THEN
			FETCH c_federal INTO l_person_id,
			                     l_assignment_id,
			                     l_tax_unit_id,
			                     l_effective_end_date,
                                             l_assignment_action_id;
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 30);
			EXIT WHEN c_federal%NOTFOUND;
                ELSIF l_report_type = 'STW2' and l_state_abbrev = 'PR' THEN
                        FETCH c_pr_state INTO l_person_id,
                                           l_assignment_id,
                                           l_tax_unit_id,
                                           l_effective_end_date,
                                           l_assignment_action_id,
                                           l_w2_box17;
                        hr_utility.set_location(
                                'pay_us_mmref_reporting.create_assignement_act', 40);
                        EXIT WHEN c_pr_state%NOTFOUND;
                        -- Check the state Tax rules if new gre
                        -- Set the Error Flag to Y so that Action Creation will Error
                        -- At the End

                        IF l_gre_id = l_tax_unit_id THEN
                            hr_utility.trace('Same GRE ');
                        ELSE
                          IF  check_state_er_data(p_pactid,l_tax_unit_id,'A') = 'N' THEN
                              hr_utility.trace('State Tax Rules Missing in GRE');
                              l_gre_id := l_tax_unit_id;
                              l_error_flag := 'Y';
                          ELSE
                              l_gre_id := l_tax_unit_id;
                          END if ; --check ER
                        END IF;
                -- Added for Bug# 5099892
		ELSIF l_report_type = 'STW2' and l_state_abbrev = 'IN' THEN
			FETCH c_state_indiana INTO l_person_id,
			                   l_assignment_id,
			                   l_tax_unit_id,
			                   l_effective_end_date,
                                           l_assignment_action_id,
                                           l_w2_box17;
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 40);
			EXIT WHEN c_state_indiana%NOTFOUND;
                        -- Check the state Tax rules if new gre
                        -- Set the Error Flag to Y so that Action Creation will Error
                        -- At the End

                        IF l_gre_id = l_tax_unit_id THEN
                            hr_utility.trace('Same GRE ');
                        ELSE
                          IF  check_state_er_data(p_pactid,l_tax_unit_id,'A') = 'N' THEN
                              hr_utility.trace('State Tax Rules Missing in GRE');
                              l_gre_id := l_tax_unit_id;
                              l_error_flag := 'Y';
                          ELSE
                              l_gre_id := l_tax_unit_id;
                          END if ; --check ER
                        END IF;

        -- Added for Bug# 5648738
		ELSIF l_report_type = 'STW2' and l_state_abbrev = 'OH' THEN
			FETCH c_state_ohio INTO l_person_id,
			                   l_assignment_id,
			                   l_tax_unit_id,
			                   l_effective_end_date,
                               l_assignment_action_id,
                               l_w2_box17;
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 40);
			EXIT WHEN c_state_ohio%NOTFOUND;
                        -- Check the state Tax rules if new gre
                        -- Set the Error Flag to Y so that Action Creation will Error
                        -- At the End

                        IF l_gre_id = l_tax_unit_id THEN
                            hr_utility.trace('Same GRE ');
                        ELSE
                          IF  check_state_er_data(p_pactid,l_tax_unit_id,'A') = 'N' THEN
                              hr_utility.trace('State Tax Rules Missing in GRE');
                              l_gre_id := l_tax_unit_id;
                              l_error_flag := 'Y';
                          ELSE
                              l_gre_id := l_tax_unit_id;
                          END if ; --check ER
                        END IF;

		ELSIF l_report_type = 'STW2' THEN
			FETCH c_state INTO l_person_id,
			                   l_assignment_id,
			                   l_tax_unit_id,
			                   l_effective_end_date,
                                           l_assignment_action_id,
                                           l_w2_box17;
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 40);
			EXIT WHEN c_state%NOTFOUND;
                        -- Check the state Tax rules if new gre
                        -- Set the Error Flag to Y so that Action Creation will Error
                        -- At the End

                        IF l_gre_id = l_tax_unit_id THEN
                            hr_utility.trace('Same GRE ');
                        ELSE
                          IF  check_state_er_data(p_pactid,l_tax_unit_id,'A') = 'N' THEN
                              hr_utility.trace('State Tax Rules Missing in GRE');
                              l_gre_id := l_tax_unit_id;
                              l_error_flag := 'Y';
                          ELSE
                              l_gre_id := l_tax_unit_id;
                          END if ; --check ER
                        END IF;


		END IF;
		--Based on the groupin criteria, check if the record is the same
		--as the previous record.
		--Grouping by GRE requires a unique person/GRE combination for
		--each record.
		IF ((l_group_by_gre AND
			l_person_id   = l_prev_person_id AND
			l_tax_unit_id = l_prev_tax_unit_id) OR
			(NOT l_group_by_gre AND
			l_person_id   = l_prev_person_id)) THEN
			--Do Nothing
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 50);
			NULL;
		ELSE
			--Create the assignment action for the record
		  hr_utility.trace('Assignment Fetched  - ');
		  hr_utility.trace('Assignment Id : '|| to_char(l_assignment_id));
		  hr_utility.trace('Person Id :  '|| to_char(l_person_id));
		  hr_utility.trace('tax unit id : '|| to_char(l_tax_unit_id));
		  hr_utility.trace('Effective End Date :  '||
		                     to_char(l_effective_end_date));

                  IF l_report_type = 'FEDW2' then

                     l_value := 0;

                     --  Check FOR SS Withheld, added by tmehra

                        FOR c_rec IN csr_get_fed_wages('A_SS_EE_WITHHELD_PER_GRE_YTD',
                                                    l_assignment_action_id,
                                                    l_tax_unit_id)
                        LOOP
                        l_value := c_rec.value;
                        END LOOP;

                        -- Check for Medicare balance if SS is zero -- tmehra

                        IF l_value = 0 THEN

                        FOR c_rec IN csr_get_fed_wages
                                  ('A_MEDICARE_EE_WITHHELD_PER_GRE_YTD',
                                    l_assignment_action_id,
                                    l_tax_unit_id)
                        LOOP
                        l_value := c_rec.value;
                        END LOOP;

                        END IF;

                        -- Check for FIT Subject balance if Medicare is also zero
                        -- Since FIT Subject is a derieved balance we add the
                        -- following balances
                        --  - 'A_REGULAR_EARNINGS_PER_GRE_YTD'
                        --  - 'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD'
                        --  - 'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD'
                        --  - 'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD'
                        --  - 'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD'
                        -- added by tmehra

                        IF l_value = 0 THEN

                        FOR c_rec IN csr_get_fit_sub_wages( l_assignment_action_id,
                                                            l_tax_unit_id)
                        LOOP
                         l_value := l_value + c_rec.value;
                        END LOOP;

                        END IF;

			If l_value = 0 THEN  /* 6868340 */
                         FOR c_rec IN csr_get_fed_wages
                                  ('A_FIT_WITHHELD_PER_GRE_YTD',
                                    l_assignment_action_id,
                                    l_tax_unit_id)
                        LOOP
                        l_value :=  c_rec.value;
                        END LOOP;
                        end if ;

                  END IF;
                   IF (l_report_type = 'FEDW2' and l_value <> 0 ) OR
                      (l_report_type = 'STW2') then
			SELECT pay_assignment_actions_s.nextval
			INTO lockingactid
			FROM dual;
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 60);
			hr_nonrun_asact.insact(lockingactid, l_assignment_id, p_pactid,
				p_chunk, l_tax_unit_id);
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 70);
			--update serial number for highly compensated people for the
			--state W2.
			/*IF l_report_type = 'STW2' THEN
				hr_utility.set_location(
					'pay_us_mmref_reporting.create_assignement_act', 80);
				IF l_w2_box17 > 9999999.99 THEN
					UPDATE pay_assignment_actions
					SET serial_number = 999999
					WHERE assignment_action_id = lockingactid;
				END IF;
			END IF;*/ -- 4490252
			hr_nonrun_asact.insint(lockingactid, l_assignment_action_id);
			hr_utility.set_location(
				'pay_us_mmref_reporting.create_assignement_act', 90);
			hr_utility.trace('Interlock Created  - ');
			hr_utility.trace('Locking Action : '|| to_char(lockingactid));
			hr_utility.trace('Locked Action :  '|| to_char(l_assignment_action_id));
			--Store the current person/GRE for comparision during the
			--next iteration.
			l_prev_person_id 	:= l_person_id;
			l_prev_tax_unit_id 	:= l_tax_unit_id;
                    END IF;
		END IF;
	END LOOP;
	IF l_report_type = 'FEDW2' THEN
		CLOSE c_federal;
	ELSIF l_report_type = 'STW2' and l_state_abbrev = 'PR' THEN
		CLOSE c_pr_state;
        /* Added for Bug# 5099892 */
	ELSIF l_report_type = 'STW2' and l_state_abbrev = 'IN' THEN
	        CLOSE c_state_indiana ;
	ELSIF l_report_type = 'STW2' and l_state_abbrev = 'OH' THEN
	        CLOSE c_state_ohio ;
	ELSIF l_report_type = 'STW2' THEN
		CLOSE c_state;
	END IF;

        IF l_error_flag = 'Y' THEN
              hr_utility.trace('Error Flag was set to Y');
              hr_utility.raise_error;
        END IF;

END create_assignment_act;

FUNCTION check_er_data (
	p_pactid 	IN NUMBER,
	p_ein_user_id  	IN NUMBER )
        RETURN varchar2
IS

l_ein_val varchar2(80);
l_ein_status varchar2(80);
l_add_status varchar2(80);
l_gre number;


message_preprocess varchar2(80);
message_text varchar2(80);

CURSOR c_get_user_entity_id
    IS
SELECT user_entity_id
  FROM ff_database_items
 WHERE  user_name in ( 'A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER',
                       'A_TAX_UNIT_NAME');

CURSOR c_get_address_entity_id
    IS
SELECT user_entity_id
  FROM ff_database_items
 WHERE  user_name  = 'TAX_UNIT_ADDRESS_LINE_1';



BEGIN
     l_ein_status := 'Y';
     l_gre := p_ein_user_id;
     FOR c_id IN c_get_user_entity_id LOOP

     SELECT value
       INTO l_ein_val
       FROM ff_archive_items fai,
            ff_contexts fc,
            ff_archive_item_contexts faic
     WHERE  fai.context1 = to_char(p_pactid)
       AND  user_entity_id = c_id.user_entity_id
       AND  faic.archive_item_id = fai.archive_item_id
       AND  faic.context = to_char(l_gre)
       AND  fc.context_name = 'TAX_UNIT_ID'
       AND  fc.context_id = faic.context_id ;

     IF l_ein_val IS NULL  OR  l_ein_status = 'N' THEN
        l_ein_status := 'N' ;
     END IF;

     END LOOP;

     IF l_ein_status = 'N' THEN
            message_preprocess := 'Pre-Process Check-';
            message_text := 'EIN or Tax Unit Name  Missing  ';
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',message_preprocess);
            pay_core_utils.push_token('description',message_text);
     END IF;

      return l_ein_status ;

exception WHEN OTHERS THEN
        return 'N';
END check_er_data;

/* check the data for only one state EIN */

FUNCTION check_state_er_data (
	p_pactid 	IN NUMBER,
	p_tax_unit  	IN NUMBER,
        p_jurisdictions  IN varchar2 )
        RETURN varchar2
IS
     l_state_ein_val varchar2(80);
     l_sit_state_id varchar2(80);
     l_jurisdiction varchar2(80);

     CURSOR c_state_sit IS
     SELECT user_entity_id
       FROM ff_user_entities
      WHERE user_entity_name = 'A_STATE_TAX_RULES_ORG_SIT_COMPANY_STATE_ID';

   CURSOR  c_get_state_id
       IS
   SELECT value
     FROM ff_archive_items fai,
             ff_archive_item_contexts faic,
             ff_archive_item_contexts faic1
     WHERE  context1 = to_char(p_pactid)
       AND  user_entity_id = l_sit_state_id
       AND  faic.archive_item_id = fai.archive_item_id
       AND  faic1.archive_item_id = fai.archive_item_id
       AND  faic.context = to_char(p_tax_unit)
       and  faic1.context = p_jurisdictions || '-000-0000';


BEGIN

     OPEN c_state_sit;
     FETCH c_state_sit INTO l_sit_state_id;
     CLOSE c_state_sit;


     OPEN c_get_state_id;
     FETCH c_get_state_id INTO l_state_ein_val;

     CLOSE c_get_state_id;
     IF l_state_ein_val is NULL THEN
        return 'Y';
     ELSE
        return 'Y';
     END IF;

exception WHEN OTHERS THEN
        return 'Y';
END check_state_er_data;


PROCEDURE ARCHIVE_EOY_DATA (
	p_pactid 	IN NUMBER,
	p_tax_id 	IN NUMBER )

IS
BEGIN
/* get the Parameter Setting */
pay_us_archive.eoy_archive_gre_data(p_pactid,p_tax_id,'FED W2 REPORTING RULES','ALL');
pay_us_archive.eoy_archive_gre_data(p_pactid,p_tax_id,'FED TAX UNIT INFORMATION','ALL');
pay_us_archive.eoy_archive_gre_data(p_pactid,p_tax_id,'FEDERAL TAX RULES','ALL');

END ARCHIVE_EOY_DATA;

/* Note: There is no way of limiting the archiving data related to single state
*/

PROCEDURE ARCHIVE_STATE_EOY_DATA (
	p_pactid 	IN NUMBER,
	p_tax_id 	IN NUMBER,
        p_state_code    IN VARCHAR2 )

IS
BEGIN
/* get the Parameter Setting */

hr_utility.trace('Calling the state archiving ');
hr_utility.trace('Pactid ' || to_char(p_pactid));
hr_utility.trace('tax id ' || to_char(p_tax_id));
hr_utility.trace('Pactid ' || p_state_code);

pay_us_archive.eoy_archive_gre_data(p_pactid,p_tax_id,'STATE TAX RULES',p_state_code);

END ARCHIVE_STATE_EOY_DATA;

FUNCTION check_state_data
       ( p_payroll_action_id number,
         p_transfer_state varchar2
       ) RETURN varchar2
IS
/* get the state Code */
CURSOR c_state_code(cp_state varchar2 )
       IS select state_code
     from pay_us_states
    WHERE state_abbrev = cp_state;

CURSOR c_yep_tax_unit_ppa_id(cp_payroll_action_id number )
       IS
   SELECT DISTINCT paa.tax_unit_id unit_id,ppa1.payroll_action_Id payroll_action,name
     FROM  pay_assignment_actions paa
          ,pay_payroll_actions ppa1 /* year End Pre-process for GRE */
          ,pay_payroll_actions ppa /* Year End Pre-process for W-2 */
          ,hr_organization_units hou
   WHERE
        ppa.payroll_action_id = cp_payroll_action_id /* W2 payroll_action_id */
    and ppa.payroll_action_id = paa.payroll_action_id
    and ppa1.legislative_parameters like ltrim(rtrim(to_char(paa.tax_unit_id)))  || ' TRANS%'
    and ppa1.effective_date = ppa.effective_date
    and ppa1.report_type = 'YREND'
    and ppa1.report_qualifier = 'FED'
    and hou.organization_id = paa.tax_unit_id;

CURSOR c_get_pr_control_num ( cp_tax_unit_id number)
IS
 SELECT org_information17 from hr_organization_information
  WHERE org_information_context = 'W2 Reporting Rules'
    AND organization_id = cp_tax_unit_id;

CURSOR c_sit_check (cp_payroll_action_id number,
                     cp_tax_unit_id number,
                     cp_state_Code varchar2 )
     IS
 SELECT target.value
   FROM
        ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target,
        ff_database_items fdi
WHERE   target.context1 = to_char(cp_payroll_action_id)
                /* context of payroll_action_id */
    and fdi.user_name = 'A_STATE_TAX_RULES_ORG_SIT_COMPANY_STATE_ID'
    and target.user_entity_id = fdi.user_entity_id
    and fc2.context_name = 'TAX_UNIT_ID'
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = ltrim(rtrim(to_char(cp_tax_unit_id)))
    and fc3.context_name = 'JURISDICTION_CODE'
    and con3.archive_item_id = target.archive_item_id
    and con3.context_id = fc3.context_id
    and substr(ltrim(rtrim(con3.context)),1,2) = ltrim(rtrim(cp_state_code));
                                     /* jurisdiction code of the state */
/* local Variables */
l_w2_state pay_us_states.state_code%type;
l_tax_unit_id number;
l_payroll_action_id number;
l_state_code varchar2(2);
l_info  varchar2(80);
l_flag  varchar2(2) := 'Y';
l_control_num_flag  varchar2(2) := 'Y';
l_gre   hr_organization_units.name%type;
l_message_preprocess varchar2(80);
l_message_text varchar2(200);
u_message_text varchar2(200);
l_control_number number;
BEGIN
 IF p_transfer_state = 'FED' THEN
   return 'Y';
 end if;
  /* Get the state Code for the W2 Tape */
  OPEN C_STATE_CODE(p_transfer_state);
  FETCH c_state_code into l_w2_state;
  CLOSE C_STATE_CODE;
  FOR  c1 IN c_yep_tax_unit_ppa_id(p_payroll_action_id )  LOOP

     IF p_transfer_state = 'PR' THEN
        open c_get_pr_control_num(C1.unit_id);
        fetch c_get_pr_control_num INTO l_control_number;
        if c_get_pr_control_num%notfound then
             l_message_text := 'ERROR: PR 499R Starting Control Number not defined';
             pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
             pay_core_utils.push_token('record_name',l_message_preprocess);
             pay_core_utils.push_token('description',l_message_text);
             hr_utility.trace(l_message_preprocess || ' ' || l_message_text );
             l_control_num_flag := 'N';
        else
           if (l_control_number is NULL or l_control_number = 0) then
             l_message_text := 'ERROR:PR 499R Starting control Number is NULL';
             hr_utility.trace(l_message_preprocess || ' ' || l_message_text );
             pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
             pay_core_utils.push_token('record_name',l_message_preprocess);
             pay_core_utils.push_token('description',l_message_text);
             hr_utility.trace(l_message_preprocess || ' ' || l_message_text );
             l_control_num_flag := 'N';
           end if;
        end if;
        close c_get_pr_control_num;
     END IF;
        open c_sit_check(C1.payroll_action,c1.unit_id,l_w2_state);
        l_message_preprocess := 'GRE: ' ||c1.name || ' has ' ;
        fetch c_sit_check INTO l_info ;
        l_message_text := to_char(c1.unit_id) || 'Payroll_action_id ' || to_char(c1.payroll_action);
        hr_utility.trace(l_message_preprocess || ' ' || l_message_text) ;
        if c_sit_check%notfound then
            l_message_text := 'ERROR: Missing State Tax Rules For State of :' || p_transfer_state;
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',l_message_preprocess);
            pay_core_utils.push_token('description',l_message_text);
            hr_utility.trace(l_message_preprocess || ' ' || l_message_text );
            l_flag := 'N';
            close c_sit_check;
        else
          if l_info IS NULL THEN
            l_flag := 'N';
            l_message_text := 'ERROR: NULL EIN For State of ' || p_transfer_state;
            hr_utility.trace(l_message_preprocess || ' ' || l_message_text );
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',l_message_preprocess);
            pay_core_utils.push_token('description',l_message_text);
          end if ;
          close c_sit_check;
        end if;
 END loop;
IF l_flag = 'N' OR l_control_num_flag = 'N' THEN
           l_message_text := 'Set your W2 Reporting Rules or State Tax Rules';
           pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
           pay_core_utils.push_token('record_name',l_message_preprocess);
           pay_core_utils.push_token('description',l_message_text);
           hr_utility.raise_error;
           return 'N';
END IF;
return 'Y';
EXCEPTION
WHEN OTHERS THEN
          l_message_preprocess := 'Exception  ';
          l_message_text := 'Set your W2 Reporting Rules or State Tax Rules';
          pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
          pay_core_utils.push_token('record_name',l_message_preprocess);
          pay_core_utils.push_token('description',l_message_text);
          u_message_text := 'Set your W2 Reporting Rules or State Tax Rules';
          hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
          hr_utility.set_message_token('MESSAGE', u_message_text);
          hr_utility.raise_error;
          return 'Y';
END check_state_data;

-- ----------------------------------------------------------------------------
-- -----------------------< get_report_category  >-----------------------------
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the 'RM' or 'RG' depending upon the archived value for the Govt
--   employer.
--   Added for US Payroll Govt Employer W2 specific situations.
--
-- Pre Conditions:
--   If no archived value is found, default value of 'RM' is returned. This is
--   done to support the employees whose data was archived before these
--   changes.
--
--
-- In Parameters:
--   p_business_group_id
--   p_effective_date
--
-- Post Success:
--   Returns 'RG' or 'RM'
--
-- Added by tmehra
-- ----------------------------------------------------------------------------
FUNCTION get_report_category     ( p_business_group_id     number,
                                   p_effective_date        date
                                 ) RETURN varchar2 IS

  --
  l_proc        varchar2(100) := 'pay_us_mmref_reporting.get_report_category';
  l_code        varchar2(2);
  l_ue_id       NUMBER;
  --
  --
  CURSOR c_get_user_entity_id IS
  SELECT user_entity_id
    FROM ff_user_entities
   WHERE user_entity_name  = 'A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER';


  CURSOR c_chk_for_govt_employer (p_user_entity_id NUMBER) IS
  SELECT 'RG'
    FROM DUAL
   WHERE EXISTS
              (SELECT NULL
                 FROM pay_payroll_actions ppa,
                      ff_archive_items    fai
                WHERE ppa.report_type       = 'YREND'
                  AND ppa.report_qualifier  = 'FED'
                  AND ppa.report_category   = 'RT'
                  AND ppa.effective_date    = p_effective_date
                  AND ppa.business_group_id = p_business_group_id
                  AND fai.context1          = ppa.payroll_action_id
                  AND fai.user_entity_id    = p_user_entity_id
                  AND fai.value             = 'Y'
               );

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --


  -- Get the user entity id for A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER

  FOR c_rec IN c_get_user_entity_id
  LOOP

    l_ue_id := c_rec.user_entity_id;

  END LOOP;


  -- Decide upon the report Category based on the archived emp type

  l_code := 'RM';

  FOR c_rec IN c_chk_for_govt_employer (l_ue_id)
  LOOP

    l_code := 'RG';

  END LOOP;


  RETURN l_code;

END get_report_category;


--
--
--
-- ----------------------------------------------------------------------------
-- -----------------------< get_report_category_new  >-----------------------------
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the 'MT' or 'RG' depending upon the archived value for the Govt employer.
--   Added for US Payroll Govt Employer W2 specific situations.
--
-- Pre Conditions:
--   If no archived value is found, default value of 'MT' is returned. This is  done to
--   support the employees whose data was archived before these changes.
--
-- In Parameters:
--   p_business_group_id
--   p_effective_date
--
-- Post Success:
--   Returns 'RG' or 'MT'
--
-- Added by Pradeep
-- ----------------------------------------------------------------------------
FUNCTION get_report_category_mt     ( p_business_group_id     number,
                                                                 p_effective_date            date
                                                               ) RETURN varchar2 IS
  --
  l_proc        varchar2(100) := 'pay_us_mmref_reporting.get_report_category';
  l_code        varchar2(2);
  l_ue_id       NUMBER;
  --
  CURSOR c_get_user_entity_id IS
  SELECT user_entity_id
    FROM ff_user_entities
   WHERE user_entity_name  = 'A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER';

  CURSOR c_chk_for_govt_employer (p_user_entity_id NUMBER) IS
  SELECT 'RG'
    FROM DUAL
   WHERE EXISTS
              (SELECT NULL
                 FROM pay_payroll_actions ppa,
                              ff_archive_items    fai
                WHERE ppa.report_type            = 'YREND'
                     AND ppa.report_qualifier       = 'FED'
                     AND ppa.report_category      = 'RT'
                     AND ppa.effective_date         = p_effective_date
                     AND ppa.business_group_id  = p_business_group_id
                     AND fai.context1                   = ppa.payroll_action_id
                     AND fai.user_entity_id           = p_user_entity_id
                     AND fai.value                        = 'Y'
               );
BEGIN
    --
    hr_utility.set_location('Entering: ' || l_proc, 10);
    --
    -- Get the user entity id for A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER

    FOR c_rec IN c_get_user_entity_id
    LOOP
           l_ue_id := c_rec.user_entity_id;
    END LOOP;

  -- Decide upon the report Category based on the archived emp type

    l_code := 'MT';
    FOR c_rec IN c_chk_for_govt_employer (l_ue_id)
    LOOP
         l_code := 'RG';
    END LOOP;
    RETURN l_code;
END get_report_category_mt;


FUNCTION set_application_error(p_state			varchar2,
                               p_error			varchar2,
			       p_assignment_action_id	number
			      )
RETURN varchar2 IS
BEGIN
	IF p_state = 'FED' and p_error = 'Y'
	THEN
	        --raise hr_utility.hr_error;
		update pay_assignment_actions
		      set SERIAL_NUMBER = 'E999999999'
		 where assignment_action_id = p_assignment_action_id;
	        return 'Y';
	ELSE
	      return 'N';
	END IF;
END set_application_error;
--
-- This function is used by formula MT_MMRF_EW_WAGE_RECORD and
-- MT_MMRF_EO_WAGE_RECORD
--
FUNCTION get_tax_unit_info  (tax_unit_id                    IN NUMBER					-- Context when from formula
						  , assignment_action_id	IN NUMBER					-- Context
				                  ,p_tax_year			IN NUMBER					--  Parameter
                                                  ,p_federal_ein			OUT NOCOPY VARCHAR2		--  Parameter
						  ,p_tax_jd_code		OUT NOCOPY VARCHAR2		--Parameter
						  ,p_tax_unit_info1		OUT NOCOPY VARCHAR2		--Parameter
						  ,p_tax_unit_info2		OUT NOCOPY VARCHAR2		--Parameter
                                                )
    RETURN varchar2
IS
    CURSOR c_get_tax_unit_info (c_tax_unit_id  NUMBER
                                                   ,c_tax_year     NUMBER)
    IS
            SELECT  federal_ein
                           ,tax_unit_name
             FROM  pay_us_w2_tax_unit_v put
          WHERE  tax_unit_id  = c_tax_unit_id
               AND  year           = c_tax_year;

    CURSOR c_get_ye_payroll_action (c_tax_unit_id  NUMBER
							   ,c_assignment_action_id  NUMBER)
    IS
            SELECT  payroll_action_id
             FROM  pay_assignment_actions
          WHERE  tax_unit_id			= c_tax_unit_id
               AND  assignment_action_id	= c_assignment_action_id;

l_tax_unit_name		VARCHAR2(2000);
l_federal_EIN			VARCHAR2(200);
l_payroll_action_id		NUMBER;
l_tax_jurisdiction_code   VARCHAR2(200);

BEGIN
	        hr_utility.trace('In Procedure PAY_US_MMREF_REPORTING.GET_TAX_UNIT_INFO' );
	        OPEN c_get_tax_unit_info(tax_unit_id,
		                                           p_tax_year);
		FETCH c_get_tax_unit_info INTO l_federal_EIN,
								      l_tax_unit_name;
		CLOSE c_get_tax_unit_info;
		p_Federal_EIN := l_federal_EIN;
		-- Extra set of information accessed for Multi thread Federal W-2 RW and RO record
		l_payroll_action_id := 0;
		BEGIN
			l_tax_jurisdiction_code := ' ';
			OPEN c_get_ye_payroll_action(tax_unit_id,
									  assignment_action_id);
			FETCH c_get_ye_payroll_action INTO l_payroll_action_id;
			CLOSE c_get_ye_payroll_action;
			IF l_payroll_action_id <> 0 THEN
				l_tax_jurisdiction_code :=
					hr_us_w2_rep.get_w2_tax_unit_item (tax_unit_id,
											          l_payroll_action_id,
												  'A_LC_W2_REPORTING_RULES_ORG_TAX_JURISDICTION');
			END IF;
			p_tax_jd_code	:= l_tax_jurisdiction_code;
		END;
	        hr_utility.trace('Federal EIN	'||l_federal_EIN );
	        hr_utility.trace('Tax Unit Name	'|| l_tax_unit_name);
	        hr_utility.trace('Tax Jurisdiction Code	'|| l_tax_jurisdiction_code);
		return l_tax_unit_name;
    EXCEPTION
    WHEN OTHERS THEN
                 l_tax_unit_name      := ' ';
                 p_Federal_EIN        := ' ';
                 return l_tax_unit_name;
END get_tax_unit_info;

FUNCTION  get_w2_er_arch_bal(
                         w2_balance_name      in varchar2,
                         w2_tax_unit_id           in varchar2,
                         w2_jurisdiction_code   in varchar2,
                         w2_jurisdiction_level   in varchar2,
                         w2_year                     in varchar2,
                         a1 OUT NOCOPY varchar2,
                         a2 OUT NOCOPY varchar2,
                         a3 OUT NOCOPY varchar2,
                         a4 OUT NOCOPY varchar2,
                         a5 OUT NOCOPY varchar2,
                         a6 OUT NOCOPY varchar2,
                         a7 OUT NOCOPY varchar2,
                         a8 OUT NOCOPY varchar2,
                         a9 OUT NOCOPY varchar2,
                         a10 OUT NOCOPY varchar2,
                         a11 OUT NOCOPY varchar2,
                         a12 OUT NOCOPY varchar2,
                         a13 OUT NOCOPY varchar2,
                         a14 OUT NOCOPY varchar2,
                         a15 OUT NOCOPY varchar2,
                         a16 OUT NOCOPY varchar2,
                         a17 OUT NOCOPY varchar2,
                         a18 OUT NOCOPY varchar2,
                         a19 OUT NOCOPY varchar2,
                         a20 OUT NOCOPY varchar2,
                         a21 OUT NOCOPY varchar2,
                         a22 OUT NOCOPY varchar2,
                         a23 OUT NOCOPY varchar2,
                         a24 OUT NOCOPY varchar2,
                         a25 OUT NOCOPY varchar2,
                         a26 OUT NOCOPY varchar2,
                         a27 OUT NOCOPY varchar2,
                         a28 OUT NOCOPY varchar2,
                         a29 OUT NOCOPY varchar2,
                         a30 OUT NOCOPY varchar2,
                         a31 OUT NOCOPY varchar2,
                         a32 OUT NOCOPY varchar2,
                         a33 OUT NOCOPY varchar2,
                         a34 OUT NOCOPY varchar2,
                         a35 OUT NOCOPY varchar2,
                         a36 OUT NOCOPY varchar2,
                         a37 OUT NOCOPY varchar2,
                         a38 OUT NOCOPY varchar2,
                         a39 OUT NOCOPY varchar2,
                         a40 OUT NOCOPY varchar2,
                         a41 OUT NOCOPY varchar2,
                         a42 OUT NOCOPY varchar2,
                         a43 OUT NOCOPY varchar2,
                         a44 OUT NOCOPY varchar2,
                         a45 OUT NOCOPY varchar2,
                         a46 OUT NOCOPY varchar2,
                         a47 OUT NOCOPY varchar2
                         )
                          RETURN varchar2 IS

CURSOR C_EMP_count(cp_tax_unit_id	number
				       ,cp_tax_year		varchar2) IS
  select   count(*)
   from pay_payroll_actions ppa,
           pay_assignment_actions paa
 where ppa.report_type           = 'W2'
     and ppa.report_qualifier    = 'FED'
     and ppa.report_category	= 'MT'
     and effective_date              = to_date('31/12/'|| cp_tax_year, 'dd/mm/yyyy')
     and ppa.payroll_action_id  = paa.payroll_action_id
     and paa.action_status          = 'C'
     and NVL(paa.serial_number, 'S')       <> 'E999999999'
     and paa.tax_unit_id             = cp_tax_unit_id;

l_rw_error_count		NUMBER := 0;

CURSOR c_rw_error_count ( cp_tax_unit_id		number
				               ,cp_tax_year		varchar2) IS
select  count(*)
  from  pay_payroll_actions       ppa
	  ,pay_assignment_actions paa
where ppa.report_type		= 'W2'
    and ppa.report_qualifier	= 'FED'
    and ppa.report_category	= 'MT'
    and ppa.effective_date		= to_date('31/12/'|| cp_tax_year,'dd/mm/yyyy')
    and ppa.payroll_action_id	= paa.payroll_action_id
    and NVL(paa.serial_number,'S') = 'E999999999'
    and paa.action_status          = 'C'
    and paa.tax_unit_id		= cp_tax_unit_id;

CURSOR C_ER_SUM ( P_TAX_UNIT_ID number) IS
SELECT user_entity_name,
              DECODE(fue.user_entity_name,
       'A_REGULAR_EARNINGS_PER_GRE_YTD', nvl(sum(round(to_number(value),2)),0) ,
       'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' , nvl(sum(round(to_number(value),2)),0) ,
       'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' , nvl(sum(round(to_number(value),2)),0) ,
       'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD', nvl(sum(round(to_number(value),2)),0) ,
       'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' , nvl(sum(round(to_number(value),2)),0) ,
       'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' , nvl(sum(round(to_number(value),2)),0) ,
       'A_FIT_WITHHELD_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_SS_EE_TAXABLE_PER_GRE_YTD',   nvl(sum(round(to_number(value),2)),0) ,
       'A_SS_EE_WITHHELD_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_BOX_7_PER_GRE_YTD',  nvl(sum(round(to_number(value),2)),0) ,
       'A_EIC_ADVANCE_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_DEPENDENT_CARE_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_401K_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_403B_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_408K_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_457_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_501C_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_MILITARY_HOUSING_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_NONQUAL_PLAN_PER_GRE_YTD',   nvl(sum(round(to_number(value),2)),0) ,
       'A_W2_NONQUAL_457_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_BOX_11_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_FIT_3RD_PARTY_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_NONQUAL_STOCK_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_HSA_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_NONTAX_COMBAT_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD', nvl(sum(to_number(value)),0) ,
       'A_W2_BOX_8_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD',  nvl(sum(round(to_number(value),2)),0) ,
       'A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD',  nvl(sum(round(to_number(value),2)),0) ,
       'A_W2_MSA_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_408P_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_ADOPTION_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_UNCOLL_SS_GTL_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_UNCOLL_MED_GTL_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
       'A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD',  nvl(sum(round(to_number(value),2)),0) ,
       'A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD',  nvl(sum(round(to_number(value),2)),0) ,
       'A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD',  nvl(sum(round(to_number(value),2)),0) ,
        'A_W2_ROTH_401K_PER_GRE_YTD',  nvl(sum(to_number(value)),0) ,
        'A_W2_ROTH_403B_PER_GRE_YTD',  nvl(sum(to_number(value)),0)
       ) val
 FROM  ff_archive_items fai,
             pay_action_interlocks pai,
             pay_payroll_actions  ppa,
             pay_assignment_actions paa,
             ff_user_entities fue
where ppa.report_type            = 'W2'
   and ppa.report_qualifier	= 'FED'
   and ppa.report_category	= 'MT'
   and effective_date		= to_date('31/12/'||w2_year,'dd/mm/yyyy')
   and ppa.payroll_action_id	= paa.payroll_action_id
   and paa.tax_unit_id		= p_tax_unit_id
   and paa.action_status			 = 'C'
   and NVL(paa.serial_number, 'S')	 <> 'E999999999'
   and paa.assignment_action_id	 = pai.locking_action_id
   and fai.context1				 = pai.locked_action_id
   and fai.user_entity_id			 = fue.user_entity_id
   and fue.user_entity_name  IN
(
     'A_REGULAR_EARNINGS_PER_GRE_YTD' ,
     'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,
     'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,
     'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,
     'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' ,
     'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' ,
     'A_FIT_WITHHELD_PER_GRE_YTD',
     'A_SS_EE_TAXABLE_PER_GRE_YTD',
     'A_SS_EE_WITHHELD_PER_GRE_YTD',
     'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD',
     'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD',
     'A_W2_BOX_7_PER_GRE_YTD',
     'A_EIC_ADVANCE_PER_GRE_YTD',
     'A_W2_DEPENDENT_CARE_PER_GRE_YTD',
     'A_W2_401K_PER_GRE_YTD',
     'A_W2_403B_PER_GRE_YTD',
     'A_W2_408K_PER_GRE_YTD',
     'A_W2_457_PER_GRE_YTD',
     'A_W2_501C_PER_GRE_YTD',
     'A_W2_MILITARY_HOUSING_PER_GRE_YTD',
     'A_W2_NONQUAL_PLAN_PER_GRE_YTD',
     'A_W2_NONQUAL_457_PER_GRE_YTD',
     'A_W2_BOX_11_PER_GRE_YTD',
     'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD',
     'A_FIT_3RD_PARTY_PER_GRE_YTD',
     'A_W2_NONQUAL_STOCK_PER_GRE_YTD',
     'A_W2_HSA_PER_GRE_YTD',
     'A_W2_NONTAX_COMBAT_PER_GRE_YTD',
     'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD',
     'A_W2_BOX_8_PER_GRE_YTD',
     /* Sum of  */
     'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD',
     'A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD',
     'A_W2_MSA_PER_GRE_YTD',
     'A_W2_408P_PER_GRE_YTD',
     'A_W2_ADOPTION_PER_GRE_YTD',
     'A_W2_UNCOLL_SS_GTL_PER_GRE_YTD',
     'A_W2_UNCOLL_MED_GTL_PER_GRE_YTD',
     'A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD',
     'A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD',
     'A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD',
     'A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD',
     'A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD'
   , 'A_W2_ROTH_401K_PER_GRE_YTD'
   , 'A_W2_ROTH_403B_PER_GRE_YTD'
)
group by fue.user_entity_name;


CURSOR c_ter(cp_tax_unit_id number) IS
SELECT
 fue.user_entity_name,decode(fue.user_entity_name,
                              'A_SIT_WITHHELD_PER_JD_GRE_YTD' ,nvl(sum(to_number(value)),0) ,
                              'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD', nvl(sum(round(to_number(value),2)),0) ,
                              'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD', nvl(sum(round(to_number(value),2)),0) ,
                              'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD', nvl(sum(round(to_number(value),2)),0)
                              ) val
FROM ff_archive_item_contexts faic
           ,ff_archive_items fai
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,pay_action_interlocks pai
           ,ff_user_entities fue
WHERE
    ppa.report_type                   = 'W2'
and ppa.report_qualifier           = 'FED'
and ppa.report_category          = 'MT'
and ppa.effective_date            = to_date('31/12/'||w2_year,'dd/mm/yyyy')
and paa.payroll_action_id        = ppa.payroll_action_id
and paa.assignment_action_id  = pai.locking_action_id
and fai.context1                      = pai.locked_action_id
and context                            = '72-000-0000'
and fai.archive_item_id           = faic.archive_item_id
and fai.user_entity_id             = fue.user_entity_id
and paa.tax_unit_id                = cp_tax_unit_id
and fue.user_entity_name       in ('A_SIT_WITHHELD_PER_JD_GRE_YTD',
                                                   'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD',
                                                   'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD',
                                                   'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD')
and paa.action_status = 'C'
group by fue.user_entity_name;
/* 7109106 */
/* CURSOR c_ter(cp_tax_unit_id number) IS
SELECT
  fue.user_entity_name,decode(fue.user_entity_name,
                              'A_SIT_WITHHELD_PER_JD_GRE_YTD' ,nvl(sum(to_number(value)),0) ,
                              'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD', nvl(sum(round(to_number(value),2)),0) ,
                              'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD', nvl(sum(round(to_number(value),2)),0) ,
                              'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD', nvl(sum(round(to_number(value),2)),0),
                              'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD', nvl(sum(round(to_number(value),2)),0)) val
FROM ff_archive_item_contexts faic
           ,ff_archive_items fai
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,pay_action_interlocks pai
           ,ff_user_entities fue
WHERE
    ppa.report_type                   = 'W2'
and ppa.report_qualifier           = 'FED'
and ppa.report_category          = 'MT'
and ppa.effective_date            = to_date('31/12/'||w2_year,'dd/mm/yyyy')
and paa.payroll_action_id        = ppa.payroll_action_id
and paa.assignment_action_id  = pai.locking_action_id
and fai.context1                      = pai.locked_action_id
and fai.archive_item_id           = faic.archive_item_id
and fai.user_entity_id             = fue.user_entity_id
and paa.tax_unit_id                = cp_tax_unit_id
and case when fue.user_entity_name = 'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD' then to_char(cp_tax_unit_id)
    else '72-000-0000' end = context
and fue.user_entity_name       in ('A_SIT_WITHHELD_PER_JD_GRE_YTD',
                                                   'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD',
                                                   'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD',
                                                   'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD' ,
                                                   'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD' )
and paa.action_status = 'C'
and exists (select 'Y'
            from ff_user_entities fai1, ff_archive_items fue1
            where fai1.user_entity_name = 'A_STATE_ABBREV'
            and fai1.user_entity_id             = fue1.user_entity_id
            and fue1.value = 'PR'
            and fai1.user_entity_id             = fue1.user_entity_id
            and fue1.context1   = fai.context1 )
group by fue.user_entity_name; */

CURSOR c_ro_count ( cp_tax_unit_id number) IS
select count(*)
from pay_payroll_actions ppa
       ,pay_assignment_actions paa
       ,ff_archive_items fai
where ppa.report_type			= 'W2'
    and ppa.report_qualifier		= 'FED'
    and ppa.report_category		= 'MT'
    and effective_date			= to_date('31/12/'||w2_year,'dd/mm/yyyy')
    and ppa.payroll_action_id		= paa.payroll_action_id
    and paa.assignment_action_id	= fai.context1
    and name					is not null
    and name					like 'TRANSFER_RO_TOTAL'
    and paa.tax_unit_id			= cp_tax_unit_id
  group by tax_unit_id;

l_er_sum			er_sum_table;
l_date			date;
l_tax_unit_id		varchar2(10);
l_fit_with			varchar2(20);
l_ss_ee_taxable	varchar2(20);
l_total_emp		number := 0;
l_ro_count		number := 0;
l_a2				number := 0;
l_a20			number := 0;
l_a27			number := 0;
l_a35			number := 0;
l_a36			number := 0;
l_a37			number := 0;
l_a39			number := 0;
l_a18			number := 0;
l_a4				number := 0;
l_a8				number := 0;

l_a70			number := 0;
l_a71			number := 0;
l_a72			number := 0;
l_a73			number := 0;
--l_a22     number := 0; /* 7109106 */
BEGIN
--        hr_utility.trace_on(NULL,'FEDW2MT');
        hr_utility.trace('In Procedure GET_W2_ER_ARCH_BAL' );

        a1 := '0';
        a2 := '0';
        a3 := '0';
        a4 := '0';
        a5 := '0';
        a6 := '0';
        a7 := '0';
        a8 := '0';
        a9 := '0';
        a10:= '0';
        a11 := '0';
        a12 := '0';
        a13 := '0';
        a14 := '0';
        a15 := '0';
        a16 := '0';
        a17 := '0';
        a18 := '0';
        a19 := '0';
        a20 := '0';
        a21 := '0';
        a22 := '0';
        a23 := '0';
        a24 := '0';
        a25 := '0';
        a26 := '0';
        a27 := '0';
        a28 := '0';
        a29 := '0';
        a30 := '0';
        a31 := '0';
        a32 := '0';
        a33 := '0';
        a34 := '0';
        a35 := '0';
        a36 := '0';
        a37 := '0';
        a38 := '0';
        a39 := '0';
        a40 := '0';
        a41 := '0';
        a42 := '0';
        a43 := '0';
        a44 := '0';
        a45 := '0';
        a46 := '0';
        a47 := '0';


    OPEN   C_EMP_COUNT(to_number(W2_tax_unit_id),
                                              w2_year);
    FETCH C_EMP_COUNT  INTO a1;
    IF C_EMP_COUNT%NOTFOUND THEN
         a1 := 0;
    END IF;
    CLOSE C_EMP_COUNT;

    l_rw_error_count := 0;
    OPEN c_rw_error_count(to_number(w2_tax_unit_id),
                                             w2_year);
    FETCH c_rw_error_count INTO l_rw_error_count;
    CLOSE c_rw_error_count;

     a1 :=  a1 || '.'||to_char(l_rw_error_count);

    l_a2 := 0;
    l_a20 := 0;
    l_a27 := 0;
    l_a39 := 0;
    l_a35 := 0;
    l_a36 := 0;
    l_a37 := 0;

    FOR I IN C_ER_SUM(to_number(W2_TAX_UNIT_ID)) LOOP

       if I.user_entity_name = 'A_REGULAR_EARNINGS_PER_GRE_YTD' THEN
              l_a2 := l_a2 + i.val;
       ELSIF I.user_entity_name = 'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' THEN
             l_a2 := l_a2 + i.val;
       ELSIF I.user_entity_name = 'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' THEN
             l_a2  := l_a2 + i.val;
       ELSIF I.user_entity_name = 'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' THEN
             l_a2 := l_a2 + i.val;
       ELSIF I.user_entity_name = 'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' THEN
             l_a2 := l_a2 + i.val;
       ELSIF I.user_entity_name = 'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' THEN
             l_a2 := l_a2 - i.val;
       ELSIF I.user_entity_name = 'A_FIT_WITHHELD_PER_GRE_YTD' THEN
              a3 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =  'A_SS_EE_TAXABLE_PER_GRE_YTD' THEN
             l_a4 := i.val;
        ELSIF i.user_entity_name ='A_SS_EE_WITHHELD_PER_GRE_YTD' THEN
            a5 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name = 'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD'  THEN
            a6 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name = 'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD'  THEN
            a7 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_BOX_7_PER_GRE_YTD'  THEN
            l_a8 := i.val;
        ELSIF i.user_entity_name =      'A_EIC_ADVANCE_PER_GRE_YTD'  THEN
            a9 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_DEPENDENT_CARE_PER_GRE_YTD'  THEN
            a10 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_401K_PER_GRE_YTD'  THEN
            a11 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_403B_PER_GRE_YTD'  THEN
            a12 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_408K_PER_GRE_YTD'  THEN
            a13 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =     'A_W2_457_PER_GRE_YTD'  THEN
            a14 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_501C_PER_GRE_YTD'  THEN
            a15 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_MILITARY_HOUSING_PER_GRE_YTD'  THEN
            a16 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_NONQUAL_457_PER_GRE_YTD'  THEN
            a17:= to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =      'A_W2_BOX_11_PER_GRE_YTD'  THEN
            a18 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =       'A_W2_HSA_PER_GRE_YTD'  THEN
            a19 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =   'A_W2_NONQUAL_PLAN_PER_GRE_YTD'  THEN
            l_a20 :=  i.val;
        ELSIF i.user_entity_name =   'A_W2_NONTAX_COMBAT_PER_GRE_YTD'  THEN
            a21 := to_char(trunc(i.val * 100));
         ELSIF i.user_entity_name =      'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD'  THEN
            a22:= to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =       'A_FIT_3RD_PARTY_PER_GRE_YTD'  THEN
            a23 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =        'A_W2_NONQUAL_STOCK_PER_GRE_YTD'  THEN
            a24 := to_char(trunc(i.val * 100));
        ELSIF i.user_entity_name =     'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD'  THEN
            a25 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_BOX_8_PER_GRE_YTD' THEN
             a26 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name = 'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD' THEN
             l_a27 :=  i.val;
       ELSIF i.user_entity_name ='A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD'  THEN
             l_a27 :=  l_a27 + i.val;
       ELSIF i.user_entity_name ='A_W2_MSA_PER_GRE_YTD'  THEN
              a28 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_408P_PER_GRE_YTD'  THEN
              a29 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_ADOPTION_PER_GRE_YTD' THEN
              a30 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_UNCOLL_SS_GTL_PER_GRE_YTD'  THEN
               a31 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_UNCOLL_MED_GTL_PER_GRE_YTD'  THEN
               a32 := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD'  THEN
               a33  := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD'  THEN
                a34  := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD'  THEN
               l_a35 := i.val;
       ELSIF i.user_entity_name ='A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD'  THEN
               l_a36  := i.val;
       ELSIF i.user_entity_name ='A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD'  THEN
                l_a37  := i.val;
       ELSIF i.user_entity_name ='A_W2_ROTH_401K_PER_GRE_YTD'  THEN
                a46  := to_char(trunc(i.val * 100));
       ELSIF i.user_entity_name ='A_W2_ROTH_403B_PER_GRE_YTD'  THEN
                a47  := to_char(trunc(i.val * 100));
       END IF;

       IF i.user_entity_name =      'A_W2_NONQUAL_457_PER_GRE_YTD'  THEN
               l_a70 := i.val;
       END IF;

	hr_utility.trace('UE Name : '|| i.user_entity_name || ' SumValue '|| to_char( i.val));
     END LOOP;
/*
       a2   := to_char(round(l_a2, 2) * 100);
       a20 := to_char(round(l_a20, 2) * 100);
       a27 :=  to_char(round(l_a27, 2) * 100);
       a35 := to_char(round(l_a35, 2) * 100);
       a36  := to_char(round(l_a36, 2) * 100);
       a37  := to_char(round(l_a37, 2) * 100);
*/
       l_a20 := l_a20 - l_a70;

       a2   := to_char(trunc(l_a2 * 100));
       a20 := to_char(trunc(l_a20 * 100));
       a27 :=  to_char(trunc(l_a27 * 100));
       a35 := to_char(trunc(l_a35 * 100));
       a36  := to_char(trunc(l_a36 * 100));
       a37  := to_char(trunc(l_a37 * 100));
       l_a4 := l_a4 - l_a8;
       a4    := to_char(trunc(l_a4 * 100));
       a8    := to_char(trunc(l_a8 * 100));

    OPEN   c_ro_count(to_number(W2_TAX_UNIT_ID));
    FETCH c_ro_count  INTO l_ro_count;
    CLOSE c_ro_count;

    a38  := to_char(nvl(l_ro_count,0));

   IF l_ro_count > 0 THEN
      FOR J IN c_ter(to_number(W2_TAX_UNIT_ID)) LOOP
          if J.user_entity_name         =  'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD'  THEN
                l_a71 :=  J.val;
          ELSIF J.user_entity_name =  'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD' THEN
                l_a72 :=  J.val;
          ELSIF J.user_entity_name =  'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD' THEN
                l_a73  :=  J.val;
      /*    ELSIF J.user_entity_name =  'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD' THEN
                l_a22  :=  to_char(trunc(J.val * 100 )); */
                 /* 7109106 */
	  ELSIF J.user_entity_name  = 'A_SIT_WITHHELD_PER_JD_GRE_YTD' THEN
                a40  := to_char(trunc(J.val * 100));
          END IF;
       END LOOP;
    END IF ;

    l_a39 := (l_a71 + l_a72) - l_a73;
  --  a22 := a22 - l_a22 ; /* 7109106 */
    a39  := to_char(round(l_a39, 2) * 100 ) ;
    a41  := to_char(trunc( (l_a39 - l_a37 - l_a35 - l_a36 ) * 100));

    hr_utility.trace('Value of a1 : '||a1 );
    hr_utility.trace('Value of a2 : '||a2);
    hr_utility.trace('Value of a3 : '||a3 );
    hr_utility.trace('Value of a4 : '||a4 );
    hr_utility.trace('Value of a5 : '||a5 );
    hr_utility.trace('Value of a6 : '||a6 );
    hr_utility.trace('Value of a7 : '||a7 );
    hr_utility.trace('Value of a8 : '||a8 );
    hr_utility.trace('Value of a9 : '||a9 );
    hr_utility.trace('Value of a10 : '||a10 );
    hr_utility.trace('Value of a11 : '||a11 );
    hr_utility.trace('Value of a12 : '||a12 );
    hr_utility.trace('Value of a13 : '||a13 );
    hr_utility.trace('Value of a14 : '||a14 );
    hr_utility.trace('Value of a15 : '||a15 );
    hr_utility.trace('Value of a16 : '||a16 );
    hr_utility.trace('Value of a17 : '||a17 );
    hr_utility.trace('Value of a18 : '||a18 );
    hr_utility.trace('Value of a19 : '||a19 );
    hr_utility.trace('Value of a20 : '||a20 );
    hr_utility.trace('Value of a21 : '||a21 );
    hr_utility.trace('Value of a22 : '||a22 );
    hr_utility.trace('Value of a23 : '||a23 );
    hr_utility.trace('Value of a24 : '||a24 );
    hr_utility.trace('Value of a25 : '||a25 );
    hr_utility.trace('Value of a26 : '||a26 );
    hr_utility.trace('Value of a27 : '||a27 );
    hr_utility.trace('Value of a28 : '||a28 );
    hr_utility.trace('Value of a29 : '||a29 );
    hr_utility.trace('Value of a30 : '||a30 );
    hr_utility.trace('Value of a31 : '||a31 );
    hr_utility.trace('Value of a32 : '||a32 );
    hr_utility.trace('Value of a33 : '||a33 );
    hr_utility.trace('Value of a34 : '||a34 );
    hr_utility.trace('Value of a35 : '||a35 );
    hr_utility.trace('Value of a36 : '||a36 );
    hr_utility.trace('Value of a37 : '||a37 );
    hr_utility.trace('Value of a38 : '||a38 );
    hr_utility.trace('Value of a39 : '||a39 );
    hr_utility.trace('Value of a40 : '||a40 );
    hr_utility.trace('Value of a41 : '||a41 );
    hr_utility.trace('Value of a42 : '||a42 );
    hr_utility.trace('Value of a43 : '||a43 );
    hr_utility.trace('Value of a44 : '||a44 );
    hr_utility.trace('Value of a45 : '||a45 );
    hr_utility.trace('Value of a46 : '||a46 );
    hr_utility.trace('Value of a47 : '||a47 );
    hr_utility.trace('Value of a71 : '||to_char(l_a71));
    hr_utility.trace('Value of a72 : '||to_char(l_a72));
    hr_utility.trace('Value of a73 : '||to_char(l_a73));

    return '0' ;
END get_w2_er_arch_bal;

--BEGIN
--        hr_utility.trace_on(NULL,'FEDW2MT');
END pay_us_mmref_reporting;

/
