--------------------------------------------------------
--  DDL for Package Body PAY_PAYACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYACT_PKG" as
/* $Header: pypayact.pkb 120.1.12010000.2 2008/08/06 08:10:40 ubhat ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_payact_pkg

    Description : This package defines the cursors needed to run
                  Payroll Activity Report for Multi-Threaded

    Note : For all the different action type there is a sqlstr in the
           range cursor and action creation cursor. This is required
           because in the Activity report before the report runs we
           insert the number of records per thread in the table
           pay_us_rpt_totals which is used to get Rpt Seq Id. If the
           report is run for a specific action type this Id will not
           show correct value.

   Change List
   -----------
   Date         Name        Vers         Description
   -----------  ----------  -----        ----------------------------
   05-APR-1999  meshah      40.0/110.0   created
   04-AUG-1999  rmonge      40.0/110.1   Made package body adchkdrv
                                         compliant.
   26-SEP-2000  sravuri     115.2        Added Assignment Set
                                         functionality to the package.
   13-APR-2001  ahanda      115.3        Changed HR_LOCATIONS to
                                         HR_LOCATIONS_ALL.
   26-apr-2001  tclewis     115.4        modified the cursor(s) in the
                                         range_cursor and action creation
                                         to use secure views.  Modified
                                         the sql query in the sort_code
                                         routine to use base tables.
   21-oct-2002  tclewis     115.5        commented out the "for update..."
                                         in the action_creation cursor.
                                         changed the locking on the sort_cursor
                                         from paf.assignment_id to paa.
   16-SEP-2003  sdahiya     115.7	 modified the sort_action procedure
					 (Bug# 3037633).Added nocopy changes
   16-OCT-2003  sdahiya     115.8	 Modified sort_action procedure so that
					 it sorts data first on employee name
					 and later on date paid (Bug 3037633).
   09-FEB-2004  ssmukher    115.9        11.5.10 Performance Fix (Bug 3372732)
                                         in action_creation
   23-AUG-2005  jgoswami    115.10       R12 Performance Fix (Bug 4347329)
                                         in range_creation
   16-Jun-2008  pannapur    115.11       Modified the cursor definitions of all
                                         process types to generate proper sequence id
                                         (6854964)

*/

-------------------------------- range_cursor ----------------------------------
PROCEDURE range_cursor (pactid in number,
                        sqlstr out nocopy varchar2) is

--
  leg_param    pay_payroll_actions.legislative_parameters%type;

  l_business_group_id    number;
  l_consolidation_set_id number;
  l_payroll_id           number;
  l_organization_id      number;
  l_location_id          number;
  l_person_id            number;
  l_leg_start_date       date;
  l_leg_end_date         date;

  pay_process              varchar2(40);
  l_payroll_text           varchar2(70);
  l_consolidation_set_text varchar2(50);
--

begin
   select legislative_parameters
     into leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

