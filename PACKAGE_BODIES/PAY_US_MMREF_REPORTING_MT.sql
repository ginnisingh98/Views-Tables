--------------------------------------------------------
--  DDL for Package Body PAY_US_MMREF_REPORTING_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMREF_REPORTING_MT" AS
/* $Header: payusmmrfrecmt.pkb 120.0.12000000.1 2007/02/24 10:12:03 sackumar noship $ */
/*REM +======================================================================+
REM |                Copyright (c) 1997 Oracle Corporation                 |
REM |                   Redwood Shores, California, USA                    |
REM |                        All rights reserved.                          |
REM +======================================================================+
REM Package Body Name : pay_us_mmref_reporting_mt
REM Package File Name : payusmmrfrecmt.pkb
REM Description : This package declares functions and procedures to support
REM the genration of magnetic W2 reports for US legislative requirements
REM incorporating magtape resilience and the new end-of-year processing.
REM
REM Change List:
REM ------------
REM
REM Name        Date       Version Bug         Text
REM ---------   ---------- ------- ----------- ------------------------------
REM ppanda      04-aug-2006 115.01             Created
REM ========================================================================

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
	           ('pay_us_mmref_reporting_mt.bal_db_item - opening cursor', 10);
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
		('pay_us_mmref_reporting_mt.bal_db_item - fetched from cursor', 30);
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
		('pay_us_mmref_reporting_mt.get_report_parameters', 10);
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
			('pay_us_mmref_reporting_mt.get_report_parameters', 20);
		ELSE
			p_state_code := '';
			hr_utility.set_location
			('pay_us_mmref_reporting_mt.get_report_parameters', 30);
		END IF;
		IF p_state_abbrev = 'FED' AND p_report_type = 'W2' THEN
			p_report_type := 'FEDW2';
		ELSIF p_report_type = 'W2' THEN
			p_report_type := 'STW2';
		END IF;
		hr_utility.set_location
		('pay_us_mmref_reporting_mt.get_report_parameters', 40);
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
		('pay_us_mmref_reporting_mt.get_balance_value', 10);
		pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
	IF p_state_abbrev <> 'FED' THEN
			SELECT jurisdiction_code
			  INTO l_jurisdiction_code
			  FROM pay_state_rules
		  	 WHERE state_code = p_state_abbrev;
     			hr_utility.set_location
			('pay_us_mmref_reporting_mt.get_balance_value', 15);
			pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction_code);
	END IF;
	hr_utility.trace(p_balance_name);
	hr_utility.trace('Context');
	hr_utility.trace('Tax Unit Id:	'|| p_tax_unit_id);
	hr_utility.trace('Jurisdiction:	'|| l_jurisdiction_code);
	hr_utility.set_location
		('pay_us_mmref_reporting_mt.get_balance_value', 20);
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
          AND report_category IN ('RG', 'RM','MT') ;


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

        hr_utility.set_location('pay_us_mmref_reporting_mt.preprocess_check', 10);

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
                    hr_utility.set_location('pay_us_mmref_reporting_mt.preprocess_check', 99);
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
                   hr_utility.set_location('pay_us_mmref_reporting_mt.preprocess_check',20);
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


                    hr_utility.trace('pay_us_mmref_reporting_mt.preprocess_check');
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
        hr_utility.trace_on(null,'FEDW2');
	hr_utility.set_location( 'pay_us_mmref_reporting_mt.range_cursor', 10);
	get_report_parameters(
		p_pactid,
		p_year_start,
		p_year_end,
		p_state_abbrev,
		p_state_code,
		p_report_type,
		p_business_group_id
	);
	hr_utility.set_location( 'pay_us_mmref_reporting_mt.range_cursor', 20);
/*	IF preprocess_check(p_pactid,
		p_year_start,
		p_year_end,
		p_business_group_id,
		p_state_abbrev,
		p_state_code,
		p_report_type
	) THEN
	*/
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
			hr_utility.set_location( 'pay_us_mmref_reporting_mt.range_cursor',
					30);
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
			hr_utility.set_location( 'pay_us_mmref_reporting_mt.range_cursor',
				40);
		END IF;
