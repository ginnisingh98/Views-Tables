--------------------------------------------------------
--  DDL for Package Body PAY_US_MMREF_LOCAL_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMREF_LOCAL_XML" AS
/*REM $Header: payusw2mmref1xml.pkb 120.0.12010000.3 2009/01/04 17:57:57 svannian ship $
REM +======================================================================+
REM |                Copyright (c) 1997 Oracle Corporation                 |
REM |                   Redwood Shores, California, USA                    |
REM |                        All rights reserved.                          |
REM +======================================================================+
REM Name
REM	   pay_us_mmref_local_xml
REM File
REM           payusw2mmref1xml.pkb
REM
REM  Purpose
REM
REM    The purpose of this package is to support the generation of XML for the process
REM    Local W-2 Generic MMREF-1. This package includes all the cursors, procedures and functions
REM    used to comply with the payroll CORE multi-thtread enhancement architecture.
REM
REM    Currently this is not meant for any specific locality magnetic tape.
REM
REM  Notes
REM    The generation of each magnetic tape report is a two stage process i.e.
REM    1.  Check if the year end pre-processor has been run for all the GREs. If not, then error
REM         out without processing further.
REM    2.  Create a payroll action for the report. Identify all the assignments to be reported and record
REM         an assignment action against the payroll action for each one of them.
REM    3.  Run the "Local W-2 Generic MMREF-1 XML" process to use this package.
REM
REM Change History
REM ============================================================================
REM 07-NOV-2006   PPANDA     115.0                        Initial Version Created
REM 02-JAN-2009   SVANNIAN   115.1                        Changed the action creation cursor to pick up Employees with SD Taxes.
REM ============================================================================
REM
*/
--
-- Global Variables
--
    g_proc_name     varchar2(240);
    g_debug         boolean;
    g_document_type varchar2(50);

  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages.
  *****************************************************************************/

  PROCEDURE HR_UTILITY_TRACE
  (
      P_TRC_DATA  varchar2
  ) AS
 BEGIN
    IF g_debug THEN
        hr_utility.trace(p_trc_data);
    END IF;
 END HR_UTILITY_TRACE;

/*
  -------------------------------------------------------------------------------------------------------
  --   Name       : bal_db_item
  --   Purpose    : Given the name of a balance DB item as would be seen in a
  --                     fast formula it returns the defined_balance_id of the balance it represents.
  --   Arguments
  --       INPUT:			p_db_item_name
  --       RETURNS :		l_defined_balance_id
  --   Notes
  --                A defined_balance_id is required by the PLSQL balance function.
  --------------------------------------------------------------------------------------------------------
*/
FUNCTION bal_db_item       (
                                                p_db_item_name VARCHAR2
                                              ) RETURN NUMBER IS
	-- Get the defined_balance_id for the specified balance DB item.
	CURSOR csr_defined_balance IS
	  SELECT TO_NUMBER(UE.creator_id)
	    FROM ff_database_items DI,
	               ff_user_entities UE
	   WHERE DI.user_name			= p_db_item_name
	        AND UE.user_entity_id		= DI.user_entity_id
	        AND UE.creator_type		= 'B'
                AND UE.legislation_code		= 'US';

	l_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;
BEGIN
	hr_utility.set_location
	           ('pay_us_mmref_local_xml.bal_db_item - opening cursor', 10);
        -- Open the cursor
	OPEN csr_defined_balance;
        -- Fetch the value
	FETCH  csr_defined_balance
           INTO  l_defined_balance_id;
 	IF csr_defined_balance%NOTFOUND THEN
		CLOSE csr_defined_balance;
		hr_utility.set_location
		('pay_us_mmref_local_xml.bal_db_item - no rows found from cursor', 20);
		hr_utility.raise_error;
	ELSE
		hr_utility.set_location
		('pay_us_mmref_local_xml.bal_db_item - fetched from cursor', 30);
		CLOSE csr_defined_balance;
	END IF;
        -- Return the value to the call
	RETURN (l_defined_balance_id);
