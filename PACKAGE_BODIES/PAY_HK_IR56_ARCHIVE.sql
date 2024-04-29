--------------------------------------------------------
--  DDL for Package Body PAY_HK_IR56_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_IR56_ARCHIVE" AS
  --  $Header: pyhk56ar.pkb 120.3.12010000.6 2009/07/28 22:58:41 jalin ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create pay_hk_ir56_archive package body
  --  for HK IR56B Archive
  --
  --  Change List
  --  ===========
  --
  --  Date           Author         Reference Description
  --  -----------+----------------+---------+------------------------------------------
  --  05 Jul 2001    A Tripathi               Initial version
  --  18 Jul 2001    A Tripathi               Added procedure to archive data for
  --					      employee manually excluded not paid in HKD
  -- 10 Aug 2001    A Tripathi                Modified the process_assignment cursor as per
  -- 				  	      the code review comment
  -- 27 Aug 2001     A Tripathi	    1955980   Removed the checks for employee paid in currency
  --  					      other than HKD
  -- 28 Aug 2001    A Tripathi      1961965   Changed archive_employer_details cursor
  -- 04 Sep 2001    A Punekar                 Changed submit_report to submit controll listing
  --					      report for magtape
  -- 18 Sep 2001    A Tripathi      1999637   Changed archive_balance_details procedure,
  --					      added cursor to get maximum assignment_action_id
  -- 19 Jan 2002    A Tripath       2189121   Modified Validate_Employee to handle date track
  --					      changes to manual exclusion
  -- 23 Jan 2002    A Tripath       2189137   Changes done to make messages more meaningful
  --				   	      Added g_employee_number
  -- 25 Jan 2002    A Tripath       2189121   Corrected the date track change.
  -- 10 Apr 2002    J Lin           2302857   1. Corrected action_type in the cursor 56_balances
  --                                          2. return greatest of quarter_start_date and
  --                                             basic year start date in cursor qrchive_quarter
  --                                             _details
  -- 29 Feb 2002    A Punekar       2263589   Modified for performance fix
  -- 17 Sep 2002    vgsriniv        2558852   Increased the item value size for
  --                                          storing employee details and
  --                                          quarters info
  -- 17 Sep 2002    vgsriniv        2558852   Increased the item value size
  --                                          further to 150 for storing
  --                                         other_name(first_name+middle_names)
  --                                          of employee
  -- 02 Dec 2002    srrajago        2689229   Included the nocopy option for 'OUT' parameter of the
  --                                          procedure 'range_code'
  -- 16 Dec 2002    srrajago        2701921   Modified cursor ir56_employee_info to fetch the
  --                                          concatenated values of address_line1,address_line2 and
  --                                          address_line3 in 'address_lines' which is stored in
  --                                          tab_empl(13).item_value ('X_HK_RESIDENTIAL_ADDRESS_1')
  --                                          for address_type 'HK_R' and in  tab_empl(15).item_name
  --                                          ('X_HK_CORRESPONDENCE_ADDRESS_1') for address_type 'HK_C'.
  -- 10 Dec 2002    srrajago        2740270   Modified the cursor process_assignments.Included a cursor
  --                                          get_params.Assignment ids fetch is done through a
  --                                          separate cursor check_run and stored in a PL/SQL table.
  -- 16 Dec 2002    srrajago        2740270   Cursor check_run modified according to coding standards.
  --                                          Exception section included in the assignment_action_code
  --                                          section.
  -- 22 Jan 2003    puchil          2762276   Modified the cursor ir56_employee_info to select area_code_res
  --					      and modified tab_empl(8).item_value ('X_HK_RESIDENTIAL_ADDRESS_AREA_CODE')
  --					      to archive area_code_res instead of town_or_city if address_type is 'HK_R'
  -- 24 Jan 2003    srrajago        2760137   Cursor quarters_info modified to include per_all_assignments_f and
  --                                          per_periods_of_service tables and related joins. quarters_period_start
  --                                          and quarters_period_end have also been modified.
  -- 27 Jan 2003    srrajago        2760137   Included nvl check for actual_termination_date in the field
  --                                          quarters_period_end of the cursor quarters_info.
  -- 10 Feb 2003    puchil          2778848   Changed the effective date check in cursor process_assignments
  --                                          so as to eliminate terminated employees. Also removed the
  --                                          check for IR56F, G in cursor as terminated employees are eliminated.
  -- 19 Feb 2003    apunekar        2810178   Removed no. of copies passed to fnd_request.set_print_options
  -- 20 Feb 2003    puchil          2805822   Cursor quarters_info modified to return quarters_period_start and
  --                                          and quarters_period_end within a particular financial year.
  -- 20 Feb 2003    puchil          2805822   Changed the cursor quarters_info to have correct date
  --                                          i.e., from 31-01-4712 to 31-12-4712
  -- 25 Feb 2003    apunekar        2810178   Reverted fix
  -- 25 Feb 2003    puchil          2805822   Changed the cursor quarters_info to have date effective
  --                                          check so as to select the correct Quarters information.
  --                                          Also closed the Get_ManualExclusion cursor in Validate_employee
  --                                          procedure.
  -- 26 Feb 2003    puchil          2778848   Changed cursor ir56_Employee_info so as to eliminate the
  --                                          check for address_type
  -- 28 Feb 2003    srrajago        2824718   In the cursor quarters_info, included a join
  --                                          paa.period_of_service_id = pps.period_of_service_id
  -- 11 Mar 2003    srrajago        2829320   In the cursor ir56_Employee_info, included substr function for
  --                                          address_lines column so that 240 characters are only fetched.
  --                                          In the procedure Archive_Employee_details -> record type archive_rec,
  --                                          the item_name and item_value declarations modified.
  -- 12 Mar 2003    srrajago        2843765   In the call to pay_hk_ir56.get_emoluments, the parameter value passed
  --                                          for balance name was 'MAGTAPE_ORSO' and 'MAGTAPE_MPF'. These have been
  --                                          modified to 'HK_MAGTAPE_ORSO' and 'HK_MAGTAPE_MPF' respectively.
  -- 27 Mar 2003    srrajago        2853776   Included a join in the where clause of the cursor quarters_info to
  --                                          pick up the correct quarters balance data when reversal is run.
  -- 15 Apr 2003    srrajago        2890935   Removed the codes that are involved in archiving
  --                                          'X_HK_MAGTAPE_MPF_ASG_LE_YTD' and 'X_HK_MAGTAPE_ORSO_ASG_LE_YTD'.
  -- 06 May 2003    puchil          2942797   Changed cursor ir56_Employee_info, removed column chineese_full_name,
  --                                          and all references to it.
  -- 06 May 2003    srrajago        2853776   Modified the sub-query in the cursor quarters_info.
  -- 07 May 2003    shoskatt        2945151   Changed the cursor ir56_employee_info to fetch chinese_full_name. This was
  --                                          removed w.r.t earlier fix (Bug# 2942797)
  -- 08 May 2003    srrajago        2853776   Removed the financial year condition check from the main part of the
  --                                          cursor quarters_info and included the same in the sub-query.
  -- 30 May 2003    kaverma         2920731   Replaced tables per_all_assignments_f and per_all_people_f by secured views
  --                                          per_assignments_f and per_people_f respectively form the queries
  -- 05 Jun 2003    puchil          2949952   Archived the country value in X_HK_RES_COUNTRY
  -- 21 Jul 2003    srrajago        3055512   Employees terminated on 31-MAR-YYYY should not be included in the archive
  --                                          run for the year YYYY. Hence modified the cursor process_assignments by
  --                                          including the join with actual_termination_date <> 31-Mar-YYYY.
  -- 28 Aug 2003    srrajago        3059915   # In the cursor 'process_assignments', few joins with effective_date,
  --                                            reporting_year and business_group_id included.Few joins with
  --                                            pay_core_utils removed.
  --                                          # In the cursors 'ir56_Spouse_info' and 'ir56_Employee_info',view
  --                                            fnd_territories_vl replaced with fnd_territories_tl table and a
  --                                            join with language also included.
  --                                          # In the procedure 'Archive_Excep_Error_dtls', cursor 'ir56_employer_info'
  --                                            modified.Table per_assignments_f and its related joins removed.
  --                                            Cursor 'ir56_Employee_info' also modified.A join with period_of_service_id
  --                                            added.
  -- 15 Dec 2003    srrajago         3193217  Modified the procedure 'archive_balance_details'. Call to the function
  --                                          'get_emoluments' and the return values substitution have been changed as package
  --                                          'pay_hk_ir56' modified. Cursor 'ir56_balances' removed.
  -- 25 May 2004    avenkatk         3642506  #In Cursor ir56_Employee_info,modified the cursor to fetch the latest Person Details.
  --                                          #In Cursor ir56_Spouse_info,modified the cursor to fetch the latest Spouse Info Details.
  --
  -- 09 Dec 2004    jkarouza         3916743  Modified cursor check_run for performance improvement for Bug 3916743.
  -- 01 Jun 2004    jlin             4396794  Replaced substr with substrb for address_lines
  -- 27 Dec 2005    snimmala         4260143  Modified the cursor max_assign_action_id for performance improvement
  -- 29 Dec 2005    snimmala         4260143  Modified the cursor max_assign_action_id.
  -- 20 Jun 2008    jalin            7184102  Added ORDER BY clause into cursor quarters_info
  -- 22 Jul 2008    jalin            7184102  ORDER BY clause should use quarter_start_date instead of b.quarter_start_date
  -- 28 Aug 2008    tbakashi         7210187  Added the cursor ir56_Report_info for replacement details.
  -- 18 Dec 2008    dduvvuri         7635388  Added cursor ir56f_report_date to fetch last run date of IR56F report.
  -- 29 Jul 2009    jalin            8338664  Modified employer_name to extract 60 characters

  --* GLobal variables (populated in archive_code procedure)
  g_assignment_id          pay_assignment_actions.assignment_id%TYPE;
  g_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
  g_payroll_Action_id      pay_payroll_actions.payroll_action_id%TYPE;
  g_archive_message        ff_archive_items.value%TYPE := NULL;
  g_error_in_quarter       BOOLEAN := FALSE;
  g_business_group_id      hr_organization_units.business_group_id%TYPE;  -- for submitting the PAYHKCTL report

  --* Bug 2189137
  g_employee_number        per_all_people_f.employee_number%TYPE;

   TYPE
	archive_rec IS RECORD (item_name  Varchar2(100),
			       item_value Varchar2(100));
   TYPE
	archive_tab IS TABLE OF archive_rec INDEX BY BINARY_INTEGER;

   tab_empr archive_tab;
  --------------------------------------------------------------------
  --* This procedure returns a sql string to select a range
  --* of assignments eligible for archival.
  --------------------------------------------------------------------
  PROCEDURE range_code
    (p_payroll_action_id   IN pay_payroll_actions.payroll_action_id%TYPE,
     p_sql                 OUT nocopy Varchar2) is
  Begin
    hr_utility.set_location('Start of range_code',1);
    p_sql := 'SELECT distinct person_id '                            ||
             'FROM  per_people_f ppf, '                              ||
                    'pay_payroll_actions ppa '                       ||
             'WHERE ppa.payroll_action_id = :payroll_action_id '     ||
             'AND    ppa.business_group_id = ppf.business_group_id ' ||
             'ORDER BY ppf.person_id';
    hr_utility.set_location('End of range_code',2);
  End range_code;

  ------------------------------------------------------------------------
  -- This is used by legislation groups to set global contexts that are
  -- required for the lifetime of the archiving process. This is null
  -- because there are no setup requirements, but a PROCEDURE needs to
  -- exist in pay_report_format_mappings_f, otherwise the archiver will
  -- assume that no archival of data is required.
  ------------------------------------------------------------------------
  PROCEDURE initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE) is
  Begin
    hr_utility.set_location('pyhkirar: Start of initialization_code',6);
    g_payroll_action_id := p_payroll_action_id;
    hr_utility.set_location('pyhkirar: End of initialization_code',7);

  End initialization_code;

  ------------------------------------------------------------------------
  -- This PROCEDURE is used to restrict the Assignment Action Creation.
  -- It calls the PROCEDURE that actually inserts the Assignment Actions.
  -- The CURSOR SELECTs the assignments that have had any payroll
  -- processing for the Legal Entity within the Reporting Year.
  ------------------------------------------------------------------------
  PROCEDURE assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
     p_start_person_id    in per_all_people_f.person_id%TYPE,
     p_end_person_id      in per_all_people_f.person_id%TYPE,
     p_chunk              in number)
  IS
    v_next_action_id  pay_assignment_actions.assignment_action_id%TYPE;
    v_run_action_id   pay_assignment_actions.assignment_action_id%TYPE;

    /* Following variables introduced for Bug No : 2740270 */
    v_fin_start_date      date;
    v_fin_end_date        date;
    v_business_group_id   pay_payroll_actions.business_group_id%TYPE;
    v_legal_entity_id     hr_organization_units.organization_id%TYPE;
    v_reporting_year      NUMBER;

    l_counter number:=1;
    counter   number:=1;
    t_aid     per_all_assignments.assignment_id%type;

    TYPE t_assignment_list IS TABLE OF per_all_assignments_f.assignment_id%type;
    asglist t_assignment_list;


    CURSOR next_action_id is
      SELECT pay_assignment_actions_s.NEXTVAL
      FROM  dual;

    /* Introduced the following cursor get_params for Bug No : 2740270 */

    CURSOR get_params(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type)
    IS
    SELECT  to_date('01-04-'|| to_char(to_number(pay_core_utils.get_parameter('REPORTING_YEAR',legislative_parameters))
             -1),'DD-MM-YYYY') FINANCIAL_YEAR_START
           ,to_date('31-03-'||pay_core_utils.get_parameter('REPORTING_YEAR',legislative_parameters),'DD-MM-YYYY')
                               FINANCIAL_YEAR_END
           ,pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) BUSINESS_GROUP_ID
           ,pay_core_utils.get_parameter('LEGAL_ENTITY_ID',legislative_parameters) LEGAL_ENTITY_ID
           ,pay_core_utils.get_parameter('REPORTING_YEAR',legislative_parameters) REPORTING_YEAR
    FROM    pay_payroll_actions
    WHERE   payroll_action_id = c_payroll_Action_id;

   /* Bug No : 2740270 - Cursor to get all the assignments in the basis year
      for whom R,B,I,Q is run */
    CURSOR check_run
    ( c_business_group_id   pay_payroll_actions.business_group_id%TYPE,
      c_legal_entity_id     hr_organization_units.organization_id%TYPE,
      c_fin_start_date      date,
      c_fin_end_date        date )
    IS
    SELECT   distinct pac.assignment_id
    FROM     pay_payroll_actions ppa,
             pay_payrolls_f pay,               /* Added for Bug 3916743 - performance fix. */
             pay_assignment_actions pac
    WHERE    ppa.action_type in ('R','B','I','Q')
    AND      ppa.payroll_action_id = pac.payroll_action_id
    AND      ppa.business_group_id = c_business_group_id
    AND      pac.tax_unit_id = c_legal_entity_id
    AND      ppa.effective_date between c_fin_start_date and c_fin_end_date
    AND      ppa.action_status = 'C'
    AND      pac.action_status = 'C'
    AND      ppa.payroll_id = pay.payroll_id             /* This and next line added for Bug 3916743 */
    AND      pay.business_group_id = c_business_group_id
    ORDER BY pac.assignment_id;


    /* Bug No : 2740270 - Modified cursor process_assignments. Included two in parameters c_fin_start_date and
       c_fin_end_date. Removed per_all_people_f table and related joins modified.Checks with effective_date
       modified with the new in parameters.Inner query modified to include joins with report type
       'HK_IR56B_ARCHIVE' and action status with 'C' and action type with 'X'.Selection of assignments ids
       is now done through a cursor check_run and hence that part of the query has been removed from process
       assignments */

    /*Bug No : 2778848 - Modified cursor process_assignments, the select statement is changed to
      eliminate the terminated employee details, by including per_periods_of_service and checking
      for the existance of assignment as of 31 of march. Since terminated employees are not selected, the
      check for whether IR56F or IR56G is run becomes invalid hence this check is removed. */

    CURSOR process_assignments
     	(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
     	c_start_person_id    in per_all_people_f.person_id%TYPE,
     	c_end_person_id      in per_all_people_f.person_id%TYPE,
        c_fin_start_date     in date,
        c_fin_end_date       in date,
        c_business_group_id  pay_payroll_actions.business_group_id%TYPE,
        c_legal_entity_id    hr_organization_units.organization_id%TYPE,
        c_reporting_year     NUMBER)
    IS
    	SELECT DISTINCT a.assignment_id 	assignment_id
    	FROM  per_assignments_f 	a,
              pay_payroll_actions 	pa,
	      per_periods_of_service    pps
    	WHERE pa.payroll_action_id = c_payroll_action_id
    	AND   a.person_id BETWEEN c_start_person_id and c_end_person_id
    	AND   a.business_group_id  = pa.business_group_id
	AND   TO_DATE('31-03-'||c_reporting_year, 'DD-MM-YYYY') between a.effective_start_date and a.effective_end_date
	AND   TO_DATE('31-03-'||c_reporting_year, 'DD-MM-YYYY') between pps.date_start
				 and NVL(pps.actual_termination_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))
        AND   NVL(pps.actual_termination_date, TO_DATE('31-12-4712', 'DD-MM-YYYY')) <> TO_DATE('31-03-'||c_reporting_year, 'DD-MM-YYYY') -- Bug: 3055512
	AND   pps.period_of_service_id = a.period_of_service_id
	AND   pps.person_id = a.person_id
 	AND NOT EXISTS		-- don't produce if they've had ir56b report produced.
               (SELECT NULL
             	FROM   pay_action_interlocks pai,
                       pay_payroll_actions ppai,
                       pay_payroll_actions ppaa,
                       pay_assignment_actions paa
             	WHERE  paa.assignment_id = a.assignment_id
                AND    ppaa.action_type='X'
                AND    ppaa.report_type = 'HK_IR56B_ARCHIVE'
                AND    ppai.action_type='X'
                AND    ppai.action_status='C'
                AND    ppaa.action_status='C'
             	AND    ppai.report_type = 'HK_IR56B_REPORT'
             	AND    paa.assignment_action_id = pai.locking_action_id
             	AND    ppai.payroll_action_id = paa.payroll_action_id
             	AND    ppaa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID',
                                                ppai.legislative_parameters)
                /* Start of Bug No : 3059915 */
                AND ppaa.business_group_id = c_business_group_id
                AND ppaa.business_group_id = ppai.business_group_id
                AND to_char(ppaa.effective_date,'YYYY') = c_reporting_year
                AND ppaa.effective_date    = ppai.effective_date
                /* End of Bug No : 3059915 */
                AND    pay_core_utils.get_parameter('LEGAL_ENTITY_ID',ppaa.legislative_parameters) =
                       c_legal_entity_id
               )
	 ;

  Begin
    hr_utility.set_location('Start of assignment_action_code '||
  	p_payroll_action_id || ':' || p_start_person_id || ':' || p_end_person_id,3);

   /* Bug No : 2740270 - Fetching values from the cursor get_params */
    OPEN get_params(p_payroll_action_id);
    FETCH get_params
    INTO  v_fin_start_date
         ,v_fin_end_date
         ,v_business_group_id
         ,v_legal_entity_id
         ,v_reporting_year;
    CLOSE get_params;

     /* Bug No : 2740270 - Store all the assignment ids for which either of R,B,I.Q is run
       for a basis year in a PL/SQL table. Once they are stored, next time onwards only
       table is searched for the assignment ids and the query will not be executed.
       This avoids the execution of the query for all the assignments  */

    IF t_assignmentid_store.count = 0 THEN
      OPEN check_run(v_business_group_id,v_legal_entity_id,v_fin_start_date,v_fin_end_date);
      LOOP
        FETCH check_run INTO t_aid;
        EXIT WHEN check_run%NOTFOUND;
        t_assignmentid_store(t_aid) := t_aid;
      END LOOP;
      CLOSE check_run;
    END IF;

   /* Bug No : 2740270 - Used bulk collect to store all the assignment ids fetched from
      process_assignments cursor to improve performance  */

    OPEN process_assignments(p_payroll_action_id,p_start_person_id,p_end_person_id,v_fin_start_date,v_fin_end_date,
                             v_business_group_id,v_legal_entity_id,v_reporting_year);
    FETCH process_assignments bulk collect INTO asglist;
    CLOSE process_assignments;

    FOR i IN 1..asglist.count
    LOOP
      IF asglist.exists(i) THEN
        IF t_assignmentid_store.exists(asglist(i))  THEN
           OPEN next_action_id;
           FETCH next_action_id INTO v_next_action_id;
           CLOSE next_action_id;

         hr_utility.set_location('Before calling hr_nonrun_asact.insact',4);
         hr_nonrun_asact.insact(v_next_action_id,
                                asglist(i),
                                p_payroll_action_id,
                                p_chunk,
                                null);
         hr_utility.set_location('After calling hr_nonrun_asact.insact',4);
        END IF;
     END IF;
    END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
       IF next_action_id%ISOPEN THEN
          CLOSE next_action_id;
       END IF;
       hr_utility.set_location('Exception in assignment_action_code ',20);
       RAISE;
  End assignment_action_code;


  ---------------------------------
  -- [ Archive Employee details ]
  ---------------------------------

  PROCEDURE Archive_Employee_details(
     		p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     		p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
     		p_reporting_year        IN Varchar2)
  IS
    v_loop_cnt  number := 0;

    -----------------------------------------
    --* get employee records to archive
    -----------------------------------------
