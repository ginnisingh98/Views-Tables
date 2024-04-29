--------------------------------------------------------
--  DDL for Package Body PAY_GB_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_PAYSLIP_ARCHIVE" AS
/* $Header: pygbparc.pkb 120.5.12010000.5 2008/12/16 13:32:53 krreddy ship $ */

TYPE balance_rec IS RECORD (
  balance_type_id      NUMBER,
  balance_dimension_id NUMBER,
  defined_balance_id   NUMBER,
  --Bug Number 3526619
  balance_narrative    VARCHAR2(80),
  balance_name         VARCHAR2(80),
  database_item_suffix VARCHAR2(30),
  legislation_code     VARCHAR2(20),
  ni_type_ind          VARCHAR2(1));

TYPE element_rec IS RECORD (
  element_type_id      NUMBER,
  input_value_id       NUMBER,
  formula_id           NUMBER,
  --Bug Number 3526619
  element_narrative    VARCHAR2(80),
  uom                  VARCHAR2(30));

TYPE ni_total_rec IS RECORD (
  balance_name         VARCHAR2(30),
  category             VARCHAR2(1));

TYPE balance_table   IS TABLE OF balance_rec   INDEX BY BINARY_INTEGER;
TYPE element_table   IS TABLE OF element_rec   INDEX BY BINARY_INTEGER;
TYPE ni_total_table  IS TABLE OF ni_total_rec  INDEX BY BINARY_INTEGER;

g_user_balance_table              balance_table;
g_element_table                   element_table;
g_statutory_balance_table         balance_table;
g_ni_totals_table                 ni_total_table;

g_balance_archive_index           NUMBER := 0;
g_element_archive_index           NUMBER := 0;
g_max_element_index               NUMBER := 0;
g_max_user_balance_index          NUMBER := 0;
g_max_statutory_balance_index     NUMBER := 0;

g_ni_element_id                   NUMBER;
g_paye_details_element_id         NUMBER;
g_paye_element_id                 NUMBER;
g_paye_previous_pay_archived      VARCHAR2(1);
g_paye_previous_pay_id            NUMBER;
g_paye_previous_tax_archived      VARCHAR2(1);
g_paye_previous_tax_id            NUMBER;

g_ni_cat_id                       NUMBER;
g_paye_tax_basis_id               NUMBER;
g_paye_tax_code_id                NUMBER;
g_tax_basis_id                    NUMBER;
g_tax_code_id                     NUMBER;

g_package                CONSTANT VARCHAR2(30) := 'pay_gb_payslip_archive.';

g_balance_context        CONSTANT VARCHAR2(30) := 'GB_PAYSLIP_BALANCES';
g_element_context        CONSTANT VARCHAR2(30) := 'GB_PAYSLIP_ELEMENTS';

g_archive_pact                    NUMBER;
g_archive_effective_date          DATE;

PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT NOCOPY VARCHAR2) IS

CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token))),
       business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_business_group_id               VARCHAR2(20);
l_token_value                     VARCHAR2(50);

l_proc                            VARCHAR2(50) := g_package || 'get_parameters';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('p_token_name = ' || p_token_name,20);

  OPEN csr_parameter_info(p_payroll_action_id,
                          p_token_name);

  FETCH csr_parameter_info INTO l_token_value,
                                l_business_group_id;

  CLOSE csr_parameter_info;

  IF p_token_name = 'BG_ID'

  THEN

     p_token_value := l_business_group_id;

  ELSE

     p_token_value := l_token_value;

  END IF;

  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || l_proc,30);

END get_parameters;

PROCEDURE get_eit_definitions(p_pactid            IN NUMBER,
                              p_business_group_id IN NUMBER,
                              p_payroll_pact      IN NUMBER,
                              p_effective_date    IN DATE,
                              p_eit_context       IN VARCHAR2,
                              p_archive           IN VARCHAR2) IS

CURSOR csr_eit_values(p_bg_id   NUMBER,
                      p_context CHAR) IS
SELECT org.org_information1,
       org.org_information2,
       org.org_information3,
       org.org_information4,
       org.org_information5,
       org.org_information6
FROM   hr_organization_information_v org
WHERE  org.org_information_context = p_context
AND    org.organization_id = p_bg_id;

CURSOR csr_balance_name(p_balance_type_id      NUMBER,
                        p_balance_dimension_id NUMBER) IS
SELECT pbt.balance_name,
       pbd.database_item_suffix,
       pbt.legislation_code,
       pdb.defined_balance_id
FROM   pay_balance_types pbt,
       pay_balance_dimensions pbd,
       pay_defined_balances pdb
WHERE  pdb.balance_type_id = pbt.balance_type_id
AND    pdb.balance_dimension_id = pbd.balance_dimension_id
AND    pbt.balance_type_id = p_balance_type_id
AND    pbd.balance_dimension_id = p_balance_dimension_id;

CURSOR csr_element_type(p_element_type_id NUMBER,
                        p_effective_date  DATE) IS
SELECT pet.formula_id
FROM   pay_element_types_f pet,
       ff_formulas_f fff
WHERE  pet.element_type_id = p_element_type_id
AND    pet.formula_id = fff.formula_id
AND    fff.formula_name = 'ONCE_EACH_PERIOD'
AND    p_effective_date BETWEEN
         fff.effective_start_date AND fff.effective_end_date
AND    p_effective_date BETWEEN
         pet.effective_start_date AND pet.effective_end_date;

CURSOR csr_input_value_uom(p_input_value_id NUMBER,
                           p_effective_date DATE) IS
SELECT piv.uom
FROM   pay_input_values_f piv
WHERE  piv.input_value_id = p_input_value_id
AND    p_effective_date BETWEEN
         piv.effective_start_date AND piv.effective_end_date;

l_action_info_id                  NUMBER(15);
l_formula_id                      NUMBER(9);
l_index                           NUMBER     := 1;
l_ovn                             NUMBER(15);
l_uom                             VARCHAR(30);

l_proc                            VARCHAR2(50) := g_package || 'get_eit_definitions';

BEGIN

  hr_utility.set_location('Entering        ' || l_proc,10);

  hr_utility.set_location('Step            ' || l_proc,20);
  hr_utility.set_location('p_eit_context = ' || p_eit_context,20);

  FOR csr_eit_rec IN csr_eit_values(p_business_group_id,
                                    p_eit_context)

  LOOP

    hr_utility.set_location('Step ' || l_proc,30);

    hr_utility.set_location('org_information1 = ' || csr_eit_rec.org_information1,30);
    hr_utility.set_location('org_information2 = ' || csr_eit_rec.org_information2,30);
    hr_utility.set_location('org_information3 = ' || csr_eit_rec.org_information3,30);
    hr_utility.set_location('org_information4 = ' || csr_eit_rec.org_information4,30);
    hr_utility.set_location('org_information5 = ' || csr_eit_rec.org_information5,30);
    hr_utility.set_location('org_information6 = ' || csr_eit_rec.org_information6,30);

    IF p_eit_context = g_balance_context

    THEN

      g_user_balance_table(l_index).balance_type_id      := SUBSTR(csr_eit_rec.org_information1,2);

      g_user_balance_table(l_index).balance_dimension_id := csr_eit_rec.org_information2;

      g_user_balance_table(l_index).balance_narrative    := csr_eit_rec.org_information3;


      OPEN csr_balance_name(g_user_balance_table(l_index).balance_type_id,
                            g_user_balance_table(l_index).balance_dimension_id);

      FETCH csr_balance_name
      INTO  g_user_balance_table(l_index).balance_name,
            g_user_balance_table(l_index).database_item_suffix,
            g_user_balance_table(l_index).legislation_code,
            g_user_balance_table(l_index).defined_balance_id;

      CLOSE csr_balance_name;

      -- If the balance name is NI Employer it is processed
      -- differently. This type of balance is identified here and
      -- given an n_type_ind of E.

      -- If the balance name is NI Employee or if the balance name
      -- starts with NI and doesnt have a space as the 5th character
      -- then it is a total of all categories for that particular balance.
      -- This type of balance is identified here and given an
      -- n_type_ind of T.

      hr_utility.set_location('g_user_balance_table(l_index).balance_name = ' ||
                               g_user_balance_table(l_index).balance_name,50);

      IF  g_user_balance_table(l_index).balance_name = 'NI Employer'

      THEN

        g_user_balance_table(l_index).ni_type_ind := 'E';

      ELSIF (g_user_balance_table(l_index).balance_name = 'NI Employee' OR
             SUBSTR(csr_eit_rec.org_information1,1,1) = 2)

      THEN

        g_user_balance_table(l_index).ni_type_ind := 'T';

      ELSE

        g_user_balance_table(l_index).ni_type_ind := ' ';

      END IF;

      hr_utility.set_location('Arch EMEA BALANCE DEFINITION',99);

      IF p_archive = 'Y'

      THEN

      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_pactid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'EMEA BALANCE DEFINITION'
      , p_action_information1          =>  p_payroll_pact
      , p_action_information2          =>  g_user_balance_table(l_index).defined_balance_id
      , p_action_information3          =>  NULL
      , p_action_information4          =>  csr_eit_rec.org_information3
      , p_action_information5          =>  g_user_balance_table(l_index).ni_type_ind);

      END IF;

      g_max_user_balance_index := g_max_user_balance_index + 1;

    END IF;

    IF p_eit_context = g_element_context

    THEN

     g_element_table(l_index).element_type_id   := csr_eit_rec.org_information1;

     g_element_table(l_index).input_value_id    := csr_eit_rec.org_information2;

     g_element_table(l_index).element_narrative := csr_eit_rec.org_information3;

     l_formula_id := NULL;

     OPEN csr_element_type(csr_eit_rec.org_information1,
                           p_effective_date);

     FETCH csr_element_type INTO l_formula_id;

     CLOSE csr_element_type;

     g_element_table(l_index).formula_id := l_formula_id;

     l_uom := NULL;

     OPEN csr_input_value_uom(csr_eit_rec.org_information2,
                              p_effective_date);

     FETCH csr_input_value_uom INTO l_uom;

     CLOSE csr_input_value_uom;

     g_element_table(l_index).uom := l_uom;

     IF p_archive = 'Y'

     THEN

       hr_utility.set_location('Arch EMEA ELEMENT DEFINITION',99);

       pay_action_information_api.create_action_information (
         p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_pactid
       , p_action_context_type          =>  'PA'
       , p_object_version_number        =>  l_ovn
       , p_effective_date               =>  p_effective_date
       , p_source_id                    =>  NULL
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'EMEA ELEMENT DEFINITION'
       , p_action_information1          =>  p_payroll_pact
       , p_action_information2          =>  csr_eit_rec.org_information1
       , p_action_information3          =>  csr_eit_rec.org_information2
       , p_action_information4          =>  csr_eit_rec.org_information3
       , p_action_information5          =>  'F'
       , p_action_information6          =>  l_uom);

     END IF;

    END IF;

    l_index := l_index + 1;

    hr_utility.set_location('l_index = ' || l_index,99);

  END LOOP;

  g_max_element_index := l_index;

  IF p_eit_context = g_balance_context

  THEN

    g_balance_archive_index := l_index - 1;

  ELSE

    g_element_archive_index := l_index - 1;

  END IF;

  hr_utility.set_location('g_balance_archive_index = ' || g_balance_archive_index,99);

  hr_utility.set_location('Leaving ' || l_proc,30);

