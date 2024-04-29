--------------------------------------------------------
--  DDL for Package Body PAY_ZA_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_PAYSLIP_ARCHIVE" as
/* $Header: pyzaparc.pkb 120.10.12010000.8 2009/12/28 10:35:53 rbabla ship $ */

type balance_rec is record
(
   balance_type_id      number,
   balance_dimension_id number,
   defined_balance_id   number,
   balance_narrative    varchar2(50),
   balance_name         varchar2(80),
   database_item_suffix varchar2(80),
   legislation_code     varchar2(20)
);

type element_rec is record
(
   element_type_id      number,
   input_value_id       number,
   formula_id           number,
   element_narrative    varchar2(50),
   once_each_period_flag varchar2(1)
);

type balance_table  is table of balance_rec   index by binary_integer;
type element_table  is table of element_rec   index by binary_integer;

g_user_balance_table                    balance_table;
g_element_table                         element_table;
g_statutory_balance_table               balance_table;

g_max_element_index                     number := 0;
g_max_user_balance_index                number := 0;
g_balance_archive_index                 number := 0;
g_element_archive_index                 number := 0;
g_max_statutory_balance_index           number := 0;

g_tax_element_id                        number;
g_tax_status                            varchar2(60) := null;
g_tax_status_meaning                    varchar2(80) := null;

g_balance_context              constant varchar2(30) := 'ZA_PAYSLIP_BALANCES';
g_element_context              constant varchar2(30) := 'ZA_PAYSLIP_ELEMENTS';

g_archive_pact                          number;
g_archive_effective_date                date;

g_package                      constant varchar2(30) := 'pay_za_payslip_archive.';

-- This procedure retrieves legislative parameters from the payroll action
procedure get_parameters
(
   p_payroll_action_id in  number,
   p_token_name        in  varchar2,
   p_token_value       out nocopy varchar2
)  is

cursor csr_parameter_info
(
   p_pact_id number,
   p_token   char
)  is
select substr
       (
          legislative_parameters,
          instr
          (
             legislative_parameters,
             p_token
          )  + (length(p_token) + 1),
          instr
          (
             legislative_parameters,
             ' ',
             instr
             (
                legislative_parameters,
                p_token
             )
          )
          -
          (
             instr
             (
                legislative_parameters,
                p_token
             )  + length(p_token)
          )
       ),
       business_group_id
from   pay_payroll_actions
where  payroll_action_id = p_pact_id;

l_business_group_id            varchar2(20);
l_token_value                  varchar2(50);

l_proc                         varchar2(50);

begin
l_proc  := g_package || 'get_parameters';
-- Removed default assignment to remove GSCC warning

   hr_utility.set_location('Entering ' || l_proc, 10);

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('p_token_name = ' || p_token_name, 20);

   open  csr_parameter_info
         (
            p_payroll_action_id,
            p_token_name
         );
   fetch csr_parameter_info into l_token_value, l_business_group_id;
   close csr_parameter_info;

   if p_token_name = 'BG_ID' then

      p_token_value := l_business_group_id;

   else

      p_token_value := l_token_value;

   end if;

   hr_utility.set_location('l_token_value = ' || p_token_value, 20);
   hr_utility.set_location('Leaving         ' || l_proc, 30);

exception
   when others then
   p_token_value := null;

end get_parameters;

procedure get_eit_definitions
(
   p_pactid            in number,     -- Payroll Action of the Archiver
   p_business_group_id in number,
   p_payroll_pact      in number,     -- Payroll Action of the Prepayments
   p_effective_date    in date,       -- Effective Date of the Prepayments
   p_eit_context       in varchar2,   -- ZA_PAYSLIP_BALANCES, ZA_PAYSLIP_ELEMENTS
   p_archive           in varchar2    -- Y, N
)  is

-- Return all the Org Developer Flex values for the specified context
cursor csr_eit_values
(
   p_bg_id   number,
   p_context char
)  is
   select org.org_information1,
          org.org_information2,
          org.org_information3,
          org.org_information4,
          org.org_information5,
          org.org_information6
   from   hr_organization_information org
   where  org.org_information_context = p_context
   and    org.organization_id = p_bg_id;

-- Returns the details of a specific balance
cursor csr_balance_name
(
   p_balance_type_id      number,
   p_balance_dimension_id number
)  is
   select pbt.balance_name,
          pbd.database_item_suffix,
          pbt.legislation_code,
          pdb.defined_balance_id
   from   pay_balance_types      pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances   pdb
   where  pbt.balance_type_id = p_balance_type_id
   and    pbd.balance_dimension_id = p_balance_dimension_id
   and    pdb.balance_type_id = pbt.balance_type_id
   and    pdb.balance_dimension_id = pbd.balance_dimension_id;

cursor csr_element_type
(
   p_element_type_id number,
   p_effective_date  date
)  is
   select pet.formula_id
   from   pay_element_types_f pet,
          ff_formulas_f       fff
   where  pet.element_type_id = p_element_type_id
   and    pet.formula_id = fff.formula_id
   and    fff.formula_name = 'ONCE_EACH_PERIOD'
   and    p_effective_date between fff.effective_start_date and fff.effective_end_date
   and    p_effective_date between pet.effective_start_date and pet.effective_end_date;

--added for Bug 4488264
cursor csr_element_type1
   (p_element_type_id number,
    p_effective_date  date
    )  is
    select once_each_period_flag
    from   pay_element_types_f pet
    where  pet.element_type_id = p_element_type_id
    and    p_effective_date between pet.effective_start_date and pet.effective_end_date;

cursor csr_input_value_uom
(
   p_input_value_id number,
   p_effective_date date
)  is
   select piv.uom
   from   pay_input_values_f piv
   where  piv.input_value_id = p_input_value_id
   and    p_effective_date between piv.effective_start_date and piv.effective_end_date;

l_index                        number       := 1;
l_action_info_id               number(15);
l_formula_id                   number(15);
l_ovn                          number(15);
l_uom                          varchar(30);
l_once_each_period_flag        varchar2(1);

l_proc                         varchar2(50);

begin
l_proc  := g_package || 'get_eit_definitions';
-- Removed default assignment to remove GSCC warning

   hr_utility.set_location('Entering        ' || l_proc, 10);

   hr_utility.set_location('Step            ' || l_proc, 20);
   hr_utility.set_location('p_eit_context = ' || p_eit_context, 20);

   -- Loop through all the Org Developer Flex values for the specified context
   for csr_eit_rec in csr_eit_values
                      (
                         p_business_group_id,
                         p_eit_context
                      )
   loop

      hr_utility.set_location('Step ' || l_proc, 30);

      hr_utility.set_location('org_information1 = ' || csr_eit_rec.org_information1, 30);
      hr_utility.set_location('org_information2 = ' || csr_eit_rec.org_information2, 30);
      hr_utility.set_location('org_information3 = ' || csr_eit_rec.org_information3, 30);
      hr_utility.set_location('org_information4 = ' || csr_eit_rec.org_information4, 30);
      hr_utility.set_location('org_information5 = ' || csr_eit_rec.org_information5, 30);
      hr_utility.set_location('org_information6 = ' || csr_eit_rec.org_information6, 30);

      -- Business Group Level Balances
      if p_eit_context = g_balance_context then

         -- Populate Balance PL/SQL table
         g_user_balance_table(l_index).balance_type_id      := csr_eit_rec.org_information1;
         g_user_balance_table(l_index).balance_dimension_id := csr_eit_rec.org_information2;
         g_user_balance_table(l_index).balance_narrative    := csr_eit_rec.org_information3;

         -- Retrieve the balance details into PL/SQL table
         open  csr_balance_name
               (
                  g_user_balance_table(l_index).balance_type_id,
                  g_user_balance_table(l_index).balance_dimension_id
               );
         fetch csr_balance_name
         into  g_user_balance_table(l_index).balance_name,
               g_user_balance_table(l_index).database_item_suffix,
               g_user_balance_table(l_index).legislation_code,
               g_user_balance_table(l_index).defined_balance_id;

         close csr_balance_name;

         hr_utility.set_location('g_user_balance_table(l_index).balance_name = ' ||
                                 g_user_balance_table(l_index).balance_name, 50);

         hr_utility.set_location('Arch EMEA BALANCE DEFINITION', 99);

         -- Archive the balance definition in 'EMEA BALANCE DEFINITION' if archive is Y
         if p_archive = 'Y' then

            pay_action_information_api.create_action_information
            (
               p_action_information_id       => l_action_info_id,
               p_action_context_id           => p_pactid,           -- Payroll Action of the Archiver
               p_action_context_type         => 'PA',
               p_object_version_number       => l_ovn,
               p_effective_date              => p_effective_date,   -- Effective Date of the Prepayments
               p_source_id                   => null,
               p_source_text                 => null,
               p_action_information_category => 'EMEA BALANCE DEFINITION',
               p_action_information1         => p_payroll_pact,     -- Payroll Action of the Prepayments
               p_action_information2         => g_user_balance_table(l_index).defined_balance_id,
               p_action_information3         => null,
               p_action_information4         => csr_eit_rec.org_information3   -- Balance Narrative
            );

         end if;

         g_max_user_balance_index := g_max_user_balance_index + 1;

      end if;

      -- Business Group Level Elements
      if p_eit_context = g_element_context then

         -- Populate Element PL/SQL table
         g_element_table(l_index).element_type_id   := csr_eit_rec.org_information1;
         g_element_table(l_index).input_value_id    := csr_eit_rec.org_information2;
         g_element_table(l_index).element_narrative := csr_eit_rec.org_information3;

         l_formula_id := null;

         open  csr_element_type(csr_eit_rec.org_information1, p_effective_date);
         fetch csr_element_type into l_formula_id;
         close csr_element_type;

         g_element_table(l_index).formula_id := l_formula_id;

-- Added for Bug 4488264
         l_once_each_period_flag  := null;
         open  csr_element_type1(csr_eit_rec.org_information1, p_effective_date);
         fetch csr_element_type1 into l_once_each_period_flag;
         close csr_element_type1;
         g_element_table(l_index).once_each_period_flag := l_once_each_period_flag;

         -- Retrieve the input value details
         open  csr_input_value_uom(csr_eit_rec.org_information2, p_effective_date);
         fetch csr_input_value_uom into l_uom;
         close csr_input_value_uom;

         hr_utility.set_location('g_element_table(l_index).once_each_period_flag: '||g_element_table(l_index).once_each_period_flag,10);
         hr_utility.set_location('g_element_table(l_index).formula_id: '||to_char(g_element_table(l_index).formula_id),10);

         -- Archive the element definition in 'EMEA ELEMENT DEFINITION' if archive is Y
         -- Note: These are the elements on the Organization Developer Flexfield only
         if p_archive = 'Y' then

            hr_utility.set_location('Arch EMEA ELEMENT DEFINITION', 99);

            pay_action_information_api.create_action_information
            (
               p_action_information_id       => l_action_info_id,
               p_action_context_id           => p_pactid,           -- Payroll Action of the Archiver
               p_action_context_type         => 'PA',
               p_object_version_number       => l_ovn,
               p_effective_date              => p_effective_date,   -- Effective Date of the Prepayments
               p_source_id                   => null,
               p_source_text                 => null,
               p_action_information_category => 'EMEA ELEMENT DEFINITION',
               p_action_information1         => p_payroll_pact,     -- Payroll Action of the Prepayments
               p_action_information2         => csr_eit_rec.org_information1,   -- Element Type ID
               p_action_information3         => csr_eit_rec.org_information2,   -- Input Value ID
               p_action_information4         => csr_eit_rec.org_information3,   -- Element Narrative
               p_action_information5         => 'F',   -- To indicate their from Flexfield, not Earning etc.
               p_action_information6         => l_uom
            );

         end if;

      end if;

      l_index := l_index + 1;

      hr_utility.set_location('l_index = ' || l_index, 99);

   end loop;

   g_max_element_index := l_index;

   if p_eit_context = g_balance_context then

      g_balance_archive_index := l_index - 1;

   else

      g_element_archive_index := l_index - 1;

   end if;

   hr_utility.set_location('g_balance_archive_index = ' || g_balance_archive_index, 99);

   hr_utility.set_location('Leaving ' || l_proc, 30);

end get_eit_definitions;

procedure setup_element_definitions
(
   p_pactid         in number,   -- Payroll Action of Archiver
   p_payroll_pact   in number,   -- Payroll Action of Prepayments
   p_effective_date in date      -- Effective Date of Prepayments
)  is