/* Bug 2778848 : Removed check for address type as cursor was failing when the address type was
   other than HK_R or HK_C. */

/* Bug No : 2829320 - Included substr function for address_lines column so that 240 characters are only fetched */
/*Bug 2942797 - Removed column chineese_full_name*/
    CURSOR ir56_Employee_info
      	(c_assignment_id  pay_assignment_actions.assignment_id%TYPE,
       	c_reporting_year  Varchar2 )
    IS
	SELECT  DISTINCT
   		papf.national_identifier 			hk_id_card_no,
	 	DECODE(papf.marital_status, 'M',
                       DECODE(sex, 'F', NVL(previous_last_name, last_name), last_name)
		      ,last_name)				last_name,
       		TRIM(papf.first_name||' '||papf.middle_names) 	other_name,
                papf.per_information5 				chinese_full_name, /* Bug 2945151 */
       		SUBSTR(papf.sex,1,1) 				sex,
       		DECODE(papf.marital_status,'M',2,1)             marital_status,
       		papf.per_information1
       		||DECODE(papf.per_information2,NULL, NULL, ' '
       		|| ftv.territory_short_name)                    passport_info,
                papf.employee_number                            employee_number,
		pad.address_type				address_type, /* Start of Bug No : 2701921, 4396794 */
                substrb(decode(pad.address_line1,null,'', pad.address_line1 ||
                        decode(pad.address_line2,null,decode(pad.address_line3,null,'',', '),', ')) ||
                          decode(pad.address_line2,null,'', pad.address_line2 || decode(pad.address_line3,null,'',', ')) ||
                            pad.address_line3,1,240)            address_lines, /* End of Bug : 2701921,4396794 */
                pad.town_or_city				town_or_city,
		pad.country					country,
                DECODE(pad.style, 'HK', ','||hrl.meaning, NULL) area_code,
                DECODE(pad.style, 'HK', hrl.meaning, NULL) area_code_res,/*Added for bug 2762276 to store residential address area code*/
		paei.aei_information1				capacity_employed,
		hsck.segment2					principal_emp_name,
		TO_CHAR(GREATEST(TO_DATE('01/04/'||
			TO_CHAR(TO_NUMBER(c_reporting_year)-1),'DD/MM/YYYY')
			,pps.date_start), 'YYYYMMDD')	 	employment_start_date,
		c_reporting_year||'0331'		  	employment_end_date,
		papf.per_information9				employee_tfn,
		hsck.segment5					remarks,
       		pcr.primary_contact_flag			primary_contact_flag,
       		NVL(pcr.contact_person_id,0)   			person_id,   -- used in spouse cursor
       		pcr.contact_type     	   			contact_type, -- used in spouse cursor
                pcr.date_start					date_start
	FROM   	per_people_f 	        	papf,
       		per_assignments_f 		paaf,
	       	fnd_territories_tl  		ftv, /*  Bug No : 3059915 */
       		per_contact_relationships  	pcr,
	       	per_addresses 			pad,
		per_assignment_extra_info 	paei,
		per_periods_of_service    	pps,
		hr_soft_coding_keyflex 		hsck,
	       	hr_lookups 			hrl
	WHERE  	paaf.person_id = papf.person_id
	AND    	TO_DATE('31-03-'|| c_reporting_year, 'DD-MM-YYYY')
       		BETWEEN   paaf.effective_start_date and paaf.effective_end_date
	AND     papf.effective_end_date = NVL(pps.actual_termination_date,TO_DATE('31-12-4712','dd-mm-yyyy')) /* Bug No : 3642506*/
	AND    	papf.per_information2 = ftv.territory_code(+)
        AND     ftv.language(+) = userenv('LANG') /* Bug No : 3059915 */
        AND     pps.period_of_service_id = paaf.period_of_service_id  /* Bug No : 3059915 */
	AND    	papf.person_id = pcr.person_id(+)
	AND    	papf.business_group_id = p_business_group_id
	AND    	pcr.business_group_id(+) = p_business_group_id  -- watch this condition
	AND    	NVL(pcr.date_end(+),TO_DATE('31-12-4712','dd-mm-yyyy')) =TO_DATE('31-12-4712','dd-mm-yyyy') /* Bug No : 3642506*/
	AND    	paaf.assignment_id = c_assignment_id
	AND    	papf.person_id = pad.person_id(+)
	AND    	NVL(pad.date_to(+),TO_DATE('31-12-4712','dd-mm-yyyy')) = TO_DATE('31-12-4712','dd-mm-yyyy') /* Bug No : 3642506*/
	AND    	pad.region_1 = hrl.lookup_code(+)
	AND    	pad.business_group_id(+) = p_business_group_id
	AND    	hrl.lookup_type(+)= 'HK_AREA_CODES'
	AND	paei.assignment_id(+) = paaf.assignment_id
	AND 	paei.aei_information_category(+) = 'HR_EMPLOYMENT_INFO_HK'
	AND 	hsck.soft_coding_keyflex_id(+) = paaf.soft_coding_keyflex_id
	AND    	TO_DATE('31-03-'|| c_reporting_year, 'DD-MM-YYYY')
	   	BETWEEN nvl(hsck.start_date_active(+),to_date('01-01-1900','dd-mm-yyyy'))
	   	AND NVL(hsck.end_date_active(+),TO_DATE('31-12-4712','dd-mm-yyyy'))
    	AND	pps.person_id = paaf.person_id
	AND    	TO_DATE('31-03-'||c_reporting_year, 'DD-MM-YYYY')
	   	BETWEEN pps.date_start
	   	AND NVL(pps.actual_termination_date,TO_DATE('31-12-4712','dd-mm-yyyy'))
	ORDER BY  papf.national_identifier ASC,pcr.primary_contact_flag DESC,pcr.date_start DESC;
        --* Order by clause above insures that contact type with primary contactflag is selected
        --* first, if more than one spouse record exists without primary contact flag then
        --* select the spouse with earliest start date. This is used in the subsequent cursor
        --* for getting the spouse detail for an employee

    employee_rec  ir56_Employee_info%ROWTYPE;

