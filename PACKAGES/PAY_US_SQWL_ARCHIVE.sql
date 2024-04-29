--------------------------------------------------------
--  DDL for Package PAY_US_SQWL_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_SQWL_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyussqwl.pkh 120.2.12010000.1 2008/07/27 23:56:48 appldev ship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   06-MAY-1998  NBRISTOW
   08-AUG-98    achauhan                Added rout nocopy ines for the Year End Pre-Process
   04-DEC-98    vmehta                  Changed definition for
                                                 check_residence_state
   27-OCT-99    rpotnuru    110.0       Created from existing file and
                                        Added two global variables g_sqwl_state and
                                        g_sqwl_jursd to fix NY burroughs problem
  03-DEC-99     rpotnuru    110.1       Added a function update_ff_archive_items
                                        which will update the value to 0 in case of 4th Qtr
                                        NY sqwl in case the employee doesnt have balances
                                        for 4th Qtr.

 10-FEB-2000  ashgupta      40.2        Added the global variable g_report_cat
                                        This variable is set in the archinit
                                        proc and is used in archive_Data proc.
                                        This contains the category of the
                                        SQWL i.e. RTM/RTS for the City of
                                        Oakland. Enhancement Req 1063413
 13-JUN-2000 asasthan      115.3        Q2 2000 changes in 11i.
 05-JUN-2001 tclewis       115.4        Added procedure archive_asg_locs.  This
                                        will archive the Assignment locations as of
                                        the 12th of the month, for each month of the
                                        quarter.
 21-FEB-2002 asasthan     115.6         Added dbdrv and checkfile.
 21-FEB-2002 asasthan     115.7         Removed previous EOY specific procedures
                                        not required by SQWLs.
                                        These are :

                                        PROCEDURE EOY_RANGE_CURSOR
                                        PROCEDURE EOY_ACTION_CREATION
                                        PROCEDURE EOY_ARCHIVE_DATA
                                        PROCEDURE EOY_ARCHINIT
 06-AUG-2003 fusman       115.8  3094891 Moved all the sqwl cursors to pay_us_sqwl_archive package header.
 11-Jan-2005 sackumar     115.11 4869678 Modified the cursor sqwl_employer_m to remove Merge Join Cartesian
					 Modified the cursor sqwl_employee_m to remove Merge Join Cartesian
					 Modified the cursor mmrf_nysqwl_employer to remove Full Table Scan on
					 hr_all_organization_units and hr_organization_information.
                                         Also replaced per_all_people_f by per_people_f
					 and per_all_assignment_f by per_assignment_f to reduce the shared memory.
  16-Aug-2006 sackumar    115.12 5379670 Created a global cursor MESQWL_RECONCILIATION.

