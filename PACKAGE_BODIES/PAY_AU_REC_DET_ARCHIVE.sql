--------------------------------------------------------
--  DDL for Package Body PAY_AU_REC_DET_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_REC_DET_ARCHIVE" as
/* $Header: pyaurecd.pkb 120.15.12010000.4 2009/12/22 07:18:27 dduvvuri ship $*/
/*
*** ------------------------------------------------------------------------+
*** Program:     pay_au_rec_det_archive (Package Body)
***
*** Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 25 DEC 03  avenkatk    1.0     3064269  Initial Version
*** 29 DEC 03  avenkatk    1.1     3064269  Changed cursor c_element_details
*** 08 JAN 04  avenkatk    1.2     3064269  Modified spawn_archive_reports.
***                                         and cursors.
*** 09 JAN 04  avenkatk    1.3     3064269  Modified assignment_action_code
***                                         to archive action_sequence.
*** 25 MAR 04  avenkatk    1.4     3531704  Modified Cursor c_payment_summary_details
***                                         Added private function get_fin_year_code
*** 25 MAR 04  avenkatk    1.5     3531704  Removed to_char for compatibility with
***                                         8i DB.
*** 16 APR 04   punmehta   1.6     3538810   Modified cursors to include rehire cases
*** 16 APR 04   punmehta   1.7     3538810   Modified for GSCC standards
*** 16 APR 04   punmehta   1.8     3538810   Modified for GSCC standards
*** 18 APR 04   punmehta   1.9     3538810   Removed initialization done in BEGIN of packge and added NVL
***                                          to global variables g_prev_assignment_id , g_def_bal_populted
*** 29 APR 04   avenkatk   1.10    3598558   Modified cursor csr_assignment_payroll_period to
***                                          pick runs when an assignment update is done.
*** 11 MAY 04   punmehta   1.11    3622295   Replaced Assignmetn_status_type_id check with per_system_Status check
*** 13 MAY 04   avenkatk   1.12    3627293   Modified Balances archival - Archive values only for Master action ID.
*** 07 JUN 04   abhkumar   1.13    3662449   Modfied the archive and assignment code to include assignment statuses SUSPEND and END.
*** 09 AUG 04   abhkumar   1.17    2610141   Legal Employer enhancement Changes.
*** 05 OCT 04   ksingla    1.18    3953702   Modified cursor c_employee_details for Grade display - Archived Grade Name
***                                          fetched from table per_grades_tl
*** 06 DEC 04   abhkumar   1.19    3953706   Mainline fix for Earnings Reporting enhancement.
*** 06 DEC 04   srrajago   1.20    4045910   Modified the cursor 'c_element_details' to handle the issue raised when user-defined secondary classification
***                                          is attached to an element (Distinct clause introduced).
*** 13 DEC 04   JLin       1.21    3953615   Added the call pay_au_reconciliation.check_report_parameters to
***                                          spawn_archive_reports to check the validation for the parameters
*** 29-DEC-04   abhkumar   1.22    4040688   Modified CURSOR csr_assignment_payroll_period so that
***                                          assignment IS reported FOR the latest payroll AS ON END DATE OF report.
***                                          Modified archive_code TO call YTD balances ONLY FOR the last RUN IN the period
***                                          Modified CURSOR c_employee_details TO FETCH the latest Legal Employer OF the assignment
*** 30-DEC-04   abhkumar   1.23    4040688   Modified the cursor csr_get_max_asg_dates and csr_get_max_asg_action to improve performance.
***                                          Modified the logic of archiving YTD balances. Two new contexts introduced
***                                          AU_BALANCE_RECON_DETAILS_RUN and AU_BALANCE_RECON_DETAILS_YTD.
*** 06-JAN-05   abhkumar   1.24    4099317   Modified assignment CURSOR - added CHECK OF action_status = 'C'
***                                          Modified element details cursor - added CHECK OF action_status = 'C' on
***                                          pay_assignment_actions table
*** 13-JAN-05   avenkatk   1.25   4116833    Set the Report Request number of copies to be read from Archive Request.
*** 21-JAN-05   abhkumar   1.26   4132525    Modified cursor c_employee_details to archive organization name, payroll name and Legal Employer
***                                          name. Sorting of records in reports to be done on basis of Org. names, Payroll names, Legal Employer names.
*** 25-JAN-05   abhkumar   1.27   4142159    Introduced Parameter P_DELETE_ACTIONS.
*** 08-FEB-05   ksingla    1.28   4161540    Modified cursors csr_assignment_org_period , csr_assignment_legal_period,
***                                           csr_assignment_payroll_period ,csr_assignment_period ,csr_assignment_default_period.
***                                            Removed join for per_assignment_status_types.
*** 09-FEB-05   ksingla    1.29   4161540     Modified cursors csr_assignment_org_period , csr_assignment_legal_period,
***                                           csr_assignment_payroll_period ,csr_assignment_period ,csr_assignment_default_period.
***                                           Modified the subquery for the check of termination in the same way as in pay_au_payment_summary .
*** 11-FEB-05   abhkumar   1.30   4132149    Modified initialisation_code to initialise the global variables for legislative parameters.
*** 13-APR-2005 abhkumar   1.31   3935471    Modified element_detail cursor to get the tax unit id of master assignment action id.
*** 05-MAY-2005 abhkumar   1.32   3935471    Modified file to put proper comments.
*** 25 May 05 abhkumar     1.33   4688872    Modified assignment action code to fix for cases where employee has a nulled payroll
***                                          at the end of year
*** 27 Feb 06 ksingla      1.34   5063359    Modified Cursor c_element_details for employer charges
*** 19 Oct 06 ksingla      1.35   5461557    Modified cursor c_element_details to get rate and hours and group by on rate.
*** 29-Oct-06 hnainani     1.36   5603254    Added  Function get_element_payment_hours to fetch hours in c_element_details.
*** 16-Nov-06 abhargav     115.40 5603254    Modified cursor c_element_details to remove joins for pay_input_values_f piv2 and pay_run_result_values prrv2.
*** 13-Feb-06 priupadh     115.41  N/A       Version for restoring Triple Maintanence between 11i-->R12(Branch) -->R12(MainLine)
*** 02-MAR-07 hnainani     1.42   5599310   Added  Function get_element_payment_rate to fetch rate in c_element_details.
-- 13-MAR-07 hnainani  115.43 5599310   Added Debug messages to function get_element_payment_rate
***11-Jun-07 vamittal      115.44 6109668   Modified cursor get_rate_input_value in function get_element_payment_rate
***                                         to fetch the rate input having UOM as Number from input value
***29-Jun-07 vamittal      115.45 6109668   Modified cursor get_rate_input_value in function get_element_payment_rate
***                                         to fetch the rate input having UOM as Number or Money or Integer from input value
***02-Aug-07 skshin        115.46 5987877   Added check in Function get_element_payment_hours for multiple Hours Input
***26-Feb-08 vdabgar       115.47 6839263   Modified proc spawn_archive_reports,csr_params and csr_report_params cursors
***                                         to call the concurrent programs accordingly.
***18-Mar-08  avenkatk     115.48 6839263   Backed out changes from assignment_action_code, initialization_code
***21-Mar-08  avenkatk     115.49 6839263   Added Logic to set the OPP Template options for PDF output
***13-Feb-09  mdubasi      115.50 7590936   Replaced secure view hr_organization_units with hr_all_organization_units
***                                         in the cursor c_employee_details
***11-Dec-09  dduvvuri     115.51 9113084   Added RANGE_PERSON_ID for Payroll Reconciliation Detail Report
***22-Dec-09  dduvvuri     115.52 9113084   Restructured the logic in assignment_action_code to use all Range
***                                         Cursors at one place and Old cursors at one place for code clarity
*** ------------------------------------------------------------------------+
*/

  g_arc_payroll_action_id           pay_payroll_actions.payroll_action_id%type;
  g_business_group_id		    hr_all_organization_units.organization_id%type;
  g_prev_assignment_id              number;
  g_def_bal_populted                varchar2(1);

  g_debug boolean ;

  g_package                         constant varchar2(60) := 'pay_au_recon_det_archive.';  -- Global to store package name for tracing.
  g_end_date                        date;
  g_start_date                        date;   --Bug#3662449

  --------------------------------------------------------------------
  -- Name  : range_code
  -- Type  : Proedure
  -- Access: Public
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --
  --------------------------------------------------------------------

  procedure range_code
  (p_payroll_action_id  in  pay_payroll_actions.payroll_action_id%type
  ,p_sql                out NOCOPY varchar2
  ) is

  l_procedure         varchar2(200) ;

  begin

    g_debug :=hr_utility.debug_enabled ;

    if g_debug then
     l_procedure := g_package||'range_code';
     hr_utility.set_location('Entering '||l_procedure,1);
    end if ;

    -- Archive the payroll action level data  and EIT defintions.
    --  sql string to SELECT a range of assignments eligible for archival.
    p_sql := ' select distinct p.person_id'                             ||
             ' from   per_people_f p,'                                  ||
                    ' pay_payroll_actions pa'                           ||
             ' where  pa.payroll_action_id = :payroll_action_id'        ||
             ' and    p.business_group_id = pa.business_group_id'       ||
             ' order by p.person_id';

    if g_debug then
      hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;

  end range_code;

/*
    Bug 9113084 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
*/

FUNCTION range_person_on
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'AU_REC_DET_ARCHIVE'
  and    map.report_format = 'AU_REC_DET_ARCHIVE'
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID';

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);

BEGIN

    g_debug := hr_utility.debug_enabled;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;

  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     IF g_debug THEN
         hr_utility.set_location('Range Person = True',1);
     END IF;
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;

  --------------------------------------------------------------------+
  -- Name  : check_termination
  -- Type  : function
  -- Access: Public
  -- This function is to return the assignment status
  --------------------------------------------------------------------+
/*Bug#3662449 function added to check for assignment status*/
function check_termination
  (p_sys_status per_assignment_status_types.per_system_status%TYPE,
   p_emp_type varchar2)
  return varchar2
  is
    l_status varchar2(10);
  begin
     l_status := 'FALSE';
     if p_emp_type = 'Y' and p_sys_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN') THEN
       l_status := 'TRUE';
     elsif p_emp_type = 'N' and p_sys_status = 'TERM_ASSIGN' THEN
       l_status :=  'TRUE';
     elsif p_emp_type = '%' and p_sys_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN','TERM_ASSIGN') THEN
       l_status := 'TRUE';
     END IF;
  return l_status;

end check_termination;


  --------------------------------------------------------------------+
  -- Name  : initialization_code
  -- Type  : Proedure
  -- Access: Public
  -- This procedure is used to set global contexts
  --------------------------------------------------------------------+