/* 7210187 */

  CURSOR ir56_Report_info
      	(c_assignment_id  pay_assignment_actions.assignment_id%TYPE,
       	c_reporting_year  Varchar2 )
    IS
    	SELECT  DISTINCT
	substr(paei.aei_information2,1,10)      last_run_date,
	paei.aei_information5             	last_run_type

	from per_assignment_extra_info 	paei

	where paei.aei_information_category = 'HR_IR56B_REPORTING_INFO_HK'
	AND	to_number(paei.assignment_id) = c_assignment_id
	AND	to_number(paei.aei_information1) = c_reporting_year;

report_rec  ir56_Report_info%ROWTYPE;

/* 7210187 */

/* 7635388 - Cursor ir56f_report_date created to fetch the last run date of IR56F report */
   CURSOR ir56f_report_date
   (c_assignment_id  pay_assignment_actions.assignment_id%TYPE)
   IS
    SELECT	TO_CHAR(to_date(paei.aei_information2,'yyyy/mm/dd hh24:mi:ss'),'yyyy/mm/dd')
    FROM 	per_assignment_extra_info paei,
                per_assignment_info_types pait
    WHERE	paei.assignment_id = c_assignment_id
    AND		paei.information_type = 'HR_LE_REPORTING_HK'
    AND		paei.information_type = pait.information_type
    AND 	pait.active_inactive_flag = 'Y';



    --* From above employee_info cursor, if contact_type ='S'
    --* and and pcr.person_id is not null,then open cursor to
    --* spouse details

    CURSOR ir56_Spouse_info(c_person_id       per_all_people_f.person_id%TYPE,
			    c_reporting_year  Varchar2 )
    IS
	SELECT papf_spouse.last_name
	       || DECODE(papf_spouse.first_name, null, null, ', '
	       || papf_spouse.first_name)
	       || DECODE(papf_spouse.middle_names, null, null, ', '
               || papf_spouse.middle_names)           		spouse_name,
	       papf_spouse.national_identifier spouse_hk_id,
	       papf_spouse.per_information1
	       ||DECODE(papf_spouse.per_information2,NULL, NULL, ' '
	       || ftv.territory_short_name)                     passport_info
	FROM   per_people_f		papf_spouse,
	       fnd_territories_tl  	ftv       /*  Bug No : 3059915 */
        WHERE  papf_spouse.person_id = c_person_id
	AND    papf_spouse.business_group_id = p_business_group_id
	AND    papf_spouse.per_information2 = ftv.territory_code(+)
        AND    ftv.language(+) = userenv('LANG')  /* Bug No : 3059915 */
	AND    papf_spouse.effective_end_date = TO_DATE('31-12-4712','dd-mm-yyyy'); /* Bug No : 3642506 */

   spouse_rec ir56_Spouse_info%ROWTYPE;

   /* Bug 2558852 Increased the item_value size from 100 to 250 to
      accomodate address details and other_name of the employee */

   /* Bug No : 2829320 - declared item_name and item_value using %type */

   TYPE
	archive_rec IS RECORD (item_name  ff_user_entities.user_entity_name%type,
			       item_value ff_archive_items.value%type);
   TYPE
	archive_tab IS TABLE OF archive_rec INDEX BY BINARY_INTEGER;
   tab_empl archive_tab;

   tab_count Number := 1;

   spouse_found Char(1) ;
   printed_once Char(1) ;

   p_value Varchar2(240);
   l_date varchar2(40); /* 7635388 */