-- Returns all elements for the specified Prepayment and Classifications
-- FIX which classifications should i use
cursor csr_element_name(p_payroll_action_id number) is   -- Payroll Action of Prepayments
   select distinct pet.element_type_id              element_type_id,
          piv.input_value_id,
          nvl(pet.reporting_name, pet.element_name) element_name,
          pec.classification_name,
          piv.uom
   from   pay_element_types_f         pet,
          pay_input_values_f          piv,
          pay_run_results             prr,
          pay_element_classifications pec,
          pay_assignment_actions      paa,    -- Assignment Action of Prepayments
          pay_assignment_actions      rpaa,   -- Assignment Action of Run
          pay_action_interlocks       pai,
          pay_payroll_actions         ppa     -- Payroll Action of Prepayments
   where  pet.element_type_id = prr.element_type_id
   and    piv.element_type_id = pet.element_type_id
   and    piv.name = 'Pay Value'
   and    pet.classification_id = pec.classification_id
   and    pec.classification_name in
   (
      'Statutory Information',
      'Normal Income',
      'Statutory Deductions',
      'Lump Sum Amounts',
      'Allowances',
      'Deductions',
      'Information',
      'Involuntary Deductions',
      'Employer Contributions',
      'Voluntary Deductions',
      'Direct Payments',
      'Fringe Benefits'
   )
   and    pet.element_name not in ('ZA_Tax_Output', 'ZA_Tax_Output_2', 'ZA_Tax', 'ZA_Tax_2',
                                   'ZA_Tax_3', 'ZA_Tax_4', 'ZA_Tax_5', 'ZA_Tax_D1', 'ZA_Tax_D2',
                                   'ZA_Tax_D3', 'ZA_Tax_M', 'ZA_Tax_6')
   and    pec.legislation_code = 'ZA'
   and    prr.assignment_action_id = rpaa.assignment_action_id
   and    paa.payroll_action_id = ppa.payroll_action_id
   and    pai.locking_action_id = paa.assignment_action_id
   and    rpaa.assignment_action_id = pai.locked_action_id
   and    ppa.effective_date between pet.effective_start_date and pet.effective_end_date
   and    ppa.effective_date between piv.effective_start_date and piv.effective_end_date
   and    ppa.payroll_action_id = p_payroll_action_id;

-- Added the ZA_Tax_6 IN the NOT IN list
-- for the bug no 3663022

l_payment_type                 varchar2(1);
l_action_info_id               number(15);
l_ovn                          number(15);

l_proc                         varchar2(60);

begin
l_proc  := g_package || 'setup_element_definitions';
-- Removed default assignment to remove GSCC warning

   hr_utility.set_location('Entering ' || l_proc, 10);
   hr_utility.set_location('p_payroll_pact = ' || p_payroll_pact, 10);

   -- Loop through all elements for the specified Prepayment and Classifications
   for csr_element_rec in csr_element_name(p_payroll_pact) loop   -- Payroll Action of Prepayments

      hr_utility.set_location('csr_element_rec.element_type_id = ' || csr_element_rec.element_type_id, 20);
      hr_utility.set_location('csr_element_rec.element_name    = ' || csr_element_rec.element_name,    20);

      -- Classify the Element according to Classification
      -- FIX which classifications should i use?
      if csr_element_rec.classification_name in ('Normal Income', 'Allowances', 'Direct Payments', 'Lump Sum Amounts') then

         l_payment_type := 'E';   -- Earning

      elsif csr_element_rec.classification_name in ('Fringe Benefits', 'Information', 'Employer Contributions', 'Statutory Information') then

         l_payment_type := 'B';   -- Benefits

      else

         l_payment_type := 'D';   -- Deduction

      end if;

      hr_utility.set_location('Arch EMEA ELEMENT DEFINITION', 99);

      -- Archive the element definition in 'EMEA ELEMENT DEFINITION'
      -- Note: These are the Elements from the above Classifications and not the ones on the Org Flex
      pay_action_information_api.create_action_information
      (
         p_action_information_id       => l_action_info_id,
         p_action_context_id           => p_pactid,
         p_action_context_type         => 'PA',
         p_object_version_number       => l_ovn,
         p_effective_date              => p_effective_date,
         p_source_id                   => null,
         p_source_text                 => null,
         p_action_information_category => 'EMEA ELEMENT DEFINITION',
         p_action_information1         => p_payroll_pact,
         p_action_information2         => csr_element_rec.element_type_id,
         p_action_information3         => csr_element_rec.input_value_id,
         p_action_information4         => csr_element_rec.element_name,
         p_action_information5         => l_payment_type,
         p_action_information6         => csr_element_rec.uom
      );

   end loop;

   hr_utility.set_location('Leaving ' || l_proc, 30);

end setup_element_definitions;

procedure setup_standard_balance_table is

type balance_name_rec is record (balance_name varchar2(80));

type balance_id_rec is record (defined_balance_id number);

type balance_name_tab is table of balance_name_rec index by binary_integer;
type balance_id_tab   is table of balance_id_rec   index by binary_integer;

l_statutory_balance balance_name_tab;
l_statutory_bal_id  balance_id_tab;
-- 3221746 included subquery
cursor csr_balance_dimension
(
   p_balance   in varchar2,
   p_dimension in varchar2
)  is
select pdb.defined_balance_id
from   pay_balance_types pbt,
       pay_defined_balances pdb
where  pdb.balance_type_id = pbt.balance_type_id
and    pbt.balance_name = p_balance
and    pdb.balance_dimension_id = (select balance_dimension_id
                                         from pay_balance_dimensions
                                         where dimension_name = p_dimension);


l_archive_index                number       := 0;
l_dimension                    varchar2(12) ;
l_found                        varchar2(1);

l_max_stat_balance             number       := 215;

l_proc                         varchar2(100);

begin
l_dimension   := '_ASG_TAX_YTD';
l_proc := g_package || 'setup_standard_balance_table';
-- Removed default assignment to remove GSCC warning

   hr_utility.set_location('Entering ' || l_proc, 10);
   hr_utility.set_location('Step ' || l_proc, 20);

   l_statutory_balance(1  ).balance_name   := 'Taxable Income RFI';
   l_statutory_balance(2  ).balance_name   := 'Taxable Income PKG';
   l_statutory_balance(3  ).balance_name   := 'Taxable Income NRFI';
   l_statutory_balance(4  ).balance_name   := 'Non Taxable Income';
   l_statutory_balance(5  ).balance_name   := 'Taxable Pension RFI';
   l_statutory_balance(6  ).balance_name   := 'Taxable Pension PKG';
   l_statutory_balance(7  ).balance_name   := 'Taxable Pension NRFI';
   l_statutory_balance(8  ).balance_name   := 'Non Taxable Pension';
   l_statutory_balance(9  ).balance_name   := 'Taxable Annual Payment RFI';
   l_statutory_balance(10 ).balance_name   := 'Taxable Annual Payment PKG';
   l_statutory_balance(11 ).balance_name   := 'Taxable Annual Payment NRFI';
   l_statutory_balance(12 ).balance_name   := 'Annual Bonus RFI';
   l_statutory_balance(13 ).balance_name   := 'Annual Bonus PKG';
   l_statutory_balance(14 ).balance_name   := 'Annual Bonus NRFI';
   l_statutory_balance(15 ).balance_name   := 'Commission RFI';
   l_statutory_balance(16 ).balance_name   := 'Commission PKG';
   l_statutory_balance(17 ).balance_name   := 'Commission NRFI';
   l_statutory_balance(18 ).balance_name   := 'Overtime RFI';
   l_statutory_balance(19 ).balance_name   := 'Overtime PKG';
   l_statutory_balance(20 ).balance_name   := 'Overtime NRFI';
   l_statutory_balance(21 ).balance_name   := 'Taxable Arbitration Award RFI';
   l_statutory_balance(22 ).balance_name   := 'Taxable Arbitration Award NRFI';
   l_statutory_balance(23 ).balance_name   := 'Non Taxable Arbitration Award';
   l_statutory_balance(24 ).balance_name   := 'Annuity from Retirement Fund RFI';
   l_statutory_balance(25 ).balance_name   := 'Annuity from Retirement Fund PKG';
   l_statutory_balance(26 ).balance_name   := 'Annuity from Retirement Fund NRFI';
   l_statutory_balance(27 ).balance_name   := 'Purchased Annuity Taxable RFI';
   l_statutory_balance(28 ).balance_name   := 'Purchased Annuity Taxable PKG';
   l_statutory_balance(29 ).balance_name   := 'Purchased Annuity Taxable NRFI';
   l_statutory_balance(30 ).balance_name   := 'Purchased Annuity Non Taxable';
   l_statutory_balance(31 ).balance_name   := 'Travel Allowance RFI';
   l_statutory_balance(32 ).balance_name   := 'Travel Allowance PKG';
   l_statutory_balance(33 ).balance_name   := 'Travel Allowance NRFI';
   l_statutory_balance(34 ).balance_name   := 'Taxable Reimbursive Travel RFI';
   l_statutory_balance(35 ).balance_name   := 'Taxable Reimbursive Travel PKG';
   l_statutory_balance(36 ).balance_name   := 'Taxable Reimbursive Travel NRFI';
   l_statutory_balance(37 ).balance_name   := 'Non Taxable Reimbursive Travel';
   l_statutory_balance(38 ).balance_name   := 'Taxable Subsistence RFI';
   l_statutory_balance(39 ).balance_name   := 'Taxable Subsistence PKG';
   l_statutory_balance(40 ).balance_name   := 'Taxable Subsistence NRFI';
   l_statutory_balance(41 ).balance_name   := 'Non Taxable Subsistence';
   l_statutory_balance(42 ).balance_name   := 'Entertainment Allowance RFI';
   l_statutory_balance(43 ).balance_name   := 'Entertainment Allowance PKG';
   l_statutory_balance(44 ).balance_name   := 'Entertainment Allowance NRFI';
   l_statutory_balance(45 ).balance_name   := 'Share Options Exercised RFI';
   l_statutory_balance(46 ).balance_name   := 'Share Options Exercised NRFI';
   l_statutory_balance(47 ).balance_name   := 'Public Office Allowance RFI';
   l_statutory_balance(48 ).balance_name   := 'Public Office Allowance PKG';
   l_statutory_balance(49 ).balance_name   := 'Public Office Allowance NRFI';
   l_statutory_balance(50 ).balance_name   := 'Uniform Allowance';
   l_statutory_balance(51 ).balance_name   := 'Tool Allowance RFI';
   l_statutory_balance(52 ).balance_name   := 'Tool Allowance PKG';
   l_statutory_balance(53 ).balance_name   := 'Tool Allowance NRFI';
   l_statutory_balance(54 ).balance_name   := 'Computer Allowance RFI';
   l_statutory_balance(55 ).balance_name   := 'Computer Allowance PKG';
   l_statutory_balance(56 ).balance_name   := 'Computer Allowance NRFI';
   l_statutory_balance(57 ).balance_name   := 'Telephone Allowance RFI';
   l_statutory_balance(58 ).balance_name   := 'Telephone Allowance PKG';
   l_statutory_balance(59 ).balance_name   := 'Telephone Allowance NRFI';
   l_statutory_balance(60 ).balance_name   := 'Other Taxable Allowance RFI';
   l_statutory_balance(61 ).balance_name   := 'Other Taxable Allowance PKG';
   l_statutory_balance(62 ).balance_name   := 'Other Taxable Allowance NRFI';
   l_statutory_balance(63 ).balance_name   := 'Other Non Taxable Allowance';
   l_statutory_balance(64 ).balance_name   := 'Asset Purchased at Reduced Value RFI';
   l_statutory_balance(65 ).balance_name   := 'Asset Purchased at Reduced Value PKG';
   l_statutory_balance(66 ).balance_name   := 'Asset Purchased at Reduced Value NRFI';
   l_statutory_balance(67 ).balance_name   := 'Use of Motor Vehicle RFI';
   l_statutory_balance(68 ).balance_name   := 'Use of Motor Vehicle PKG';
   l_statutory_balance(69 ).balance_name   := 'Use of Motor Vehicle NRFI';
   l_statutory_balance(70 ).balance_name   := 'Right of Use of Asset RFI';
   l_statutory_balance(71 ).balance_name   := 'Right of Use of Asset PKG';
   l_statutory_balance(72 ).balance_name   := 'Right of Use of Asset NRFI';
   l_statutory_balance(73 ).balance_name   := 'Meals Refreshments and Vouchers RFI';
   l_statutory_balance(74 ).balance_name   := 'Meals Refreshments and Vouchers PKG';
   l_statutory_balance(75 ).balance_name   := 'Meals Refreshments and Vouchers NRFI';
   l_statutory_balance(76 ).balance_name   := 'Free or Cheap Accommodation RFI';
   l_statutory_balance(77 ).balance_name   := 'Free or Cheap Accommodation PKG';
   l_statutory_balance(78 ).balance_name   := 'Free or Cheap Accommodation NRFI';
   l_statutory_balance(79 ).balance_name   := 'Free or Cheap Services RFI';
   l_statutory_balance(80 ).balance_name   := 'Free or Cheap Services PKG';
   l_statutory_balance(81 ).balance_name   := 'Free or Cheap Services NRFI';
   l_statutory_balance(82 ).balance_name   := 'Low or Interest Free Loans RFI';
   l_statutory_balance(83 ).balance_name   := 'Low or Interest Free Loans PKG';
   l_statutory_balance(84 ).balance_name   := 'Low or Interest Free Loans NRFI';
   l_statutory_balance(85 ).balance_name   := 'Payment of Employee Debt RFI';
   l_statutory_balance(86 ).balance_name   := 'Payment of Employee Debt PKG';
   l_statutory_balance(87 ).balance_name   := 'Payment of Employee Debt NRFI';
   l_statutory_balance(88 ).balance_name   := 'Bursaries and Scholarships RFI';
   l_statutory_balance(89 ).balance_name   := 'Bursaries and Scholarships PKG';
   l_statutory_balance(90 ).balance_name   := 'Bursaries and Scholarships NRFI';
   l_statutory_balance(91 ).balance_name   := 'Medical Aid Paid on Behalf of Employee RFI';
   l_statutory_balance(92 ).balance_name   := 'Medical Aid Paid on Behalf of Employee PKG';
   l_statutory_balance(93 ).balance_name   := 'Medical Aid Paid on Behalf of Employee NRFI';
   l_statutory_balance(94 ).balance_name   := 'Retirement or Retrenchment Gratuities';
   l_statutory_balance(95 ).balance_name   := 'Resignation Pension and RAF Lump Sums';
   l_statutory_balance(96 ).balance_name   := 'Retirement Pension and RAF Lump Sums';
   l_statutory_balance(97 ).balance_name   := 'Resignation Provident Lump Sums';
   l_statutory_balance(98 ).balance_name   := 'Retirement Provident Lump Sums';
   l_statutory_balance(99 ).balance_name   := 'Special Remuneration';
   l_statutory_balance(100).balance_name   := 'Other Lump Sums';
   l_statutory_balance(101).balance_name   := 'Current Pension Fund';
   l_statutory_balance(102).balance_name   := 'Arrear Pension Fund';
   l_statutory_balance(103).balance_name   := 'Current Provident Fund';
   l_statutory_balance(104).balance_name   := 'Arrear Provident Fund';
   l_statutory_balance(105).balance_name   := 'Medical Aid Contribution';
   l_statutory_balance(106).balance_name   := 'Current Retirement Annuity';
   l_statutory_balance(107).balance_name   := 'Arrear Retirement Annuity';
   l_statutory_balance(108).balance_name   := 'Tax on Lump Sums';
   l_statutory_balance(109).balance_name   := 'Tax';
   l_statutory_balance(110).balance_name   := 'UIF Employee Contribution';
   l_statutory_balance(111).balance_name   := 'Voluntary Tax';
   l_statutory_balance(112).balance_name   := 'Bonus Provision';
   l_statutory_balance(113).balance_name   := 'SITE';
   l_statutory_balance(114).balance_name   := 'PAYE';
   l_statutory_balance(115).balance_name   := 'Annual Pension Fund';
   l_statutory_balance(116).balance_name   := 'Annual Commission RFI';
   l_statutory_balance(117).balance_name   := 'Annual Commission PKG';
   l_statutory_balance(118).balance_name   := 'Annual Commission NRFI';
   l_statutory_balance(119).balance_name   := 'Annual Provident Fund';
   l_statutory_balance(120).balance_name   := 'Restraint of Trade RFI';
   l_statutory_balance(121).balance_name   := 'Restraint of Trade PKG';
   l_statutory_balance(122).balance_name   := 'Restraint of Trade NRFI';
   l_statutory_balance(123).balance_name   := 'Annual Restraint of Trade RFI';
   l_statutory_balance(124).balance_name   := 'Annual Restraint of Trade PKG';
   l_statutory_balance(125).balance_name   := 'Annual Restraint of Trade NRFI';
   l_statutory_balance(126).balance_name   := 'Annual Asset Purchased at Reduced Value RFI';
   l_statutory_balance(127).balance_name   := 'Annual Asset Purchased at Reduced Value PKG';
   l_statutory_balance(128).balance_name   := 'Annual Asset Purchased at Reduced Value NRFI';
   l_statutory_balance(129).balance_name   := 'Annual Retirement Annuity';
   l_statutory_balance(130).balance_name   := 'Annual Arrear Pension Fund';
   l_statutory_balance(131).balance_name   := 'Annual Arrear Retirement Annuity';
   l_statutory_balance(132).balance_name   := 'Annual Bursaries and Scholarships NRFI';
   l_statutory_balance(133).balance_name   := 'Annual Bursaries and Scholarships RFI';
   l_statutory_balance(134).balance_name   := 'Annual Bursaries and Scholarships PKG';
   l_statutory_balance(135).balance_name   := 'Annual EE Income Protection Policy Contributions';
   l_statutory_balance(136).balance_name   := 'Annual Independent Contractor Payments NRFI';
   l_statutory_balance(137).balance_name   := 'Annual Independent Contractor Payments RFI';
   l_statutory_balance(138).balance_name   := 'Annual Independent Contractor Payments PKG';
   l_statutory_balance(139).balance_name   := 'Annual Labour Broker Payments NRFI';
   l_statutory_balance(140).balance_name   := 'Annual Labour Broker Payments RFI';
   l_statutory_balance(141).balance_name   := 'Annual Labour Broker Payments PKG';
   l_statutory_balance(142).balance_name   := 'Annual NRFIable Total Package';
   l_statutory_balance(143).balance_name   := 'Annual Payment of Employee Debt NRFI';
   l_statutory_balance(144).balance_name   := 'Annual Payment of Employee Debt RFI';
   l_statutory_balance(145).balance_name   := 'Annual Payment of Employee Debt PKG';
   l_statutory_balance(146).balance_name   := 'Annual RFIable Total Package';
   l_statutory_balance(147).balance_name   := 'Directors Deemed Remuneration';
   l_statutory_balance(148).balance_name   := 'EE Income Protection Policy Contributions';
   l_statutory_balance(149).balance_name   := 'Executive Equity Shares NRFI';
   l_statutory_balance(150).balance_name   := 'Executive Equity Shares RFI';
   l_statutory_balance(151).balance_name   := 'Independent Contractor Payments NRFI';
   l_statutory_balance(152).balance_name   := 'Independent Contractor Payments RFI';
   l_statutory_balance(153).balance_name   := 'Independent Contractor Payments PKG';
   l_statutory_balance(154).balance_name   := 'Labour Broker Payments NRFI';
   l_statutory_balance(155).balance_name   := 'Labour Broker Payments RFI';
   l_statutory_balance(156).balance_name   := 'Labour Broker Payments PKG';
   l_statutory_balance(157).balance_name   := 'NRFIable Total Package';
   l_statutory_balance(158).balance_name   := 'Non Taxable Subsistence Allowance Foreign Travel';
   l_statutory_balance(159).balance_name   := 'Other Retirement Lump Sums';
   l_statutory_balance(160).balance_name   := 'RFIable Total Package';
   l_statutory_balance(161).balance_name   := 'Taxable Subsistence Allowance Foreign Travel NRFI';
   l_statutory_balance(162).balance_name   := 'Taxable Subsistence Allowance Foreign Travel RFI';
   l_statutory_balance(163).balance_name   := 'Taxable Subsistence Allowance Foreign Travel PKG';
   l_statutory_balance(164).balance_name   := 'EE Broadbased Share Plan NRFI';
   l_statutory_balance(165).balance_name   := 'EE Broadbased Share Plan RFI';
   l_statutory_balance(166).balance_name   := 'EE Broadbased Share Plan PKG';
   l_statutory_balance(167).balance_name   := 'Other Lump Sum Taxed as Annual Payment RFI';
   l_statutory_balance(168).balance_name   := 'Other Lump Sum Taxed as Annual Payment NRFI';
   l_statutory_balance(169).balance_name   := 'Other Lump Sum Taxed as Annual Payment PKG';