*/
--  ***********SQWL Cursors Begin *************************

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

    level_cnt	NUMBER;

  --
 -- Used by most states for State Quarterly Wage Listing.
 --
 -- Sets up the tax unit context for each employer to be reported on NB. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.  The
 -- payroll action id context is used for the Archive DB Items.
 -- The Date_Earned Context is used for balances with dimensions of
 --  "GRE_JD_QTD"  -- Notably Pennsylvania SUI_EE_GROSS.  Added join to payroll
 --  action table.
 --
 cursor sqwl_employer is
   select distinct
          'PAYROLL_ACTION_ID=C', AA.payroll_action_id,
	  'TAX_UNIT_ID=C'      , AA.tax_unit_id,
	  'TAX_UNIT_ID=P'      , AA.tax_unit_id,
	  'JURISDICTION_CODE=C', SR.jurisdiction_code,
	  'DATE_EARNED=C'     ,fnd_date.date_to_canonical(PA.effective_date),
          'BUSINESS_GROUP_ID=C', PA.business_group_id,
          'TRANSFER_BUSINESS_GROUP_ID=P', PA.business_group_id
     from pay_state_rules        SR,
          pay_assignment_actions AA,
          pay_payroll_actions    PA
    where AA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  PA.payroll_action_id = AA.payroll_action_id
     and  SR.state_code        = pay_magtape_generic.get_parameter_value
			           ('TRANSFER_STATE');

 -- Used by California (Multi Wage Plan) for State Quarterly Wage Listing.
 -- Added by Ashu Gupta (ashgupta) on 10-FEB-2000
 --
 -- Sets up the tax unit context for each employer to be reported on NB. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.  The
 -- payroll action id context is used for the Archive DB Items.
 -- The Date_Earned Context is used for balances with dimensions of
 --  "GRE_JD_QTD"  -- Notably Pennsylvania SUI_EE_GROSS.  Added join to payroll
 --  action table. The order by clause is added in the SQL, so that all the
 --  records of a GRE come together.
 --
 cursor sqwl_employer_m is
   select distinct
          'PAYROLL_ACTION_ID=C', AA.payroll_action_id,
	  'TAX_UNIT_ID=C'      , AA.tax_unit_id,
	  'TAX_UNIT_ID=P'      , AA.tax_unit_id,
	  'JURISDICTION_CODE=C', SR.jurisdiction_code,
	  'DATE_EARNED=C'      , fnd_date.date_to_canonical(PA.effective_date),
          'BUSINESS_GROUP_ID=C', PA.business_group_id,
          'TRANSFER_COMPANY_SUI_ID=P', hoi.org_information2,
          'TRANSFER_WAGE_PLAN_CODE=P', hoi.org_information3,
          'TRANSFER_REPORT_FORMAT=P', pay_magtape_generic.get_parameter_value
                                       ('TRANSFER_REPORT_CATEGORY')
   from   pay_payroll_actions         PA,
          pay_assignment_actions      AA,
	  pay_state_rules             SR,
          hr_organization_information hoi
   where  AA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  PA.payroll_action_id = AA.payroll_action_id
     and  SR.state_code        = pay_magtape_generic.get_parameter_value
			           ('TRANSFER_STATE')
     and  hoi.org_information_context = 'PAY_US_STATE_WAGE_PLAN_INFO'
     and  hoi.organization_id    = AA.tax_unit_id
     and  hoi.org_information1   = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_STATE')
     and  EXISTS (SELECT /*+ ordered */NULL
                  FROM  pay_assignment_actions  paa,
                        ff_archive_items        fai,
                         ff_user_entities        fue
                  WHERE fai.context1 = paa.assignment_action_id
                  AND   paa.payroll_action_id = AA.payroll_action_id
                  AND   fue.user_entity_id    = fai.user_entity_id
                  AND   fue.user_entity_name  = 'A_SCL_ASG_US_CA_WAGE_PLAN_CODE'
                  AND   paa.tax_unit_id       = AA.tax_unit_id
                  AND   fai.value             = hoi.org_information3 )
   order by 4 ;


 --
 -- Used by most states for State Quarterly Wage Listing.
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --
cursor sqwl_transmitter is
   select 'TAX_UNIT_ID=C',
          pay_magtape_generic.get_parameter_value
               ('TRANSFER_TRANS_LEGAL_CO_ID'),
	  'JURISDICTION_CODE=C',
          SR.jurisdiction_code,
          'PAYROLL_ACTION_ID=C',
          pay_magtape_generic.get_parameter_value
                    ('TRANSFER_PAYROLL_ACTION_ID'),
          'TRANSFER_SUI_WAGE_BASE=P',
           nvl(FFAI.value,' ')
     from pay_state_rules SR,
          ff_archive_items ffai,
          ff_database_items fdi
    where SR.state_code = pay_magtape_generic.get_parameter_value
			     ('TRANSFER_STATE')
      and ffai.user_entity_id = fdi.user_entity_id
      and fdi.user_name = 'A_SUI_TAXABLE_WAGE_BASE'
      and ffai.context1 = pay_magtape_generic.get_parameter_value
                          ('TRANSFER_PAYROLL_ACTION_ID');

 cursor sqwl_employee is
   select 'TRANSFER_ASS_ACTION_ID=C', AA.assignment_action_id,
	  'ASSIGNMENT_ACTION_ID=C'  , AA.assignment_action_id,
	  'ASSIGNMENT_ID=C'         , AA.assignment_id,
	  'ASSIGNMENT_ID=P'         , AA.assignment_id, /* Bug 976472 */
	  'DATE_EARNED=C'           ,fnd_date.date_to_canonical(pay_magtape_generic.date_earned
          (PA.effective_date, AA.assignment_id))
