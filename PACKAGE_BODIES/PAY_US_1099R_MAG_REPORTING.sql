--------------------------------------------------------
--  DDL for Package Body PAY_US_1099R_MAG_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_1099R_MAG_REPORTING" AS
/* $Header: pyyep99r.pkb 120.3.12010000.2 2009/12/15 06:47:58 svannian ship $ */
/*
   ******************************************************************
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

    Name        : pay_us_1099r_mag_reporting

    Description : Generate 1099R end of year magnetic reports according to
                  US legislative requirements.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    01-OCT-98   AHANDA   40.0            Created.
    11-JAN-99   AHANDA   40.5            Tuned the Queries.
    22-JAN-99   AHANDA   40.6            Changed the cursor for range_cursor,
                                         assignment_action_creation and
                                         preprocess_check to check for
                                         assignment action in that year.
    28-MAY-99	rthakur  40.7    875113  Arizona no longer requires the 1099R
                                         for employees with no SIT withheld.
                                         Changed the logic in the
                                         preprocess_check function.
                                         In the action creation cursor, changed
                                         the logic to only look for assignments
                                         that fall underneath the TCC.
    27-JUN-99	rthakur	 40.8            Commented out the call to trace_on.
    27-JUN-99   rthakur  40.9            Fixed order by clause on c_gre_federal.
                                         Commented out exists clause in assign.
                                         action creation cursors because the
                                         logic is being duplicated by the year
                                         end pre-processor.
    02-JUL-99   rthakur  40.10           Added some more debugging information.
    02-JUL-99   rthakur  40.11           Changed c_chk_cntc_info to take into
                                         account different character TCC's.
    24-JUL-99   rthakur  40.12           Modified the preprocess check to take
                                         into account Transmitter GREs not
                                         being archived.
    30-AUG-99   rthakur  40.13/14        Modified the action creation code to
                                         look at archived TCC instead of live.
    21-SEP-99   rthakur  115.2           Arcsd in 110.8 of r11.
    04-MAR-01   mreid    115.4           Corrected error message number
    02-AUG-01   ekim     115.5           Added cursor c_chk_vnd_info
                                         to check for vendor information
                                         Bug 1811755.
    06-SEP-01   ekim     115.6           Changed message to
                                         PAY_34980_TRSMTR_VND_NOT_FOUND
                                         for missing vendor information error.
    07-SEP-01   ekim     115.7           Added space in
                                         pay_mag_utils.get_parameter call.
    16-NOV-01   jgoswami 115.8           Added South Carolina to check if SIT>0.
    30-NOV-2001 jgoswami 115.9           Added dbdrv command
    08-AUG-2002 ahanda   115.10          Changed the following cursors for perf:
                                             - fed and state action creation
                                             - c_1099_gre_state
    03-dec-2002 djoshi   115.12          Added KS and MT logic record created
                                         only if sit = 0
    03-dec-2002 djoshi   115.13          Corrected typo
    07-DEC-2002 ahanda   115.14          Changed from clause to join to main
                                         table instead of secure views.
    08-DEC-2002 ahanda   115.15          Changed view to use pay_us_state_w2_v
                                         instead of pay_us_w2_state_v.
    19-MAY-2003 ahanda   115.16  2955696 Changed federal and state action_creation
                                         cursor to add ff_contexts and get only
                                         context of TAX_UNIT_ID.
    19-JUN-2003 ahanda   115.17  3013521 Changed federal and state action_creation
                                         cursor to add to_char for tax_unit_id.
                                         There will be no perf degradation as there
                                         is no index on tax_unit_id.
    30-OCT-2003 jgoswami 115.18 3209884  Modified mag_1099r_action_creation procedure
                                         Changed boundry conditions for employees to be reported on tape
                                         (creating assignemnt_action_id) for 1099R_STATE for folowing States
                                         'AR' if SIT > 0 or State_wages > 2500 changed to
                                         'AR' if SIT > 0 or State_wages > 0
                                         'KS' was SIT > 0 must be paper so we have 'KS' if SIT = 0 changed to
                                         'KS' if SIT > 0 or State_wages > 0
                                         'MT' if SIT > 0 must be Paper so we check SIT = 0 only, report on tape
   21-NOV-2003 jgoswami 115.19            Added check for 'KS' as mentioned in comments.
   02-JAN-2004 jgoswami 115.20  3349571   Reverted changes for 'KS' .
   27-JAN-2003 jgoswami 115.21  3381162   Check for gorss (box1) instead of
                                          checking taxable (Box 2a) in
                                          action_creation.
   11-NOV-2004 asasthan 115.22  2694998   Changed c_chk_cntc_info
                                          Should make tape error
                                          out if after replacing EXT etc
                                          the net result is NULL;
                                          It should be noted that in
                                          the US_1099R_TRANSMITTER
                                          in fields like vendorcontact phone
                                          if the data is simply a () and
                                          after replacement the net value is
                                          null then the tape will not fold
                                          properly but be short by that
                                          many characters as the length of the
                                          field.

   15-NOV-2004 asasthan 115.23  2694998   Added 'E' to strip
   12-AUG-2005 kvsankar 115.24  4347429   Modified the Pre Process
                                4344915   procedure to not to check
                                          for each and every assignment
                                          in the current GRE.
                                          The procedure now just
                                          checks for whether a GRE is archived
                                          or not. If not a warning will be
                                          given to Customer for archiving the
                                          same.
   14-MOV-2005 pragupta 115.25  4350849   Changed the condition w2_state_wages
                                          > 0 to >=0 in the range_cursor. Also
                                          changed the condition ln_box_17 > 0
                                          to >= 0 in the action_creation.
   17-MAR-2006 pragupta 115.26  4583577   Performace changes to remove merge
                                          join cartesian. Exists clause added
					  in the cursor tcc_1099R_cur. Added
					  date condition in Create Interlock
					  query in mag_1099r_action_creation.
*********************************************************************/

Function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val ff_archive_items.value%type;
  par_value ff_archive_items.value%type;
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


