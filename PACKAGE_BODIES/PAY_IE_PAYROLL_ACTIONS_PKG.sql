--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAYROLL_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAYROLL_ACTIONS_PKG" AS
/* $Header: pyiesoe.pkb 120.2 2006/09/29 12:39:11 rbhardwa noship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  SOE  package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  06 NOV 2001 kavenkat  N/A        Created
**  05 DEC 2001 gpadmasa  N/A        Added dbdrv Commands
**  10 JAN 2002 gpadmasa  N/A        Modified the Fetch_Action-Id Procedures
**                                   to handle Iterative Engine Run Results.
**  12 DEC 2002 viviswan  2665701    Performance changes/nocopy changes.
**  13 OCT 2004 mseshadr  3922415    Modified and added new cursors so that
**			             SOE retrieves latest run,prepayments
**                                   quickpay and quickpay prepayments
**  21 OCT 2004 mseshadr  3922415-   Modified cur_assignment_action_id
**  21 FEB 2006 sgajula   4771780    replaced cur_old with cur_lat_action
**                                   and cur_pact_details
**  29 SEP 2006 rbhardwa  5574503    Modified fetch_action_id to return the
**                                   p_assignment_action_id for prepayments.
**
-------------------------------------------------------------------------------
*/
procedure fetch_action_id (p_session_date             in     date,
           p_payroll_exists           in out nocopy varchar2,
           p_assignment_action_id     in out nocopy number,
           p_run_assignment_action_id in out nocopy number,
           p_paye_prsi_action_id         out nocopy number,
           p_assignment_id            in     number,
           p_payroll_action_id        in out nocopy number,
           p_date_earned              in out nocopy varchar2) IS
-- select the latest prepayments action for this individual and get the
-- details of the last run that that action locked
/*cursor csr_formula is
select
        to_char(nvl(rppa.date_earned,rppa.effective_date),'YYYY/MM/DD'),
        rpaa.payroll_action_id,
        rpaa.assignment_action_id,
        paa.assignment_action_id
from    pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_assignment_actions rpaa,
        pay_payroll_actions rppa
where  paa.payroll_action_id = ppa.payroll_action_id
and    rppa.payroll_action_id = rpaa.payroll_action_id
and    paa.assignment_action_id =
        (select
          to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
          from   pay_payroll_actions pa,
                  pay_assignment_actions aa
          where  pa.action_type in ('U','P')
          and    aa.action_status = 'C'
          and   pa.payroll_action_id = aa.payroll_action_id
          and aa.assignment_id = p_assignment_id
          and pa.effective_date <= p_session_date)
and    ppa.action_type in ('P', 'U')
and    rpaa.assignment_id = p_assignment_id
and    rpaa.action_sequence =
        (select max(aa.action_sequence)
         from   pay_assignment_actions aa,
                pay_action_interlocks loc
         where loc.locked_action_id = aa.assignment_action_id
          and aa.source_action_id is null
         and loc.locking_action_id = paa.assignment_action_id); */

--csrformula has been replaced by cur_old for bug 3922415
-- replaced cur_old with cur_lat_action and cur_pact_details 4771780
/*  cursor cur_old( curvar2   number)is
         select
         to_char(nvl(rppa.date_earned,rppa.effective_date),'YYYY/MM/DD'),
         rpaa.payroll_action_id,
         rpaa.assignment_action_id,
         paa.assignment_action_id
         from    pay_assignment_actions paa,
                 pay_payroll_actions ppa,
                 pay_assignment_actions rpaa,
                 pay_payroll_actions rppa
        where    paa.payroll_action_id = ppa.payroll_action_id
        and      rppa.payroll_action_id = rpaa.payroll_action_id
        and      paa.assignment_action_id = curvar2
        and      ppa.action_type in ('P', 'U')
        and      rpaa.assignment_id = p_assignment_id
        and    rpaa.action_sequence =
                                    (select max(aa.action_sequence)
                                     from   pay_assignment_actions aa,
                                            pay_action_interlocks loc
                                     where loc.locked_action_id = aa.assignment_action_id
                                     and aa.source_action_id is null
                                      and loc.locking_action_id = paa.assignment_action_id);
*/
cursor cur_lat_action( curvar2   number)is
select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
				          paa.assignment_action_id),16))
from   pay_assignment_actions paa,
       pay_action_interlocks loc
where  loc.locked_action_id = paa.assignment_action_id
  and  paa.source_action_id IS NULL
  and  loc.locking_action_id = curvar2;