from	  per_all_people_f           PE,
	  per_all_assignments_f      SS,
	  pay_assignment_actions AA,
          pay_payroll_actions    PA
   where  PA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  AA.payroll_action_id = PA.payroll_action_id
     and  AA.tax_unit_id    = pay_magtape_generic.get_parameter_value
                                   ('TAX_UNIT_ID')
     and  SS.assignment_id     = AA.assignment_id
     and  PE.person_id         = SS.person_id
     /* commented for bug 2464463
        and  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) between
	SS.effective_start_date and SS.effective_end_date
        and  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) between
        PE.effective_start_date and PE.effective_end_date
     */

      /* Added for bug 2464463 */
      AND   SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_all_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
		     and paf2.assignment_type = 'E')
      AND SS.effective_end_date >= PA.start_date
      AND SS.assignment_type = 'E'
      AND LEAST(SS.effective_end_date, PA.effective_date)
          between PE.effective_start_date and PE.effective_end_date
	/* End of Change for bug 2464463 */
   order  by PE.last_name, PE.first_name, PE.middle_names;

-- Used in case the report category is RTM
-- This cursor expects that every person will have at least a single row
-- in ff_archive_items table for wage plan code. Added by ashgupta on
-- 10-FEB-2000 for enhancement request req 1063413
   cursor sqwl_employee_m is
   select /*+ ORDERED */ 'TRANSFER_ASS_ACTION_ID=C', AA.assignment_action_id,
	  'ASSIGNMENT_ACTION_ID=C'  , AA.assignment_action_id,
	  'ASSIGNMENT_ID=C'         , AA.assignment_id,
	  'ASSIGNMENT_ID=P'         , AA.assignment_id,
	  'DATE_EARNED=C'           , fnd_date.date_to_canonical(pay_magtape_generic.date_earned
				        (PA.effective_date,
                                         AA.assignment_id)),
          'TRANSFER_WAGE_PLAN_CODE=P',pay_magtape_generic.get_parameter_value
                                          ('TRANSFER_WAGE_PLAN_CODE'),
          'TRANSFER_REPORT_FORMAT=P', pay_magtape_generic.get_parameter_value
                                       ('TRANSFER_REPORT_CATEGORY')
   from   pay_payroll_actions    PA,
	  pay_assignment_actions AA,
	  per_all_assignments_f      SS,
	  per_all_people_f           PE,
          ff_archive_items       fai,
          ff_user_entities       fue
   where  PA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  AA.payroll_action_id = PA.payroll_action_id
     and  AA.tax_unit_id    = pay_magtape_generic.get_parameter_value
                                   ('TAX_UNIT_ID')
     and  SS.assignment_id     = AA.assignment_id
     and  PE.person_id         = SS.person_id
     /* commented for bug 2464463
     and  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) between
	    SS.effective_start_date and SS.effective_end_date
     and  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) between
	    PE.effective_start_date and PE.effective_end_date
     */
     /*  Added for bug 2464463 */
      AND   SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_all_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
		     and paf2.assignment_type = 'E')
      AND SS.effective_end_date >= PA.start_date
      AND SS.assignment_type = 'E'
      AND LEAST(SS.effective_end_date, PA.effective_date)
          between PE.effective_start_date and PE.effective_end_date
	/* End of Change for bug 2464463 */
      AND  aa.assignment_action_id = fai.context1
     and  fai.value =
             pay_magtape_generic.get_parameter_value('TRANSFER_WAGE_PLAN_CODE')
     and  fai.user_entity_id = fue.user_entity_id
     and  fue.user_entity_name = 'A_SCL_ASG_US_CA_WAGE_PLAN_CODE'
     and  NOT EXISTS (SELECT value
                      FROM   ff_archive_items fai1
                      WHERE  fai1.context1 = fai.context1
                      AND    fai1.value    = fai.value
                      AND    fai1.archive_item_id > fai.archive_item_id
                      AND    fai1.user_entity_id  = fai.user_entity_id)
   order  by PE.last_name, PE.first_name, PE.middle_names;


