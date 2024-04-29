--------------------------------------------------------
--  DDL for Package Body PAY_P45_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_P45_PKG2" AS
/* $Header: payp45p.pkb 120.2 2006/11/08 00:34:26 rmakhija noship $ */

/*
   NAME
     payp45p.pkb -- procedure  P45 Report
  --
   DESCRIPTION
     this procedure is used by PAYRPP45 report to retrieve the database
     items and the balance items.
  --
  MODIFIED       (DD-MON-YYYY)
  btailor	  11-JUL-1995 - Created.
  ctucker         01-SEP-1995 - Return code for Tax basis instead of desc
				on procedure get_database_items
  smrobinson      11-APR-2001 - Added legislation code specifier to
                                balance_type_id select in defined_balance_id
                                function.
  smrobins        27-FEB-2002 - Added get_uk_term_dates. Called by HREMEA
                                to default the last standard process and
                                final process dates.
  smrobins        01-MAR-2002 - Change to get_uk_term_dates to only return
                                a value for final close, which has been
                                pushed out nocopy for end date of period
                                regular payment date resides in. Change for
                                Positive Offsets.
  rmakhija 115.4  01-MAY-2002 - Changed context and database items for tax
                                details
  rmakhija 115.5  05-JUL-2002 - Changed get_database_items procedure to
                                get statutory details from run result
                                values before fetching them from DBIs
  rmakhija 115.6  08-JUL-2002 - Changed DBI names for Previous Pay and Tax
  gbutler  115.7  27-JAN-2003 - nocopy and gscc fixes
  amills   115.8  21-JUL-2003 - Agg PAYE changes.
  amills   115.9  02-MAR-2004 - 3473274. changed get_database_items and
                                get_balance_items to handle NDFs.
  amills   115.10 02-MAR-2004 - Added nocopy hints.
  npershad 115.11 14-OCT-2005 - 4428406. Removed reference to redundant index
                                PAY_ASSIGNMENT_ACTIONS_N1 used in hints.
  rmakhija 115.12 07-NOV-2006 - 5144323, replaced PER_TD_YTD dimension with
                                PER_TD_CPE_YTD
*/

/* Constants */

  -- DataBase Items
  -- these are the database items used for the values displayed
  --
  G_TAX_REFNO_ITEM    varchar2(30) := 'SCL_PAY_GB_TAX_REFERENCE';
  G_TAX_CODE_ITEM     varchar2(40) := 'PAYE_DETAILS_TAX_CODE_GB_ENTRY_VALUE';
  G_TAX_BASIS_ITEM    varchar2(40) := 'PAYE_DETAILS_TAX_BASIS_GB_ENTRY_VALUE';
  G_TAX_PERIOD_ITEM   varchar2(40) := 'PAY_STATUTORY_PERIOD_NUMBER';
  G_PREV_PAY_DETAILS  varchar2(40) := 'PAYE_DETAILS_PAY_PREVIOUS_GB_ENTRY_VALUE';
  G_PREV_TAX_DETAILS  varchar2(40) := 'PAYE_DETAILS_TAX_PREVIOUS_GB_ENTRY_VALUE';
  --
  -- Balance Items
  --
  -- the following are the database items used to retrieve the balances
  -- for P45 report. Use PERson level for Aggregated PAYE details.
  --
  G_TAXABLE_PAY_BALANCE        varchar2(30) := 'PAYE_ASG_TD_YTD';
  G_GROSS_PAY_BALANCE          varchar2(30) := 'TAXABLE_PAY_ASG_TD_YTD';
  G_AGG_TAXABLE_PAY_BALANCE    varchar2(30) := 'PAYE_PER_TD_CPE_YTD';
  G_AGG_GROSS_PAY_BALANCE      varchar2(30) := 'TAXABLE_PAY_PER_TD_CPE_YTD';
  --
  -- Balance Types
  --
  -- the following are the types associated with the above balances
  --
  g_gross_pay_type      varchar2(30) := 'TAXABLE PAY';
  g_taxable_pay_type    varchar2(30) := 'PAYE';
  --
  -- Dimension suffixes
  --
  -- the following are the different balance dimension suffixes used by
  -- the balance items
  --
  g_year_to_date         varchar2(30) := '_ASG_YTD';
  g_tax_district_ytd     varchar2(30) := '_ASG_TD_YTD';
  g_agg_tax_district_ytd varchar2(30) := '_PER_TD_CPE_YTD';