Begin

     ---------------------------------------
     --* Initialization section
     ---------------------------------------
        spouse_found := 'N';
	printed_once := 'N';

    	tab_empl(1).item_name  := 'X_HK_HKID';
      --*
    	tab_empl(2).item_name  := 'X_HK_LAST_NAME';
      --*
    	tab_empl(3).item_name  := 'X_HK_OTHER_NAMES';
      --*
    	tab_empl(4).item_name  := 'X_HK_CHINESE_FULL_NAME';
      --*
    	tab_empl(5).item_name  := 'X_HK_SEX';
      --*
    	tab_empl(6).item_name  := 'X_HK_MARITAL_STATUS';
      --*
    	tab_empl(7).item_name  := 'X_HK_PASSPORT_INFO';
      --*
    	tab_empl(8).item_name  := 'X_HK_RESIDENTIAL_ADDRESS_AREA_CODE';
      --*
    	tab_empl(9).item_name  := 'X_HK_CAPACITY_EMPLOYED';
      --*
    	tab_empl(10).item_name  := 'X_HK_PRINCIPAL_EMPLOYER_NAME';
      --*
    	tab_empl(11).item_name  := 'X_HK_EMPLOYMENT_START_DATE';

      --*
    	tab_empl(12).item_name  := 'X_HK_EMPLOYMENT_END_DATE';
      --*
    	tab_empl(13).item_name  := 'X_HK_RESIDENTIAL_ADDRESS_1';

      --*
    	tab_empl(14).item_name  := 'X_HK_RESIDENTIAL_ADDRESS_2';
      --*
    	tab_empl(15).item_name  := 'X_HK_CORRESPONDENCE_ADDRESS_1';
      --*
    	tab_empl(16).item_name  := 'X_HK_SPOUSE_NAME';
      --*
    	tab_empl(17).item_name  := 'X_HK_SPOUSE_HKID';
      --*
	tab_empl(18).item_name  := 'X_HK_SPOUSE_PASSPORT_INFO';
      --*
	tab_empl(19).item_name  := 'X_HK_EMPLOYEE_TFN';
      --*
	tab_empl(20).item_name  := 'X_HK_REMARKS';
      --*
    	tab_empl(21).item_name  := 'X_HK_CORRESPONDENCE_ADDRESS_2';
      --*
    	tab_empl(22).item_name  := 'X_HK_RES_COUNTRY';      /* 2949952 */
      --*
	tab_empl(23).item_name  := 'X_HK_LAST_RUN_DATE';   /* 7210187 */
      --*
	tab_empl(24).item_name  := 'X_HK_LAST_RUN_TYPE';


     ---------------------------------------
     --* Initialization section over
     ---------------------------------------




   OPEN   ir56_Employee_info(g_assignment_id,p_reporting_year);
   LOOP
   FETCH  ir56_Employee_info INTO employee_rec;
   IF ir56_Employee_info%FOUND Then


      ---------------------------------------
      --* Prepare employee data
      ---------------------------------------

      /*
         The cursor is created in such a way that for an assignment it could return
 	 more than one row. So printed_once flag is used to avoid the archival records
         from getting duplicated
      */



      IF printed_once = 'N' Then

     	--* 'X_HK_HKID'
    	tab_empl(1).item_value := employee_rec.hk_id_card_no;

        --* 'X_HK_LAST_NAME'
    	tab_empl(2).item_value := rtrim(employee_rec.last_name);

        --* 'X_HK_OTHER_NAMES'
    	tab_empl(3).item_value :=  employee_rec.other_name;

        --* 'X_HK_CHINESE_FULL_NAME'
    	tab_empl(4).item_value := employee_rec.chinese_full_name;   /*Bug 2942797*/
                                /*Bug 2945151 - Set the Chinese Full Name back. This was removed w.r.t
                                  earlier Bug 2942797 */

        --* 'X_HK_SEX'
    	tab_empl(5).item_value := employee_rec.sex;

        --* 'X_HK_MARITAL_STATUS'
    	tab_empl(6).item_value := employee_rec.marital_status;

        --* 'X_HK_PASSPORT_INFO'
    	tab_empl(7).item_value := employee_rec.passport_info;

        --* 'X_HK_CAPACITY_EMPLOYED'
	tab_empl(9).item_value :=  employee_rec.capacity_employed;

        --* 'X_HK_PRINCIPAL_EMPLOYER_NAME'
	tab_empl(10).item_value :=  employee_rec.principal_emp_name;

        --* 'X_HK_EMPLOYMENT_START_DATE'
	tab_empl(11).item_value :=  employee_rec.employment_start_date;

        --* 'X_HK_EMPLOYMENT_END_DATE'
	tab_empl(12).item_value :=  employee_rec.employment_end_date;

        --* 'X_HK_EMPLOYEE_TFN'
	tab_empl(19).item_value :=  employee_rec.employee_tfn;

        --* 'X_HK_REMARKS'
	tab_empl(20).item_value :=  employee_rec.remarks;

        --* Bug 2189137
        --* 'Employee number
        g_employee_number := employee_rec.employee_number;


	printed_once := 'Y';
     End if;

/* 7210187 */

   OPEN   ir56_Report_info(g_assignment_id,p_reporting_year);

   FETCH  ir56_Report_info INTO report_rec;

   If ir56_Report_info%found then

     	tab_empl(23).item_value := report_rec.last_run_date;
	tab_empl(24).item_value := report_rec.last_run_type;
   else /* 7635388 - fetch the last run date of IR56F report */
        OPEN ir56f_report_date(g_assignment_id);
        FETCH ir56f_report_date INTO l_date;
        if l_date is not null then
        tab_empl(23).item_value := l_date;
        tab_empl(24).item_value := 'REPLACEMENT';
        end if;
        CLOSE ir56f_report_date;
   End If;

   CLOSE ir56_Report_info;

/* 7210187 */

     /* printed_flag is not used since the cursor may return more than one record,
        for example address_type can have two values , HK_R and HK_C for a single
        assignment.In that case the cursor will return 2 rows and both the values
        need to be stored */

     If employee_rec.address_type='HK_R' Then
     	   --* 'X_HK_RESIDENTIAL_ADDRESS_1'
	   tab_empl(13).item_value := employee_rec.address_lines; /* Bug No : 2701921 */

	 /* Moved the following two lines from the above if block as residential address
	    area code requires check for address type. further, the item_value is populated
            by area_code_res instead of town_or_city -- Bug 2762276*/
           --* 'X_HK_RESIDENTIAL_ADDRESS_AREA_CODE'
	   tab_empl(8).item_value :=  employee_rec.area_code_res;

         /*Start of fix for Bug 2949952 */
           --* 'X_HK_RESIDENTIAL_ADDRESS_2'
    	   tab_empl(14).item_value := employee_rec.town_or_city;

           --* 'X_HK_RES_COUNTRY'
           tab_empl(22).item_value := employee_rec.country;
         /*End of fix for Bug 2949952 */

     End If;

     --* 'X_HK_CORRESPONDENCE_ADDRESS_1'
     If employee_rec.address_type='HK_C' Then
    	      tab_empl(15).item_value := employee_rec.address_lines; /* Bug No : 2701921 */
     End If;

     --* 'X_HK_CORRESPONDENCE_ADDRESS_2'
     If employee_rec.address_type='HK_C' Then
        If employee_rec.country IS NULL Then
           tab_empl(21).item_value := employee_rec.town_or_city
				   ||employee_rec.area_code;
        Else
           tab_empl(21).item_value := employee_rec.town_or_city
				   ||employee_rec.area_code
				   ||','||employee_rec.country;
        End If;
     End If;


     --* Employee data over

     ---------------------------------------
     --* Prepare spouse data
     ---------------------------------------
     ---* Find the spouse detail only if 1) the person is having a spouse 2) contact type ='S'
     ---* 3) the employee cursor may loop more than once , don't find the spouse again if found
     ---* earlier.The order by clause in the employee cursor ensures that if the primary contact
     ---* type is 'Y' then  that record is selected first . If the primary contact is 'Y' ,
     ---* no need to find  other types of spouse ie. of type other than 'Y'.If no contact
     ---* with type 'Y' exists then get any other contact type details ie. 'N'

     If ( (employee_rec.person_id <> 0) AND (employee_rec.contact_type = 'S')
	   AND (spouse_found = 'N')) Then

    	OPEN  ir56_Spouse_info(employee_rec.person_id,p_reporting_year);
	FETCH ir56_Spouse_info INTO spouse_rec;
	If ir56_Spouse_info%FOUND Then
	   --*'X_HK_SPOUSE_NAME'
    	   tab_empl(16).item_value := spouse_rec.spouse_name;

           --*'X_HK_SPOUSE_HKID'
    	   tab_empl(17).item_value := spouse_rec.spouse_hk_id;

    	   --* 'X_HK_SPOUSE_PASSPORT_INFO'
    	   tab_empl(18).item_value := spouse_rec.passport_info;

 	   spouse_found := 'Y';
	End If;
	CLOSE ir56_Spouse_info;
     End if;
   Else
      --* No employee details exists
      Exit;
   End If;
   END LOOP;
   ---------------------------------------
   --* Archive employee and spouse details
   ---------------------------------------

     For tab_count in 1..tab_empl.COUNT
     LOOP
        If tab_empl.EXISTS(tab_count) Then
           archive_item(tab_empl(tab_count).item_name,
                      g_assignment_action_id,
                      tab_empl(tab_count).item_value);

        End If;
     END LOOP;

   CLOSE ir56_Employee_info;
 Exception
    When Others Then
	If ir56_Employee_info%ISOPEN Then
	   CLOSE ir56_Employee_info;
        End If;
	hr_utility.set_location('Archive_employee_details ,Exception others',20);
	RAISE;
 End Archive_Employee_details;

  ---------------------------------
  -- [ Archive Employer details ]
  ---------------------------------
  PROCEDURE Archive_Employer_details  (
     		p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     		p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
     		p_reporting_year        IN Varchar2)
  IS
    v_loop_cnt  number := 0;

    -----------------------------------------
    --* get employer records to archive
    -- Bug 8338664, extract employer_name 60 characters
    -----------------------------------------
    CURSOR ir56_Employer_info
      	(c_legal_entity_id  hr_organization_units.organization_id%TYPE,
	 c_reporting_year   Varchar2 )
    IS
	SELECT DISTINCT
               substr(hou.name,1,60)                       employer_name,
               hoi.org_information1            employer_tfn,
               hoi.org_information2            designation,
               p_legal_entity_id               legal_employer_id,
               hoi.org_information3            contact_name,
               p_reporting_year                reporting_year,
               TO_CHAR(SYSDATE,'YYYYMMDD')   issue_date
        FROM   hr_organization_information      hoi,
               hr_organization_units            hou
        WHERE  hoi.org_information_context = 'HK_LEGAL_EMPLOYER'
        AND    hoi.organization_id = hou.organization_id
        AND    hoi.organization_id = c_legal_entity_id ;

    	employer_rec ir56_employer_info%ROWTYPE;



   tab_count 	Number := 1;
   tab_index 	Number := 1;

   e_employer_notfound  Exception;