procedure initialization_code
  (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type)
  is
    l_procedure               varchar2(200) ;

/*Bug 4132149 - Modification begins here*/
  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('PAY',legislative_parameters)        payroll_id,
                   pay_core_utils.get_parameter('ORG',legislative_parameters)           org_id,
                   pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('PACTID',legislative_parameters)        pact_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   pay_core_utils.get_parameter('ASG',legislative_parameters) assignment_id,
                   pay_core_utils.get_parameter('SO1',legislative_parameters)   sort_order_1,
                   pay_core_utils.get_parameter('SO2',legislative_parameters)   sort_order_2,
                   pay_core_utils.get_parameter('SO3',legislative_parameters)   sort_order_3,
                   pay_core_utils.get_parameter('SO4',legislative_parameters)   sort_order_4,
                   to_date(pay_core_utils.get_parameter('PEDATE',legislative_parameters),'YYYY/MM/DD') period_end_date,
                   pay_core_utils.get_parameter('YTD_TOT',legislative_parameters)      ytd_totals,
                   pay_core_utils.get_parameter('ZERO_REC',legislative_parameters)    zero_records,
                   pay_core_utils.get_parameter('NEG_REC',legislative_parameters)     negative_records,
                   decode(pay_core_utils.get_parameter('EMP_TYPE',legislative_parameters),'C','Y','T','N','%') employee_type,
                   pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions  /*Bug# 4142159*/
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;

 --------------------------------------------------------------------+
  -- Cursor      : csr_period_date_earned
  -- Description : Fetches Date Earned for a given payroll
  --               run.
  --------------------------------------------------------------------+
      CURSOR csr_period_date_earned(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT ppa.date_earned
	FROM pay_payroll_actions ppa
        WHERE
	ppa.payroll_action_id = c_payroll_action_id;

/*Bug 4132149 - Modification ends here*/

  begin

    g_debug :=hr_utility.debug_enabled ;
    if g_debug then
        l_procedure := g_package||'initialization_code';
        hr_utility.set_location('Entering '||l_procedure,1);
    end if;


/*Bug 4132149 - Modification begins here*/

    -- initialization_code to to set the global tables for EIT
        -- that will be used by each thread in multi-threading.

    g_arc_payroll_action_id := p_payroll_action_id;

    -- Fetch the parameters by user passed into global variable.

        OPEN csr_params(p_payroll_action_id);
     	FETCH csr_params into g_parameters;
       	CLOSE csr_params;


    if g_debug then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.payroll_id..............= ' || g_parameters.payroll_id,30);
        hr_utility.set_location('g_parameters.org_id................= ' || g_parameters.org_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || g_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || g_parameters.end_date,30);
        hr_utility.set_location('g_parameters.period_end_date.........= ' || g_parameters.period_end_date,30);
        hr_utility.set_location('g_parameters.pact_id..............= ' || g_parameters.pact_id,30);
        hr_utility.set_location('g_parameters.employee_type..........= '||g_parameters.employee_type,30);
        hr_utility.set_location('g_parameters.sort_order1..........= '||g_parameters.sort_order_1,30);
        hr_utility.set_location('g_parameters.sort_order2..........= '||g_parameters.sort_order_2,30);
        hr_utility.set_location('g_parameters.sort_order3..........= '||g_parameters.sort_order_3,30);
        hr_utility.set_location('g_parameters.sort_order4..........= '||g_parameters.sort_order_4,30);
	hr_utility.set_location('g_parameters.delete_actions..........= '||g_parameters.delete_actions,30);/*Bug# 4142159*/
    end if;


    g_business_group_id := g_parameters.business_group_id ;

    -- Set end date variable .This value is used to fetch latest assignment details of
    -- employee for archival.In case of archive start date/end date - archive end date
    -- taken and pact_id/period_end_date , period end date is picked.

    if g_parameters.end_date is not null
    then
        g_end_date := g_parameters.end_date;
	g_start_date := g_parameters.start_date;
    else
        if g_parameters.period_end_date is not null
        then
	    open csr_period_date_earned(g_parameters.pact_id);
	    fetch csr_period_date_earned into g_start_date;
            close csr_period_date_earned;
            g_end_date  := g_parameters.period_end_date;
        else
	    g_start_date := to_date('1900/01/01','YYYY/MM/DD');
            g_end_date  := to_date('4712/12/31','YYYY/MM/DD');
        end if;
    end if; /* End of outer if loop */

/*Bug 4132149 - Modification ends here*/

    pay_au_reconciliation_pkg.populate_defined_balance_ids('Y',g_parameters.legal_employer);

    if g_debug then
            hr_utility.set_location('Leaving '||l_procedure,1000);
    end if;

  exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
  end initialization_code;

  --------------------------------------------------------------------+
  -- Name  : assignment_Action_code
  -- Type  : Procedure
  -- Access: Public
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  -- This procedure gets the parameters given by user and restricts
  -- the assignments to be archived.
  -- it then calls hr_nonrun.insact to create an assignment action id
  -- it then archives Payroll Run assignment action id  details
  -- in pay_Action_information with context 'AU_ARCHIVE_ASG_DETAILS'
  -- for each assignment.
  -- There are 10 different cursors for choosing the assignment ids.
  -- Depending on the parameters passed,the appropriate cursor is used.
  --------------------------------------------------------------------+

procedure assignment_action_code
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type
  ,p_start_person      in per_all_people_f.person_id%type
  ,p_end_person        in per_all_people_f.person_id%type
  ,p_chunk             in number
  ) is

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_org_period
  -- Description : Fetches assignments when Organization,Archive
  --               Start Date and End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_org_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
       ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		hr_organization_units hou,
  		per_periods_of_service pps
--		,per_assignment_status_types past
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
  	and    hou.organization_id          = c_organization_id
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type   --4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_org_period
  -- Description : Fetches assignments when Organization,Archive
  --               Start Date and End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
  cursor rg_csr_assignment_org_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
       ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		hr_organization_units hou,
  		per_periods_of_service pps,
                pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number      = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
  	and    hou.organization_id          = c_organization_id
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type   --4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_org_run
  -- Description : Fetches assignments when Organization,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_org_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
      		hr_organization_units hou,
      		per_periods_of_service pps
      	where   ppa.payroll_action_id        = c_payroll_action_id
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                between c_start_person and c_end_person
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
      	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
      	and    hou.organization_id          = c_organization_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_org_run
  -- Description : Fetches assignments when Organization,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
  cursor rg_csr_assignment_org_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_organization_id    hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
      		hr_organization_units hou,
      		per_periods_of_service pps,
		pay_population_ranges ppr
      	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                = ppr.person_id
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
      	and    paaf.organization_id         = hou.organization_id
  	and    hou.business_group_id        = c_business_group_id
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
      	and    hou.organization_id          = c_organization_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_legal_period
  -- Description : Fetches assignments when Legal Employer,Archive
  --               Start Date and End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_legal_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
--		,per_assignment_status_types past
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paa.tax_unit_id              = c_legal_employer
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
	 and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --bug 4161540
	  and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_legal_period
  -- Description : Fetches assignments when Legal Employer,Archive
  --               Start Date and End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
  cursor rg_csr_assignment_legal_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk  number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paa.tax_unit_id              = c_legal_employer
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
	 and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --bug 4161540
	  and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_legal_run
  -- Description : Fetches assignments when Legal Employer,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+


    cursor csr_assignment_legal_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    paa.tax_unit_id              = c_legal_employer
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_legal_run
  -- Description : Fetches assignments when Legal Employer,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+

    cursor rg_csr_assignment_legal_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk number
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_legal_employer     hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id        = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    paa.tax_unit_id              = c_legal_employer
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

    --------------------------------------------------------------------+
    -- Cursor      : csr_assignment_payroll_period
    -- Description : Fetches assignments when Payroll,Archive Start
    --               Date and End Date is specified
    --------------------------------------------------------------------+

    cursor csr_assignment_payroll_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
       select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
--		per_assignment_status_types past
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
        AND    paaf.payroll_id              = c_payroll_id /*Bug 4040688*/
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type   --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date
               AND iipaf.payroll_id IS NOT NULL)  /*Bug 4688872*/
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

    --------------------------------------------------------------------+
    -- Bug         : 9113084
    -- Cursor      : rg_assignment_payroll_period
    -- Description : Fetches assignments when Payroll,Archive Start
    --               Date and End Date is specified
    -- Usage       : When Range Person is enabled
    --------------------------------------------------------------------+

    cursor rg_assignment_payroll_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
       select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number  = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    ppa1.effective_date  between c_archive_start_date and c_archive_end_date
        AND    paaf.payroll_id              = c_payroll_id
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type   --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date
               AND iipaf.payroll_id IS NOT NULL)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_payroll_run
  -- Description : Fetches assignments when Payroll,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

  cursor csr_assignment_payroll_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select      paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
       		per_periods_of_service pps
      	where   ppa.payroll_action_id        = c_payroll_action_id
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                between c_start_person and c_end_person
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
        and    ppa1.payroll_id              = c_payroll_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_payroll_run
  -- Description : Fetches assignments when Payroll,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+

  cursor rg_csr_assignment_payroll_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_payroll_id         pay_payroll_actions.payroll_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select      paa.assignment_action_id,
                paa.action_sequence,
          	   	paaf.assignment_id,
          	   	paa.tax_unit_id
           	from  	per_people_f pap,
      		per_assignments_f paaf,
      		pay_payroll_actions ppa,
      		pay_payroll_actions ppa1,
      		pay_assignment_actions paa,
       		per_periods_of_service pps,
		pay_population_ranges ppr
      	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id        = ppa.payroll_action_id
	and     ppr.chunk_number             = c_chunk
      	and     paa.assignment_id            = paaf.assignment_id
      	and     pap.person_id                = ppr.person_id
      	and     pap.person_id                = paaf.person_id
      	and     pap.person_id                = pps.person_id
      	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
      	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
      	and    ppa1.business_group_id       = ppa.business_group_id
      	and    ppa.business_group_id        = c_business_group_id
      	and    ppa1.action_type             in ('R','Q','I','B','V')
      	and    NVL(pap.current_employee_flag,'N') like c_employee_type
        and    ppa1.payroll_id              = c_payroll_id
      	and    ppa1.payroll_action_id       = c_pact_id
      	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_period
  -- Description : Fetches assignments when Assignment,Archive Start
  --               Date and End Date is specified
  --------------------------------------------------------------------+

   cursor csr_assignment_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