--
-------------------------------------------------------------------------
--
-- sets the context for which a database item is to be retrieved and returns
-- whether context has been set correctly
--
function set_database_context (p_database_item in varchar2,
                               p_payroll_action_id in number   default null,
                               p_date_earned       in varchar2 default null,
                               p_assignment_id     in number   default null)
return boolean is
--
begin
--
  if p_database_item = G_TAX_PERIOD_ITEM then
  --
    if p_payroll_action_id is not null then
    --
      pay_balance_pkg.set_context ('payroll_action_id',
                                   to_char(p_payroll_action_id));
      --
      hr_utility.trace('Set context for G_TAX_PERIOD_ITEM.');
      return true;
    --
    else
    --
      return false;
    --
    end if;
  --
  elsif p_database_item = G_TAX_REFNO_ITEM then
    if p_date_earned is not null and
       p_assignment_id is not null then
    --
      pay_balance_pkg.set_context ('date_earned',
                                   p_date_earned);
      --
      pay_balance_pkg.set_context ('assignment_id',
                                   to_char(p_assignment_id));
      --
      hr_utility.trace('Set context for G_TAX_REFNO_ITEM.');
      return true;
    --
    else
    --
       return false;
    end if;
  elsif p_database_item = G_TAX_CODE_ITEM then
  --
    if p_payroll_action_id is not null and
       p_assignment_id is not null then
    --
      hr_utility.trace('Set context for G_TAX_CODE_ITEM, payroll_action_id='||to_char(p_payroll_action_id));
      pay_balance_pkg.set_context ('payroll_action_id',
                                   to_char(p_payroll_action_id));
      --
      hr_utility.trace('Set context for G_TAX_CODE_ITEM, assignment_id='||to_char(p_assignment_id));
      pay_balance_pkg.set_context ('assignment_id',
                                   to_char(p_assignment_id));
      --
      hr_utility.trace('Set context for G_TAX_CODE_ITEM.');
      return true;
    --
    else
    --
      return false;
    --
    end if;
  --
  end if;
--
end;
--
-------------------------------------------------------------------------
procedure get_ele_entry_details(p_assignment_id in number,
                                p_effective_date in date,
                                p_tax_refno      out nocopy varchar2,
                                p_tax_code       out nocopy varchar2,
                                p_tax_basis      out nocopy varchar2,
                                p_pay_previous   out nocopy varchar2,
                                p_tax_previous   out nocopy varchar2) is
--
l_paye_id number;
--
cursor csr_paye_id(c_effective_date in date)  is
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  element_name = 'PAYE Details'
  AND  c_effective_date BETWEEN effective_start_date
                                AND effective_end_date;
--
CURSOR csr_tax_ref (c_assignment_id in number,
                    c_effective_date in date) is
  select scl.segment1
   from per_all_assignments_f paf,
        pay_all_payrolls_f ppf,
        hr_soft_coding_keyflex scl
   where paf.assignment_id = c_assignment_id
   and paf.payroll_id = ppf.payroll_id
   and scl.soft_coding_keyflex_id = ppf.soft_coding_keyflex_id
   and c_effective_date between
      paf.effective_start_date and paf.effective_end_date
   and c_effective_date between
      ppf.effective_start_date and ppf.effective_end_date;