--  End bug 4276047

-- Begin: TYS 06-07 Changes
   l_statutory_balance(170).balance_name   := 'Med Costs Pd by ER IRO EE_Family RFI';
   l_statutory_balance(171).balance_name   := 'Med Costs Pd by ER IRO EE_Family NRFI';
   l_statutory_balance(172).balance_name   := 'Med Costs Pd by ER IRO EE_Family PKG';
   l_statutory_balance(173).balance_name   := 'Annual Med Costs Pd by ER IRO EE_Family RFI';
   l_statutory_balance(174).balance_name   := 'Annual Med Costs Pd by ER IRO EE_Family NRFI';
   l_statutory_balance(175).balance_name   := 'Annual Med Costs Pd by ER IRO EE_Family PKG';
   l_statutory_balance(176).balance_name   := 'Annual Med Costs Pd by ER IRO Other RFI';
   l_statutory_balance(177).balance_name   := 'Annual Med Costs Pd by ER IRO Other NRFI';
   l_statutory_balance(178).balance_name   := 'Annual Med Costs Pd by ER IRO Other PKG';
   l_statutory_balance(179).balance_name   := 'Med Costs Pd by ER IRO Other RFI';
   l_statutory_balance(180).balance_name   := 'Med Costs Pd by ER IRO Other NRFI';
   l_statutory_balance(181).balance_name   := 'Med Costs Pd by ER IRO Other PKG';
   l_statutory_balance(182).balance_name   := 'Medical Contributions Abatement';
   l_statutory_balance(183).balance_name   := 'Annual Medical Contributions Abatement';
   l_statutory_balance(184).balance_name   := 'Medical Fund Capping Amount';
   l_statutory_balance(185).balance_name   := 'Med Costs Dmd Pd by EE EE_Family RFI';
   l_statutory_balance(186).balance_name   := 'Med Costs Dmd Pd by EE EE_Family NRFI';
   l_statutory_balance(187).balance_name   := 'Med Costs Dmd Pd by EE EE_Family PKG';
   l_statutory_balance(188).balance_name   := 'Annual Med Costs Dmd Pd by EE EE_Family RFI';
   l_statutory_balance(189).balance_name   := 'Annual Med Costs Dmd Pd by EE EE_Family NRFI';
   l_statutory_balance(190).balance_name   := 'Annual Med Costs Dmd Pd by EE EE_Family PKG';
   l_statutory_balance(191).balance_name   := 'Med Costs Dmd Pd by EE Other RFI';
   l_statutory_balance(192).balance_name   := 'Med Costs Dmd Pd by EE Other NRFI';
   l_statutory_balance(193).balance_name   := 'Med Costs Dmd Pd by EE Other PKG';
   l_statutory_balance(194).balance_name   := 'Annual Med Costs Dmd Pd by EE Other RFI';
   l_statutory_balance(195).balance_name   := 'Annual Med Costs Dmd Pd by EE Other NRFI';
   l_statutory_balance(196).balance_name   := 'Annual Med Costs Dmd Pd by EE Other PKG';
   l_statutory_balance(197).balance_name   := 'Non Taxable Med Costs Pd by ER';
-- End: TYS 06-07 Changes

-- Begin: TYE 08 Changes
   l_statutory_balance(198).balance_name   := 'Employers Retirement Annuity Fund Contributions';
   l_statutory_balance(199).balance_name   := 'Employers Premium paid on Loss of Income Policies';
   l_statutory_balance(200).balance_name   := 'Medical Contr Pd by ER for Retired EE';
   l_statutory_balance(201).balance_name   := 'Surplus Apportionment';
   l_statutory_balance(202).balance_name   := 'Unclaimed Benefits';
   l_statutory_balance(203).balance_name   := 'Retire Pen RAF Prov Fund Ben on Ret or Death RFI';
   l_statutory_balance(204).balance_name   := 'Retire Pen RAF Prov Fund Ben on Ret or Death NRFI';
   l_statutory_balance(205).balance_name   := 'Tax on Retirement Fund Lump Sums';
-- End: TYE 08 Changes
   l_statutory_balance(206).balance_name   := 'Pension Employer Contribution';
   l_statutory_balance(207).balance_name   := 'Provident Employer Contribution';
   l_statutory_balance(208).balance_name   := 'Medical Aid Employer Contribution';
   --Added for Bug 8406456-Mar2009 Sars codes
   l_statutory_balance(209).balance_name   := 'Retire Pen RAF and Prov Fund Lump Sum withdrawal benefits';
   l_statutory_balance(210).balance_name   := 'Donations made by EE and paid by ER';
   l_statutory_balance(211).balance_name   := 'Annual Donations made by EE and paid by ER';
   l_statutory_balance(212).balance_name   := 'Annual Payment of Employee Debt NRFI NTG';
   l_statutory_balance(213).balance_name   := 'Annual Payment of Employee Debt RFI NTG';
   l_statutory_balance(214).balance_name   := 'PAYE Employer Contribution for Tax Free Earnings';
   l_statutory_balance(215).balance_name   := 'Living Annuity and Surplus Apportionments Lump Sums';


   hr_utility.set_location('Step = ' || l_proc, 30);

   for l_index in 1..l_max_stat_balance loop

      hr_utility.set_location('l_index      = ' || l_index, 30);
      hr_utility.set_location('balance_name = ' || l_statutory_balance(l_index).balance_name, 30);
      hr_utility.set_location('l_dimension  = ' || l_dimension, 30);

      open  csr_balance_dimension(l_statutory_balance(l_index).balance_name, l_dimension);
      fetch csr_balance_dimension
      into  l_statutory_bal_id(l_index).defined_balance_id;

      if csr_balance_dimension%notfound then

         l_statutory_bal_id(l_index).defined_balance_id := 0;

      end if;

      close csr_balance_dimension;

      hr_utility.set_location('defined_balance_id = ' || l_statutory_bal_id(l_index).defined_balance_id, 30);

   end loop;

   hr_utility.set_location('Step = ' || l_proc, 40);

   hr_utility.set_location('l_max_stat_balance       = ' || l_max_stat_balance, 40);
   hr_utility.set_location('g_max_user_balance_index = ' || g_max_user_balance_index, 40);

   for l_index in 1..l_max_stat_balance loop

      l_found := 'N';

      for l_eit_index in 1..g_max_user_balance_index loop

         hr_utility.set_location('l_index            = ' || l_index, 40);
         hr_utility.set_location('l_eit_index        = ' || l_eit_index, 40);
         hr_utility.set_location('defined_balance_id = ' || l_statutory_bal_id(l_index).defined_balance_id, 40);
         hr_utility.set_location('l_found            = ' || l_found, 40);

         if l_statutory_bal_id(l_index).defined_balance_id
            = g_user_balance_table(l_eit_index).defined_balance_id then

            l_found := 'Y';

         end if;

      end loop;

      if l_found = 'N' then

         hr_utility.set_location('l_archive_index = ' || l_archive_index, 40);

         l_archive_index := l_archive_index + 1;
         g_statutory_balance_table(l_archive_index).defined_balance_id := l_statutory_bal_id(l_index).defined_balance_id;

      end if;

   end loop;

   g_max_statutory_balance_index := l_archive_index;

   hr_utility.set_location('Step ' || l_proc, 50);
   hr_utility.set_location('l_archive_index = ' || l_archive_index, 50);

   hr_utility.set_location('Leaving ' || l_proc, 60);