END get_eit_definitions;

PROCEDURE setup_element_definitions (p_pactid            IN NUMBER,
                                     p_payroll_pact      IN NUMBER,
                                     p_business_group_id IN NUMBER,
                                     p_effective_date    IN DATE)
IS

l_action_info_id   NUMBER(15);
l_ovn              NUMBER(15);
l_payment_type     VARCHAR2(1);

CURSOR csr_element_name (p_business_group_id NUMBER,
                         p_effective_date    DATE) IS
SELECT pet.element_type_id,
       piv.input_value_id,
       NVL(pet.reporting_name,pet.element_name) element_name,
       pec.classification_name,
       piv.uom
FROM   pay_element_classifications pec,
       pay_input_values_f piv,
       pay_element_types_f pet
WHERE  pec.classification_name IN ('Court Orders','Voluntary Deductions','Pre Tax Deductions',
                                   'PAYE','NI','Earnings','Direct Payment','Pre NI Deductions','Pre Tax and NI Deductions')
AND    pec.business_group_id IS NULL
AND    pec.legislation_code = 'GB'
AND    pet.classification_id = pec.classification_id
AND    NVL(pet.business_group_id,p_business_group_id) = p_business_group_id
AND    piv.element_type_id = pet.element_type_id
AND    piv.name = 'Pay Value'
AND    p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND    p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date;

l_proc VARCHAR2(60) := g_package || 'setup_element_definitions';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('p_payroll_pact = ' || p_payroll_pact,10);

  FOR csr_element_rec IN csr_element_name(p_business_group_id,
                                          p_effective_date)

  LOOP

     hr_utility.set_location('csr_element_rec.element_type_id = ' || csr_element_rec.element_type_id,20);
     hr_utility.set_location('csr_element_rec.element_name    = ' || csr_element_rec.element_name,20);

     IF csr_element_rec.classification_name = 'Earnings'

     THEN

       l_payment_type := 'E';

     ELSIF csr_element_rec.classification_name = 'Direct Payment'

     THEN

       l_payment_type := 'P';

     ELSE

       l_payment_type := 'D';

     END IF;

     hr_utility.set_location('Arch EMEA ELEMENT DEFINITION',99);

     pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  p_pactid
     , p_action_context_type          =>  'PA'
     , p_object_version_number        =>  l_ovn
     , p_effective_date               =>  p_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'EMEA ELEMENT DEFINITION'
     , p_action_information1          =>  p_payroll_pact
     , p_action_information2          =>  csr_element_rec.element_type_id
     , p_action_information3          =>  csr_element_rec.input_value_id
     , p_action_information4          =>  csr_element_rec.element_name
     , p_action_information5          =>  l_payment_type
     , p_action_information6          =>  csr_element_rec.uom);

  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,30);

END setup_element_definitions;

PROCEDURE setup_standard_balance_table
IS

TYPE balance_name_rec IS RECORD (
  balance_name VARCHAR2(30));

TYPE balance_id_rec IS RECORD (
  defined_balance_id NUMBER);

TYPE balance_name_tab IS TABLE OF balance_name_rec INDEX BY BINARY_INTEGER;
TYPE balance_id_tab   IS TABLE OF balance_id_rec   INDEX BY BINARY_INTEGER;

l_statutory_balance balance_name_tab;
l_statutory_bal_id  balance_id_tab;

CURSOR csr_balance_dimension(p_balance   IN CHAR,
                             p_dimension IN CHAR) IS
SELECT pdb.defined_balance_id
FROM   pay_balance_types pbt,
       pay_balance_dimensions pbd,
       pay_defined_balances pdb
WHERE  pdb.balance_type_id = pbt.balance_type_id
AND    pdb.balance_dimension_id = pbd.balance_dimension_id
AND    pbt.balance_name = p_balance
AND    pbd.database_item_suffix = p_dimension;

l_archive_index                   NUMBER       := 0;
l_dimension                       VARCHAR2(12) := '_ASG_TD_YTD';
l_found                           VARCHAR2(1);
l_max_stat_balance                NUMBER       := 13;

l_proc                            VARCHAR2(100) := g_package || 'setup_standard_balance_table';


BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);

  l_statutory_balance(1).balance_name  := 'Gross Pay';
  l_statutory_balance(2).balance_name  := 'Notional Pay';
  l_statutory_balance(3).balance_name  := 'Taxable Pay';
  l_statutory_balance(4).balance_name  := 'NIable Pay';
  l_statutory_balance(5).balance_name  := 'SSP Total';
  l_statutory_balance(6).balance_name  := 'SMP Total';
  l_statutory_balance(7).balance_name  := 'Tax Credit';
  l_statutory_balance(8).balance_name  := 'PAYE';
  l_statutory_balance(9).balance_name  := 'NI Employer';
  l_statutory_balance(10).balance_name := 'NI Ees Rebate';
  l_statutory_balance(11).balance_name := 'NI Ers Rebate';
  l_statutory_balance(12).balance_name := 'Student Loan';
  l_statutory_balance(13).balance_name := 'Superannuation Total';

  hr_utility.set_location('Step = ' || l_proc,30);

  FOR l_index IN 1 .. l_max_stat_balance

  LOOP

    hr_utility.set_location('l_index      = ' || l_index,30);
    hr_utility.set_location('balance_name = ' || l_statutory_balance(l_index).balance_name,30);
    hr_utility.set_location('l_dimension  = ' || l_dimension,30);

    OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,
                               l_dimension);

    FETCH csr_balance_dimension
    INTO  l_statutory_bal_id(l_index).defined_balance_id;

    IF csr_balance_dimension%NOTFOUND

    THEN

      l_statutory_bal_id(l_index).defined_balance_id := 0;

    END IF;

    CLOSE csr_balance_dimension;

    hr_utility.set_location('defined_balance_id = ' || l_statutory_bal_id(l_index).defined_balance_id,30);

  END LOOP;

  hr_utility.set_location('Step = ' || l_proc,40);

  hr_utility.set_location('l_max_stat_balance       = ' || l_max_stat_balance,40);
  hr_utility.set_location('g_max_user_balance_index = ' || g_max_user_balance_index,40);

  FOR l_index IN 1 .. l_max_stat_balance

  LOOP

    l_found := 'N';

    FOR l_eit_index IN 1 .. g_max_user_balance_index

    LOOP

      hr_utility.set_location('l_index            = ' || l_index,40);
      hr_utility.set_location('l_eit_index        = ' || l_eit_index,40);
      hr_utility.set_location('defined_balance_id = ' || l_statutory_bal_id(l_index).defined_balance_id,40);
      hr_utility.set_location('l_found            = ' || l_found,40);

      IF l_statutory_bal_id(l_index).defined_balance_id = g_user_balance_table(l_eit_index).defined_balance_id

      THEN

        l_found := 'Y';

      END IF;

    END LOOP;

    IF l_found = 'N'

    THEN

       hr_utility.set_location('l_archive_index = ' || l_archive_index,40);

       l_archive_index := l_archive_index + 1;

       g_statutory_balance_table(l_archive_index).defined_balance_id := l_statutory_bal_id(l_index).defined_balance_id;

       g_statutory_balance_table(l_archive_index).ni_type_ind := ' ';

    END IF;

  END LOOP;

  g_max_statutory_balance_index := l_archive_index;

  hr_utility.set_location('Step ' || l_proc,50);
  hr_utility.set_location('l_archive_index = ' || l_archive_index,50);

  hr_utility.set_location('Leaving ' || l_proc,60);

END setup_standard_balance_table;

PROCEDURE archinit (p_payroll_action_id IN NUMBER)
IS

  CURSOR csr_archive_effective_date(pactid NUMBER) IS
  SELECT effective_date
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = pactid;

  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'GB'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

  l_proc                            VARCHAR2(50) := g_package || 'archinit';

  l_assignment_set_id               NUMBER;
  l_bg_id                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               NUMBER;
  l_end_date                        VARCHAR2(30);
  l_payroll_id                      NUMBER;
  l_start_date                      VARCHAR2(30);

BEGIN

 -- hr_utility.trace_on(NULL,'UKPS0');

  hr_utility.set_location('Entering ' || l_proc,10);

  g_archive_pact := p_payroll_action_id;

  OPEN csr_archive_effective_date(p_payroll_action_id);

  FETCH csr_archive_effective_date
  INTO  g_archive_effective_date;

  CLOSE csr_archive_effective_date;

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'ASSIGNMENT_SET'
  , p_token_value       => l_assignment_set_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
  hr_utility.set_location('l_start_date = ' || l_start_date,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  -- retrieve ids for NI and tax elements

  OPEN csr_input_value_id('NI','Category');

  FETCH csr_input_value_id INTO g_ni_element_id,
                                g_ni_cat_id;

  CLOSE csr_input_value_id;

  OPEN csr_input_value_id('PAYE Details','Tax Code');

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_tax_code_id;

  CLOSE csr_input_value_id;


  OPEN csr_input_value_id('PAYE Details','Tax Basis');

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_tax_basis_id;

  CLOSE csr_input_value_id;

  OPEN csr_input_value_id('PAYE','Tax Code');

  FETCH csr_input_value_id INTO g_paye_element_id,
                                g_paye_tax_code_id;

  CLOSE csr_input_value_id;


  OPEN csr_input_value_id('PAYE','Tax Basis');

  FETCH csr_input_value_id INTO g_paye_element_id,
                                g_paye_tax_basis_id;

  CLOSE csr_input_value_id;

  hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
  hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
  hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);

  -- retrieve and archive user defintions from EITs

  g_max_user_balance_index := 0;

  hr_utility.set_location('get_eit_definitions - balances',20);

  pay_gb_payslip_archive.get_eit_definitions (
    p_pactid            => p_payroll_action_id
  , p_business_group_id => l_bg_id
  , p_payroll_pact      => NULL
  , p_effective_date    => l_canonical_start_date
  , p_eit_context       => g_balance_context
  , p_archive           => 'N');

  hr_utility.set_location('get_eit_definitions - elements',20);

  pay_gb_payslip_archive.get_eit_definitions (
    p_pactid            => p_payroll_action_id
  , p_business_group_id => l_bg_id
  , p_payroll_pact      => NULL
  , p_effective_date    => l_canonical_start_date
  , p_eit_context       => g_element_context
  , p_archive           => 'N');

  pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                             , p_payroll_action_id);

  -- setup statutory balances pl/sql table

  pay_gb_payslip_archive.setup_standard_balance_table;

  hr_utility.set_location('Leaving ' || l_proc,20);