--
cursor csr_paye_details(c_assignment_id  NUMBER,
                        c_effective_date DATE,
                        c_paye_id in number) IS
  SELECT  max(decode(iv.name,'Tax Code',screen_entry_value)) tax_code,
          max(decode(iv.name,'Tax Basis',screen_entry_value)) tax_basis,
          max(decode(iv.name,'Pay Previous',screen_entry_value))
                                                                pay_previous,
          max(decode(iv.name,'Tax Previous',screen_entry_value))
                                                                tax_previous
  FROM  pay_element_entries_f e,
        pay_element_entry_values_f v,
        pay_input_values_f iv,
        pay_element_links_f link
  WHERE e.assignment_id = c_assignment_id
  AND   link.element_type_id = c_paye_id
  AND   e.element_link_id = link.element_link_id
  AND   e.element_entry_id = v.element_entry_id
  AND   iv.input_value_id = v.input_value_id
  AND   c_effective_date
          BETWEEN link.effective_start_date AND link.effective_end_date
  AND   c_effective_date
          BETWEEN e.effective_start_date AND e.effective_end_date
  AND   c_effective_date
          BETWEEN iv.effective_start_date AND iv.effective_end_date
  AND   c_effective_date
          BETWEEN v.effective_start_date AND v.effective_end_date;
--
BEGIN
   hr_utility.set_location('get_ele_entry_details',10);
   --
   OPEN csr_paye_id(p_effective_date);
   FETCH csr_paye_id into l_paye_id;
   CLOSE csr_paye_id;
   --
   open csr_tax_ref(p_assignment_id,p_effective_date);
   fetch csr_tax_ref into p_tax_refno;
   close csr_tax_ref;
   --
   OPEN csr_paye_details(p_assignment_id,p_effective_date,l_paye_id);
   FETCH csr_paye_details INTO p_tax_code,
                               p_tax_basis,
                               p_pay_previous,
                               p_tax_previous;
   CLOSE csr_paye_details;
   --
   hr_utility.set_location('get_ele_entry_details',20);
   --
EXCEPTION WHEN NO_DATA_FOUND THEN
   p_tax_code := null;
   p_tax_basis := null;
   p_tax_refno := null;
   p_pay_previous := null;
   p_tax_previous := null;
--
END get_ele_entry_details;
----------------------------------------------------------------------------
-- returns the value associated with a given database item assuming that the
-- correct context has already been set
--
function database_item (p_database_item in varchar2) return varchar2 is
--
  -- constants for calls to database items
  --
  l_business_group_id number       := null;
  l_legislation_code  varchar2(30) := 'GB';
--
begin
--
  return pay_balance_pkg.run_db_item
                     (p_database_name    => p_database_item,
                      p_bus_group_id     => l_business_group_id,
                      p_legislation_code => l_legislation_code);
--
end;
--
-------------------------------------------------------------------------
--
-- retrieves the values to be displayed by calling database items
--
procedure get_database_items (p_assignment_id     in     number,
                              p_date_earned       in     varchar2,
                              p_payroll_action_id in     number,
                              p_tax_period        in out nocopy varchar2,
                              p_tax_refno         in out nocopy varchar2,
                              p_tax_code          in out nocopy varchar2,
                              p_tax_basis         in out nocopy varchar2,
                              p_prev_pay_details  in out nocopy varchar2,
			      p_prev_tax_details  in out nocopy varchar2) is
--
   l_tax_basis varchar2(30);
   l_paye_element_id      number;
   l_tax_code_ipv_id      number;
   l_tax_basis_ipv_id     number;
   l_pay_previous_ipv_id  number;
   l_tax_previous_ipv_id  number;
   l_max_run_result_id    number;
--
   CURSOR csr_paye_element IS
   SELECT element_type_id
   FROM pay_element_types_f
   WHERE element_name = 'PAYE';
--
   CURSOR csr_input_value(p_ipv_name IN VARCHAR2) IS
   SELECT input_value_id
   FROM   pay_input_values_f
   WHERE  element_type_id = l_paye_element_id
   AND    name = p_ipv_name;