Procedure get_selection_information (
       p_payroll_action_id  in number,
       p_year_start        out nocopy date,
       p_year_end          out nocopy date,
       p_state_code        out nocopy varchar2,
       p_state_abbrev      out nocopy varchar2,
       p_report_type       out nocopy varchar2,
       p_business_group_id out nocopy number,
       p_tax_unit_id       out nocopy number,
       p_trans_cont_code   out nocopy varchar2,
       p_yrend_ppa_id      out nocopy number)
is


-- Cursor to fetch the 1099R Transmitter Control Code for a particular gre

cursor tcc_1099R_cur(p_tax_unit_id NUMBER, p_business_group_id NUMBER) is
/*4583577 Perf change 1 start*/
select hoi2.org_information2
from hr_all_organization_units hou,
     hr_organization_information hoi2 -- 1099R transmitter
    where hou.business_group_id + 0    = p_business_group_id
      and hou.organization_id          = p_tax_unit_id
      and hoi2.organization_id         = hou.organization_id
      and hoi2.org_information_context = '1099R Magnetic Report Rules'
      and exists
          (select 'Y'
	   from hr_all_organization_units hou1, hr_organization_information hoi
              where hou1.business_group_id + 0   = p_business_group_id
 		and hou1.organization_id         = p_tax_unit_id
 		and hou1.organization_id         = hoi.organization_id
		and hoi.org_information_context  = 'CLASS'
		and hoi.org_information1         = 'HR_LEGAL');
/*4583577 Perf change 1 end*/

cursor c_sel is
 select ppa.start_date,
        ppa.effective_date,
        ppa.business_group_id,
        ppa.report_qualifier,
        ppa.report_type
   FROM pay_payroll_actions ppa
   WHERE payroll_action_id = p_payroll_action_id;

-- Cursor to fetch the YREND ARCHIVER Payroll action id for TCC Gre
cursor c_yrend_ppa(p_tax_unit_id NUMBER, p_payroll_action_id NUMBER) is
select ppa.payroll_action_id
from pay_payroll_actions ppa,  -- YREND
     pay_payroll_actions ppa1 -- 1099R
where ppa1.payroll_action_id = p_payroll_action_id  -- 1099R
and   ppa.report_type = 'YREND'
      and ppa.effective_date = ppa1.effective_date
      and ppa.business_group_id + 0 = ppa1.business_group_id
      and ppa.action_status = 'C'
      and rtrim(ltrim(Pay_Mag_Utils.Get_Parameter('TRANSFER_GRE',' ',ppa.legislative_parameters))) = p_tax_unit_id;


ln_business_group_id number;
lv_report_qualifier varchar2(30);
lv_report_type varchar2(30);
ld_year_start date;
ld_year_end date;
lv_state_code varchar2(10);
lv_tax_unit_id varchar2(30);
lv_trans_cont_code varchar2(30);
ln_yrend_ppa_id number;
lv_leg_param    pay_payroll_actions.legislative_parameters%type;

begin

hr_utility.trace('Entering pay_us_1099r_mag_reporting.get_selection_information');

 open c_sel;
 fetch c_sel into ld_year_start, ld_year_end, ln_business_group_id,
                  lv_report_qualifier, lv_report_type;

hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',10);

 if c_sel%notfound then

    hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',20);
    hr_utility.set_message(801, 'PAY_ARCH_GRE_NOT_FOUND');
    hr_utility.raise_error;

 end if;

 close c_sel;

    hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',30);

 if lv_report_qualifier = 'FED' then

    lv_state_code := ' ';
    lv_report_type := '1099R_FED';

 else
    select state_code into lv_state_code
      from pay_us_states
     where state_abbrev = lv_report_qualifier;

    lv_report_type := '1099R_STATE';

 end if;

    hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',40);

-- To get the tax unit id from legislative parameters
-- Note: The below get_parameter_value returns varchar2 so when we assign lv_tax_unit_id
-- to p_tax_unit_id we convert it to a number below.
-- We had to create a function to read from legislative parameters to get the tax_unit_id
-- of the transmitter GRE


   select legislative_parameters
     into lv_leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = p_payroll_action_id;

 lv_tax_unit_id := get_parameter('TRANSFER_TRANS_LEGAL_CO_ID', lv_leg_param);

    hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',50);
    hr_utility.trace('The tax unit id is :  '||lv_tax_unit_id);

-- To get the transmitter control code for the specific tax unit id

 open tcc_1099R_cur(lv_tax_unit_id, ln_business_group_id);
 fetch tcc_1099R_cur into lv_trans_cont_code;
	if tcc_1099R_cur%notfound then

        hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',60);
        hr_utility.set_message(801, 'PAY_ARCH_GRE_NOT_FOUND');
        hr_utility.raise_error;
	end if;
 close tcc_1099R_cur;

-- To get the YREND ppa ID

 open c_yrend_ppa(lv_tax_unit_id, p_payroll_action_id);
 fetch c_yrend_ppa into ln_yrend_ppa_id;

       if c_yrend_ppa %notfound then

       hr_utility.trace('Payroll action id: '||to_char(p_payroll_action_id));
       hr_utility.trace('Tax unit id:  '||lv_tax_unit_id);
       hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',65);
       hr_utility.set_message(801, 'PAY_ARCH_GRE_NOT_FOUND');
       hr_utility.raise_error;
       end if;

 close c_yrend_ppa;

 p_year_start := ld_year_start;
 p_year_end := ld_year_end;
 p_state_code := lv_state_code;
 p_state_abbrev := lv_report_qualifier;
 p_report_type := lv_report_type;
 p_business_group_id := ln_business_group_id;
 p_tax_unit_id := to_number(lv_tax_unit_id);
 p_trans_cont_code := lv_trans_cont_code;
 p_yrend_ppa_id    := ln_yrend_ppa_id;