end setup_standard_balance_table;

procedure arch_za_pay_action_level_data(
               p_payroll_action_id in number
              ,p_payroll_id        in number
              ,p_effective_date    in date) is

cursor csr_get_organization(p_payroll_id     number
                           ,p_effective_date date) is
       select distinct paei.aei_information7 legal_entity_id
       from   per_all_assignments_f paa,
              per_assignment_extra_info paei
       where  paa.payroll_id = p_payroll_id
       and    p_effective_date between paa.effective_start_date
                                   and paa.effective_end_date
       and    paa.assignment_id = paei.assignment_id
       and    paei.information_type = 'ZA_SPECIFIC_INFO'
       and    not exists (select 1
                          from per_all_assignments_f paa1
                          where paa1.payroll_id = p_payroll_id
                          and paa1.organization_id = paei.aei_information7
                          And p_effective_date between paa1.effective_start_date
                                               and     paa1.effective_end_date);
-- added effective date condition in "not exists" clasuse on 02-Jul-06


cursor csr_legal_entity_details(p_legal_entity_id number) is
       select hou.name legal_entity_name,
              hl.address_line_1,
              hl.address_line_2,
              hl.address_line_3,
              hl.town_or_city,
              hl.region_1,
              hl.region_2,
              hl.region_3,
              hl.postal_code,
              hl.country,
              hl.telephone_number_1
       from   hr_locations hl,
              hr_organization_units hou
       where  hou.organization_id = p_legal_entity_id
       and    hou.location_id = hl.location_id;

l_action_information_id number(15);
l_ovn                   number;
l_name                  varchar2(240);
l_address_line_1        varchar2(240);
l_address_line_2        varchar2(240);
l_address_line_3        varchar2(240);
l_town_or_city          varchar2(30);
l_region_1              varchar2(120);
l_region_2              varchar2(120);
l_region_3              varchar2(120);
l_postal_code           varchar2(30);
l_country               varchar2(60);
l_telephone_number_1    varchar2(60);

l_proc                         varchar2(60) ;

begin
l_proc  := g_package || 'arch_za_pay_action_level_data';
-- Removed default assignment to remove GSCC warning

   hr_utility.set_location('Entering ' || l_proc, 10);

   hr_utility.set_location('Step ' || l_proc, 20);

  for rec_get_organization in csr_get_organization(p_payroll_id,p_effective_date)

  loop

    open csr_legal_entity_details(rec_get_organization.legal_entity_id);

    fetch csr_legal_entity_details into l_name,
                                        l_address_line_1,
                                        l_address_line_2,
                                        l_address_line_3,
                                        l_town_or_city,
                                        l_region_1,
                                        l_region_2,
                                        l_region_3,
                                        l_postal_code,
                                        l_country,
                                        l_telephone_number_1;

    close csr_legal_entity_details;

    pay_action_information_api.create_action_information(
      p_action_information_id       => l_action_information_id,
      p_action_context_id           => p_payroll_action_id, -- Payroll Action of the Archiver
      p_action_context_type         => 'PA',
      p_object_version_number       => l_ovn,
      p_effective_date              => p_effective_date,   -- Effective Date of the Prepayments
      p_source_id                   => null,
      p_source_text                 => null,
      p_action_information_category => 'ADDRESS DETAILS',
      p_action_information1         => rec_get_organization.legal_entity_id,
      p_action_information2         => null,
      p_action_information3         => null,
      p_action_information4         => null,
      p_action_information5         => l_address_line_1,
      p_action_information6         => l_address_line_2,
      p_action_information7         => l_address_line_3,
      p_action_information8         => l_town_or_city,
      p_action_information9         => l_region_1,
      p_action_information10        => l_region_2,
      p_action_information11        => l_region_3,
      p_action_information12        => l_postal_code,
      p_action_information13        => l_country,
      p_action_information14        => 'Employer Address'
    );

  end loop;

  hr_utility.set_location('Leaving ' || l_proc, 30);

end arch_za_pay_action_level_data;

procedure update_employee_information(
              p_action_context_id in number
             ,p_assignment_id     in number) is

cursor csr_get_archive_info(p_action_context_id number
                           ,p_assignment_id     number) is
       select action_information_id,
              effective_date,
              object_version_number
       from   pay_action_information
       where  action_context_id = p_action_context_id
       and    action_context_type = 'AAP'
       and    assignment_id = p_assignment_id
       and    action_information_category = 'EMPLOYEE DETAILS';

--Added to update the address if postal address same as residential address
cursor csr_employee_address is
       select action_information_id,
              action_information10, --region2 i.e. Postal same as residential address indicator
              effective_date,
              object_version_number
       from   pay_action_information
       where  action_context_id = p_action_context_id
       and    action_context_type = 'AAP'
       and    assignment_id = p_assignment_id
       and    action_information_category = 'ADDRESS DETAILS'
       and    action_information14 = 'Employee Address';

-- Retrieve residential address
cursor csr_res_address is
       select address_line1  ee_unit_num
              , address_line2  ee_complex
              , address_line3  ee_street_num
              , region_1       ee_street_name
              , region_2       ee_suburb_district
              , town_or_city   ee_town_city
              , postal_code    ee_postal_code
       from per_addresses ad,
            per_all_assignments_f paf
       where paf.assignment_id = p_assignment_id
       and   paf.person_id = ad.person_id
       and   g_archive_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'))
       and   g_archive_effective_date between paf.effective_start_date and paf.effective_end_date
       and   ad.style        = 'ZA_SARS'
       and   ad.address_type = 'ZA_RES';

cursor csr_emp_legal_entity(p_assignment_id number) is
       select paei.aei_information7 legal_entity_id,
              hou.name legal_entity_name,
              hl.telephone_number_1
       from   per_assignment_extra_info paei,
              hr_organization_units hou,
              hr_locations hl
       where  paei.assignment_id = p_assignment_id
       and    paei.information_type = 'ZA_SPECIFIC_INFO'
       and    paei.aei_information7 = hou.organization_id
       and    hou.location_id = hl.location_id;

l_action_information_id number(15);
l_effective_date        date;
l_ovn                   number;
l_legal_entity_id       varchar2(150);
l_legal_entity_name     varchar2(240);
l_telephone_number_1    varchar2(60);
rec_employee_address csr_employee_address%rowtype;
rec_res_address csr_res_address%rowtype;

l_proc                  varchar2(60);

begin
l_proc  := g_package || 'update_employee_information';
-- Removed default assignment to remove GSCC warning
  hr_utility.set_location('Entering ' || l_proc, 10);

  hr_utility.set_location('Step ' || l_proc, 20);

  open csr_get_archive_info(p_action_context_id,p_assignment_id);

  loop

    fetch csr_get_archive_info into l_action_information_id,
                                    l_effective_date,
                                    l_ovn;

    if csr_get_archive_info%notfound then
         exit;
    end if;

    open csr_emp_legal_entity(p_assignment_id);

    fetch csr_emp_legal_entity into l_legal_entity_id,
                                    l_legal_entity_name,
                                    l_telephone_number_1;

    close csr_emp_legal_entity;

    -- telephone number should be archived in action_information25
    -- but for ZA, address_line4 is stored in hl.telephone_number_1
    -- so action_information25 is set to null until this is resolved

    pay_action_information_api.update_action_information(
      p_action_information_id => l_action_information_id,
      p_object_version_number => l_ovn,
      p_action_information18  => l_legal_entity_name,
      p_action_information25  => NULL
      );

    update pay_action_information
    set tax_unit_id = l_legal_entity_id
    where action_information_id = l_action_information_id;

  end loop;
  close csr_get_archive_info;

  --Check whether postal address is same as residential address
  open csr_employee_address;
  fetch csr_employee_address into rec_employee_address;
  if rec_employee_address.action_information10='Y' then
      open csr_res_address;
      fetch csr_res_address into rec_res_address;
      close csr_res_address;

      pay_action_information_api.update_action_information(
        p_action_information_id => rec_employee_address.action_information_id,
        p_object_version_number => rec_employee_address.object_version_number,
        p_action_information5   => rec_res_address.ee_unit_num,
        p_action_information6   => rec_res_address.ee_complex,
        p_action_information7   => rec_res_address.ee_street_num,
        p_action_information8   => rec_res_address.ee_street_name,
        p_action_information9   => rec_res_address.ee_suburb_district,
        p_action_information10  => rec_res_address.ee_town_city,
        p_action_information12   => rec_res_address.ee_postal_code
       );

  elsif rec_employee_address.action_information10='N' then
     --Set the Postal as same as residential to null so it is not displayed in payslip
      pay_action_information_api.update_action_information(
        p_action_information_id => rec_employee_address.action_information_id,
        p_object_version_number => rec_employee_address.object_version_number,
        p_action_information10  => NULL
       );
  end if;
  close csr_employee_address;


  hr_utility.set_location('Leaving ' || l_proc, 30);

end update_employee_information;

-- This procedure gets called third to do initialization.
-- The procedure gets called once for each concurrent sub process?
procedure archinit(p_payroll_action_id in number) is   -- Payroll Action of the Archiver

cursor csr_archive_effective_date(pactid number) is
   select effective_date
   from   pay_payroll_actions
   where  payroll_action_id = pactid;

cursor csr_input_value_id
(
   p_element_name varchar2,
   p_value_name   varchar2
)  is
   select piv.input_value_id
   from   pay_input_values_f  piv,
          pay_element_types_f pet
   where  piv.element_type_id = pet.element_type_id
   and    pet.legislation_code = 'ZA'
   and    pet.element_name = p_element_name
   and    piv.name = p_value_name;

-- Returns all prepayments for the specified parameters
cursor csr_payroll_info
(
   p_payroll_id       number,
   p_consolidation_id number,
   p_start_date       date,
   p_end_date         date
)  is
   select pact.payroll_action_id payroll_action_id,
          pact.effective_date    effective_date
   from   pay_payrolls_f      ppf,
          pay_payroll_actions pact   -- Payroll Action of Prepayments
   where  pact.payroll_id = ppf.payroll_id
   and    pact.effective_date between ppf.effective_start_date and ppf.effective_end_date
   and    pact.payroll_id = nvl(p_payroll_id, pact.payroll_id)
   and    pact.consolidation_set_id = p_consolidation_id
   and    pact.effective_date between p_start_date and p_end_date
   and
   (
      pact.action_type = 'P'
      or
      pact.action_type = 'U'
   )
   and    pact.action_status = 'C';

l_payroll_id                   number;
l_consolidation_set            number;
l_assignment_set_id            number;
l_start_date                   varchar2(30);
l_end_date                     varchar2(30);
l_bg_id                        number;
l_canonical_end_date           date;
l_canonical_start_date         date;

l_proc                         varchar2(50);

begin
l_proc := g_package || 'archinit';
-- Removed default assignment to remove GSCC warning

   -- hr_utility.trace_on(null,'ZA_SOE');
   hr_utility.set_location('Entering ' || l_proc, 10);

   g_archive_pact := p_payroll_action_id;   -- Payroll Action of the Archiver

   -- Get the effective date of the payroll action
   open  csr_archive_effective_date(p_payroll_action_id);   -- Payroll Action of the Archiver
   fetch csr_archive_effective_date into g_archive_effective_date;
   close csr_archive_effective_date;

   -- Retrieve the legislative parameters from the payroll action
   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,   -- Payroll Action of the Archiver
      p_token_name        => 'PAYROLL',
      p_token_value       => l_payroll_id
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,
      p_token_name        => 'CONSOLIDATION',
      p_token_value       => l_consolidation_set
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,
      p_token_name        => 'ASSIGNMENT_SET',
      p_token_value       => l_assignment_set_id
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,
      p_token_name        => 'START_DATE',
      p_token_value       => l_start_date
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,
      p_token_name        => 'END_DATE',
      p_token_value       => l_end_date
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,
      p_token_name        => 'BG_ID',
      p_token_value       => l_bg_id
   );

  --Added for Bug 7519419
   update pay_payroll_actions
   set payroll_id = l_payroll_id, consolidation_set_id = l_consolidation_set
   where payroll_action_id=p_payroll_action_id;

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('l_payroll_id = ' || l_payroll_id, 20);
   hr_utility.set_location('l_start_date = ' || l_start_date, 20);
   hr_utility.set_location('l_end_date   = ' || l_end_date,   20);

   l_canonical_start_date := to_date(l_start_date,'yyyy/mm/dd');
   l_canonical_end_date   := to_date(l_end_date,'yyyy/mm/dd');

   -- Retrieve id for tax element
   open  csr_input_value_id('ZA_Tax','Tax Status');
   fetch csr_input_value_id into g_tax_element_id;
   close csr_input_value_id;

   hr_utility.set_location('l_payroll_id           = ' || l_payroll_id, 20);
   hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set, 20);
   hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date, 20);
   hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date, 20);

   -- Loop through all the prepayments for the specified parameters
   for rec_payroll_info in csr_payroll_info
                           (
                              l_payroll_id,
                              l_consolidation_set,
                              l_canonical_start_date,
                              l_canonical_end_date
                           )
   loop

      -- Retrieve and archive user definitions from EITs
      -- The definitions are archived again for each prepayment
      g_max_user_balance_index := 0;

      hr_utility.set_location('get_eit_definitions - balances', 20);

      pay_za_payslip_archive.get_eit_definitions
      (
         p_pactid            => p_payroll_action_id,                  -- Payroll Action of the Archiver
         p_business_group_id => l_bg_id,
         p_payroll_pact      => rec_payroll_info.payroll_action_id,   -- Payroll Action of the Prepayment
         p_effective_date    => rec_payroll_info.effective_date,      -- Effective Date of the Prepayment
         p_eit_context       => g_balance_context,
         p_archive           => 'N'
      );

      hr_utility.set_location('get_eit_definitions - elements', 20);

      pay_za_payslip_archive.get_eit_definitions
      (
         p_pactid            => p_payroll_action_id,                  -- Payroll Action of the Archiver
         p_business_group_id => l_bg_id,
         p_payroll_pact      => rec_payroll_info.payroll_action_id,   -- Payroll Action of the Prepayment
         p_effective_date    => rec_payroll_info.effective_date,      -- Effective Date of the Prepayment
         p_eit_context       => g_element_context,
         p_archive           => 'N'
      );

      -- Set the Payroll Action ID context to the Payroll Action of the current Prepayment
      -- Note: It takes the last value it gets set to
      -- FIX must be an error
      pay_balance_pkg.set_context
      (
         'PAYROLL_ACTION_ID',
         rec_payroll_info.payroll_action_id
      );

   end loop;

   -- Setup statutory balances pl/sql table
   pay_za_payslip_archive.setup_standard_balance_table;

   hr_utility.set_location('Leaving ' || l_proc, 20);