--		,per_assignment_status_types past
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.effective_date between c_archive_start_date and c_archive_end_date
	and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_period
  -- Description : Fetches assignments when Assignment,Archive Start
  --               Date and End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
   cursor rg_csr_assignment_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.effective_date between c_archive_start_date and c_archive_end_date
	and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  -------------------------------------------------------------------+
  -- Cursor      : csr_assignment_run
  -- Description : Fetches assignments when Assignment,Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

      cursor csr_assignment_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
    		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  -------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_run
  -- Description : Fetches assignments when Assignment,Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
      cursor rg_csr_assignment_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_assignment_id      per_all_assignments_f.assignment_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
    		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    paa.assignment_id            = c_assignment_id
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

    --------------------------------------------------------------------+
    -- Cursor      : csr_assignment_default_period
    -- Description : Fetches assignments when Archive Start date
    --               and End Date is specified
    --------------------------------------------------------------------+

      cursor csr_assignment_default_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
--		,per_assignment_status_types past
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date) --Bug# 3538810
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

    --------------------------------------------------------------------+
    -- Bug         : 9113084
    -- Cursor      : rg_assignment_default_period
    -- Description : Fetches assignments when Archive Start date
    --               and End Date is specified
    -- Usage       : When Range Person is enabled
    --------------------------------------------------------------------+
      cursor rg_assignment_default_period
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_archive_start_date         date
      ,c_archive_end_date           date
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    ppa1.effective_date   between c_archive_start_date and c_archive_end_date
        and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (c_archive_end_date)),1,'Y','N')) LIKE c_employee_type  --Bug 4161540
        and   paaf.effective_end_date = (select max(effective_end_date)
					From  per_assignments_f iipaf
					WHERE iipaf.assignment_id  = paaf.assignment_id
					and iipaf.effective_end_date >= c_archive_start_date
					and iipaf.effective_start_date <= c_archive_end_date)
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_assignment_default_run
  -- Description : Fetches assignments when Payroll Run
  --               and Period End Date is specified
  --------------------------------------------------------------------+

      cursor csr_assignment_default_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      ,c_start_person       per_all_people_f.person_id%type
      ,c_end_person         per_all_people_f.person_id%type
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps
  	where   ppa.payroll_action_id        = c_payroll_action_id
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                between c_start_person and c_end_person
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C' /*Bug 4099317*/
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;


  --------------------------------------------------------------------+
  -- Bug         : 9113084
  -- Cursor      : rg_csr_assignment_default_run
  -- Description : Fetches assignments when Payroll Run
  --               and Period End Date is specified
  -- Usage       : When Range Person is enabled
  --------------------------------------------------------------------+
      cursor rg_csr_assignment_default_run
      (c_payroll_action_id  pay_payroll_actions.payroll_action_id%type
      , c_chunk NUMBER
      ,c_employee_type      per_all_people_f.current_employee_flag%type
      ,c_business_group_id  hr_all_organization_units.organization_id%type
      ,c_period_end_date            date
      ,c_pact_id            pay_payroll_actions.payroll_action_id%type
      ) is
      select 	paa.assignment_action_id,
                paa.action_sequence,
      	   	paaf.assignment_id,
      	   	paa.tax_unit_id
       	from  	per_people_f pap,
  		per_assignments_f paaf,
  		pay_payroll_actions ppa,
  		pay_payroll_actions ppa1,
  		pay_assignment_actions paa,
  		per_periods_of_service pps,
		pay_population_ranges ppr
  	where   ppa.payroll_action_id        = c_payroll_action_id
	and     ppr.payroll_action_id = ppa.payroll_action_id
	and     ppr.chunk_number = c_chunk
  	and     paa.assignment_id            = paaf.assignment_id
  	and     pap.person_id                = ppr.person_id
  	and     pap.person_id                = paaf.person_id
  	and     pap.person_id                = pps.person_id
  	and     pps.period_of_service_id     = paaf.period_of_service_id
  	and     ppa1.date_earned between paaf.effective_start_date and paaf.effective_end_date
  	and     ppa1.date_earned between pap.effective_start_date  and pap.effective_end_date
  	and    ppa1.payroll_action_id       = paa.payroll_action_id
	AND    paa.action_status = 'C'
  	and    ppa1.business_group_id       = ppa.business_group_id
  	and    ppa.business_group_id        = c_business_group_id
  	and    ppa1.action_type             in ('R','Q','I','B','V')
  	and    NVL(pap.current_employee_flag,'N') like c_employee_type
  	and    ppa1.payroll_action_id       = c_pact_id
  	order  by paaf.assignment_id, paa.assignment_action_id, paa.tax_unit_id;

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('PAY',legislative_parameters)        payroll_id,
                   pay_core_utils.get_parameter('ORG',legislative_parameters)           org_id,
                   pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('PACTID',legislative_parameters)        pact_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   pay_core_utils.get_parameter('ASG',legislative_parameters) assignment_id,
                   pay_core_utils.get_parameter('SO1',legislative_parameters)   sort_order_1,
                   pay_core_utils.get_parameter('SO2',legislative_parameters)   sort_order_2,
                   pay_core_utils.get_parameter('SO3',legislative_parameters)   sort_order_3,
                   pay_core_utils.get_parameter('SO4',legislative_parameters)   sort_order_4,
                   to_date(pay_core_utils.get_parameter('PEDATE',legislative_parameters),'YYYY/MM/DD') period_end_date,
                   pay_core_utils.get_parameter('YTD_TOT',legislative_parameters)      ytd_totals,
                   pay_core_utils.get_parameter('ZERO_REC',legislative_parameters)    zero_records,
                   pay_core_utils.get_parameter('NEG_REC',legislative_parameters)     negative_records,
                   decode(pay_core_utils.get_parameter('EMP_TYPE',legislative_parameters),'C','Y','T','N','%') employee_type,
                   pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions  /*Bug# 4142159*/
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;

 --------------------------------------------------------------------+
  -- Cursor      : csr_period_date_earned
  -- Description : Fetches Date Earned for a given payroll
  --               run.
  --------------------------------------------------------------------+
      /*Bug#3662449 *********/
      CURSOR csr_period_date_earned(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT ppa.date_earned
	FROM pay_payroll_actions ppa
        WHERE
	ppa.payroll_action_id = c_payroll_action_id;


    cursor csr_next_action_id is
    select pay_assignment_actions_s.nextval
    from   dual;

    l_next_assignment_action_id       pay_assignment_actions.assignment_action_id%type;
    l_procedure               	      varchar2(200) ;
    i 				      number;

    l_action_information_id 	 	number;
    l_object_version_number		number;


begin
    i := 1;
    g_debug :=hr_utility.debug_enabled ;

    if g_debug then
        l_procedure := g_package||'assignment_action_code';
        hr_utility.set_location('Entering ' || l_procedure,1);
        hr_utility.set_location('Entering assignment_Action_code',302);
    end if;

    -- initialization_code to to set the global tables for EIT
        -- that will be used by each thread in multi-threading.

    g_arc_payroll_action_id := p_payroll_action_id;

    -- Fetch the parameters by user passed into global variable.

        OPEN csr_params(p_payroll_action_id);
     	FETCH csr_params into g_parameters;
       	CLOSE csr_params;


    if g_debug then
        hr_utility.set_location('p_payroll_action_id.........= ' || p_payroll_action_id,30);
        hr_utility.set_location('p_start_person..............= ' || p_start_person,30);
        hr_utility.set_location('p_end_person................= ' || p_end_person,30);
        hr_utility.set_location('g_parameters.business_group_id.........= ' || g_parameters.business_group_id,30);
        hr_utility.set_location('g_parameters.payroll_id..............= ' || g_parameters.payroll_id,30);
        hr_utility.set_location('g_parameters.org_id................= ' || g_parameters.org_id,30);
        hr_utility.set_location('g_parameters.legal_employer.........= ' || g_parameters.legal_employer,30);
        hr_utility.set_location('g_parameters.start_date..............= ' || g_parameters.start_date,30);
        hr_utility.set_location('g_parameters.end_date................= ' || g_parameters.end_date,30);
        hr_utility.set_location('g_parameters.period_end_date.........= ' || g_parameters.period_end_date,30);
        hr_utility.set_location('g_parameters.pact_id..............= ' || g_parameters.pact_id,30);
        hr_utility.set_location('g_parameters.employee_type..........= '||g_parameters.employee_type,30);
        hr_utility.set_location('g_parameters.sort_order1..........= '||g_parameters.sort_order_1,30);
        hr_utility.set_location('g_parameters.sort_order2..........= '||g_parameters.sort_order_2,30);
        hr_utility.set_location('g_parameters.sort_order3..........= '||g_parameters.sort_order_3,30);
        hr_utility.set_location('g_parameters.sort_order4..........= '||g_parameters.sort_order_4,30);
	hr_utility.set_location('g_parameters.delete_actions..........= '||g_parameters.delete_actions,30);/*Bug# 4142159*/
    end if;


    g_business_group_id := g_parameters.business_group_id ;

    -- Set end date variable .This value is used to fetch latest assignment details of
    -- employee for archival.In case of archive start date/end date - archive end date
    -- taken and pact_id/period_end_date , period end date is picked.

    if g_parameters.end_date is not null
    then
        g_end_date := g_parameters.end_date;
	g_start_date := g_parameters.start_date; --Bug#3662449
    else
        if g_parameters.period_end_date is not null
        then
	    open csr_period_date_earned(g_parameters.pact_id); --Bug#3662449
	    fetch csr_period_date_earned into g_start_date;
            close csr_period_date_earned;
            g_end_date  := g_parameters.period_end_date;
        else
	    g_start_date := to_date('1900/01/01','YYYY/MM/DD');  --Bug#3662449
            g_end_date  := to_date('4712/12/31','YYYY/MM/DD');
        end if;
    end if; /* End of outer if loop */


IF range_person_on THEN /* 9113084 - Use Range Person Cursors when RANGE_PERSON_ID is enabled */

    if g_parameters.org_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
                IF g_debug THEN
                      hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                END IF;
            FOR csr_rec in rg_csr_assignment_org_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.org_id,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 1 Org,Archive start date,end date */
             open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

              if g_debug then

                   hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                   hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                   hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                   hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);

              end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);


                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


            END LOOP;/* Loop 1 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop1 Org+Period....' || l_procedure,1000);
            end if;

       else
                 IF g_debug THEN
                    hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_org_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.org_id,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 2 Org,Pact_id and period end date*/
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


               END LOOP; /* Loop 2 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop2 ,Org + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Organization  */
    else      /* Not Org,check for others */

    if g_parameters.legal_employer is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
                IF g_debug THEN
                  hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                END IF;
            FOR csr_rec in rg_csr_assignment_legal_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.legal_employer,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 3 Leg Employer,Archive Start date,archive end date*/
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;
             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


            END LOOP;/* Loop 3 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop3.Legal Emp + period...' || l_procedure,1000);
            end if;

       else
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_legal_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.legal_employer,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 4 Leg employer,pact_id + period end date */
             open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


               END LOOP; /* Loop 4 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop4.Legal Emp + Run...' || l_procedure,1000);
            end if;
        end if; /* End of Inner Legal Employer  */
    else /* Not Org,Legal Emp Check others */

    if g_parameters.payroll_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
               IF g_debug THEN
                 hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
               END IF;
            FOR csr_rec in rg_assignment_payroll_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.payroll_id,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 5 Payroll, Archive start date,end date */
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


            END LOOP;/* Loop 5 */

            if g_debug then
            hr_utility.set_location('Leaving............Loop5 Payroll + Period....' || l_procedure,1000);
            end if;

       else
                  IF g_debug THEN
                    hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                  END IF;
               FOR csr_rec in rg_csr_assignment_payroll_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.payroll_id,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 6 Payroll, pact_id + period end date*/
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


               END LOOP; /* Loop 6 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop6 Payroll+ Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Payroll */
    else /* Not Org,Legal,Payroll check others */

    if g_parameters.assignment_id is not null
    then
         if g_parameters.start_date is not null and g_parameters.end_date is not null
            then
                   IF g_debug THEN
                     hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                   END IF;
                 FOR csr_rec in rg_csr_assignment_period(p_payroll_action_id,
                                                         p_chunk,
                                                         g_parameters.employee_type,
                                                         g_parameters.business_group_id,
                                                         g_parameters.assignment_id,
                                                         g_parameters.start_date,
                                                         g_parameters.end_date)
                 LOOP /*Loop 7 Assignment ,Archive start date,end date*/
                      open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

                  if g_debug then
                     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
                  end if;

                    -- Create the archive assignment actions
                     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


                 END LOOP;/* Loop 7 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop7. Asg + Period...' || l_procedure,1000);
                 end if;

            else
                     IF g_debug THEN
                        hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                     END IF;
                    FOR csr_rec in rg_csr_assignment_run(p_payroll_action_id,
                                                         p_chunk,
                                                         g_parameters.employee_type,
                                                         g_parameters.business_group_id,
                                                         g_parameters.assignment_id,
                                                         g_parameters.period_end_date,
                                                         g_parameters.pact_id)
                    LOOP /*Loop 8 Assignment Pact_id,Period end date */
                     open csr_next_action_id;
                     fetch  csr_next_action_id into l_next_assignment_action_id;
                     close csr_next_action_id;

                     if g_debug then
                     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
                     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
                     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
                     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
                     end if;

                    -- Create the archive assignment actions
                     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


                    END LOOP; /* Loop 8 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop8.Asg + Run...' || l_procedure,1000);
                 end if;
             end if; /* End of Inner Assignment */

    else

    /* Default Begins */

       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
              IF g_debug THEN
                hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
              END IF;
            FOR csr_rec in rg_assignment_default_period(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.start_date,
                                                 g_parameters.end_date)
            LOOP /*Loop 9*/
             open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


            END LOOP;/* Loop 9 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop9..Default + Period..' || l_procedure,1000);
            end if;

       else
                 IF g_debug THEN
                   hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
                 END IF;
               FOR csr_rec in rg_csr_assignment_default_run(p_payroll_action_id,
                                                 p_chunk,
                                                 g_parameters.employee_type,
                                                 g_parameters.business_group_id,
                                                 g_parameters.period_end_date,
                                                 g_parameters.pact_id)
               LOOP /*Loop 10 */
                 open csr_next_action_id;
             fetch  csr_next_action_id into l_next_assignment_action_id;
             close csr_next_action_id;

             if g_debug then
             hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
             hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
             hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
             hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
             end if;

            -- Create the archive assignment actions
             hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                        insert into pay_action_information(
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
                                      effective_date,
                                      source_id,
                                      tax_unit_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      assignment_id
                                      )
                                      values(
                                      pay_action_information_s.nextval,
                                      l_next_assignment_action_id,
                                      'AAP',
                                      null,
                                      null,
                                      csr_rec.tax_unit_id,
                                      'AU_ARCHIVE_ASG_DETAILS',
                                      csr_rec.assignment_action_id,
                                      p_payroll_action_id,
                                      csr_rec.action_sequence,
                                      csr_rec.assignment_id
                                      );


               END LOOP; /* Loop 10 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop10 Default + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Default */


    end if ;/*End Assignment id */
    end if ; /* End Payroll */
    end if; /* End Legal */