hr_utility.set_location('pay_us_1099r_mag_reporting.get_selection_information',70);
hr_utility.trace('The year start from get_selection_information is:  '||to_char(ld_year_start));
hr_utility.trace('The year end from get_selection_information is:  '||to_char(ld_year_end));
hr_utility.trace('The state code from get_selection_information is:  '||lv_state_code);
hr_utility.trace('The state abbrev from get_selection_information is:  '||lv_report_qualifier);
hr_utility.trace('The report type from get_selection_information is:  '||lv_report_type);
hr_utility.trace('The business group id from get_selection_information is:  '||to_char(ln_business_group_id));
hr_utility.trace('The tax unit id from get_selection_information is:  '||lv_tax_unit_id);
hr_utility.trace('The transmitter control code from get_selection_information is:  '||lv_trans_cont_code);
hr_utility.trace('The year end payroll action id from get_selection_information is: '||to_char(ln_yrend_ppa_id));

hr_utility.trace('Exiting pay_us_1099r_mag_reporting.get_selection_information');

end get_selection_information;


Function get_balance_value (
        p_balance_name   in VARCHAR2,
        p_tax_unit_id    in NUMBER,
        p_state_abbrev   in VARCHAR2,
        p_assignment_id  in NUMBER,
        p_effective_date in DATE) RETURN NUMBER
is

lv_jurisdiction_code   varchar2(20);
ln_defined_balance_id  number;
ln_balance_value       number;

cursor c_jurisdiction (cp_state_abbrev varchar2) is
   select jurisdiction_code
    from pay_state_rules
   where state_code = cp_state_abbrev;

cursor c_defined_balance (cp_database_item varchar2)IS
   select to_number(ue.creator_id)
     from ff_database_items fdi,
          ff_user_entities ue
    where fdi.user_name = cp_database_item
      and ue.user_entity_id = fdi.user_entity_id
      and ue.creator_type = 'B';

begin

hr_utility.trace('Entering pay_us_1099r_mag_reporting.get_balance_value');

hr_utility.set_location ('pay_us_1099r_mag_reporting.get_balance_value', 10);

    open c_defined_balance(p_balance_name);
    fetch c_defined_balance into ln_defined_balance_id;
    close c_defined_balance;

    pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);

    if p_state_abbrev <> 'FED' THEN
       open c_jurisdiction(p_state_abbrev);
       fetch c_jurisdiction into lv_jurisdiction_code;
       close c_jurisdiction;

       hr_utility.set_location
              ('pay_us_1099r_mag_reporting.get_balance_value', 15);

       pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
    end if;

    hr_utility.trace(p_balance_name);
    hr_utility.trace('Context');
    hr_utility.trace('Tax Unit Id:  '|| p_tax_unit_id);
    hr_utility.trace('Jurisdiction: '|| lv_jurisdiction_code);
    hr_utility.set_location
            ('pay_us_1099r_mag_reporting.get_balance_value', 20);

    ln_balance_value := pay_balance_pkg.get_value
                               (ln_defined_balance_id,
                                p_assignment_id, p_effective_date);

hr_utility.trace('Exiting pay_us_1099r_mag_reporting.get_balance_value');

    return (ln_balance_value);


end get_balance_value;



  --------------------------------------------------------------------------
  --Name
  --  preprocess_check
  --Purpose
  --  This function checks if the year end preprocessor has been run for the
  --  GREs involved in the 1099R report. It also checks if any of the assignments
  --  have errored out or have been marked for retry. The checking is done based
  --  on the narrow scope of the parameters that the user has entered.
  --  The logic in how we check for the existence of and archived GRE depends on
  --  whether we are running the Federal or State 1099R.
  --
  --  We will always error out the 1099R Mag if the Transmitter GRE is not archived.
  --
  --     FEDERAL:
  --              1) Check for all 1099R GRE's within the transmitter control code.
  --              2) See if all the said GRE's have been archived.
  --                a) If YES, have then check for existence of errored or retried
  --                   assignment actions.
  --                b) If NO, then we check and see if the GRE should have been
  --     STATE:
  --             1) Check for all the 1099R GRE's which have assignments in the
  --                particular state and transmitter control code.
  --              2) See if the said GRE's have been archived.
  --                 a) If YES, have then check for existence of errored or retried
  --                    assignment actions.
  --                 b) If NO, then we check and see if the GRE should have been
  --                    archived.
  --
  --Arguments
  --  p_payroll_action_id   Payroll_action_id for the report
  --  p_year_start          Start date of the period for which the report
  --                        has been requested
  --  p_year_end            End date of the period
  --  p_business_group_id   Business group for which the report is being run
  --  p_state_abbrev        Two digit state abbreviation (or 'FED' for federal
  --                        report)
  --  p_state_code          State code (NULL for federal)
  --  p_report_type         Type of report being run (W2, 1099R ...)
  --  p_tax_unit_id         The GRE that was entered through SRS,
  --                        determined by the procedure get_selection_information
  --  p_trans_cont_code     The Transmitter Control Code of the GRE
  --                        determined by the procedure get_selection_information
  --Note:
  --  The check for errored/marked for retry  assignments can be bypassed by
  --  setting the parameter 'FORCE_MAG_REPORT' to 'E' and 'R' respectively. In
  --  such cases the report will ignore the assignments in question.
  --Note2:
  --  Our cursors here are going against the live data to verify that the
  --  pre-process check has run correctly and is returning the correct data.
  -----------------------------------------------------------------------------
--

Function preprocess_check (
   p_payroll_action_id in number,
   p_year_start        in date,
   p_year_end          in date,
   p_business_group_id in number,
   p_state_abbrev	    in varchar2,
   p_state_code        in varchar2,
   p_report_type       in varchar2,
   p_tax_unit_id       in number,
   p_trans_cont_code   in varchar2) RETURN BOOLEAN
is

-- Cursor to fetch all 1099R GREs belonging to the transmitter control code
-- This is ordering by the Transmitter indicator to always make the Transmitter
-- GRE pop to the top to make that one process first.

Cursor c_1099_fed_gre(p_trans_cont_code VARCHAR2) is
select  hou.organization_id, hoi2.org_information1
     from hr_all_organization_units hou,
          hr_organization_information hoi,
          hr_organization_information hoi2
    where hou.business_group_id + 0 = p_business_group_id
      and hou.organization_id = hoi.organization_id
      and hoi.org_information_context = 'CLASS'
      and hoi.org_information1 = 'HR_LEGAL'
      and hoi.organization_id = hoi2.organization_id
      and hoi2.org_information_context = '1099R Magnetic Report Rules'
      and hou.organization_id in (
              select organization_id
                from hr_organization_information
               where org_information_context = '1099R Magnetic Report Rules'
                 and org_information2 = p_trans_cont_code)
      order by 2 desc;

