--------------------------------------------------------
--  DDL for Package Body PAY_US_MAGW2_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MAGW2_REPORTING" AS
 /* $Header: pyyepmw2.pkb 115.15 2002/12/03 03:02:16 ppanda ship $ */
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
             AND UE.legislation_code = 'US'; /* Bug: 2296797 */
	l_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;
BEGIN
	hr_utility.set_location
	           ('pay_us_magw2_reporting.bal_db_item - opening cursor', 10);
        -- Open the cursor
	OPEN csr_defined_balance;
        -- Fetch the value
	FETCH  csr_defined_balance
	 INTO  l_defined_balance_id;
 	IF csr_defined_balance%NOTFOUND THEN
		CLOSE csr_defined_balance;
		hr_utility.set_location
		('pay_us_magw2_reporting.bal_db_item - no rows found from cursor', 20);
		hr_utility.raise_error;
	ELSE
		hr_utility.set_location
		('pay_us_magw2_reporting.bal_db_item - fetched from cursor', 30);
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
	(	p_pactid    		IN	       NUMBER,
		p_year_start		IN OUT	nocopy DATE,
		p_year_end		IN OUT  nocopy DATE,
		p_state_abbrev		IN OUT	nocopy VARCHAR2,
		p_state_code		IN OUT	nocopy VARCHAR2,
		p_report_type		IN OUT	nocopy VARCHAR2,
		p_business_group_id	IN OUT	nocopy NUMBER
	) IS
	BEGIN
		hr_utility.set_location
		('pay_us_magw2_reporting.get_report_parameters', 10);
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
			('pay_us_magw2_reporting.get_report_parameters', 20);
		ELSE
			p_state_code := '';
			hr_utility.set_location
			('pay_us_magw2_reporting.get_report_parameters', 30);
		END IF;
		IF p_state_abbrev = 'FED' AND p_report_type = 'W2' THEN
			p_report_type := 'FEDW2';
		ELSIF p_report_type = 'W2' THEN
			p_report_type := 'STW2';
		END IF;
		hr_utility.set_location
		('pay_us_magw2_reporting.get_report_parameters', 40);
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
		('pay_us_magw2_reporting.get_balance_value', 10);
		pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
	IF p_state_abbrev <> 'FED' THEN
			SELECT jurisdiction_code
			  INTO l_jurisdiction_code
			  FROM pay_state_rules
		  	 WHERE state_code = p_state_abbrev;
     			hr_utility.set_location
			('pay_us_magw2_reporting.get_balance_value', 15);
			pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction_code);
	END IF;
	hr_utility.trace(p_balance_name);
	hr_utility.trace('Context');
	hr_utility.trace('Tax Unit Id:	'|| p_tax_unit_id);
	hr_utility.trace('Jurisdiction:	'|| l_jurisdiction_code);
	hr_utility.set_location
		('pay_us_magw2_reporting.get_balance_value', 20);
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
		p_year_start		DATE,
		p_year_end			DATE,
		p_business_group_id	NUMBER,
		p_state_abbrev		VARCHAR2,
		p_state_code		VARCHAR2,
		p_report_type		VARCHAR2
	)
	RETURN BOOLEAN IS
		-- Cursor to get all the GREs belonging to the given business group
		CURSOR 	c_get_gre IS
		SELECT 	hou.organization_id gre
		  FROM 	hr_organization_information hoi,
	  	       	hr_organization_units hou
		 WHERE	hou.business_group_id+0 = p_business_group_id AND
 			    hoi.organization_id = hou.organization_id AND
	 	    	hoi.org_information_context = 'CLASS' AND
			    hoi.org_information1 = 'HR_LEGAL' AND
			    NOT EXISTS (
                                SELECT  'Y'
                                  FROM hr_organization_information
                                 WHERE organization_id = hou.organization_id
                                   AND org_information_context = '1099R Magnetic Report Rules');
        -- Check if the GRE needs to be archived.
		-- Cursor to fetch people in a given GRE with earnings in the given state to

        	CURSOR c_gre_state (cp_tax_unit_id NUMBER)IS
    		SELECT paf.person_id,
                       paf.assignment_id,
                       paf.effective_end_date
	        FROM per_assignments_f paf
	 	    WHERE exists
		      	(SELECT 'x'
			       FROM pay_us_emp_state_tax_rules_f pest
	  		      WHERE pest.state_code = p_state_code
                                AND pest.business_group_id + 0 = p_business_group_id
                                AND pest.effective_start_date <= p_year_end
                                AND pest.effective_end_date >= p_year_start
                                AND pest.assignment_id = paf.assignment_id
                         )
	            AND paf.effective_start_date <= p_year_end
	            AND paf.effective_end_date >= p_year_start
		    AND paf.business_group_id+0 = p_business_group_id
		    AND paf.assignment_type = 'E'
		    AND EXISTS
                         (SELECT 'x'
                            FROM pay_assignment_actions paa_act,
                                 pay_payroll_actions ppa_act
                           WHERE paa_act.assignment_id = paf.assignment_id
                             AND paa_act.tax_unit_id = cp_tax_unit_id
                             AND ppa_act.payroll_action_id = paa_act.payroll_action_id
                             AND ppa_act.action_type IN ('R', 'Q', 'B', 'I', 'V')
                             AND ppa_act.effective_date BETWEEN p_year_start
                                                            AND p_year_end
                             AND ppa_act.date_earned BETWEEN paf.effective_start_date
                                                         AND paf.effective_end_date
                             AND ppa_act.action_status = 'C' )
                      ORDER BY 1, 3 DESC, 2;

	-- Cursor to fetch people from the GRE belonging to the business group

		CURSOR c_gre_fed (cp_tax_unit_id NUMBER) IS
		SELECT  paf.person_id,
			paf.assignment_id,
			paf.effective_end_date
		  FROM  per_assignments_f paf
	   	 WHERE  paf.business_group_id+0 = p_business_group_id
		 -- In order to avoid full table scan on per_assignment_f
		 -- added assignmet_id
                   AND paf.assignment_id >= 0
                   AND paf.effective_start_date <= p_year_end
                   AND paf.effective_end_date >= p_year_start
                   AND paf.assignment_type = 'E'
                   AND EXISTS (
			SELECT	'x'
			  FROM 	pay_payroll_actions ppa_act,
				pay_assignment_actions paa_act
			 WHERE  paa_act.assignment_id = paf.assignment_id
			   AND  paa_act.tax_unit_id = cp_tax_unit_id
			   AND  ppa_act.payroll_action_id = paa_act.payroll_action_id
			   AND  ppa_act.action_type IN ('R', 'Q', 'B', 'I', 'V')
			   AND  ppa_act.effective_date
		       		BETWEEN  p_year_start AND p_year_end
			   AND  ppa_act.date_earned
				BETWEEN paf.effective_start_date AND paf.effective_end_date
			   AND  ppa_act.action_STATUS = 'C'  -- ADDED BY Djoshi
                          )
                 ORDER BY 1, 3 DESC, 2;

            -- Cursor to get payroll_action_ids of the pre-process for the given GRE.
			-- This will also serve as a check to make sure that all GREs have been
			-- archived
		CURSOR c_gre_payroll_action (cp_gre NUMBER) IS
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
      	  --any of the assignments for federal W2
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