end if; /* End Organization */

ELSE /* 9113084 - Use Old logic when RANGE_PERSON_ID is disabled */

    if g_parameters.org_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_org_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.org_id,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 1 Org,Archive start date,end date */
             open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;

    	      if g_debug then

    	           hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
	           hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
	           hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
	           hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);

	      end if;



    	    -- Create the archive assignment actions
    	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);


                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


            END LOOP;/* Loop 1 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop1 Org+Period....' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_org_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.org_id,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 2 Org,Pact_id and period end date*/
                 open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
       	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

       	    -- Create the archive assignment actions
       	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


               END LOOP; /* Loop 2 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop2 ,Org + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Organization  */
    else      /* Not Org,check for others */

    if g_parameters.legal_employer is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_legal_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.legal_employer,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 3 Leg Employer,Archive Start date,archive end date*/
                 open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;
    	     if g_debug then
    	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
    	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
    	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
    	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
    	     end if;

    	    -- Create the archive assignment actions
    	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


            END LOOP;/* Loop 3 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop3.Legal Emp + period...' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_legal_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.legal_employer,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 4 Leg employer,pact_id + period end date */
             open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
       	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

       	    -- Create the archive assignment actions
       	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


               END LOOP; /* Loop 4 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop4.Legal Emp + Run...' || l_procedure,1000);
            end if;
        end if; /* End of Inner Legal Employer  */
    else /* Not Org,Legal Emp Check others */

    if g_parameters.payroll_id is not null
    then
       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_payroll_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.payroll_id,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 5 Payroll, Archive start date,end date */
                 open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;

    	     if g_debug then
    	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
    	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
    	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
    	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
    	     end if;

    	    -- Create the archive assignment actions
    	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


            END LOOP;/* Loop 5 */

            if g_debug then
            hr_utility.set_location('Leaving............Loop5 Payroll + Period....' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_payroll_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.payroll_id,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 6 Payroll, pact_id + period end date*/
                 open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

       	    -- Create the archive assignment actions
       	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


               END LOOP; /* Loop 6 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop6 Payroll+ Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Payroll */
    else /* Not Org,Legal,Payroll check others */

    if g_parameters.assignment_id is not null
    then
         if g_parameters.start_date is not null and g_parameters.end_date is not null
            then
                 FOR csr_rec in csr_assignment_period(p_payroll_action_id,
                 					 p_start_person,
                 					 p_end_person,
                 					 g_parameters.employee_type,
                 					 g_parameters.business_group_id,
                 					 g_parameters.assignment_id,
                 					 g_parameters.start_date,
                 					 g_parameters.end_date)
                 LOOP /*Loop 7 Assignment ,Archive start date,end date*/
                      open csr_next_action_id;
         	     fetch  csr_next_action_id into l_next_assignment_action_id;
         	     close csr_next_action_id;

		  if g_debug then
         	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
         	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
         	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
         	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
         	  end if;

         	    -- Create the archive assignment actions
         	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


                 END LOOP;/* Loop 7 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop7. Asg + Period...' || l_procedure,1000);
                 end if;

            else
                    FOR csr_rec in csr_assignment_run(p_payroll_action_id,
                    					 p_start_person,
                    					 p_end_person,
                    					 g_parameters.employee_type,
                    					 g_parameters.business_group_id,
                    					 g_parameters.assignment_id,
                    					 g_parameters.period_end_date,
                    					 g_parameters.pact_id)
                    LOOP /*Loop 8 Assignment Pact_id,Period end date */
                     open csr_next_action_id;
            	     fetch  csr_next_action_id into l_next_assignment_action_id;
            	     close csr_next_action_id;

            	     if g_debug then
            	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
            	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
            	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
            	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
            	     end if;

            	    -- Create the archive assignment actions
            	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                   	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


                    END LOOP; /* Loop 8 */
                 if g_debug then
                 hr_utility.set_location('Leaving............Loop8.Asg + Run...' || l_procedure,1000);
                 end if;
             end if; /* End of Inner Assignment */

    else

    /* Default Begins */

       if g_parameters.start_date is not null and g_parameters.end_date is not null
       then
            FOR csr_rec in csr_assignment_default_period(p_payroll_action_id,
            					 p_start_person,
            					 p_end_person,
            					 g_parameters.employee_type,
            					 g_parameters.business_group_id,
            					 g_parameters.start_date,
            					 g_parameters.end_date)
            LOOP /*Loop 9*/
             open csr_next_action_id;
    	     fetch  csr_next_action_id into l_next_assignment_action_id;
    	     close csr_next_action_id;

    	     if g_debug then
    	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
    	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
    	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
    	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
    	     end if;

    	    -- Create the archive assignment actions
    	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


            END LOOP;/* Loop 9 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop9..Default + Period..' || l_procedure,1000);
            end if;

       else
               FOR csr_rec in csr_assignment_default_run(p_payroll_action_id,
               					 p_start_person,
               					 p_end_person,
               					 g_parameters.employee_type,
               					 g_parameters.business_group_id,
               					 g_parameters.period_end_date,
               					 g_parameters.pact_id)
               LOOP /*Loop 10 */
                 open csr_next_action_id;
       	     fetch  csr_next_action_id into l_next_assignment_action_id;
       	     close csr_next_action_id;

       	     if g_debug then
       	     hr_utility.set_location('p_payroll_action_id.........= '||p_payroll_action_id,20);
       	     hr_utility.set_location('l_next_assignment_action_id.= '||l_next_assignment_action_id,20);
       	     hr_utility.set_location('csr_rec.assignment_id.......= '||csr_rec.assignment_id,20);
       	     hr_utility.set_location('csr_rec.tax_unit_id.........= '||csr_rec.tax_unit_id,20);
       	     end if;

       	    -- Create the archive assignment actions
       	     hr_nonrun_asact.insact(l_next_assignment_action_id, csr_rec.assignment_id, p_payroll_action_id, p_chunk, csr_rec.tax_unit_id);

                  	insert into pay_action_information(
                  	              action_information_id,
                  	              action_context_id,
                  	              action_context_type,
                  	              effective_date,
                  	              source_id,
                  	              tax_unit_id,
                  	              action_information_category,
                  	              action_information1,
                  	              action_information2,
                  	              action_information3,
                  	              assignment_id
                  	              )
                  	              values(
                  	              pay_action_information_s.nextval,
                  	              l_next_assignment_action_id,
                  	              'AAP',
                  	              null,
                  	              null,
                  	              csr_rec.tax_unit_id,
                  	              'AU_ARCHIVE_ASG_DETAILS',
                  	              csr_rec.assignment_action_id,
                  	              p_payroll_action_id,
                  	              csr_rec.action_sequence,
                  	              csr_rec.assignment_id
                  	              );


               END LOOP; /* Loop 10 */
            if g_debug then
            hr_utility.set_location('Leaving............Loop10 Default + Run....' || l_procedure,1000);
            end if;
        end if; /* End of Inner Default */


    end if ;/*End Assignment id */
    end if ; /* End Payroll */
    end if; /* End Legal */
end if; /* End Organization */

END IF;

exception
    when others then
      hr_utility.set_location('Error in '||l_procedure,999999);
      raise;
end assignment_action_code;

 --------------------------------------------------------------------+
  -- Name  : archive_code
  -- Type  : Procedure
  -- Access: Public
  -- This procedure archives details for assignment.
  -- Employee details
  -- Checks pay_Action_information context ='AU_ARCHIVE_ASG_DETAILS'
  -- If employee details not previously archived,proc archives
  -- employee details in pay_Action_information with context
  -- 'AU_EMPLOYEE_RECON_DETAILS'.
  -- Element details.
  -- For each assignment run,proc archives element processed in
  -- pay_Action_information with context 'AU_ELEMENT_RECON_DETAILS'
  -- Balance Details.
  -- For each assignment run,proc archives balance details in
  -- pay_Action_information with context 'AU_BALANCE_RECON_DETAILS'
  -- Uses package pay_au_reconciliation_pkg to fetch balances.

  --------------------------------------------------------------------+

procedure archive_code
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type
  ,p_effective_date        in pay_payroll_actions.effective_date%type
  ) is



 cursor c_employee_details(c_business_group_id hr_all_organization_units.organization_id%TYPE,
   	                    c_assignment_id number,c_end_date date, c_start_date date) /*Bug#3662449 c_start_date parameter added*/
  is
  select pap.full_name,
  	 paa.assignment_number,
         paa.assignment_id,
  	 to_number(pro.proposed_salary_n) actual_salary,
  	 paa.normal_hours,
  	 pps.actual_termination_date,
  	 pgr.name grade,     /* Bug 3953702*/
         paa.organization_id,
	 hou.NAME organization_name, /*Bug 3953706 */