/****  Bug 976472 *********/
 --
 -- Used by NY state for State Quarterly Wage Listing.
 --
 -- Sets up the Jurisdiction Code (for NY City and 5 burroughs)  contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
/******
 cursor sqwl_employee_jurisdiction is
    Select distinct
            'JURISDICTION_CODE=C', pcty.jurisdiction_code
     from   pay_us_emp_city_tax_rules_f pcty,
            per_assignments_f paf1,
            per_assignments_f paf
     where  paf.assignment_id  = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
     and    paf.effective_end_date >=
to_date('01-01-2001','DD-MM-YYYY')
     and    paf.effective_start_date <=
to_date('31-03-2001','DD-MM-YYYY')
     and    paf1.person_id = paf.person_id
     and    paf1.effective_end_date >=
to_date('01-01-2001','DD-MM-YYYY')
     and    paf1.effective_start_date <=
to_date('31-03-2001','DD-MM-YYYY')
     and    pcty.assignment_id = paf1.assignment_id
     and    pcty.effective_start_date <=
to_date('31-03-2001','DD-MM-YYYY')
     and    pcty.effective_end_date >=
to_date('01-01-2001','DD-MM-YYYY')
     and    pcty.jurisdiction_code in ('33-005-2010',
                                       '33-047-2010',
                                       '33-061-2010',
                                       '33-081-2010',
                                       '33-085-2010',
                                       '33-119-3230');

*****/
 cursor sqwl_employee_jurisdiction is
/* commented for bug 2852640
    Select distinct
            'JURISDICTION_CODE=C', pcty.jurisdiction_code
     from   pay_us_emp_city_tax_rules_f pcty,
            per_assignments_f paf1,
            per_assignments_f paf
     where  paf.assignment_id  = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
     and    paf.effective_end_date >= (
                 select
                    decode(
                          to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER') ,'MMYYYY'),'Q'),
                          '4',
                          trunc(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY'),'Y'),
                          trunc(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY'),'Q')
                          )
                 from dual
                                      )
     and    paf.effective_start_date <=
                to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE'),'DD-MM-YYYY')
     and    paf1.person_id = paf.person_id
     and    paf1.effective_end_date >=(
                 select
                    decode(
                          to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER') ,'MMYYYY'),'Q'),
                          '4',
                          trunc(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY'),'Y'),
                          trunc(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY'),'Q')
                          )
                 from dual
                                      )
     and    paf1.effective_start_date <=
                to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE'),'DD-MM-YYYY')
     and    pcty.assignment_id = paf1.assignment_id
     and    pcty.effective_start_date <=
                to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE'),'DD-MM-YYYY')
     and    pcty.effective_end_date >=(
                 select
                    decode(
                          to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER') ,'MMYYYY'),'Q'),
                          '4',
                          trunc(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY'),'Y'),
                          trunc(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY'),'Q')
                          )
                 from dual
                                      )
     and    pcty.jurisdiction_code in ('33-005-2010',
                                       '33-047-2010',
                                       '33-061-2010',
                                       '33-081-2010',
                                       '33-085-2010',
                                       '33-119-3230');
*/
select  distinct 'JURISDICTION_CODE=C', context
from ff_archive_items fai,
    ff_archive_item_contexts faic,
    pay_assignment_actions paa,
    pay_payroll_actions ppa
where ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and ppa.payroll_action_id = paa.payroll_action_id
and paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
and fai.context1 = paa.assignment_action_id
and faic.archive_item_id = fai.archive_item_id
and faic.context in ('33-005-2010',
                     '33-047-2010',
                     '33-061-2010',
                     '33-081-2010',
                     '33-085-2010',
                     '33-119-3230');