END archinit;

PROCEDURE archive_employee_details (
  p_assactid             IN NUMBER
, p_assignment_id        IN NUMBER
, p_curr_pymt_ass_act_id IN NUMBER
, p_effective_date       IN DATE
, p_date_earned          IN DATE
, p_curr_pymt_eff_date   IN DATE
, p_time_period_id       IN NUMBER
, p_record_count         IN NUMBER) IS

l_action_info_id NUMBER;
l_ovn            NUMBER;

l_proc           VARCHAR2(50) := g_package || 'archive_employee_details';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  -- call generic procedure to retrieve and archive all data for
  -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION

  hr_utility.set_location('Calling pay_emp_action_arch',20);

  pay_emp_action_arch.get_personal_information (
    p_payroll_action_id    => g_archive_pact            -- archive payroll_action_id
  , p_assactid             => p_assactid                -- archive assignment_action_id
  , p_assignment_id        => p_assignment_id           -- current assignment_id
  , p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id    -- prepayment assignment_action_id
  , p_curr_eff_date        => g_archive_effective_date  -- archive effective_date
  , p_date_earned          => p_date_earned             -- payroll date_earned
  , p_curr_pymt_eff_date   => p_curr_pymt_eff_date      -- prepayment effective_date
  , p_tax_unit_id          => NULL                      -- only required for US
  , p_time_period_id       => p_time_period_id          -- payroll time_period_id
  , p_ppp_source_action_id => NULL);

  hr_utility.set_location('Returned from pay_emp_action_arch',30);

END archive_employee_details;

PROCEDURE archive_gb_employee_details (
  p_assactid             IN NUMBER
, p_assignment_id        IN NUMBER
, p_curr_pymt_ass_act_id IN NUMBER
, p_effective_date       IN DATE) IS

l_action_info_id NUMBER;
l_ni_cat         VARCHAR2(10);
l_ovn            NUMBER;
l_tax_basis      VARCHAR2(10);
l_tax_basis_det  VARCHAR2(20);
l_tax_code       VARCHAR2(10);

l_proc           VARCHAR2(60) := g_package || 'archive_gb_employee_details';

BEGIN

  -- Retrieve and Archive the GB specific employee details

  l_ni_cat    := pay_gb_payroll_actions_pkg.get_tax_details (
                   p_run_assignment_action_id => p_curr_pymt_ass_act_id
                 , p_input_value_id           => g_ni_cat_id
                 , p_paye_input_value_id      => g_ni_cat_id
                 , p_date_earned              => to_char(p_effective_date,'yyyy/mm/dd'));

  l_tax_code  := pay_gb_payroll_actions_pkg.get_tax_details (
                   p_run_assignment_action_id => p_curr_pymt_ass_act_id
                 , p_input_value_id           => g_tax_code_id
                 , p_paye_input_value_id      => g_paye_tax_code_id
                 , p_date_earned              => to_char(p_effective_date,'yyyy/mm/dd'));

  hr_utility.set_location('l_tax_code = ' || l_tax_code,40);

  l_tax_basis := pay_gb_payroll_actions_pkg.get_tax_details (
                   p_run_assignment_action_id => p_curr_pymt_ass_act_id
                 , p_input_value_id           => g_tax_basis_id
                 , p_paye_input_value_id      => g_paye_tax_basis_id
                 , p_date_earned              => to_char(p_effective_date,'yyyy/mm/dd'));

  hr_utility.set_location('l_tax_basis = ' || l_tax_basis,40);

  IF l_tax_basis = 'C'

  THEN

    l_tax_basis_det := 'Cumulative';

  ELSIF l_tax_basis = 'N'

  THEN

    l_tax_basis_det := 'Non Cumulative';

  ELSE

    l_tax_basis_det := l_tax_basis;

  END IF;

  hr_utility.set_location('Archiving GB EMPLOYEE DETAILS',50);

  pay_action_information_api.create_action_information (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_assactid
  , p_action_context_type          =>  'AAP'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  p_assignment_id
  , p_effective_date               =>  g_archive_effective_date
  , p_source_id                    =>  NULL
  , p_source_text                  =>  NULL
  , p_action_information_category  =>  'GB EMPLOYEE DETAILS'
  , p_action_information1          =>  NULL
  , p_action_information2          =>  NULL
  , p_action_information3          =>  NULL
  , p_action_information21         =>  l_tax_code
  , p_action_information22         =>  l_tax_basis_det
  , p_action_information23         =>  l_ni_cat);

END archive_gb_employee_details;

FUNCTION process_employer_balance (
  p_assignment_action_id IN NUMBER,
  p_balance_dimension    IN VARCHAR2)
  RETURN NUMBER

-- This function calculates the NI Employer YTD balance, which is not
-- forced to be the latest balance in the NI formula. The following
-- formula is used instead :
--   NI_x_EMPLOYER = NI_x_TOTAL - NI_x_EMPLOYEE + NI_C_EMPLOYER + NI_S_EMPLOYER
--
-- The function pay_gb_payroll_actions_pkg.report_employer_balance does the
-- same thing, but uses globals which are not calculated if the function is
-- called directly so it cannot be called from this package.

IS

l_tax_district_ytd VARCHAR2(11) := '_ASG_TD_YTD';
l_temp             NUMBER;
l_total            NUMBER;

BEGIN

  g_ni_totals_table(1).balance_name := 'NI A Total';
  g_ni_totals_table(2).balance_name := 'NI B Total';
  g_ni_totals_table(3).balance_name := 'NI D Total';
  g_ni_totals_table(4).balance_name := 'NI E Total';
  g_ni_totals_table(5).balance_name := 'NI F Total';
  g_ni_totals_table(6).balance_name := 'NI G Total';

  g_ni_totals_table(1).category     := 'A';
  g_ni_totals_table(2).category     := 'B';
  g_ni_totals_table(3).category     := 'D';
  g_ni_totals_table(4).category     := 'E';
  g_ni_totals_table(5).category     := 'F';
  g_ni_totals_table(6).category     := 'G';

  l_temp  := 0;
  l_total := 0;

  FOR l_index IN 1..6

  LOOP

    IF hr_gbbal.ni_category_exists_in_year (p_assignment_action_id,
                                            g_ni_totals_table(l_index).category) = 1

    THEN

      l_temp := pay_gb_payroll_actions_pkg.report_balance_items (
                  p_balance_name         => g_ni_totals_table(l_index).balance_name
                , p_dimension            => p_balance_dimension
                , p_assignment_action_id => p_assignment_action_id);

      l_total := l_total + l_temp;

    END IF;

  END LOOP;

  l_temp := pay_gb_payroll_actions_pkg.report_all_ni_balance (
              p_balance_name         => 'NI Employee'
            , p_dimension            => p_balance_dimension
            , p_assignment_action_id => p_assignment_action_id);

  l_total := l_total - l_temp;

  l_temp := pay_gb_payroll_actions_pkg.report_balance_items (
              p_balance_name         => 'NI C Employer'
            , p_dimension            => p_balance_dimension
            , p_assignment_action_id => p_assignment_action_id);

  l_total := l_total + l_temp;

  l_temp := pay_gb_payroll_actions_pkg.report_balance_items (
              p_balance_name         => 'NI S Employer'
            , p_dimension            => p_balance_dimension
            , p_assignment_action_id => p_assignment_action_id);

  l_total := l_total + l_temp;

  return l_total;

END process_employer_balance;

PROCEDURE process_balance (p_action_context_id IN NUMBER,
                           p_assignment_id     IN NUMBER,
                           p_source_id         IN NUMBER,
                           p_effective_date    IN DATE,
                           p_balance           IN VARCHAR2,
                           p_dimension         IN VARCHAR2,
                           p_defined_bal_id    IN NUMBER,
                           p_ni_type           IN VARCHAR2,
                           p_record_count      IN NUMBER)

IS

--Bug 5172062
CURSOR csr_context_values(p_assig_action_id NUMBER, p_context_name varchar2
                     ) IS
    SELECT pac.context_id           context_id
          ,pac.context_value        context_value
	  ,ff.context_name          context_name
    FROM   ff_contexts              ff
          ,pay_action_contexts      pac
    WHERE  ff.context_name          = p_context_name
    AND    pac.context_id           = ff.context_id
    AND    pac.assignment_Action_id = p_assig_action_id;
    --

CURSOR csr_get_reference(p_element_entry_id NUMBER
                        ,p_effective_date DATE
			,p_assig_action_id NUMBER)
IS
SELECT prrv.result_value reference
FROM   pay_element_entries_f peef
      ,pay_run_results prr
      ,pay_run_result_values prrv
      ,pay_input_values_f  piv
WHERE  peef.element_entry_id = p_element_entry_id
and    piv.name ='Reference'
and    piv.legislation_code='GB'
and    peef.element_type_id = piv.element_type_id
and    peef.element_type_id = prr.element_type_id
and    peef.element_entry_id = prr.element_entry_id
and    prr.assignment_action_id =p_assig_action_id
and    prr.run_result_id = prrv.run_result_id
and    prrv.input_value_id = piv.input_value_id
and    p_effective_date between
		peef.effective_start_date and peef.effective_end_date
and    p_effective_date between
		piv.effective_start_date and piv.effective_end_date;


CURSOR csr_get_agg_info(p_assignment_id IN NUMBER)
IS
SELECT per_information10
FROM   per_all_people_f ppf,
       per_all_assignments_f paf
WHERE  paf.assignment_id = p_assignment_id
and    ppf.person_id = paf.person_id
and    p_effective_date between
		paf.effective_start_date and paf.effective_end_date
and    p_effective_date between
		ppf.effective_start_date and ppf.effective_end_date;



l_action_info_id                 NUMBER;
l_balance_value                  NUMBER;
l_ni_balance                     VARCHAR2(80);
l_ovn                            NUMBER;
l_record_count                   VARCHAR2(10);
l_context                        VARCHAR2(100);
l_agg_flag		         VARCHAR2(1);


l_proc                           VARCHAR2(50) := g_package || 'process_balance';

v_context_rec csr_context_values%ROWTYPE;
v_csr_reference csr_get_reference%ROWTYPE;

BEGIN

  --hr_utility.trace_on(null, 'PARC');

  hr_utility.set_location('Entering ' || l_proc,10);

OPEN csr_get_agg_info(p_assignment_id);
FETCH csr_get_agg_info into l_agg_flag;
CLOSE csr_get_agg_info;