--         paa.payroll_id, /*Bug 4688872*/
--	 papf.payroll_name, /*Bug 4132525, Bug 4688872*/
	 hsc.segment1 tax_unit_id, /*Bug 4040688*/
	 hou1.NAME Legal_Employer /*Bug 4132525*/
  from  per_people_f pap,
       	per_assignments_f paa,
	per_grades_tl pgr,       /* Bug 3953702*/
    	per_periods_of_service pps,
        per_pay_bases ppb,
	per_pay_proposals pro,
	per_assignment_status_types past,
	hr_soft_coding_keyflex hsc, /*Bug 4040688*/
	hr_all_organization_units hou, /*Bug 3953706 */
	hr_all_organization_units hou1 /*Bug 4132525*/
--	pay_payrolls_f papf /*Bug 4132525, Bug 4688872*/
  where  pap.person_id = paa.person_id
  and    paa.assignment_id = c_assignment_id
  and    paa.business_group_id = c_business_group_id
  and    paa.grade_id     = pgr.grade_id(+)              /* Bug 3953702*/
  and    pgr.language(+)  = userenv('LANG')
  and    paa.pay_basis_id  = ppb.pay_basis_id(+)
  and    paa.assignment_id = pro.assignment_id(+)
  AND    hou.organization_id = paa.organization_id /*Bug 3953706 */
  AND    hou1.organization_id = hsc.segment1 /*Bug 4132525*/
--  AND    papf.payroll_id = paa.payroll_id /*Bug 4132525, Bug 4688872*/
--  AND    c_end_date BETWEEN papf.effective_start_date AND papf.effective_end_date /*Bug 4132525, Bug 4688872*/
  and    pps.period_of_service_id = paa.period_of_service_id
  AND    paa.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id /*Bug 4040688*/
  and    paa.assignment_status_type_id = past.assignment_status_type_id
  and    paa.effective_end_date = ( select max(effective_end_date)         /*Bug#3662449 sub query added*/
                                    from  per_assignments_f
                                    WHERE assignment_id  =  c_assignment_id
                                    and effective_end_date >= c_start_date
                                    and effective_start_date <= c_end_date)
  and    c_end_date between pap.effective_start_date and pap.effective_end_date
  and   pps.person_id = pap.person_id
  and   pro.change_date(+) <= c_end_date
  and   nvl(pro.approved,'Y') = 'Y'
  and   nvl(pro.change_date,to_date('4712/12/31','YYYY/MM/DD')) = (select nvl(max(pro1.change_date),to_date('4712/12/31','YYYY/MM/DD'))
                             from per_pay_proposals pro1
							  where pro1.assignment_id(+) = paa.assignment_id
							  and pro1.change_date(+) <=  c_end_date
							  and nvl(pro1.approved,'Y')='Y');


/*Bug# 4688872 - Introduced a new cursor to get the payroll name for the employee. This has been done to take care of cases
                    where assignment has payroll attached to it for few months but is not attached at the end of year*/
 CURSOR c_get_payroll_name(c_assignment_id number,
                           c_start_date date,
                           c_end_date date)
 IS
 SELECT paaf.payroll_id, pay.payroll_name
 FROM per_all_assignments_f        paaf,
      pay_payrolls_f               pay
 WHERE paaf.assignment_id = c_assignment_id
 and   paaf.effective_end_date = (select max(effective_end_date)
   	                           From  per_assignments_f iipaf
				                     WHERE iipaf.assignment_id  = c_assignment_id
				                     and iipaf.effective_end_date >= c_start_date
				                     and iipaf.effective_start_date <= c_end_date
                                 AND iipaf.payroll_id IS NOT NULL)
 AND  pay.payroll_id = paaf.payroll_id
 AND  paaf.effective_end_date BETWEEN pay.effective_start_date AND pay.effective_end_date;

  cursor c_payment_summary_details(c_assignment_id number,
                                   c_fin_date per_assignment_extra_info.aei_information1%TYPE)
  is
  select hr.meaning fin_year
  from per_assignment_extra_info pae,
       hr_lookups    hr
  where pae.aei_information_category = 'HR_PS_ISSUE_DATE_AU'
   and   pae.information_type   = 'HR_PS_ISSUE_DATE_AU'
   and   pae.assignment_id      = c_assignment_id
   and   pae.aei_information1   = c_fin_date
   and   pae.aei_information1   = hr.lookup_code
   and   hr.lookup_type         = 'AU_PS_FINANCIAL_YEAR';

 /* Bug 3627293 Modified cursor to return source_action_id */
/* Bug 3953706 Modified cursor to group elements into 7 groups (Taxable Earnings,Non Taxable Earnings,Pre Tax Deductions,Employer Superannuation Contributions,
								Post Tax Deductions,Direct Payments,Tax Deductions)*/
/*Bug 3935471 modified cursor to return the tax unit of master assignment action id*/
/* Bug 5063359 - Modified decode for Employer Charges to return classification as Employer Charges rather than Employer Superannuation Contribution */

/* Bug 5461557 - Added tables piv2 and prrv2 to get input value for hours and rate and their relative joins,
                 Used a group by based on rate */