END bal_db_item;

 -----------------------------------------------------------------------------
   -- Name:       get_report_parameters
   -- Purpose
   --                 The procedure gets the 'parameter' for which the report is being
   --                  run i.e., the period, state and business organization.
   -- Arguments
   --   p_year_start		Start Date of the period for which the report
   --					has been requested
   --   p_year_end		End date of the period
   --   p_business_group_id	Business group for which the report is being run
   --   p_state_abbrev		Two digit state abbreviation (or 'FED' for federal
   --					report)
   --   p_state_code		State code (NULL for federal)
   --   p_report_type		W2_LOCAL_XML
   --
   --   p_locality_code		This parameter will have the jurisdiction
   --
   -- Notes
 ----------------------------------------------------------------------------
        PROCEDURE get_report_parameters
	(	p_pactid    			IN		NUMBER,
		p_year_start			IN OUT	NOCOPY DATE,
		p_year_end			IN OUT	NOCOPY DATE,
		p_state_abbrev			IN OUT	NOCOPY VARCHAR2,
		p_state_code			IN OUT	NOCOPY VARCHAR2,
		p_report_type			IN OUT	NOCOPY VARCHAR2,
		p_business_group_id	IN OUT	NOCOPY NUMBER,
		p_locality_code         IN OUT	NOCOPY VARCHAR2
	) IS
		l_state_code				varchar2(200);
	BEGIN
		hr_utility.set_location
				('pay_us_mmref_local_xml.get_report_parameters', 10);
		hr_utility.trace('Payroll_Action_Id '|| to_char(p_pactid));
		SELECT  ppa.start_date,
		   	        ppa.effective_date,
		  	        ppa.business_group_id,
				 pay_us_get_item_data_pkg.GET_CPROG_PARAMETER_VALUE(ppa.payroll_action_id,
																	'TRANSFER_STATE'),
		  	        ppa.report_type,
                                pay_us_get_item_data_pkg.GET_CPROG_PARAMETER_VALUE(ppa.payroll_action_id,
																	'LC')
		  INTO  p_year_start,
                             p_year_end,
			     p_business_group_id,
			     p_state_abbrev,
			     p_report_type,
                             p_locality_code
                 FROM  pay_payroll_actions	ppa
	       WHERE  ppa.payroll_action_id =  p_pactid;
	       --
                select state_code into l_state_code
		 from pay_us_states pus
		where pus.state_abbrev = p_state_abbrev;

		p_state_code := l_state_code;

	       /*
		if p_locality_code = 'NULL' then
		   p_locality_code := l_state_code||'000-0000';
		end if;
                */
		hr_utility.set_location('pay_us_mmref_local_xml.get_report_parameters', 15);
		hr_utility.trace('Parameter Values ');
		hr_utility.trace('Year Start			'|| to_char(p_year_start,'dd-mon-yyyy'));
		hr_utility.trace('Year End			'|| to_char(p_year_end,'dd-mon-yyyy'));
		hr_utility.trace('Business Group Id	'|| to_char(p_business_group_id));
		hr_utility.trace('p_state_abbrev		'|| p_state_abbrev);
		hr_utility.trace('p_state_code		'|| p_state_code);
		hr_utility.trace('p_report_type		'|| p_report_type);
		hr_utility.trace('p_locality_code		'|| p_locality_code);
		hr_utility.set_location
                              ('pay_us_mmref_local_xml.get_report_parameters', 40);
        EXCEPTION
	WHEN OTHERS THEN
		hr_utility.trace('get_report_parameters procedure Raised Exception  ');
		hr_utility.trace('ERROR '||substr(SQLERRM,1,40));
		hr_utility.trace(substr(SQLERRM,41,90));
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
        --					        retrieved
        --  p_effective_date			effective_date
        --Note
        --  This procedure set is a wrapper for setting the GRE/Jurisdiction context
        --  needed by the pay_balance_pkg.get_value to get the actual balance
        -------------------------------------------------------------------------
	FUNCTION get_balance_value (
		            p_balance_name	VARCHAR2,
		            p_tax_unit_id	NUMBER,
		            p_state_abbrev	VARCHAR2,
		            p_assignment_id	NUMBER,
		            p_effective_date	DATE
	) RETURN NUMBER IS
		l_jurisdiction_code		VARCHAR2(20);
	BEGIN
	  hr_utility.set_location
		('pay_us_mmref_local_xml.get_balance_value', 10);
	  pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
	  IF p_state_abbrev <> 'FED' THEN
			SELECT jurisdiction_code
			    INTO l_jurisdiction_code
			  FROM pay_state_rules
		       WHERE state_code = p_state_abbrev;
     			hr_utility.set_location
			              ('pay_us_mmref_local_xml.get_balance_value', 15);
			pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction_code);
	  END IF;
	  hr_utility.trace(p_balance_name);
	  hr_utility.trace('Context');
	  hr_utility.trace('Tax Unit Id:	'|| p_tax_unit_id);
	  hr_utility.trace('Jurisdiction:	'|| l_jurisdiction_code);
	  hr_utility.set_location
	                      ('pay_us_mmref_local_xml.get_balance_value', 20);
	  RETURN pay_balance_pkg.get_value(bal_db_item(p_balance_name),
			                                            p_assignment_id,
								    p_effective_date);
	END get_balance_value;

  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed for process
                        Local YearEnd Interface Extract. This procedure defines a SQL statement
                        to fetch all the people to be included in the generic XML extract. This SQL
			statement is  used to define the 'chunks' for multi-threaded operation
  Arguments
      p_pactid	payroll action id for the report
      p_sqlstr	the SQL statement to fetch the people
  *****************************************************************************/

PROCEDURE range_cursor ( 	p_pactid	IN	NUMBER,
                                                p_sqlstr	OUT	nocopy VARCHAR2
                                            )
IS
	p_year_start			DATE;
	p_year_end			DATE;
	p_business_group_id		NUMBER;
	p_state_abbrev			VARCHAR2(200);
	p_state_code			VARCHAR2(200);
	p_report_type			VARCHAR2(200);
        p_locality_code                 VARCHAR2(200);