IF  (p_dimension LIKE '%ELEMENT_ITD%' or p_dimension LIKE '%ELEMENT_PTD%') or
    (p_dimension LIKE '%PER_CO_TD_REF_ITD%' or p_dimension LIKE '%PER_CO_TD_REF_PTD%') then

  IF p_record_count = 0 THEN

    l_record_count := NULL;

  ELSE
    l_record_count := p_record_count + 1;

  END IF;


    IF  p_dimension LIKE '%ELEMENT_ITD%' or p_dimension LIKE '%ELEMENT_PTD%'  then

		 OPEN csr_context_values(p_source_id,'ORIGINAL_ENTRY_ID');
		 LOOP
		 FETCH csr_context_values into v_context_rec;
		 exit when csr_context_values%notfound;

		 l_balance_value := 0;

		 IF v_context_rec.context_name IS NOT NULL AND v_context_rec.context_value IS NOT NULL THEN

		      pay_balance_pkg.set_context(v_context_rec.context_name, v_context_rec.context_value);

		      l_balance_value := pay_balance_pkg.get_value(p_defined_bal_id, p_source_id);


			 OPEN  csr_get_reference(v_context_rec.context_value,p_effective_date,p_source_id);
			 FETCH csr_get_reference into v_csr_reference;

			 if v_csr_reference.reference ='Unknown' then
			    v_csr_reference.reference := null;
			 end if;


			 IF l_balance_value <> 0 and  nvl(l_agg_flag,'N')='N' then

				pay_action_information_api.create_action_information (
				 p_action_information_id        => l_action_info_id
				,p_action_context_id            => p_action_context_id
				,p_action_context_type          => 'AAP'
				,p_object_version_number        => l_ovn
				,p_assignment_id                => p_assignment_id
				,p_effective_date               => p_effective_date
				,p_source_id                    => p_source_id
				,p_source_text                  => NULL
				,p_action_information_category  => 'EMEA BALANCES'
				,p_action_information1          => p_defined_bal_id
				,p_action_information2          => v_csr_reference.reference  -- Context value
				,p_action_information3          => NULL
				,p_action_information4          => fnd_number.number_to_canonical(l_balance_value)
				,p_action_information5          => l_record_count
				,p_action_information6          => v_context_rec.context_value);
			   END IF;

			 close csr_get_reference;
		END IF;
		END LOOP;
		CLOSE csr_context_values;
    END IF;

  IF p_dimension LIKE '%PER_CO_TD_REF_ITD%' or p_dimension LIKE '%PER_CO_TD_REF_PTD%' THEN


         OPEN csr_context_values(p_source_id,'SOURCE_TEXT');
	 LOOP
	 FETCH csr_context_values into v_context_rec;
         exit when csr_context_values%notfound;

	  l_balance_value := 0;
	  IF v_context_rec.context_name IS NOT NULL AND v_context_rec.context_value IS NOT NULL THEN

              pay_balance_pkg.set_context(v_context_rec.context_name, v_context_rec.context_value);
	      l_balance_value := pay_balance_pkg.get_value(p_defined_bal_id, p_source_id);

	       if v_context_rec.context_value ='Unknown' then
		   v_context_rec.context_value := null;
	       end if;

	      IF l_balance_value <> 0  and  nvl(l_agg_flag,'N') = 'Y'  then

			pay_action_information_api.create_action_information (
			 p_action_information_id        => l_action_info_id
			,p_action_context_id            => p_action_context_id
			,p_action_context_type          => 'AAP'
			,p_object_version_number        => l_ovn
			,p_assignment_id                => p_assignment_id
			,p_effective_date               => p_effective_date
			,p_source_id                    => p_source_id
			,p_source_text                  => NULL
			,p_action_information_category  => 'EMEA BALANCES'
			,p_action_information1          => p_defined_bal_id
			,p_action_information2          => v_context_rec.context_value  -- Context value
			,p_action_information3          => NULL
			,p_action_information4          => fnd_number.number_to_canonical(l_balance_value)
			,p_action_information5          => l_record_count );
	     END IF;
        END IF;
       END LOOP;
       CLOSE csr_context_values;
  END IF;
-- end of court order context sensitive balances

ELSE
  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('p_source_id      = ' || p_source_id,20);
  hr_utility.set_location('p_balance        = ' || p_balance,20);
  hr_utility.set_location('p_dimension      = ' || p_dimension,20);
  hr_utility.set_location('p_defined_bal_id = ' || p_defined_bal_id,20);
  hr_utility.set_location('ni_type          = ' || nvl(p_ni_type,'NULL'),20);

  IF p_ni_type = ' '

  THEN

    l_balance_value := pay_balance_pkg.get_value (
                         p_defined_balance_id   => p_defined_bal_id
                       , p_assignment_action_id => p_source_id);

  ELSIF p_ni_type = 'T'

  THEN

    l_ni_balance := SUBSTR(p_balance,1,3) || SUBSTR(p_balance,6);

    hr_utility.set_location('l_ni_balance = ' || l_ni_balance,20);

    l_balance_value := pay_gb_payroll_actions_pkg.report_all_ni_balance (
                         p_balance_name         => l_ni_balance
                       , p_assignment_action_id => p_source_id
                       , p_dimension            => p_dimension);

  ELSE

    l_balance_value := pay_gb_payslip_archive.process_employer_balance (
                         p_assignment_action_id => p_source_id
                        ,p_balance_dimension    => p_dimension);

  END IF;

  hr_utility.set_location('l_balance_value = ' || l_balance_value,20);

  IF p_record_count = 0

  THEN

    l_record_count := NULL;

  ELSE

    l_record_count := p_record_count + 1;
--    l_record_count := '  (' || l_record_count || ')';

  END IF;

  IF l_balance_value <> 0

  THEN

    hr_utility.set_location('Archiving EMEA BALANCES',20);

    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_action_context_id
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  p_assignment_id
    , p_effective_date               =>  p_effective_date
    , p_source_id                    =>  p_source_id
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'EMEA BALANCES'
    , p_action_information1          =>  p_defined_bal_id
    , p_action_information2          =>  NULL
    , p_action_information3          =>  NULL
    , p_action_information4          =>  fnd_number.number_to_canonical(l_balance_value)
    , p_action_information5          =>  l_record_count);

  END IF;
 END IF;

  hr_utility.set_location('Leaving ' || l_proc,30);

EXCEPTION

  WHEN NO_DATA_FOUND

  THEN

    NULL;

END process_balance;

PROCEDURE get_element_info (p_action_context_id       IN NUMBER,
                            p_assignment_id           IN NUMBER,
                            p_child_assignment_action IN NUMBER,
                            p_effective_date          IN DATE,
                            p_record_count            IN NUMBER,
                            p_run_method              IN VARCHAR2)
IS

CURSOR csr_element_values (p_assignment_action_id NUMBER,
                           p_element_type_id      NUMBER,
                           p_input_value_id       NUMBER) IS
SELECT prv.result_value
FROM   pay_run_result_values prv,
       pay_run_results prr
WHERE  prr.status IN ('P','PA')
AND    prv.run_result_id = prr.run_result_id
AND    prr.assignment_action_id = p_assignment_action_id
AND    prr.element_type_id = p_element_type_id
AND    prv.input_value_id = p_input_value_id
AND    prv.result_value IS NOT NULL;

l_action_info_id  NUMBER;
l_column_sequence NUMBER;
l_element_type_id NUMBER;
l_main_sequence   NUMBER;
l_multi_sequence  NUMBER;
l_ovn             NUMBER;
l_record_count    VARCHAR2(10);
l_result_value    pay_run_result_values.result_value%TYPE;

BEGIN

  hr_utility.set_location('Entering get_element_info',10);

  l_column_sequence := 0;
  l_element_type_id := 0;
  l_main_sequence   := 0;
  l_multi_sequence  := NULL;

  IF p_record_count = 0

  THEN

    l_record_count := NULL;

  ELSE

    l_record_count := p_record_count + 1;

  END IF;

  hr_utility.set_location('g_max_element_index = ' || g_max_element_index,10);

  FOR l_index IN 1 .. g_max_element_index

  LOOP

    hr_utility.set_location('element_type_id = ' || g_element_table(l_index).element_type_id,10);
    hr_utility.set_location('input_value_id = '  || g_element_table(l_index).input_value_id,10);
    hr_utility.set_location('p_child_assignment_action = ' || p_child_assignment_action,10);

    FOR rec_element_value IN csr_element_values (
                               p_child_assignment_action
                             , g_element_table(l_index).element_type_id
                             , g_element_table(l_index).input_value_id)

    LOOP

      hr_utility.set_location('element_type_id = ' || g_element_table(l_index).element_type_id,10);
      hr_utility.set_location('input_value_id = '  || g_element_table(l_index).input_value_id,10);
      hr_utility.set_location('Archiving EMEA ELEMENT INFO',20);

      hr_utility.set_location('l_element_type_id = ' || l_element_type_id,20);
      hr_utility.set_location('g_element_table.element_type_id = ' || g_element_table(l_index).element_type_id,20);


      IF l_element_type_id <> g_element_table(l_index).element_type_id

      THEN

        l_main_sequence := l_main_sequence + 1;

      END IF;

      hr_utility.set_location('l_main_sequence = ' || l_main_sequence,20);

      l_column_sequence := l_column_sequence + 1;

      -- If the run method is P, Process Separate, then only archive the data if
      -- a skip rule (formula_id) has been set. If there is no skip rule then the
      -- element info will be archived for the normal assignment action and doesn't
      -- need to be archived twice. If it is then duplicates will be displayed on
      -- the payslip.

      IF p_run_method = 'P' AND g_element_table(l_index).formula_id IS NULL

      THEN

        NULL;

      ELSE
         SELECT decode(g_element_table(l_index).uom, 'M',
                      ltrim(rtrim(to_char(fnd_number.canonical_to_number(rec_element_value.result_value), '999999999999999990.00'))),
                      rec_element_value.result_value)
         INTO l_result_value
         FROM dual;
        --
        pay_action_information_api.create_action_information (
          p_action_information_id        => l_action_info_id
        , p_action_context_id            => p_action_context_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => l_ovn
        , p_assignment_id                => p_assignment_id
        , p_effective_date               => p_effective_date
        , p_source_id                    => p_child_assignment_action
        , p_source_text                  => NULL
        , p_action_information_category  => 'EMEA ELEMENT INFO'
        , p_action_information1          => g_element_table(l_index).element_type_id
        , p_action_information2          => g_element_table(l_index).input_value_id
        , p_action_information3          => NULL
        , p_action_information4          => l_result_value
        , p_action_information5          => l_main_sequence
        , p_action_information6          => l_multi_sequence
        , p_action_information7          => l_column_sequence
        , p_action_information8          => l_record_count);

      END IF;

      l_multi_sequence := NVL(l_multi_sequence,0) + 1;
      l_element_type_id := g_element_table(l_index).element_type_id;

    END LOOP;

    l_multi_sequence := NULL;

  END LOOP;

EXCEPTION

  WHEN NO_DATA_FOUND

  THEN

    NULL;

END get_element_info;

PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2)
-- public procedure which archives the payroll information, then returns a
-- varchar2 defining a SQL statement to select all the people that may be
-- eligible for payslip reports.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
IS
  --
  l_proc    CONSTANT VARCHAR2(50):= g_package||'range_cursor';
  -- vars for constructing the sqlstr
  l_range_cursor              VARCHAR2(4000) := NULL;
  l_parameter_match           VARCHAR2(500)  := NULL;
  l_ovn                       NUMBER(15);
  l_request_id                NUMBER;
  l_action_info_id            NUMBER(15);
  l_business_group_id         NUMBER;

  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'GB'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

/* 4071160 - This cursor to get payrolls based on a given consolidation set is
             is not consistent with other processes like prePayments and Cheque Writer etc.
  CURSOR csr_payrolls (p_payroll_id           NUMBER,
                       p_consolidation_set_id NUMBER,
                       p_effective_date       DATE) IS
  SELECT ppf.payroll_id
  FROM   pay_all_payrolls_f ppf
  WHERE  ppf.consolidation_set_id = p_consolidation_set_id
  AND    ppf.payroll_id = NVL(p_payroll_id,ppf.payroll_id)
  AND    p_effective_date BETWEEN
          ppf.effective_start_date AND ppf.effective_end_date;
4071160 */


--Commented for Bug fix 5209228
 /* CURSOR csr_payroll_info(p_payroll_id       NUMBER,
                          p_consolidation_id NUMBER,
                          p_start_date       DATE,
                          p_end_date         DATE) IS
  SELECT pact.payroll_action_id payroll_action_id,
         pact.effective_date effective_date,
         pact.date_earned date_earned,
         pact.payroll_id,
         org.org_information1 employers_ref_no,
         org.org_information2 tax_office_name,
         org.org_information3 employer_name,
         org.org_information4 employer_address,
         org.org_information8 tax_office_phone_no,
         ppf.payroll_name payroll_name,
         ppf.period_type period_type,
         pact.pay_advice_message payroll_message
  FROM   pay_payrolls_f ppf,
         pay_payroll_actions pact,
         hr_soft_coding_keyflex flex,
         hr_organization_information org
  WHERE  ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
  AND    org.org_information_context = 'Tax Details References'
  AND    org.org_information1 = flex.segment1
  AND    ppf.business_group_id = org.organization_id
  AND    pact.payroll_id = ppf.payroll_id
  AND    pact.effective_date BETWEEN
               ppf.effective_start_date AND ppf.effective_end_date
  AND    pact.payroll_id = NVL(p_payroll_id,pact.payroll_id)
  AND    pact.consolidation_set_id = p_consolidation_id -- 4071160
  AND    pact.effective_date BETWEEN
               p_start_date AND p_end_date
  AND    (pact.action_type = 'P' OR
          pact.action_type = 'U')
  AND    pact.action_status = 'C'
  AND    NOT EXISTS (SELECT NULL
                     FROM   pay_action_information pai
                     WHERE  pai.action_context_id = pact.payroll_action_id
                     AND    pai.action_context_type = 'PA'
                     AND    pai.action_information_category = 'EMEA PAYROLL INFO');

  CURSOR csr_payroll_mesg (p_payroll_id       NUMBER,
                           p_start_date       DATE,
                           p_end_date         DATE) IS
  SELECT pact.payroll_action_id payroll_action_id,
         pact.effective_date effective_date,
         pact.date_earned date_earned,
         pact.pay_advice_message payroll_message
  FROM   pay_payrolls_f ppf,
         pay_payroll_actions pact
  WHERE  pact.payroll_id = ppf.payroll_id
  AND    pact.effective_date BETWEEN
               ppf.effective_start_date AND ppf.effective_end_date
  AND    pact.payroll_id = p_payroll_id
  AND    pact.effective_date BETWEEN
               p_start_date AND p_end_date
  AND    (pact.action_type = 'R' OR
          pact.action_type = 'Q')
  AND    pact.action_status = 'C'
  AND    NOT EXISTS (SELECT NULL
                     FROM   pay_action_information pai
                     WHERE  pai.action_context_id = pact.payroll_action_id
                     AND    pai.action_context_type = 'PA'
                     AND    pai.action_information_category = 'EMPLOYEE OTHER INFORMATION');
*/

l_assignment_set_id               NUMBER;
l_bg_id                           NUMBER;
l_canonical_end_date              DATE;
l_canonical_start_date            DATE;
l_consolidation_set               NUMBER;
l_end_date                        VARCHAR2(30);
l_legislation_code                VARCHAR2(30) := 'GB';
l_payroll_id                      NUMBER;
l_start_date                      VARCHAR2(30);
l_tax_period_no                   VARCHAR2(30);

BEGIN

--  hr_utility.trace_on(NULL,'UKPS1');

  hr_utility.set_location('Entering ' || l_proc,10);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'ASSIGNMENT_SET'
  , p_token_value       => l_assignment_set_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
  hr_utility.set_location('l_start_date = ' || l_start_date,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  -- archive EMEA PAYROLL INFO for each prepayment run identified

  hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
  hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
  hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);

  g_max_user_balance_index := 0;

  pay_gb_payslip_archive.get_eit_definitions (
    p_pactid            => pactid
  , p_business_group_id => l_bg_id
  , p_payroll_pact      => NULL
  , p_effective_date    => l_canonical_start_date
  , p_eit_context       => g_balance_context
  , p_archive           => 'Y');

  pay_gb_payslip_archive.get_eit_definitions (
    p_pactid            => pactid
  , p_business_group_id => l_bg_id
  , p_payroll_pact      => NULL
  , p_effective_date    => l_canonical_start_date
  , p_eit_context       => g_element_context
  , p_archive           => 'Y');

  pay_gb_payslip_archive.setup_element_definitions (
    p_pactid            => pactid
  , p_payroll_pact      => NULL
  , p_business_group_id => l_bg_id
  , p_effective_date    => l_canonical_start_date);


/* 4071160 - This cursor to get payrolls based on a given consolidation set is
             is not consistent with other processes like prePayments and Cheque Writer etc.
  FOR rec_payrolls in csr_payrolls(l_payroll_id,
                                   l_consolidation_set,
                                   l_canonical_end_date)
  LOOP

    hr_utility.set_location('Calling arch_pay_action_level_data',25);

    pay_emp_action_arch.arch_pay_action_level_data (
      p_payroll_action_id => pactid
    , p_payroll_id        => rec_payrolls.payroll_id
    , p_effective_date    => l_canonical_end_date);

  END LOOP;
4071160 */



--Commented for Bug fix 5209228
/*  FOR rec_payroll_info in csr_payroll_info(l_payroll_id,
                                           l_consolidation_set,
                                           l_canonical_start_date,
                                           l_canonical_end_date)

  LOOP

    pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                               , rec_payroll_info.payroll_action_id);

    hr_utility.set_location('rec_payroll_info.payroll_action_id   = ' || rec_payroll_info.payroll_action_id,30);
    hr_utility.set_location('rec_payroll_info.tax_office_name     = ' || rec_payroll_info.tax_office_name,30);
    hr_utility.set_location('rec_payroll_info.tax_office_phone_no = ' || rec_payroll_info.tax_office_phone_no,30);
    hr_utility.set_location('rec_payroll_info.employers_ref_no    = ' || rec_payroll_info.employers_ref_no,30);

    hr_utility.set_location('Archiving EMEA PAYROLL INFO',30);

-- Added for 4071160
    pay_emp_action_arch.arch_pay_action_level_data (
      p_payroll_action_id => pactid
    , p_payroll_id        => rec_payroll_info.payroll_id
    , p_effective_date    => l_canonical_end_date);
-- End 4071160

    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  pactid
    , p_action_context_type          =>  'PA'
    , p_object_version_number        =>  l_ovn
    , p_effective_date               =>  rec_payroll_info.effective_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'EMEA PAYROLL INFO'
    , p_action_information1          =>  rec_payroll_info.payroll_action_id
    , p_action_information2          =>  rec_payroll_info.payroll_id
    , p_action_information3          =>  NULL
    , p_action_information4          =>  rec_payroll_info.tax_office_name
    , p_action_information5          =>  rec_payroll_info.tax_office_phone_no
    , p_action_information6          =>  rec_payroll_info.employers_ref_no);

  END LOOP;

  -- The Payroll level message is archived in the generic archive structure
  -- EMPLOYEE OTHER INFORMATION

  FOR rec_payroll_msg in csr_payroll_mesg(l_payroll_id,
                                          l_canonical_start_date,
                                          l_canonical_end_date)

  LOOP

    IF rec_payroll_msg.payroll_message IS NOT NULL

    THEN

      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  pactid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  rec_payroll_msg.effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'EMPLOYEE OTHER INFORMATION'
      , p_action_information1          =>  rec_payroll_msg.payroll_action_id
      , p_action_information2          =>  'MESG'
      , p_action_information3          =>  NULL
      , p_action_information4          =>  NULL
      , p_action_information5          =>  NULL
      , p_action_information6          =>  rec_payroll_msg.payroll_message);

    END IF;

  END LOOP;*/
  --
  -- Performance enhancement, the range code can now restrict
  -- by payroll_id, if the payroll_id is not null, ie has
  -- been defined in the conc process call. The l_payroll_id
  -- was selected by the get_parameters call above.
  --
  if l_payroll_id is null then
     --
     -- Use full cursor not restricting by payroll
     --
       hr_utility.trace('Range Cursor Not using Payroll Restriction');
       sqlstr := 'SELECT DISTINCT person_id
                 FROM   per_people_f ppf,
                        pay_payroll_actions ppa
                 WHERE  ppa.payroll_action_id = :payroll_action_id
                 AND    ppa.business_group_id +0= ppf.business_group_id
                 ORDER BY ppf.person_id';
  else
     --
     -- The Payroll ID was used as parameter, so restrict by this
     --
       hr_utility.trace('Range Cursor using Payroll Restriction');
       sqlstr := 'SELECT DISTINCT ppf.person_id
                  FROM   per_all_people_f ppf,
                         pay_payroll_actions ppa,
                         per_all_assignments_f paaf
                  WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND    ppf.business_group_id +0 = ppa.business_group_id
                  AND    paaf.person_id = ppf.person_id
                  AND    paaf.payroll_id = '|| to_char(l_payroll_id) ||
                 ' ORDER BY ppf.person_id';
  end if;
 --
  hr_utility.set_location('Leaving ' || l_proc,40);

END range_cursor;
---------------------------------------------------------------------------
-- Function: range_person_on.
-- Description: Returns true if the range_person performance enhancement is
--              enabled for the system. Used by action_creation.
---------------------------------------------------------------------------
FUNCTION range_person_on RETURN BOOLEAN IS
--
 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';
--
 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'UKPS'
  and    map.report_format = 'UKPSGEN'
  and    map.report_qualifier = 'GB'
  and    par.parameter_name = 'RANGE_PERSON_ID'; -- Bug fix 5567246
--
  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);