-- Cursor to get payroll_action_ids of the pre-process for the given GRE.
-- This will also serve as a check to make sure that all GREs have been
-- archived
Cursor c_payroll_action (cp_tax_unit_id varchar2,
                         cp_year_start  date,
                         cp_year_end    date,
                         cp_business_group_id number) is
   select payroll_action_id
     from pay_payroll_actions
    where report_type = 'YREND'
      and effective_date = cp_year_end
      and start_date = cp_year_start
      and business_group_id + 0 = cp_business_group_id
      and substr(legislative_parameters,
             (instr(legislative_parameters, 'TRANSFER_GRE=') +
                                length('TRANSFER_GRE='))) = cp_tax_unit_id;

--Cursor for checking if any of the the archiver has errored for
--any of the assignments or any assignment is pending (Marked for Retry)
Cursor c_check_asg (cp_payroll_action_id number,
                    cp_status_type varchar2) IS
   select '1'
     from dual
    where exists (
           select '1'
             from pay_assignment_actions paa
            where paa.payroll_action_id = cp_payroll_action_id
              and paa.action_status = decode(cp_status_type,'R','M', --If R is passed we compare for retry
                                                            cp_status_type))
     and not exists (
           select '1'
             from pay_action_parameters
            where parameter_name = 'FORCE_MAG_REPORT'
              and instr(parameter_value, cp_status_type) > 0);

-- Cursor to check Transmitter Contact Information for the 'T' record

Cursor c_chk_cntc_info (cp_trans_control_code varchar2, cp_tax_unit_id number) IS
        select 'Y'
          from hr_organization_information hoi
        where hoi.organization_id = cp_tax_unit_id
          and hoi.org_information_context = '1099R Magnetic Report Rules'
          and hoi.org_information1 = 'Y'
      and hoi.org_information2 = cp_trans_control_code
      and replace(substr(hoi.org_information9,1,40),',') is not null
      and replace(replace(replace(replace(replace(replace(replace(replace
               (upper(substr(hoi.org_information10,1,15)),'-'),'.'),'('),')'),'E'),'X'), 'T'),' ') is not null;

-- Cursor to check Transmitter Vendor Type for the 'T' record

Cursor c_chk_vnd_type (cp_trans_control_code varchar2,
                       cp_tax_unit_id number) IS
     select hoi.org_information11
       from hr_organization_information hoi
      where hoi.organization_id = cp_tax_unit_id
        and hoi.org_information_context = '1099R Magnetic Report Rules'
        and hoi.org_information1 = 'Y'
        and hoi.org_information2 = cp_trans_control_code;


--
-- Cursor to check Transmitter Vendor Information for the 'T' record
--
Cursor c_chk_vnd_info (cp_trans_control_code varchar2,
                             cp_tax_unit_id number) IS
    select 'Y' from hr_organization_information hoi
     where hoi.organization_id = cp_tax_unit_id
       and hoi.org_information_context = '1099R Magnetic Report Rules'
       and hoi.org_information1 = 'Y'
       and hoi.org_information2 = cp_trans_control_code
       and hoi.org_information11 is not null
       and hoi.org_information12 is not null
       and hoi.org_information13 is not null
       and hoi.org_information14 is not null
       and hoi.org_information15 is not null
       and hoi.org_information16 is not null
       and hoi.org_information17 is not null
       and hoi.org_information18 is not null
       and hoi.org_information19 is not null ;


--local variables used for processing
ln_picked_gre number(1) := 0;

ln_curr_gre           number(15);
ln_curr_person        number(15);
ln_prev_person        number(15);
ln_assignment         number(15);
ld_asg_effective_dt   date;
ln_payroll_action_id  number(15);
lc_asgn_retry         varchar2(2) := 'N';
lc_asgn_error         varchar2(2) := 'N';
ln_archived_gre_found number := 0;
ln_balance_exists     number := 0;
ln_no_of_gres_picked  number := 0;
l_trans_cont_code     varchar2(30);
l_gre_tcc             varchar2(30);
ln_balance_value      number := 0;
ln_balance_value_ar   number := 0;

l_fed_gre_check      number(15);
lv_contact_chk   varchar2(2);
lv_gre_archive   varchar2(2);
lv_chk_state_balances varchar2(2) := 'Y';
lv_transmitter_flag varchar2(2);
lv_vendor_chk    varchar2(2);
lv_vendor_type   varchar2(1);
lv_contact_name   varchar2(150);
lv_contact_number   varchar2(150);
lv_message_preprocess varchar2(2000);
lv_message_text VARCHAR2(32000);

begin

   /* First check if the transmitter contact information is there for the 'T' record */