/* cursor to determine if archive gre has any person in State */

  CURSOR c_person_in_state( cp_payroll_action_id number,
                            cp_user_entity_id   number,
                            cp_context_tax_unit  number,
                            cp_tax_unit_id        varchar2,
                            cp_context_jursidiction number)
      IS
  SELECT 'Y'
  FROM
       ff_archive_items fai,
       pay_assignment_actions paa,
       pay_payroll_actions ppa
 WHERE ppa.PAYROLL_ACTION_ID = CP_PAYROLL_ACTION_ID
  AND  ppa.payroll_action_id = paa.payroll_action_id
  AND  paa.assignment_action_id = fai.context1
  AND  fai.user_entity_id = cp_user_entity_id
  AND  fai.value  > 0
  AND  EXISTS
       ( SELECT 'Y'
           FROM ff_archive_item_contexts faic1
          WHERE faic1.archive_item_id = fai.archive_item_id
            AND faic1.context_id = cp_context_tax_unit
            AND rtrim(ltrim(faic1.context)) = cp_tax_unit_id
        )
   AND EXISTS
        ( SELECT 'Y'
           FROM ff_archive_item_contexts faic2
          WHERE faic2.archive_item_id = fai.archive_item_id
            AND faic2.context_id = cp_context_jursidiction
            AND rtrim(ltrim(substr(faic2.context,1,2))) = p_state_code
         );