--
BEGIN
  hr_utility.set_location('range_person_on',10);
  --
  BEGIN
    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;
    --
    hr_utility.set_location('range_person_on',20);
    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;
  --
    hr_utility.set_location('range_person_on',30);
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
  hr_utility.set_location('range_person_on',40);
  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     hr_utility.trace('Range Person = True');
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;
---------------------------------------------------------------------------
PROCEDURE action_creation (pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number) is
--
CURSOR csr_prepaid_assignments(p_pact_id          NUMBER,
                               stperson           NUMBER,
                               endperson          NUMBER,
                               p_payroll_id       NUMBER,
                               p_consolidation_id NUMBER) IS
SELECT act.assignment_id assignment_id,
       act.assignment_action_id run_action_id,
       act1.assignment_action_id prepaid_action_id
FROM   pay_payroll_actions ppa,
       pay_payroll_actions appa,
       pay_payroll_actions appa2,
       pay_assignment_actions act,
       pay_assignment_actions act1,
       pay_action_interlocks pai,
       per_all_assignments_f as1
WHERE  ppa.payroll_action_id = p_pact_id
AND    appa.consolidation_set_id = p_consolidation_id
AND    appa.effective_date BETWEEN
         ppa.start_date AND ppa.effective_date
AND    as1.person_id BETWEEN
         stperson AND endperson
AND    appa.action_type IN ('R','Q')                             -- Payroll Run or Quickpay Run
AND    act.payroll_action_id = appa.payroll_action_id
AND    act.source_action_id IS NULL
AND    as1.assignment_id = act.assignment_id
AND    ppa.effective_date BETWEEN
         as1.effective_start_date AND as1.effective_end_date
AND    act.action_status = 'C'
AND    act.assignment_action_id = pai.locked_action_id
AND    act1.assignment_action_id = pai.locking_action_id
AND    act1.action_status = 'C'
AND    act1.payroll_action_id = appa2.payroll_action_id
AND    appa2.action_type IN ('P','U')                            -- Prepayments or Quickpay Prepayments
AND    (as1.payroll_id = p_payroll_id OR p_payroll_id IS NULL)
AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa3
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa3.payroll_action_id
                   AND    appa3.action_type = 'X'
                   AND    appa3.report_type = 'UKPS')
ORDER BY act.assignment_id
FOR UPDATE OF as1.assignment_id;
--
-- csr_range_pre_assignments is a copy of csr_prepaid_assignments
-- but with a join to pay_population_ranges for performance enhancement
-- stperson and endperson are not needed, uses chunk.
--
CURSOR csr_range_pre_assignments(p_pact_id          NUMBER,
                                 p_payroll_id       NUMBER,
                                 p_consolidation_id NUMBER) IS
SELECT act.assignment_id assignment_id,
       act.assignment_action_id run_action_id,
       act1.assignment_action_id prepaid_action_id
FROM   pay_payroll_actions ppa,
       pay_payroll_actions appa,
       pay_payroll_actions appa2,
       pay_assignment_actions act,
       pay_assignment_actions act1,
       pay_action_interlocks pai,
       per_all_assignments_f as1,
       pay_population_ranges ppr
WHERE  ppa.payroll_action_id = p_pact_id
AND    appa.consolidation_set_id = p_consolidation_id
AND    appa.effective_date BETWEEN
         ppa.start_date AND ppa.effective_date
AND    as1.person_id = ppr.person_id
AND    ppr.chunk_number = chunk
AND    ppr.payroll_action_id = p_pact_id
AND    appa.action_type IN ('R','Q')                             -- Payroll Run or Quickpay Run
AND    act.payroll_action_id = appa.payroll_action_id
AND    act.source_action_id IS NULL
AND    as1.assignment_id = act.assignment_id
AND    ppa.effective_date BETWEEN
         as1.effective_start_date AND as1.effective_end_date
AND    act.action_status = 'C'
AND    act.assignment_action_id = pai.locked_action_id
AND    act1.assignment_action_id = pai.locking_action_id
AND    act1.action_status = 'C'
AND    act1.payroll_action_id = appa2.payroll_action_id
AND    appa2.action_type IN ('P','U')                            -- Prepayments or Quickpay Prepayments
AND    (as1.payroll_id = p_payroll_id OR p_payroll_id IS NULL)
AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa3
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa3.payroll_action_id
                   AND    appa3.action_type = 'X'
                   AND    appa3.report_type = 'UKPS')
ORDER BY act.assignment_id
FOR UPDATE OF as1.assignment_id;
--
l_actid                           NUMBER;
l_canonical_end_date              DATE;
l_canonical_start_date            DATE;
l_consolidation_set               VARCHAR2(30);
l_end_date                        VARCHAR2(20);
l_payroll_id                      NUMBER;
l_prepay_action_id                NUMBER;
l_start_date                      VARCHAR2(20);

l_proc VARCHAR2(50) := g_package||'action_creation';

BEGIN
--  hr_utility.trace_on(null,'UKPS3');
  hr_utility.set_location('Entering ' || l_proc,10);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
  hr_utility.set_location('l_start_date = ' || l_start_date,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  l_prepay_action_id := 0;
 --
 -- Check that the Range Person settings are on, if so,
 -- use csr_range_pre_assignments. If not, use csr_prepaid_assignments.
 --
 IF range_person_on THEN

  FOR csr_rec IN csr_range_pre_assignments(pactid, l_payroll_id, l_consolidation_set)
     LOOP
       IF l_prepay_action_id <> csr_rec.prepaid_action_id THEN
         --
         SELECT pay_assignment_actions_s.NEXTVAL
         INTO   l_actid
         FROM   dual;
         --
         -- Create the archive assignment action for master action
         --
         hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,NULL);
         --
         -- Create Archive to master action interlock and
         -- the archive to prepayment asg action interlock
         --
         hr_utility.trace('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id);
         hr_utility.trace('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id);
         --
         hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);
       END IF;
    --
    hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);
    l_prepay_action_id := csr_rec.prepaid_action_id;
  END LOOP;
 --
 ELSE
 --
 -- Use the original code for non performance-enhanced cursor
 --
   FOR csr_rec IN csr_prepaid_assignments(pactid,
                                         stperson,
                                         endperson,
                                         l_payroll_id,
                                         l_consolidation_set)

  LOOP

    IF l_prepay_action_id <> csr_rec.prepaid_action_id

    THEN

    SELECT pay_assignment_actions_s.NEXTVAL
    INTO   l_actid
    FROM   dual;

    -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION

    hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,NULL);

    -- CREATE THE ARCHIVE TO PAYROLL MASTER ASSIGNMENT ACTION INTERLOCK AND
    -- THE ARCHIVE TO PREPAYMENT ASSIGNMENT ACTION INTERLOCK

    hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,20);
    hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id,20);

    hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);

    END IF;

    hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);

    l_prepay_action_id := csr_rec.prepaid_action_id;

  END LOOP;
 --
 END IF; -- Range Person Code check.

 hr_utility.set_location('Leaving ' || l_proc,20);

END action_creation;

PROCEDURE archive_code (p_assactid       in number,
                        p_effective_date in date) IS

CURSOR csr_assignment_actions(p_locking_action_id NUMBER) IS
SELECT pre.locked_action_id      pre_assignment_action_id,
       pay.locked_action_id      master_assignment_action_id,
       assact.assignment_id      assignment_id,
       assact.payroll_action_id  pay_payroll_action_id,
       paa.effective_date        effective_date,
       ppaa.effective_date       pre_effective_date,
       paa.date_earned           date_earned,
       paa.time_period_id        time_period_id,
       paa.action_type           action_type	/*Added for the bug 7502055*/
FROM   pay_action_interlocks pre,
       pay_action_interlocks pay,
       pay_payroll_actions paa,
       pay_payroll_actions ppaa,
       pay_assignment_actions assact,
       pay_assignment_actions passact
WHERE  pre.locked_action_id = pay.locking_action_id
AND    pre.locking_action_id = p_locking_action_id
AND    pre.locked_action_id = passact.assignment_action_id
AND    passact.payroll_action_id = ppaa.payroll_action_id
AND    ppaa.action_type IN ('P','U')
AND    pay.locked_action_id = assact.assignment_action_id
AND    assact.payroll_action_id = paa.payroll_action_id
AND    assact.source_action_id IS NULL
ORDER BY pay.locked_action_id;

CURSOR csr_child_actions(p_master_assignment_action NUMBER,
                         p_payroll_action_id        NUMBER,
                         p_assignment_id            NUMBER,
                         p_effective_date           DATE  ) IS
SELECT paa.assignment_action_id child_assignment_action_id,
       'S' run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.source_action_id = p_master_assignment_action
AND    paa.payroll_action_id = p_payroll_action_id
AND    paa.assignment_id = p_assignment_id
AND    paa.run_type_id = prt.run_type_id
AND    prt.run_method = 'S'
AND    p_effective_date BETWEEN
         prt.effective_start_date AND prt.effective_end_date
UNION
SELECT paa.assignment_action_id child_assignment_action_id,
       'NP' run_type
FROM   pay_assignment_actions paa
WHERE  paa.payroll_action_id = p_payroll_action_id
AND    paa.assignment_id = p_assignment_id
AND    paa.action_sequence = (SELECT MAX(paa1.action_sequence)
                              FROM   pay_assignment_actions paa1,
                                     pay_run_types_f prt1
                              WHERE  prt1.run_type_id = paa1.run_type_id
                              AND    prt1.run_method IN ('N','P')
                              AND    paa1.payroll_action_id = p_payroll_action_id
                              AND    paa1.assignment_id = p_assignment_id
                              AND    paa1.source_action_id = p_master_assignment_action
                              AND    p_effective_date BETWEEN
                                       prt1.effective_start_date AND prt1.effective_end_date);

CURSOR csr_np_children (p_assignment_action_id NUMBER,
                        p_payroll_action_id    NUMBER,
                        p_assignment_id        NUMBER,
                        p_effective_date       DATE) IS
SELECT paa.assignment_action_id np_assignment_action_id,
       prt.run_method
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.source_action_id = p_assignment_action_id
AND    paa.payroll_action_id = p_payroll_action_id
AND    paa.assignment_id = p_assignment_id
AND    paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    p_effective_date BETWEEN
         prt.effective_start_date AND prt.effective_end_date;

l_actid                           NUMBER;
l_action_context_id               NUMBER;
l_action_info_id                  NUMBER(15);
l_assignment_action_id            NUMBER;
l_business_group_id               NUMBER;
l_child_count                     NUMBER;
l_chunk_number                    NUMBER;
l_date_earned                     DATE;
l_ovn                             NUMBER;
l_person_id                       NUMBER;
l_record_count                    NUMBER;
l_salary                          VARCHAR2(10);
l_sequence                        NUMBER;
csr_rec                           csr_assignment_actions%rowtype;

l_proc                            VARCHAR2(50) := g_package || 'archive_code';

BEGIN