end archinit;

procedure archive_employee_details
(
   p_assactid             in number,
   p_assignment_id        in number,
   p_curr_pymt_ass_act_id in number,
   p_date_earned          in date,
   p_curr_pymt_eff_date   in date,
   p_time_period_id       in number
)  is

l_action_info_id               number;
l_person_id                    number;
l_ovn                          number;
l_tax_status                   varchar2(60);
l_tax_status_meaning           varchar2(80);
l_termination_date             date;
l_tax_ref_number               varchar2(150);
l_tax_period                   varchar(20);
l_pay_date                     date;

l_proc                         varchar2(50);

begin
l_proc := g_package || 'archive_employee_details';
-- Removed default assignment to remove GSCC warning
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Call generic procedure to retrieve and archive all data for
   -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION
   hr_utility.set_location('Calling pay_emp_action_arch', 20);

   -- Archive Employee Details through core package
   pay_emp_action_arch.get_personal_information
   (
      p_payroll_action_id    => g_archive_pact,            -- archive payroll_action_id
      p_assactid             => p_assactid,                -- archive assignment_action_id
      p_assignment_id        => p_assignment_id,           -- current assignment_id
      p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id,    -- prepayment assignment_action_id
      p_curr_eff_date        => g_archive_effective_date,  -- archive effective_date
      p_date_earned          => p_date_earned,             -- payroll date_earned
      p_curr_pymt_eff_date   => p_curr_pymt_eff_date,      -- prepayment effective_date
      p_tax_unit_id          => null,                      -- only required for US
      p_time_period_id       => p_time_period_id,          -- payroll time_period_id
      p_ppp_source_action_id => null
   );

   hr_utility.set_location('Returned from pay_emp_action_arch', 30);

   -- Call procedure to archive ZA specific data in generic EMPLOYEE DETAILS

   hr_utility.set_location('Calling update_employee_information', 40);

   update_employee_information
   (
      p_action_context_id => p_assactid,
      p_assignment_id     => p_assignment_id
   );

   hr_utility.set_location('Returned from update_employee_information', 50);

   -- Retrieve the ZA specific employee details
   -- Person Id
   select max(person_id)
   into   l_person_id
   from   per_all_assignments_f
   where  assignment_id = p_assignment_id;

   -- Tax Reference Number (Income Tax Number)
   begin

      select max(per_information1)
      into   l_tax_ref_number
      from   per_all_people_f papf
      where  papf.person_id = l_person_id
      and    papf.current_employee_flag = 'Y'
      and    per_information_category = 'ZA'
      and    g_archive_effective_date between effective_start_date and effective_end_date;  -- Bug 4204930

   exception
      when no_data_found then
         l_tax_ref_number := null;

   end;

   -- Tax Status
   begin

      select peevf.screen_entry_value
      into   l_tax_status
      from   pay_element_entries_f      peef,
             pay_element_entry_values_f peevf
      where  peef.assignment_id = p_assignment_id
      and    peevf.input_value_id = g_tax_element_id
      and    peef.element_entry_id = peevf.element_entry_id
      and    peef.effective_start_date <= g_archive_effective_date    -- Bug 3513520
      and    peef.effective_end_date >= g_archive_effective_date    -- Bug 3513520
      and    peevf.effective_start_date = peef.effective_start_date; -- Bug 3513520

      if g_tax_status is null or g_tax_status <> l_tax_status then

         select meaning
         into   g_tax_status_meaning
         from   hr_lookups
         where  lookup_type = 'ZA_TAX_STATUS'
         and    application_id = 800
         and    lookup_code = l_tax_status;

         g_tax_status := l_tax_status;
         l_tax_status_meaning := g_tax_status_meaning;

      else

         l_tax_status_meaning := g_tax_status_meaning;

      end if;

   exception
      when no_data_found then
         l_tax_status_meaning := null;

   end;

   -- Tax Period
   begin

      select period_num, cut_off_date
      into   l_tax_period, l_pay_date
      from   per_time_periods
      where  time_period_id = p_time_period_id;

   exception
      when no_data_found then
         l_tax_period := null;

   end;

   -- Termination Date
   begin

      select decode(to_char(max(papf.effective_end_date), 'dd/mm/yyyy'), '31/12/4712', null, max(papf.effective_end_date))
      into   l_termination_date
      from   per_all_people_f papf
      where  papf.person_id = l_person_id
      and    papf.current_employee_flag = 'Y';

   exception
      when no_data_found then
         l_termination_date := null;

   end;

   hr_utility.set_location('Archiving ZA EMPLOYEE DETAILS', 50);

   -- Archive the ZA specific employee details
   pay_action_information_api.create_action_information
   (
      p_action_information_id       => l_action_info_id,
      p_action_context_id           => p_assactid,
      p_action_context_type         => 'AAP',
      p_object_version_number       => l_ovn,
      p_assignment_id               => p_assignment_id,
      p_effective_date              => g_archive_effective_date,
      p_source_id                   => null,
      p_source_text                 => null,
      p_action_information_category => 'ZA EMPLOYEE DETAILS',
      p_action_information1         => null,
      p_action_information2         => null,
      p_action_information3         => null,
      p_action_information21        => l_tax_ref_number,
      p_action_information22        => l_tax_status_meaning,
      p_action_information23        => l_tax_period,
      p_action_information24        => fnd_date.date_to_displaydate(l_termination_date), -- Bug 3513520
      p_action_information25        => fnd_date.date_to_displaydate(l_pay_date) -- Bug 3513520
   );

end archive_employee_details;

procedure process_balance
(
   p_action_context_id in number,
   p_assignment_id     in number,
   p_source_id         in number,
   p_effective_date    in date,
   p_balance           in varchar2,
   p_dimension         in varchar2,
   p_defined_bal_id    in number,
   p_record_count      in number
)  is

l_action_info_id               number;
l_balance_value                number;
l_ovn                          number;
l_record_count                 varchar2(10);

l_proc                         varchar2(50);

begin
l_proc  := g_package || 'process_balance';
-- Removed default assignment to remove GSCC warning
   hr_utility.set_location('Entering ' || l_proc, 10);

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('p_source_id      = ' || p_source_id, 20);
   hr_utility.set_location('p_balance        = ' || p_balance, 20);
   hr_utility.set_location('p_dimension      = ' || p_dimension, 20);
   hr_utility.set_location('p_defined_bal_id = ' || p_defined_bal_id, 20);

   l_balance_value := pay_balance_pkg.get_value
                      (
                         p_defined_balance_id   => p_defined_bal_id,
                         p_assignment_action_id => p_source_id
                      );

   hr_utility.set_location('l_balance_value = ' || l_balance_value, 20);

   if p_record_count = 0 then

      l_record_count := null;

   else

      l_record_count := p_record_count + 1;

   end if;

   if l_balance_value <> 0 then

      hr_utility.set_location('Archiving EMEA BALANCES', 20);

      pay_action_information_api.create_action_information
      (
         p_action_information_id       => l_action_info_id,
         p_action_context_id           => p_action_context_id,
         p_action_context_type         => 'AAP',
         p_object_version_number       => l_ovn,
         p_assignment_id               => p_assignment_id,
         p_effective_date              => p_effective_date,
         p_source_id                   => p_source_id,
         p_source_text                 => null,
         p_action_information_category => 'EMEA BALANCES',
         p_action_information1         => p_defined_bal_id,
         p_action_information2         => null,
         p_action_information3         => null,
         p_action_information4         => fnd_number.number_to_canonical(l_balance_value),
         p_action_information5         => l_record_count
      );

   end if;

   hr_utility.set_location('Leaving ' || l_proc, 30);

exception
   when no_data_found then
      null;

end process_balance;

procedure get_element_info
(
   p_action_context_id       in number,
   p_assignment_id           in number,
   p_child_assignment_action in number,
   p_effective_date          in date,
   p_record_count            in number,
   p_run_method              in varchar2
)  is

cursor csr_element_values
(
   p_assignment_action_id number,
   p_element_type_id      number,
   p_input_value_id       number
)  is
   select fnd_number.canonical_to_number(prv.result_value) result_value
   from   pay_run_result_values prv,
          pay_run_results       prr
   where  prr.status in ('P', 'PA')
   and    prv.run_result_id = prr.run_result_id
   and    prr.assignment_action_id = p_assignment_action_id
   and    prr.element_type_id = p_element_type_id
   and    prv.input_value_id = p_input_value_id
   and    prv.result_value is not null;


-- Added for NTG
-- It retrieves the sum of the run results of PAYE ER COntribution for the particula period
-- It sums up all the assignment actions which has source action id (master assignment action) the same
-- as that of the normal run
cursor csr_paye_er_contr_value
(
   p_assignment_action_id number,
   p_element_type_id      number,
   p_input_value_id       number
)  is
   select nvl(sum(fnd_number.canonical_to_number(prv.result_value)),0) result_value
   from   pay_run_result_values prv,
          pay_run_results       prr
   where  prr.status in ('P', 'PA')
   and    prv.run_result_id = prr.run_result_id
   and    prr.assignment_action_id in (select paa.assignment_action_id
                                       from pay_assignment_actions paa,
                                       pay_assignment_actions paa1
                                       where paa.source_action_id =paa1.source_action_id
                                       and paa1.assignment_action_id = p_assignment_action_id
                                       )
   and    prr.element_type_id = p_element_type_id
   and    prv.input_value_id = p_input_value_id;

--Added for NTG
--It retrieves the element type id of the Employer Contribution NTG element
cursor csr_paye_er_contr_ele_type_id
is
  select element_type_id
  from pay_element_types_f
  where element_name = 'ZA_Tax_PAYE_Employer_Contribution_NTG'
  and legislation_code='ZA'
  and p_effective_date between effective_start_date and effective_end_date;

l_column_sequence              number;
l_element_type_id              number;
l_main_sequence                number;
l_multi_sequence               number;
l_action_info_id               number;
l_ovn                          number;
l_record_count                 varchar2(10);

l_proc                         varchar2(50) ;
l_paye_er_contr                number;

begin