--
   CURSOR csr_result_value(p_ipv_id IN NUMBER) IS
   SELECT result_value
   FROM   pay_run_result_values
   WHERE  run_result_id = l_max_run_result_id
   AND    input_value_id = p_ipv_id;
 --
   CURSOR csr_max_run_result IS
        SELECT /*+ ORDERED INDEX (assact2 PAY_ASSIGNMENT_ACTIONS_N51,
                           pact PAY_PAYROLL_ACTIONS_PK,
                           r2 PAY_RUN_RESULTS_N50)
            USE_NL(assact2, pact, r2) */
            to_number(substr(max(lpad(assact2.action_sequence,15,'0')||r2.source_type||
                               r2.run_result_id),17))
            FROM    pay_assignment_actions assact2,
                    pay_payroll_actions pact,
                    pay_run_results r2
            WHERE   assact2.assignment_id = p_assignment_id
            AND     r2.element_type_id+0 = l_paye_element_id
            AND     r2.assignment_action_id = assact2.assignment_action_id
            AND     r2.status IN ('P', 'PA')
            AND     pact.payroll_action_id = assact2.payroll_action_id
            AND     pact.action_type IN ( 'Q','R','B','I')
            AND     assact2.action_status = 'C'
            AND     pact.effective_date <= to_date(p_date_earned,'YYYY/MM/DD')
            AND NOT EXISTS(
               SELECT '1'
               FROM  pay_action_interlocks pai,
                     pay_assignment_actions assact3,
                     pay_payroll_actions pact3
               WHERE   pai.locked_action_id = assact2.assignment_action_id
               AND     pai.locking_action_id = assact3.assignment_action_id
               AND     pact3.payroll_action_id = assact3.payroll_action_id
               AND     pact3.action_type = 'V'
               AND     assact3.action_status = 'C');
begin
--
 hr_utility.set_location('pay_p45_pkg2.get_database_items',10);
 --
 -- Bug 3473274. Check that the payroll action is not null or -9999, which
 -- may have been set if there are no payroll actions found for the
 -- assignment (new starter). If so, use el entries.
 IF p_payroll_action_id is null OR
    p_payroll_action_id = -9999 THEN
    --
     hr_utility.trace('Payroll Action invalid, obtain El Entries');
     get_ele_entry_details(p_assignment_id  => p_assignment_id,
                           p_effective_date => to_date(p_date_earned,'YYYY/MM/DD'),
                           p_tax_refno      => p_tax_refno,
                           p_tax_code       => p_tax_code,
                           p_tax_basis      => p_tax_basis,
                           p_pay_previous   => p_prev_pay_details,
                           p_tax_previous   => p_prev_tax_details);

    --
    hr_utility.trace('Tax Ref: '||p_tax_refno);
 ELSE
  hr_utility.set_location('pay_p45_pkg2.get_database_items',20);
  -- There is a valid Payroll Action, continue selecting information.
  -- Set context for Tax Period database item and retrieve it
  --
  if set_database_context (p_database_item     => G_TAX_PERIOD_ITEM,
                           p_payroll_action_id => p_payroll_action_id) then
  --
    hr_utility.trace('Getting G_TAX_PERIOD_ITEM.');
    p_tax_period      := database_item (G_TAX_PERIOD_ITEM);
  --
  --
  --
  -- set context for the Tax Refno database item and retrieve it
  if set_database_context (p_database_item     => G_TAX_REFNO_ITEM,
                           p_date_earned       => p_date_earned,
                           p_assignment_id     => p_assignment_id) then
  --
    hr_utility.trace('Getting G_TAX_REFNO_ITEM.');
    p_tax_refno        := database_item (G_TAX_REFNO_ITEM);
    --
    -- Look for tax details in run results first and if not found then
    -- call dbis
    -- Get element id for PAYE element
    OPEN csr_paye_element;
    FETCH csr_paye_element INTO l_paye_element_id;
    CLOSE csr_paye_element;
    --
    -- Get input_value_id for Tax Code input value
    OPEN csr_input_value('Tax Code');
    FETCH csr_input_value INTO l_tax_code_ipv_id;
    CLOSE csr_input_value;
    --
    -- Get input_value_id for Tax Basis input value
    OPEN csr_input_value('Tax Basis');
    FETCH csr_input_value INTO l_tax_basis_ipv_id;
    CLOSE csr_input_value;
    --
    -- Get input_value_id for Pay Previous input value
    OPEN csr_input_value('Pay Previous');
    FETCH csr_input_value INTO l_pay_previous_ipv_id;
    CLOSE csr_input_value;
    --
    -- Get input_value_id for Tax Previous input value
    OPEN csr_input_value('Tax Previous');
    FETCH csr_input_value INTO l_tax_previous_ipv_id;
    CLOSE csr_input_value;

    -- Get tax code from run results of PAYE element
    BEGIN
       -- Get max run_result_id for PAYE element
       OPEN csr_max_run_result;
       FETCH csr_max_run_result INTO l_max_run_result_id;
       -- if max run result found then get values from run result values
       IF csr_max_run_result%FOUND THEN
          OPEN csr_result_value(l_tax_code_ipv_id);
          FETCH csr_result_value INTO p_tax_code;
          CLOSE csr_result_value;
          --
          OPEN csr_result_value(l_tax_basis_ipv_id);
          FETCH csr_result_value INTO p_tax_basis;
          CLOSE csr_result_value;
          --
          OPEN csr_result_value(l_pay_previous_ipv_id);
          FETCH csr_result_value INTO p_prev_pay_details;
          CLOSE csr_result_value;
          --
          OPEN csr_result_value(l_tax_previous_ipv_id);
          FETCH csr_result_value INTO p_prev_tax_details;
          CLOSE csr_result_value;
          --
       ELSE
          -- set context for tax code database item , which is also
          -- used for the remaining items, and retrieve the remaining items
          --
          if set_database_context (p_database_item     => G_TAX_CODE_ITEM,
                           p_payroll_action_id => p_payroll_action_id,
                           p_assignment_id     => p_assignment_id) then
             --
             hr_utility.trace('Getting G_TAX_CODE_ITEM.');
             p_tax_code         := database_item (G_TAX_CODE_ITEM);
             --
             p_tax_basis        := database_item (G_TAX_BASIS_ITEM);
             --
             -- Tax Basis is translated into its meaning
             --
             -- ctucker: NO!
             --p_tax_basis        := hr_general.decode_lookup ('GB_TAX_BASIS', l_tax_basis);
             --
             p_prev_pay_details := database_item (G_PREV_PAY_DETAILS);
             --
             p_prev_tax_details := database_item (G_PREV_TAX_DETAILS);
             --
          end if;
       END IF;
    END;
  end if;
  end if;
 END IF; -- payroll action not found.