--  hr_utility.trace_on(NULL,'UKPS2');

  hr_utility.set_location('Entering '|| l_proc,10);

  hr_utility.set_location('Step '|| l_proc,20);
  hr_utility.set_location('p_assactid = ' || p_assactid,20);

  -- retrieve the chunk number for the current assignment action
  SELECT paa.chunk_number
  INTO   l_chunk_number
  FROM   pay_assignment_actions paa
  WHERE  paa.assignment_action_id = p_assactid;

  l_action_context_id := p_assactid;

  l_record_count := 0;

  /*****************************************************************
  ** Cursor to  return all the Runs for a Pre Payment Process which
  ** is being archived.
  *****************************************************************/
  OPEN csr_assignment_actions(p_assactid);
  LOOP
     fetch csr_assignment_actions into csr_rec;
     hr_utility.set_location('csr_rec.master_assignment_action_id = ' ||
                              csr_rec.master_assignment_action_id,20);
     hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' ||
                              csr_rec.pre_assignment_action_id,20);

     /*****************************************************************
     ** Archive the employee details for the last row returned by
     ** the cursor csr_assignment_actions.
     ** This will ensure that the the correct time period is passed
     ** to the global package if there are multiple runs in a single
     ** pre payment. Also, the global package can not be called
     ** multiple times if there are multiple runs in a single pre
     ** payment as it will archive the Net Distribution every time.
     **
     ** Call the global package only if the cursor fetches a record.
     *****************************************************************/
     if csr_assignment_actions%notfound then
        if csr_assignment_actions%rowcount > 0 then
           /* pay_gb_payslip_archive.archive_employee_details
               p_assactid             => p_assactid
              ,p_assignment_id        => assignment_id
              ,p_curr_pymt_ass_act_id => prepayment assignment_action_id
              ,p_effective_date       => payroll effective_date
              ,p_date_earned          => payroll date_earned
              ,p_curr_pymt_eff_date   => prepayment effective_date
              ,p_time_period_id       => payroll time_period_id
              ,p_record_count         => l_record_count);
           */
           pay_gb_payslip_archive.archive_employee_details (
               p_assactid             => p_assactid
              ,p_assignment_id        => csr_rec.assignment_id
              ,p_curr_pymt_ass_act_id => csr_rec.pre_assignment_action_id
              ,p_effective_date       => csr_rec.effective_date
              ,p_date_earned          => csr_rec.date_earned
              ,p_curr_pymt_eff_date   => csr_rec.pre_effective_date
              ,p_time_period_id       => csr_rec.time_period_id
              ,p_record_count         => l_record_count);
        end if;
        exit;
     end if;



    /*****************************************************************
    ** This returns all the Child Actions for a given master
    ** assignment action. There will not be any issue in this case if
    ** there are multiple runs for a pre payment as we calling it
    ** for the master run action.
    *****************************************************************/
    FOR csr_child_rec IN csr_child_actions(
                             csr_rec.master_assignment_action_id,
                             csr_rec.pay_payroll_action_id,
                             csr_rec.assignment_id,
                             csr_rec.effective_date)

    LOOP
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

          IF l_record_count = 0 THEN
             /* pay_gb_payslip_archive.archive_employee_details
                 p_assactid             => p_assactid
                ,p_assignment_id        => assignment_id
                ,p_curr_pymt_ass_act_id => prepayment assignment_action_id
                ,p_effective_date       => payroll effective_date
                ,p_date_earned          => payroll date_earned
                ,p_curr_pymt_eff_date   => prepayment effective_date
                ,p_time_period_id       => payroll time_period_id
                ,p_record_count         => l_record_count);
             */
             pay_gb_payslip_archive.archive_employee_details (
               p_assactid             => l_action_context_id
              ,p_assignment_id        => csr_rec.assignment_id
              ,p_curr_pymt_ass_act_id => csr_rec.pre_assignment_action_id
              ,p_effective_date       => csr_rec.effective_date
              ,p_date_earned          => csr_rec.date_earned
              ,p_curr_pymt_eff_date   => csr_rec.pre_effective_date
              ,p_time_period_id       => csr_rec.time_period_id
              ,p_record_count         => l_record_count);

             pay_gb_payslip_archive.archive_gb_employee_details (
              p_assactid             => l_action_context_id
             ,p_assignment_id        => csr_rec.assignment_id
             ,p_curr_pymt_ass_act_id => csr_child_rec.child_assignment_action_id
             ,p_effective_date       => csr_rec.effective_date);

          END IF;

          pay_gb_payslip_archive.get_element_info (
            p_action_context_id       => l_action_context_id
          , p_assignment_id           => csr_rec.assignment_id
          , p_child_assignment_action => csr_child_rec.child_assignment_action_id
          , p_effective_date          => csr_rec.effective_date
          , p_record_count            => l_record_count
          , p_run_method              => 'S');

       END IF;

       IF csr_child_rec.run_type = 'NP' THEN
          l_child_count := 0;
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

             IF l_child_count = 0 AND l_record_count = 0 THEN
                pay_gb_payslip_archive.archive_gb_employee_details (
                  p_assactid             => l_action_context_id
                 ,p_assignment_id        => csr_rec.assignment_id
                 ,p_curr_pymt_ass_act_id => csr_np_rec.np_assignment_action_id
                 ,p_effective_date       => csr_rec.effective_date);
             END IF;

             pay_gb_payslip_archive.get_element_info (
               p_action_context_id       => l_action_context_id
              ,p_assignment_id           => csr_rec.assignment_id
              ,p_child_assignment_action => csr_np_rec.np_assignment_action_id
              ,p_effective_date          => csr_rec.effective_date
              ,p_record_count            => l_record_count
              ,p_run_method              => csr_np_rec.run_method);

              l_child_count := l_child_count + 1;

          END LOOP;
       END IF;

       -- Both User and Statutory Balances are archived for all Separate
       -- Payment assignment actions and the last (i.e. highest action_sequence)
       -- Process Separately assignment action (EMEA BALANCES) archive
       -- user balances
       hr_utility.set_location('Archive User Balances - Starting',60);
       hr_utility.set_location('g_max_user_balance_index = '||
                                g_max_user_balance_index,60);

       FOR l_index IN 1 .. g_max_user_balance_index
       LOOP
          pay_gb_payslip_archive.process_balance (
            p_action_context_id => l_action_context_id
          , p_assignment_id     => csr_rec.assignment_id
          , p_source_id         => csr_child_rec.child_assignment_action_id
          , p_effective_date    => csr_rec.effective_date
          , p_balance           => g_user_balance_table(l_index).balance_name
          , p_dimension         => g_user_balance_table(l_index).database_item_suffix
          , p_defined_bal_id    => g_user_balance_table(l_index).defined_balance_id
          , p_ni_type           => g_user_balance_table(l_index).ni_type_ind
          , p_record_count      => l_record_count);

       END LOOP;

       hr_utility.set_location('Archive User Balances - Complete',60);

       -- archive statutory balances
       hr_utility.set_location('Archive Statutory Balances - Starting',70);
       hr_utility.set_location('g_max_statutory_balance_index = '||
                                g_max_statutory_balance_index,70);

       FOR l_index IN 1 .. g_max_statutory_balance_index
       LOOP
          hr_utility.set_location('l_index = ' || l_index,70);
          pay_gb_payslip_archive.process_balance (
            p_action_context_id => l_action_context_id
          , p_assignment_id     => csr_rec.assignment_id
          , p_source_id         => csr_child_rec.child_assignment_action_id
          , p_effective_date    => csr_rec.effective_date
          , p_balance           => g_statutory_balance_table(l_index).balance_name
          , p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
          , p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
          , p_ni_type           => g_statutory_balance_table(l_index).ni_type_ind
          , p_record_count      => l_record_count);
       END LOOP;

       hr_utility.set_location('Archive Statutory Balances - Complete',70);

     /*****************************************************************
     ** Below call is to address bug #7171712.
     ** It archives the payments and deductions details for the employee
     ** for the given assignment_action_id.
     *****************************************************************/

     PAY_GB_PAYSLIP_ARCHIVE.get_pay_deduct_element_info (p_assactid);

     hr_utility.set_location('Archive Payments and Deductions data - Complete',75);

    END LOOP; -- child assignment actions

    l_record_count := l_record_count + 1;

    /*Start modifications for bug 7502055*/
	if (csr_rec.action_type = 'B')
	then
			 l_record_count := l_record_count - 1;
	end if;
    /*End modifications for bug 7502055*/

  END LOOP;
  close csr_assignment_actions;

  hr_utility.set_location('Leaving '|| l_proc,80);

END archive_code;

--Added for bug fix 5209228
PROCEDURE ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER) IS


  l_proc    CONSTANT VARCHAR2(50):= g_package||'archive_deinit';

  l_archived		      NUMBER(1);
  l_ovn                       NUMBER(15);
  l_request_id                NUMBER;
  l_action_info_id            NUMBER(15);
  l_business_group_id         NUMBER;


 CURSOR csr_payroll_info(p_payroll_id       NUMBER,
                          p_consolidation_id NUMBER,
                          p_start_date       DATE,
                          p_end_date         DATE) IS
  SELECT pact.payroll_action_id payroll_action_id,
         pact.effective_date effective_date,
         pact.date_earned date_earned,
         pact.payroll_id,
         org.org_information1 employers_ref_no,
         org.org_information2 tax_office_name,
         org.org_information3 employer_name,
         org.org_information4 employer_address,
         org.org_information8 tax_office_phone_no,
         ppf.payroll_name payroll_name,
         ppf.period_type period_type,
         pact.pay_advice_message payroll_message
  FROM   pay_payrolls_f ppf,
         pay_payroll_actions pact,
         hr_soft_coding_keyflex flex,
         hr_organization_information org
  WHERE  ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
  AND    org.org_information_context = 'Tax Details References'
  AND    org.org_information1 = flex.segment1
  AND    ppf.business_group_id = org.organization_id
  AND    pact.payroll_id = ppf.payroll_id
  AND    pact.effective_date BETWEEN
               ppf.effective_start_date AND ppf.effective_end_date
  AND    pact.payroll_id = NVL(p_payroll_id,pact.payroll_id)
  AND    pact.consolidation_set_id = p_consolidation_id -- 4071160
  AND    pact.effective_date BETWEEN
               p_start_date AND p_end_date
  AND    (pact.action_type = 'P' OR
          pact.action_type = 'U')
  AND    pact.action_status = 'C'
  AND    NOT EXISTS (SELECT NULL
                     FROM   pay_action_information pai
                     WHERE  pai.action_context_id = pact.payroll_action_id
                     AND    pai.action_context_type = 'PA'
                     AND    pai.action_information_category = 'EMEA PAYROLL INFO');

  CURSOR csr_payroll_mesg (p_payroll_id       NUMBER,
                           p_start_date       DATE,
                           p_end_date         DATE) IS
  SELECT pact.payroll_action_id payroll_action_id,
         pact.effective_date effective_date,
         pact.date_earned date_earned,
         pact.pay_advice_message payroll_message
  FROM   pay_payrolls_f ppf,
         pay_payroll_actions pact
  WHERE  pact.payroll_id = ppf.payroll_id
  AND    pact.effective_date BETWEEN
               ppf.effective_start_date AND ppf.effective_end_date
  AND    pact.payroll_id = p_payroll_id
  AND    pact.effective_date BETWEEN
               p_start_date AND p_end_date
  AND    (pact.action_type = 'R' OR
          pact.action_type = 'Q')
  AND    pact.action_status = 'C'
  AND    NOT EXISTS (SELECT NULL
                     FROM   pay_action_information pai
                     WHERE  pai.action_context_id = pact.payroll_action_id
                     AND    pai.action_context_type = 'PA'
                     AND    pai.action_information_category = 'EMPLOYEE OTHER INFORMATION');