l_proc := g_package || 'get_element_info';
-- Removed default assignment to remove GSCC warning

   hr_utility.set_location('Entering ' || l_proc, 10);

   l_column_sequence := 0;
   l_element_type_id := 0;
   l_main_sequence   := 0;
   l_multi_sequence  := null;

   if p_record_count = 0 then

      l_record_count := null;

   else

      l_record_count := p_record_count + 1;

   end if;

   hr_utility.set_location('g_max_element_index = ' || g_max_element_index, 10);

   open csr_paye_er_contr_ele_type_id;
   fetch csr_paye_er_contr_ele_type_id into l_paye_er_contr;
   close csr_paye_er_contr_ele_type_id;

   for l_index in 1 .. g_max_element_index loop

      hr_utility.set_location('element_type_id = ' || g_element_table(l_index).element_type_id, 10);
      hr_utility.set_location('input_value_id = '  || g_element_table(l_index).input_value_id,  10);
      hr_utility.set_location('p_child_assignment_action = ' || p_child_assignment_action,      10);

      if (g_element_table(l_index).element_type_id <> l_paye_er_contr) then

              for rec_element_value in csr_element_values
                                       (
                                          p_child_assignment_action,
                                          g_element_table(l_index).element_type_id,
                                          g_element_table(l_index).input_value_id
                                       )

              loop

                 hr_utility.set_location('element_type_id = ' || g_element_table(l_index).element_type_id, 10);
                 hr_utility.set_location('input_value_id = '  || g_element_table(l_index).input_value_id,  10);
                 hr_utility.set_location('Archiving EMEA ELEMENT INFO', 20);

                 if l_element_type_id <> g_element_table(l_index).element_type_id then

                    l_main_sequence := l_main_sequence + 1;

                 end if;

                 hr_utility.set_location('l_main_sequence = ' || l_main_sequence, 20);

                 l_column_sequence := l_column_sequence + 1;

                 -- If the run method is P, Process Separate, then only archive the data if
                 -- a skip rule (formula_id) OR Once Each Period Flag has been set.
                 -- If there is no skip rule then the element info will be archived for
                 -- the normal assignment action and doesn't need to be archived twice.
                 -- If it is then duplicates will be displayed on the payslip.

                 /*if p_run_method = 'P' and g_element_table(l_index).formula_id is null then*/
                 --Added for Bug 4488264
                 /* Commented for Net to Gross NTG -Run types
                 if ((p_run_method = 'P' and g_element_table(l_index).formula_id is null)
                      OR
                    (p_run_method = 'P' and nvl(g_element_table(l_index).once_each_period_flag,'N') <> 'Y')) then

                    null;
                  */
                 if  (p_run_method = 'P' and
                    (g_element_table(l_index).formula_id is null AND nvl(g_element_table(l_index).once_each_period_flag,'N') <> 'Y')) then

                    hr_utility.set_location('Not archiving element',25);
                    null;

                  else

                    pay_action_information_api.create_action_information
                    (
                       p_action_information_id        => l_action_info_id,
                       p_action_context_id            => p_action_context_id,
                       p_action_context_type          => 'AAP',
                       p_object_version_number        => l_ovn,
                       p_assignment_id                => p_assignment_id,
                       p_effective_date               => p_effective_date,
                       p_source_id                    => p_child_assignment_action,
                       p_source_text                  => null,
                       p_action_information_category  => 'EMEA ELEMENT INFO',
                       p_action_information1          => g_element_table(l_index).element_type_id,
                       p_action_information2          => g_element_table(l_index).input_value_id,
                       p_action_information3          => null,
                       p_action_information4          => rec_element_value.result_value,
                       p_action_information5          => l_main_sequence,
                       p_action_information6          => l_multi_sequence,
                       p_action_information7          => l_column_sequence
                    );

                  end if;

                  l_multi_sequence := nvl(l_multi_sequence, 0) + 1;
                  l_element_type_id := g_element_table(l_index).element_type_id;

              end loop;

      elsif p_run_method = 'N' then

              for rec_paye_er_contr in csr_paye_er_contr_value
                                       (
                                          p_child_assignment_action,
                                          g_element_table(l_index).element_type_id,
                                          g_element_table(l_index).input_value_id
                                       )

              loop
                 hr_utility.set_location('Archiving Paye ER Contribution',30);
                 hr_utility.set_location('element_type_id = ' || g_element_table(l_index).element_type_id, 30);
                 hr_utility.set_location('input_value_id = '  || g_element_table(l_index).input_value_id,  30);
                 hr_utility.set_location('Archiving EMEA ELEMENT INFO', 30);

                 l_main_sequence := l_main_sequence + 1;

                 hr_utility.set_location('l_main_sequence = ' || l_main_sequence, 30);
                 hr_utility.set_location('rec_paye_er_contr.result_value ='||rec_paye_er_contr.result_value,30);

                 l_column_sequence := l_column_sequence + 1;

		 pay_action_information_api.create_action_information
                 (
                       p_action_information_id        => l_action_info_id,
                       p_action_context_id            => p_action_context_id,
                       p_action_context_type          => 'AAP',
                       p_object_version_number        => l_ovn,
                       p_assignment_id                => p_assignment_id,
                       p_effective_date               => p_effective_date,
                       p_source_id                    => p_child_assignment_action,
                       p_source_text                  => null,
                       p_action_information_category  => 'EMEA ELEMENT INFO',
                       p_action_information1          => g_element_table(l_index).element_type_id,
                       p_action_information2          => g_element_table(l_index).input_value_id,
                       p_action_information3          => null,
                       p_action_information4          => rec_paye_er_contr.result_value,
                       p_action_information5          => l_main_sequence,
                       p_action_information6          => l_multi_sequence,
                       p_action_information7          => l_column_sequence
                 );


                  l_multi_sequence := nvl(l_multi_sequence, 0) + 1;
                  l_element_type_id := g_element_table(l_index).element_type_id;

              end loop;

      end if;

      l_multi_sequence := null;

   end loop;

exception
   when no_data_found then
      null;

end get_element_info;

-- Public procedure which archives the payroll information, then returns a
-- varchar2 defining a SQL statement to select all the people that may be
-- eligible for payslip reports.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
-- This procedure gets called first to determine which person_id's to process
procedure range_cursor
(
   pactid in number,     -- Payroll Action of the Archiver
   sqlstr out nocopy varchar2
)  is

  -- Variables for constructing the sqlstr
  l_range_cursor              VARCHAR2(4000) := NULL;
  l_parameter_match           VARCHAR2(500)  := NULL;

  l_request_id                NUMBER;
  l_business_group_id         NUMBER;

  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'ZA'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;
  --
  -- Start of comment for Bug 4153551
  /*  This cursor to get payrolls based on a given consolidation set is
      is not consistent with other processes like prePayments and Cheque Writer etc.
  --
  -- New cursor for processing archive information by payroll
  CURSOR csr_payrolls (p_payroll_id           NUMBER,
                       p_consolidation_set_id NUMBER,
                       p_effective_date       DATE) IS
  SELECT ppf.payroll_id
  FROM   pay_all_payrolls_f ppf
  WHERE  ppf.consolidation_set_id = p_consolidation_set_id
  AND    ppf.payroll_id = NVL(p_payroll_id,ppf.payroll_id)
  AND    p_effective_date BETWEEN
          ppf.effective_start_date AND ppf.effective_end_date;
  --
  -- Emd of comment for Bug 4153551  */
  --
  -- Returns all prepayments for the specified parameters that has not been archived yet
  cursor csr_payroll_info
  (p_payroll_id       number
  ,p_consolidation_id number
  ,p_start_date       date
  ,p_end_date         date
  )  is
    select pact.payroll_action_id  payroll_action_id,   -- Payroll Action of Prepayments
           pact.effective_date     effective_date,      -- Effective Date of Prepayments
           pact.date_earned        date_earned,
           pact.payroll_id,
           ppf.payroll_name        payroll_name,
           ppf.period_type         period_type,
           pact.pay_advice_message payroll_message
    from   pay_payrolls_f              ppf,
           pay_payroll_actions         pact   -- Payroll Action of Prepayments
    where  pact.payroll_id = ppf.payroll_id
    and    pact.effective_date between ppf.effective_start_date and ppf.effective_end_date
    and    pact.payroll_id = nvl(p_payroll_id, pact.payroll_id)
    and    pact.consolidation_set_id = p_consolidation_id
    and    pact.effective_date between p_start_date and p_end_date
    and    (pact.action_type = 'P' or pact.action_type = 'U')
    and    pact.action_status = 'C'
    and    not exists
    (
      select null
      from   pay_action_information pai
      where  pai.action_context_id = pact.payroll_action_id   -- Payroll Action of Prepayments
      and    pai.action_context_type = 'PA'
      and    pai.action_information_category = 'EMEA PAYROLL INFO'
    );

-- Returns all the Pay Advice messages that have not been archived for the specificied
-- payroll and date range
-- FIX will not work for multiple payrolls (multiple payrolls possible?)
cursor csr_payroll_mesg
(
   p_payroll_id number,
   p_start_date date,
   p_end_date   date
)  is
   select pact.payroll_action_id  payroll_action_id,
          pact.effective_date     effective_date,
          pact.date_earned        date_earned,
          pact.pay_advice_message payroll_message
   from   pay_payrolls_f      ppf,
          pay_payroll_actions pact   -- Payroll Action of Run
   where  pact.payroll_id = ppf.payroll_id
   and    pact.effective_date between ppf.effective_start_date and ppf.effective_end_date
   and    pact.payroll_id = p_payroll_id
   and    pact.effective_date between p_start_date and p_end_date
   and    (pact.action_type = 'R' or pact.action_type = 'Q')
   and    pact.action_status = 'C'
   and    not exists
   (
      select null
      from   pay_action_information pai
      where  pai.action_context_id = pact.payroll_action_id   -- FIX can't user payroll action id of Run
      and    pai.action_context_type = 'PA'                   -- should be PA of archiver
      and    pai.action_information_category = 'EMPLOYEE OTHER INFORMATION'
   );

l_action_info_id                        number(15);
l_ovn                                   number(15);

l_payroll_id                            number;
l_consolidation_set                     number;
l_assignment_set_id                     number;
l_start_date                            varchar2(30);
l_end_date                              varchar2(30);
l_bg_id                                 number;
l_canonical_start_date                  date;
l_canonical_end_date                    date;

l_legislation_code                VARCHAR2(30) ;
l_tax_period_no                   VARCHAR2(30);


l_proc                         constant varchar2(50) := g_package || 'range_cursor';

begin
l_legislation_code := 'ZA';
-- Removed default assignment to remove GSCC warning
   --
   --hr_utility.trace_on(null, 'ZA_SOE');
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Retrieve the legislative parameters from the payroll action
   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'PAYROLL',
      p_token_value       => l_payroll_id
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'CONSOLIDATION',
      p_token_value       => l_consolidation_set
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'ASSIGNMENT_SET',
      p_token_value       => l_assignment_set_id
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'START_DATE',
      p_token_value       => l_start_date
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'END_DATE',
      p_token_value       => l_end_date
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'BG_ID',
      p_token_value       => l_bg_id
   );

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('l_payroll_id = ' || l_payroll_id, 20);
   hr_utility.set_location('l_start_date = ' || l_start_date, 20);
   hr_utility.set_location('l_end_date   = ' || l_end_date,   20);

   l_canonical_start_date := to_date(l_start_date, 'yyyy/mm/dd');
   l_canonical_end_date   := to_date(l_end_date,   'yyyy/mm/dd');

   -- Archive EMEA PAYROLL INFO for each prepayment run identified
   hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
   hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
   hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
   hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);
   --
   -- Loop through all the prepayments for the specified parameters that has not been archived yet
   for rec_payroll_info in csr_payroll_info
                           (l_payroll_id
                           ,l_consolidation_set
                           ,l_canonical_start_date
                           ,l_canonical_end_date)
   loop
      --
      g_max_user_balance_index := 0;
      --
      -- Retrieve and archive user balance definitions from EITs
      -- The definitions are archived again for each prepayment
      pay_za_payslip_archive.get_eit_definitions
      (
         p_pactid            => pactid,                                  -- Payroll Action of Archiver
         p_business_group_id => l_bg_id,
         p_payroll_pact      => rec_payroll_info.payroll_action_id,      -- Payroll Action of Prepayments
         p_effective_date    => rec_payroll_info.effective_date,         -- Effective Date of Prepayments
         p_eit_context       => g_balance_context,
         p_archive           => 'Y'
      );
      --
      -- This archives the element definitions on the Org Developer Flexfield
      pay_za_payslip_archive.get_eit_definitions
      (
         p_pactid            => pactid,                                  -- Payroll Action of Archiver
         p_business_group_id => l_bg_id,
         p_payroll_pact      => rec_payroll_info.payroll_action_id,      -- Payroll Action of Prepayments
         p_effective_date    => rec_payroll_info.effective_date,         -- Effective Date of Prepayments
         p_eit_context       => g_element_context,
         p_archive           => 'Y'
      );
      --
      -- This archives the element definitions for each Pay Advice Classification
      pay_za_payslip_archive.setup_element_definitions
      (
         p_pactid            => pactid,                                  -- Payroll Action of Archiver
         p_payroll_pact      => rec_payroll_info.payroll_action_id,      -- Payroll Action of Prepayments
         p_effective_date    => rec_payroll_info.effective_date          -- Effective Date of Prepayments
      );
    end loop; -- End loop rec_payroll_info
    --
    --
    -- Start of comment for Bug 4153551
    /* This cursor to get payrolls based on a given consolidation set is
             is not consistent with other processes like prePayments and Cheque Writer etc.

    FOR rec_payrolls in csr_payrolls(l_payroll_id
                                    ,l_consolidation_set
                                    ,l_canonical_end_date)
    LOOP
    -- Start Bug No 3436989 passing rec_payrolls.payroll_id parameter instead of l_payroll_id
      hr_utility.set_location('Calling arch_pay_action_level_data', 25);
      pay_emp_action_arch.arch_pay_action_level_data
      (p_payroll_action_id   => pactid
      ,p_payroll_id          => rec_payrolls.payroll_id -- l_payroll_id
      ,p_effective_date      => l_canonical_end_date
      );

      hr_utility.set_location('Calling arch_za_pay_action_level_data', 27);
      arch_za_pay_action_level_data
      (p_payroll_action_id   => pactid
      ,p_payroll_id          => rec_payrolls.payroll_id -- l_payroll_id
      ,p_effective_date      => l_canonical_end_date
      );
    -- End of 3436989
    END LOOP; -- End loop rec_payrolls
    --
    -- End of comment for Bug 4153551 */
    --
    --
    for rec_payroll_info in csr_payroll_info
                           (l_payroll_id
                           ,l_consolidation_set
                           ,l_canonical_start_date
                           ,l_canonical_end_date)
    loop
      --
      --
      -- Set the Payroll Action ID context to the Payroll Action of the current Prepayment
      -- Note: It takes the last value it gets set to
      -- FIX must be an error
      pay_balance_pkg.set_context
      (
         'PAYROLL_ACTION_ID',
         rec_payroll_info.payroll_action_id
      );
      --
      --
-- Added for Bug 4153551
      hr_utility.set_location('Calling arch_pay_action_level_data', 25);
      pay_emp_action_arch.arch_pay_action_level_data(
      p_payroll_action_id   => pactid
      ,p_payroll_id          => rec_payroll_info.payroll_id -- l_payroll_id (for bug 3436989)
      ,p_effective_date      => l_canonical_end_date
      );

      hr_utility.set_location('Calling arch_za_pay_action_level_data', 27);
      arch_za_pay_action_level_data(
      p_payroll_action_id   => pactid
      ,p_payroll_id          => rec_payroll_info.payroll_id -- l_payroll_id (for bug 3436989)
      ,p_effective_date      => l_canonical_end_date
      );
