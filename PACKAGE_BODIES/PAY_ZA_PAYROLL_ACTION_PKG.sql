--------------------------------------------------------
--  DDL for Package Body PAY_ZA_PAYROLL_ACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_PAYROLL_ACTION_PKG" as
/* $Header: pyzapay.pkb 120.2.12010000.2 2009/11/18 09:46:35 rbabla ship $ */

procedure total_payment (p_assignment_action_id in number,
                                 p_total_payment out nocopy number) is

cursor csr_payment is select sum(result_value)
                        from pay_element_types_v1
                           where classification_name in ('Normal Income','Allowances',
                                                                        'Direct Payments','Lump Sum Amounts')
                         and p_assignment_action_id = assignment_action_id;
begin
  open csr_payment;
  fetch csr_payment into p_total_payment;
  close csr_payment;
--
exception
   when others then
   p_total_payment := null;
--
end total_payment;

------------------------------------------------------------------------------
procedure total_deduct (p_assignment_action_id in number,
                                p_total_deduct out nocopy number) is
cursor csr_deduct  is select sum(result_value)
                        from pay_element_types_v1
                           where classification_name in ('Statutory Deductions', 'Deductions',
                                                                     'Involuntary Deductions','Voluntary Deductions')
                         and p_assignment_action_id = assignment_action_id;
begin
  open csr_deduct;
  fetch csr_deduct into p_total_deduct;
  close csr_deduct;
--
exception
   when others then
   p_total_deduct := null;
--
end total_deduct;
-------------------------------------------------------------------------
function defined_balance_id (p_balance_type     in varchar2,
                             p_dimension_suffix in varchar2) return number is
--
  l_legislation_code  varchar2(30) := 'ZA';
--
  l_found       BOOLEAN := FALSE;

  l_balance_name        VARCHAR2(80);
  l_balance_suffix      VARCHAR2(30);

  CURSOR c_defined_balance IS
        SELECT
                defined_balance_id
        FROM
                pay_defined_balances PDB,
                pay_balance_dimensions PBD,
                pay_balance_types PBT
        WHERE   PBT.balance_name = p_balance_type
        AND     nvl(PBT.legislation_code, l_legislation_code) = l_legislation_code -- Bug 4377803; added nvl function
        AND     PDB.balance_type_id = PBT.balance_type_id
        AND     PBD.balance_dimension_id = PDB.balance_dimension_id
        AND     nvl(PDB.legislation_code, l_legislation_code) = l_legislation_code -- Bug 4377803; added nvl function
        AND     PBD.database_item_suffix = p_dimension_suffix;



--
  l_result number;
--
begin

        open c_defined_balance;
        fetch c_defined_balance into l_result;
        close c_defined_balance;

  return l_result;
end;
--
-- bug no 4276047
FUNCTION get_balance_reporting_name (p_balance_type in varchar2
                 ) return varchar2 is
  l_legislation_code  varchar2(30) := 'ZA';
  l_reporting_name    pay_balance_types_tl.REPORTING_NAME%type;
  Cursor get_bal_rpt_name is
      SELECT
       substr( nvl(pbtl.REPORTING_NAME, nvl(pbt.REPORTING_NAME,pbt.balance_name)),1,50)
      FROM
                pay_balance_types PBT,
                pay_balance_types_tl PBTl
      WHERE     PBT.balance_name = p_balance_type
        AND     nvl(PBT.legislation_code, l_legislation_code) = l_legislation_code -- Bug 4377803; added nvl function
        and     pbt.BALANCE_TYPE_ID = pbtl.BALANCE_TYPE_ID (+)
        and     pbtl.LANGUAGE(+) = userenv('LANG');
begin
  OPEN get_bal_rpt_name;
  FETCH get_bal_rpt_name INTO l_reporting_name;
  IF get_bal_rpt_name%ISOPEN then
     CLOSE get_bal_rpt_name;
  END if;
return l_reporting_name;
exception
   when others then
   RETURN p_balance_type;
END;
-- bug no 4276047

-- bug 4751740: start
-- Call to GB Package from PAYZASOE is not a good coding practice
-- Thus, duplicate of PAY_GB_PAYROLL_ACTIONS_PKG.FORMULA_INPUTS_WF and
-- PAY_GB_PAYROLL_ACTIONS_PKG.FORMULA_INPUTS_HC should be created in this
-- ZA package.