--
l_assignment_set_id               NUMBER;
l_bg_id                           NUMBER;
l_canonical_end_date              DATE;
l_canonical_start_date            DATE;
l_consolidation_set               NUMBER;
l_end_date                        VARCHAR2(30);
l_legislation_code                VARCHAR2(30) := 'GB';
l_payroll_id                      NUMBER;
l_start_date                      VARCHAR2(30);
l_tax_period_no                   VARCHAR2(30);
l_error                           varchar2(1) ;


BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);


 -- To avoid re-archiving while Retry
   delete from pay_action_information pai
     where pai.action_context_id = p_payroll_action_id
       and pai.action_context_type = 'PA'
       and pai.action_information_category in ('EMPLOYEE OTHER INFORMATION')
       and pai.action_information2 = 'MESG';

     delete from pay_action_information pai
     where pai.action_context_id = p_payroll_action_id
       and pai.action_context_type = 'PA'
       and pai.action_information_category in ('EMEA PAYROLL INFO');


 pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'ASSIGNMENT_SET'
  , p_token_value       => l_assignment_set_id);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  pay_gb_payslip_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);


  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
  hr_utility.set_location('l_start_date = ' || l_start_date,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  -- archive EMEA PAYROLL INFO for each prepayment run identified

  hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
  hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
  hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);


--Archiving contexts  EMPLOYEE OTHER INFORMATION for MESG and
--ADDRESS DETAILS for Employer Address

      pay_emp_action_arch.arch_pay_action_level_data (
          p_payroll_action_id => p_payroll_action_id
        , p_effective_date    => l_canonical_end_date);


 --Archiving context EMEA PAYROLL INFO
  FOR rec_payroll_info in csr_payroll_info(l_payroll_id,
                                           l_consolidation_set,
                                           l_canonical_start_date,
                                           l_canonical_end_date)

  LOOP

    pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                               , rec_payroll_info.payroll_action_id);


    hr_utility.set_location('rec_payroll_info.payroll_action_id   = ' || rec_payroll_info.payroll_action_id,30);
    hr_utility.set_location('rec_payroll_info.tax_office_name     = ' || rec_payroll_info.tax_office_name,30);
    hr_utility.set_location('rec_payroll_info.tax_office_phone_no = ' || rec_payroll_info.tax_office_phone_no,30);
    hr_utility.set_location('rec_payroll_info.employers_ref_no    = ' || rec_payroll_info.employers_ref_no,30);

    hr_utility.set_location('Archiving EMEA PAYROLL INFO',30);

    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_payroll_action_id
    , p_action_context_type          =>  'PA'
    , p_object_version_number        =>  l_ovn
    , p_effective_date               =>  rec_payroll_info.effective_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'EMEA PAYROLL INFO'
    , p_action_information1          =>  rec_payroll_info.payroll_action_id
    , p_action_information2          =>  rec_payroll_info.payroll_id
    , p_action_information3          =>  NULL
    , p_action_information4          =>  rec_payroll_info.tax_office_name
    , p_action_information5          =>  rec_payroll_info.tax_office_phone_no
    , p_action_information6          =>  rec_payroll_info.employers_ref_no);

  END LOOP;

  -- The Payroll level message is archived in the generic archive structure
  -- EMPLOYEE OTHER INFORMATION

 --Archiving context EMPLOYEE OTHER INFORMATION
  FOR rec_payroll_msg in csr_payroll_mesg(l_payroll_id,
                                          l_canonical_start_date,
                                          l_canonical_end_date)

  LOOP

    IF rec_payroll_msg.payroll_message IS NOT NULL

    THEN

      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_payroll_action_id
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  rec_payroll_msg.effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'EMPLOYEE OTHER INFORMATION'
      , p_action_information1          =>  rec_payroll_msg.payroll_action_id
      , p_action_information2          =>  'MESG'
      , p_action_information3          =>  NULL
      , p_action_information4          =>  NULL
      , p_action_information5          =>  NULL
      , p_action_information6          =>  rec_payroll_msg.payroll_message);

    END IF;

  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,40);
  END ARCHIVE_DEINIT;
-- Start fix for Bug#7171712
--Added the below procedure for populating the historic data in to pay_action_information table
PROCEDURE get_pay_deduct_element_info ( p_assignment_action_id  IN NUMBER,
                                        p_assignment_id IN NUMBER DEFAULT NULL,
                                        p_effective_date IN DATE DEFAULT NULL)
IS

/* Cursor to fetch earnings and deductions values depending on the element type */
CURSOR csr_element_values (p_assignment_action_id NUMBER,
                           p_element_type_1 IN VARCHAR,
                           p_element_type_2 IN VARCHAR,
                           p_element_type_3 IN VARCHAR) IS

SELECT /*+ leading(lck,paa2) */ lck.locking_action_id ACTION_CONTEXT_ID, pet.element_type_id, piv.input_value_id, pai.action_information4 NARRATIVE, pai.action_information5 PAYMENT_TYPE,
SUM(FND_NUMBER.CANONICAL_TO_NUMBER(prv.result_value)) value, SUM(FND_NUMBER.CANONICAL_TO_NUMBER(prv.result_value)) numeric_value
FROM  pay_action_interlocks lck, -- archive action locking prepayment
     pay_assignment_actions paa1, -- prepayment action
	 pay_assignment_actions paa2, -- archive action
	 pay_payroll_actions ppa, -- prepayment
	 pay_action_information pai, -- archived element/input value definition
     pay_action_interlocks pac, -- prepayment locking payroll run/quickpay
     pay_assignment_actions paa, -- payroll run/quickpay action
	 pay_payroll_actions ppa1, -- payroll run/quickpay action
	 pay_element_types_f pet, -- element types processed by the payroll run/quickpay
	 pay_input_values_f piv, -- "Pay values" of type Money
	 pay_run_results prr, -- run result created by the payroll run/quick pay
	 pay_run_result_values prv -- Run Result value (Pay Value) created by the payroll run/quickpay
WHERE   lck.locking_action_id = paa2.assignment_action_id
    AND paa2.payroll_action_id = pai.action_context_id
    AND pai.action_context_type = 'PA'
    AND pai.action_information_category = 'EMEA ELEMENT DEFINITION'
    AND lck.locked_action_id = paa1.assignment_action_id
    AND paa1.source_action_id IS NULL
    AND paa1.payroll_action_id = ppa.payroll_action_id
    AND ppa.action_type IN ('P','U')
    AND ppa.payroll_action_id = NVL (pai.action_information1,ppa.payroll_action_id)
    AND paa1.assignment_action_id = pac.locking_action_id
    AND pet.element_type_id = pai.action_information2
    AND pet.element_type_id = piv.element_type_id
    AND piv.input_value_id = pai.action_information3
    AND prr.element_type_id = pet.element_type_id
    AND prr.status IN ('P','PA')
    AND prv.input_value_id = piv.input_value_id
    AND prv.run_result_id = prr.run_result_id
    AND piv.name = 'Pay Value'
    AND piv.uom = 'M'
    AND pac.locked_action_id = prr.assignment_action_id
    AND pac.locked_action_id = paa.assignment_action_id
    AND paa.payroll_action_id = ppa1.payroll_action_id
    AND ppa1.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND ppa1.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
    AND lck.locking_action_id = p_assignment_action_id
    AND pai.action_information5 in (p_element_type_1 , p_element_type_2, p_element_type_3)
GROUP BY lck.locking_action_id, pet.element_type_id, piv.input_value_id, pai.action_information4, pai.action_information5;

/* Local variables to store action information id and ovn number returned by the create action information api */
l_action_info_id  NUMBER;
l_ovn             NUMBER;

l_assignment_id   NUMBER;
l_effective_date  DATE;
BEGIN
hr_utility.set_location('Entering get_pay_deduct_element_info',10);
hr_utility.set_location('p_assignment_action_id = '  || p_assignment_action_id,10);

  if (p_assignment_id is null or p_effective_date is null)
  then
    select  paa.assignment_id, ppa.effective_date
      into  l_assignment_id, l_effective_date
      from  pay_payroll_actions ppa,
            pay_assignment_actions paa
      where paa.assignment_action_id = p_assignment_action_id
        and paa.payroll_action_id = ppa.payroll_action_id;

   else
    l_assignment_id := p_assignment_id;
    l_effective_date := p_effective_date;
   end if;

    /* Archiving the payments and deductions data */
    for rec_element_value in csr_element_values (p_assignment_action_id
                             , 'E'
                             , 'P'
                             , 'D')
    loop

      hr_utility.set_location('element_type_id = ' || rec_element_value.element_type_id,20);
      hr_utility.set_location('input_value_id = '  || rec_element_value.input_value_id,20);
      hr_utility.set_location('assignment_id = '  || l_assignment_id,20);
      hr_utility.set_location('effective_date = '  || l_effective_date,20);

	if ((rec_element_value.element_type_id is not null)
    	and (rec_element_value.input_value_id is not null)
        and (rec_element_value.payment_type is not null)
	    and (rec_element_value.value is not null)
	    and (rec_element_value.narrative is not null))
	then
	   hr_utility.set_location('Archiving GB ELEMENT PAYSLIP INFO',30);
       /* Creating action information */
       pay_action_information_api.create_action_information (
          p_action_information_id        => l_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => l_ovn
        , p_action_information_category  => 'GB ELEMENT PAYSLIP INFO'
        , p_action_information1          => rec_element_value.element_type_id
        , p_action_information2          => rec_element_value.input_value_id
        , p_action_information3          => rec_element_value.payment_type
        , p_action_information4          => FND_NUMBER.CANONICAL_TO_NUMBER(rec_element_value.value)
        , p_action_information5          => rec_element_value.narrative
        , p_effective_date               => l_effective_date
        , p_assignment_id                => l_assignment_id
       );

    end if;
    end loop;
    hr_utility.set_location('Leaving get_pay_deduct_element_info',40);
EXCEPTION

  WHEN OTHERS
  THEN
    hr_utility.set_location('Exception occured in get_pay_deduct_element_info '||SQLERRM,50);
    RAISE;
END get_pay_deduct_element_info;
-- End fix for Bug#7171712
END;

/