--	END IF;
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
              and paf.person_id BETWEEN p_stperson AND p_endperson
              and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0
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
              and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                                    'A_W2_STATE_WAGES',
                                                     paa.tax_unit_id,
                                                     faic.context , 2),0) > 0
              and exists ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */
                           select 'x'
                             from pay_us_state_tax_info_f pustif
                            where substr(faic.context,1,2) = pustif.state_code
                              and ppa.effective_date between pustif.effective_start_date
                                                         and pustif.effective_end_date
                              and pustif.sit_exists = 'Y'
                           )
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             WHERE hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )
               ORDER BY 1, 3, 4 DESC, 2
               FOR UPDATE OF paf.assignment_id;
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
	hr_utility.set_location( 'pay_us_mmref_reporting_mt.create_assignement_act',
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
	hr_utility.set_location( 'pay_us_mmref_reporting_mt.create_assignement_act',
		20);
	IF l_report_type = 'FEDW2' THEN
		OPEN c_federal;
--
-- This was added specifically to have PuertoRico GRE employees for assignment creation
--
        ELSIF l_report_type = 'STW2' and l_state_abbrev = 'PR' THEN
		OPEN c_pr_state;
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
				'pay_us_mmref_reporting_mt.create_assignement_act', 30);
			EXIT WHEN c_federal%NOTFOUND;
                ELSIF l_report_type = 'STW2' and l_state_abbrev = 'PR' THEN
                        FETCH c_pr_state INTO l_person_id,
                                           l_assignment_id,
                                           l_tax_unit_id,
                                           l_effective_end_date,
                                           l_assignment_action_id,
                                           l_w2_box17;
                        hr_utility.set_location(
                                'pay_us_mmref_reporting_mt.create_assignement_act', 40);
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

		ELSIF l_report_type = 'STW2' THEN
			FETCH c_state INTO l_person_id,
			                   l_assignment_id,
			                   l_tax_unit_id,
			                   l_effective_end_date,
                                           l_assignment_action_id,
                                           l_w2_box17;
			hr_utility.set_location(
				'pay_us_mmref_reporting_mt.create_assignement_act', 40);
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
				'pay_us_mmref_reporting_mt.create_assignement_act', 50);
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

                  END IF;
                   IF (l_report_type = 'FEDW2' and l_value <> 0 ) OR
                      (l_report_type = 'STW2') then
			SELECT pay_assignment_actions_s.nextval
			INTO lockingactid
			FROM dual;
			hr_utility.set_location(
				'pay_us_mmref_reporting_mt.create_assignement_act', 60);
			hr_nonrun_asact.insact(lockingactid, l_assignment_id, p_pactid,
				p_chunk, l_tax_unit_id);
			hr_utility.set_location(
				'pay_us_mmref_reporting_mt.create_assignement_act', 70);
			--update serial number for highly compensated people for the
			--state W2.
			/*IF l_report_type = 'STW2' THEN
				hr_utility.set_location(
					'pay_us_mmref_reporting_mt.create_assignement_act', 80);
				IF l_w2_box17 > 9999999.99 THEN
					UPDATE pay_assignment_actions
					SET serial_number = 999999
					WHERE assignment_action_id = lockingactid;
				END IF;
			END IF;*/ -- 4490252
			hr_nonrun_asact.insint(lockingactid, l_assignment_action_id);
			hr_utility.set_location(
				'pay_us_mmref_reporting_mt.create_assignement_act', 90);
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
  l_proc        varchar2(100) := 'pay_us_mmref_reporting_mt.get_report_category';
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

FUNCTION set_application_error(p_state varchar2,
                                                    p_error varchar2)
RETURN varchar2 IS
BEGIN

IF p_state = 'FED' and p_error = 'Y'
THEN
        raise hr_utility.hr_error;
        return 'Y';
END IF;
      return 'N';
END;
--
-- This function is used by formula MT_MMRF_EW_WAGE_RECORD and
-- MT_MMRF_EO_WAGE_RECORD
--
FUNCTION get_tax_unit_info  (tax_unit_id                    IN NUMBER             -- Context when from formula
                                                ,p_tax_year                    IN NUMBER
                                                ,p_federal_ein                OUT NOCOPY VARCHAR2
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

    l_tax_unit_name           VARCHAR2(2000);
    l_federal_EIN              VARCHAR2(200);

    BEGIN
        OPEN c_get_tax_unit_info(tax_unit_id,
 	                                         p_tax_year);
	FETCH c_get_tax_unit_info INTO l_tax_unit_name,
	                               l_federal_EIN;
        CLOSE c_get_tax_unit_info;
        p_Federal_EIN := l_federal_EIN;
        return l_tax_unit_name;
    EXCEPTION
    WHEN OTHERS THEN
                 l_tax_unit_name      := ' ';
                 p_Federal_EIN        := ' ';
                 return l_tax_unit_name;
    END get_tax_unit_info;

END pay_us_mmref_reporting_mt;

/