--   hr_utility.trace_on(NULL, 'MAGR');
   hr_utility.trace('Entering the pay_us_1099r_mag_reporting.preprocess_check');

   -- Initialization
   ln_curr_gre := -9999;
   lv_message_preprocess := 'Pre-Process check';

   open c_chk_cntc_info(p_trans_cont_code, p_tax_unit_id);
   fetch c_chk_cntc_info into lv_contact_chk;
   if c_chk_cntc_info%NOTFOUND then
      hr_utility.set_location( 'pay_us_1099r_mag_reporting.preprocess_check', 20);
      hr_utility.set_message(801, 'PAY_72837_TRSMTR_CNT_NOT_FND');
      close c_chk_cntc_info;
      hr_utility.raise_error;
   end if;
   close c_chk_cntc_info;   -- The 'T' record contact information is
   hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',10);


   /* Check if the transmitter vendor Information exists for 'T' record */
   open c_chk_vnd_type(p_trans_cont_code, p_tax_unit_id);
   fetch c_chk_vnd_type into lv_vendor_type;
   if lv_vendor_type = 'Y' THEN
      open c_chk_vnd_info(p_trans_cont_code, p_tax_unit_id);
      fetch c_chk_vnd_info into lv_vendor_chk;
      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',23);
      if c_chk_vnd_info%NOTFOUND then
         hr_utility.set_location( 'pay_us_1099r_mag_reporting.preprocess_check', 24);
         hr_utility.set_message(801, 'PAY_34980_TRSMTR_VND_NOT_FOUND');
         CLOSE c_chk_vnd_info;
         close c_chk_vnd_type;
         hr_utility.raise_error;
      end if;
      close c_chk_vnd_info; -- The 'T' record Vendor information exists.
   end if;
   close c_chk_vnd_type;

   hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',30);

   -- Performance Changes
   -- Check and see if we have any GREs(within the tcc) which have not been processed
   -- Open the cursor which will give us all 1099R GREs for a particular
   -- transmitter control code FED,
   -- We do not distinguish between State and Federal level reports in
   -- Pre-process
   open c_1099_fed_gre(p_trans_cont_code);

   loop -- Main Loop
      hr_utility.trace('The previous GRE was :  '||to_char(ln_curr_gre));
      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',70);
      fetch c_1099_fed_gre into ln_curr_gre, lv_transmitter_flag;
      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',80);
      hr_utility.trace('The GRE being checked is:  '||to_char(ln_curr_gre));
      if c_1099_fed_gre%NOTFOUND THEN
         -- This means that the there are no more rows in the cursor
         -- So lets get out of the loop and continue
         hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',81);
         exit;
      end if; -- if c_1099_fed_gre%NOTFOUND

      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',120);

      -- At this point we have the GREs for both Federal and State,
      -- we do not know if they have been
      -- archived or not yet. All we know is that they exist.
      -- Lets see if the GRE has been archived we will set a flag to
      -- determine if it has been archived or not
      open c_payroll_action (ln_curr_gre, p_year_start, p_year_end, p_business_group_id);
      fetch c_payroll_action into ln_payroll_action_id;
      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',130);
      if c_payroll_action%notfound then
         lv_gre_archive := 'N';  -- it has not been archived
         hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',140);
      else
         lv_gre_archive := 'Y';  -- it has been archived
         ln_no_of_gres_picked := ln_no_of_gres_picked + 1;
         hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',150);
      end if;
      close c_payroll_action;

      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',190);

      -- Now if the gre has been archived lets verify that none of the assignments
      -- have errored and none are marked for retry.
      -- If they have been marked for error or retry then set a flag
      -- lc_asgn_retry or lc_asgn_error.

      IF lv_gre_archive = 'Y' THEN

         open c_check_asg(ln_payroll_action_id, 'R');
         fetch c_check_asg into lc_asgn_retry;
         if c_check_asg%found then
            lc_asgn_retry := 'Y';
            hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',200);
         end if;
         close c_check_asg;

         open c_check_asg(ln_payroll_action_id, 'E');
         fetch c_check_asg into lc_asgn_error;
         if c_check_asg%found then
            lc_asgn_error := 'Y';
            hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',210);
         end if;
         close c_check_asg;

         -- If the flag for retry and or error is set to 'Y' then we must
         -- close the cursor and get out
         if lc_asgn_error = 'Y' then
            hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',220);
            close c_1099_fed_gre;
            hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check', 230);
            hr_utility.set_message(801, 'PAY_72729_ASG_NOT_ARCH');
            hr_utility.raise_error;
         elsif lc_asgn_retry = 'Y' then
            close c_1099_fed_gre;
            hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check', 240);
            hr_utility.set_message(801, 'PAY_72730_ASG_MARKED_FOR_RETRY');
            hr_utility.raise_error;
         end if; -- if lc_asgn_error = 'Y'
      ELSE
         hr_utility.trace(ln_curr_gre || 'GRE not archived');
         lv_message_text := 'Please Archive GRE With ID := ' || to_char(ln_curr_gre) ;
         /*
          * Commenting the code
         pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA_WARNING','P');
         pay_core_utils.push_token('record_name',lv_message_preprocess);
         pay_core_utils.push_token('description',lv_message_text);
          */
      END IF; -- IF lv_gre_archive = 'Y'

      hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',410);
   END LOOP; --Main Loop

   -- This is in the scenario if a customer runs the 1099R mag for a/or
   -- many GREs that are not archived nor should they be archived, but since
   -- their is no one to pick up, we need to error out the report.
   -- The variable ln_no_of_gres_picked will be greater than zero if there is
   -- a payroll action id of the YREND archiver for the specific GRE.
   -- Otherwise it will never be set.

   if ln_no_of_gres_picked = 0 then
      hr_utility.set_location( 'pay_us_mag_1099r_reporting.preprocess_check', 415);
      hr_utility.set_message(801, 'PAY_ARCH_GRE_NOT_FOUND');
      hr_utility.raise_error;
   else
      if p_report_type = '1099R_FED' then
         hr_utility.trace('The number of GREs that have been archived ' ||
                          'for the federal mag are:  '||to_char(ln_no_of_gres_picked));
      else
         hr_utility.trace('The number of GREs that have been archived ' ||
                          'for the state mag are: ' ||to_char(ln_no_of_gres_picked));
      end if;
   end if;

   close c_1099_fed_gre;

   hr_utility.set_location('pay_us_1099r_mag_reporting.preprocess_check',420);
   hr_utility.trace('Exiting the pay_us_1099r_mag_reporting.preprocess_check');
   return(TRUE);

end preprocess_check;

Procedure range_cursor (
         p_payroll_action_id  in number,
         p_sql_string        out nocopy varchar2)
is

lv_sql_string  varchar2(2000);

ld_year_start        date;
ld_year_end          date;
lv_state_code        varchar2(10);
lv_state_abbrev      varchar2(30);
lv_report_type       varchar2(30);
ln_business_group_id number;
ln_tax_unit_id 	     number;
lv_trans_cont_code   varchar2(30);
ln_yrend_ppa_id      number;

lb_pre_process       boolean;

begin
-- hr_utility.trace_on(NULL,'oracle');
hr_utility.trace('Entering pay_us_1099r_mag_reporting.range_cursor');
hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',10);

get_selection_information (
                      p_payroll_action_id,
                      ld_year_start,
                      ld_year_end,
                      lv_state_code,
                      lv_state_abbrev,
                      lv_report_type,
                      ln_business_group_id,
                      ln_tax_unit_id,
                      lv_trans_cont_code,
                      ln_yrend_ppa_id);

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',20);