/* cursor to check if the state tax Rules have been added or Not. */


CURSOR c_chk_archive_state_code(cp_tax_unit_id number,cp_payroll_action_id number)
IS
SELECT 'Y'
  FROM
        ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target,
        ff_database_items fdi
WHERE   target.context1 = cp_payroll_action_id
		/* context of payroll_action_id */
    and fdi.user_name = 'A_FIPS_CODE_JD'
    and target.user_entity_id = fdi.user_entity_id
    and fc2.context_name = 'TAX_UNIT_ID'
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(cp_tax_unit_id)
    and fc3.context_name = 'JURISDICTION_CODE'
    and con3.archive_item_id = target.archive_item_id
    and con3.context_id = fc3.context_id
    and substr(ltrim(rtrim(con3.context)),1,2) = p_state_code;
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
  AND report_category = 'RT' ;


/* Local variables used for processing */
    message_text              VARCHAR2(32000);
	l_gre				      NUMBER(15);
	l_person			      NUMBER(15);
	l_assignment			  NUMBER(15);
	l_asg_effective_dt		  DATE;
	l_payroll_action_id		  NUMBER(15);
	l_asg_errored			  VARCHAR2(1);
	l_asg_retry_pend		  VARCHAR2(1);
	l_balance_exists 		  NUMBER(1) := 0;
	l_no_of_gres_picked		  NUMBER(15) := 0;
    l_transmitter             NUMBER(15) :=0;
    l_state_tax_rules_exist   CHAR(1);
    l_person_in_state         CHAR(1);
    l_user_entity_id          number;
    l_context_jursidiction    number;
    l_context_tax_unit_id     number; --ff_contexts.context_id%type;
    l_package_error_status    char(1) := 'N';
BEGIN
/* GET the context and user entity id */

 OPEN  c_user_entity_id_of_bal;
 FETCH c_user_entity_id_of_bal INTO l_user_entity_id;
 IF c_user_entity_id_of_bal%NOTFOUND THEN
              CLOSE c_user_entity_id_of_bal;
              l_package_error_status := 'Y';

              /* message to user -  Database item missing */
              hr_utility.trace('Database item for balacne missing ');
              message_text := 'Database item missing ';
              hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
              hr_utility.set_message_token('MESSAGE', message_text);
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
               hr_utility.trace('Contxt_id value for tax unit id missing');
               hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
               hr_utility.set_message_token('MESSAGE', message_text);
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
               hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
               hr_utility.set_message_token('MESSAGE', message_text);
               hr_utility.raise_error;

  ELSE
               CLOSE c_context_jurisdiction;
  END IF;


/* Get the Tranmitter id of the Current Mag. W2. and check if it has
   archived or Not for the year End process

   Get the transmitter for the Mag. W2. Process. */

        OPEN c_transmitter;
        FETCH c_transmitter INTO l_transmitter;
        IF c_transmitter%NOTFOUND THEN
              CLOSE c_transmitter;
               /* message to user -- transmitter has not been defined for the gre */
                   message_text := 'Transmitter Not denfined';
                   hr_utility.trace('Transmitter Not defined ');
                   hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
                   hr_utility.set_message_token('MESSAGE', message_text);
           --        hr_utility.raise_error;
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
                 hr_utility.trace('Transmitter has not been Archvied ');
                 CLOSE c_gre_payroll_action;
                 /* message to user -- Transmitter has not been archived */
                 message_text := 'Transmitter has not been archived';
                 hr_utility.trace('Transmitter has not been archived');
                 hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
                 hr_utility.set_message_token('MESSAGE', message_text);
