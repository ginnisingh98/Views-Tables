--------------------------------------------------------
--  DDL for Package PAY_AU_PAYMENT_SUMMARY_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYMENT_SUMMARY_MAGTAPE" AUTHID CURRENT_USER as
/* $Header: pyaupsm.pkh 120.6.12010000.2 2008/08/06 06:50:56 ubhat ship $*/

  level_cnt  number;

  ---------------------------------------------------------------------------+
    -- These are PUBLIC procedures are required by the Archive/Magtape process.
    -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
    -- the archive process knows what code to execute for each step of
    -- the archive.
  -----------------------------------------------------------------------------+

  procedure range_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_sql               out NOCOPY varchar2);

    procedure assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in per_all_people_f.person_id%type,
       p_end_person_id      in per_all_people_f.person_id%type,
       p_chunk              in number);

     procedure initialization_code
           (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);

     procedure archive_code
           (p_payroll_action_id  in pay_assignment_actions.payroll_action_id%type,
            p_effective_date        in date);


  --------------------------------------------------------------------+
-- These cursors are used to retrieve data and pass it to formulas.
  --------------------------------------------------------------------+

  --------------------------------------------------------------------+
  -- PUBLIC cursor to select Supplier data.
  --------------------------------------------------------------------+
   cursor supplier_details_val IS -- (Bug 3132178) Created to be called for spawned process
       select  'ASSIGNMENT_ACTION_ID=C',
                ppac.assignment_action_id ps_report_id,
	       'TEST_FLAG=P',
	       'Y'
      from    pay_assignment_actions ppac,
	      pay_payroll_actions ppa
       where  ppa.payroll_action_id =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
       and    ppac.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_PAYROLL_ACTION',ppa.legislative_parameters)
       AND    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',  ppac.assignment_action_id)='YES'
       AND pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',ppac.assignment_action_id)='NO'   /* Added for bug 5257622 */
       and    ppac.action_status = 'C'
       and    ppa.report_type = 'AU_PS_DATA_FILE_VAL'
       and    ppa.report_qualifier = 'AU'
       and    ppa.report_category = 'REPORT'
       and rownum=1;


       --(Bug 3132178) Added TEST_FLAG to the cursor which is set to N i.e. this cursor creates Production EFILE
   cursor supplier_details is
       select  'ASSIGNMENT_ACTION_ID=C',
                apac.assignment_action_id ps_report_id,
	       'TEST_FLAG=P',
	       'N'
        from    pay_assignment_actions apac,
                pay_assignment_actions ppac,
                pay_payroll_actions ppa,
                pay_assignment_actions mpac,
                pay_action_interlocks ppai,
                pay_action_interlocks mpai
         where  apac.assignment_action_id = ppai.locked_action_id
         and    mpac.assignment_Action_id = mpai.locking_action_id
         and    ppa.payroll_action_id = ppac.payroll_Action_id
         and    apac.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
         and    ppac.assignment_action_id = mpai.locked_action_id
         and    mpac.payroll_action_id =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
         and    apac.action_status = 'C'
         and    ppac.action_status = 'C'  /* Bug No : 3288757 */
         /*Bug 3400521 - Added the following joins to improve the performance*/
         and    ppa.action_status = 'C'
         and    ppa.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
         and    ppa.report_qualifier = 'AU'
         and    ppa.report_category = 'REPORT'
	 and    rownum=1;

  --------------------------------------------------------------------+
  -- PUBLIC cursor to select Legal Employer data.
  --------------------------------------------------------------------+
  cursor employer_details_val is	-- (Bug 3132178) Created to be called for spawned process
  select * from
  (
  select 'ASSIGNMENT_ACTION_ID=C',
         ppac.assignment_action_id ps_report_id,
         'FINANCIAL_YEAR_END=P',
         substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),6,4),
         'FINANCIAL_YEAR_START=P',
         substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),1,4)