-- End Bug 4153551
      --
      --
      hr_utility.set_location('rec_payroll_info.payroll_action_id   = ' || rec_payroll_info.payroll_action_id, 30);
      --
      hr_utility.set_location('Archiving EMEA PAYROLL INFO', 30);
      --
      -- Archive the Payroll Info in 'EMEA PAYROLL INFO'
      -- Note: Actually information on Org DF Tax Details References
      pay_action_information_api.create_action_information
      (  p_action_information_id       => l_action_info_id
        ,p_action_context_id           => pactid
        ,p_action_context_type         => 'PA'
        ,p_object_version_number       => l_ovn
        ,p_effective_date              => rec_payroll_info.effective_date
        ,p_source_id                   => null
        ,p_source_text                 => null
        ,p_action_information_category => 'EMEA PAYROLL INFO'
        ,p_action_information1         => rec_payroll_info.payroll_action_id
        ,p_action_information2         => null
        ,p_action_information3         => null
        --,p_action_information4         => rec_payroll_info.tax_office_name
        --,p_action_information5         => rec_payroll_info.tax_office_phone_no
        --,p_action_information6         => rec_payroll_info.employers_ref_no
      );

      -- Loop through all the Pay Advice messages that have not been archived for the specificied
      -- payroll and date range
      -- EMPLOYEE OTHER INFORMATION
      --
      for rec_payroll_msg in csr_payroll_mesg
                             (
                                rec_payroll_info.payroll_id,
                                l_canonical_start_date,
                                l_canonical_end_date
                             )
      loop
         --Archive the Payroll message in 'EMPLOYEE OTHER INFORMATION'
         pay_action_information_api.create_action_information
         (
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => pactid,   -- Payroll Action ID of archiver
            p_action_context_type         => 'PA',
            p_object_version_number       => l_ovn,
            p_effective_date              => rec_payroll_msg.effective_date,
            p_source_id                   => null,
            p_source_text                 => null,
            p_action_information_category => 'EMPLOYEE OTHER INFORMATION',
            p_action_information1         => rec_payroll_msg.payroll_action_id,
            p_action_information2         => 'MESG',
            p_action_information3         => null,
            p_action_information4         => null,
            p_action_information5         => null,
            p_action_information6         => rec_payroll_msg.payroll_message
         );

      end loop;
   end loop;
   -- Populate the sqlstr to specify person_id's to process
   -- 3221746 modified business_group_id join condition
   sqlstr := 'select distinct person_id
              from   per_people_f        ppf,
                     pay_payroll_actions ppa
              where  ppa.payroll_action_id     = :payroll_action_id
              and    ppf.business_group_id  = ppa.business_group_id
              order  by ppf.person_id';

   hr_utility.set_location('Leaving ' || l_proc, 40);
--   hr_utility.trace_off;

   exception
   when others then
   sqlstr := null;

end range_cursor;

-- This procedure creates the assignment actions for a specific chunk.
-- This procedure gets called second to create the assignment actions.
-- The procedure gets called once for each person_id returned by the range_cursor.
procedure action_creation
(
   pactid    in number,   -- Payroll Action of Archiver
   stperson  in number,
   endperson in number,
   chunk     in number
)  is

-- Returns all runs and prepayments that have not already been locked by
-- an Payslip Archive process
-- 3221746 added ORDERED hint
cursor csr_prepaid_assignments
(
   p_pact_id          number,   -- Payroll Action of Archiver
   stperson           number,
   endperson          number,
   p_payroll_id       number,
   p_consolidation_id number
)  is
   select paa_run.assignment_id        assignment_id,
          paa_run.assignment_action_id run_action_id,
          paa_pre.assignment_action_id prepaid_action_id
   from   pay_payroll_actions    ppa_pre,   -- Payroll Action of Prepayment
          pay_assignment_actions paa_pre,   -- Assignment Action of Prepayment
          pay_action_interlocks  pai,
          per_all_assignments_f  paaf,
          pay_assignment_actions paa_run,   -- Assignment Action of Run
          pay_payroll_actions    ppa_run,   -- Payroll Action of Run
          pay_payroll_actions    ppa_arch   -- Payroll Action of Archiver
   where  ppa_arch.payroll_action_id = p_pact_id
   and    ppa_run.action_type in ('R', 'Q')                             -- Payroll Run or Quickpay Run
   and    (ppa_run.payroll_id = p_payroll_id or p_payroll_id is null)
   and    ppa_run.effective_date between ppa_arch.start_date and ppa_arch.effective_date
   and    ppa_run.business_group_id = ppa_arch.business_group_id
   and    paa_run.payroll_action_id = ppa_run.payroll_action_id
   and    paa_run.source_action_id is null
   and    paa_run.action_status = 'C'
   and    paaf.assignment_id = paa_run.assignment_id
   and    ppa_arch.effective_date between paaf.effective_start_date and paaf.effective_end_date
   and    paaf.person_id between stperson and endperson
   and    (paaf.payroll_id = p_payroll_id or p_payroll_id is null)
   and    pai.locked_action_id = paa_run.assignment_action_id
   and    paa_pre.assignment_action_id = pai.locking_action_id
   and    paa_pre.action_status = 'C'
   and    ppa_pre.payroll_action_id = paa_pre.payroll_action_id
   and    ppa_pre.action_type in ('P', 'U')                            -- Prepayments or Quickpay Prepayments
   and    ppa_pre.consolidation_set_id = p_consolidation_id
   and    not exists   -- You can comment this to make the Archive rerunable
   (
      select /*+ ORDERED */ NULL
      from   pay_action_interlocks  pai2,
             pay_assignment_actions paa_arch2,   -- Assignment Action of Archiver
             pay_payroll_actions    ppa_arch2    -- Payroll Action of Archiver
      where  pai2.locked_action_id = paa_run.assignment_action_id
      and    paa_arch2.assignment_action_id = pai2.locking_action_id
      and    paa_arch2.payroll_action_id = ppa_arch2.payroll_action_id
      and    ppa_arch2.action_type = 'X'
      and    ppa_arch2.report_type = 'ZA_SOE'
   )
   order  by paa_run.assignment_id
   for update of paaf.assignment_id;

cursor csr_get_tax_unit_id (p_assignment_id number) is
  select paei.aei_information7
  from   per_assignment_extra_info paei
  where  paei.assignment_id = p_assignment_id
  and    paei.information_type = 'ZA_SPECIFIC_INFO';

l_payroll_id                   number;
l_consolidation_set            varchar2(30);
l_start_date                   varchar2(20);
l_end_date                     varchar2(20);
l_canonical_start_date         date;
l_canonical_end_date           date;
l_actid                        number;
l_prepay_action_id             number;
l_tax_unit_id                  number;

l_proc                         varchar2(50);

begin

l_proc  := g_package || 'action_creation';
-- Removed default assignment to remove GSCC warning
   --hr_utility.trace_on(null, 'ZA_SOE');
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Retrieve the legislative parameters from the payroll action
   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,        -- Payroll Action of the Archiver
      p_token_name        => 'PAYROLL',
      p_token_value       => l_payroll_id
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,        -- Payroll Action of the Archiver
      p_token_name        => 'CONSOLIDATION',
      p_token_value       => l_consolidation_set
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,        -- Payroll Action of the Archiver
      p_token_name        => 'START_DATE',
      p_token_value       => l_start_date
   );

   pay_za_payslip_archive.get_parameters
   (
      p_payroll_action_id => pactid,        -- Payroll Action of the Archiver
      p_token_name        => 'END_DATE',
      p_token_value       => l_end_date
   );

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('l_payroll_id = ' || l_payroll_id, 20);
   hr_utility.set_location('l_start_date = ' || l_start_date, 20);
   hr_utility.set_location('l_end_date   = ' || l_end_date,   20);
   hr_utility.set_location('pactid       = ' || pactid,       20);

   l_canonical_start_date := to_date(l_start_date, 'yyyy/mm/dd');
   l_canonical_end_date   := to_date(l_end_date,   'yyyy/mm/dd');

   l_prepay_action_id := 0;

   -- Loop through all runs and prepayments that have not already been locked by
   -- an Payslip Archive process
   hr_utility.set_location('csr_prepaid_assignments info', 99);
   hr_utility.set_location('pactid = '||pactid, 99);
   hr_utility.set_location('stperson = '||stperson, 99);
   hr_utility.set_location('endperson = '||endperson, 99);
   hr_utility.set_location('l_payroll_id = '||l_payroll_id, 99);
   hr_utility.set_location('l_consolidation_set = '||l_consolidation_set, 99);
   for csr_rec in csr_prepaid_assignments
                  (
                     pactid,
                     stperson,
                     endperson,
                     l_payroll_id,
                     l_consolidation_set
                  )
   loop

      if l_prepay_action_id <> csr_rec.prepaid_action_id then

         -- Select the next Assignment Action ID
         select pay_assignment_actions_s.nextval
         into   l_actid
         from   dual;

         -- retrieve the tax_unit_id
         l_tax_unit_id := null;

         open csr_get_tax_unit_id(csr_rec.assignment_id);

         fetch csr_get_tax_unit_id into l_tax_unit_id;

         close csr_get_tax_unit_id;

         -- Create the archive assignment action for the master assignment action
         hr_nonrun_asact.insact(l_actid, csr_rec.assignment_id, pactid, chunk, l_tax_unit_id);

         -- Create the archive to payroll master assignment action interlock and
         -- the archive to prepayment assignment action interlock
         hr_utility.set_location('creating lock for assignment_id ' || csr_rec.assignment_id,         20);
         hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,     20);
         hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id, 20);

         hr_nonrun_asact.insint(l_actid, csr_rec.prepaid_action_id);

      end if;

      hr_nonrun_asact.insint(l_actid, csr_rec.run_action_id);
      l_prepay_action_id := csr_rec.prepaid_action_id;

   end loop;

   hr_utility.set_location('Leaving ' || l_proc, 20);

end action_creation;

-- This procedure gets called fourth to archive each assignment action.
-- The procedure gets called once for each assignment action.
procedure archive_code
(
   p_assactid       in number,   -- Assignment Action of Archiver
   p_effective_date in date
)  is

-- Returns all the Prepayments and Runs for the current Archiver Assignment Action
-- This only returns master assignment actions, since the source_action_id is null
cursor csr_assignment_actions(p_locking_action_id number) is
   select pre.locked_action_id     pre_assignment_action_id,      -- Assignment Action of Prepayments
          pay.locked_action_id     master_assignment_action_id,   -- Assignment Action of Run
          assact.assignment_id     assignment_id,
          assact.payroll_action_id pay_payroll_action_id,         -- Payroll Action of Run
          paa.effective_date       effective_date,                -- Effective Date of Run
          ppaa.effective_date      pre_effective_date,            -- Effective Date of Archive
          paa.date_earned          date_earned,                   -- Date Earned of Run
          paa.time_period_id       time_period_id                 -- Time Period Id of Run
   from   pay_action_interlocks  pre,      -- Lock of Archiver on Prepayment
          pay_action_interlocks  pay,      -- Lock of Prepayment on Run
          pay_payroll_actions    paa,      -- Payroll Action of Run
          pay_payroll_actions    ppaa,     -- Payroll Action of Archiver
          pay_assignment_actions assact,   -- Assignment Action of Run
          pay_assignment_actions passact   -- Assignment Action of Archiver
   where  pre.locked_action_id = pay.locking_action_id
   and    pre.locking_action_id = p_locking_action_id   -- Assignment Action of Archiver
   and    pre.locked_action_id = passact.assignment_action_id
   and    passact.payroll_action_id = ppaa.payroll_action_id
   and    ppaa.action_type in ('P', 'U')
   and    pay.locked_action_id = assact.assignment_action_id
   and    assact.payroll_action_id = paa.payroll_action_id
   and    assact.source_action_id is NULL;


-- Returns the assignment_action_id of any child runs
-- The assignment_action_id with the maximum action_sequence is returned for N and P run types
-- FIX Could use Edwin trick
cursor csr_child_actions
(
   p_master_assignment_action number,   -- Assignment Action of Master Run
   p_payroll_action_id        number,   -- Payroll Action of Master Run
   p_assignment_id            number,
   p_effective_date           date
)  is
   select paa.assignment_action_id child_assignment_action_id,
          'S' run_type   -- Separate Payment Run
   from   pay_assignment_actions paa,   -- Assignment Action of Child Run
          pay_run_types_f        prt
   where  paa.source_action_id  = p_master_assignment_action   -- Assignment Action of Master Run
   and    paa.payroll_action_id = p_payroll_action_id          -- Payroll Action of Master Run
   and    paa.assignment_id = p_assignment_id
   and    paa.run_type_id = prt.run_type_id
   and    prt.run_method = 'S'
   and    p_effective_date between prt.effective_start_date and prt.effective_end_date
   union
   select paa.assignment_action_id child_assignment_action_id,
          'NP' run_type   -- Standard Run, Process Separate Run
   from   pay_assignment_actions paa
   where  paa.payroll_action_id = p_payroll_action_id
   and    paa.assignment_id = p_assignment_id
   and    paa.action_sequence =
   (
      select max(paa1.action_sequence)
      from   pay_assignment_actions paa1,
             pay_run_types_f        prt1
      where  prt1.run_type_id = paa1.run_type_id
      and    prt1.run_method in ('N', 'P')
      and    paa1.payroll_action_id = p_payroll_action_id         -- Payroll Action of Master Run
      and    paa1.assignment_id = p_assignment_id
      and    paa1.source_action_id = p_master_assignment_action   -- Assignment Action of Master Run
      and    p_effective_date between prt1.effective_start_date and prt1.effective_end_date
   );