-------------------------------------------------------------------------------
-- This procedure is dupllicate of PAY_GB_PAYROLL_ACTIONS_PKG.FORMULA_INPUTS_WF
-- It(PAY_GB_PAYROLL_ACTIONS_PKG) was at 37th version when it's copied
--
procedure formula_inputs_wf (p_session_date             in     date,
			     p_payroll_exists           in out nocopy varchar2,
			     p_assignment_action_id     in out nocopy number,
			     p_run_assignment_action_id in out nocopy number,
			     p_assignment_id            in     number,
			     p_payroll_action_id        in out nocopy number,
			     p_date_earned              in out nocopy varchar2) is
-- select the latest prepayments action for this individual and get the
-- details of the last run that that action locked
cursor csr_formula is
select /*+ ORDERED USE_NL(paa,ppa,rpaa,rppa) */
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
and    paa.assignment_id = rpaa.assignment_id
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
         and loc.locking_action_id = paa.assignment_action_id);

-- Copied from HR_GBBAL.get_latest_action_id, include action type P and U
cursor csr_formula_2 is
SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = p_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  (paa.source_action_id is not null
          or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date <= p_session_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B', 'U', 'P');

cursor csr_formula_3(p_assig_act_id  NUMBER) is
select to_char(nvl(ppa.date_earned,ppa.effective_date),'YYYY/MM/DD'),
       paa.payroll_action_id
from   pay_payroll_actions ppa,
       pay_assignment_actions paa
where  paa.assignment_action_id = p_assig_act_id
and    ppa.payroll_action_id = paa.payroll_action_id;

cursor csr_formula_4(p_assig_act_id NUMBER) is
select pact.action_type
from   pay_assignment_actions assact,
       pay_payroll_actions pact
where  assact.assignment_action_id = p_assignment_action_id
and    pact.payroll_action_id = assact.payroll_action_id;

cursor csr_formula_5(p_assig_act_id NUMBER) is
select assact.assignment_action_id
from   pay_assignment_actions assact,
       pay_action_interlocks loc
where  loc.locking_action_id = p_assignment_action_id
and    assact.assignment_action_id = loc.locked_action_id
order  by assact.action_sequence desc;

--
l_assignment_action_id NUMBER;
l_action_type   varchar2(1);
--
begin
  --
  l_assignment_action_id := null;
  --
   -- open csr_formula;
  -- fetch csr_formula into p_date_earned,
  --                     p_payroll_action_id,
  --                     p_run_assignment_action_id,
  --                     p_assignment_action_id;
  open csr_formula_2;
  fetch csr_formula_2 into p_assignment_action_id;
  close csr_formula_2;

  if p_assignment_action_id is NOT NULL then
     p_payroll_exists := 'TRUE';

     open csr_formula_4(p_assignment_action_id);
     fetch csr_formula_4 into l_action_type;
     close csr_formula_4;

     if l_action_type in ('P','U') then
        open csr_formula_5(p_assignment_action_id);
        fetch csr_formula_5 into p_run_assignment_action_id;
        close csr_formula_5;
        -- Bug 4584572
     else
        p_run_assignment_action_id := p_assignment_action_id;
     end if;

     open csr_formula_3(p_run_assignment_action_id);
     fetch csr_formula_3 into p_date_earned,
                              p_payroll_action_id;
     close csr_formula_3;

  end if;
  -- if csr_formula_2%FOUND then
  --   p_payroll_exists := 'TRUE';
  -- end if;
  -- close csr_formula;
  --
end formula_inputs_wf;

--
-------------------------------------------------------------------------------
-- This procedure is dupllicate of PAY_GB_PAYROLL_ACTIONS_PKG.FORMULA_INPUTS_HC
-- It(PAY_GB_PAYROLL_ACTIONS_PKG) was at 37th version when it's copied
--
procedure formula_inputs_hc (p_assignment_action_id in out nocopy number,
                             p_run_assignment_action_id in out nocopy number,
			     p_assignment_id        in out nocopy number,
			     p_payroll_action_id    in out nocopy number,
			     p_date_earned          in out nocopy varchar2) is
-- if the action is a run then return the run details
-- if the action is a prepayment return the latest run details locked
cursor csr_formula is
-- find what type of action this is
               select pact.action_type , assact.assignment_id
                             from pay_assignment_actions assact,
                             pay_payroll_actions pact
		    where   assact.assignment_action_id = p_assignment_action_id
                    and     pact.payroll_action_id = assact.payroll_action_id
;
cursor csr_formula_2 is
-- for prepayment action find the latest interlocked run
               select assact.assignment_action_id
                             from pay_assignment_actions assact,
                                  pay_action_interlocks loc
                      where loc.locking_action_id = p_assignment_action_id
                      and   assact.assignment_action_id = loc.locked_action_id
                      order by assact.action_sequence desc
;
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
                      order by assact.action_sequence desc
;
cursor csr_formula_4 is
-- now find the date earned and payroll action of the run action
               select pact.payroll_action_id,
               to_char(nvl(pact.date_earned,pact.effective_date),'YYYY/MM/DD')
                             from pay_assignment_actions assact,
                             pay_payroll_actions pact
                where   assact.assignment_action_id = p_run_assignment_action_id
                   and     pact.payroll_action_id = assact.payroll_action_id
;
--
l_action_type varchar2(1);
--
begin
--
  open csr_formula;
  fetch csr_formula into l_action_type, p_assignment_id;
  close csr_formula;
--
  if l_action_type in ('P', 'U') then
     open csr_formula_2;
     fetch csr_formula_2 into p_run_assignment_action_id;
     close csr_formula_2;
  else
     p_run_assignment_action_id := p_assignment_action_id;
  end if;
-- fetch payroll details
  open csr_formula_4;
  fetch csr_formula_4 into p_payroll_action_id,
                           p_date_earned;
  close csr_formula_4;
--
end formula_inputs_hc;
--

-- bug 4751740: End

procedure get_home_add(p_person_id IN NUMBER,
                       p_add1 IN out nocopy VARCHAR2,
                       p_add2 IN out nocopy VARCHAR2,
                       p_add3 IN out nocopy VARCHAR2,
                       p_reg1 IN out nocopy VARCHAR2,
                       p_reg2 IN out nocopy VARCHAR2,
                       p_reg3 IN out nocopy VARCHAR2,
                       p_twnc IN out nocopy VARCHAR2) is
--
cursor homeadd is
select pad.address_line1,
       pad.address_line2,
       pad.address_line3,
       l.meaning,
       pad.postal_code,
       pad.region_3,
       pad.town_or_city,
       nvl(pad.region_2,'N') --Postal not same as residential address
from   per_addresses pad,
       hr_lookups l
where  pad.person_id = p_person_id
and    pad.primary_flag = 'Y'
and    l.lookup_type(+) = 'ZA_PROVINCE'
and    l.lookup_code(+) = pad.region_1
and    sysdate between nvl(pad.date_from, sysdate)
                   and nvl(pad.date_to,   sysdate);

cursor residential_address is
select  address_line1  ee_unit_num
      , address_line2  ee_complex
      , address_line3  ee_street_num
      , region_1       ee_street_name
      , region_2       ee_suburb_district
      , postal_code    ee_postal_code
      , town_or_city   ee_town_city
   from per_addresses pad
  where person_id = p_person_id
    and sysdate between nvl(pad.date_from, sysdate) and nvl(pad.date_to,   sysdate)
    and style        = 'ZA_SARS'
    and address_type = 'ZA_RES';

--
l_indicator varchar2(1):=null; --Postal same as residential
begin
--
open homeadd;
fetch homeadd into p_add1,
                   p_add2,
                   p_add3,
                   p_reg1,
                   p_reg2,
                   p_reg3,
                   p_twnc,
                   l_indicator;
--
close homeadd;

if l_indicator = 'Y' then --Postal address same as residential address
open residential_address;
fetch residential_address into p_add1,
                   p_add2,
                   p_add3,
                   p_reg1,
                   p_reg2,
                   p_reg3,
                   p_twnc;
close residential_address;
end if;

end get_home_add;



END PAY_ZA_PAYROLL_ACTION_PKG;

/