/*Bug 5603254 -  Removed tables piv2 and prrv2  and their joins from cursor , added a call to function pay_au_rec_det_archive.get_element_payment_hours to get the value for hours and rate */


  cursor c_element_details(c_business_group_id hr_all_organization_units.organization_id%TYPE,c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
  is
  select element_name,label classification_name,sum(amount) payment,sum(hours) hours,source_action_id master_action_id, tax_unit_id master_tax_unit_id,rate /*Bug 3935471 ,5461557 */
  from
  (select  distinct -- Bug No: 4045910
	  nvl(pet.reporting_name, pet.element_name) element_name,
       decode(instr(pec.classification_name,  'Earnings'),  0,  null,
               decode(pec2.classification_name,  'Non Taxable', 'Non Taxable Earnings',  'Taxable Earnings'))  ||
       decode(instr(pec.classification_name,  'Payments'),  0,  null,
	       decode(instr(pec.classification_name,  'Direct'),  0,  'Taxable Earnings',  'Direct Payments')) ||
       decode(instr(pec.classification_name,  'Deductions'),  0,  null,
	       decode(pec.classification_name , 'Termination Deductions' , 'Tax Deductions'
	                                      , 'Involuntary Deductions' , 'Post Tax Deductions'
			                      , 'Voluntary Deductions' , 'Post Tax Deductions'
                                              , pec.classification_name )) ||
       decode(instr(pec.classification_name, 'Employer Charges'), 0,null,'Employer Charges' ) label,
          decode(substr(piv.uom,1,1), 'M', prrv.result_value, null) amount,
 pay_au_rec_det_archive.get_element_payment_hours(prr.assignment_action_id,pet.element_type_id,prr.run_result_id,ppa.effective_date) hours, /*Bug 5603254 */
decode(pay_au_rec_det_archive.get_element_payment_rate(prr.assignment_action_id,pet.element_type_id,prr.run_result_id,ppa.effective_date), null,
        (prrv.result_value/pay_au_rec_det_archive.get_element_payment_hours(prr.assignment_action_id,pet.element_type_id,prr.run_result_id, ppa.effective_date)),
    pay_au_rec_det_archive.get_element_payment_rate(prr.assignment_action_id,pet.element_type_id,prr.run_result_id,ppa.effective_date)) rate, /* 5599310 */
  	  prr.run_result_id,
	  paa.source_action_id,
	  paa2.tax_unit_id /*Bug 3935471*/
   from   pay_element_types_f pet
  	 ,pay_input_values_f piv
 	 ,pay_element_classifications pec
  	 ,pay_assignment_actions paa
  	 ,pay_assignment_actions paa2  /*Bug 3935471*/
    ,pay_payroll_actions ppa
  	 ,per_assignments_f paaf
  	 ,pay_run_results prr
	 ,pay_run_result_values prrv
	 ,pay_element_classifications pec2
	 ,pay_sub_classification_rules_f pscr
  where   pet.element_type_id    = piv.element_type_id
  and 	pet.element_type_id      = prr.element_type_id
  and 	prr.assignment_action_id = paa.assignment_action_id
  and 	paaf.assignment_id       = paa.assignment_id
  AND   paa2.assignment_action_id = nvl(paa.source_action_id, paa.assignment_action_id) /*Bug 3935471*/
  and 	paaf.business_group_id   =  c_business_group_id/*Bug 5370001 */
  and 	prr.run_result_id        = prrv.run_result_id
  and 	prrv.input_value_id      = piv.input_value_id
  and 	pet.classification_id    = pec.classification_id
  and 	pec.legislation_code = 'AU'
  and 	paa.assignment_action_id = c_assignment_action_id/*Bug 5370001 */
  and 	paa.payroll_action_id    = ppa.payroll_action_id
  and   paa.action_status = 'C'  /*Bug 4099317*/
  and 	piv.name = 'Pay Value'
  and    (instr(pec.classification_name, 'Earnings') > 0
  or     instr(pec.classification_name, 'Payments') > 0
  or     instr(pec.classification_name, 'Deductions') > 0
  or     instr(pec.classification_name, 'Employer Charges' ) > 0 )
  and    pet.element_type_id = pscr.element_type_id (+)
  and    ppa.effective_date between nvl(pscr.effective_start_date, ppa.effective_date)
  and nvl(pscr.effective_end_date, ppa.effective_date)
  and    pscr.classification_id = pec2.classification_id(+)
  and 	ppa.date_earned between pet.effective_start_date and pet.effective_end_date
  and 	ppa.date_earned between paaf.effective_start_date and paaf.effective_end_date
  and   prr.status in ('P','PA')
 )
group by element_name,label,source_action_id, tax_unit_id, rate ; /*Bug 3935471*/

    cursor csr_get_data (c_arc_ass_act_id number)
    is
    select pai.action_information1, pai.tax_unit_id, pai.assignment_id,pai.action_information3
    from pay_action_information pai
    where action_information_category = 'AU_ARCHIVE_ASG_DETAILS'
    and  pai.action_context_id = c_arc_ass_act_id;

/*Bug 4040688 - Two new cursors added to get the maximum assignment action id*/
    cursor csr_get_max_asg_dates (c_assignment_id number,
                                   c_start_date DATE,
				   c_end_date DATE,
				   c_tax_unit_id number)
    is
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
           ,max(paa.action_sequence)
    from    pay_assignment_actions      paa
    ,       pay_payroll_actions         ppa
	,       per_assignments_f           paf
    where   paa.assignment_id           = paf.assignment_id
	and     paf.assignment_id           = c_assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.effective_date      between c_start_date and c_end_date
	    and ppa.payroll_id        =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
	    and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
	    AND paa.tax_unit_id = nvl(c_tax_unit_id, paa.tax_unit_id);


    cursor csr_get_max_asg_action (c_assignment_id number,
                                   c_payroll_action_id number,
				   c_tax_unit_id number)
    is
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
            ,max(paa.action_sequence)
    from    pay_assignment_actions      paa
    ,       pay_payroll_actions         ppa
	,       per_assignments_f           paf
    where   paa.assignment_id           = paf.assignment_id
	and     paf.assignment_id           = c_assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.payroll_action_id      = c_payroll_action_id
	    and ppa.payroll_id        =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
	    and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
	    AND paa.tax_unit_id = nvl(c_tax_unit_id, paa.tax_unit_id);

   /*Bug 4040688 - end of modification*/

    l_procedure                       varchar2(200);
    l_action_information_id    	    number;
    l_object_version_number	    number;

    --
    -- Table Declarations for the BBR
    --
    l_context_lst 		    pay_balance_pkg.t_context_tab;
    l_output_tab		    pay_balance_pkg.t_detailed_bal_out_tab;

    l_TAXABLE_EARNINGS                number;
    l_GROSS_EARNINGS		    number;
    l_PRE_TAX_DEDUCTIONS            number;
    l_DIRECT_PAYMENTS               number;
    l_NON_TAXABLE_EARNINGS    	    number;
    l_DEDUCTIONS          	    number;
    l_TAX                             number;
    l_NET_PAYMENT           	    number;
    l_EMPLOYER_CHARGES		    number;

    l_YTD_TAXABLE_EARNINGS            number;
    l_YTD_NON_TAXABLE_EARNINGS        number;
    l_YTD_GROSS_EARNINGS		    number;
    l_YTD_PRE_TAX_DEDUCTIONS            number;
    l_YTD_DIRECT_PAYMENTS               number;
    l_YTD_DEDUCTIONS          	    number;
    l_YTD_TAX                         number;
    l_YTD_NET_PAYMENT           	    number;
    l_YTD_EMPLOYER_CHARGES	    number;

    l_ass_act_id 		    number;
    l_tax_unit_id 	   number;
    l_assignment_id 		number;

    l_fin_year             varchar2(80);
    l_action_sequence      number;
    l_fin_year_code        per_assignment_extra_info.aei_information1%TYPE;
    l_balance_flag         varchar2(1);

    l_max_asg_action_id number; /*Bug 4040688*/
    l_max_action_sequence  number; /*Bug 4040688*/
    l_payroll_id           number;     /*Bug 4688872*/
    l_payroll_name         pay_payrolls_f.payroll_name%type;     /*Bug 4688872*/

    /* Bug 3531704 */
--------------------------------------------------------------------+
-- Name   : get_fin_year_code
-- Type   : Function
-- Access : Private
-- This function returns the AU financial year code
-- based on the Date parameter.
--------------------------------------------------------------------+

 FUNCTION get_fin_year_code(p_end_date in date)
   RETURN VARCHAR2
   IS
   l_check_date date;
   BEGIN
   /* Bug 3531704 Removed to_char */
   l_check_date := to_date('01/07/'||to_char(p_end_date,'YYYY'),'DD/MM/YYYY');

    if (months_between(p_end_date,l_check_date) >= 0 )
    then
       return to_char(p_end_date,'YY');
    else
       return to_char(add_months(p_end_date,-6),'YY');
    end if;
 END get_fin_year_code;

begin

    g_debug :=hr_utility.debug_enabled ;
    l_balance_flag := 'Y' ; /* Bug 3627293 - Balances have to be stored */
    l_YTD_GROSS_EARNINGS :=0 ;
    l_YTD_NON_TAXABLE_EARNINGS :=0 ;
    l_YTD_PRE_TAX_DEDUCTIONS :=0 ;
    l_YTD_TAXABLE_EARNINGS :=0 ;
    l_YTD_TAX		 :=0 ;
    l_YTD_DEDUCTIONS	 :=0 ;
    l_YTD_DIRECT_PAYMENTS :=0 ;
    l_YTD_NET_PAYMENT	 :=0 ;
    l_YTD_EMPLOYER_CHARGES :=0 ;

    if g_debug then
    l_procedure  := g_package||'archive_code';
    hr_utility.set_location('Entering '||l_procedure,1);
    hr_utility.set_location('p_assignment_action_id......= '|| p_assignment_action_id,10);
    hr_utility.set_location('p_effective_date............= '|| to_char(p_effective_date,'DD-MON-YYYY'),10);
    end if;

    OPEN csr_get_data(p_assignment_action_id);
    FETCH csr_get_data into l_ass_act_id, l_tax_unit_id, l_assignment_id,l_action_sequence;
    CLOSE csr_get_data;

    if g_debug then
    hr_utility.set_location('l_ass_act_id......= '|| l_ass_act_id,10);
    hr_utility.set_location('l_tax_unit_id............= '|| l_tax_unit_id,10);
    hr_utility.set_location('l_assignment_id......= '|| l_assignment_id,10);
    end if;

 FOR csr_rec in c_employee_details(g_business_group_id, l_assignment_id,g_end_date,g_start_date) --Bug#3662449
 LOOP

     if g_debug then
     hr_utility.set_location('csr_rec.full_name............= '|| csr_rec.full_name,10);
     end if;

     IF (NVL(g_prev_assignment_id,0) <> csr_rec.assignment_id) THEN

     	g_prev_assignment_id := csr_rec.assignment_id;

  -- Fetch Manual PS Details for assignment

         l_fin_year_code := get_fin_year_code(g_end_date);

        OPEN c_payment_summary_details(csr_rec.assignment_id,l_fin_year_code);
     	FETCH c_payment_summary_details into l_fin_year;
     	CLOSE c_payment_summary_details;

/*Bug 4040688 - Call to the procedure to get maximum assignment action id*/
	IF g_parameters.pact_id IS NULL THEN
	  OPEN csr_get_max_asg_dates(csr_rec.assignment_id, g_start_date, g_end_date, g_parameters.legal_employer);
          FETCH csr_get_max_asg_dates INTO l_max_asg_action_id, l_max_action_sequence;
	  CLOSE csr_get_max_asg_dates;
	ELSE
  	  OPEN csr_get_max_asg_action(csr_rec.assignment_id, g_parameters.pact_id, g_parameters.legal_employer);
          FETCH csr_get_max_asg_action INTO l_max_asg_action_id, l_max_action_sequence;
	  CLOSE csr_get_max_asg_action;
	END IF ;
  -- Archive YTD balance details
       	   /*Bug 3953706 - Modfied the call to procedure introduce new parameters*/
	   /*Bug 4040688 - YTD Balances will be called for the maximum assignment action id of the assignment*/
         IF l_max_asg_action_id IS NOT NULL THEN
            pay_au_reconciliation_pkg.GET_YTD_AU_REC_BALANCES(
                 P_ASSIGNMENT_ACTION_ID         => l_max_asg_action_id,
		 P_REGISTERED_EMPLOYER          => g_parameters.legal_employer, --2610141
		 P_YTD_GROSS_EARNINGS		=> l_YTD_GROSS_EARNINGS,
              	 P_YTD_NON_TAXABLE_EARNINGS	=> l_YTD_NON_TAXABLE_EARNINGS,
		 P_YTD_PRE_TAX_DEDUCTIONS	=> l_YTD_PRE_TAX_DEDUCTIONS,
             	 P_YTD_TAXABLE_EARNINGS		=> l_YTD_TAXABLE_EARNINGS,
              	 P_YTD_TAX			=> l_YTD_TAX		,
              	 P_YTD_DEDUCTIONS		=> l_YTD_DEDUCTIONS	,
		 P_YTD_DIRECT_PAYMENTS		=> l_YTD_DIRECT_PAYMENTS,
                 P_YTD_NET_PAYMENT		=> l_YTD_NET_PAYMENT	,
       	         P_YTD_EMPLOYER_CHARGES		=> l_YTD_EMPLOYER_CHARGES);
          END IF ;

                     insert into pay_action_information (
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
             			       effective_date,
             			       source_id,
                                      tax_unit_id,
                                      assignment_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      action_information4,
                                      action_information5,
                                      action_information6,
                                      action_information7,
                                      action_information8,
                                      action_information9,
                                      action_information10)
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
             			 'AAP',
                                p_effective_date,
                                null,
             			 null,
             			 l_assignment_id,
             			 'AU_BALANCE_RECON_DETAILS_YTD',
             			 l_YTD_TAXABLE_EARNINGS,
             			 l_YTD_NON_TAXABLE_EARNINGS,
             			 l_YTD_DEDUCTIONS,
             			 l_YTD_TAX,
             			 l_YTD_NET_PAYMENT,
             			 l_YTD_EMPLOYER_CHARGES,
				 l_YTD_GROSS_EARNINGS,
				 l_YTD_PRE_TAX_DEDUCTIONS,
				 l_YTD_DIRECT_PAYMENTS,
                                 l_max_action_sequence);

