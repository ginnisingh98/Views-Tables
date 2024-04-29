--------------------------------------------------------
--  DDL for Package Body PAY_PQH_RBC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PQH_RBC" 
/* $Header: pypqhrbc.pkb 120.0.12010000.1 2008/07/27 23:26:32 appldev ship $ */
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

    Name        : pay_pqh_rbc

    Description : delivery of eventy qulaifier for pqh rate by
		  criteria , for retro notif

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    06-Nov-2006 Tbattoo  110.0           Created.
    03-Jan-2008 AYegappa 115.6           Corrected determine_rbc_rate call
  *******************************************************************/
AS



FUNCTION RBC_event_qualifier  return  varchar2

is

cursor get_pact_de is
 select ppa.date_earned
 from pay_payroll_actions ppa,
      pay_element_entries_f pee,
      pay_assignment_actions paa
 where paa.assignment_id=pay_interpreter_pkg.g_asg_id
 and   paa.payroll_action_id=ppa.payroll_action_id
 and   ppa.action_type in ('R','Q')
 and   ppa.date_earned >=pay_interpreter_pkg.g_effective_date
 and   ppa.date_earned between pee.effective_start_date and pee.effective_end_date
 and   pee.element_entry_id=pay_interpreter_pkg.g_ee_id
 order by ppa.date_earned desc;

cursor get_bg is
 select distinct business_group_id
 from pay_element_entries_f pee,
     per_all_assignments_f paf
 where pee.element_entry_id=pay_interpreter_pkg.g_ee_id
 and   pee.assignment_id=paf.assignment_id
 and   pay_interpreter_pkg.g_effective_date between
            pee.effective_start_date and pee.effective_end_date
 and   pay_interpreter_pkg.g_effective_date between
            paf.effective_start_date and paf.effective_end_date;

cursor  rate_effected is
select 'Y'
from dual
where exists (
  select 'Y'
  from pay_element_entries_f pee
  ,pqh_criteria_rate_elements pcre
  ,pqh_rate_matrix_rates_f prmr
  where pee.element_entry_id=pay_interpreter_pkg.g_ee_id
  and pcre.element_type_id=pee.element_type_id
  and pcre.criteria_rate_defn_id=prmr.criteria_rate_defn_id
  and prmr.rate_matrix_rate_id=pay_interpreter_pkg.g_object_key
  and pee.effective_end_date >= prmr.effective_start_date
  and pee.effective_start_date <= prmr.effective_end_date)
or exists (
  Select 'Y'
  from pay_element_entries_f pee,
  pqh_criteria_rate_elements pcre,
  pqh_criteria_rate_factors pcrf,
  pqh_rate_matrix_rates_f prmr
  where pee.element_entry_id=pay_interpreter_pkg.g_ee_id
  and pcre.element_type_id=pee.element_type_id
  and pcre.criteria_rate_defn_id = pcrf.criteria_rate_defn_id
  and pcrf.parent_criteria_rate_defn_id = prmr.criteria_rate_defn_id
  and prmr.rate_matrix_rate_id = pay_interpreter_pkg.g_object_key
  and pee.effective_end_date >= prmr.effective_start_date
  and pee.effective_start_date <= prmr.effective_end_date);

l_exists varchar2(1);
l_rate_factors pqh_rbc_rate_retrieval.g_rbc_factor_tbl;
l_rate_factor_cnt number;
l_min_rate number;
l_max_rate number;
l_rate number;
l_mid_rate number;
l_bus_grp number;
l_date_earned date;

begin


open rate_effected;
fetch rate_effected into l_exists;

if rate_effected%notfound then
 close rate_effected;
 return 'N';
else
 --if does exist then call rbc api
 close rate_effected;
 open get_bg;
 fetch get_bg into l_bus_grp;

 if get_bg%notfound then
   close get_bg;
   return 'N';
 else
   close get_bg;

   open get_pact_de;
   loop
    fetch get_pact_de into l_date_earned;

    if get_pact_de%notfound then
     close get_pact_de;
     return 'N';
    end if;

    /* Added parameter names for bug 6695937 */
    pqh_rbc_rate_retrieval.determine_rbc_rate(
		p_element_entry_id    =>  pay_interpreter_pkg.g_ee_id,
                p_business_group_id   =>  l_bus_grp,
		p_effective_date      =>  l_date_earned,
 		p_rate_factors        =>  l_rate_factors,
		p_rate_factor_cnt     =>  l_rate_factor_cnt,
		p_min_rate            =>  l_min_rate,
		p_mid_rate            =>  l_mid_rate,
		p_max_rate            =>  l_max_rate,
		p_rate                =>  l_rate);

    for i in 1..l_rate_factor_cnt loop
      if (l_rate_factors(i).rate_matrix_rate_id=pay_interpreter_pkg.g_object_key)
      then
       close get_pact_de;
       return 'Y';
      end if;
    end loop;
  end loop;
  close get_pact_de;
  return 'N';
 end if;
end if;

end;

end pay_pqh_rbc;

/