--
EXCEPTION WHEN NO_DATA_FOUND THEN
--
  p_tax_period        := null;
  p_tax_refno         := null;
  p_tax_code          := null;
  p_tax_basis         := null;
  p_prev_pay_details  := null;
  p_prev_tax_details  := null;
--
END get_database_items;
--
------------------------------------------------------------------------------
--
-- returns the defined balance ID associated with a given balance database
-- item - the balance is defined in terms of its type and the balance
-- dimension
--
function defined_balance_id (p_balance_type     in varchar2,
                             p_dimension_suffix in varchar2) return number is
--
  cursor c_defined_balance is
    select defined_balance_id
    from pay_defined_balances
    --
    where balance_type_id = (select balance_type_id
                             from pay_balance_types
                             where upper(balance_name) = p_balance_type
                             and legislation_code = 'GB')
      --
      and balance_dimension_id = (select balance_dimension_id
                                  from pay_balance_dimensions
                                  where upper(database_item_suffix) =
                                                          p_dimension_suffix);
--
  l_result number;
--
begin
--
  open c_defined_balance;
  fetch c_defined_balance into l_result;
  close c_defined_balance;
  --
  return l_result;
end;
--
------------------------------------------------------------------------------
--
-- returns the value associated with a given balance database item
-- this is derived by translating the balance name into its balance type
-- and dimension
-- using the type and dimesnion to derive the defined balance ID
-- using the defined balance ID to obtain the current value for the balance
-- for the given assignment action ID
--
function balance_item_value (p_balance_name         in varchar2,
                             p_assignment_action_id in number) return number is
--
  l_balance_type         varchar2(30);
  l_dimension_suffix     varchar2(30);
  l_defined_balance_id   number;