--                 hr_utility.raise_error;

           END IF;
                 CLOSE c_gre_payroll_action;

/* end of Transmitter Checking */


        hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 10);

       FOR gre_rec IN c_get_gre LOOP
           /* set l_gre to gre Fethched */
           l_gre := gre_rec.gre;
           /* Get the payroll_action_id of the archvier for given GRe */
           OPEN c_gre_payroll_action (l_gre);
           FETCH c_gre_payroll_action INTO l_payroll_action_id;
	   IF c_gre_payroll_action%FOUND THEN
              /* Check if any of the payroll_action_id has errored out or Not */
              OPEN  c_arch_errored_asg (l_payroll_action_id);
              FETCH c_arch_errored_asg
                 INTO l_asg_errored;
              IF c_arch_errored_asg%FOUND THEN
                 --Some of the assignments have not been archived


                 hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 70);
                 hr_utility.set_message(801, 'PAY_72729_ASG_NOT_ARCH');
                 l_package_error_status := 'Y';
                 /* message to user --  assignment has errored out  */
--                 hr_utility.raise_error;
              END IF;
              CLOSE c_arch_errored_asg;
              OPEN c_arch_retry_pending (l_payroll_action_id);
              FETCH c_arch_retry_pending INTO l_asg_retry_pend;
              IF c_arch_retry_pending%FOUND THEN
                 --Some of the assignments have been marked for retry
                 hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 80);
                 hr_utility.set_message(801, 'PAY_72730_ASG_MARKED_FOR_RETRY');
                 l_package_error_status := 'Y';
               --  hr_utility.raise_error;
              END IF;
              CLOSE c_arch_retry_pending;

               /* CHECK IF THERE IS NEED TO DO STATE TAX_RULES  CHECKING */
              IF  p_report_type = 'STW2' THEN
                    OPEN c_person_in_state(l_payroll_action_id ,
                                           l_user_entity_id   ,
                                           l_context_tax_unit_id  ,
                                           l_gre ,
                                           l_context_jursidiction );
                    FETCH   c_person_in_state into l_person_in_state;
                    hr_utility.trace( to_char(l_gre) || ' GRE-ID has atleast one person in the state ' || p_state_abbrev);
                    IF c_person_in_state%FOUND THEN
                            /* Check to set if state tax rules have been defined */

                           	OPEN c_chk_archive_state_code (l_gre,l_payroll_action_id);
                 	        FETCH c_chk_archive_state_code INTO l_state_tax_rules_exist;
         	      	        hr_utility.trace('GRE:' || TO_CHAR(l_gre));
     	      	            hr_utility.trace('payroll_action_id - '|| to_char(l_payroll_action_id));
                	        IF c_chk_archive_state_code%NOTFOUND THEN
                   	          --State Tax rules have not been defined
                             /* message to user -- State Tax rules not defined for the state ')  */
                              message_text := 'State Tax Rules not Defind for GRE ' || to_char(l_gre) || ' for ' || P_state_abbrev;
                                  insert  into pay_message_lines (
                                                                   line_sequence,
                                                                   payroll_id,
                                                                   message_level,
                                                                   source_id,
                                                                   source_type,
                                                                   line_text)
                                 values (pay_message_lines_s.nextval,
                                 NULL,
                                 'F',    -- it's a fatal message.
                                 p_pactid,
                                 'P',    -- payroll action level.
                                  message_text);
                                  commit;
                                  hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
                                  hr_utility.set_message_token('MESSAGE', message_text);
                                  l_package_error_status := 'Y';
                                  --hr_utility.raise_error;
                      	    END IF;
              	            CLOSE c_chk_archive_state_code;
                            CLOSE c_person_in_state;
                    ELSE
                            CLOSE c_person_in_state;
                    END IF; -- END OF C_person_in state not found if
              END IF; -- REPORT TYPE = STATE

               hr_utility.trace('GRE:' || TO_CHAR(l_gre));
	           hr_utility.trace('payroll_action_id - '|| to_char(l_payroll_action_id));
	           hr_utility.trace('No. of GREs picked so far - '|| to_char(l_no_of_gres_picked));
	           l_no_of_gres_picked := l_no_of_gres_picked + 1;
           ELSE
             /* The GRE has not been archived so check for valid Persons in the GRE
                who have been paid for the run YEAR

                Open Cursor as per your Report type to check if GRE needs to be archived
                or Not */
                IF p_report_type = 'FEDW2' THEN --federal W2
                    hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 99);
		            OPEN c_gre_fed(gre_rec.gre);
                ELSIF   p_report_type = 'STW2' THEN --state W2
 		            OPEN c_gre_state(gre_rec.gre);
                END IF;

                LOOP  --Main Loop
	            IF p_report_type = 'FEDW2' THEN
	               FETCH c_gre_fed INTO l_person
	                               ,l_assignment
 	                               ,l_asg_effective_dt;
	               hr_utility.set_location('pay_us_magw2_reporting.preprocess_check',20);
                   hr_utility.trace('GRE:' || TO_CHAR(l_gre));
                   hr_utility.trace('Assignment ID:' || TO_CHAR(l_assignment));
                   hr_utility.trace('Person ID:' || TO_CHAR(l_person));
                   hr_utility.trace('Effective Date:' || TO_CHAR(l_asg_effective_dt));
                   IF c_gre_fed%NOTFOUND THEN
                      EXIT;
                   END IF;
	            ELSIF p_report_type = 'STW2' THEN
	   	           FETCH c_gre_state INTO l_person
	                                   ,l_assignment
		                           ,l_asg_effective_dt;
		           hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 40);
                   hr_utility.trace('GRE:' || TO_CHAR(l_gre));
                   hr_utility.trace('Assignment ID:' || TO_CHAR(l_assignment));
                   hr_utility.trace('Person ID:' || TO_CHAR(l_person));
                   hr_utility.trace('Effective Date:' || TO_CHAR(l_asg_effective_dt));
                   IF c_gre_state%NOTFOUND THEN
                        EXIT;
                   END IF;
	            END IF; /* report type = 'STW2' and etc */
                    hr_utility.trace('pay_us_magw2_reporting.preprocess_check');
                    hr_utility.trace('GRE - '||to_char(l_gre));
                IF p_report_type = 'FEDW2' THEN
                   IF get_balance_value('GROSS_EARNINGS_PER_GRE_YTD',
                                        l_gre, p_state_abbrev, l_assignment,
                                        LEAST(p_year_end, l_asg_effective_dt)) > 0 THEN
                      l_balance_exists := 1;
                   END IF;
                ELSIF p_report_type = 'STW2' THEN
                   IF get_balance_value('GROSS_EARNINGS_PER_GRE_YTD',
                                        l_gre, p_state_abbrev, l_assignment,
                                        LEAST(p_year_end, l_asg_effective_dt)) > 0 AND
                        get_balance_value('SIT_GROSS_PER_JD_GRE_YTD',
                                          l_gre, p_state_abbrev, l_assignment,
                                          LEAST(p_year_end, l_asg_effective_dt)) > 0 THEN
                       l_balance_exists := 1;
                   END IF;
                END IF;
                if l_balance_exists = 1 then
                      --It means that no archived GRE was
		               --found for the Organization. This is an error.
                         if  p_report_type = 'FEDW2' THEN
                             close c_gre_fed;
                         else
                             close c_gre_state;
                         end if;
                         hr_utility.set_location(
                            'pay_us_magw2_reporting.preprocess_check', 12);
                         hr_utility.set_message(801, 'PAY_72728_ARCH_GRE_NOT_FOUND');
                         /* Check for state tax rules for the gre */
                         OPEN c_chk_archive_state_code (l_gre,l_payroll_action_id);
                	     FETCH c_chk_archive_state_code INTO l_state_tax_rules_exist;
         	      	     hr_utility.trace('GRE:' || TO_CHAR(l_gre));
     	      	         hr_utility.trace('payroll_action_id - '|| to_char(l_payroll_action_id));
                	     IF c_chk_archive_state_code%NOTFOUND THEN
                   	        --State Tax rules have not been defined
                            /* message to user -- State Tax rules not defined for the state ')  */
                              message_text := 'GRE_id ' || to_char(l_gre) || 'not archived- STR State ' || P_state_abbrev;
                            insert  into pay_message_lines (
                                                                   line_sequence,
                                                                   payroll_id,
                                                                   message_level,
                                                                   source_id,
                                                                   source_type,
                                                                   line_text)
                            values (pay_message_lines_s.nextval,
                                   NULL,
                                 'F',    -- it's a fatal message.
                                 p_pactid,
                                 'P',    -- payroll action level.
                                  message_text);
                             commit;
                             hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
                             hr_utility.set_message_token('MESSAGE', message_text);
                             l_package_error_status := 'Y';
                             hr_utility.raise_error;
                      	 END IF;
              	         CLOSE c_chk_archive_state_code;
                          --hr_utility.raise_error;
                   end if;  /* balance exists */
	                  l_no_of_gres_picked := l_no_of_gres_picked + 1;
                      l_balance_exists := 0;
                END LOOP;  --Main Loop
                      if  p_report_type = 'FEDW2' THEN
                          close c_gre_fed;
                      else
                          close c_gre_state;
                       end if;
           END IF;  --end if for checking of person balance if the GRE has
                    --not been archived.
           CLOSE c_gre_payroll_action;
	END LOOP;  /* end of for statement */

    IF l_package_error_status = 'Y' THEN
           message_text := 'Package error - Message lines have detail';
           hr_utility.set_message(801, 'HR_7998_ALL_EXEMACRO_MESSAGE');
           hr_utility.set_message_token('MESSAGE', message_text);
           hr_utility.raise_error;
     END IF;

	IF l_no_of_gres_picked = 0 THEN
           --It means that no archived GRE was
           --found for the Organization. This is an error.
           hr_utility.set_location('pay_us_magw2_reporting.preprocess_check', 110);
           hr_utility.set_message(801, 'PAY_72728_ARCH_GRE_NOT_FOUND');
           /* message to User --  No Gre Found for the archive */
             hr_utility.raise_error;
	END IF;
	       hr_utility.set_location( 'pay_us_magw2_reporting.preprocess_check', 120);
	RETURN TRUE;
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
	p_pactid	IN	       NUMBER,
	p_sqlstr	OUT	nocopy VARCHAR2
)
IS
	p_year_start			DATE;
	p_year_end				DATE;
	p_business_group_id		NUMBER;
	p_state_abbrev			VARCHAR2(3);
	p_state_code			VARCHAR2(2);
	p_report_type			VARCHAR2(30);