cursor cur_pact_details(curvar3   number) IS
select to_char(nvl(rppa.date_earned,rppa.effective_date),'YYYY/MM/DD'),
         rpaa.payroll_action_id
  from  pay_assignment_actions rpaa,
        pay_payroll_actions rppa
 where  rpaa.payroll_action_id = rppa.payroll_action_id
   and  rpaa.assignment_action_id = curvar3;


 ---This cursor is used to get the assignment action ids corresponding to the assignment Bug 3922415
 ---The session date is used to retrieve the last date of the pay period (for the corresponding payroll id)

 ---3922415 - This cursor is modified so that SOE does not display payroll run results when the session date is
 ---before the date on which the payroll was run.It will display run results corresponding to prev.Payroll Run
 ---in this case
        cursor  cur_assignment_action_id is
          select to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
          from   pay_payroll_actions pa,
                 pay_assignment_actions aa
/*3922415-       per_time_periods ptp */
          where  pa.action_type in ('Q','R','P','U')
          and    aa.action_status = 'C'
/*3922415-and    ptp.payroll_id = pa.payroll_id*/
          and    pa.payroll_action_id = aa.payroll_action_id
          and    aa.assignment_id = p_assignment_id
/*3922415-and    pa.effective_date <=ptp.regular_payment_date*/
/*3922415-and    p_session_date between ptp.start_date and  ptp.end_date;*/
          and    pa.effective_date <=  p_session_date;


    ---This is used to retrive the actio_type corresponding to the assignment action id found by prev cursor

         cursor cur_action_type(curvar3 number) is
         select distinct action_type
	     from   pay_payroll_actions,pay_assignment_actions
   	     where  pay_payroll_actions.payroll_action_id = pay_assignment_actions.payroll_action_id
         and    assignment_action_id =curvar3;




cursor csr_get_stand_run is
      select pac.assignment_action_id
       from  pay_assignment_actions pac,
             pay_run_types_f prt
       where pac.run_type_id = prt.run_type_id
         -- Added to be driven by index bug 2665701
         and pac.assignment_id = p_assignment_id
         and pac.source_action_id = p_run_assignment_action_id
         and prt.run_method='N';


--
l_payroll_exists            VARCHAR2(30);
l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
l_run_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
l_payroll_action_id         pay_payroll_actions.payroll_action_id%TYPE;
l_date_earned               VARCHAR2(30);
l_end_date                  date;
l_action_type               varchar2(2);
--
begin
  --
l_payroll_exists            := p_payroll_exists;
l_assignment_action_id      := p_assignment_action_id;
l_run_assignment_action_id  := p_run_assignment_action_id;
l_payroll_action_id         := p_payroll_action_id;
l_date_earned               := p_date_earned;

  --
 /*before 3922415  open csr_formula;
  fetch csr_formula into p_date_earned,
       p_payroll_action_id,
       p_run_assignment_action_id,
       p_assignment_action_id;

   if csr_formula%FOUND then
     p_payroll_exists := 'TRUE';
     open csr_get_stand_run;
     fetch csr_get_stand_run into p_paye_prsi_action_id;
     close csr_get_stand_run;
  end if;
  close csr_formula;*/

   open cur_assignment_action_id;
   fetch cur_assignment_action_id into l_assignment_action_id;
   close cur_assignment_action_id;

   open cur_action_type(l_assignment_action_id);
   fetch cur_action_type into l_action_type;
   close cur_action_type;

   IF    l_action_type in ('P','U')
      THEN
      -- removed cur_old and split the same into two cursors which avoids non-mergeable view
      /*
           open cur_old(l_assignment_action_id);
           fetch cur_old into p_date_earned,
                                 p_payroll_action_id,
                                 p_run_assignment_action_id,
                                 p_assignment_action_id;

			      IF cur_old%FOUND
      */


          p_assignment_action_id := l_assignment_action_id;    /* 5574503 */
          open cur_lat_action(l_assignment_action_id);
	  fetch cur_lat_action into p_run_assignment_action_id;

		 IF cur_lat_action%FOUND
				     THEN
                         open cur_pact_details(p_run_assignment_action_id);
		         fetch cur_pact_details into p_date_earned,p_payroll_action_id;
		         close cur_pact_details;


                          p_payroll_exists := 'TRUE';

                          open csr_get_stand_run;
                          fetch csr_get_stand_run into p_paye_prsi_action_id;
                          close csr_get_stand_run;
                  END IF;
            close cur_lat_action;
	   ELSE

			   IF  l_action_type in ('Q','R')

			     THEN
                       p_assignment_action_id:=l_assignment_action_id;
			   p_payroll_exists := 'TRUE';
                       p_run_assignment_action_id := p_assignment_action_id;
                       p_assignment_action_id := p_run_assignment_action_id;
                       p_paye_prsi_action_id := p_run_assignment_action_id;
               end if;
        end if;




EXCEPTION
      WHEN OTHERS THEN
        -- in out
        l_payroll_exists            := p_payroll_exists;
        l_assignment_action_id      := p_assignment_action_id;
        l_run_assignment_action_id  := p_run_assignment_action_id;
        l_payroll_action_id         := p_payroll_action_id;
        l_date_earned               := p_date_earned;
        -- out
        p_paye_prsi_action_id       := null;