/*Bug 6630375 - removed ETP_PAYER_TYPE */
--       ,'ETP_PAYER_TYPE=P',
--       ,decode(fue.user_entity_name,'X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD',decode(value ,0,null ,null,null, 'P')) etp_payer_type
  from
  pay_assignment_actions ppac,
  pay_payroll_actions ppa,
  ff_archive_items ff,
  ff_user_entities fue
  where  ppa.payroll_action_id =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and  ppac.action_status='C'
    and  ppac.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_PAYROLL_ACTION',ppa.legislative_parameters)
    AND    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',  ppac.assignment_action_id)='YES'
    	  AND pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',ppac.assignment_action_id)='NO'   /* Added for bug 5257622 */
    and  fue.user_Entity_id= ff.user_entity_id
    and  ff.context1= ppac.assignment_action_id
    and  ppa.report_type = 'AU_PS_DATA_FILE_VAL'
    and  ppa.report_qualifier = 'AU'
    and  ppa.report_category = 'REPORT'
--    order by etp_payer_type
   )
   where rownum=1;


  cursor employer_details is
  select * from
  (
  select /*+ ORDERED */  'ASSIGNMENT_ACTION_ID=C',
         apac.assignment_action_id ps_report_id,
         'FINANCIAL_YEAR_END=P',
         substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),6,4),
         'FINANCIAL_YEAR_START=P',
         substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),1,4)
/*Bug 6630375 - removed ETP_PAYER_TYPE */
--       ,'ETP_PAYER_TYPE=P',
--       ,decode(fue.user_entity_name,'X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD',decode(value ,0,null ,null,null, 'P')) etp_payer_type
  from
  pay_assignment_actions mpac, --magtape
  pay_action_interlocks mpai,
  pay_assignment_actions ppac, --self printed
  pay_action_interlocks ppai,
  pay_assignment_actions apac, --archive
  pay_payroll_actions ppa,  --self printed
  ff_archive_items ff,
  ff_user_entities fue
  where  mpac.payroll_action_id =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and  mpac.action_status ='C'
    and  ppac.action_status='C'
    and  mpai.locking_action_id = mpac.assignment_Action_id  -- magtapes locking action id
    and  ppac.assignment_action_id = mpai.locked_action_id  --self printed locked by maghtape
    and  ppai.locking_Action_id =ppac.assignment_action_id -- self printed has locked archive
    and  apac.assignment_action_id=ppai.locked_action_id   --archive actionslocked by self printed
    and  apac.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
    and  ppa.payroll_action_id = ppac.payroll_Action_id    --payroll actions for self printed
    and  ppa.report_type='AU_PAYMENT_SUMMARY_REPORT'
    and  apac.assignment_id = ppac.assignment_id
    and  ppac.assignment_id = mpac.assignment_id
    and  fue.user_Entity_id= ff.user_entity_id
    and  ff.context1= apac.assignment_action_id
--    order by etp_payer_type
   )
where rownum=1;
  --------------------------------------------------------------------+
  -- PUBLIC cursor to select Employee Payment summary data.
  --------------------------------------------------------------------+
    /* Bug #6630375 - Added Check for Assignment ID in both ARCHIVE and Magtape assignment actions */

 cursor payment_summary_data_val is	-- (Bug 3132178) Created to be called for spawned process
       select  'ASSIGNMENT_ACTION_ID=C',
                 ppac.assignment_action_id ps_report_id
         from    pay_assignment_actions ppac,
		 pay_payroll_actions mpa,
		 pay_assignment_actions mpac
	  where  mpa.payroll_action_id	= pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
	  AND    mpac.payroll_action_id = mpa.payroll_action_id /* Added for bug 6630375 */
	  AND    mpac.assignment_id = ppac.assignment_id  /* Added for bug 6630375 */
	  AND    ppac.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_PAYROLL_ACTION',mpa.legislative_parameters)
      AND    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',  ppac.assignment_action_id)='YES'
	  AND    pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',ppac.assignment_action_id)='NO'   /* Added for bug 5257622 */
	  and    ppac.action_status = 'C'
	  and    mpa.report_type = 'AU_PS_DATA_FILE_VAL'
	  and    mpa.report_qualifier = 'AU'
	  and    mpa.report_category = 'REPORT'