Begin

   if tab_empr.count = 0 then/*2263589-Store in table only once.open cursor only first time*/

    OPEN  ir56_Employer_info(p_legal_entity_id, p_reporting_year);

    FETCH ir56_Employer_info into employer_rec;

    If ir56_Employer_info%FOUND Then
        ---------------------------------------
    	--* Prepare employer the data to arhive
        ---------------------------------------
      --*
    	tab_empr(1).item_name  := 'X_HK_EMPLOYER_TFN';
    	tab_empr(1).item_value := employer_rec.employer_tfn;
      --*
	tab_empr(2).item_name  := 'X_HK_EMPLOYER_NAME';
    	tab_empr(2).item_value := employer_rec.employer_name;
      --*
    	tab_empr(3).item_name  := 'X_HK_LEGAL_EMPLOYER_ID';
    	tab_empr(3).item_value := employer_rec.legal_employer_id;
      --*
    	tab_empr(4).item_name  := 'X_HK_DESIGNATION';
    	tab_empr(4).item_value := employer_rec.designation;
      --*
    	tab_empr(5).item_name  := 'X_HK_CONTACT';
    	tab_empr(5).item_value := employer_rec.contact_name;
      --*
    	tab_empr(6).item_name  := 'X_HK_REPORTING_YEAR';
    	tab_empr(6).item_value := employer_rec.reporting_year;
      --*
    	tab_empr(7).item_name  := 'X_HK_ISSUE_DATE';
    	tab_empr(7).item_value := employer_rec.issue_date;


     CLOSE ir56_Employer_info;
     Else
       CLOSE ir56_Employer_info;
       RAISE  e_employer_notfound;
    end if;
end if;

      	--* end employer data
       For tab_count in 1..tab_empr.COUNT
       LOOP
          If tab_empr.EXISTS(tab_count) Then
	     archive_item(tab_empr(tab_count).item_name,
                      g_assignment_action_id,
		      tab_empr(tab_count).item_value);
          End If;
       END LOOP;


        -------------------------------------------
        --* Call procedure to archive employee data
        -------------------------------------------
	Archive_Employee_details(
				p_business_group_id,
				p_legal_entity_id,
				p_reporting_year);


  Exception
     When e_employer_notfound then
         hr_utility.set_location('No employee Details found for the assigment id  ',20);
     When Others Then
	If ir56_Employer_info%ISOPEN Then
	   CLOSE ir56_Employer_info;
        End If;
        hr_utility.set_location('Error in archive_employee_details ',99);
        RAISE;
  End Archive_Employer_details;

  ---------------------------------
  -- [ Archive Balance details ]
  ---------------------------------
  PROCEDURE Archive_Balance_details(
     		p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     		p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
     		p_reporting_year        IN Varchar2)
  IS

    CURSOR max_assign_action_id(c_assignment_id pay_assignment_actions.assignment_id%TYPE,
			     c_reporting_year   Varchar2 )
    IS
          SELECT  paa.assignment_action_id
          FROM    pay_assignment_actions paa
          WHERE   paa.assignment_id = c_assignment_id
           and    paa.action_sequence = (select max(paa2.action_sequence)
                                         from   pay_assignment_actions paa2,
                                                pay_payroll_actions ppa
			                 where  paa2.assignment_id = c_assignment_id
                                         and    ppa.payroll_action_id = paa2.payroll_action_id
                                         and    paa2.action_status = 'C'
                                         and    ppa.action_type in ('R', 'Q', 'B', 'I', 'V')
   			                 and    ppa.effective_date BETWEEN TO_DATE('01-04-'|| TO_CHAR(TO_NUMBER(c_reporting_year)-1), 'DD-MM-YYYY')
			                 and    TO_DATE('31-03-'||c_reporting_year, 'DD-MM-YYYY'));

    rec_max_assign_action_id max_assign_action_id%ROWTYPE;

    l_emol_details   pay_hk_ir56.g_emol_details_tab;
    i                Number := 1;
    v_period_format  Varchar2(100); -- Holds the period in the format yyyymmdd-yyyymmdd

  Begin
    OPEN max_assign_action_id(g_assignment_id,p_reporting_year);
    FETCH max_assign_action_id INTO rec_max_assign_action_id;
    CLOSE max_assign_action_id;

    l_emol_details := PAY_HK_IR56.GET_EMOLUMENTS
			(g_assignment_id,
                         rec_max_assign_action_id.assignment_action_id,
                         p_legal_entity_id,
		         p_reporting_year);

    FOR i IN l_emol_details.FIRST..l_emol_details.LAST
    LOOP
       IF(l_emol_details.EXISTS(i)) THEN

         archive_item('X_HK_' || l_emol_details(i).balance_name ||'_ASG_LE_YTD',
                       g_assignment_action_id,
                       l_emol_details(i).balance_value);
         archive_item('X_HK_' || l_emol_details(i).balance_name ||'_DESCRIPTION',
                       g_assignment_action_id,
                       l_emol_details(i).particulars);

         --* the period returned is in the format dd/mm/yyyy-dd/mm/yyyy
         --* change it to yyyymmdd - yyyymmdd
         If (l_emol_details(i).period_dates IS NOT NULL) THEN
            v_period_format := substr(l_emol_details(i).period_dates,7,4)||substr(l_emol_details(i).period_dates,4,2)||
                               substr(l_emol_details(i).period_dates,1,2)||' - '||
	         	       substr(l_emol_details(i).period_dates,20,4)||substr(l_emol_details(i).period_dates,17,2)||
                               substr(l_emol_details(i).period_dates,14,2);
         Else
	    v_period_format := l_emol_details(i).period_dates;
         end If;

         archive_item('X_HK_' || l_emol_details(i).balance_name ||'_PERIOD',
                       g_assignment_action_id,
                       v_period_format);
       END IF;
    END LOOP;

  Exception
     When Others Then
        hr_utility.set_location('Error in archive_balance_details ',99);
        RAISE;
  End Archive_Balance_details;

  ---------------------------------
  -- [ Archive Quarter details ]
  ---------------------------------
  PROCEDURE Archive_Quarter_details(
     		p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     		p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
       		p_reporting_year        IN Varchar2)
  IS
    v_loop_cnt  number := 0;

/* Bug No : 2760137 - Modified the cursor quarters_info */

/* Bug No : 2805822 - Modified the cursor quarters_info, changed the decode statements for
   quarter_period_start and quarter_period_end which is calculated as below:-

   If user has entered quarter start and end dates, and either start
   date, end date, or both, fall within the tax year being processed
   The quarters period is calculated as follows:

   Start Date = 1-Apr Tax Year, Quarters Start Date or Hire Date
             (whichever is later)
   End Date = 31-Mar Tax Year, Quarters End Date or Termination Date
             (whichever is earlier)

   If user has entered quarter start and end dates, and both start and
   end date fall outside the processing year, OR if the user has not
   entered dates. The quarters period is calculated as follows:

   Start Date = 1-Apr Tax Year or Hire Date(whichever is later)

   End Date = 31-Mar Tax Year or Termination Date(whichever is earlier) */

/* Bug No : 2805822 - Modified the cursor quarters_info, added date effective check
   so that quarters details for that particular financial year is selected*/

/* Bug No : 2853776 - Cursor quarters_info modified -
   The sub query included for Bug No: 2853776 has been modified to join max action_sequence instead of
   max assignment action id.*/

