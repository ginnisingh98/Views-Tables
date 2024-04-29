--------------------------------------------------------
--  DDL for Package Body PAY_US_OVER_LIMIT_TAX_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_OVER_LIMIT_TAX_RPT_PKG" 
/* $Header: pyusoltx.pkb 120.1 2006/11/17 07:09:10 ckesanap noship $ */
/* ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Name        : pyusoltx.pkb

    Description : This script is used by the Over Limit Report
			   for populating limits and retreining it from
			   the PL/SQL Table

   Name        :This package defines the cursors needed for OLT to run Multi-Threaded
                This loads all the records that will appear in the report. This
                data is being stored in pay_us_rpt_totals table.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----------- -------- ------  --------   -----------
    01-NOV-1999 hzhao    110.0               Initial Version.
    22-NOV-1999 hzhao    110.1               Moved Header below Create stmt.
    15-AUG-2001 tmehra   110.2               Added support for 403b and 457
    15-AUG-2001 tmehra   110.3               Updated the above remark

   07-DEC-2001 irgonzal  115.4               Same as 115.2
                                             115.3 changes are not required
                                             due to performance issues.
    04-FEB-2002 meshah   115.5   2166701     added procedure load_data,
                                             load_state_taxes and
                                             load_federal_taxes. Also changed
                                             some cursors for performance.
    05-FEB-2002 meshah   115.6               Added checkfile entry to the file.
    05-MAR-2002 meshah   115.7               removed to_char from 401, 403 and
                                             457 in hr_utility.
    06-MAR-2002 meshah   115.8               cursor c_federal_taxes was refered
                                             at a wrong place in load_federal_balance.
                                             this was causing report to error out
                                             with invalid cursor error.
    20-MAR-2002 meshah   115.9               changed the date checking in load_data
                                             and removed per_assignments_f table
                                             from load_state_data.
    27-MAR-2002 meshah   115.10   2280318    the call to get_tax_balances has been
                                             changed. Instead of calling it in the
                                             sql statement we are calling it in a
                                             loop. Also the get_value function has
                                             been changed from pay_us_balance_view_pkg
                                             to pay_balance_pkg for Tax Group balances
                                             and setting the TAX GROUP context instead
                                             of the TAX UNIT ID.
    30-APR-2002 meshah   115.11   2345031    cursor sel_aaid has been changed in load_data
                                             we are now selecting effective_end_date for
                                             the assignment. This date is then compared
                                             with as_of_date and the lowest date is then
                                             passed to the other procedures/functions.
                                             This is required to handle terminated employees.
   07-JUN-2002 sshetty  115.12               Added qualifier to func get_pqp_limit
                                             and get_457_annual_limit.
   25-NOV-2002 irgonzal 115.13    2664340    Added logic to handle Catchup balances.
   03-DEC-2002 irgonzal 115.14    2664340    Modified Load_Fed_Catchup_Balance
                                             procedure and ensure the balance_name
                                             does not concatenate "_".
   03-DEC-2002 irgonzal 115.15   2664340     Modified Load_Fed_Catchup_Balance
                                             procedure and added upper function
                                             when getting balance name.
   17-DEC-2002 irgonzal 115.16   2714501     Modified load_data procedure: initialized
                                             l_as_of_date within the "sel_aaid" loop.
   19-DEC-2002 irgonzal 115.17   2693022     Added logic to handle USERRA balances.
   18-MAY-2003 vgunasek 115.18   2938556     report rewrite including support for
   					     new balance reporting architecture (run
   					     balances) and multi threading.
   06-JUN-2003 vgunasek 115.19   2938556     Changed code to check changes in Tax group
   					     removed chnkno = 1 check to insert dummy
   					     assignment action. Some Spell changes in
   					     comments.
   06-JUN-2003 vgunasek 115.20   2938556     Changed comments and fixed gscc errors.
   12-JUN-2003 vgunasek 115.21   3002767     Initialised g_inserted_asg_action_id_flag
   					     for all assignments. Made state query as
   					     rule based.
   19-JUN-2003 kaverma  115.22   3015312     Corrected the declaration of l_leg_param in
                                             load_data
   24-JUN-2003 kaverma  115.23   3018606     Corrected call to load_federal_taxes and load_state_taxes
                                             in load_data procedure.
   07-AUG-2003 sshetty  115.24               Added a check for Defined
                                             Contrib Plan  over limit.

   05-SEP-2003 sdahiya  115.25   3118107     Added code in load_data procedure for insertion
                                             of assignment action id.
   02-JAN-2004 sshetty  115.26   3349624     Changed the Dimension name referenced
                                             for DCP from PER_YTD to PER_GRE_YTD.
   02-SEP-2004 tmehra   115.27   3770316     Removed the 403b and 457 Catchup
                                             limit checking for tax_type = null
                                             option.
   16-NOV-2006 ckesanap 115.28   4521358     Added the 'Roth 401k' and 'Roth 403b' over limit
                                             check. The balance values of both deferred 401k and Roth 401k
					     are combined and then checked for exceeding the annual limit.
					     Similarly for 403b.
***************************************************************************/
AS

--------------------- GLOBAL variables ----------------------------------
l_start_date               pay_payroll_actions.start_date%type;
l_end_date                 pay_payroll_actions.effective_date%type;
l_business_group_id        pay_payroll_actions.business_group_id%type;
l_payroll_action_id        pay_payroll_actions.payroll_action_id%type;
l_effective_date           pay_payroll_actions.effective_date%type;
l_action_type              pay_payroll_actions.action_type%type;
l_assignment_action_id     pay_assignment_actions.assignment_action_id%type;
l_assignment_id            pay_assignment_actions.assignment_id%type;
l_tax_unit_id              hr_organization_units.organization_id%type;
l_gre_name                 hr_organization_units.name%type;
l_organization_id          hr_organization_units.organization_id%type;
l_org_name                 hr_organization_units.name%type;
l_location_id              hr_locations.location_id%type;
l_location_code            hr_locations.location_code%type;
l_leg_param                pay_payroll_actions.legislative_parameters%type;--Bug3015312
l_leg_start_date           date;
l_leg_end_date             date;
t_gre_id                   number(15);
t_payroll_action_id        pay_payroll_actions.payroll_action_id%type; --:PACTID
l_row_count                number :=0;
l_tax_type                 varchar2(240);
l_tax_group                hr_organization_information.org_information5%type;
l_date_prm                 varchar2(20);
l_as_of_date               date;

-- bug # 2938556
l_prev_tg                  hr_organization_information.org_information5%type;
l_tg_changed varchar2(1):= 'Y';
g_get_param  varchar2(1):= 'Y';
g_inserted_asg_action_id_flag  varchar2(1):= 'N';
g_inserted_asg_action_id  number;
l_ppa_finder                 varchar2(240);
p_insert_done_flag         varchar2(1):= 'N';
 TYPE t_rec_bal IS RECORD
   (balance_id    ff_user_entities.creator_id%TYPE,
    balance_name  varchar2(1000),
    tax_type      varchar2(50)
   );

 TYPE t_balance IS TABLE OF t_rec_bal INDEX BY BINARY_INTEGER;

 t_fed_balance_list t_balance;
 t_state_balance_list t_balance;


----------------------- END global variables ------------------------------+
--

--------------- START tax group info --------------------------------------+
--
function tax_group(p_tax_unit_id number) return VARCHAR2
is
  cursor c_tax_group(cp_tax_unit_id in number) is
    select org_information5
      from hr_organization_information
     where organization_id = cp_tax_unit_id
       and org_information_context = 'Federal Tax Rules';

  lv_tax_group varchar2(240);

begin
   open c_tax_group(p_tax_unit_id);
   fetch c_tax_group into lv_tax_group;
   close c_tax_group;

   if ltrim(rtrim(lv_tax_group)) is null then
      return('xXx');
   else
      return(lv_tax_group);
   end if;