lb_pre_process := preprocess_check (
                       p_payroll_action_id,
                       ld_year_start,
                       ld_year_end,
                       ln_business_group_id,
                       lv_state_abbrev,
                       lv_state_code,
                       lv_report_type,
		       ln_tax_unit_id,
                       lv_trans_cont_code);

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',30);

if lb_pre_process then

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',40);

   if lv_report_type = '1099R_FED' then

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',50);
hr_utility.trace('The transmitter control code is:  '||lv_trans_cont_code);

      lv_sql_string :=
            'select distinct paf.person_id
               from --hr_soft_coding_keyflex hsck,
                    per_all_assignments_f paf,
                    pay_assignment_actions paa,
                    pay_payroll_actions ppa1,
                    pay_payroll_actions ppa
              where ppa1.payroll_action_id = :p_payroll_action_id
                and ppa.report_type = ''YREND''
                and ppa.business_group_id + 0 = ppa1.business_group_id
                and ppa.effective_date = ppa1.effective_date
                and ppa.start_date = ppa1.start_date
                and ppa.payroll_action_id = paa.payroll_action_id
                and paa.action_status = ''C''
                and paa.assignment_id = paf.assignment_id
                and paf.assignment_type = ''E''
                and paf.effective_start_date <= ppa.effective_date
                and paf.effective_end_date >= ppa.start_date
                and paf.business_group_id + 0 = ppa.business_group_id
                --and paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
                --and hsck.segment1 = paa.tax_unit_id
                --and hsck.segment1 in
                and paa.tax_unit_id in
                        (select hoi.organization_id
                          from hr_organization_information hoi
                         where hoi.org_information_context = ''1099R Magnetic Report Rules'')
            order by paf.person_id';

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor', 60);

   elsif lv_report_type = '1099R_STATE' then

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',70);

       lv_sql_string :=
            'select distinct paf.person_id
               from --hr_soft_coding_keyflex hsck,
						  hr_organization_units hou,
                    per_all_assignments_f paf,
                    pay_us_state_w2_v psv,
                    pay_payroll_actions ppa
              where ppa.payroll_action_id = :p_payroll_action_id
                and hou.business_group_id + 0 = ppa.business_group_id + 0
                and psv.tax_unit_id = hou.organization_id
                and psv.action_status = ''C''
                and psv.year = to_number(to_char(ppa.effective_date, ''YYYY''))
                and ( psv.state_ein <> ''FLI P.P. #'' and
                  decode(psv.state_abbrev, ''NY'', psv.w2_state_income_tax,
                                             ''WV'', psv.w2_state_income_tax,
                                             ''IN'', psv.w2_state_income_tax,
                                             ''CT'', psv.w2_state_income_tax,
                                             ''SC'', psv.w2_state_income_tax,
                                             ''AZ'', psv.w2_state_income_tax,
                                             psv.w2_state_wages) >= 0 ) -- 4350849
                and psv.state_abbrev = ppa.report_qualifier
                and psv.assignment_id = paf.assignment_id
                and paf.assignment_type = ''E''
                and paf.effective_start_date <= ppa.effective_date
                and paf.effective_end_date >= ppa.start_date
                and paf.business_group_id + 0 = ppa.business_group_id
	        --and paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
	        --and hsck.segment1 = psv.tax_unit_id
	        --and hsck.segment1 in
                and psv.tax_unit_id in
          (select hoi.organization_id
             from hr_organization_information hoi
            where hoi.org_information_context = ''1099R Magnetic Report Rules'')
	    order by paf.person_id';

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor', 80);

   end if;

hr_utility.set_location('pay_us_1099r_mag_reporting.range_cursor',90);

   p_sql_string := lv_sql_string;

end if;

hr_utility.trace('Exiting pay_us_1099r_mag_reporting.range_cursor');

end range_cursor;



  -----------------------------------------------------------------------------
  --Name
  --  mag_1099r_action_creation
  --Purpose
  --  Creates assignment actions for the payroll action associated with the
  --  report and only for the assignments on the particular Transmitter
  --
  --Arguments
  --  p_payroll_action_id 	payroll action for the report
  --  p_start_person		starting person id for the chunk
  --  p_end_person		last person id for the chunk
  --  p_chunk			size of the chunk
  --Note
  --  The procedure processes assignments in 'chunks' to facilitate
  --  multi-threaded operation. The chunk is defined by the size and the
  --  starting and ending person id. An interlock is also created against the
  --  pre-processor assignment action to prevent rolling back of the archiver.
  --  Now the year end pre processor is archiving all assignments and all
  --  balances so we must check to see if the Federal Gross is greater than
  --  zero.
  ----------------------------------------------------------------------------
--

Procedure mag_1099r_action_creation
     (p_payroll_action_id in number,
      p_start_person      in number,
      p_end_person        in number,
      p_chunk             in number)

is


-- Cursor to get the assignments for federal 1099R. Includes only 1099R GREs.
-- Removed the exists clause as the YREND archiver does the same logic
-- so it is safe to assume that the assignment action id we pick up should
-- satisfy the exists clause.
-- Now when choosing tax_unit_id we need to roll up to the TCC from the archiver.