/* Bug 7184102 Added ORDER BY clause into cursor quarters_info */

    CURSOR quarters_info
      (c_assignment_id        IN pay_assignment_actions.assignment_id%TYPE,
       c_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE)
    IS
      SELECT b.assignment_id assignment_id,
             b.SOURCE_ID      source_id,
   	     b.QUARTERS_ADDRESS   quarters_address,
   	     b.QUARTERS_NATURE	   quarters_nature,
	     to_char(decode(to_date(max(b.quarters_period_start),'DD/MM/YYYY'), null,
	        greatest(max(pps.date_start),to_date(to_char(to_number(p_reporting_year)-1)||'0401', 'YYYYMMDD')),
		decode(greatest(to_date(max(b.quarters_period_start),'DD/MM/YYYY'), to_date(p_reporting_year||'0331', 'YYYYMMDD')),
	           to_date(max(b.quarters_period_start),'DD/MM/YYYY'),
		   greatest(max(pps.date_start),to_date(to_char(to_number(p_reporting_year)-1)||'0401', 'YYYYMMDD')),
		   greatest(max(pps.date_start),to_date(to_char(to_number(p_reporting_year)-1)||'0401', 'YYYYMMDD'), to_date(max(b.quarters_period_start),'DD/MM/YYYY')))), 'YYYYMMDD') quarters_period_start,
  	    to_char(decode(to_date(max(b.quarters_period_end),'DD/MM/YYYY'), null,
	        least(to_date(p_reporting_year||'0331', 'YYYYMMDD'), nvl(max(pps.actual_termination_date), to_date('31-12-4712', 'DD-MM-YYYY'))),
		decode(least(to_date(max(b.quarters_period_end),'DD/MM/YYYY'), to_date(to_char(to_number(p_reporting_year)-1)||'0401', 'YYYYMMDD')),
	           to_date(max(b.quarters_period_end),'DD/MM/YYYY'),
		   least(to_date(p_reporting_year||'0331', 'YYYYMMDD'), nvl(max(pps.actual_termination_date), to_date('31-12-4712', 'DD-MM-YYYY'))),
		   least(to_date(max(b.quarters_period_end),'DD/MM/YYYY'), nvl(max(pps.actual_termination_date), to_date('31-12-4712', 'DD-MM-YYYY')), to_date(p_reporting_year||'0331', 'YYYYMMDD')))), 'YYYYMMDD') quarters_period_end,
             max(b.QUARTERS_ER_TO_LANDLORD) QUARTERS_ER_TO_LANDLORD,
	     max(b.QUARTERS_EE_TO_LANDLORD) QUARTERS_EE_TO_LANDLORD,
	     max(b.QUARTERS_REFUND_TO_EE)   QUARTERS_REFUND_TO_EE,
	     max(b.QUARTERS_EE_TO_ER)       QUARTERS_EE_TO_ER
       FROM  pay_hk_ir56_quarters_info_v   b,
             per_periods_of_service        pps,
             per_assignments_f             paa
       WHERE b.assignment_id = c_assignment_id
         AND paa.assignment_id = b.assignment_id
         AND paa.person_id     = pps.person_id
         AND paa.period_of_service_id = pps.period_of_service_id  /* Bug No : 2824718 */
         AND b.action_sequence        = (SELECT max(action_sequence)
                                           FROM pay_hk_ir56_quarters_info_v
                                          WHERE assignment_id = b.assignment_id
                                            AND source_id     = b.source_id /* Bug No : 2853776 */
                                            AND start_date between
                                                to_date('01/04/'||to_char(to_number(p_reporting_year)-1),'DD/MM/YYYY')
                                                AND to_date('31/03/'||p_reporting_year,'DD/MM/YYYY')
                                            AND end_date between
                                                to_date('01/04/'||to_char(to_number(p_reporting_year)-1),'DD/MM/YYYY')
                                                AND to_date('31/03/'||p_reporting_year,'DD/MM/YYYY'))
       GROUP BY
              b.assignment_id,
              b.SOURCE_ID,
   	      b.QUARTERS_ADDRESS,
   	      b.QUARTERS_NATURE,
          quarters_period_start,
          quarters_period_end
       ORDER BY quarters_period_start,quarters_period_end;  /* Bug 7184102 */

   quarters_rec quarters_info%rowtype;

   /* Bug 2558852 Increased the item_value size from 100 to 150 to
      accomodate quarters address which can exceed 100 characters */
   TYPE
	archive_rec IS RECORD (item_name  Varchar2(100),
			       item_value Varchar2(150));
   TYPE
	archive_tab IS TABLE OF archive_rec INDEX BY BINARY_INTEGER;
   tab_quarter archive_tab;

   tab_count Number := 1;

 Begin

     ---------------------------------------
     --* Initialization section
     ---------------------------------------
    -------------
    --* Quarter 1
    -------------
    tab_quarter(1).item_name   := 'X_HK_QUARTERS_PROVIDED';
    --*
    tab_quarter(2).item_name   := 'X_HK_QUARTERS_1_ADDRESS';
    --*
    tab_quarter(3).item_name   := 'X_HK_QUARTERS_1_NATURE';
    --*
    tab_quarter(4).item_name   := 'X_HK_QUARTERS_1_PERIOD';
    --*
    tab_quarter(5).item_name   := 'X_HK_QUARTERS_1_ER_TO_LL_LE_YTD';
    --*
    tab_quarter(6).item_name   := 'X_HK_QUARTERS_1_EE_TO_LL_LE_YTD';
    --*
    tab_quarter(7).item_name   := 'X_HK_QUARTERS_1_REFUND_TO_EE_LE_YTD';
    --*
    tab_quarter(8).item_name   := 'X_HK_QUARTERS_1_EE_TO_ER_LE_YTD';

    -------------
    --* Quarter 2
    -------------
    tab_quarter(9).item_name   := 'X_HK_QUARTERS_2_ADDRESS';
    --*
    tab_quarter(10).item_name  := 'X_HK_QUARTERS_2_NATURE';
    --*
    tab_quarter(11).item_name  := 'X_HK_QUARTERS_2_PERIOD';
    --*
    tab_quarter(12).item_name  := 'X_HK_QUARTERS_2_ER_TO_LL_LE_YTD';
    --*
    tab_quarter(13).item_name  := 'X_HK_QUARTERS_2_EE_TO_LL_LE_YTD';
    --*
    tab_quarter(14).item_name  := 'X_HK_QUARTERS_2_REFUND_TO_EE_LE_YTD';
    --*
    tab_quarter(15).item_name  := 'X_HK_QUARTERS_2_EE_TO_ER_LE_YTD';
    --*

    g_error_in_quarter := FALSE;

    OPEN quarters_info(g_assignment_id,g_assignment_action_id);
    FETCH quarters_info INTO quarters_rec;
    If quarters_info%FOUND Then
    	--*
    	tab_quarter(1).item_value   := 1;
    	--*
    	tab_quarter(2).item_value   :=  quarters_rec.quarters_address ; -- check it
    	--*
    	tab_quarter(3).item_value   := quarters_rec.quarters_nature;
    	--*
    	tab_quarter(4).item_value   := quarters_rec.QUARTERS_PERIOD_START||'-'
				       ||quarters_rec.QUARTERS_PERIOD_END   ;
    	--*
    	tab_quarter(5).item_value   := quarters_rec.QUARTERS_ER_TO_LANDLORD;
    	--*
    	tab_quarter(6).item_value   := quarters_rec.QUARTERS_EE_TO_LANDLORD;
    	--*
    	tab_quarter(7).item_value   := quarters_rec. QUARTERS_REFUND_TO_EE;
    	--*
    	tab_quarter(8).item_value   := quarters_rec.QUARTERS_EE_TO_ER;
    	--*

        --* Fetch again to get the second quarter detail if exists

        FETCH quarters_info into quarters_rec;
        If quarters_info%FOUND then
           --*
           tab_quarter(9).item_value    := quarters_rec.quarters_address ;  --  check it
    	   --*
	   tab_quarter(10).item_value   := quarters_rec.quarters_nature;
    	   --*
	   tab_quarter(11).item_value   := quarters_rec.QUARTERS_PERIOD_START||'-'
		  	                   ||quarters_rec.QUARTERS_PERIOD_END   ;
    	   --*
	   tab_quarter(12).item_value   := quarters_rec.QUARTERS_ER_TO_LANDLORD;
    	   --*
	   tab_quarter(13).item_value   := quarters_rec.QUARTERS_EE_TO_LANDLORD;
    	   --*
	   tab_quarter(14).item_value   := quarters_rec.QUARTERS_REFUND_TO_EE;
    	   --*
	   tab_quarter(15).item_value   := quarters_rec.QUARTERS_EE_TO_ER;
        End If;

        --* If more than 2 quarters exists then its an error
        FETCH quarters_info into quarters_rec;
        If quarters_info%FOUND Then
	    --* If the employee is having more than 2 quaretrs then archive message need to be
            --* populated but the record need to be archived
           g_archive_message := g_assignment_action_id||':Employee number '
		              ||g_employee_number||' has more than two quarters locations.';
	   g_error_in_quarter := TRUE;

        End if;
    Else
       --* If no quarters exists then set X_HK_QUARTERS_PROVIDED to 0
       tab_quarter(1).item_value   := 0;
    End if;

    --* Archive Quarter details
    For tab_count in 1..tab_quarter.COUNT
    LOOP
       If tab_quarter.EXISTS(tab_count) Then
          archive_item(tab_quarter(tab_count).item_name,
	            g_assignment_action_id,
                    tab_quarter(tab_count).item_value);

       End If;
    END LOOP;

    CLOSE quarters_info;

  Exception
     When Others Then
	If quarters_info%ISOPEN Then
	   CLOSE quarters_info;
        End If;
        hr_utility.set_location('Error in archive_quarter_details ',99);
        RAISE;
  End Archive_Quarter_details;


  ---------------------------------
  -- [ Archive Overseas details ]
  ---------------------------------

  PROCEDURE Archive_Overseas_Details(
     		p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     		p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
     		p_reporting_year        IN Varchar2)
  IS
    v_loop_cnt  number := 0;

  CURSOR os_info (c_assignment_id in pay_assignment_actions.assignment_id%TYPE)
  IS
      SELECT *
      FROM   pay_hk_ir56_overseas_concern_v
      WHERE  assignment_id = c_assignment_id
      AND    tax_reporting_year = p_reporting_year;

    os_rec os_info%ROWTYPE;

    e_More_Than_1_Overseas_conc Exception;

    p_Value Varchar2(240);

 Begin

    OPEN os_info(g_assignment_id);
    FETCH os_info into os_rec;
    If os_info%FOUND Then
       archive_item('X_HK_OVERSEAS_CONCERN',g_assignment_action_id,1);
       archive_item('X_HK_OVERSEAS_AMOUNT',g_assignment_action_id,os_rec.overseas_amount_message);
       archive_item('X_HK_OVERSEAS_NAME',g_assignment_action_id,os_rec.overseas_name);
       archive_item('X_HK_OVERSEAS_ADDRESS',g_assignment_action_id,os_rec.overseas_address);
    Else
       archive_item('X_HK_OVERSEAS_CONCERN',g_assignment_action_id,0);
       archive_item('X_HK_OVERSEAS_AMOUNT',g_assignment_action_id,NULL);
       archive_item('X_HK_OVERSEAS_NAME',g_assignment_action_id, NULL);
       archive_item('X_HK_OVERSEAS_ADDRESS',g_assignment_action_id,NULL);
    End If;

    --* If the employee is having more than 1 overseas concrens then archive message
    --* need to be populated but rest the record need to be archived
    FETCH os_info into os_rec;
    If os_info%FOUND Then
       --* If the message is not pupulated for Quarter then only archive the
       --* message for overseas concern.We can have only one message per employee
       If g_error_in_quarter = FALSE Then
          g_archive_message := g_assignment_action_id||':Employee number '
		              ||g_employee_number||' has multiple overseas concern details';
       End If;
    End If;
    CLOSE os_info;
  Exception
     When Others Then
	If os_info%ISOPEN Then
	   CLOSE os_info;
        End If;
        hr_utility.set_location('Error in archive_quarter_details ',99);
        RAISE;
  End Archive_Overseas_Details;

  Procedure Archive_Excep_Error_dtls(
		p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     		p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
     		p_reporting_year        IN Varchar2)
  IS
    CURSOR ir56_Employer_info
      	(c_legal_entity_id  hr_organization_units.organization_id%TYPE,
	 c_reporting_year   Varchar2 )
    IS
	SELECT DISTINCT
	       hou.name 			employer_name,
	       hoi.org_information1 		employer_tfn,
	       p_reporting_year  		reporting_year
        FROM   hr_organization_information 	hoi,
               hr_organization_units 		hou
        WHERE  hoi.org_information_context = 'HK_LEGAL_EMPLOYER'
        AND    hoi.organization_id = hou.organization_id
        AND    hoi.organization_id = c_legal_entity_id ;

    	employer_rec ir56_employer_info%ROWTYPE;

    CURSOR ir56_Employee_info
      	(c_assignment_id  pay_assignment_actions.assignment_id%TYPE,
       	c_reporting_year  Varchar2 )
    IS
	SELECT  DISTINCT
	        papf.national_identifier 			hk_id_card_no,
	 	DECODE(papf.marital_status, 'M',
                       DECODE(sex, 'F', NVL(previous_last_name, last_name), last_name)
		      ,last_name)				last_name,
       		TRIM(papf.first_name||' '||papf.middle_names) 	other_name
	FROM   	per_people_f 		        papf,
       		per_assignments_f 		paaf,
		per_periods_of_service    	pps
	WHERE  	paaf.person_id = papf.person_id
	AND    	TO_DATE('31-03-'|| c_reporting_year, 'DD-MM-YYYY')
       		BETWEEN   paaf.effective_start_date and paaf.effective_end_date
	AND    	TO_DATE('31-03-'|| c_reporting_year, 'DD-MM-YYYY')
	   	BETWEEN   papf.effective_start_date and papf.effective_end_date
	AND    	papf.business_group_id = p_business_group_id
	AND    	paaf.assignment_id = c_assignment_id
    	AND	pps.person_id = paaf.person_id
        AND     pps.period_of_service_id = paaf.period_of_service_id /* Bug No : 3059915 */
	AND    	TO_DATE('31-03-'||c_reporting_year, 'DD-MM-YYYY')
	   	BETWEEN pps.date_start
	   	AND NVL(pps.actual_termination_date,TO_DATE('31-12-4712','dd-mm-yyyy'));

       employee_rec  ir56_Employee_info%ROWTYPE;

   TYPE
	archive_rec IS RECORD (item_name  Varchar2(100),
			       item_value Varchar2(100));
   TYPE
	archive_tab IS TABLE OF archive_rec INDEX BY BINARY_INTEGER;

   tab_exception archive_tab;

   tab_count 	Number := 1;
   tab_index 	Number := 1;

   e_employer_notfound  Exception;
   e_employee_notfound  Exception;