end Tax_group;
--

  --Removed procedure poplulate_state_limits_table as part of bug # 2938556
  --
  --
  -- Function to get the balances
  --
  FUNCTION get_taxable_balance (
           p_assignment_id           IN NUMBER
          ,p_effective_date          IN DATE
          ,p_assignment_action_id    IN NUMBER
          ,p_tax_unit_id             IN NUMBER
          ,p_tax_group               IN VARCHAR2
          ,p_jurisdiction_code       IN VARCHAR2
          ,p_tax_type                IN VARCHAR2
          ,p_balance_id              IN NUMBER
           )
  RETURN NUMBER IS
    ln_balance_value   number := 0;
    ln_catchup_balance_value number := 0;
--    lv_tax_group       hr_organization_information.org_information5%TYPE ;
    lv_tg_balance_name varchar2(1000);
    ln_defined_bal_id  ff_user_entities.creator_id%TYPE;
    lv_bal_flag        varchar2(30) := ' ';
    --
    -- #2664340
    lv_balance_name varchar2(1000);

l_catchup_bal_name varchar2(50);
l_catchup_bal_id number;
l_catchup_count number :=1;
ln_catchup_defined_bal_id  ff_user_entities.creator_id%TYPE;

    --

    cursor c_def_bal_id(cp_balance_name in varchar2) is
      select creator_id
        from ff_database_items fdi,
             ff_user_entities fue
       where fue.user_entity_id = fdi.user_entity_id
         and fue.creator_type='B'
         and fdi.user_name = cp_balance_name;
  --
  -- -----------------------------------------------------------------------+
  -- # 2664340          Catchup Balance Processing                          +
  -- -----------------------------------------------------------------------+
-- This procdure was removed as it is no longer required due to
-- report rewrite bug # 2938556

-- -----------------------------------------------------------------------+
--                     Main get_taxable_balance                           +
-- -----------------------------------------------------------------------+
BEGIN
    --lv_tax_group := null;
    ln_defined_bal_id := p_balance_id;
    if p_tax_type in ('FUTA', 'SS ER', 'SS EE') and p_tax_group <> 'xXx' then

          pay_balance_pkg.set_context('TAX_GROUP', p_tax_group);

          ln_balance_value := pay_balance_pkg.get_value(
                                  p_assignment_id       => p_assignment_id
                                 ,p_defined_balance_id  => ln_defined_bal_id
                                 ,p_virtual_date        => p_effective_date
                                  );

       elsif p_tax_type in ('FUTA', 'SS ER', 'SS EE') and p_tax_group = 'xXx'then
          hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));

          ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );

     elsif p_tax_type in ('401K') then
        hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));
        ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );

        l_catchup_bal_name := 'DEF_COMP_401K_CATCHUP_PER_GRE_YTD';
          open c_def_bal_id(l_catchup_bal_name);
          fetch c_def_bal_id into ln_catchup_defined_bal_id;
          close c_def_bal_id;

          hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_catchup_defined_bal_id));

	  ln_catchup_balance_value := pay_balance_pkg.get_value(
                            		     p_defined_balance_id  => ln_catchup_defined_bal_id
		                            ,p_assignment_action_id      => p_assignment_action_id
					    ,p_tax_unit_id	=> p_tax_unit_id
	  		                    ,p_jurisdiction_code	=> p_jurisdiction_code
		                            ,p_source_id => null
				 	    ,p_tax_group => null
					    ,p_date_earned =>null
                                            );

          ln_balance_value := nvl(ln_balance_value,0) -
                                nvl(ln_catchup_balance_value,0);

---- Added for bug 4521358

 elsif p_tax_type in ('401K ROTH') then
        hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));
        ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );
------

     elsif p_tax_type in ('403B') then
        hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));
        ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );

        l_catchup_bal_name := 'DEF_COMP_403B_CATCHUP_PER_GRE_YTD';
          open c_def_bal_id(l_catchup_bal_name);
          fetch c_def_bal_id into ln_catchup_defined_bal_id;
          close c_def_bal_id;

          hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_catchup_defined_bal_id));

	  ln_catchup_balance_value := pay_balance_pkg.get_value(
                            		     p_defined_balance_id  => ln_catchup_defined_bal_id
		                            ,p_assignment_action_id      => p_assignment_action_id
					    ,p_tax_unit_id	=> p_tax_unit_id
	  		                    ,p_jurisdiction_code	=> p_jurisdiction_code
		                            ,p_source_id => null
				 	    ,p_tax_group => null
					    ,p_date_earned =>null
                                            );

          ln_balance_value := nvl(ln_balance_value,0) -
                                nvl(ln_catchup_balance_value,0);

---- Added for bug 4521358

 elsif p_tax_type in ('403B ROTH') then
        hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));
        ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );

-----------

     elsif p_tax_type in ('457') then
        hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));
        ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );

        l_catchup_bal_name := 'DEF_COMP_457_CATCHUP_PER_GRE_YTD';
          open c_def_bal_id(l_catchup_bal_name);
          fetch c_def_bal_id into ln_catchup_defined_bal_id;
          close c_def_bal_id;

          hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_catchup_defined_bal_id));

	  ln_catchup_balance_value := pay_balance_pkg.get_value(
                            		     p_defined_balance_id  => ln_catchup_defined_bal_id
		                            ,p_assignment_action_id      => p_assignment_action_id
					    ,p_tax_unit_id	=> p_tax_unit_id
	  		                    ,p_jurisdiction_code	=> p_jurisdiction_code
		                            ,p_source_id => null
				 	    ,p_tax_group => null
					    ,p_date_earned =>null
                                            );

          ln_balance_value := nvl(ln_balance_value,0) -
                                nvl(ln_catchup_balance_value,0);

      elsif p_tax_type in ('SDI ER', 'SDI EE', 'SUI ER', 'SUI EE') then
          hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));
          ln_balance_value := pay_balance_pkg.get_value(
                                 p_defined_balance_id  => ln_defined_bal_id
                                ,p_assignment_action_id      => p_assignment_action_id
				,p_tax_unit_id	=> p_tax_unit_id
				,p_jurisdiction_code	=> p_jurisdiction_code
				,p_source_id => null
				,p_tax_group => null
				,p_date_earned =>null
                                  );

      elsif p_tax_type in ( '401K CATCHUP', '403B CATCHUP', '457 CATCHUP','DCP') then   -- #2664340

          hr_utility.trace('in to get_taxable_balance defined_balance_id   : ' || to_char(ln_defined_bal_id));

	  ln_balance_value := pay_balance_pkg.get_value(
                            		     p_defined_balance_id  => ln_defined_bal_id
		                            ,p_assignment_action_id      => p_assignment_action_id
					    ,p_tax_unit_id	=> p_tax_unit_id
	  		                    ,p_jurisdiction_code	=> p_jurisdiction_code
		                            ,p_source_id => null
				 	    ,p_tax_group => null
					    ,p_date_earned =>null
                                  );
    end if;
    if ln_balance_value is null then
        ln_balance_value := 0;
    end if;
    return (ln_balance_value);

  END get_taxable_balance;