/**** End Bug 976472*****/
 --

/* added for MMREF SQWLs */

/* for bug 2752145, commented the join with hr_organization_information,
   this to remove the dependency on W2 reporting rules for SQWL */
   cursor mmrf_sqwl_transmitter is
   select 'TAX_UNIT_ID=C',
   pay_magtape_generic.get_parameter_value ('TRANSFER_TRANS_LEGAL_CO_ID'),
   'JURISDICTION_CODE=C', SR.jurisdiction_code,
   'TRANSFER_JD=P', SR.jurisdiction_code,
   'ASSIGNMENT_ID=C' , '-1',
   'DATE_EARNED=C', fnd_date.date_to_canonical(ppa.effective_date),
   'PAYROLL_ACTION_ID=C',
    pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),
--   'TRANSFER_2678_FILER=P', HOI.org_information8,
   'BUSINESS_GROUP_ID=C'  , PPA.business_group_id,
   'TRANSFER_BUSINESS_GROUP_ID=P',PPA.business_group_id,
   'TRANSFER_SUI_WAGE_BASE=P', nvl(FFAI.value,' '),
   'TRANSFER_REPORT_CATEGORY=P', pay_magtape_generic.get_parameter_value
                                       ('TRANSFER_REPORT_CATEGORY')
   from pay_state_rules SR,
          ff_archive_items ffai,
          ff_database_items fdi,
--          hr_organization_information hoi,
          pay_payroll_actions ppa
    where ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value
                                        ('TRANSFER_PAYROLL_ACTION_ID')
 --   and hoi.organization_id    =  pay_magtape_generic.get_parameter_value
--                                        ('TRANSFER_TRANS_LEGAL_CO_ID')
 --    and hoi.org_information_context = 'W2 Reporting Rules'
     and SR.state_code          = pay_magtape_generic.get_parameter_value
                                        ('TRANSFER_STATE')
      and ffai.user_entity_id = fdi.user_entity_id
      and fdi.user_name = 'A_SUI_TAXABLE_WAGE_BASE'
      and ffai.context1 = pay_magtape_generic.get_parameter_value
                                        ('TRANSFER_PAYROLL_ACTION_ID');



 cursor mmrf_sqwl_employer is
   select distinct
          'PAYROLL_ACTION_ID=C', AA.payroll_action_id,
	  'TAX_UNIT_ID=C'      , AA.tax_unit_id,
	  'TAX_UNIT_ID=P'      , AA.tax_unit_id,
	  'DATE_EARNED=C'      , fnd_date.date_to_canonical(PA.effective_date),
          'TAX_UNIT_NAME=P'    , hou.name
     from hr_all_organization_units     hou,
          pay_assignment_actions        AA,
          pay_payroll_actions           PA
    where AA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  PA.payroll_action_id = AA.payroll_action_id
     and  AA.tax_unit_id = hou.organization_id
     order by hou.name;

--sackumar
  cursor mmrf_nysqwl_employer is
   select /*+ index (hoi hr_organization_informatio_FK1)
              index(hou hr_organization_units_PK)
          */  distinct
          'PAYROLL_ACTION_ID=C', AA.payroll_action_id,
          'TAX_UNIT_ID=C'      , AA.tax_unit_id,
          'TAX_UNIT_ID=P'      , AA.tax_unit_id,
          'DATE_EARNED=C'      , fnd_date.date_to_canonical(PA.effective_date),
          'TAX_UNIT_NAME=P'    , hou.name,
	  'FEIN=P'	       , hoi.org_information1
     from hr_all_organization_units     hou,
	  hr_organization_information   hoi,
          pay_assignment_actions        AA,
          pay_payroll_actions           PA
    where AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
     and  PA.payroll_action_id = AA.payroll_action_id
     and  AA.tax_unit_id = hou.organization_id
     and  hoi.organization_id = hou.organization_id
     and  hoi.org_information_context = 'Employer Identification'
     order by hoi.org_information1;

 cursor mmrf_sqwl_employee is
   select 'TRANSFER_ASS_ACTION_ID=C', AA.assignment_action_id,
	  'ASSIGNMENT_ACTION_ID=C'  , AA.assignment_action_id,
	  'ASSIGNMENT_ID=C'         , AA.assignment_id,
	  'ASSIGNMENT_ID=P'         , AA.assignment_id, /* Bug 976472 */
	  'DATE_EARNED=C'           ,fnd_date.date_to_canonical(pay_magtape_generic.date_earned(PA.effective_date, AA.assignment_id))