Begin

    OPEN  ir56_Employer_info(p_legal_entity_id, p_reporting_year);
    FETCH ir56_Employer_info into employer_rec;

    If ir56_Employer_info%FOUND Then
        --------------------------------------------
    	--* Prepare employer/employee data to arhive
        --------------------------------------------
      --*
    	tab_exception(1).item_name  := 'X_HK_EMPLOYER_TFN';
    	tab_exception(1).item_value := employer_rec.employer_tfn;
      --*
	tab_exception(2).item_name  := 'X_HK_EMPLOYER_NAME';
    	tab_exception(2).item_value := employer_rec.employer_name;
      --*
    	tab_exception(3).item_name  := 'X_HK_REPORTING_YEAR';
    	tab_exception(3).item_value := employer_rec.reporting_year;

        OPEN   ir56_Employee_info(g_assignment_id,p_reporting_year);
        FETCH  ir56_Employee_info INTO employee_rec ;
	If ir56_Employee_info%FOUND Then
        --*
    	   tab_exception(4).item_name  := 'X_HK_LAST_NAME';
    	   tab_exception(4).item_value := employee_rec.last_name;
        --*
	   tab_exception(5).item_name  := 'X_HK_OTHER_NAMES';
    	   tab_exception(5).item_value := employee_rec.other_name;
        --*
    	   tab_exception(6).item_name  := 'X_HK_HKID';
    	   tab_exception(6).item_value := employee_rec.hk_id_card_no;

   	   --* Archive the details prepared above
       	   For tab_count in 1..tab_exception.COUNT
           LOOP
              If tab_exception.EXISTS(tab_count) Then
	         archive_item(tab_exception(tab_count).item_name,
                      g_assignment_action_id,
		      tab_exception(tab_count).item_value);
               End If;
           END LOOP;
        Else
   	   CLOSE ir56_Employee_info;
	   RAISE e_employee_notfound;
        End If;
     Else
       CLOSE  ir56_Employer_info;
       RAISE  e_employer_notfound;
     End If;

     CLOSE ir56_Employee_info;
     CLOSE ir56_Employer_info;

  Exception
     When e_employer_notfound then
         hr_utility.set_location('From Archive_excp:No employer Details found ',20);
     When e_employee_notfound then
         hr_utility.set_location('From Archive_excp:No employee Details found  ',20);
     When Others Then
	If ir56_Employer_info%ISOPEN Then
	   CLOSE ir56_Employer_info;
        End If;
	If ir56_Employee_info%ISOPEN Then
	   CLOSE ir56_Employee_info;
        End If;
        hr_utility.set_location('Error in archive_employee_details ',99);
        RAISE;
  End Archive_Excep_Error_dtls;


  --------------------------------------------------
  --* This function validates
     --* Person is manually excluded
  --------------------------------------------------

  Function Validate_Employee(p_reporting_year IN Varchar2)  Return Number
  IS

   Cursor Get_ManualExclusion(p_assignment_id per_all_assignments_f.assignment_id%TYPE)
   IS
   SELECT pap.employee_number
   FROM   per_assignments_f  a,
          hr_soft_coding_keyflex  sck,
          per_people_f            pap
   WHERE  a.assignment_id = p_assignment_id
   AND    a.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
   AND    pap.person_id = a.person_id
   AND    TO_DATE('31/03'||p_reporting_year,'DD/MM/YYYY')
          BETWEEN a.effective_start_date AND a.effective_end_date
   AND    NVL(sck.segment3, 'Y')  = 'N';


    l_employee_number per_all_people_f.employee_number%TYPE;

  Begin
      --* Find whether person is manually excluded
      OPEN  Get_ManualExclusion(g_assignment_id);
      FETCH Get_ManualExclusion INTO l_employee_number;
      If Get_ManualExclusion%FOUND Then
         g_employee_number := l_employee_number;
         g_archive_message := g_assignment_action_id||':Employee number '
		    ||g_employee_number||' has been manually excluded';
         CLOSE Get_ManualExclusion;
         RETURN 0;
      End If;

      CLOSE Get_ManualExclusion; /*Bug 2805822*/
      RETURN 1;
  Exception
      When Others Then
        NULL;
  End Validate_Employee;


  PROCEDURE Archive_Info
  (
     p_business_group_id     IN hr_organization_units.business_group_id%TYPE,
     p_legal_entity_id       IN hr_organization_units.organization_id%TYPE,
     p_reporting_year        IN Varchar2)
  IS
    res Number;
  Begin
     ----------------------------------------------------------------
     --* Validate_Employee checks whether the emplyee is manually
     --* excluded.
     --* If so then message is set in HK_ARCHIVE_MESSAGE it
     --* returns value 0 and the assignment is not processed.
     --* Note : For employees having more than 2 Quartyers
     --* and more than 1 overseas concerns message is still
     --* populated in HK_ARCHIVE_MESSAGE but the assignment is
     --* not prevented from the archival.So these cases are not handled
     --* in this functions . They are handled in there respective procs
     ------------------------------------------------------------------


     res := Validate_Employee(p_reporting_year);
     If res = 1 Then
        --* Archive Employer details calls Archive_Employee_Details internally
        g_archive_message := NULL;
	Archive_Employer_details(
			      p_business_group_id,
			      p_legal_entity_id,
			      p_reporting_year) ;
        Archive_Balance_details(
			     p_business_group_id,
			     p_legal_entity_id,
			     p_reporting_year) ;
        Archive_Quarter_details(
			     p_business_group_id,
			     p_legal_entity_id,
			     p_reporting_year) ;
        Archive_Overseas_details(
			      p_business_group_id,
			      p_legal_entity_id,
			      p_reporting_year) ;

        archive_item('X_HK_SHEET_NO', g_assignment_action_id,0);

      	archive_item('X_HK_ARCHIVE_MESSAGE',
                      g_assignment_action_id,
		      g_archive_message);

     Else
        --* Archive only the details needed to print on the
        --* exception listing report when the employee is manually excluded
	--* 1) employer TFN 2) employer name 3) reporting year 4) employee last name
        --* 5) employee other names 6) employee hkid
         Archive_Excep_Error_dtls(
			      p_business_group_id,
			      p_legal_entity_id,
			      p_reporting_year) ;
      	archive_item('X_HK_ARCHIVE_MESSAGE',
                      g_assignment_action_id,
		      g_archive_message);

     End if;
  End archive_info;

  ------------------------------------------------------------------------
  -- SELECTs the SRS parameters for the archive and calls other PROCEDUREs
  -- to archive the data in groups because depending on the data,
  -- different parameters are required.
  ------------------------------------------------------------------------

  PROCEDURE archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE,
     p_effective_date        in date)
  IS
     v_person_id              per_all_people_f.person_id%TYPE;
     v_assignment_id          per_all_assignments_f.assignment_id%TYPE;
     v_business_group_id      hr_organization_units.business_group_id%TYPE;
     v_legal_entity_id        pay_assignment_actions.tax_unit_id%TYPE;
     v_reporting_year         varchar2(4);
     v_archive_date           pay_payroll_actions.effective_date%TYPE;

    CURSOR archive_parameters
      (c_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE)
    IS
      SELECT paa.person_id,
             pac.assignment_id,
             pay_core_utils.get_parameter('BUSINESS_GROUP_ID',ppa.legislative_parameters),
             pay_core_utils.get_parameter('LEGAL_ENTITY_ID',ppa.legislative_parameters),
             pay_core_utils.get_parameter('REPORTING_YEAR',ppa.legislative_parameters),
             effective_date
      FROM   pay_payroll_actions    ppa,
             pay_assignment_actions pac,
             per_assignments_f  paa
      WHERE  pac.assignment_action_id = c_assignment_action_id
      AND    ppa.payroll_action_id    = pac.payroll_action_id
      AND    paa.assignment_id        = pac.assignment_id;

   e_No_Assignment_Found Exception;

  Begin
     hr_utility.set_location('pyhkirar: Start of archive_code',10);

     OPEN archive_parameters (p_assignment_action_id);
     FETCH archive_parameters INTO v_person_id,
    				v_assignment_id,
    				v_business_group_id,
    				v_legal_entity_id,
    				v_reporting_year,
    				v_archive_date;
     If archive_parameters%FOUND Then
        hr_utility.set_location('pyhkirar: Person Id: ' || to_char(v_person_id) ,100);

        --* set the global value for assignment_id
        g_assignment_id := v_assignment_id;

        --* set the global value for business_group_id
        g_business_group_id := v_business_group_id;

        --* set the global value for assignment_action_id
        g_assignment_action_id := p_assignment_action_id;

        If g_assignment_id IS NOT NULL Then
       	   Archive_Info(v_business_group_id,v_legal_entity_id, v_reporting_year);
        Else
           CLOSE archive_parameters;
           RAISE e_No_Assignment_Found;
        End if;
     End If;

     CLOSE archive_parameters;

     hr_utility.set_location('pyhkirar: End of archive_code',20);
  Exception
     When e_No_Assignment_Found Then
	hr_utility.set_location('Exception: ARCHIVE_CODE,:No assignment id for assignment action id '||
					p_assignment_action_id,20);
     When Others Then
	If archive_parameters%ISOPEN Then
	   CLOSE archive_parameters;
        End If;
        hr_utility.set_location('Error in archive_code ',99);
        RAISE;
  End archive_code;


  ---------------------------------------------------------------------------
  -- Calls the archive utility to actually perform the archive of the item.
  ---------------------------------------------------------------------------

  PROCEDURE archive_item
     (p_user_entity_name      IN ff_user_entities.user_entity_name%TYPE,
      p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE,
      p_archive_value         IN ff_archive_items.value%TYPE)
  IS
     v_user_entity_id         ff_user_entities.user_entity_id%TYPE;
     v_archive_item_id        ff_archive_items.archive_item_id%TYPE;
     v_object_version_number  ff_archive_items.object_version_number%TYPE;
     v_some_warning           boolean;

  CURSOR user_entity_id(c_user_entity_name ff_user_entities.user_entity_name%TYPE)
  IS
     SELECT user_entity_id
     FROM   ff_user_entities
     WHERE  user_entity_name = c_user_entity_name;

  Begin
     hr_utility.set_location('Start of archive_item',10);

     OPEN user_entity_id (p_user_entity_name);
     FETCH user_entity_id into v_user_entity_id;
     If user_entity_id%FOUND Then

        ff_archive_api.create_archive_item
    	    (p_validate              => false                    -- boolean  in default
    	    ,p_archive_item_id       => v_archive_item_id        -- number   out
    	    ,p_user_entity_id        => v_user_entity_id         -- number   in
    	    ,p_archive_value         => p_archive_value          -- varchar2 in
    	    ,p_archive_type          => 'AAP'                    -- varchar2 in default
    	    ,p_action_id             => p_assignment_action_id   -- number   in
    	    ,p_legislation_code      => 'HK'                     -- varchar2 in
    	    ,p_object_version_number => v_object_version_number  -- number   out
    	    ,p_context_name1         => 'ASSIGNMENT_ACTION_ID'   -- varchar2 in default
    	    ,p_context1              => p_assignment_action_id   -- varchar2 in default
    	    ,p_some_warning          => v_some_warning);         -- boolean  out

    	hr_utility.set_location('End of archive_item',20);
    Else
	hr_utility.set_location('User entity not found :'||p_user_entity_name,20);
    End If;
    CLOSE user_entity_id;

  Exception
     When Others Then
	If user_entity_id%ISOPEN Then
	   CLOSE user_entity_id;
        End If;
        hr_utility.set_location('Error in archive_item ',99);
        RAISE;
  End archive_item;

  ------------------------------
  -- [ Submit the report ]
  ------------------------------
  FUNCTION SUBMIT_REPORT
  (p_archive_or_magtape    in varchar2) RETURN Number
  IS
  l_count                NUMBER := 0;
  l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
  l_archive_action_id    pay_payroll_actions.payroll_action_id%TYPE;

  l_number_of_copies     NUMBER := 0;/*Reverted fix for 2810178 */
  l_request_id           NUMBER := 0;
  l_print_return         BOOLEAN;
  l_report_short_name    varchar2(30);

  l_formula_id   number ;

  l_error_text          varchar2(255) ;
  e_missing_formula     exception ;
  e_submit_error        exception ;

  -- Cursor to get the report print options.

  cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
    SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;

  rec_print_options  csr_get_print_options%ROWTYPE;

  cursor get_archive_id is
          select distinct ppa3.payroll_action_id
          from
           pay_payroll_actions ppa,   -- Magtape payroll action
           pay_payroll_actions ppa2,  -- Report payroll action
           pay_payroll_actions ppa3  -- Archive payroll action
           where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
           and    ppa2.payroll_action_id =pay_core_utils.get_parameter('REPORT_ACTION_ID', ppa.legislative_parameters)
           and    ppa3.payroll_action_id =pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa2.legislative_parameters);