cursor c_federal(cp_payroll_action_id number,
                 cp_start_person number,
                 cp_end_person number,
                 cp_yrend_ppa_id number) is
   select paf.person_id,
          paa.tax_unit_id,
          paf.effective_end_date,
          paf.assignment_id,
          --pww.wages_tips_compensation
          pww.gross_1099r
    from pay_payroll_actions ppa,
         pay_payroll_actions ppa1,
         pay_us_wages_1099r_v pww,
         per_all_assignments_f paf,
         pay_assignment_actions paa
   where ppa1.payroll_action_id = cp_payroll_action_id
     and pww.year = to_number(to_char(ppa.effective_date, 'YYYY'))
     and pww.assignment_id = paf.assignment_id
     and pww.tax_unit_id = paa.tax_unit_id
     and ppa.report_type = 'YREND'
     and ppa.business_group_id + 0 = ppa1.business_group_id + 0
     and ppa.effective_date = ppa1.effective_date
     and ppa.start_date = ppa1.start_date
     and paa.payroll_action_id = ppa.payroll_action_id
     and paf.assignment_id = paa.assignment_id
     and paf.person_id BETWEEN cp_start_person and cp_end_person
     and paf.assignment_type = 'E'
     and paf.effective_start_date <= ppa.effective_date
     and paf.effective_end_date >= ppa.start_date
     and to_char(paa.tax_unit_id) in (
           select ffaic2.context
             from ff_contexts ffc,
                  ff_user_entities ffue,
                  ff_archive_items ffai,
                  ff_archive_items ffai2,
                  ff_archive_item_contexts ffaic,
                  ff_archive_item_contexts ffaic2,
                  ff_contexts ffc2
            where ffai.context1 = cp_yrend_ppa_id
              and ffue.user_entity_id = ffai.user_entity_id
              and ffue.user_entity_name = 'A_US_1099R_TRANSMITTER_CODE'
              and ffai.archive_item_id = ffaic.archive_item_id
              and ffaic.context_id = ffc.context_id
              and ffc.context_name = 'TAX_UNIT_ID'
              and ffai2.user_entity_id = ffai.user_entity_id
              and ffai2.value = ffai.value
              and ffai2.context1 in (select payroll_action_id
                                       from pay_payroll_actions
                                      where report_type = 'YREND'
                                        and effective_date = ppa.effective_date)
              and ffai2.archive_item_id = ffaic2.archive_item_id
              and ffaic2.context_id = ffc2.context_id
              and ffc2.context_name = 'TAX_UNIT_ID')
      order by 1, 2, 3 desc, 4;


-- Cursor to get the assignments for state 1099R. Gets only those employees
-- which have wages for the specified state.This cursor only includes the
-- 1099R GREs.
-- Removed the exists clause as the YREND archiver does the same logic
-- so it is safe to assume that the assignment action id we pick up should
-- satisfy the exists clause.
-- Now when choosing tax_unit_id we need to roll up to the TCC in the archiver.

cursor c_state(cp_payroll_action_id number,
               cp_start_person number,
               cp_end_person number,
               cp_yrend_ppa_id number) is
   select paf.person_id,
          psv.tax_unit_id, --to_number(hsck.segment1),
          paf.effective_end_date,
          paf.assignment_id,
          psv.w2_state_wages,
          psv.w2_state_income_tax
     from per_all_assignments_f paf,
          pay_us_state_w2_v psv,
          pay_payroll_actions ppa
    where ppa.payroll_action_id = cp_payroll_action_id
      and psv.year = to_number(to_char(ppa.effective_date, 'YYYY'))
      and psv.state_abbrev = ppa.report_qualifier
      and psv.assignment_id = paf.assignment_id
      and psv.state_ein <> 'FLI P.P. #'  /* 9205571 */
      and paf.assignment_type = 'E'
      and paf.person_id between cp_start_person and cp_end_person
      and paf.effective_start_date <= ppa.effective_date
      and paf.effective_end_date >= ppa.start_date
      and paf.business_group_id + 0 = ppa.business_group_id + 0
      and to_char(psv.tax_unit_id) in
           (select ffaic2.context
             from ff_contexts ffc,
                  ff_user_entities ffue,
                  ff_archive_items ffai,
                  ff_archive_items ffai2,
                  ff_archive_item_contexts ffaic,
                  ff_archive_item_contexts ffaic2,
                  ff_contexts ffc2
            where ffai.context1 = cp_yrend_ppa_id
              and ffue.user_entity_id = ffai.user_entity_id
              and ffue.user_entity_name = 'A_US_1099R_TRANSMITTER_CODE'
              and ffai.archive_item_id = ffaic.archive_item_id
              and ffaic.context_id = ffc.context_id
              and ffc.context_name = 'TAX_UNIT_ID'
              and ffai2.user_entity_id = ffai.user_entity_id
              and ffai2.value = ffai.value
              and ffai2.context1 in (select payroll_action_id
                                       from pay_payroll_actions
                                      where report_type = 'YREND'
                                        and effective_date = ppa.effective_date)
              and ffai2.archive_item_id = ffaic2.archive_item_id
              and ffaic2.context_id = ffc2.context_id
              and ffc2.context_name = 'TAX_UNIT_ID')
      order by 1, 2, 3 desc, 4;


--local variables
ld_effective_end_date date;

ln_person_id          number;
ln_prev_person_id     number;

ln_assignment_id      number;
ln_tax_unit_id        number;
ln_prev_tax_unit_id   number;
ln_lockingactid	      number;
ln_lockedactid        number;
ln_balance_value      number;

ld_year_start date;
ld_year_end date;
lv_state_code varchar2(10);
lv_state_abbrev varchar2(30);
lv_report_type varchar2(30);
ln_business_group_id number;
lv_trans_cont_code   varchar2(30);
ln_yrend_ppa_id      number;

ln_box_17            number;
ln_box_18            number;
ln_box1	             number;
ln_create_assignment number;

begin