cursor csr_np_children
(
   p_assignment_action_id number,
   p_payroll_action_id    number,
   p_assignment_id        number,
   p_effective_date       date
)  is
   select paa.assignment_action_id np_assignment_action_id,
          prt.run_method
   from   pay_assignment_actions   paa,
          pay_run_types_f          prt
   where  paa.source_action_id = p_assignment_action_id
   and    paa.payroll_action_id = p_payroll_action_id
   and    paa.assignment_id = p_assignment_id
   and    paa.run_type_id = prt.run_type_id
   and    prt.run_method in ('N','P')
   and    p_effective_date between prt.effective_start_date and prt.effective_end_date;

csr_child_rec    csr_child_actions%rowtype;
l_actid                        number;
l_action_context_id            number;
l_action_info_id               number(15);
l_assignment_action_id         number;
l_business_group_id            number;
l_chunk_number                 number;
l_date_earned                  date;
l_ovn                          number;
l_person_id                    number;
l_record_count                 number;
l_salary                       varchar2(10);
l_sequence                     number;

l_proc                         varchar2(50) ;

l_pre_assignment_action_id    number;

-- 3693941 added the l_pre_assignment_action_id variable.
begin

l_proc := g_package || 'archive_code';



-- Removed default assignment to remove GSCC warning
   -- hr_utility.trace_on(null, 'ZA_SOE');
   hr_utility.set_location('Entering '|| l_proc, 10);

   hr_utility.set_location('Step '|| l_proc, 20);
   hr_utility.set_location('p_assactid = ' || p_assactid, 20);

   -- Retrieve the chunk number for the current assignment action
   select paa.chunk_number
   into   l_chunk_number
   from   pay_assignment_actions paa
   where  paa.assignment_action_id = p_assactid;

   l_action_context_id := p_assactid;   --Assignment Action of Archiver

   l_record_count := 0;

l_pre_assignment_action_id := 0;
-- 3693941 initialise the l_pre_assignment_action_id variable.
   -- Loop through all the Prepayments and Runs for the current Archiver Assignment Action
   for csr_rec in csr_assignment_actions(p_assactid) loop

      hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.master_assignment_action_id, 20);
      hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' || csr_rec.pre_assignment_action_id,    20);
      hr_utility.set_location('csr_rec.assignment_id    = ' || csr_rec.assignment_id,20);
      hr_utility.set_location('csr_rec.date_earned    = ' ||to_char( csr_rec.date_earned,'dd-mon-yyyy'),20);
      hr_utility.set_location('csr_rec.pre_effective_date    = ' ||to_char( csr_rec.pre_effective_date,'dd-mon-yyyy'),20);
      hr_utility.set_location('csr_rec.time_period_id    = ' || csr_rec.time_period_id,20);

      if l_record_count = 0 then

         hr_utility.set_location(' record_count = 0 , starting archive_employee_details' , 23);

         -- Archive the Employee Details in 'EMPLOYEE DETAILS', 'ADDRESS DETAILS',
         -- 'EMPLOYEE NET PAY DISTRIBUTION' and 'ZA EMPLOYEE DETAILS'
         pay_za_payslip_archive.archive_employee_details
         (
            p_assactid             => p_assactid,
            p_assignment_id        => csr_rec.assignment_id,
            p_curr_pymt_ass_act_id => csr_rec.pre_assignment_action_id,   -- prepayment assignment_action_id
            p_date_earned          => csr_rec.date_earned,                -- payroll date_earned
            p_curr_pymt_eff_date   => csr_rec.pre_effective_date,         -- prepayment effective_date
            p_time_period_id       => csr_rec.time_period_id              -- payroll time_period_id
         );

         hr_utility.set_location(' out of archive_employee_details ' , 25);

      end if;

      --Start changes for Multiple Run Types
      --Net to Gross NTG

    /*****************************************************************
    ** This returns all the Child Actions for a given master
    ** assignment action. There will not be any issue in this case if
    ** there are multiple runs for a pre payment as we calling it
    ** for the master run action.
    *****************************************************************/
    OPEN csr_child_actions(
                             csr_rec.master_assignment_action_id,
                             csr_rec.pay_payroll_action_id,
                             csr_rec.assignment_id,
                             csr_rec.effective_date);

    LOOP
       fetch csr_child_actions into csr_child_rec;
       /* If child run types doesnt exist i.e. Payroll was run before enabling of run types then archive
          element info for the master assignment action id  (i.e. the only assignment action for the run) */
       if csr_child_actions%rowcount=0 then
             pay_za_payslip_archive.get_element_info
            (
                p_action_context_id       => l_action_context_id,
                p_assignment_id           => csr_rec.assignment_id,
                p_child_assignment_action => csr_rec.master_assignment_action_id,
                p_effective_date          => csr_rec.pre_effective_date,
                p_record_count            => l_record_count,
                p_run_method              => 'N'
            );
	    exit;
       end if;

       exit when csr_child_actions%notfound;

       -- create additional archive assignment actions and interlocks
       SELECT pay_assignment_actions_s.NEXTVAL
       INTO   l_actid
       FROM dual;

       hr_utility.set_location('csr_child_rec.run_type              = ' ||
                                csr_child_rec.run_type,30);
       hr_utility.set_location('csr_rec.master_assignment_action_id = ' ||
                                csr_rec.master_assignment_action_id,30);

       hr_nonrun_asact.insact(
           lockingactid => l_actid
          ,assignid     => csr_rec.assignment_id
          ,pactid       => g_archive_pact
          ,chunk        => l_chunk_number
          ,greid        => NULL
          ,prepayid     => NULL
          ,status       => 'C'
          ,source_act   => p_assactid);

       IF csr_child_rec.run_type = 'S' THEN
          hr_utility.set_location('creating lock3 ' || l_actid || ' to ' ||
                                   csr_child_rec.child_assignment_action_id,30);

          hr_nonrun_asact.insint(
             lockingactid => l_actid
            ,lockedactid  => csr_child_rec.child_assignment_action_id);

          l_action_context_id := l_actid;

          pay_za_payslip_archive.get_element_info (
            p_action_context_id       => l_action_context_id
          , p_assignment_id           => csr_rec.assignment_id
          , p_child_assignment_action => csr_child_rec.child_assignment_action_id
          , p_effective_date          => csr_rec.effective_date
          , p_record_count            => l_record_count
          , p_run_method              => 'S');

       END IF;

       IF csr_child_rec.run_type = 'NP' THEN
        --  l_child_count := 0;
          FOR csr_np_rec IN csr_np_children(
                                    csr_rec.master_assignment_action_id,
                                    csr_rec.pay_payroll_action_id,
                                    csr_rec.assignment_id,
                                    csr_rec.effective_date)
          LOOP
             hr_utility.set_location('creating lock4 ' || l_actid || ' to ' ||
                                      csr_np_rec.np_assignment_action_id,30);

             hr_nonrun_asact.insint(
               lockingactid => l_actid
              ,lockedactid  => csr_np_rec.np_assignment_action_id);

             pay_za_payslip_archive.get_element_info (
               p_action_context_id       => l_action_context_id
              ,p_assignment_id           => csr_rec.assignment_id
              ,p_child_assignment_action => csr_np_rec.np_assignment_action_id
              ,p_effective_date          => csr_rec.effective_date
              ,p_record_count            => l_record_count
              ,p_run_method              => csr_np_rec.run_method);

         --     l_child_count := l_child_count + 1;

          END LOOP;
       END IF;
   END LOOP;
   CLOSE csr_child_actions;

       --End changes for Multiple Run TYpes
       --Net to Gross NTG

/* Commented for Net to Gross
      pay_za_payslip_archive.get_element_info
      (
         p_action_context_id       => l_action_context_id,
         p_assignment_id           => csr_rec.assignment_id,
         p_child_assignment_action => csr_rec.master_assignment_action_id,
         p_effective_date          => csr_rec.pre_effective_date,
         p_record_count            => l_record_count,
         p_run_method              => 'N'
      );
End for Net to Gross*/

-- Added if condition for the bug 3693941
      if l_pre_assignment_action_id <>  csr_rec.pre_assignment_action_id then
         -- Both User and Statutory Balances are archived for all Separate Payment assignment actions
         -- and the last (i.e. highest action_sequence) Process Separately assignment action
         -- (EMEA BALANCES)

         -- Archive user balances
         hr_utility.set_location('l_pre_assignment_action_id = '|| l_pre_assignment_action_id, 60);

         l_pre_assignment_action_id :=  csr_rec.pre_assignment_action_id;

         hr_utility.set_location('Archive User Balances - Starting', 60);
         hr_utility.set_location('g_max_user_balance_index = '|| g_max_user_balance_index, 60);
         hr_utility.set_location('l_pre_assignment_action_id = '|| l_pre_assignment_action_id, 60);

         for l_index in 1..g_max_user_balance_index loop
-- Bug 5507715
            pay_za_payslip_archive.process_balance
            (
               p_action_context_id => l_action_context_id,
               p_assignment_id     => csr_rec.assignment_id,
               p_source_id         => csr_rec.master_assignment_action_id, --csr_rec.pre_assignment_action_id, --
               p_effective_date    => csr_rec.pre_effective_date,
               p_balance           => g_user_balance_table(l_index).balance_name,
               p_dimension         => g_user_balance_table(l_index).database_item_suffix,
               p_defined_bal_id    => g_user_balance_table(l_index).defined_balance_id,
               p_record_count      => l_record_count
            );/*
           IF g_user_balance_table(l_index).database_item_suffix = '_ASG_RUN' or
              g_user_balance_table(l_index).database_item_suffix = '_ASG_TAX_PTD' then
                    pay_za_payslip_archive.process_balance
                    (
                       p_action_context_id => l_action_context_id,
                       p_assignment_id     => csr_rec.assignment_id,
                       p_source_id         => csr_rec.master_assignment_action_id,
                       p_effective_date    => csr_rec.pre_effective_date,
                       p_balance           => g_user_balance_table(l_index).balance_name,
                       p_dimension         => g_user_balance_table(l_index).database_item_suffix,
                       p_defined_bal_id    => g_user_balance_table(l_index).defined_balance_id,
                       p_record_count      => l_record_count
                    );
            else
                    pay_za_payslip_archive.process_balance
                    (
                       p_action_context_id => l_action_context_id,
                       p_assignment_id     => csr_rec.assignment_id,
                       p_source_id         => csr_rec.pre_assignment_action_id, --csr_rec.master_assignment_action_id,
                       p_effective_date    => csr_rec.pre_effective_date,
                       p_balance           => g_user_balance_table(l_index).balance_name,
                       p_dimension         => g_user_balance_table(l_index).database_item_suffix,
                       p_defined_bal_id    => g_user_balance_table(l_index).defined_balance_id,
                       p_record_count      => l_record_count
                    );
           END if;*/

         end loop;

         hr_utility.set_location('Archive User Balances - Complete', 60);

         -- Archive statutory balances
         hr_utility.set_location('Archive Statutory Balances - Starting', 70);
         hr_utility.set_location('g_max_statutory_balance_index = '|| g_max_statutory_balance_index, 70);

         for l_index in 1..g_max_statutory_balance_index loop

            hr_utility.set_location('l_index = ' || l_index, 70);
--5507715
          pay_za_payslip_archive.process_balance
            (
               p_action_context_id => l_action_context_id,
               p_assignment_id     => csr_rec.assignment_id,
               p_source_id         => csr_rec.master_assignment_action_id,--csr_rec.pre_assignment_action_id, --
               p_effective_date    => csr_rec.pre_effective_date,
               p_balance           => g_statutory_balance_table(l_index).balance_name,
               p_dimension         => g_statutory_balance_table(l_index).database_item_suffix,
               p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id,
               p_record_count      => l_record_count
            ); /*
            IF g_statutory_balance_table(l_index).database_item_suffix = '_ASG_RUN' or
              g_statutory_balance_table(l_index).database_item_suffix = '_ASG_TAX_PTD' then

                    pay_za_payslip_archive.process_balance
                    (
                       p_action_context_id => l_action_context_id,
                       p_assignment_id     => csr_rec.assignment_id,
                       p_source_id         => csr_rec.master_assignment_action_id,
                       p_effective_date    => csr_rec.pre_effective_date,
                       p_balance           => g_statutory_balance_table(l_index).balance_name,
                       p_dimension         => g_statutory_balance_table(l_index).database_item_suffix,
                       p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id,
                       p_record_count      => l_record_count
                    );
            else
                    pay_za_payslip_archive.process_balance
                    (
                       p_action_context_id => l_action_context_id,
                       p_assignment_id     => csr_rec.assignment_id,
                       p_source_id         => csr_rec.pre_assignment_action_id, --csr_rec.master_assignment_action_id,
                       p_effective_date    => csr_rec.pre_effective_date,
                       p_balance           => g_statutory_balance_table(l_index).balance_name,
                       p_dimension         => g_statutory_balance_table(l_index).database_item_suffix,
                       p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id,
                       p_record_count      => l_record_count
                    );
           END if;*/
         end loop;
      end if;
-- and passed the csr_rec.pre_assignment_action_id instead of master_assignment_action_id
-- End of if condition for the bug 3693941
      hr_utility.set_location('Archive Statutory Balances - Complete', 70);

      l_record_count := l_record_count + 1;

   end loop;

   hr_utility.set_location('Leaving '|| l_proc, 80);

end archive_code;
end;

/