--    pay_process := pay_payact_pkg.get_parameter('P_P_TY',leg_param);

  select ppa.legislative_parameters,
          pay_payrg_pkg.get_parameter('P_P_TY', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('C_ST_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('PY_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('O_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('L_ID', ppa.legislative_parameters),
          pay_payrg_pkg.get_parameter('P_ID', ppa.legislative_parameters),
          ppa.start_date,
          ppa.effective_date,
          ppa.business_group_id
     into leg_param,
          pay_process,
          l_consolidation_set_id,
          l_payroll_id,
          l_organization_id,
          l_location_id,
          l_person_id,
          l_leg_start_date,
          l_leg_end_date,
          l_business_group_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

    IF l_consolidation_set_id is not null THEN

       l_consolidation_set_text := 'and pa1.consolidation_set_id = ' || to_char(l_consolidation_set_id) ;

    ELSE

        l_consolidation_set_text := NULL;

    END IF;

    IF l_payroll_id is not null THEN

       l_payroll_text := 'and pa1.payroll_id = ' || to_char(l_payroll_id) ;

    ELSE

         l_payroll_text := null;

    END IF;

/* pay act  */

-- if pay process type (P_P_TY) is balance adjustement
-- if pay_process = 'BA' then
--    action_type = 'B'
-- if pay process type (P_P_TY) is balance initialization
-- if pay_process = 'BI' then
--    action_type = 'I'
-- if pay process type (P_P_TY) is balance adjustement and  balance initilization
-- if pay_process = 'BAI' then
--    action_type in ('B','I')
-- if P_P_TY is RUN
-- if pay_process = 'PR' then
--    action_type = 'R'
-- if P_P_TY is Quick Pay
-- if pay_process = 'QP' then
--    action_type = 'Q'
-- if P_P_TY is RUN and Quick Pay
-- if pay_process = 'PRQP' then
--    action_type in ('R','Q')
-- if P_P_TY is Reversal
-- if pay_process = 'REV' then
--    action_type = 'V'
-- if pay_process = 'ALL' then
-- if P_P_TY is ALL then
--    action_type in ('B','D','I','R','Q','V')

-- Modified to a single sql statement with dynamic selection criteria
-- for payroll and consolidation set

    sqlstr :=
      'select distinct asg.person_id
         from pay_payroll_actions    ppa,
              pay_payroll_actions    pa1,
              pay_assignment_actions act,
              per_assignments_f      asg
         where ppa.payroll_action_id    = :payroll_action_id
                '||l_consolidation_set_text||'
                '||l_payroll_text||'
                and pa1.effective_date between ppa.start_date
                                           and ppa.effective_date
                and pa1.effective_date between asg.effective_start_date
                                           and asg.effective_end_date
                and pa1.action_type in (''B'',''D'',''I'',''R'',''Q'',''V'')
                and pa1.payroll_action_id = act.payroll_action_id
                and asg.assignment_id = act.assignment_id
                and act.action_status = ''C''
                and asg.organization_id = nvl('''||l_organization_id||''',
                                                    asg.organization_id)
                and asg.location_id     = nvl('''||l_location_id||''',
                                                    asg.location_id)
                and asg.person_id       = nvl('''||l_person_id||''',
                                                    asg.person_id)
                and asg.business_group_id +0 = ppa.business_group_id
              order by asg.person_id';

end range_cursor;

---------------------------------- action_creation ----------------------------------
PROCEDURE action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  -- Bug 3372732 : cursor created to fetch legislative parameter values for
  --               Payroll Activity generated Payroll Action
  -- All the values will be passed to cursors below

  CURSOR c_inputs(pactid     number) is  -- Bug 3372732
       select pay_payrg_pkg.get_parameter('PY_ID',ppa.legislative_parameters) payroll_id,
	      pay_payrg_pkg.get_parameter('C_ST_ID',ppa.legislative_parameters) consolidation_set_id,
	      pay_payrg_pkg.get_parameter('T_U_ID',ppa.legislative_parameters) tax_unit_id,
	      pay_payrg_pkg.get_parameter('L_ID',ppa.legislative_parameters) location_id,
	      pay_payrg_pkg.get_parameter('O_ID',ppa.legislative_parameters) organization_id,
	      pay_payrg_pkg.get_parameter('P_ID',ppa.legislative_parameters) person_id,
	      pay_payrg_pkg.get_parameter('B_G_ID',ppa.legislative_parameters) business_group_id,
	      ppa.start_date start_date,
	      ppa.effective_date effective_date
       from   pay_payroll_actions  ppa
       where  ppa.payroll_action_id = pactid;


  -- Bug 3372732 : All cursors defined below are changed
  -- to include pay_payrolls_f and inputs from
  -- cursor c_inputs .

  CURSOR c_bal_adj
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id 		number,
	 c_consolidation_set_id number,
	 c_tax_unit_id 		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date
      ) is  --Bug 3372732
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions act,
             per_assignments_f      paf,
             pay_payroll_actions    ppa,     /* pre-payments and reversals
                                                payroll action id */
             pay_payrolls_f         ppf -- Bug 3372732
      where  ppa.payroll_id               =  nvl(c_payroll_id,ppa.payroll_id)
      and    ppa.consolidation_set_id + 0 =  nvl(c_consolidation_set_id,
                                                 ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date
                                    and c_effective_date
      and    act.tax_unit_id              = nvl(c_tax_unit_id ,act.tax_unit_id)
      and    paf.organization_id = nvl(c_organization_id,paf.organization_id)
      and    paf.location_id     = nvl(c_location_id,paf.location_id)
      and    paf.person_id       = nvl(c_person_id,paf.person_id)
      and    paf.business_group_id + 0 = c_business_group_id
      and    ppa.action_type     = 'B'
      and    act.action_status   = 'C'
      and    act.payroll_action_id = ppa.payroll_action_id
      and    paf.assignment_id   = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
                                    and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id = ppf.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
                                    and ppf.effective_end_date
      and    ppf.payroll_id >= 0
      --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;



  CURSOR c_bal_ini
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id		number,
	 c_consolidation_set_id number,
	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date
      ) is  -- Bug 3372737
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions act,
             per_assignments_f      paf,
             pay_payroll_actions    ppa,   /* pre-payments and reversals payroll action id */
	     pay_payrolls_f	    ppf -- Bug 3372732
      where  ppa.payroll_id 	      =  nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0    =
                nvl(c_consolidation_set_id, ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id          =  nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id      =  nvl(c_organization_id,
				            paf.organization_id)
      and    paf.location_id  	      =  nvl(c_location_id, paf.location_id)
      and    paf.person_id            =  nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0 = c_business_group_id
      and    ppa.action_type 	      = 'I'
      and    act.action_status        = 'C'
      and    act.payroll_action_id    = ppa.payroll_action_id
      and    paf.assignment_id        = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id = ppf.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id 	      >= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

  CURSOR c_bal_adj_ini
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id		number,
	 c_consolidation_set_id	number,
	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date

      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions  act,
             per_assignments_f       paf,
             pay_payroll_actions     ppa,   /* pre-payments and reversals payroll action id */
             pay_payrolls_f	     ppf -- Bug 3372732
      where  ppa.payroll_id =
        	nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0    =
                nvl(c_consolidation_set_id, ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id      = nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id  = nvl(c_organization_id, paf.organization_id)
      and    paf.location_id      = nvl(c_location_id, paf.location_id)
      and    paf.person_id        = nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0 = c_business_group_id
      and    ppa.action_type in ('B','I')
      and    act.action_status 	  = 'C'
      and    act.payroll_action_id = ppa.payroll_action_id
      and    paf.assignment_id    = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id 	  = ppf.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id >= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

CURSOR c_run
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id 		number,
	 c_consolidation_set_id	number,
 	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date

      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions act,
             per_assignments_f      paf,
             pay_payroll_actions    ppa,   /* pre-payments and reversals  */
					   /* payroll action id */
             pay_payrolls_f 	    ppf	-- Bug 3372732
      where  ppa.payroll_id 	=   nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0    =   nvl(c_consolidation_set_id,
						    ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id    =  nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id=  nvl(c_organization_id, paf.organization_id)
      and    paf.location_id    =  nvl(c_location_id, paf.location_id)
      and    paf.person_id      =  nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0 = c_business_group_id
      and    ppa.action_type 	= 'R'
      and    act.action_status  = 'C'
      and    act.payroll_action_id  = ppa.payroll_action_id
      and    paf.assignment_id  = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id = ppf.payroll_id --  Bug3372732
      and    ppa.effective_date  between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id 	>= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

CURSOR c_qp
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id 		number,
	 c_consolidation_set_id	number,
	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date

      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions  act,
             per_assignments_f       paf,
             pay_payroll_actions     ppa,   /* pre-payments and  */
					   /* reversals payroll action id */
             pay_payrolls_f          ppf	-- Bug 3372732
      where  ppa.payroll_id                 = nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0    = nvl(c_consolidation_set_id,
						  ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id                = nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id            = nvl(c_organization_id,
						  paf.organization_id)
      and    paf.location_id                = nvl(c_location_id, paf.location_id)
      and    paf.person_id 		    = nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0 	    = c_business_group_id
      and    ppa.action_type 		    = 'Q'
      and    act.action_status 		    = 'C'
      and    act.payroll_action_id          = ppa.payroll_action_id
      and    paf.assignment_id              = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppf.payroll_id = ppa.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id  		    >= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

CURSOR c_run_qp
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id		number,
	 c_consolidation_set_id	number,
	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date
      ) is -- Bug 3372732
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions act,
             per_assignments_f      paf,
             pay_payroll_actions    ppa,   /* pre-payments and  */
					/* reversals payroll action id */
	     pay_payrolls_f 	    ppf
      where  ppa.payroll_id  	         = nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0 = nvl(c_consolidation_set_id,
					       ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id 		 = nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id         = nvl(c_organization_id ,paf.organization_id)
      and    paf.location_id 		 = nvl(c_location_id, paf.location_id)
      and    paf.person_id 		 = nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0 	 = c_business_group_id
      and    ppa.action_type in ('R','Q')
      and    act.action_status 		 = 'C'
      and    act.payroll_action_id       =  ppa.payroll_action_id
      and    paf.assignment_id           = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id = ppf.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id >= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

CURSOR c_rev
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id		number,
	 c_consolidation_set_id number,
	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date
      ) is	--Bug 3372732
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions  act,
             per_assignments_f       paf,
             pay_payroll_actions     ppa,   /* pre-payments and */
					     /* reversals payroll action id */
             pay_payrolls_f	     ppf  -- Bug 3372732
      where  ppa.payroll_id =
                nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0 = nvl(c_consolidation_set_id,
					      ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id 		 = nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id 	 = nvl(c_organization_id, paf.organization_id)
      and    paf.location_id 		 = nvl(c_location_id, paf.location_id)
      and    paf.person_id 		 = nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0    = c_business_group_id
      and    ppa.action_type 		 = 'V'
      and    act.action_status 		 = 'C'
      and    act.payroll_action_id       =  ppa.payroll_action_id
      and    paf.assignment_id           = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id  		 = ppf.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id 		 >= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

CURSOR c_all
      (
         c_stperson  		number,
         c_endperson 		number,
	 c_payroll_id		number,
	 c_consolidation_set_id	number,
	 c_tax_unit_id		number,
	 c_location_id		number,
	 c_organization_id	number,
	 c_person_id		number,
	 c_business_group_id	number,
	 c_start_date		date,
	 c_effective_date	date
      ) is  -- Bug 3372732
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id
      from   pay_assignment_actions  act,
             per_assignments_f       paf,
             pay_payroll_actions     ppa,   /* pre-payments and  */
					    /* reversals payroll action id */
             pay_payrolls_f          ppf
      where  ppa.payroll_id 		 = nvl(c_payroll_id, ppa.payroll_id)
      and    ppa.consolidation_set_id +0 = nvl(c_consolidation_set_id ,ppa.consolidation_set_id)
      and    ppa.effective_date between c_start_date and c_effective_date
      and    act.tax_unit_id             = nvl(c_tax_unit_id,act.tax_unit_id)
      and    paf.organization_id 	 = nvl(c_organization_id,
					       paf.organization_id)
      and    paf.location_id 		 = nvl(c_location_id, paf.location_id)
      and    paf.person_id 		 = nvl(c_person_id, paf.person_id)
      and    paf.business_group_id +0    = c_business_group_id
      and    ppa.action_type in ('B','D','I','R','Q','V')
      and    act.action_status 		 = 'C'
      and    act.payroll_action_id       = ppa.payroll_action_id
      and    paf.assignment_id           = act.assignment_id
      and    ppa.effective_date between paf.effective_start_date
					and paf.effective_end_date
      and    paf.person_id between stperson and endperson
      and    ppa.payroll_id  		 = ppf.payroll_id -- Bug 3372732
      and    ppa.effective_date between ppf.effective_start_date
					and ppf.effective_end_date
      and    ppf.payroll_id		 >= 0
         --added for bug 6854964
       AND ((nvl(act.run_type_id, ppa.run_type_id) is null and
           act.source_action_id is null)
       or (nvl(act.run_type_id, ppa.run_type_id) is not null and
           act.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           act.run_type_id is not null and
           act.source_action_id is null))
      --end of addition
      ORDER BY act.assignment_action_id;
--      for update of paf.assignment_id;

--
      lockingactid  number;
      lockedactid   number;
      assignid      number;
      greid         number;
      num           number;
      process_type  varchar2(20);

      -- Bug 3372732
      leg_param     pay_payroll_actions.legislative_parameters%type;
      ass_set_id    number;
      ass_flag	    varchar2(2);

--
      l_payroll_id  			pay_payroll_actions.payroll_id%TYPE;
      l_location_id  			per_all_assignments_f.location_id%TYPE;
      l_consolidation_set_id  		pay_payroll_actions.consolidation_set_id%TYPE;
      l_tax_unit_id  			pay_assignment_actions.tax_unit_id%TYPE;
      l_person_id			per_all_assignments_f.person_id%TYPE;
      l_business_group_id		per_all_assignments_f.business_group_id%TYPE;
      l_organization_id			per_all_assignments_f.organization_id%TYPE;
      l_start_date			pay_payroll_actions.effective_date%TYPE;
      l_effective_date			pay_payroll_actions.effective_date%TYPE;

   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   begin

      hr_utility.set_location('procpyr',1);

	select legislative_parameters into leg_param
	from pay_payroll_actions
	where payroll_action_id = pactid;

        --  Bug 3372732:Fetching the Input parameters that are passed to other cursors
	open c_inputs(pactid);

		fetch c_inputs into l_payroll_id,
				    l_consolidation_set_id,
	   			    l_tax_unit_id,
				    l_location_id,
				    l_organization_id,
				    l_person_id,
				    l_business_group_id	,
				    l_start_date,
	  			    l_effective_date;
	close c_inputs;
      process_type := pay_payact_pkg.get_parameter('P_P_TY',leg_param) ;

      -- BALANCE AJUSTMENT
      if process_type = 'BA' then

      --  Bug 3372732 : Passing values from the c_input Cursor
         open c_bal_adj( stperson,
			 endperson,
			 l_payroll_id,
			 l_consolidation_set_id,
			 l_tax_unit_id,
			 l_location_id,
			 l_organization_id,
			 l_person_id,
			 l_business_group_id,
			 l_start_date,
			 l_effective_date);
         loop
          hr_utility.set_location('procpyr',2);

             fetch c_bal_adj into lockedactid,assignid,greid;
                 if c_bal_adj%found then
                         num := num + 1;
                 end if;
                 exit when c_bal_adj%notfound;

          -- we should include the assignment_set_id to the new version for
          -- dynamic assignment_set_id
          -- Assignment set  funtionality starts here and ends before the
          -- endloop of this cur

          ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

          -- Generating the assignment actions only for assignment where
          -- Assignment_flag = Y
          if ass_set_id is not null then

             ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

 	    If ass_flag = 'Y' then

                hr_utility.set_location('procpyr',3);
                select pay_assignment_actions_s.nextval
                into   lockingactid
                from   dual;

                -- insert the action record.
                hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                -- insert an interlock to this action.
                hr_nonrun_asact.insint(lockingactid,lockedactid);

              End if;
          else

             hr_utility.set_location('procpyr',30);
             select pay_assignment_actions_s.nextval
             into   lockingactid
             from   dual;

             -- insert the action record.
             hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

             -- insert an interlock to this action.
             hr_nonrun_asact.insint(lockingactid,lockedactid);
           end if;

       end loop;

       close c_bal_adj;

     end if;  /* 'BA' */

     -- BALANCE INITIALIZATION
     if process_type = 'BI' then

        open c_bal_ini( stperson,
			endperson,
			l_payroll_id,
			l_consolidation_set_id,
			l_tax_unit_id,
			l_location_id,
			l_organization_id,
			l_person_id,
			l_business_group_id,
			l_start_date,
			l_effective_date);
        loop
         hr_utility.set_location('procpyr',2);

            fetch c_bal_ini into lockedactid,assignid,greid;
                if c_bal_ini%found then
                        num := num + 1;
                end if;
                exit when c_bal_ini%notfound;

          -- we should include the assignment_set_id to the new version for
          -- dynamic assignment_set_id
          -- Assignment set  funtionality starts here and ends before the
          -- endloop of this cur


          ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

          -- Generating the assignment actions only for assignment where
          -- Assignment_flag = Y
          if ass_set_id is not null then

	     ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

	     If ass_flag = 'Y' then

                hr_utility.set_location('procpyr',3);
                select pay_assignment_actions_s.nextval
                into   lockingactid
                from   dual;

                -- insert the action record.
                hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                 -- insert an interlock to this action.
                 hr_nonrun_asact.insint(lockingactid,lockedactid);

             end if;
          else
             hr_utility.set_location('procpyr',3);
             select pay_assignment_actions_s.nextval
             into   lockingactid
             from   dual;

             -- insert the action record.
             hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

             -- insert an interlock to this action.
             hr_nonrun_asact.insint(lockingactid,lockedactid);
          end if;

      end loop;
      close c_bal_ini;

      end if;  /* 'BI' */

      -- BALANCE ADJUST. AND INITIALIZATION
      if process_type = 'BAI' then

      	open c_bal_adj_ini( stperson,
			    endperson,
			    l_payroll_id,
			    l_consolidation_set_id,
			    l_tax_unit_id,
			    l_location_id,
			    l_organization_id,
			    l_person_id,
			    l_business_group_id,
			    l_start_date,
			    l_effective_date);
	loop
           hr_utility.set_location('procpyr',2);

           fetch c_bal_adj_ini into lockedactid,assignid,greid;
           if c_bal_adj_ini%found then
              num := num + 1;
           end if;
           exit when c_bal_adj_ini%notfound;

           -- we should include the assignment_set_id to the new version for
           -- dynamic assignment_set_id
           -- Assignment set  funtionality starts here and ends before the
           -- endloop of this cur


           ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

           -- Generating the assignment actions only for assignment where
           -- Assignment_flag = Y
           if ass_set_id is not null then

              ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

	      If ass_flag = 'Y' then

                 hr_utility.set_location('procpyr',3);
                 select pay_assignment_actions_s.nextval
                 into   lockingactid
                 from   dual;

                 -- insert the action record.
                 hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                 -- insert an interlock to this action.
                 hr_nonrun_asact.insint(lockingactid,lockedactid);

              end if;
           else
              hr_utility.set_location('procpyr',3);
              select pay_assignment_actions_s.nextval
              into   lockingactid
              from   dual;

              -- insert the action record.
              hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

               -- insert an interlock to this action.
               hr_nonrun_asact.insint(lockingactid,lockedactid);
           end if;

           end loop;
           close c_bal_adj_ini;

      end if;  /* 'BA','BI','BAI'  */

      -- PAYROLL RUNS
      if process_type = 'PR' then

         open c_run( stperson,
		     endperson,
		     l_payroll_id,
		     l_consolidation_set_id,
		     l_tax_unit_id,
		     l_location_id,
		     l_organization_id,
		     l_person_id,
		     l_business_group_id,
		     l_start_date,
		     l_effective_date);

         loop
            hr_utility.set_location('procpyr',2);

            fetch c_run into lockedactid,assignid,greid;
            if c_run%found then
               num := num + 1;
            end if;
            exit when c_run%notfound;

            -- we should include the assignment_set_id to the new version for
            -- dynamic assignment_set_id
            -- Assignment set  funtionality starts here and ends before the
            -- endloop of this cur


            ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

            -- Generating the assignment actions only for assignment where
            -- Assignment_flag = Y
            if ass_set_id is not null then
               ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

	       If ass_flag = 'Y' then

                  hr_utility.set_location('procpyr',3);
                  select pay_assignment_actions_s.nextval
                  into   lockingactid
                  from   dual;

                  -- insert the action record.
                  hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                  -- insert an interlock to this action.
                  hr_nonrun_asact.insint(lockingactid,lockedactid);

               end if;
            else
               hr_utility.set_location('procpyr',3);
               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;

               -- insert the action record.
               hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

               -- insert an interlock to this action.
               hr_nonrun_asact.insint(lockingactid,lockedactid);

            end if;
         end loop;
         close c_run;

      end if; /* 'RUN' */


      -- QUICK PAYS
      if process_type = 'QP' then

         open c_qp( stperson,
		    endperson,
		    l_payroll_id,
	     	    l_consolidation_set_id,
		    l_tax_unit_id,
		    l_location_id,
		    l_organization_id,
		    l_person_id,
		    l_business_group_id,
		    l_start_date,
		    l_effective_date);

         loop
            hr_utility.set_location('procpyr',2);

            fetch c_qp into lockedactid,assignid,greid;
            if c_qp%found then
               num := num + 1;
            end if;
            exit when c_qp%notfound;

            -- we should include the assignment_set_id to the new version for
            -- dynamic assignment_set_id
            -- Assignment set  funtionality starts here and ends before the
            -- endloop of this cur


            ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

            -- Generating the assignment actions only for assignment where
            -- Assignment_flag = Y
            if ass_set_id is not null then

               ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

	       If ass_flag = 'Y' then

                  hr_utility.set_location('procpyr',3);
                  select pay_assignment_actions_s.nextval
                  into   lockingactid
                  from   dual;

                  -- insert the action record.
                  hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                  -- insert an interlock to this action.
                  hr_nonrun_asact.insint(lockingactid,lockedactid);

               end if;
            else

               hr_utility.set_location('procpyr',3);
               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;

               -- insert the action record.
               hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

               -- insert an interlock to this action.
               hr_nonrun_asact.insint(lockingactid,lockedactid);

           end if;
         end loop;

         close c_qp;

      end if; /* 'QUICK PAY' */

      -- PAYROLL RUNS AND QUICK PAYS
      if process_type = 'PRQP' then

         open c_run_qp( stperson,
			endperson,
			l_payroll_id,
			l_consolidation_set_id,
			l_tax_unit_id,
			l_location_id,
			l_organization_id,
			l_person_id,
			l_business_group_id,
			l_start_date,
			l_effective_date);

	 loop
            hr_utility.set_location('procpyr',2);

            fetch c_run_qp into lockedactid,assignid,greid;
            if c_run_qp%found then
               num := num + 1;
            end if;
            exit when c_run_qp%notfound;

            -- we should include the assignment_set_id to the new version for
            -- dynamic assignment_set_id
            -- Assignment set  funtionality starts here and ends before the
            -- endloop of this cur


            ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

            -- Generating the assignment actions only for assignment where
            -- Assignment_flag = Y
            if ass_set_id is not null then

               ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

               If ass_flag = 'Y' then

                  hr_utility.set_location('procpyr',3);
                  select pay_assignment_actions_s.nextval
                  into   lockingactid
                  from   dual;

                  -- insert the action record.
                  hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                  -- insert an interlock to this action.
                  hr_nonrun_asact.insint(lockingactid,lockedactid);

	       end if;
            else

               hr_utility.set_location('procpyr',3);
               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;
--
               -- insert the action record.
               hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
--
               -- insert an interlock to this action.
               hr_nonrun_asact.insint(lockingactid,lockedactid);
            end if;

         end loop;
         close c_run_qp;

      end if; /* 'RUN','QP','RUN and QP'  */


      if process_type = 'REV' then

         open c_rev( stperson,
		     endperson,
		     l_payroll_id,
		     l_consolidation_set_id,
		     l_tax_unit_id,
		     l_location_id,
		     l_organization_id,
		     l_person_id,
		     l_business_group_id,
		     l_start_date,
		     l_effective_date);

         loop
            hr_utility.set_location('procpyr',2);

           fetch c_rev into lockedactid,assignid,greid;
           if c_rev%found then
              num := num + 1;
           end if;
           exit when c_rev%notfound;


           -- we should include the assignment_set_id to the new version for
           -- dynamic assignment_set_id
           -- Assignment set  funtionality starts here and ends before the
           -- endloop of this cur


           ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

           -- Generating the assignment actions only for assignment where
           -- Assignment_flag = Y
           if ass_set_id is not null then
	      ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

	      If ass_flag = 'Y' then

                 hr_utility.set_location('procpyr',3);
                 select pay_assignment_actions_s.nextval
                 into   lockingactid
                 from   dual;

                 -- insert the action record.
                 hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                 -- insert an interlock to this action.
                 hr_nonrun_asact.insint(lockingactid,lockedactid);
	      end if;
           else
              hr_utility.set_location('procpyr',3);
              select pay_assignment_actions_s.nextval
              into   lockingactid
              from   dual;

              -- insert the action record.
              hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

              -- insert an interlock to this action.
              hr_nonrun_asact.insint(lockingactid,lockedactid);
           end if;
        end loop;
        close c_rev;

     end if; /* 'REV' */


     if process_type = 'ALL' then

        open c_all( stperson,
		    endperson,
		    l_payroll_id,
		    l_consolidation_set_id,
		    l_tax_unit_id,
	            l_location_id,
	            l_organization_id,
		    l_person_id,
		    l_business_group_id,
		    l_start_date,
	            l_effective_date);
      	num := 0;
        loop
           hr_utility.set_location('procpyr',2);

           fetch c_all into lockedactid,assignid,greid;

           if c_all%found then
              num := num + 1;
           end if;
           exit when c_all%notfound;

           -- we should include the assignment_set_id to the new version for
           -- dynamic assignment_set_id
           -- Assignment set  funtionality starts here and ends before the
           -- endloop of this cur


           ass_set_id := pay_payact_pkg.get_parameter('PASID',leg_param);

           -- Generating the assignment actions only for assignment where
           -- Assignment_flag = Y
           if ass_set_id is not null then

              ass_flag := hr_assignment_set.assignment_in_set(ass_set_id,assignid);

	      If ass_flag = 'Y' then
                 -- we need to insert one action for each of the
                 -- rows that we return from the cursor (i.e. one
                 -- for each assignment/pre-payment/reversal).
                 hr_utility.set_location('procpyr',3);
                 select pay_assignment_actions_s.nextval
                 into   lockingactid
                 from   dual;

                 -- insert the action record.
                 hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

                 -- insert an interlock to this action.
                 hr_nonrun_asact.insint(lockingactid,lockedactid);

	      end if;
           else

              -- we need to insert one action for each of the
              -- rows that we return from the cursor (i.e. one
              -- for each assignment/pre-payment/reversal).
              hr_utility.set_location('procpyr',3);
              select pay_assignment_actions_s.nextval
              into   lockingactid
              from   dual;

              -- insert the action record.
              hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

              -- insert an interlock to this action.
              hr_nonrun_asact.insint(lockingactid,lockedactid);
          end if;

        end loop;
        close c_all;
      end if;  /* 'ALL' */

end action_creation;

---------------------------------- sort_action ----------------------------------
PROCEDURE sort_action(
             payactid   in     varchar2,     /* payroll action id */
             sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
             len        out nocopy   number        /* length of the sql string */
          ) is
-- Cursor to get legislative parameters for Payroll Activity
-- Bug 3037633
cursor cur_leg_params(pactid varchar2) is
           select legislative_parameters
           from pay_payroll_actions
           where payroll_action_id = pactid;

leg_params pay_payroll_actions.legislative_parameters%type;
   begin
      sqlstr :=  'select paa.rowid
             /* we need the row id of the assignment actions
                that are created by PYUGEN */
               from hr_all_organization_units  hou, /* Assignment Org */
                    hr_all_organization_units  hou1,/* Tax Unit       */
                    hr_locations_all       loc,
                    per_all_people_f       ppf,
                    per_all_assignments_f  paf,
                    pay_assignment_actions paa, /* PYUGEN assignment action */
                    pay_payroll_actions    ppa,  /* PYUGEN payroll action id */
                    pay_assignment_actions	paa1, /*For Sorting */
		    pay_action_interlocks 	pai,
                    pay_payroll_actions		ppa1 /*For Sorting */
              where ppa.payroll_action_id = :payactid
                and paa.payroll_action_id = ppa.payroll_action_id
                and paf.assignment_id = paa.assignment_id
                and paf.effective_start_date =
                      (select max(paf1.effective_start_date)
                         from per_all_assignments_f paf1
                        where paf1.assignment_id = paf.assignment_id
                          and paf1.effective_start_date <= ppa.effective_date
                          and paf1.effective_end_date >= ppa.start_date
                      )
                and hou1.organization_id = paa.tax_unit_id
                and hou.organization_id = paf.organization_id
                and loc.location_id  = paf.location_id
                and ppf.person_id = paf.person_id
                and ppa.effective_date between ppf.effective_start_date
                                           and ppf.effective_end_date
      		AND	ppa1.effective_date BETWEEN ppa.start_date and ppa.effective_Date
		AND	ppa1.action_status		= ''C''
		AND	ppa1.payroll_action_id 	  = paa1.payroll_action_id
		and paa1.action_status = ''C''
		AND paa1.assignment_id = paa.assignment_id
		and pai.locking_action_id = paa.assignment_action_id
		and pai.locked_action_id = paa1.assignment_action_id
		and ppa.business_group_id = ppa1.business_group_id';

        open cur_leg_params(payactid);
	fetch cur_leg_params into leg_params;

        /* Bug 3037633 : The SQL query string is prepared on the basis of the legislative parameters
			 string obtained from the cursor 'cur_leg_params'. This string is passed
			 to the get_parameter function to obtain the actual value.  */

        IF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'BA' then
	    sqlstr := sqlstr || ' and ppa1.action_type = ''B'' ';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'BI' then
	    sqlstr := sqlstr || ' and ppa1.action_type = ''I'' ';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'BAI' then
	    sqlstr := sqlstr || ' and (ppa1.action_type = ''B'' or ppa1.action_type = ''I'')';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'PR' then
	    sqlstr := sqlstr || ' and ppa1.action_type = ''R''';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'QP' then
	    sqlstr := sqlstr || ' and ppa1.action_type = ''Q''';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'PRQP' then
	    sqlstr := sqlstr || ' and (ppa1.action_type = ''R'' or ppa1.action_type = ''Q'')';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'REV' then
	    sqlstr := sqlstr || ' and ppa1.action_type = ''V''';
        ELSIF pay_payrg_pkg.get_parameter('P_P_TY',leg_params)=   'ALL' then
	    sqlstr := sqlstr || ' and (ppa1.action_type = ''B'' or ppa1.action_type = ''D'' or ppa1.action_type = ''I'' or ppa1.action_type = ''Q'' or ppa1.action_type = ''R'' or ppa1.action_type = ''V'')';
	END IF;
	close cur_leg_params;

	/* Bug 3037633 : Order By clause changed to include the effective_date after sort options
			 choosen by the user. */

        sqlstr := sqlstr||'order by
                decode(pay_payrg_pkg.get_parameter(''P_S1'',
                                                   ppa.legislative_parameters),
                             ''GRE'',hou1.name,
                             ''Organization'',hou.name,
                             ''Location'',loc.location_code,null),
                decode(pay_payrg_pkg.get_parameter(''P_S2'',
                                                   ppa.legislative_parameters),
                             ''GRE'',hou1.name,
                             ''Organization'',hou.name,
                             ''Location'',loc.location_code,null),
                decode(pay_payrg_pkg.get_parameter(''P_S3'',
                                                   ppa.legislative_parameters),
                             ''GRE'',hou1.name,
                             ''Organization'',hou.name,
                             ''Location'',loc.location_code,null),
                hou.name, ppf.full_name, ppa1.effective_date
              for update of paa.assignment_id';

      len := length(sqlstr); -- return the length of the string.
   end sort_action;

------------------------------ get_parameter -------------------------------
FUNCTION get_parameter(name in varchar2,
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

end pay_payact_pkg;

/