begin

   -- Get all of the parameters needed to submit the report. Parameters defined
   -- in the concurrent program definition are passed through here by the PAR
   -- process. End the loop by the exception clause because we don't know
   -- what order the parameters will be in.

   -- Default the parameters in case they are not found.
  hr_utility.set_location('Submit report called',1);

  l_archive_action_id := 0;

  Begin
     LOOP
        l_count := l_count + 1;
        if pay_mag_tape.internal_prm_names(l_count) = 'TRANSFER_PAYROLL_ACTION_ID' then
           if  p_archive_or_magtape = 'MAGTAPE' then
              OPEN get_archive_id;
              FETCH get_archive_id into l_archive_action_id;
           else
              l_archive_action_id := to_number(pay_mag_tape.internal_prm_values(l_count));
           end if;
        end if;
     END LOOP;
  Exception
     When no_data_found then
        hr_utility.set_location('No data found',1);
        NULL;
     When value_error then
        hr_utility.set_location('Value error',1);
        NULL;
  End;
  -- Default the number of report copies to 0.
  l_number_of_copies := 0;/*Reverted fix for 2810178 */
  -- Set up the printer options.

  OPEN  csr_get_print_options(l_archive_action_id);
  FETCH csr_get_print_options INTO rec_print_options;
  CLOSE csr_get_print_options;

  hr_utility.set_location('fnd_request.set_print_options',1);

/*Reverted fix for 2810178 */
  l_print_return := fnd_request.set_print_options
                    (printer        => rec_print_options.printer,
                     style          => rec_print_options.print_style,
                     copies         => l_number_of_copies,
                     save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                     print_together => 'N');

  l_report_short_name := 'PAYHKCTL';

  -- Submit the report

  Begin

     -- Need to supply the parameters with keywords because it's a postscript report
     -- and the option version=2.0b set in the SRS definition uses a keyword, hence

     hr_utility.set_location('fnd_request.submit_request',1);

     l_request_id := fnd_request.submit_request
            (application => 'PAY',
             program     => l_report_short_name,
             argument1   => 'P_ARCHIVE_ACTION_ID='||l_archive_action_id,
             argument2   => 'P_ARCHIVE_OR_MAGTAPE='||p_archive_or_magtape,
             argument3   => 'P_BUSINESS_GROUP_ID='||g_business_group_id);

    -- If an error submitting report then get message and put to log.

    hr_utility.set_location('l_request_id : '||l_request_id,1);

    If l_request_id = 0 Then
      RAISE e_submit_error;
    End If;
    RETURN l_request_id;
  Exception
     When e_submit_error then
       ROLLBACK ;
       raise_application_error(-20001, 'Could Not submit report') ;
       Return 0;
    When others then
       ROLLBACK;
       raise_application_error(-20001, sqlerrm) ;
       Return 0;
  End;

End submit_report;

End pay_hk_ir56_archive;

/