-- End of get_taxable_balance_procedure


 --
 --  Added for bug 4521358.
 --  Function to get the p_balance_id of Roth 401k, Roth 403b, 401k and 403b
 --  to combine Deferred and Roth balances and check for Over Limit Report.
 --  If the tax type is of deferred deduction, it returns the balance_id of Roth deduction.
 --  Similarly if the tax type is Roth deduction, it return the balance_id of deferred.
 --
 FUNCTION get_roth_balance_id ( p_tax_type IN VARCHAR2 )

  RETURN NUMBER IS

    ln_balance_id number := 0 ;

    def_401k_balance_name varchar2(40) := 'DEF_COMP_401K_PER_GRE_YTD';
    def_403b_balance_name varchar2(40) := 'DEF_COMP_403B_PER_GRE_YTD';
    roth_401k_balance_name varchar2(40) := 'ROTH_401K_AMOUNT_PER_GRE_YTD';
    roth_403b_balance_name varchar2(40) := 'ROTH_403B_AMOUNT_PER_GRE_YTD';

  cursor c_def_bal_id(cp_balance_name in varchar2) is
      select creator_id
        from ff_database_items fdi,
             ff_user_entities fue
       where fue.user_entity_id = fdi.user_entity_id
         and fue.creator_type='B'
         and fdi.user_name = cp_balance_name;

  BEGIN

  hr_utility.trace('In get_roth_balance_id, p_tax_type: '|| p_tax_type);

        if p_tax_type = '401K' then
            open c_def_bal_id (roth_401k_balance_name);
            fetch c_def_bal_id into ln_balance_id;
            close c_def_bal_id;

            hr_utility.trace('Balance name: '||roth_401k_balance_name||', balance id: '||ln_balance_id);

        elsif p_tax_type = '403B' then
            open c_def_bal_id (roth_403b_balance_name);
            fetch c_def_bal_id into ln_balance_id;
            close c_def_bal_id;

	     hr_utility.trace('Balance name: '||roth_401k_balance_name||', balance id: '||ln_balance_id);

        elsif p_tax_type = '401K ROTH' then
            open c_def_bal_id (def_401k_balance_name);
            fetch c_def_bal_id into ln_balance_id;
            close c_def_bal_id;

	     hr_utility.trace('Balance name: '||roth_401k_balance_name||', balance id: '||ln_balance_id);

        elsif p_tax_type = '403B ROTH' then
            open c_def_bal_id (def_403b_balance_name);
            fetch c_def_bal_id into ln_balance_id;
            close c_def_bal_id;

	     hr_utility.trace('Balance name: '||roth_401k_balance_name||', balance id: '||ln_balance_id);

        end if;

    return (ln_balance_id) ;

  END get_roth_balance_id ;

-- End of get_roth_balance_id function.


-- Procedure to populate federal balances table.
-- This is included as part of bug # 2938556. The plsql table will be populated with
-- values required depending on the tax type and tax group. these values will be used
-- to calculate over limit values

  procedure populate_fed_balance_list (p_tax_type	 IN	 VARCHAR2,
			     	       p_tax_group	 IN	 VARCHAR2) is

  cursor c_def_bal_id(cp_balance_name in varchar2) is
      select creator_id
        from ff_database_items fdi,
             ff_user_entities fue
       where fue.user_entity_id = fdi.user_entity_id
         and fue.creator_type='B'
         and fdi.user_name = cp_balance_name;

l_count number := 1;

  begin

     hr_utility.set_location('IN populate_fed_balance_list ',350);

   if p_tax_type is null then
      if p_tax_group = 'xXx' then
        t_fed_balance_list(1).balance_name := 'FUTA_TAXABLE_PER_GRE_YTD';
	t_fed_balance_list(1).tax_type := 'FUTA';
        t_fed_balance_list(2).balance_name := 'SS_ER_TAXABLE_PER_GRE_YTD';
	t_fed_balance_list(2).tax_type := 'SS ER';
        t_fed_balance_list(3).balance_name := 'SS_EE_TAXABLE_PER_GRE_YTD';
	t_fed_balance_list(3).tax_type := 'SS EE';
        t_fed_balance_list(4).balance_name := 'DEF_COMP_401K_PER_GRE_YTD';
	t_fed_balance_list(4).tax_type := '401K';
        t_fed_balance_list(5).balance_name := 'DEF_COMP_403B_PER_GRE_YTD';
	t_fed_balance_list(5).tax_type := '403B';
        t_fed_balance_list(6).balance_name := 'DEF_COMP_457_PER_GRE_YTD';
	t_fed_balance_list(6).tax_type := '457';
        t_fed_balance_list(7).balance_name := 'DEF_COMP_401K_CATCHUP_PER_GRE_YTD';
	t_fed_balance_list(7).tax_type := '401K CATCHUP';
/* -- part of the bug #3770316 Fix. tmehra
        t_fed_balance_list(8).balance_name := 'DEF_COMP_403B_CATCHUP_PER_GRE_YTD';
	t_fed_balance_list(8).tax_type := '403B CATCHUP';
        t_fed_balance_list(9).balance_name := 'DEF_COMP_457_CATCHUP_PER_GRE_YTD';
	t_fed_balance_list(9).tax_type := '457 CATCHUP';
*/
        t_fed_balance_list(8).balance_name := 'EE_SRS_DCP_CONTRIBUTION_PER_GRE_YTD';
        t_fed_balance_list(8).tax_type := 'DCP';

-- Added for bug 4521358

        t_fed_balance_list(9).tax_type := '401K ROTH';
        t_fed_balance_list(9).balance_name := 'ROTH_401K_AMOUNT_PER_GRE_YTD';
        t_fed_balance_list(10).tax_type := '403B ROTH';
        t_fed_balance_list(10).balance_name := 'ROTH_403B_AMOUNT_PER_GRE_YTD';

      else
	t_fed_balance_list(1).balance_name := 'FUTA_TAXABLE_PER_TG_YTD';
	t_fed_balance_list(1).tax_type := 'FUTA';
        t_fed_balance_list(2).balance_name := 'SS_ER_TAXABLE_PER_TG_YTD';
	t_fed_balance_list(2).tax_type := 'SS ER';
        t_fed_balance_list(3).balance_name := 'SS_EE_TAXABLE_PER_TG_YTD';
	t_fed_balance_list(3).tax_type := 'SS EE';
        t_fed_balance_list(4).balance_name := 'DEF_COMP_401K_PER_GRE_YTD';
	t_fed_balance_list(4).tax_type := '401K';
        t_fed_balance_list(5).balance_name := 'DEF_COMP_403B_PER_GRE_YTD';
	t_fed_balance_list(5).tax_type := '403B';
        t_fed_balance_list(6).balance_name := 'DEF_COMP_457_PER_GRE_YTD';
	t_fed_balance_list(6).tax_type := '457';
        t_fed_balance_list(7).balance_name := 'DEF_COMP_401K_CATCHUP_PER_GRE_YTD';
	t_fed_balance_list(7).tax_type := '401K CATCHUP';
/*  -- part of the bug #3770316 Fix. tmehra
        t_fed_balance_list(8).balance_name := 'DEF_COMP_403B_CATCHUP_PER_GRE_YTD';
	t_fed_balance_list(8).tax_type := '403B CATCHUP';
        t_fed_balance_list(9).balance_name := 'DEF_COMP_457_CATCHUP_PER_GRE_YTD';
	t_fed_balance_list(9).tax_type := '457 CATCHUP';
*/
        t_fed_balance_list(8).balance_name := 'EE_SRS_DCP_CONTRIBUTION_PER_GRE_YTD';
        t_fed_balance_list(8).tax_type := 'DCP';

-- Added for bug 4521358

        t_fed_balance_list(9).tax_type := '401K ROTH';
        t_fed_balance_list(9).balance_name := 'ROTH_401K_AMOUNT_PER_GRE_YTD';
        t_fed_balance_list(10).tax_type := '403B ROTH';
        t_fed_balance_list(10).balance_name := 'ROTH_403B_AMOUNT_PER_GRE_YTD';

     end if;
   elsif p_tax_type = 'FUTA' and p_tax_group = 'xXx' then
        t_fed_balance_list(1).balance_name := 'FUTA_TAXABLE_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SS ER' and p_tax_group = 'xXx' then
        t_fed_balance_list(1).balance_name := 'SS_ER_TAXABLE_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SS EE' and p_tax_group = 'xXx' then
        t_fed_balance_list(1).balance_name := 'SS_EE_TAXABLE_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'FUTA' and p_tax_group  <> 'xXx' then
        t_fed_balance_list(1).balance_name := 'FUTA_TAXABLE_PER_TG_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SS ER' and p_tax_group <> 'xXx' then
        t_fed_balance_list(1).balance_name := 'SS_ER_TAXABLE_PER_TG_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SS EE' and p_tax_group <> 'xXx' then
        t_fed_balance_list(1).balance_name := 'SS_EE_TAXABLE_PER_TG_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = '401K' then
        t_fed_balance_list(1).balance_name := 'DEF_COMP_401K_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = '403B' then
        t_fed_balance_list(1).balance_name := 'DEF_COMP_403B_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = '457' then
        t_fed_balance_list(1).balance_name := 'DEF_COMP_457_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = '401K CATCHUP' then
        t_fed_balance_list(1).balance_name := 'DEF_COMP_401K_CATCHUP_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = '403B CATCHUP' then
        t_fed_balance_list(1).balance_name := 'DEF_COMP_403B_CATCHUP_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;