end fetch_action_id;

procedure fetch_action_id (  p_assignment_action_id     in out nocopy number,
                             p_run_assignment_action_id in out nocopy number,
                             p_paye_prsi_action_id         out nocopy number,
                             p_assignment_id            in out nocopy number) IS
-- if the action is a run then return the run details
-- if the action is a prepayment return the latest run details locked
cursor csr_formula is
-- find what type of action this is
      select pact.action_type , assact.assignment_id
      from pay_assignment_actions assact,
     pay_payroll_actions pact
      where assact.assignment_action_id = p_assignment_action_id
      and pact.payroll_action_id = assact.payroll_action_id;
cursor csr_formula_2 is
-- for prepayment action find the latest interlocked run
     select assact.assignment_action_id
     from pay_assignment_actions assact,
          pay_action_interlocks loc
     where loc.locking_action_id = p_assignment_action_id
           and   assact.assignment_action_id = loc.locked_action_id
           and   assact.source_action_id is null
     --order by loc.locked_action_id desc ;
   order by assact.action_sequence desc ;
cursor csr_formula_3 is
-- for run action check if its been prepaid
      select assact.assignment_action_id
      from pay_assignment_actions assact,
     pay_payroll_actions pact,
     pay_action_interlocks loc
      where loc.locked_action_id = p_assignment_action_id
            and   assact.assignment_action_id = loc.locking_action_id
            and   pact.payroll_action_id = assact.payroll_action_id
            and   pact.action_type in ('P','U') /* prepayments only */
      order by assact.action_sequence desc  ;
cursor csr_get_stand_run is
      select pac.assignment_action_id
       from  pay_assignment_actions pac,
             pay_run_types_f prt
       where pac.run_type_id = prt.run_type_id
       -- Added to be driven by index bug 2665701
         and pac.assignment_id = p_assignment_id
         and pac.source_action_id = p_run_assignment_action_id
         and prt.run_method='N';
  --
  l_action_type varchar2(1);
  --
  l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
  l_run_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  l_assignment_id             per_all_assignments_f.assignment_id%TYPE;
  --
  begin
  --
  l_assignment_action_id      := p_assignment_action_id;
  l_run_assignment_action_id  := p_run_assignment_action_id;
  l_assignment_id             := p_assignment_id;
  --
    open csr_formula;
    fetch csr_formula into l_action_type, p_assignment_id;
    close csr_formula;
  --
    if l_action_type in ('P', 'U') then
       open csr_formula_2;
       fetch csr_formula_2 into p_run_assignment_action_id;
               open csr_get_stand_run;
               fetch csr_get_stand_run into p_paye_prsi_action_id;
               close csr_get_stand_run;
       close csr_formula_2;
       -- if its a run action it may or may not have been prepaid
    else
      p_run_assignment_action_id := p_assignment_action_id;
      begin
    open csr_formula_3;
    fetch csr_formula_3 into p_assignment_action_id;
    IF csr_formula_3%NOTFOUND then
      p_assignment_action_id := p_run_assignment_action_id;
    END IF;
    close csr_formula_3;
    p_paye_prsi_action_id := p_run_assignment_action_id;
      end;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        -- in out
        p_assignment_action_id      := l_assignment_action_id;
        p_run_assignment_action_id  := l_run_assignment_action_id;
        p_assignment_id             := l_assignment_id;
        -- out
        p_paye_prsi_action_id       := null;

END fetch_action_id;

function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type is

    v_currency_code  fnd_currencies.currency_code%type;

/*  cursor currency_code
      (c_business_group_id  hr_organization_units.business_group_id%type) is
    select fcu.currency_code
    from   hr_organization_information hoi,
           hr_organization_units hou,
           fnd_currencies fcu
    where  hou.business_group_id       = c_business_group_id
    and    hou.organization_id         = hoi.organization_id
    and    hoi.org_information_context = 'Business Group Information'
    and    fcu.issuing_territory_code  = hoi.org_information9;
*/

--   cursor currency_code modified for Performance Fix 2665701
    cursor currency_code
      (c_business_group_id  hr_organization_units.business_group_id%type) is
    select /*+ USE_NL(fcu hoi) */
           fcu.currency_code
    from   hr_organization_information hoi,
           fnd_currencies fcu
    where  hoi.organization_id         = c_business_group_id
    and    hoi.org_information_context = 'Business Group Information'
    and    fcu.issuing_territory_code  = hoi.org_information9;


begin
  open currency_code (p_business_group_id);
  fetch currency_code into v_currency_code;
  close currency_code;

  return v_currency_code;
end business_currency_code;

END PAY_IE_PAYROLL_ACTIONS_PKG ;


/