from	  per_all_people_f           PE,
	  per_all_assignments_f      SS,
	  pay_assignment_actions AA,
          pay_payroll_actions    PA
   where  PA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  AA.payroll_action_id = PA.payroll_action_id
     and  AA.tax_unit_id    = pay_magtape_generic.get_parameter_value
                                   ('TAX_UNIT_ID')
     and  SS.assignment_id     = AA.assignment_id
     and  PE.person_id         = SS.person_id
          /* commented for bug 2464463
     and  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) between
            SS.effective_start_date and SS.effective_end_date
     and  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) between
            PE.effective_start_date and PE.effective_end_date
     */
     /*  Added for bug 2464463 */
      AND   SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
		     and paf2.assignment_type = 'E')
      AND SS.effective_end_date >= PA.start_date
      AND SS.assignment_type = 'E'
      AND LEAST(SS.effective_end_date, PA.effective_date)
          between PE.effective_start_date and PE.effective_end_date
	/* End of Change for bug 2464463 */
   order  by PE.last_name, PE.first_name, PE.middle_names;

/*Bug # 5379670*/
 cursor sqwl_reconciliation is
    select 'TRANSFER_DATE_WAGES_PAID_ME=P',  hoi.org_information2,
              'TRANSFER_AMOUNT_WITHHELD_ME=P',  hoi.org_information3,
              'TRANSFER_PAYMENT_DEPOSITED_ME=P', hoi.org_information4
   from   pay_state_rules             SR,
          hr_organization_information hoi
   where  SR.state_code        = pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
     and  hoi.org_information_context = 'SQWL Employer Rules 3'
     and  hoi.organization_id    = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
     and  hoi.org_information1   = pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
     and to_date(hoi.org_information2,'YYYY/MM/DD HH24:MI:SS') between
	    add_months(last_day(to_date(
	    pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER')
	    ,'MMYYYY')),-3) + 1
	    and last_day(to_date(pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_QUARTER'),'MMYYYY')) ;

--  ***********SQWL Cursors Ends *************************

TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
TYPE number_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;
g_min_chunk    number:= -1;
g_archive_flag varchar2(1) := 'N';

/* Bug 976472 */
g_sqwl_state   varchar2(2);
g_sqwl_jursd   varchar2(11);
/* End Bug 976472 */

/* Added by Ashu Gupta on 10-FEB-2000 */
g_report_cat pay_report_format_mappings_f.report_category%TYPE;

procedure range_cursor(pactid in  number,
                       sqlstr out  nocopy  varchar2);
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);
FUNCTION check_residence_state (
        p_assignment_id NUMBER,
        p_period_start  DATE,
        p_period_end    DATE,
        p_state         VARCHAR2,
                  p_effective_end_date DATE
 ) RETURN BOOLEAN;

procedure archive_data(p_assactid in number, p_effective_date in date);
procedure archinit(p_payroll_action_id in number);
FUNCTION Update_ff_archive_items (
                                  p_payroll_action_id in VARCHAR2
                                 )
         return varchar;
/* Bug 773937 */
procedure archive_gre_data(p_payroll_action_id in number,
                           p_tax_unit_id       in number);
/* End of Bug 773937 */

procedure archive_asg_locs( p_asg_act_id       in number
                           ,p_pay_act_id       in number
                           ,p_asg_id           in number);

--
end pay_us_sqwl_archive;

/