--- Added for bug 4521358

   elsif p_tax_type = '401K ROTH' then
        t_fed_balance_list(1).balance_name := 'ROTH_401K_AMOUNT_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = '403B ROTH' then
        t_fed_balance_list(1).balance_name := 'ROTH_403B_AMOUNT_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
-----
   elsif p_tax_type = '457 CATCHUP' then
        t_fed_balance_list(1).balance_name := 'DEF_COMP_457_CATCHUP_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'DCP' then
        t_fed_balance_list(1).balance_name := 'EE_SRS_DCP_CONTRIBUTION_PER_GRE_YTD';
        t_fed_balance_list(1).tax_type := p_tax_type;
   else
        null; -- Not a Federal Tax
   end if;

  l_count := t_fed_balance_list.count;
  for i in 1 .. l_count loop
     open c_def_bal_id (t_fed_balance_list(i).balance_name);
     fetch c_def_bal_id into t_fed_balance_list(i).balance_id;
     close c_def_bal_id;
     hr_utility.trace('Inserting fed_balance_list table with balance name  ' || t_fed_balance_list(i).balance_name );
     hr_utility.trace('Inserting fed_balance_list table with balance id  ' || t_fed_balance_list(i).balance_id );
  end loop;
     hr_utility.set_location('OUT populate_fed_balance_list ',360);
  end populate_fed_balance_list;

-- end of procedure populate_fed_balance_list


-- This is included as part of bug # 2938556. The plsql table will be populated with
-- values required depending on the tax type. These values will be used
-- to calculate over limit values

  procedure populate_state_balance_list (p_tax_type	 IN	 VARCHAR2) is

  cursor c_def_bal_id(cp_balance_name in varchar2) is
      select creator_id
        from ff_database_items fdi,
             ff_user_entities fue
       where fue.user_entity_id = fdi.user_entity_id
         and fue.creator_type='B'
         and fdi.user_name = cp_balance_name;

  l_count number := 1;

  begin

     hr_utility.set_location('IN populate_state_balance_list ',370);
   if p_tax_type is null then
        t_state_balance_list(1).balance_name := 'SDI_ER_TAXABLE_PER_JD_GRE_YTD';
	t_state_balance_list(1).tax_type := 'SDI ER';
        t_state_balance_list(2).balance_name := 'SDI_EE_TAXABLE_PER_JD_GRE_YTD';
	t_state_balance_list(2).tax_type := 'SDI EE';
        t_state_balance_list(3).balance_name := 'SUI_ER_TAXABLE_PER_JD_GRE_YTD';
	t_state_balance_list(3).tax_type := 'SUI ER';
        t_state_balance_list(4).balance_name := 'SUI_EE_TAXABLE_PER_JD_GRE_YTD';
	t_state_balance_list(4).tax_type := 'SUI EE';
   elsif p_tax_type = 'SDI ER' then
        t_state_balance_list(1).balance_name := 'SDI_ER_TAXABLE_PER_JD_GRE_YTD';
        t_state_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SDI EE' then
        t_state_balance_list(1).balance_name := 'SDI_EE_TAXABLE_PER_JD_GRE_YTD';
        t_state_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SUI ER' then
        t_state_balance_list(1).balance_name := 'SUI_ER_TAXABLE_PER_JD_GRE_YTD';
        t_state_balance_list(1).tax_type := p_tax_type;
   elsif p_tax_type = 'SUI EE' then
        t_state_balance_list(1).balance_name := 'SUI_EE_TAXABLE_PER_JD_GRE_YTD';
        t_state_balance_list(1).tax_type := p_tax_type;
   else
        null; -- Not a State Tax
   end if;

  l_count := t_state_balance_list.count;
  for i in 1 .. l_count loop
     open c_def_bal_id (t_state_balance_list(i).balance_name);
     fetch c_def_bal_id into t_state_balance_list(i).balance_id;
     close c_def_bal_id;
     hr_utility.trace('Inserting state_balance_list table with balance name  ' || t_state_balance_list(i).balance_name );
     hr_utility.trace('Inserting state_balance_list table with balance id  ' || t_state_balance_list(i).balance_id );
  end loop;
  hr_utility.set_location('OUT populate_state_balance_list ',380);
  end populate_state_balance_list;