--
begin
--
  if p_balance_name = G_GROSS_PAY_BALANCE then
  --
    l_balance_type     := g_gross_pay_type;
    l_dimension_suffix := g_tax_district_ytd ;
  --
  elsif p_balance_name = G_TAXABLE_PAY_BALANCE then
  --
    l_balance_type     := g_taxable_pay_type;
    l_dimension_suffix := g_tax_district_ytd;
  --
  elsif p_balance_name = G_AGG_GROSS_PAY_BALANCE then
  --
    l_balance_type     := g_gross_pay_type;
    l_dimension_suffix := g_agg_tax_district_ytd ;
  --
  elsif p_balance_name = G_AGG_TAXABLE_PAY_BALANCE then
  --
    l_balance_type     := g_taxable_pay_type;
    l_dimension_suffix := g_agg_tax_district_ytd;
  --
  end if;
  --
  -- derive defined balance ID
  --
  l_defined_balance_id := defined_balance_id
                               (p_balance_type     => l_balance_type,
                                p_dimension_suffix => l_dimension_suffix);
  --
  return pay_balance_pkg.get_value
                            (p_defined_balance_id   => l_defined_balance_id,
                             p_assignment_action_id => p_assignment_action_id);
--
end;
--
-------------------------------------------------------------------------------
-- Retrieves the balance items.
--
PROCEDURE get_balance_items (p_assignment_action_id in     number,
                             p_gross_pay            in out nocopy number,
                             p_taxable_pay          in out nocopy number,
                             p_agg_paye_flag        in     varchar2 default null) IS
--
  l_ni_a_employee_value    number;
  l_ni_b_employee_value    number;
  l_ni_d_employee_value    number;
  l_ni_e_employee_value    number;
--
BEGIN
--
  hr_utility.set_location('pay_p45_pkg2.get_balance_items',10);
  -- if the assignment action id is not specified then do nothing.
  -- this may have been set to -9999 to denote no action found.
  --
  if p_assignment_action_id is null or
     p_assignment_action_id = -9999 then
  --
    hr_utility.trace('Assignment Action invalid, return');
    return;
  --
  end if;
  --
  if p_agg_paye_flag = 'Y' then
      -- Use the Person Level Balance names
      p_gross_pay   := balance_item_value
                      (p_balance_name         => G_AGG_GROSS_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
      --
      p_taxable_pay := balance_item_value
                      (p_balance_name         => G_AGG_TAXABLE_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
  else
      -- Use the assignment level balance names
      p_gross_pay   := balance_item_value
                      (p_balance_name         => G_GROSS_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
      --
      p_taxable_pay := balance_item_value
                      (p_balance_name         => G_TAXABLE_PAY_BALANCE,
                       p_assignment_action_id => p_assignment_action_id);
  end if;
  --
--
END;
--
-- Default Last Standard Process Date and Final Process Date
-- to Regular Payment Date for Current Period on Termination
-- Form. Called from HREMEA library. (Positive Offset Enhancement)
--
 PROCEDURE get_uk_term_dates(p_person_id                 in   number,
                            p_period_of_service_id      in   number,
                            p_act_term_date             in   date,
                            p_reg_pay_end_date          out nocopy  date) IS
--
-- Deliberately getting the end date of the period that the
-- regular payment date resides in as opposed to the
-- end date of the period for regular payment dates
-- to push Fianl Process date out further.
-- Called by HREMEA library.
--
    cursor  get_reg_pay_date_period is
    select  ptp2.end_date regular_payment_end_date
    from    per_time_periods ptp1,
            per_time_periods ptp2
    where   p_act_term_date between ptp1.start_date and ptp1.end_date
    and     ptp1.payroll_id IN (select pa.payroll_id
                               from   per_assignments pa
                               where  pa.period_of_Service_id = p_period_of_service_id
                               and    pa.person_id = p_person_id)
    and     ptp1.regular_payment_date between ptp2.start_date and ptp2.end_date
    and     ptp2.payroll_id IN (select pa2.payroll_id
                                from   per_assignments pa2
                                where  pa2.period_of_service_id = p_period_of_Service_id
                                and    pa2.person_id = p_person_id);
--
    l_pay_dates get_reg_pay_date_period%ROWTYPE;
 BEGIN
    open get_reg_pay_date_period;
    fetch get_reg_pay_date_period into l_pay_dates;
    close get_reg_pay_date_period;
    p_reg_pay_end_date := l_pay_dates.regular_payment_end_date;
 END;
END PAY_P45_PKG2;

/