hr_utility.trace('Entering pay_us_1099r_mag_reporting.mag_1099r_action_creation');

 -- Get the report parameters. These define the report being run.
 hr_utility.set_location(
          'pay_us_1099r_mag_reporting.mag_1099r_action_creation',10);

 get_selection_information (
                       p_payroll_action_id,
                       ld_year_start,
                       ld_year_end,
                       lv_state_code,
                       lv_state_abbrev,
                       lv_report_type,
                       ln_business_group_id,
                       ln_tax_unit_id,
                       lv_trans_cont_code,
                       ln_yrend_ppa_id);



 --Open the appropriate cursor

 hr_utility.set_location(
        'pay_us_1099r_mag_reporting.mag_1099r_action_creation',20);

 if lv_report_type = '1099R_FED' then
    open c_federal(p_payroll_action_id,
                   p_start_person,
                   p_end_person,
                   ln_yrend_ppa_id);
 elsif lv_report_type = '1099R_STATE' then
    open c_state(p_payroll_action_id,
                   p_start_person,
                   p_end_person,
                   ln_yrend_ppa_id);
 end if;

 loop
    if lv_report_type = '1099R_FED' then
       fetch c_federal into ln_person_id,
                            ln_tax_unit_id,
                            ld_effective_end_date,
                            ln_assignment_id,
							ln_box1;

       hr_utility.set_location(
               'pay_us_1099r_mag_reporting.mag_1099r_action_creation', 30);

       if c_federal%notfound then
          exit;
       end if;

    elsif lv_report_type = '1099R_STATE' then
       fetch c_state into ln_person_id,
                          ln_tax_unit_id,
                          ld_effective_end_date,
                          ln_assignment_id,
                          ln_box_17,
                          ln_box_18;

       hr_utility.set_location(
           'pay_us_1099r_mag_reporting.mag_1099r_action_creation', 40);

       if c_state%notfound then
          exit;
       end if;

    end if;

    --Based on the groupin criteria, check if the record is the same
    --as the previous record. If the records are not same then we
    --create the assignment actions and do the interlocking else
    --we do nothing.
    --Grouping by GRE requires a unique person/GRE combination for
    --each record.Only one of the condition will always be satisfied
    --if group by gre is TRUE then first condition will hold true
    --otherwise the second.
    if (ln_person_id = nvl(ln_prev_person_id, -1) and
              ln_tax_unit_id <> nvl(ln_prev_tax_unit_id, -1))
        or
        (ln_person_id <> nvl(ln_prev_person_id, -1)) then

        --Create the assignment action for the record
        hr_utility.trace('Assignment Fetched  - ');
        hr_utility.trace('Assignment Id : '|| to_char(ln_assignment_id));
        hr_utility.trace('Person Id :  '|| to_char(ln_person_id));
        hr_utility.trace('tax unit id : '|| to_char(ln_tax_unit_id));
        hr_utility.trace('Effective End Date :  '|| to_char(ld_effective_end_date));

        if lv_report_type = '1099R_FED' then
			if ln_box1 > 0 then
            	ln_create_assignment := 1;
			else
				ln_create_assignment := 0;
			end if;

        elsif lv_report_type = '1099R_STATE' then

     /* Bug 3209884  Changed boundry conditions for employees to be reported on tape
        (creating assignemnt_action_id) for 1099R_STATE for folowing States
        'AR' if SIT > 0 or State_wages > 2500 changed to
        'AR' if SIT > 0 or State_wages > 0
        'KS' was SIT > 0 must be paper so we have 'KS' if SIT = 0 changed to
        'KS' if SIT > 0 or State_wages > 0
        'MT' if SIT > 0 must be Paper so we check SIT = 0 only then report on tape
      */
     /* Bug 3349571 Reverted change for KS as if there is KS SIT,
                    the 1099-R cannot be included on the magnetic tape */

           if lv_state_abbrev in ('AR','CT','IN','WV','NY','AZ','SC','KS','MT') then
              if lv_state_abbrev = 'AR' then
                 if ln_box_18 > 0 or ln_box_17 > 0 then
                    ln_create_assignment := 1;
                 else
                    ln_create_assignment := 0;
                 end if;
              elsif lv_state_abbrev = 'KS' OR lv_state_abbrev = 'MT' then
                 if ln_box_18 = 0 then
                    ln_create_assignment  := 1;
                 else
                    ln_create_assignment := 0;
                 end if;
              else
                 if ln_box_18 > 0 then
                    ln_create_assignment := 1;
                 else
                    ln_create_assignment := 0;
                 end if;
              end if;
           else
              if ln_box_17 >= 0 then  -- 4350849
                 ln_create_assignment := 1;
              else
                 ln_create_assignment := 0;
              end if;
           end if;
        end if;

        if ln_create_assignment = 1 then

           select pay_assignment_actions_s.nextval
             into ln_lockingactid from dual;

           hr_utility.set_location(
             'pay_us_1099r_mag_reporting.mag_1099r_action_creation', 60);

           hr_nonrun_asact.insact(ln_lockingactid, ln_assignment_id, p_payroll_action_id,
                               p_chunk, ln_tax_unit_id);

           hr_utility.set_location(
             'pay_us_1099r_mag_reporting.mag_1099r_action_creation', 70);

           --Create Interlock
           select assignment_action_id into ln_lockedactid
             from pay_assignment_actions paa,
                  per_all_assignments_f paf,
                  pay_payroll_actions ppa
            where paa.payroll_action_id = ppa.payroll_action_id
              and paa.assignment_id = paf.assignment_id
              and paa.tax_unit_id = ln_tax_unit_id
              and ppa.report_type = 'YREND'
              and substr(legislative_parameters,
                      instr(legislative_parameters, 'TRANSFER_GRE=') +
                              length('TRANSFER_GRE=')) = to_char(ln_tax_unit_id)
              and ppa.effective_date = ld_year_end
              and ppa.start_date = ld_year_start
              and paf.effective_end_date = ld_effective_end_date
              and paf.assignment_id = ln_assignment_id
	      and paf.effective_start_date <= ppa.effective_date; -- 4583577 Perf Change 2.

            --insert into pay_action_interlocks
            hr_nonrun_asact.insint(ln_lockingactid, ln_lockedactid);

            hr_utility.set_location(
                 'pay_us_1099r_mag_reporting.mag_1099r_action_creation', 90);
            hr_utility.trace('Interlock Created  - ');
            hr_utility.trace('Locking Action : '|| to_char(ln_lockingactid));
            hr_utility.trace('Locked Action :  '|| to_char(ln_lockedactid));

            --Store the current person/GRE for comparision during the
            --next iteration.
            ln_prev_person_id := ln_person_id;
            ln_prev_tax_unit_id := ln_tax_unit_id;

       end if;
    end if;

    ln_create_assignment := 0;

    end loop;

    if lv_report_type = '1099R_FED' then
        close c_federal;
    elsif lv_report_type = '1099R_STATE' then
        close c_state;
    end if;

hr_utility.trace('Exiting pay_us_1099r_mag_reporting.mag_1099r_action_creation');

end mag_1099r_action_creation;


end pay_us_1099r_mag_reporting;

/