/*Bug 4040688 - end of modification*/

     	if g_debug then
     	hr_utility.set_location('g_prev_assignment_id......= '|| g_prev_assignment_id,10);
     	hr_utility.set_location('g_arc_payroll_action_id......= '|| g_arc_payroll_action_id,20);
     	hr_utility.set_location('l_max_asg_action_id......= '|| l_max_asg_action_id,20);
     	end if;

  -- Archive employee details
   /* Bug 3953702 - Archived the Grade Name details into pay_action_information */

    /*Bug 4688872*/
    OPEN c_get_payroll_name(l_assignment_id,g_start_date,g_end_date);
    FETCH c_get_payroll_name INTO l_payroll_id, l_payroll_name;
    CLOSE c_get_payroll_name;


        insert into pay_action_information(
                            action_information_id,
			    action_context_id,
			    action_context_type,
			    effective_date,
			    source_id,
			    tax_unit_id,
			    action_information_category,
			    action_information1,
			    action_information2,
			    action_information3,
			    action_information4,
			    action_information5,
			    action_information6,
			    action_information7,
			    action_information8,
			    action_information9,
			    action_information10,
			    action_information11,
			    assignment_id)
		    values(
		            pay_action_information_s.nextval,
		            g_arc_payroll_action_id,
		            'PA',
		            p_effective_date,
		            null,
		            l_tax_unit_id,
		            'AU_EMPLOYEE_RECON_DETAILS',
		            csr_rec.full_name,
		            csr_rec.assignment_number,
		            csr_rec.actual_salary,
		            csr_rec.grade,   /* Bug 3953702*/
		            csr_rec.normal_hours,
		            csr_rec.actual_termination_date,
		            l_fin_year,
		            csr_rec.organization_name,/*Bug 4132525*/
		            csr_rec.Legal_Employer, /*Bug 4040688, Bug 4132525*/
		            l_payroll_name, /*Bug 4132525, Bug 4688872*/
		            csr_rec.organization_name, /*Bug 3953706*/
		            l_assignment_id);


     END IF;


     FOR csr_ele_det in c_element_details(g_business_group_id,l_ass_act_id)
     LOOP

      -- Delete all the data that was populated due to previous action id
      --
      l_context_lst.delete;
      l_output_tab.delete;

       /*Bug 3627293 - Support for Run Types */
       /*Bug 3935471 - Archive run balances only for master actions and for those child actions which
                       have tax unit id different as compared to the master actions.*/

     if csr_ele_det.master_action_id IS NOT NULL THEN
       /* Assignment Action is a child action,balances need not be stored */
	   IF l_tax_unit_id = csr_ele_det.master_tax_unit_id OR g_parameters.legal_employer IS NULL THEN
             l_balance_flag :='N';
	   END IF;
     end if;

      --
      -- Insert the element data into pay_action_information table
      -- This Direct Insert statement is for Performance Reasons.
      --

        insert into pay_action_information (
			    action_information_id,
			    action_context_id,
			    action_context_type,
			    effective_date,
			    source_id,
			    tax_unit_id,
			    action_information_category,
			    action_information1,
			    action_information2,
			    action_information3,
			    action_information4,
			    action_information5,
			    action_information6,
			    assignment_id)
                        values (
			      pay_action_information_s.nextval,
			      p_assignment_action_id,
			      'AAP',
			      p_effective_date,
			      null,
			      l_tax_unit_id,
			      'AU_ELEMENT_RECON_DETAILS',
			      csr_ele_det.element_name,
			      csr_ele_det.classification_name,
			      null,
			      csr_ele_det.hours,
			      csr_ele_det.rate, /* 5599310 */
			      csr_ele_det.payment,
			      l_assignment_id);

      ---
       END LOOP;   /* Completed the Element Details Archive */

          -- Balances Coding for BBR
          --
            -- Populate the Defined Balance IDs for the RUN and YTD dimensions
            -- for the required balances.

            -- Get The Action Sequence for the Assignment_Action_Id.



	  /* Bug 3627293 - Archive Balances only for Master Assignment Action */
	   if ( l_balance_flag = 'Y' )
	   then
     	   /*Bug 3953706 - Modfied the call to procedure introduce new parameters*/
            pay_au_reconciliation_pkg.GET_AU_REC_BALANCES(
                 P_ASSIGNMENT_ACTION_ID         => l_ass_act_id,
		 P_REGISTERED_EMPLOYER          => g_parameters.legal_employer, --2610141
		 P_GROSS_EARNINGS		=> l_GROSS_EARNINGS,
             	 P_NON_TAXABLE_EARNINGS         => l_NON_TAXABLE_EARNINGS,
		 P_PRE_TAX_DEDUCTIONS		=> l_PRE_TAX_DEDUCTIONS,
                 P_TAXABLE_EARNINGS             => l_TAXABLE_EARNINGS    ,
             	 P_TAX                          => l_TAX                 ,
             	 P_DEDUCTIONS                   => l_DEDUCTIONS          ,
		 P_DIRECT_PAYMENTS		=> l_DIRECT_PAYMENTS,
             	 P_NET_PAYMENT                  => l_NET_PAYMENT         ,
             	 P_EMPLOYER_CHARGES             => l_EMPLOYER_CHARGES);


           --
           -- Insert the balance data into pay_action_information table
           -- This Direct Insert statement is for Performance Reasons.
           --
             /*Bug 4040688 - Modified insert statement to store run balance details.*/
             insert into pay_action_information (
                                      action_information_id,
                                      action_context_id,
                                      action_context_type,
             			       effective_date,
             			       source_id,
                                      tax_unit_id,
                                      assignment_id,
                                      action_information_category,
                                      action_information1,
                                      action_information2,
                                      action_information3,
                                      action_information4,
                                      action_information5,
                                      action_information6,
                                      action_information7,
                                      action_information8,
                                      action_information9,
                                      action_information10)
                          values (
                                pay_action_information_s.nextval,
                                p_assignment_action_id,
             			 'AAP',
                                p_effective_date,
                                null,
             			 l_tax_unit_id,
             			 l_assignment_id,
             			 'AU_BALANCE_RECON_DETAILS_RUN',
             			 l_taxable_earnings,
             			 l_NON_TAXABLE_EARNINGS,
             			 l_DEDUCTIONS,
             			 l_TAX,
             			 l_NET_PAYMENT,
             			 l_EMPLOYER_CHARGES,
				 l_GROSS_EARNINGS,
				 l_PRE_TAX_DEDUCTIONS,
				 l_DIRECT_PAYMENTS,
                                 l_action_sequence);
           end if; /*End Check for Balance Flag */
 END LOOP; /* End of assignments for employee */


end archive_code;

  --------------------------------------------------------------------+
  -- Name  : spawn_archive_reports
  -- Type  : Procedure
  -- Access: Public
  -- This procedure calls the Detail report
  -- Using the parameters passed, this proc calls the Reconciliation
  -- Detail report.
  -- This proc is called as deinitialization code of archive process.

  --------------------------------------------------------------------+