BEGIN
       -- hr_utility.trace_on(null,'LOCALXML');
	hr_utility.set_location( 'pay_us_mmref_local_xml.range_cursor', 10);

	get_report_parameters( p_pactid,
		                            p_year_start,
		                            p_year_end,
		                            p_state_abbrev,
		                            p_state_code,
		                            p_report_type,
		                            p_business_group_id,
                                            p_locality_code
	);
	hr_utility.set_location( 'pay_us_mmref_local_xml.range_cursor', 20);


	IF p_report_type = 'W2_MAG_XML' THEN
			p_sqlstr := '
                            SELECT DISTINCT
                                           to_number(paa.serial_number)
                              FROM ff_archive_item_contexts faic,
                                         ff_archive_items fai,
                                         ff_database_items fdi,
                                         pay_assignment_actions paa,
                                         pay_payroll_actions ppa,
                                         per_all_assignments_f  paf,
                                         pay_payroll_actions ppa1,
					 pay_us_states         pus
                             WHERE  ppa1.payroll_action_id		= :payroll_action_id
			           AND ppa.business_group_id+0	= ppa1.business_group_id
                                   AND ppa1.effective_date		= ppa.effective_date
                                   AND ppa.report_type			= ''YREND''
                                   AND ppa.payroll_action_id		= paa.payroll_action_id
                                   AND paf.assignment_id			= paa.assignment_id
                                   AND paf.assignment_type		= ''E''
                                   AND fdi.user_name			= ''A_STATE_ABBREV''
                                   AND fdi.user_entity_id			= fai.user_entity_id
                                   AND fai.archive_item_id		= faic.archive_item_id
                                   AND fai.context1				= paa.assignment_action_id
				   AND pus.STATE_ABBREV		= pay_us_get_item_data_pkg.GET_CPROG_PARAMETER_VALUE(ppa1.payroll_action_id,
																			''TRANSFER_STATE'')
                                   AND fai.value				= pus.STATE_ABBREV
                                   AND paf.effective_start_date		<= ppa.effective_date
                                   AND paf.effective_end_date		>= ppa.start_date
                                   AND paa.action_status			= ''C''
                                   AND nvl(hr_us_w2_rep.get_w2_arch_bal( paa.assignment_action_id,
                                                                                                  ''A_W2_STATE_WAGES'',
                                                                                                   paa.tax_unit_id,
                                                                                                   faic.context , 2), 0) > 0
				   AND EXISTS ( /*+ INDEX(pustif PAY_US_STATE_TAX_INFO_F_N1) */
                                                       SELECT ''x''
                                                          FROM pay_us_state_tax_info_f pustif
                                                       WHERE substr(faic.context,1,2) = pustif.state_code
                                                             AND ppa.effective_date between pustif.effective_start_date
                                                             AND pustif.effective_end_date
                                                             AND pustif.sit_exists = ''Y'')
                                  AND NOT EXISTS (
                                                      SELECT ''x''
                                                         FROM hr_organization_information hoi
                                                      WHERE hoi.organization_id = paa.tax_unit_id
                                                           AND hoi.org_information_context = ''1099R Magnetic Report Rules''
                                                               )
                             ORDER BY to_number(paa.serial_number)';
			     hr_utility.set_location( 'pay_us_mmref_local_xml.range_cursor',	40);
	END IF;
        hr_utility.trace( substr(p_sqlstr,1,	50));
        hr_utility.set_location( 'pay_us_mmref_local_xml.range_cursor',	50);
END range_cursor;
--

/****************************************************************************
    Name         : CREATE_ASSIGNMENT_ACT
    Description : This procedure creates assignment actions for the payroll action associated
                        process <Local YearEnd Interface Extract>

                        The procedure processes assignments in 'chunks' to facilitate  multi-threaded
			operation. The chunk is defined by the size and the starting and ending person id.
			An interlock is also created against the year-end pre-processor assignment action
			to prevent rolling back of the archiver.

 *****************************************************************************/

PROCEDURE create_assignment_act(
								p_pactid 	IN NUMBER,
								p_stperson 	IN NUMBER,
								p_endperson IN NUMBER,
								p_chunk 	IN NUMBER
							  )