BEGIN
	hr_utility.set_location( 'pay_us_magw2_reporting.range_cursor', 10);
	get_report_parameters(
		p_pactid,
		p_year_start,
		p_year_end,
		p_state_abbrev,
		p_state_code,
		p_report_type,
		p_business_group_id
	);
	hr_utility.set_location( 'pay_us_magw2_reporting.range_cursor', 20);
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
				 FROM per_assignments_f paf,
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
			hr_utility.set_location( 'pay_us_magw2_reporting.range_cursor',
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
                                   per_assignments_f  paf,
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
			hr_utility.set_location( 'pay_us_magw2_reporting.range_cursor',
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
                  per_assignments_f  paf,
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
                 --hr_soft_coding_keyflex hsck,
	         per_assignments_f paf,
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
	  --AND hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
	  --AND hsck.segment1 = paa.tax_unit_id
	  --AND hsck.segment1 NOT IN (
	  AND not exists (
	 	SELECT 'x'
	 	FROM hr_organization_information hoi
	  	WHERE hoi.organization_id = paa.tax_unit_id
                  and hoi.org_information_context = '1099R Magnetic Report Rules')
        ORDER BY 1, 3, 4 DESC, 2
	FOR UPDATE OF paf.assignment_id;
        cursor csr_get_fed_wages(p_assignment_action_id number,
                                 p_tax_unit_id          number) is
        select to_number(fai.value)
        from ff_archive_item_contexts faic,
             ff_archive_items         fai,
             ff_contexts              fc,
             ff_database_items        fdi
        where fdi.user_name = 'A_GROSS_EARNINGS_PER_GRE_YTD'
        and   fc.context_name = 'TAX_UNIT_ID'
        and   fai.context1 = p_assignment_action_id
        and   fai.user_entity_id = fdi.user_entity_id
        and   faic.archive_item_id = fai.archive_item_id
        and   faic.context_id = fc.context_id
        and   faic.context = p_tax_unit_id
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
BEGIN
	-- Get the report parameters. These define the report being run.
	hr_utility.set_location( 'pay_us_magw2_reporting.create_assignement_act',
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
	hr_utility.set_location( 'pay_us_magw2_reporting.create_assignement_act',
		20);
	IF l_report_type = 'FEDW2' THEN
		OPEN c_federal;
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
				'pay_us_magw2_reporting.create_assignement_act', 30);
			EXIT WHEN c_federal%NOTFOUND;
		ELSIF l_report_type = 'STW2' THEN
			FETCH c_state INTO l_person_id,
			                   l_assignment_id,
			                   l_tax_unit_id,
			                   l_effective_end_date,
                                           l_assignment_action_id,
                                           l_w2_box17;
			hr_utility.set_location(
				'pay_us_magw2_reporting.create_assignement_act', 40);
			EXIT WHEN c_state%NOTFOUND;
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
				'pay_us_magw2_reporting.create_assignement_act', 50);
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
                     open csr_get_fed_wages(l_assignment_action_id, l_tax_unit_id);
                     fetch csr_get_fed_wages into l_value;
                     if csr_get_fed_wages%NOTFOUND then
                        l_value := 0;
                     end if;
                     close csr_get_fed_wages;
                   END IF;
                   IF (l_report_type = 'FEDW2' and l_value > 0) OR
                      (l_report_type = 'STW2') then
			SELECT pay_assignment_actions_s.nextval
			INTO lockingactid
			FROM dual;
			hr_utility.set_location(
				'pay_us_magw2_reporting.create_assignement_act', 60);
			hr_nonrun_asact.insact(lockingactid, l_assignment_id, p_pactid,
				p_chunk, l_tax_unit_id);
			hr_utility.set_location(
				'pay_us_magw2_reporting.create_assignement_act', 70);
			--update serial number for highly compensated people for the
			--state W2.
			IF l_report_type = 'STW2' THEN
				hr_utility.set_location(
					'pay_us_magw2_reporting.create_assignement_act', 80);
				IF l_w2_box17 > 9999999.99 THEN
					UPDATE pay_assignment_actions
					SET serial_number = 999999
					WHERE assignment_action_id = lockingactid;
				END IF;
			END IF;
			hr_nonrun_asact.insint(lockingactid, l_assignment_action_id);
			hr_utility.set_location(
				'pay_us_magw2_reporting.create_assignement_act', 90);
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
	ELSIF l_report_type = 'STW2' THEN
		CLOSE c_state;
	END IF;
END create_assignment_act;

--begin
-- hr_utility.trace_on(NULL, 'VIP');

END pay_us_magw2_reporting;

/