procedure spawn_archive_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
  is
 l_count                number;
 ps_request_id          NUMBER;
 l_print_style          VARCHAR2(2);
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;
 l_procedure            VARCHAR2(50);
 l_short_report_name    VARCHAR2(30);  /* 6839263 */
 l_xml_options          BOOLEAN     ;  /* 6839263 */

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_report_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('PAY',legislative_parameters)        payroll_id,
                   pay_core_utils.get_parameter('ORG',legislative_parameters)           org_id,
                   pay_core_utils.get_parameter('BG',legislative_parameters)    business_group_id,
                   to_date(pay_core_utils.get_parameter('SDATE',legislative_parameters),'YYYY/MM/DD') start_date,
                   to_date(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')   end_date,
                   pay_core_utils.get_parameter('PACTID',legislative_parameters)        pact_id,
                   pay_core_utils.get_parameter('LE',legislative_parameters) legal_employer,
                   pay_core_utils.get_parameter('ASG',legislative_parameters) assignment_id,
                   pay_core_utils.get_parameter('SO1',legislative_parameters)   sort_order_1,
                   pay_core_utils.get_parameter('SO2',legislative_parameters)   sort_order_2,
                   pay_core_utils.get_parameter('SO3',legislative_parameters)   sort_order_3,
                   pay_core_utils.get_parameter('SO4',legislative_parameters)   sort_order_4,
                   to_date(pay_core_utils.get_parameter('PEDATE',legislative_parameters),'YYYY/MM/DD') period_end_date,
                   pay_core_utils.get_parameter('YTD_TOT',legislative_parameters)      ytd_totals,
                   pay_core_utils.get_parameter('ZERO_REC',legislative_parameters)    zero_records,
                   pay_core_utils.get_parameter('NEG_REC',legislative_parameters)     negative_records,
                   pay_core_utils.get_parameter('EMP_TYPE',legislative_parameters) employee_type,
                   pay_core_utils.get_parameter('DEL_ACT',legislative_parameters) delete_actions,  /*Bug# 4142159*/
                   pay_core_utils.get_parameter('OUTPUT_TYPE',legislative_parameters)p_output_type /* Bug# 6839263 */
                   FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id  =  c_payroll_action_id;


 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
          ,number_of_copies /* Bug 4116833 */
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;

 rec_print_options  csr_get_print_options%ROWTYPE;

 l_parameters csr_report_params%ROWTYPE;

  Begin
    l_count           :=0;
    ps_request_id     :=-1;
    g_debug :=hr_utility.debug_enabled ;

             if g_debug then
             l_procedure := g_package||' spawn_archive_reports';
             hr_utility.set_location('Entering '||l_procedure,999);
             end if;

-- Set User Parameters for Report.

             open csr_report_params(p_payroll_action_id);
             fetch csr_report_params into l_parameters;
             close csr_report_params;

             /* Start Bug 6839263 */
             IF  l_parameters.p_output_type = 'XML_PDF'
             THEN
                     l_short_report_name := 'PYAURECD_XML';

                     l_xml_options      := fnd_request.add_layout
                                        (template_appl_name => 'PAY',
                                         template_code      => 'PYAURECD_XML',
                                         template_language  => 'en',
                                         template_territory => 'US',
                                         output_format      => 'PDF');

             ELSE
                     l_short_report_name := 'PYAURECD';
             END IF;
             /* End Bug 6839263 */


             /*Bug 3953615 -- Added the call to check parameters validations*/
             pay_au_reconciliation_pkg.check_report_parameters(l_parameters.start_date
                                                              ,l_parameters.end_date
                                                              ,l_parameters.period_end_date);



          if g_debug then
                   hr_utility.set_location('payroll_parameters.action '||p_payroll_action_id,0);
                   hr_utility.set_location('in BG_ID '||l_parameters.business_group_id,1);
                   hr_utility.set_location('in org_id '||l_parameters.org_id,2);
                   hr_utility.set_location('in payroll_parameters.id '||l_parameters.payroll_id,3);
                   hr_utility.set_location('in asg_id '||l_parameters.assignment_id,4);
                   hr_utility.set_location('in archive start date '||to_char(l_parameters.start_date,'YYYY/MM/DD'),5);
                   hr_utility.set_location('in archive end date '||to_char(l_parameters.end_date,'YYYY/MM/DD'),6);
                   hr_utility.set_location('in pact_id '||l_parameters.pact_id,7);
                   hr_utility.set_location('in legal employer '||l_parameters.legal_employer,8);
            	   hr_utility.set_location('in PERIOD END DATE '||to_char(l_parameters.period_end_date,'YYYY/MM/DD'),9);
                   hr_utility.set_location('in YTD totals '||l_parameters.ytd_totals,10);
                   hr_utility.set_location('in zero records'||l_parameters.zero_records,11);
                   hr_utility.set_location('in Negative records'||l_parameters.negative_records,12);
                   hr_utility.set_location('in emp_type '||l_parameters.employee_type,14);
                   hr_utility.set_location('in sort order 1'||l_parameters.sort_order_1,15);
                   hr_utility.set_location('in sort order 2'||l_parameters.sort_order_2,16);
                   hr_utility.set_location('in sort order 3'||l_parameters.sort_order_3,17);
                   hr_utility.set_location('in sort order 4'||l_parameters.sort_order_4,18);
                   hr_utility.set_location('in delete action'||l_parameters.delete_actions,19); /*Bug# 4142159*/
                   hr_utility.set_location('in Output Type  '||l_parameters.p_output_type,20); /*Bug# 6939263 */
            end if;

     if g_debug then
      hr_utility.set_location('Afer payroll action ' || p_payroll_action_id , 125);

      hr_utility.set_location('Before calling report',24);
      end if;

    OPEN csr_get_print_options(p_payroll_action_id);
       FETCH csr_get_print_options INTO rec_print_options;
       CLOSE csr_get_print_options;
       --
       l_print_together := nvl(fnd_profile.value('CONC_PRINT_TOGETHER'), 'N');
       --
       -- Set printer options
       l_print_return := fnd_request.set_print_options
                           (printer        => rec_print_options.printer,
                            style          => rec_print_options.print_style,
                            copies         => rec_print_options.number_of_copies, /* Bug 4116833*/
                            save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                            print_together => l_print_together);
    -- Submit report
      if g_debug then
      hr_utility.set_location('payroll_action id    '|| p_payroll_action_id,25);
      end if;

ps_request_id := fnd_request.submit_request
 ('PAY',
  l_short_report_name,
   null,
   null,
   false,
   'P_PAYROLL_ACTION_ID='||to_char(p_payroll_action_id),
   'P_BUSINESS_GROUP_ID='||to_char(l_parameters.business_group_id),
   'P_ORGANIZATION_ID='||to_char(l_parameters.org_id),
   'P_PAYROLL_ID='||to_char(l_parameters.payroll_id),
   'P_REGISTERED_EMPLOYER='||to_char(l_parameters.legal_employer),
   'P_ASSIGNMENT_ID='||to_char(l_parameters.assignment_id),
   'P_START_DATE='||to_char(l_parameters.start_date,'YYYY/MM/DD'),
   'P_END_DATE='||to_char(l_parameters.end_date,'YYYY/MM/DD'),
   'P_PAYROLL_RUN_ID='||to_char(l_parameters.pact_id),
   'P_PERIOD_END_DATE='||to_char(l_parameters.period_end_date,'YYYY/MM/DD'),
   'P_EMPLOYEE_TYPE='||l_parameters.employee_type,
   'P_YTD_TOTALS='||l_parameters.ytd_totals,
   'P_ZERO_RECORDS='||l_parameters.zero_records,
   'P_NEGATIVE_RECORDS='||l_parameters.negative_records,
   'P_SORT_ORDER_1='||l_parameters.sort_order_1,
   'P_SORT_ORDER_2='||l_parameters.sort_order_2,
   'P_SORT_ORDER_3='||l_parameters.sort_order_3,
   'P_SORT_ORDER_4='||l_parameters.sort_order_4,
   'P_DELETE_ACTIONS='||l_parameters.delete_actions, /*Bug# 4142159*/
   'BLANKPAGES=NO',
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL
);
      if g_debug then
      hr_utility.set_location('After calling report',24);
      end if;






end spawn_archive_reports;

-------------------------------------------------------------------------------------------
 /* Bug 5603254 - Function is used to compute Hours for Elements.
    Function    : get_element_payment_hours
    Description : This function is to be used for getting the Hours component paid in run.

    Inputs      : p_assignment_action_id - Assignment Action ID
                  p_element_type_id      - Element Type ID
                  p_run_result_id        - Run Result ID
                  p_effective_date       - Effective Date of Run
*/
-------------------------------------------------------------------------------------------
FUNCTION get_element_payment_hours
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER
IS

    l_element_type_id  pay_element_types_f.element_type_id%TYPE;
    l_input_value_id   pay_input_values_f.input_value_id%TYPE;

    l_result number := NULL;
    l_temp   NUMBER := NULL;

/* Bug 5987877 - Added Check for Input with Name - Hours */
    CURSOR get_hours_input_value
    (c_element_type_id pay_element_types_f.element_type_id%TYPE
    ,c_effective_date  date)
     IS
        SELECT pivf.input_value_id
              ,pivf.name
              ,decode(pivf.name,'Hours',1,2) sort_index
        FROM   pay_input_values_f pivf
        WHERE  pivf.element_type_id = c_element_type_id
        AND    substr(pivf.uom,1,1) = 'H'
        AND    c_effective_date between pivf.effective_start_date and pivf.effective_end_date
        ORDER BY sort_index;

    CURSOR  get_hours_result_value
    (c_run_result_id  pay_run_result_values.run_result_id%TYPE
    ,c_input_value_id pay_run_result_values.input_value_id%TYPE)
    IS
        SELECT prrv.result_value
        FROM   pay_run_result_values prrv
        WHERE  prrv.run_result_id  = c_run_result_id
        AND    prrv.input_value_id = c_input_value_id;

BEGIN

    g_debug := hr_utility.debug_enabled;

    /* Bug 5987877 - Added Check for Multiple Hours Input
       If Input Name = "Hours", return run result for it
       else sum the run results for all "H_" UOM type.
    */
    FOR csr_rec IN get_hours_input_value(p_element_type_id,p_effective_date)
    LOOP
            OPEN get_hours_result_value(p_run_result_id,csr_rec.input_value_id);
            FETCH get_hours_result_value INTO l_temp;
            CLOSE get_hours_result_value;
            IF csr_rec.sort_index = 1
            THEN
                l_result := l_temp;
                EXIT;
            ELSE
                l_result := NVL(l_result,0) + NVL(l_temp,0);
            END IF;
    END LOOP;


 /* Avoid Divide by Zero Errors when used for computing Rate, Report Hours and Rate as Null */
    IF l_result = 0
    THEN
        l_result := NULL;
    END IF;

 RETURN l_result;
END get_element_payment_hours;

 -------------------------------------------------------------------------------------------
 /* Bug 5599310 - Function is used to compute Rate for Elements.
    Function    : get_element_payment_rate
    Description : This function is to be used for getting the Rate component if cusomters have entered it

    Inputs      : p_assignment_action_id - Assignment Action ID
                  p_element_type_id      - Element Type ID
                  p_run_result_id        - Run Result ID
                  p_effective_date       - Effective Date of Run
*/
-------------------------------------------------------------------------------------------
FUNCTION get_element_payment_rate
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER
IS

    l_element_type_id  pay_element_types_f.element_type_id%TYPE;
    l_input_value_id   pay_input_values_f.input_value_id%TYPE;

    l_result number := NULL;

       CURSOR get_rate_input_value
    (c_element_type_id pay_element_types_f.element_type_id%TYPE
    ,c_effective_date  date)
     IS
        SELECT pivf.input_value_id
        FROM   pay_input_values_f pivf
        WHERE  pivf.element_type_id = c_element_type_id
        AND    upper(pivf.name) like  'RATE%'
	AND    pivf.uom  in ('N','M','I') /*bug 6109668 */
        AND    c_effective_date between pivf.effective_start_date and pivf.effective_end_date;

    CURSOR  get_rate_result_value
    (c_run_result_id  pay_run_result_values.run_result_id%TYPE
 ,c_input_value_id pay_run_result_values.input_value_id%TYPE)
    IS
        SELECT prrv.result_value
        FROM   pay_run_result_values prrv
        WHERE  prrv.run_result_id  = c_run_result_id
        AND    prrv.input_value_id = c_input_value_id;

BEGIN

    g_debug := hr_utility.debug_enabled;

 if g_debug then
                hr_utility.trace('Entering get_element_payment_rate');
 end if;

    OPEN get_rate_input_value(p_element_type_id,p_effective_date);
    FETCH get_rate_input_value INTO l_input_value_id;
    CLOSE get_rate_input_value;

    IF l_input_value_id IS NOT NULL
    THEN
        OPEN get_rate_result_value(p_run_result_id,l_input_value_id);
        FETCH get_rate_result_value INTO l_result;
        CLOSE get_rate_result_value;
    END IF;

    /* Avoid Divide by Zero Errors when used for computing Rate, Report Hours and Rate as Null */

if g_debug then
                hr_utility.trace('l_result is ' || l_result);
 end if;

    IF l_result = 0
    THEN
        l_result := NULL;
    END IF;


if g_debug then
                hr_utility.trace('Leaving get_element_payment_rate');
 end if;

 RETURN l_result;
END get_element_payment_rate;


end pay_au_rec_det_archive;

/