IS
	-- Cursor to get the assignments for Local YearEnd Interface Extract. Gets only those employees
	-- which have wages for the specified state.This cursor excludes the 1099R GREs.
	--
          CURSOR c_local (	c_state_code    VARCHAR2,
					c_locality_code VARCHAR2)
          IS
          SELECT
                  to_number(paa.serial_number),
                  paf.assignment_id,
                  paa.tax_unit_id,
                  paf.effective_end_date,
                  paa.assignment_action_id,
                  sum(fai1.value)
            FROM
                  pay_assignment_actions		paa,	  -- YREND PAA
                  pay_payroll_actions		ppa,	  -- YREND PPA
                  per_all_assignments_f		paf,
                  pay_payroll_actions			ppa1,
                  ff_contexts				fc1 ,   --for city context
                  ff_archive_items			fai1,   -- city
                  ff_archive_item_contexts		faic1, -- city_context
                  ff_database_items			fdi1    --database_items for City_withheld
                  --,pay_us_city_tax_info_f	puctif
            WHERE   ppa1.payroll_action_id		= p_pactid
                 AND   ppa.business_group_id+0	= ppa1.business_group_id
                 AND   ppa1.effective_date		= ppa.effective_date
                 AND   ppa.report_type			= 'YREND'
                 AND   ppa.payroll_action_id		= paa.payroll_action_id
                 AND   paf.assignment_id			= paa.assignment_id
                 AND   paf.assignment_type		= 'E'
                 AND   fc1.context_name			= 'JURISDICTION_CODE'
                 AND   faic1.context_id			= fc1.context_id
                 AND   fdi1.user_name			= 'A_CITY_WITHHELD_PER_JD_GRE_YTD'
                 AND   fdi1.user_entity_id		= fai1.user_entity_id
                 AND   fai1.context1			= paa.assignment_action_id
                 AND   fai1.archive_item_id		= faic1.archive_item_id
		 AND   ltrim(rtrim(faic1.context))	like c_state_code||'%'
                 AND   (c_locality_code IS NULL OR
		              ( c_locality_code IS NOT NULL
			        AND EXISTS ( SELECT 'x' from pay_us_city_tax_info_f puctif
                                                         WHERE substr(puctif.jurisdiction_code,1,2)||'-000-'||
					                            substr(puctif.jurisdiction_code,8,4)
					                             =    substr(ltrim(rtrim(faic1.context)),1,2)||'-000-'||
									   substr(ltrim(rtrim(faic1.context)),8,4)
                                                           AND  puctif.jurisdiction_code	like substr(c_locality_code,1,2)||'%'||
					                                                                      substr(c_locality_code,8,4)||'%'
                                                           AND puctif.effective_start_date	<    ppa.effective_date
					                   AND puctif.effective_end_date	>=   ppa.effective_date
                                                        )
                                )
                              )
		 AND paf.effective_start_date	<= ppa.effective_date
                 AND paf.effective_end_date	>= ppa.start_date
                 AND paa.action_status		= 'C'
                 AND paa.serial_number		BETWEEN p_stperson AND p_endperson
                 AND paf.person_id			BETWEEN p_stperson AND p_endperson
                 AND NOT EXISTS
                          (
                            SELECT  'x'
                               FROM  hr_organization_information hoi
                            WHERE  hoi.organization_id			=  paa.tax_unit_id
                                  AND hoi.org_information_context	= '1099R Magnetic Report Rules'
                           )
                 AND rtrim(ltrim(fai1.value))  <> '0'
		 GROUP BY paa.serial_number,
                                     paf.assignment_id,
                                     paa.tax_unit_id,
                                     paf.effective_end_date,
                                     paa.assignment_action_id
   union all
               SELECT
                  to_number(paa.serial_number),
                  paf.assignment_id,
                  paa.tax_unit_id,
                  paf.effective_end_date,
                  paa.assignment_action_id,
                  sum(fai1.value)
            FROM
                  pay_assignment_actions		paa,	  -- YREND PAA
                  pay_payroll_actions		ppa,	  -- YREND PPA
                  per_all_assignments_f		paf,
                  pay_payroll_actions			ppa1,
                  ff_contexts				fc1 ,   --for city context
                  ff_archive_items			fai1,   -- city
                  ff_archive_item_contexts		faic1, -- city_context
                  ff_database_items			fdi1

            WHERE   ppa1.payroll_action_id		= p_pactid
                 AND   ppa.business_group_id+0	= ppa1.business_group_id
                 AND   ppa1.effective_date		= ppa.effective_date
                 AND   ppa.report_type			= 'YREND'
                 AND   ppa.payroll_action_id		= paa.payroll_action_id
                 AND   paf.assignment_id			= paa.assignment_id
                 AND   paf.assignment_type		= 'E'
                 AND   fc1.context_name			= 'JURISDICTION_CODE'
                 AND   faic1.context_id			= fc1.context_id
                 AND   fdi1.user_name			= 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'
                 AND   fdi1.user_entity_id		= fai1.user_entity_id
                 AND   fai1.context1			= paa.assignment_action_id
                 AND   fai1.archive_item_id		= faic1.archive_item_id
		 AND   ltrim(rtrim(faic1.context))	like c_state_code||'%'
                 AND   (c_locality_code IS NULL OR
		              ( c_locality_code IS NOT NULL
			        AND EXISTS ( SELECT 'x' from PAY_US_CITY_SCHOOL_DSTS puctif
                                                WHERE
                                                puctif.state_code = c_state_code
                                                and puctif.state_code ||'-'||
					                            puctif.county_code || '-'|| puctif.city_code = c_locality_code
					                            and c_state_code || '-'|| puctif.school_dst_code = ltrim(rtrim(faic1.context))

                                                 )
                                )
                              )
		 AND paf.effective_start_date	<= ppa.effective_date
                 AND paf.effective_end_date	>= ppa.start_date
                 AND paa.action_status		= 'C'
                 AND paa.serial_number		BETWEEN p_stperson AND p_endperson
                 AND paf.person_id			BETWEEN p_stperson AND p_endperson
                 AND NOT EXISTS
                          (
                            SELECT  'x'
                               FROM  hr_organization_information hoi
                            WHERE  hoi.organization_id			=  paa.tax_unit_id
                                  AND hoi.org_information_context	= '1099R Magnetic Report Rules'
                           )
                 AND rtrim(ltrim(fai1.value))  <> '0'
		 GROUP BY paa.serial_number,
                                     paf.assignment_id,
                                     paa.tax_unit_id,
                                     paf.effective_end_date,
                                     paa.assignment_action_id
                 ORDER BY 1, 3, 4 DESC, 2;
        --
	--	LOCAL VARIABLES
	--
	l_year_start			DATE;
	l_year_end			DATE;
	l_effective_end_date		DATE;
	l_state_abbrev 			VARCHAR2(3);
	l_state_code 			VARCHAR2(2);
	l_report_type			VARCHAR2(30);
	l_business_group_id		NUMBER;
	l_person_id			NUMBER;
	l_prev_person_id		NUMBER;
	l_assignment_id			NUMBER;
	l_assignment_action_id	NUMBER;
	l_value				NUMBER;
	l_tax_unit_id			NUMBER;
	l_prev_tax_unit_id		NUMBER;
	lockingactid			NUMBER;
	l_group_by_gre			BOOLEAN;
	l_w2_box17 			NUMBER;		--City or Locality Wages
        l_gre_id				NUMBER;
        l_error_flag			VARCHAR2(10);
        l_locality_code			VARCHAR2(200);