/* Added check for bug 5353402 - Details will be displayed in the Data File only if sum of values of these balances are greater than zero */
     and    1 <= (select sum(nvl(value,0))
                     from   ff_user_entities fue, ff_archive_items ff
                     where   fue.user_Entity_id = ff.user_entity_id
               and   fue.user_entity_name in
                         ('X_ALLOWANCE_1_ASG_YTD','X_ALLOWANCE_2_ASG_YTD','X_ALLOWANCE_3_ASG_YTD',
'X_ALLOWANCE_4_ASG_YTD','X_FRINGE_BENEFITS_ASG_YTD',
'X_CDEP_ASG_YTD','X_EARNINGS_TOTAL_ASG_YTD','X_WORKPLACE_DEDUCTIONS_ASG_YTD',
'X_LUMP_SUM_A_DEDUCTION_ASG_YTD','X_LUMP_SUM_A_PAYMENTS_ASG_YTD',
'X_LUMP_SUM_B_DEDUCTION_ASG_YTD','X_LUMP_SUM_B_PAYMENTS_ASG_YTD',
'X_LUMP_SUM_D_PAYMENTS_ASG_YTD','X_LUMP_SUM_E_PAYMENTS_ASG_YTD',
'X_TOTAL_TAX_DEDUCTIONS_ASG_YTD','X_OTHER_INCOME_ASG_YTD','X_UNION_FEES_ASG_YTD')
                   and   ff.context1= ppac.assignment_action_id
             )
	group by ppac.assignment_action_id;

 cursor payment_summary_data is  /* 5471093 */
  select /*+ ORDERED */  'ASSIGNMENT_ACTION_ID=C',
           apac.assignment_action_id ps_report_id
  from     pay_assignment_actions mpac,
           pay_action_interlocks mpai,
           pay_assignment_actions ppac,
           pay_action_interlocks ppai,
           pay_assignment_actions apac,
           pay_payroll_actions ppa
    where  ppa.payroll_action_id = ppac.payroll_Action_id
    and    apac.assignment_action_id = ppai.locked_action_id
    and    apac.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
    and    ppai.locking_Action_id = ppac.assignment_action_id  /* 5471093 */
    and    ppac.assignment_action_id = mpai.locked_action_id
    and    mpac.assignment_Action_id = mpai.locking_action_id
    and    mpac.payroll_action_id =pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    apac.action_status = 'C'
    and    ppac.action_status = 'C'  /* Bug No : 3288757 */
    /*Bug 3400521 - Added the following joins to improve the performance*/
    and    mpac.action_status = 'C'
    and    ppa.action_status = 'C'
    and    ppa.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
    and    ppa.report_qualifier = 'AU'
    and    ppa.report_category = 'REPORT'
    and    apac.assignment_id  = ppac.assignment_id /* 5471093 */
    and    ppac.assignment_id  = mpac.assignment_id /* 5471093 */
   /* Added check for bug 5353402 - Details will be displayed in the Data File only if sum of values of these balances are greater than zero */
     and    1 <= (select sum(nvl(value,0))
                     from   ff_user_entities fue, ff_archive_items ff
                     where   fue.user_Entity_id = ff.user_entity_id
               and   fue.user_entity_name in
                         ('X_ALLOWANCE_1_ASG_YTD','X_ALLOWANCE_2_ASG_YTD','X_ALLOWANCE_3_ASG_YTD',
'X_ALLOWANCE_4_ASG_YTD','X_FRINGE_BENEFITS_ASG_YTD',
'X_CDEP_ASG_YTD','X_EARNINGS_TOTAL_ASG_YTD','X_WORKPLACE_DEDUCTIONS_ASG_YTD',
'X_LUMP_SUM_A_DEDUCTION_ASG_YTD','X_LUMP_SUM_A_PAYMENTS_ASG_YTD',
'X_LUMP_SUM_B_DEDUCTION_ASG_YTD','X_LUMP_SUM_B_PAYMENTS_ASG_YTD',
'X_LUMP_SUM_D_PAYMENTS_ASG_YTD','X_LUMP_SUM_E_PAYMENTS_ASG_YTD',
'X_TOTAL_TAX_DEDUCTIONS_ASG_YTD','X_OTHER_INCOME_ASG_YTD','X_UNION_FEES_ASG_YTD')
                   and   ff.context1= apac.assignment_action_id
             )
    group by apac.assignment_action_id;

  --------------------------------------------------------------------+
  -- PUBLIC cursor to select Employee ETP Payment Summary data.
  --------------------------------------------------------------------+
  /* Bug #2113363 - In the User Entity Name, add X_PRE_JUL_83_COMPONENT_ASG_YTD,
    X_POST_JUN_83_UNTAXED_ASG_YTD, X_POST_JUN_83_UNTAXED_ASG_YTD,X_INVALIDITY_PAYMENTS_ASG_YTD */
  /* Bug #2581412 - Used ORDERED hint and added few joins to improve performance */
  /* Bug #4570012 - Added Check for Employee Type in Cursor to ensure only terminated employees are picked */
  /* Bug #6630375 - Added Check for Assignment ID in both ARCHIVE and Magtape assignment actions */

  cursor etp_payment_summary_data_val IS    -- (Bug 3132178) Created to be called for spawned process
        select 'ASSIGNMENT_ACTION_ID=C',
               ppac.assignment_action_id ps_report_id
        from   pay_assignment_actions ppac,
               pay_payroll_actions mpa,
               pay_assignment_actions mpac
        where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
        AND    mpac.payroll_action_id = mpa.payroll_action_id /* Added for bug 6630375 */
        AND    mpac.assignment_id = ppac.assignment_id /* Added for bug 6630375 */
        AND    ppac.payroll_action_id =   pay_core_utils.get_parameter('ARCHIVE_PAYROLL_ACTION',mpa.legislative_parameters)
        AND    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG',  ppac.assignment_action_id)='YES'
        AND    pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG',ppac.assignment_action_id)='NO'   /* Added for bug 5257622 */
        and    pay_au_payment_summary.get_archive_value('X_SORT_EMPLOYEE_TYPE',ppac.assignment_action_id) = 'T'
        and    ppac.action_status = 'C'
        and    mpa.report_type = 'AU_PS_DATA_FILE_VAL'
        and    mpa.report_qualifier = 'AU'
        and    mpa.report_category = 'REPORT'
        and    1 <= (select sum(nvl(value,0))
                     from   ff_user_entities fue, ff_archive_items ff
                     where   fue.user_Entity_id = ff.user_entity_id
               and   fue.user_entity_name in
                         ('X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD',
                          'X_PRE_JUL_83_COMPONENT_ASG_YTD',
                          'X_POST_JUN_83_UNTAXED_ASG_YTD',
                          'X_POST_JUN_83_TAXED_ASG_YTD',
                         'X_INVALIDITY_PAYMENTS_ASG_YTD')
                   and   ff.context1= ppac.assignment_action_id
             )
        group by ppac.assignment_action_id;

  /* Bug #4570012 - Added Check for Employee Type in Cursor to ensure only terminated employees are picked */

  cursor etp_payment_summary_data is
        select /*+ORDERED*/ 'ASSIGNMENT_ACTION_ID=C',
               apac.assignment_action_id ps_report_id
        from
               pay_assignment_actions mpac, -- Magtape
               pay_action_interlocks mpai,
               pay_assignment_actions ppac,  --Self Printed
               pay_action_interlocks ppai,
               pay_assignment_actions apac,  --Archive
               pay_payroll_actions ppa      --Self Printed
        where  mpac.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
        and    mpac.action_status = 'C'
        and    ppac.action_status = 'C'
        and    mpac.assignment_Action_id = mpai.locking_action_id
        and    ppac.assignment_action_id =   mpai.locked_action_id
        and    ppai.locking_Action_id = ppac.assignment_action_id
        and    apac.assignment_action_id =   ppai.locked_action_id
        and    apac.payroll_action_id =   pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
        and    pay_au_payment_summary.get_archive_value('X_SORT_EMPLOYEE_TYPE',apac.assignment_action_id) = 'T'
        and    ppa.payroll_action_id =   ppac.payroll_Action_id
        and    ppa.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
        and    apac.assignment_id  = ppac.assignment_id
        and    ppac.assignment_id  = mpac.assignment_id
        and    1 <= (select sum(nvl(value,0))
                     from   ff_user_entities fue, ff_archive_items ff
                     where   fue.user_Entity_id = ff.user_entity_id
               and   fue.user_entity_name in
                         ('X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD',
                          'X_PRE_JUL_83_COMPONENT_ASG_YTD',
                          'X_POST_JUN_83_UNTAXED_ASG_YTD',
                          'X_POST_JUN_83_TAXED_ASG_YTD',
                          'X_INVALIDITY_PAYMENTS_ASG_YTD')
                   and   ff.context1= apac.assignment_action_id
             )
        group by apac.assignment_action_id;


end pay_au_payment_summary_magtape;

/