-- End of the procedure populate_state_balance_list


  -- -----------------------------------------------------------------------+
  -- END of function get_taxable_balance                                    +
  -- -----------------------------------------------------------------------+

  FUNCTION get_state_limit(
           p_state_code             IN NUMBER
          ,p_tax_type         IN VARCHAR2 )
  RETURN NUMBER is
    ln_state_tax_limit      NUMBER;

  BEGIN
    if p_tax_type = 'SDI EE' then
        ln_state_tax_limit := pay_us_payroll_utils.ltr_state_tax_info(p_state_code).sdi_ee_limit;
    elsif p_tax_type = 'SDI ER' then
        ln_state_tax_limit := pay_us_payroll_utils.ltr_state_tax_info(p_state_code).sdi_er_limit;
    elsif p_tax_type = 'SUI EE' then
        ln_state_tax_limit := pay_us_payroll_utils.ltr_state_tax_info(p_state_code).sui_ee_limit;
    elsif p_tax_type = 'SUI ER' then
        ln_state_tax_limit := pay_us_payroll_utils.ltr_state_tax_info(p_state_code).sui_er_limit;
    end if;

    if ln_state_tax_limit is null then
        ln_state_tax_limit := 0;
    end if;
    hr_utility.trace('Returning tax limit ' || p_tax_type || ' for the state code ' || to_char (p_state_code) ||' with
the value as ' ||to_char(ln_state_tax_limit));
    return (ln_state_tax_limit);
  EXCEPTION
    when others then
        return 0;
  END get_state_limit;

-------------------- START STATE TAXES ---------------------------------
--
procedure load_state_taxes (p_asg_id          number,
                            p_ppa_finder      varchar2,
                            p_asg_action_id   number,
                            p_as_of_date      date,
                            p_tax_unit_id     varchar2,
                            p_tax_type        varchar2,
                            p_tax_group       varchar2,
			    p_chnkno          number) is

cursor C_state_taxes is
  select /*+RULE */
     pus.state_abbrev,
     pest.state_code,
     pest.jurisdiction_code
   from
      pay_us_emp_state_tax_rules_f pest,
      pay_us_states pus
   where
         pest.assignment_id = p_asg_id
     and p_as_of_date between pest.effective_start_date
                          and pest.effective_end_date
     and pus.state_code = pest.state_code
     order by state_abbrev;
--
-- local variables
l_over_limit number;
l_tax_person_id   number;
l_state_abbrev    varchar2(240);
l_state_code      varchar2(10);
l_state_tax_type  varchar2(240);
l_state_tax_limit number;
l_state_taxable_value number;

l_jurisdiction_code     pay_us_emp_state_tax_rules_f.jurisdiction_code%type;

--  #2938556
l_assignment_number	per_assignments_f.assignment_number%type;
l_person_id		per_assignments_f.person_id%type;
l_first_name		per_people_f.first_name%type;
l_middle_name		per_people_f.middle_names%type;
l_last_name		per_people_f.last_name%type;
l_ssn			per_people_f.national_identifier%type;
l_prev_asg_act_id       pay_assignment_actions.assignment_action_id%type;
new_asg_act_id          pay_assignment_actions.assignment_action_id%type;
  l_count  number := 1;
  l_bal_id number;


--
--
begin
     hr_utility.set_location('IN load_state_taxes ',300);

/* do not execute this procedure if the tax type is for federal */

     if (( p_tax_type is null ) or
         ( p_tax_type not in ('FUTA', 'SS ER', 'SS EE', '401K','403B','457','401K CATCHUP','403B CATCHUP','457 CATCHUP'))
        ) then

        open c_state_taxes;
        loop
           fetch c_state_taxes into
                              l_state_abbrev,
                              l_state_code,
                              l_jurisdiction_code;

          hr_utility.trace('Number of STATE TAXES Records fetched = '||to_char(c_state_taxes%ROWCOUNT));
          exit when c_state_taxes%notfound;

	  l_count := t_state_balance_list.count;


	  for i in 1 .. l_count loop

	   l_state_tax_type := t_state_balance_list(i).tax_type;
	   l_bal_id := t_state_balance_list(i).balance_id;

           if (l_state_abbrev = 'NY' or l_state_abbrev = 'HI') then
              if  l_state_tax_type in('SDI EE','SDI ER') then
                 l_state_tax_type := 'xx';
              end if;
           end if;
           hr_utility.trace('STATE = '|| l_state_abbrev);
           hr_utility.trace('Tax Type  : ' || l_state_tax_type);
           hr_utility.trace('Balance Id  : ' || l_bal_id);

	          l_state_taxable_value := get_taxable_balance(
                                              p_asg_id,
                                              p_as_of_date,
                                              p_asg_action_id,
                                              p_tax_unit_id,
                                              p_tax_group,
                                              l_jurisdiction_code,
                                              l_state_tax_type,
                                              l_bal_id);
                 l_state_tax_limit := get_state_limit( l_state_code,
					               l_state_tax_type);

          -- calculate the over limit amount
          hr_utility.trace('State Taxable Value is : '|| to_char(l_state_taxable_value));
          hr_utility.trace('State Tax Limit is : ' ||to_char(l_state_tax_limit));

          l_over_limit := nvl(l_state_taxable_value,0) - nvl(l_state_tax_limit,0);

          -- need to insert those rows that have over limit > 0

          if nvl(l_over_limit,0) > 0 then
     	    if (l_prev_asg_act_id = p_asg_action_id) then

              null;

	    else

	     l_prev_asg_act_id := p_asg_action_id;
	     if (g_inserted_asg_action_id_flag  = 'N') then
	        select pay_assignment_actions_s.nextval
                into   new_asg_act_id
                from   dual;

                -- insert the action record.
	        hr_utility.trace('New Assignment action id: '||to_char(new_asg_act_id));
	        hr_utility.trace('Assignment id: '||to_char(p_asg_id));

                hr_nonrun_asact.insact(new_asg_act_id,p_asg_id,t_payroll_action_id,p_chnkno,p_tax_unit_id);
                g_inserted_asg_action_id_flag  := 'Y';
              else
                g_inserted_asg_action_id_flag  := 'N';
      	        new_asg_act_id := g_inserted_asg_action_id;
                hr_utility.trace('Inserted Assignment action id: '||to_char(new_asg_act_id));
             end if;
                select paf.assignment_number
		      ,paf.person_id
	      	      ,ppf.first_name
                      ,ppf.middle_names
		      ,ppf.last_name
		      ,ppf.national_identifier
		into   l_assignment_number
		      ,l_person_id
		      ,l_first_name
		      ,l_middle_name
		      ,l_last_name
		      ,l_ssn
		from  per_assignments_f paf
  		     ,per_people_f      ppf
		where paf.assignment_id = p_asg_id
		and   paf.effective_end_date = ( select max(paf1.effective_end_date)
                                                    from per_assignments_f paf1
                                                    where paf1.assignment_id = paf.assignment_id
                                                      and paf1.effective_start_date <= p_as_of_date)
		and   ppf.person_id = paf.person_id
		and   p_as_of_date between ppf.effective_start_date and ppf.effective_end_date;
             end if;

	     insert into pay_us_rpt_totals
                   ( attribute2, -- :PACTID
                     session_id,
                     tax_unit_id,
                     gre_name, organization_name,
                     location_name, state_code, state_abbrev
                    ,value7      -- asg. id
                    ,attribute7  -- tax type
                    ,value1       -- state_taxable_value
                    ,value2       -- state_over_limit
                    ,value3       -- state_tax_limit
		    ,attribute5   -- New Assignment Action id
		    ,attribute10   -- Assignment number
		    ,attribute11  -- Person id
		    ,attribute12  -- First name
		    ,attribute13  -- Middle name
                    ,attribute14  -- Last name
		    ,attribute15  -- SSN
                   )
             values
                  (t_payroll_action_id
                  ,p_ppa_finder
                  ,p_tax_unit_id
                  ,l_gre_name, l_org_name
                  ,l_location_code, l_state_code, l_state_abbrev
                  ,p_asg_id
                  ,l_state_tax_type
                  ,nvl(l_state_taxable_value,0)
                  ,l_over_limit
                  ,nvl(l_state_tax_limit,0)
		  ,new_asg_act_id
		  ,l_assignment_number
		  ,l_person_id
                  ,l_first_name
	          ,l_middle_name
		  ,l_last_name
		  ,l_ssn
                  );

        	hr_utility.trace('Inserting a record in pay_us_rpt_totals for the employee ' ||l_last_name || ' ' ||
l_first_name );
		hr_utility.trace('Inserted chunk number ' ||p_chnkno || ' for tax type ' || l_state_tax_type );

          end if;
	end loop;

      end loop;
        close c_state_taxes;

     end if;

        hr_utility.set_location('OUT load_state_taxes ',350);

exception
    when others then
         hr_utility.trace('Error occurred load_state_taxes ...' ||SQLERRM);
         raise;
end load_state_taxes;
-- -----------------------------------------------------------------------+
--                     START FEDERAL TAXES                                +
-- -----------------------------------------------------------------------+
--
-- Get USERRA balance and checks whether person is over the limit
-- Returns new over limit balance (2693022)
--
procedure Process_USERRA_balance(p_tax_type                    varchar2,
                                 p_over_limit    IN OUT nocopy number,
                                 p_business_group_id      number,
                                 p_as_of_date             date,
                                 p_asg_action_id          number,
                                 p_tax_unit_id            number) is
 --
 l_temp_over_limit  number;
 l_bal_feed_exists  varchar2(1);
 l_bal_name         pay_balance_types.balance_name%TYPE;
 l_bal_type_id      pay_balance_types.balance_type_id%TYPE;
 l_bal_dimension    varchar2(150) := 'Person within Government Reporting Entity Year to Date';
 l_def_balance_id   ff_user_entities.creator_id%TYPE;
 l_value            number;

 --
 cursor csr_balance_type(cp_tax_type varchar2
                       , cp_bg_id    number
                        ) is
    select bal.balance_type_id, bal.balance_name
    from pay_balance_types   bal
    where bal.balance_name    like cp_tax_type
      and bal.business_group_id  = cp_bg_id
    order by bal.balance_name DESC;
 --
 cursor csr_balance_feed(cp_balance_type_id number, cp_bg_id number) is
    select 'Y'
    from pay_balance_feeds_f
    where balance_type_id   = cp_balance_type_id
      and business_group_id = cp_bg_id;
 --
 cursor csr_def_balance(cp_balance_type_id number
                       ,cp_bg_id           number
                       ,cp_dimension       varchar2) is
        select def.defined_balance_id
        from pay_defined_balances   def
            ,pay_balance_dimensions dim
        where def.balance_type_id      = cp_balance_type_id
          and def.business_group_id    = cp_bg_id
          and def.balance_dimension_id = dim.balance_dimension_id
          and dim.legislation_code = 'US'
          and dim.dimension_name = cp_dimension;
 --
begin
   l_temp_over_limit := p_over_limit;
   -- Check whether balances exist
   open csr_balance_type('W2 USERRA '||p_tax_type||'%'
                        ,p_business_group_id);
   fetch csr_balance_type into l_bal_type_id, l_bal_name;
   --
   Loop

     exit when (csr_balance_type%NOTFOUND)
            or (l_temp_over_limit <= 0);
     --
     -- Check whether the balance is fed
     open csr_balance_feed(l_bal_type_id, p_business_group_id);
     fetch csr_balance_feed into l_bal_feed_exists;
     --
     if csr_balance_feed%FOUND then
        --
        -- Get the balance and update the over limit amount
        --
        open csr_def_balance(l_bal_type_id
                           , p_business_group_id
                           , l_bal_dimension);
        fetch csr_def_balance into l_def_balance_id;
        --
        if csr_def_balance%FOUND then
           -- Get balance
           pay_us_balance_view_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
           l_value := nvl(pay_us_balance_view_pkg.get_value
               (
                 p_defined_balance_id   => l_def_balance_id
                ,p_assignment_action_id => p_asg_action_id
                ),0);
           -- Update over limit amount
           l_temp_over_limit := l_temp_over_limit - l_value;
        end if;
        close csr_def_balance;
     end if;
     close csr_balance_feed;
     --
     fetch csr_balance_type into l_bal_type_id, l_bal_name;
   end loop;
   close csr_balance_type;
   p_over_limit := l_temp_over_limit;

end Process_USERRA_balance;
-- -----------------------------------------------------------------------+
--                     load_federal_taxes                                 +
-- -----------------------------------------------------------------------+
procedure load_federal_taxes (p_asg_id            number,
                              p_ppa_finder        varchar2,
                              p_asg_action_id     number,
                              p_as_of_date        date,
                              p_tax_unit_id       number,
                              p_tax_type          varchar2,
                              p_business_group_id number,    -- #2693022
                              p_tax_group         varchar2,
			      p_chnkno            number) is

--
-- local variables
--
  l_fed_taxable_value number;
  l_futa_wage_limit   number;
  l_ss_ee_wage_limit  number;
  l_ss_er_wage_limit  number;
  l_fed_401k_limit   varchar2(240);
  l_fed_403b_limit   varchar2(240);
  l_fed_457_limit    varchar2(240);
  l_over_limit       number := 0;
  l_fed_tax_limit    number;
  l_fed_tax_type    varchar2(240);
  l_fed_roth_taxable_value number;  --- Added the last 2 for bug 4521358
  l_fed_roth_balance_id number;



  -- #2938556
  l_assignment_number	per_assignments_f.assignment_number%type;
  l_person_id		per_assignments_f.person_id%type;
  l_first_name		per_people_f.first_name%type;
  l_middle_name		per_people_f.middle_names%type;
  l_last_name		per_people_f.last_name%type;
  l_ssn			per_people_f.national_identifier%type;
  l_fed_401k_catchup_limit number;
  l_fed_403b_catchup_limit number;
  l_fed_457_catchup_limit number;
  l_dcp_limit             number;
  l_prev_asg_act_id        pay_assignment_actions.assignment_action_id%type;
  new_asg_act_id           pay_assignment_actions.assignment_action_id%type;
  l_count  number := 1;
  l_bal_id number;
--
--
begin
     hr_utility.set_location('IN load_federal_taxes ',400);

/* do not execute this procedure if the tax type is for state */

     if (( p_tax_type is null ) or
         ( p_tax_type in ('FUTA', 'SS ER', 'SS EE', '401K','403B','401K ROTH','403B ROTH','457','401K CATCHUP','403B CATCHUP','457 CATCHUP','DCP'))
        ) then


/* We should consider getting the federal taxes along with 403 and 457 limits
   once and put them in PL/SQL table for performance */

     -- get 401K, SS and FUTA limits.
  -- #2938556
	l_futa_wage_limit   := pay_us_payroll_utils.ltr_fed_tax_info(1).futa_wage;
	l_ss_ee_wage_limit  := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_wage;
	l_ss_er_wage_limit  := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_wage;
	l_fed_401k_limit    := pay_us_payroll_utils.ltr_fed_tax_info(1).p401_limit;
	l_fed_403b_limit    := pay_us_payroll_utils.ltr_fed_tax_info(1).p403_limit;
	l_fed_457_limit     := pay_us_payroll_utils.ltr_fed_tax_info(1).p457_limit;
	l_fed_401k_catchup_limit     := pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_401k;
	l_fed_403b_catchup_limit     := pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_403b;
	l_fed_457_catchup_limit      := pay_us_payroll_utils.ltr_fed_tax_info(1).catchup_457;
	l_dcp_limit      := pay_us_payroll_utils.ltr_fed_tax_info(1).dcp_limit;

        hr_utility.trace('FUTA  : ' || to_char(l_futa_wage_limit));
        hr_utility.trace('SS EE : ' || to_char(l_ss_ee_wage_limit));
        hr_utility.trace('SS ER : ' || to_char(l_ss_er_wage_limit));
        hr_utility.trace('401K  : ' || l_fed_401k_limit);
        hr_utility.trace('403B : ' || l_fed_403B_limit);
        hr_utility.trace('457  : ' || l_fed_457_limit);
        hr_utility.trace('Tax Type  : ' || p_tax_type);
        --

 l_count := t_fed_balance_list.count;

 for i in 1 .. l_count loop
   l_fed_tax_type := t_fed_balance_list(i).tax_type;
        hr_utility.trace('Tax Type  : ' || l_fed_tax_type);
   l_bal_id := t_fed_balance_list(i).balance_id;

            l_fed_taxable_value := get_taxable_balance(
                                                p_asg_id,
                                                p_as_of_date,
                                                p_asg_action_id,
                                                p_tax_unit_id,
                                                p_tax_group,
                                                null,
                                                l_fed_tax_type,
                                                 l_bal_id);

        -- calculate the over limit amount
        if l_fed_tax_type = 'FUTA' then
            l_over_limit := nvl(l_fed_taxable_value,0) - nvl(l_futa_wage_limit,0);
            l_fed_tax_limit := nvl(l_futa_wage_limit,0);
        elsif l_fed_tax_type = 'SS ER' then
            l_over_limit := nvl(l_fed_taxable_value,0) - nvl(l_ss_er_wage_limit,0);
            l_fed_tax_limit := nvl(l_ss_er_wage_limit,0);
        elsif l_fed_tax_type = 'SS EE' then
            l_over_limit := nvl(l_fed_taxable_value,0) - nvl(l_ss_ee_wage_limit,0);
            l_fed_tax_limit := nvl(l_ss_ee_wage_limit,0);
        elsif l_fed_tax_type = '401K' then
            l_fed_tax_limit := nvl(to_number(l_fed_401k_limit),0);

            -- Added for bug 4521358
            -- We get the balance_id for the 401k Roth deduction
            -- and pass that to get_taxable_balance. Then, we add the
            -- balance values of both deferred and Roth deductions to
            -- check for the over limit report.

            l_fed_roth_balance_id := get_roth_balance_id(l_fed_tax_type);
            l_fed_roth_taxable_value := get_taxable_balance(
                                                p_asg_id,
                                                p_as_of_date,
                                                p_asg_action_id,
                                                p_tax_unit_id,
                                                p_tax_group,
                                                null,
                                                '401K ROTH',
                                                l_fed_roth_balance_id);
            l_fed_taxable_value := l_fed_taxable_value + l_fed_roth_taxable_value;

            -----
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;
            if l_over_limit > 0 then  -- #2693022
               Process_USERRA_balance(l_fed_tax_type,
                                      l_over_limit,
                                      p_business_group_id,
                                      p_as_of_date,
                                      p_asg_action_id,
                                      p_tax_unit_id
                                      );
            end if;

        elsif l_fed_tax_type = '403B' then
            l_fed_tax_limit := nvl(to_number(l_fed_403b_limit),0);

             -- Added for bug 4521358

            l_fed_roth_balance_id := get_roth_balance_id(l_fed_tax_type);
            l_fed_roth_taxable_value := get_taxable_balance(
                                                p_asg_id,
                                                p_as_of_date,
                                                p_asg_action_id,
                                                p_tax_unit_id,
                                                p_tax_group,
                                                null,
                                                '403B ROTH',
                                                l_fed_roth_balance_id);
            l_fed_taxable_value := l_fed_taxable_value + l_fed_roth_taxable_value;

            -----

            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;
            if l_over_limit > 0 then  -- #2693022
               Process_USERRA_balance(l_fed_tax_type,
                                      l_over_limit,
                                      p_business_group_id,
                                      p_as_of_date,
                                      p_asg_action_id,
                                      p_tax_unit_id
                                      );
            end if;

         -- Added for bug 4521358. Here the l_count is being checked because
         -- when no tax_type is selected while passing it as a parameter, the
         -- employees will appear twice, once in the '401K' tax_type and again
         -- in '401K Roth' tax_type.

        elsif ( l_fed_tax_type = '401K ROTH' and l_count = 1 ) then
            l_fed_tax_limit := nvl(to_number(l_fed_401k_limit),0);
            l_fed_roth_balance_id := get_roth_balance_id(l_fed_tax_type);
            l_fed_roth_taxable_value := get_taxable_balance(
                                                p_asg_id,
                                                p_as_of_date,
                                                p_asg_action_id,
                                                p_tax_unit_id,
                                                p_tax_group,
                                                null,
                                                '401K',
                                                l_fed_roth_balance_id);
            l_fed_taxable_value := l_fed_taxable_value + l_fed_roth_taxable_value;
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;
            if l_over_limit > 0 then  -- #2693022
               Process_USERRA_balance(l_fed_tax_type,
                                      l_over_limit,
                                      p_business_group_id,
                                      p_as_of_date,
                                      p_asg_action_id,
                                      p_tax_unit_id
                                      );
            end if;

        elsif ( l_fed_tax_type = '403B ROTH' and l_count = 1 ) then
            l_fed_tax_limit := nvl(to_number(l_fed_403b_limit),0);
            l_fed_roth_balance_id := get_roth_balance_id(l_fed_tax_type);
            l_fed_roth_taxable_value := get_taxable_balance(
                                                p_asg_id,
                                                p_as_of_date,
                                                p_asg_action_id,
                                                p_tax_unit_id,
                                                p_tax_group,
                                                null,
                                                '403B',
                                                l_fed_roth_balance_id);
            l_fed_taxable_value := l_fed_taxable_value + l_fed_roth_taxable_value;
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;
            if l_over_limit > 0 then  -- #2693022
               Process_USERRA_balance(l_fed_tax_type,
                                      l_over_limit,
                                      p_business_group_id,
                                      p_as_of_date,
                                      p_asg_action_id,
                                      p_tax_unit_id
                                      );
            end if;
-------------------------

        elsif l_fed_tax_type = '457' then
            l_fed_tax_limit := nvl(to_number(l_fed_457_limit),0);
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;
            if l_over_limit > 0 then -- #2693022
               Process_USERRA_balance(l_fed_tax_type,
                                      l_over_limit,
                                      p_business_group_id,
                                      p_as_of_date,
                                      p_asg_action_id,
                                      p_tax_unit_id
                                      );
            end if;
        --
        -- # 2664340: Process Catchup balances
        elsif l_fed_tax_type = '401K CATCHUP' then

            l_fed_tax_limit := nvl(l_fed_401k_catchup_limit,0);
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;

        elsif l_fed_tax_type = '403B CATCHUP' then

            l_fed_tax_limit := nvl(l_fed_403b_catchup_limit,0);
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;

        elsif l_fed_tax_type = '457 CATCHUP' then

            l_fed_tax_limit := nvl(l_fed_457_catchup_limit,0);
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;

        elsif l_fed_tax_type = 'DCP' then
            l_fed_tax_limit := NVL(l_dcp_limit,0);
            l_over_limit := nvl(l_fed_taxable_value,0) - l_fed_tax_limit;
        end if;

       	  hr_utility.trace('Federal Taxable Value is : '|| to_char(l_fed_taxable_value));
          hr_utility.trace('Federal Tax Limit is : ' ||to_char(l_fed_tax_limit));

        -- need to insert those rows that have over limit > 0
        if nvl(l_over_limit,0) > 0 then
	  if (l_prev_asg_act_id = p_asg_action_id) then

            null;

	  else

	     l_prev_asg_act_id := p_asg_action_id;

	     select pay_assignment_actions_s.nextval
             into   new_asg_act_id
             from   dual;

	     -- insert the action record.
	     hr_utility.trace('New Assignment action id: '||to_char(new_asg_act_id));
	     hr_utility.trace('Assignment id: '||to_char(p_asg_id));

             hr_nonrun_asact.insact(new_asg_act_id,p_asg_id,t_payroll_action_id,p_chnkno,p_tax_unit_id);
	     g_inserted_asg_action_id := new_asg_act_id;
	     g_inserted_asg_action_id_flag  := 'Y';
             select paf.assignment_number
	           ,paf.person_id
		   ,ppf.first_name
                   ,ppf.middle_names
		   ,ppf.last_name
		   ,ppf.national_identifier
	      into  l_assignment_number
		   ,l_person_id
		   ,l_first_name
		   ,l_middle_name
		   ,l_last_name
		   ,l_ssn
              from  per_assignments_f paf
  		   ,per_people_f      ppf
              where paf.assignment_id = p_asg_id
	      and   paf.effective_end_date = ( select max(paf1.effective_end_date)
                                               from per_assignments_f paf1
                                               where paf1.assignment_id = paf.assignment_id
                                               and paf1.effective_start_date <= p_as_of_date)
	      and   ppf.person_id = paf.person_id
	      and   p_as_of_date between ppf.effective_start_date and ppf.effective_end_date;

	 end if;

           insert into pay_us_rpt_totals
               ( attribute2 -- :PACTID
                ,session_id
                ,tax_unit_id
                ,gre_name, organization_name, location_name
                ,value7      -- asg. id
                ,attribute7  -- tax type
                ,value1       -- fed_taxable_value
                ,value2       -- fed_over_limit
                ,value3       -- fed_tax_limit
       		,attribute5   -- New Assignment Action id
       		,attribute10   -- Assignment number
		,attribute11  -- Person id
		,attribute12  -- First name
		,attribute13  -- Middle name
                ,attribute14  -- Last name
		,attribute15  -- SSN
               )
           values
               (t_payroll_action_id
               ,p_ppa_finder
               ,p_tax_unit_id
               ,l_gre_name, l_org_name, l_location_code
               ,p_asg_id
               ,l_fed_tax_type
               ,l_fed_taxable_value
               ,l_over_limit
               ,l_fed_tax_limit
               ,new_asg_act_id
	       ,l_assignment_number
	       ,l_person_id
	       ,l_first_name
	       ,l_middle_name
	       ,l_last_name
	       ,l_ssn
                );
	hr_utility.trace('Inserting a record in pay_us_rpt_totals for the employee ' ||l_last_name || ' ' || l_first_name
);
	hr_utility.trace('Inserted chunk number ' ||p_chnkno || ' for tax type ' || l_fed_tax_type );
        end if; -- over limit > 0

        end loop;
--        close c_balance_sets;
     end if; /* tax type is null or one of the federal limit tax */

     hr_utility.set_location('OUT load_federal_taxes ',450);

exception
    when others then
         hr_utility.trace('Error occurred load_federal_taxes ...' ||SQLERRM);
         raise;
end load_federal_taxes;
--
--------------------- END FEDERAL TAXES -----------------------------------
--
procedure load_data
(
   pactid     in     number,     /* payroll action id */
   chnkno     in     number,
   p_assignment_id     		IN	NUMBER,
   p_assignment_action_id    	IN 	NUMBER,
   p_tax_unit_id             	IN 	NUMBER
) is

  cursor sel_aaid (l_aaid   number)
  is
 select
          ppa_arch.start_date          start_date,
          ppa_arch.effective_date      end_date,
          ppa_arch.business_group_id   business_group_id,
          ppa_arch.payroll_action_id   payroll_action_id,
--          to_number(paa.serial_number) assignment_action_id, -- max assignment_action_id
          paa.assignment_id            assignment_id,
          paa.tax_unit_id              tax_unit_id,
          hou.name                     gre_name,
          paf.organization_id          organization_id,
          hou1.name                    organization_name,
          paf.location_id              location_id,
          hrl.location_code            location_code,
          paf.effective_end_date       max_end_date
  from    hr_locations_all             hrl,
          hr_all_organization_units    hou1,
          hr_all_organization_units    hou,
          per_assignments_f            paf,
          pay_assignment_actions       paa,     -- PYUGEN
          pay_payroll_actions          ppa_arch -- PYUGEN
    where
--    ppa_arch.payroll_action_id = l_pactid
      paa.assignment_action_id   = l_aaid
      and paa.payroll_action_id      = ppa_arch.payroll_action_id
--      and paa.chunk_number           = l_chnkno
      and paf.assignment_id          = paa.assignment_id
      and paf.effective_end_date     = ( select max(effective_end_date)
                                         from per_assignments_f paf1
                                         where paf1.assignment_id = paf.assignment_id
                                           and paf1.effective_start_date <=
                                                        ppa_arch.effective_date
                                        )
      and hrl.location_id            = NVL(paf.location_id,hou.location_id)
      and hou1.organization_id       =  nvl(paf.organization_id,paf.business_group_id)
      and hou.organization_id        = paa.tax_unit_id;

l_bal_date    per_assignments_f.effective_end_date%TYPE;
new_asg_act_id           pay_assignment_actions.assignment_action_id%type;
--
--
--------------------------- M A I N -------------------------------------
begin
    --hr_utility.trace_on(null,'oracle');

    hr_utility.set_location('IN load data',500);

    hr_utility.trace('PACTID = '||pactid);
    hr_utility.trace('CHNKNO = '||to_char(chnkno));
    begin
      if g_get_param = 'Y' then
         g_get_param := 'N';
        select ppa.legislative_parameters,
               ppa.business_group_id,
               ppa.start_date,
               ppa.effective_date,
               pay_us_over_limit_pkg.get_parameter('GRE',ppa.legislative_parameters),
               pay_us_over_limit_pkg.get_parameter('AS_OF_DATE',ppa.legislative_parameters),
               pay_us_over_limit_pkg.get_parameter('TAX_TYPE',ppa.legislative_parameters),
	       pay_us_over_limit_pkg.get_parameter('PPA_FINDER',ppa.legislative_parameters),
               ppa.payroll_action_id
          into l_leg_param,
               l_business_group_id,
               l_leg_start_date,
               l_leg_end_date,
               t_gre_id,
               l_date_prm,
               l_tax_type,
	       l_ppa_finder,
               t_payroll_action_id
          from pay_payroll_actions ppa
         where ppa.payroll_action_id = pactid;


         /* the tax type returned is like SDI_EE whereas the value stored
            in the table is SDI EE hence we need to replace '_' with null */

         l_tax_type   := replace(l_tax_type,'_',' ');

      end if;
    exception when no_data_found then
              hr_utility.trace('Legislative Details not found...');
              raise;
    end;

    g_inserted_asg_action_id_flag := 'N';
    l_as_of_date := to_date(l_date_prm,'YYYY/MM/DD');

    if (pay_us_payroll_utils.ltr_fed_tax_info.count < 1 or pay_us_payroll_utils.ltr_state_tax_info.count < 1  ) THEN
        hr_utility.trace('Inserting Limit Values using utilities package');
        pay_us_payroll_utils.populate_jit_information(p_effective_date => l_as_of_date
        						,p_get_federal => 'Y'
        						,p_get_state  => 'Y');
    end if;



-- removed the select statement to fetch parameters as part of bug # 2938556

--  Removed call to   populate_state_limits_table as part of bug # 2938556
    --
    open sel_aaid (p_assignment_action_id);
        fetch sel_aaid into  l_start_date,
                             l_end_date,
                             l_business_group_id,
                             l_payroll_action_id,
--                             l_assignment_action_id,
                             l_assignment_id,
                             l_tax_unit_id,
                             l_gre_name,
                             l_organization_id,
                             l_org_name,
                             l_location_id,
                             l_location_code,
                             l_bal_date;



        hr_utility.trace('Chunk No          = '||to_char(chnkno));
        hr_utility.trace('Start Date        = '||to_char(l_start_date));
        hr_utility.trace('End Date          = '||to_char(l_end_date));
        hr_utility.trace('BG ID             = '||to_char(l_business_group_id));
        hr_utility.trace('Payroll Action ID = '||to_char(l_payroll_action_id));
        hr_utility.trace('Action Type       = '||l_action_type);
        hr_utility.trace('Asg Act ID        = '||to_char(p_assignment_action_id));
        hr_utility.trace('Asg ID            = '||to_char(l_assignment_id));
        hr_utility.trace('Tax Unit ID       = '||to_char(l_tax_unit_id));
        hr_utility.trace('GRE Name          = '||l_gre_name);

        l_tax_group := Tax_group(l_tax_unit_id);

        hr_utility.trace('Tax Group           = '||l_tax_group);

-- Insert a dummy assignment action to enable the report to be fired in case of
-- no employee is found.

 -- Bug No 3118107 removed insertion of dummy assignment action
 if  p_insert_done_flag = 'N' then
     l_prev_tg := l_tax_group;
 end if;

        -- # 2664340
        -- Clear the catchup balances table
        -- commented for # 2938556
--
--         t_fed_catchup_balance.DELETE;
        --
-- We have to check the as_of_date with the effective_end_date of the assignment
-- and pass in the date that is less. This is required for terminated employees
-- Employees who have been terminated before the as_of_date.

        if l_bal_date < l_as_of_date then

            l_as_of_date := l_bal_date;

        end if;

-- Check if the tax group changes

if ( l_prev_tg <> l_tax_group) then
 l_prev_tg := l_tax_group;
 l_tg_changed := 'Y';
end if;

-- Populate the federal balances table only if that is empty
-- or if the tax group changes.

 if (t_fed_balance_list.count < 1  or l_tg_changed = 'Y' ) THEN
   populate_fed_balance_list(l_tax_type,l_tax_group);
   l_tg_changed := 'N';
 end if;

-- Populate the state balances table only if that is empty.

if (t_state_balance_list.count < 1 ) THEN
    populate_state_balance_list(l_tax_type);
end if;


-- Call load_federal_taxes to process federal balances

        load_federal_taxes(l_assignment_id -- Bug3018606
                          ,l_ppa_finder
                          ,p_assignment_action_id
                          ,l_as_of_date
                          ,p_tax_unit_id
                          ,l_tax_type
                          ,l_business_group_id
                          ,l_tax_group
			  ,chnkno);

-- Call load_state_taxes to process state balances

        load_state_taxes(l_assignment_id --Bug3018606
                        ,l_ppa_finder
                        ,p_assignment_action_id
                        ,l_as_of_date
                        ,p_tax_unit_id
                        ,l_tax_type
                        ,l_tax_group
			,chnkno);

    hr_utility.trace('End of LOAD DATA');
    hr_utility.set_location('OUT load data',550);

    -----------------------------------------------
    --Bug # 3118107
    -----------------------------------------------

    if p_insert_done_flag = 'N' then
       select pay_assignment_actions_s.nextval
       into new_asg_act_id
       from dual;

        --insert the action record
       hr_nonrun_asact.insact(new_asg_act_id,p_assignment_id,pactid,chnkno,p_tax_unit_id);
       p_insert_done_flag := 'Y';
    end if;
    close sel_aaid;
exception
    when others then
    hr_utility.trace('Error occurred load_data ...' ||SQLERRM);
    raise;

end load_data;
--------------------------end load data-----------------------------

END pay_us_over_limit_tax_rpt_pkg;

/