--
BEGIN
	-- Set the local variable to correct Value
        l_gre_id := -1;
        l_error_flag := 'N';

	-- Get the report parameters. These define the report being run.
	hr_utility.set_location( 'pay_us_mmref_local_xml.create_assignement_act', 10);
	get_report_parameters(	p_pactid,
						l_year_start,
						l_year_end,
						l_state_abbrev,
						l_state_code,
						l_report_type,
						l_business_group_id,
				                l_locality_code
					);
	IF l_locality_code = 'NULL' THEN
		l_locality_code := NULL;
	END IF;

	--Currently all reports group by GRE
	l_group_by_gre := TRUE;
	--Open the appropriate cursor
	hr_utility.set_location( 'pay_us_mmref_local_xml.create_assignement_act',	20);
	hr_utility.trace('LOCALITY_CODE  : '|| l_locality_code);
	IF l_report_type = 'W2_MAG_XML' THEN
		OPEN c_local(l_state_code,
                                       l_locality_code);
	END IF;
	LOOP
		FETCH c_local  INTO	l_person_id,
							l_assignment_id,
							l_tax_unit_id,
							l_effective_end_date,
							l_assignment_action_id,
							l_w2_box17;
		hr_utility.set_location(
				'pay_us_mmref_local_xml.create_assignement_act', 40);
		EXIT WHEN c_local%NOTFOUND;
		--Based on the groupin criteria, check if the record is the same
		--as the previous record.
		--Grouping by GRE requires a unique person/GRE combination for
		--each record.
		IF ( (l_group_by_gre AND
			l_person_id   = l_prev_person_id AND
			l_tax_unit_id = l_prev_tax_unit_id
		       )
		      OR
			( NOT l_group_by_gre AND
			  l_person_id   = l_prev_person_id
			)
	 	    ) THEN
		    --{
			--Do Nothing
			hr_utility.set_location(
				'pay_us_mmref_local_xml.create_assignement_act', 50);
			NULL;
		    --}
		ELSE
		--{
  			--Create the assignment action for the record
			hr_utility.trace('Assignment Fetched  - ');
			hr_utility.trace('Assignment Id		: '|| to_char(l_assignment_id));
			hr_utility.trace('Person Id			: '|| to_char(l_person_id));
			hr_utility.trace('tax unit id			: '|| to_char(l_tax_unit_id));
			hr_utility.trace('Effective End Date	: '|| to_char(l_effective_end_date));
			IF  (l_report_type = 'W2_MAG_XML') then
				SELECT pay_assignment_actions_s.nextval
				    INTO lockingactid
				   FROM dual;
				hr_utility.set_location(
					'pay_us_mmref_local_xml.create_assignement_act', 60);
				hr_nonrun_asact.insact(	lockingactid,
									l_assignment_id,
									p_pactid,
									p_chunk,
									l_tax_unit_id);
				hr_utility.set_location(
					'pay_us_mmref_local_xml.create_assignement_act', 70);
				hr_nonrun_asact.insint(lockingactid,
							          l_assignment_action_id);
				hr_utility.set_location(
					'pay_us_mmref_local_xml.create_assignement_act', 80);
				hr_utility.trace('Interlock Created  - ');
				hr_utility.trace('Locking Action : '|| to_char(lockingactid));
				hr_utility.trace('Locked Action :  '|| to_char(l_assignment_action_id));
				--Store the current person/GRE for comparision during the
				--next iteration.
				l_prev_person_id 	:= l_person_id;
				l_prev_tax_unit_id 	:= l_tax_unit_id;
			END IF;
                  ENd IF;
	END LOOP;
        IF l_report_type = 'W2_MAG_XML' THEN
		CLOSE c_local;
	END IF;

        IF l_error_flag = 'Y' THEN
              hr_utility.trace('Error Flag was set to Y');
              hr_utility.raise_error;
        END IF;

END create_assignment_act;
--
-- Follwing Procedure is used for Submitter Record
--
PROCEDURE transmitter_record_start IS
	l_final_xml_string		VARCHAR2(32000);
       EOL					VARCHAR2(10);
	p_payroll_action_id 		NUMBER;
	p_tax_unit_id			NUMBER;
	p_jurisdiction_code		VARCHAR2(200);
	p_state_code			NUMBER;
	p_state_abbreviation		VARCHAR2(200);
	p_locality_code			VARCHAR2(200);
	status				VARCHAR2(200);
	p_date_earned			DATE;
	p_reporting_year		VARCHAR2(200);
        p_final_xml_string		VARCHAR2(32767);
BEGIN
--{
        -- Fetch All parameters value set by Transmitter Cursor and Conc. Program
	p_tax_unit_id		:= pay_magtape_generic.get_parameter_value('TR_TAX_UNIT_ID');
	p_payroll_action_id	:= pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
	p_date_earned	:= pay_magtape_generic.get_parameter_value('TR_DATE_EARNED');
        p_reporting_year	:= pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR');
       --
       -- Following Procedure Call will form the RA Record Structure in XML format
       --
       pay_us_w2_generic_extract.populate_arch_transmitter(
							 p_payroll_action_id
							,p_tax_unit_id
							,p_date_earned
							,p_reporting_year
							,p_jurisdiction_code
							,p_state_code
							,p_state_abbreviation
							,p_locality_code
							,status
							,p_final_xml_string);
	HR_UTILITY_TRACE('end_of_file l_final_xml_string = '
                                                 || p_final_xml_string);
	WRITE_TO_MAGTAPE_LOB(p_final_xml_string);
--}
END transmitter_record_start;

PROCEDURE transmitter_record_end is
     l_final_xml				CLOB;
     l_final_xml_string			VARCHAR2(32000);
     l_is_temp_final_xml		VARCHAR2(2);

  BEGIN
	l_final_xml_string := '</TRANSMITTER>';
	HR_UTILITY_TRACE('end_of_file l_final_xml_string = '
                                                 || l_final_xml_string);
	WRITE_TO_MAGTAPE_LOB(l_final_xml_string);
--	pay_core_files.write_to_magtape_lob(l_final_xml_string);
  END;

--
-- Follwing Procedure is used for Employer Record
--
PROCEDURE local_w2_xml_employer_start
IS
	l_final_xml_string		VARCHAR2(32000);
        EOL					VARCHAR2(10);
	p_payroll_action_id 		NUMBER;
	p_tax_unit_id			NUMBER;
	p_jurisdiction_code		VARCHAR2(200);
	p_state_code			NUMBER;
	p_state_abbreviation		VARCHAR2(200);
	p_locality_code			VARCHAR2(200);
	status				VARCHAR2(200);
	p_date_earned			DATE;
	p_reporting_year		VARCHAR2(200);
        p_final_xml_string		VARCHAR2(32767);
BEGIN
--{
        -- Fetch All parameters value set by Transmitter Cursor and Conc. Program
	p_tax_unit_id		:= pay_magtape_generic.get_parameter_value('TR_TAX_UNIT_ID');
	p_payroll_action_id	:= pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
	p_date_earned		:= pay_magtape_generic.get_parameter_value('TR_DATE_EARNED');
        p_reporting_year	:= pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR');
       --
       -- Following Procedure Call will form the RE Record Structure in XML format
       --
       pay_us_w2_generic_extract.populate_arch_employer(
							 p_payroll_action_id
							,p_tax_unit_id
							,p_date_earned
							,p_reporting_year
							,p_jurisdiction_code
							,p_state_code
							,p_state_abbreviation
							,p_locality_code
							,status
							,p_final_xml_string);
	HR_UTILITY_TRACE('end_of_file l_final_xml_string = '
                                                 || p_final_xml_string);
	WRITE_TO_MAGTAPE_LOB(p_final_xml_string);
--}
END local_w2_xml_employer_start;

PROCEDURE local_w2_xml_employer_end is
     l_final_xml				CLOB;
     l_final_xml_string			VARCHAR2(32000);
     l_is_temp_final_xml		VARCHAR2(2);

  BEGIN
	l_final_xml_string := '</EMPLOYER>';
	HR_UTILITY_TRACE('end_of_file l_final_xml_string = '
                                                 || l_final_xml_string);
	WRITE_TO_MAGTAPE_LOB(l_final_xml_string);
--	pay_core_files.write_to_magtape_lob(l_final_xml_string);
  END  local_w2_xml_employer_end;

--
-- Follwing Procedure is used for Employer Record
--
PROCEDURE local_w2_xml_employee_build
IS
	l_final_xml_string			VARCHAR2(32000);
        EOL						VARCHAR2(10);
	p_payroll_action_id 			NUMBER;
	p_ye_assignment_action_id	NUMBER;
	p_assignment_action_id		NUMBER;
	p_assignment_id			NUMBER;
	p_tax_unit_id				NUMBER;
	p_jurisdiction_code			VARCHAR2(200);
	p_state_code				NUMBER;
	p_state_abbreviation			VARCHAR2(200);
	p_locality_code			VARCHAR2(200);
	status					VARCHAR2(200);
	p_date_earned				DATE;
	p_reporting_year			VARCHAR2(200);
        p_final_xml_string			VARCHAR2(32767);

	CURSOR c_get_params IS
         SELECT paa1.assignment_action_id,	-- archiver asg action Id
	                paa1.tax_unit_id,			-- archiver Tax Unit Id
			paa1.payroll_action_id,		-- archiver payroll action id
			ppa.payroll_action_id,		-- Main Payroll Action Id
			paa.assignment_action_id,	 	-- Main Asg Action Id
			paa.assignment_id,
			ppa.effective_date,			-- Date Earned
			pay_us_mmref_local_xml.get_parameter('TRANSFER_REPORTING_YEAR',
			                                                                 ppa.legislative_parameters),
			pay_us_mmref_local_xml.get_parameter('LC',ppa.legislative_parameters),
			pay_us_mmref_local_xml.get_parameter('TRANSFER_STATE',ppa.legislative_parameters)
         FROM pay_assignment_actions	paa,
		     pay_payroll_actions		ppa,
		     pay_action_interlocks		pai,
		     pay_assignment_actions	paa1,
		     pay_payroll_actions		ppa1
         where ppa.payroll_action_id	 = paa.payroll_action_id
         and ppa.payroll_action_id	 = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
         and paa.assignment_action_id	 = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
         and pai.locking_action_id		 = paa.assignment_action_id
	 and pai.locked_action_id          = paa1.assignment_action_id
         and paa1.payroll_action_id	 = ppa1.payroll_action_id
         and ppa1.report_type		 = 'YREND'
         and ppa1.action_type		 = 'X'
         and ppa1.action_status		 = 'C'
         and ppa1.effective_date		 = ppa.effective_date;

	l_year_start			DATE;
	l_year_end			DATE;
	l_business_group_id		NUMBER;
	l_state_abbrev			VARCHAR2(200);
	l_state_code			VARCHAR2(200);
	l_report_type			VARCHAR2(200);
        l_locality_code                 VARCHAR2(200);
	l_main_payroll_action_id	NUMBER;
BEGIN
--{
        -- Fetch All parameters value set by Transmitter Cursor and Conc. Program
	 HR_UTILITY_TRACE('Constructing XML for Employee ->');
         HR_UTILITY_TRACE('EE ASGN ID  :'||to_char(pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')));
         OPEN c_get_params;
         FETCH c_get_params INTO p_ye_assignment_action_id,
							p_tax_unit_id,
							p_payroll_action_id,
							l_main_payroll_action_id,
							p_assignment_action_id,
							p_assignment_id,
							p_date_earned,
							p_reporting_year,
							p_locality_code,
							p_state_abbreviation;
         CLOSE c_get_params;
/*
	p_tax_unit_id		      := pay_magtape_generic.get_parameter_value('YE_TAX_UNIT_ID');
	p_payroll_action_id	      := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
	p_assignment_action_id  :=
						pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');
	p_ye_assignment_action_id :=
						pay_magtape_generic.get_parameter_value('YE_ASSIGNMENT_ACTION_ID');
	p_assignment_id	 := pay_magtape_generic.get_parameter_value('EE_ASSIGNMENT_ID');
	p_date_earned		 := pay_magtape_generic.get_parameter_value('EE_DATE_EARNED');
        p_reporting_year	 := pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR');
	p_locality_code       := pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE');
	p_jurisdiction_code := pay_magtape_generic.get_parameter_value('EE_LOCALITY_JD_CODE');
*/
	HR_UTILITY_TRACE('Prameter Used for Employee level XML');
        HR_UTILITY_TRACE('p_tax_unit_id YE			:'||to_char(p_tax_unit_id));
        HR_UTILITY_TRACE('p_payroll_action_id YE		:'||to_char(p_payroll_action_id));
	HR_UTILITY_TRACE('p_payroll_action_id			:'||to_char(l_main_payroll_action_id));
        HR_UTILITY_TRACE('p_ye_assignment_action_id	:'||to_char(p_ye_assignment_action_id));
        HR_UTILITY_TRACE('p_assignment_action_id		:'||to_char(p_assignment_action_id));
        HR_UTILITY_TRACE('p_assignment_id				:'||to_char(p_assignment_id));
        HR_UTILITY_TRACE('p_date_earned				:'||to_char(p_date_earned,'DD-MON-YYYY'));
        HR_UTILITY_TRACE('p_reporting_year			:'||p_reporting_year);
        HR_UTILITY_TRACE('p_locality_code				:'||p_locality_code);
--        HR_UTILITY_TRACE('p_jurisdiction_code			:'||p_jurisdiction_code);

	get_report_parameters( l_main_payroll_action_id,
		                            l_year_start,
		                            l_year_end,
		                            l_state_abbrev,
		                            l_state_code,
		                            l_report_type,
		                            l_business_group_id,
                                            l_locality_code
	);

        HR_UTILITY_TRACE('Year Start 			:'||to_char(l_year_start,'dd-mon-yyyy'));
        HR_UTILITY_TRACE('Year End			:'||to_char(l_year_end,'dd-mon-yyyy'));
	HR_UTILITY_TRACE('State Abbreviation	:'||l_state_abbrev);
        HR_UTILITY_TRACE('State Code			:'||l_state_code);
        HR_UTILITY_TRACE('Report Type		:'||l_report_type);
        HR_UTILITY_TRACE('Locality Code		:'||l_locality_code);

       --
       -- Following Procedure Call will form the RE Record Structure in XML format
       --
       pay_us_w2_generic_extract.populate_arch_employee(
							 p_payroll_action_id
							,p_ye_assignment_action_id
							,p_tax_unit_id
							,p_assignment_id
							,p_date_earned
							,p_reporting_year
							,p_jurisdiction_code
							,l_state_code
							,l_state_abbrev
							,l_locality_code
							,status
							,p_final_xml_string
							);

	--HR_UTILITY_TRACE('end_of_file p_final_xml_string = '
        --                                         || p_final_xml_string);
	WRITE_TO_MAGTAPE_LOB(p_final_xml_string);
--}
EXCEPTION
WHEN OTHERS THEN
	HR_UTILITY_TRACE('Error Encountered in local_w2_xml_employee_build');
	HR_UTILITY_TRACE(sqlerrm);
END local_w2_xml_employee_build;

  /****************************************************************************
    Name        : PRINT_BLOB
    Description : This procedure prints contents of BLOB passed as parameter.
  *****************************************************************************/

  PROCEDURE PRINT_BLOB(p_blob BLOB) IS
  BEGIN
    IF g_debug THEN
        pay_ac_utility.print_lob(p_blob);
    END IF;
  END PRINT_BLOB;


  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed BLOB parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE WRITE_TO_MAGTAPE_LOB(p_blob BLOB) IS
  BEGIN
    IF  dbms_lob.getLength (p_blob) IS NOT NULL THEN
        pay_core_files.write_to_magtape_lob (p_blob);
    END IF;
  END WRITE_TO_MAGTAPE_LOB;


  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed varchar2 parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE WRITE_TO_MAGTAPE_LOB(p_data varchar2) IS
  BEGIN
        pay_core_files.write_to_magtape_lob (p_data);
  END WRITE_TO_MAGTAPE_LOB;


------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
				  parameter_list varchar2) return varchar2
is
	start_ptr number;
	end_ptr   number;
	token_val pay_payroll_actions.legislative_parameters%type;
	par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;
 PROCEDURE local_non_pa_emp_data(p_pactid IN varchar2 ,
                        p_assignment_id in varchar2 ,
                        on_visa in out nocopy varchar2 ,
                        non_pa_res in out nocopy varchar2 ,
                        p_reporting_year in varchar2) IS

  l_year number ;
  p_person_id number ;
  l_non_pa_res varchar2(5);
  l_on_visa varchar2(5);
 -- l_year_start := '01-JAN-' ||p_reporting_year ;
 -- l_year_end := '31-DEC-' || p_reporting_year ;

  cursor c_get_person_id (p_assignment_id in number) is
  select person_id from per_all_assignments_f
  where assignment_id = p_assignment_id ;

  cursor c_get_non_pa_emp_det( p_person_id in number ) is
  select 'Y' from dual
  where not exists
  ( select person_id from per_addresses
  where person_id = p_person_id
  and region_2  = 'PA'
  and primary_flag = 'Y'
  and l_year between  to_number(to_char(trunc(date_from,'yyyy'),'yyyy')) and  to_number(nvl(to_char(trunc(date_to,'yyyy'),'yyyy') , '4712')));


  cursor c_get_visa_details( p_person_id in number ) is
  select 'Y' from per_people_extra_info
  where person_id = p_person_id
  and information_type  = 'PER_US_VISA_DETAILS'
  and pei_information_category = 'PER_US_VISA_DETAILS' ;

  BEGIN
  -- l_non_pa_res := non_pa_res ;
  l_year := to_number(p_reporting_year) ;

  open c_get_person_id(p_assignment_id) ;
  fetch c_get_person_id into p_person_id ;
 -- exit when c_get_person_id%notfound ;
  close c_get_person_id ;

  open c_get_non_pa_emp_det(p_person_id) ;
  fetch c_get_non_pa_emp_det into l_non_pa_res ;
  close c_get_non_pa_emp_det ;

  open c_get_visa_details(p_person_id) ;
  fetch c_get_visa_details into l_on_visa ;
  close c_get_visa_details ;

  non_pa_res := l_non_pa_res ;
  on_visa := l_on_visa ;


  END local_non_pa_emp_data;
BEGIN
--    hr_utility.trace_on(null, 'USLOCALW2');
    g_proc_name := 'PAY_US_MMREF_LOCAL_XML.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'LOCAL_W2_XML';

END pay_us_mmref_local_xml;

/
