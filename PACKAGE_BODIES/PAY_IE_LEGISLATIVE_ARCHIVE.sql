--------------------------------------------------------
--  DDL for Package Body PAY_IE_LEGISLATIVE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_LEGISLATIVE_ARCHIVE" AS
/* $Header: pyieparc.pkb 120.15.12010000.7 2009/07/28 09:06:15 vijranga ship $ */

TYPE balance_rec IS RECORD (
  balance_type_id      NUMBER,
  balance_dimension_id NUMBER,
  defined_balance_id   NUMBER,
  balance_narrative    VARCHAR2(150),
  balance_name         VARCHAR2(150),
  database_item_suffix VARCHAR2(30),
  legislation_code     VARCHAR2(20));

TYPE element_rec IS RECORD (
  element_type_id      NUMBER,
  input_value_id       NUMBER,
  formula_id           NUMBER,
  element_narrative    VARCHAR2(150),
  -- Added for bug 5387406
  uom                  VARCHAR2(30));



TYPE balance_table   IS TABLE OF balance_rec   INDEX BY BINARY_INTEGER;
TYPE element_table   IS TABLE OF element_rec   INDEX BY BINARY_INTEGER;

g_user_balance_table              balance_table;
g_element_table                   element_table;
g_statutory_balance_table         balance_table;

g_balance_archive_index           NUMBER := 0;
g_element_archive_index           NUMBER := 0;
g_max_element_index               NUMBER := 0;
g_max_user_balance_index          NUMBER := 0;
g_max_statutory_balance_index     NUMBER := 0;

g_paye_details_element_id         NUMBER;
g_paye_previous_pay_archived      VARCHAR2(1);
g_paye_previous_pay_id            NUMBER;
g_paye_previous_tax_archived      VARCHAR2(1);
g_paye_previous_tax_id            NUMBER;

g_tax_basis_id                    NUMBER;
g_prsi_cat_id       NUMBER;
g_prsi_subcat_id      NUMBER;
g_ins_weeks_id                    NUMBER;
g_tax_credit_id       NUMBER;
g_std_cut_off_id      NUMBER;
g_tax_unit_id         NUMBER;
g_prsi_week_id                    NUMBER;

g_package                CONSTANT VARCHAR2(30) := 'pay_ie_legislative_archive.';

g_balance_context        CONSTANT VARCHAR2(30) := 'IE_BALANCES';
g_element_context        CONSTANT VARCHAR2(30) := 'IE_ELEMENTS';

g_archive_pact                    NUMBER;
g_archive_effective_date          DATE;

PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT  NOCOPY VARCHAR2) IS

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

-- Start fix for Bug#8522324
--Added the below procedure to archieve payments and dedutions data in to pay_action_information table
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
    l_proc          VARCHAR2(60) := g_package || ' get_pay_deduct_element_info';


BEGIN
hr_utility.set_location('Entering ' || l_proc,10);
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
	   hr_utility.set_location('Archiving EMEA ELEMENT INFO',30);
       /* Creating action information */
       pay_action_information_api.create_action_information (
          p_action_information_id        => l_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => l_ovn
        , p_action_information_category  => 'EMEA ELEMENT INFO'
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

hr_utility.set_location('Leaving ' || l_proc,20);

EXCEPTION
  WHEN OTHERS
  THEN
    hr_utility.set_location('Exception occured in get_pay_deduct_element_info '||SQLERRM,50);
    RAISE;

END get_pay_deduct_element_info;
-- End fix for Bug#8522324

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

      g_user_balance_table(l_index).balance_type_id := csr_eit_rec.org_information2;

      g_user_balance_table(l_index).balance_dimension_id := csr_eit_rec.org_information3;

      g_user_balance_table(l_index).balance_narrative := csr_eit_rec.org_information4;

      OPEN csr_balance_name(g_user_balance_table(l_index).balance_type_id,
                            g_user_balance_table(l_index).balance_dimension_id);

      FETCH csr_balance_name
      INTO  g_user_balance_table(l_index).balance_name,
            g_user_balance_table(l_index).database_item_suffix,
            g_user_balance_table(l_index).legislation_code,
            g_user_balance_table(l_index).defined_balance_id;

      CLOSE csr_balance_name;

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
      , p_action_information4          =>  csr_eit_rec.org_information4);

      END IF;

      g_max_user_balance_index := g_max_user_balance_index + 1;

    END IF;

    IF p_eit_context = g_element_context

    THEN

     g_element_table(l_index).element_type_id   := csr_eit_rec.org_information1;

     g_element_table(l_index).input_value_id    := csr_eit_rec.org_information2;

     g_element_table(l_index).element_narrative := csr_eit_rec.org_information3;

     OPEN csr_input_value_uom(csr_eit_rec.org_information2,
                              p_effective_date);

     FETCH csr_input_value_uom INTO l_uom;

     CLOSE csr_input_value_uom;

     -- added for bug 5387406
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




PROCEDURE setup_element_definitions (p_pactid         IN NUMBER,
                                     p_payroll_pact   IN NUMBER,
                                     p_business_group_id IN NUMBER,
                                     p_effective_date IN DATE)
IS

l_action_info_id   NUMBER(15);
l_ovn              NUMBER(15);
l_payment_type     VARCHAR2(1);
l_payment_type_bik VARCHAR2(1);


-- Bug No: 2338289
-- Deduction Net Tax (and value) not to be shown, it should be
-- PAYE at Higher Rate and PAYE at Standard Rate
-- csr_element_name modified

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
WHERE  pec.classification_name IN
       ('Court Orders',
        'Voluntary Deductions',
        'Pre-Tax Deductions',
        'Pre PRSI Deduction',             -- Bug 2672763
        'Pre Tax and Pre PRSI Deduction', -- Bug 2672763
        'PAYE',
        'PRSI',
        'Earnings',
        'Direct Payments',
        'IE Earnings Non PRSIable',  -- Bug 2943335
        'IE Earnings Non Taxable and Non PRSIable', -- Bug 2943335
        'IE Social Benefits Clearup', -- Bug 2943335
        'IE Benefit In Kind Arrearage',--Bug 2367175
        'IE Benefit In Kind Arrearage Recovery',
        'Advance Earnings',  --Bug 3720315
	'Income Tax Levy',
        'Parking Levy') /* 7658548 */
AND    pet.element_name <> 'IE PRSI'
and    pet.element_name not in ('IE Reduced Std Rate Cut Off' , 'IE Reduced Tax Credit')
AND    pec.business_group_id IS NULL
AND    pec.legislation_code = 'IE'
AND    pet.classification_id = pec.classification_id
AND    NVL(pet.business_group_id,p_business_group_id) = p_business_group_id
AND    piv.element_type_id = pet.element_type_id
AND    (
       (piv.name ='Pay Value' )
OR     (pet.element_name in ('IE BIK Arrearage Details','IE BIK Arrearage Recovery Details') and  piv.name in ('BIK Arrearage','BIK Arrearage Recovered'))
OR     (pet.element_name in ('IE PAYE at higher rate','IE PAYE at standard rate') AND   piv.name ='Value' ))
AND    p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND    p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
Union  -- Added for bug Fix 2367175
SELECT pet.element_type_id,piv.input_value_id,
       NVL(pet.reporting_name,pet.element_name) element_name,
       'Information',
       piv.uom
FROM   pay_element_classifications pec,
       pay_input_values_f piv,
       pay_element_types_f pet
WHERE  pec.classification_name IN ( 'Information')
AND    pec.business_group_id IS NULL
AND    pec.legislation_code = 'IE'
AND    pet.classification_id = pec.classification_id
AND    NVL(pet.business_group_id,p_business_group_id) = p_business_group_id
AND    piv.element_type_id = pet.element_type_id
AND    p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND    p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
-- Changed to improve the performance 4771780
-- moving them to decode and avoiding OR condition removes merge cartesian join
AND    piv.name = decode(pet.element_name,
                         'IE BIK Accommodation Details','Taxable Value for Run',
                         'IE BIK Asset Type Details','Taxable Value for Run',
                         'IE BIK Company Vehicle Details','Taxable Value for Run',
                         'IE BIK Preferential Loan Details','Taxable Value for Run',
                         'IE BIK Other Reportable Item Details','Taxable Value for Run',
                         'IE BIK Non Recurring Reportable Items','Benefit Value'
			 );

l_proc VARCHAR2(60) := g_package || 'setup_element_definitions';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('p_payroll_pact = ' || p_payroll_pact,10);


  FOR csr_element_rec IN csr_element_name(p_business_group_id,
                                          p_effective_date)
  LOOP

     hr_utility.set_location('csr_element_rec.element_type_id = ' || csr_element_rec.element_type_id,20);
     hr_utility.set_location('csr_element_rec.element_name    = ' || csr_element_rec.element_name,20);

     IF csr_element_rec.classification_name IN
     ('Earnings', 'IE Earnings Non PRSIable',   'IE Earnings Non Taxable and Non PRSIable')
     --  Bug 2943335 Added 'IE Earnings Non PRSIable' and'IE Earnings Non Taxable and Non PRSIable'
     THEN

       l_payment_type := 'E';
       l_payment_type_bik :='P';

     ELSIF csr_element_rec.classification_name = 'Direct Payments'

     THEN

       l_payment_type := 'P';
       l_payment_type_bik :='P';

     ELSIF csr_element_rec.classification_name = 'Information'

     THEN

        l_payment_type_bik :='C';
/*Bug No. 3720315*/
     ELSIF csr_element_rec.classification_name = 'Advance Earnings'
     THEN
       l_payment_type := 'P';
       l_payment_type_bik :='P';
/*End of Bug No. 3720315*/

     ELSE

       l_payment_type := 'D';
       l_payment_type_bik :='P';

     END IF;



     hr_utility.set_location('Arch EMEA ELEMENT DEFINITION',99);

  IF l_payment_type_bik='P'
  THEN
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

  END IF;
 --Added for bug fix 2367175
 --To Display the taxable value for all benefits in kind, in both the payments and
 --deduction section,passing a value of 'E' and 'D' to payment type

  IF l_payment_type_bik='C'
  THEN
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
     , p_action_information5          =>  'E'
     , p_action_information6          =>  csr_element_rec.uom);

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
     , p_action_information5          =>  'D'
     , p_action_information6          =>  csr_element_rec.uom);

  END IF;

  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,30);

END setup_element_definitions;

PROCEDURE setup_standard_balance_table
IS

TYPE balance_name_rec IS RECORD (
  balance_name VARCHAR2(50));  /* 7691477 */

TYPE balance_id_rec IS RECORD (
  defined_balance_id NUMBER,
  balance_name VARCHAR2(50),  -- 4879850  /* 7691477 */
  dimension_name VARCHAR2(100)); --6633719

TYPE balance_name_tab IS TABLE OF balance_name_rec INDEX BY BINARY_INTEGER;
TYPE balance_id_tab   IS TABLE OF balance_id_rec   INDEX BY BINARY_INTEGER;

l_statutory_balance balance_name_tab;
l_statutory_bal_id  balance_id_tab;

-- Bug 3221451 : Added the condition to check the Legislation Code and
-- Business Group Id

CURSOR csr_balance_dimension(p_balance   IN CHAR,
                             p_dimension IN CHAR) IS
SELECT pdb.defined_balance_id
FROM   pay_balance_types pbt,
       pay_balance_dimensions pbd,
       pay_defined_balances pdb
WHERE  pdb.balance_type_id = pbt.balance_type_id
AND    pdb.balance_dimension_id = pbd.balance_dimension_id
AND    pbt.balance_name = p_balance
AND    pbd.database_item_suffix = p_dimension
AND    pbd.legislation_code = 'IE'
AND    pbd.business_group_id is NULL
AND    pbt.legislation_code = 'IE'
AND    pbt.business_group_id is NULL
AND    pdb.legislation_code = 'IE'
AND    pdb.business_group_id is NULL;

l_archive_index                   NUMBER       := 0;
l_dimension                       VARCHAR2(16) := '_ASG_YTD';
l_dimension_1                     VARCHAR2(16) := '_PRSI_ASG_YTD';
--Changed to stripe the balances by employer Level 4369280
l_dimension_2                     VARCHAR2(20) := '_PER_PAYE_REF_YTD';
l_found                           VARCHAR2(1);
/* 8520684 */
l_max_stat_balance                NUMBER       := 23;  /* 7691477 */

l_proc                          VARCHAR2(120) := g_package || 'setup_standard_balance_table';
l_index_id                    NUMBER       := 0;

l_dimension_3                     VARCHAR2(50) := '_PER_PAYE_REF_PPSN_YTD'; --6633719

BEGIN





  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);

  l_statutory_balance(1).balance_name  := 'IE Total Deductions';
  l_statutory_balance(2).balance_name  := 'IE Taxable Pay';
  l_statutory_balance(3).balance_name  := 'IE PRSIable Pay';
  l_statutory_balance(4).balance_name  := 'IE Net Tax';
  l_statutory_balance(5).balance_name  := 'IE PRSI Employer';
  l_statutory_balance(6).balance_name  := 'IE PRSI Employee';
  l_statutory_balance(7).balance_name  := 'IE PRSI Insurable Weeks';
-- Bug 3436737 : Added new balances which needs to be archived for
-- severance payment.
  l_statutory_balance(8).balance_name   := 'IE PRSI K Employee Lump Sum';
  l_statutory_balance(9).balance_name   := 'IE PRSI M Employee Lump Sum';
  l_statutory_balance(10).balance_name  := 'IE PRSI K Employer Lump Sum';
  l_statutory_balance(11).balance_name  := 'IE PRSI M Employer Lump Sum';
  l_statutory_balance(12).balance_name  := 'IE PRSI K Term Insurable Weeks';
  l_statutory_balance(13).balance_name  := 'IE PRSI M Term Insurable Weeks';
  l_statutory_balance(14).balance_name  := 'IE Term Health Levy';

/* 7691477 */
  l_statutory_balance(15).balance_name  := 'IE Income Tax Levy Refund Amount';
  l_statutory_balance(16).balance_name  := 'IE Income Tax Levy';
  l_statutory_balance(17).balance_name  := 'IE Parking Levy';

  /* 8520684 */
  l_statutory_balance(18).balance_name  := 'IE Gross Income Adjustment';
  l_statutory_balance(19).balance_name  := 'IE Gross Income';
  l_statutory_balance(20).balance_name  := 'IE BIK Taxable and PRSIable Pay';
  l_statutory_balance(21).balance_name  := 'IE Income Tax Levy First Band';
  l_statutory_balance(22).balance_name  := 'IE Income Tax Levy Second Band';
  l_statutory_balance(23).balance_name  := 'IE Income Tax Levy Third Band';

  hr_utility.set_location('Step = ' || l_proc,30);

  FOR l_index IN 1 .. l_max_stat_balance

  LOOP

    l_dimension := '_ASG_YTD';
    hr_utility.set_location('l_index      = ' || l_index,30);
    hr_utility.set_location('balance_name = ' || l_statutory_balance(l_index).balance_name,30);
    hr_utility.set_location('l_dimension  = ' || l_dimension,30);


    IF l_statutory_balance(l_index).balance_name = 'IE PRSI Insurable Weeks' then
       l_dimension := l_dimension_1;
    END IF;


    /*  Commented to archive _ASG_YTD value instead of _PRSI_ASG_YTD for IE PRSI Employee
    IF l_statutory_balance(l_index).balance_name = 'IE PRSI Employee' THEN
       l_dimension := l_dimension_1;
    END IF;
    */
    l_index_id := l_index_id +1;
    OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,
                               l_dimension);

    FETCH csr_balance_dimension
    INTO  l_statutory_bal_id(l_index_id).defined_balance_id;
    l_statutory_bal_id(l_index_id).balance_name := l_statutory_balance(l_index).balance_name; --4879850
    l_statutory_bal_id(l_index_id).dimension_name := l_dimension; --6633719


    IF csr_balance_dimension%NOTFOUND

    THEN


      l_statutory_bal_id(l_index_id).defined_balance_id := 0;

    END IF;

    CLOSE csr_balance_dimension;

    -- Bug No 2569918 Added for  P35/P60 Reporting
    -- Create entries for PER_YTD defined balances in the l_statutory_bal_id pl/sql table
    --
    l_index_id := l_index_id + 1;
    OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,
                               l_dimension_2);

    FETCH csr_balance_dimension
    INTO  l_statutory_bal_id(l_index_id).defined_balance_id;
    l_statutory_bal_id(l_index_id).balance_name := l_statutory_balance(l_index).balance_name;  -- 4879850
    l_statutory_bal_id(l_index_id).dimension_name := l_dimension_2; --6633719

    IF csr_balance_dimension%NOTFOUND

    THEN


      l_statutory_bal_id(l_index_id).defined_balance_id := 0;

    END IF;

     CLOSE csr_balance_dimension;

    hr_utility.set_location('defined_balance_id = ' || l_statutory_bal_id(l_index_id).defined_balance_id,30);

--6633719
    l_index_id := l_index_id + 1;
    OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,
                               l_dimension_3);

    FETCH csr_balance_dimension
    INTO  l_statutory_bal_id(l_index_id).defined_balance_id;
    l_statutory_bal_id(l_index_id).balance_name := l_statutory_balance(l_index).balance_name;
    l_statutory_bal_id(l_index_id).dimension_name := l_dimension_3; --6633719

    IF csr_balance_dimension%NOTFOUND

    THEN

      l_statutory_bal_id(l_index_id).defined_balance_id := 0;

    END IF;

     CLOSE csr_balance_dimension;
--6633719

  END LOOP;

  hr_utility.set_location('Step = ' || l_proc,40);

  hr_utility.set_location('l_max_stat_balance       = ' || l_max_stat_balance,40);
  hr_utility.set_location('g_max_user_balance_index = ' || g_max_user_balance_index,40);

  FOR l_index IN 1 .. l_index_id

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

       l_archive_index := l_archive_index + 1;

       hr_utility.set_location('l_archive_index = ' || l_archive_index,40);

       g_statutory_balance_table(l_archive_index).defined_balance_id := l_statutory_bal_id(l_index).defined_balance_id;
	 g_statutory_balance_table(l_archive_index).balance_name := l_statutory_bal_id(l_index).balance_name; --4879850
	 g_statutory_balance_table(l_archive_index).database_item_suffix := l_statutory_bal_id(l_index).dimension_name; --6633719


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
  AND    pet.legislation_code = 'IE'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

  CURSOR csr_payroll_type(p_payroll_id       NUMBER,
                          p_effective_date   DATE) IS
  SELECT period_type
  FROM   pay_all_payrolls_f
  WHERE  payroll_id = p_payroll_id
  AND    p_effective_date
  BETWEEN effective_start_date AND effective_end_date;

  CURSOR csr_get_prsi_week_id IS
  SELECT pdb.defined_balance_id
  FROM   pay_defined_balances pdb,
         pay_balance_types pbt,
         pay_balance_dimensions pbd
  WHERE  pbd.dimension_name = '_ASG_YTD'
  AND    pbd.legislation_code = 'IE'
  AND    pbt.balance_name = 'IE PRSI Insurable Weeks'
  AND    pbt.legislation_code = 'IE'
  AND    pdb.balance_type_id = pbt.balance_type_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id
  AND    pdb.legislation_code = 'IE';

  -- 4369280
  -- Cursor to fetch Employer id to stripe the balances.
  CURSOR csr_get_tax_unit_id(p_business_group_id NUMBER,
  			     p_consolidation_set NUMBER,
                             p_start_date    DATE,
                             p_end_date DATE
                            )IS

SELECT org.organization_id
FROM
       pay_all_payrolls_f ppf,
       hr_soft_coding_keyflex flex,
       hr_organization_information org
WHERE  ppf.soft_coding_keyflex_id=flex.soft_coding_keyflex_id
  AND  ppf.business_group_id =p_business_group_id
  AND  org.org_information_context  = 'IE_EMPLOYER_INFO'
  AND  org.organization_id=flex.segment4
  AND  ppf.consolidation_set_id =p_consolidation_set
--  AND  ppf.payroll_id=p_payroll_id
  AND    ppf.effective_start_date <= p_end_date
  AND    ppf.effective_end_date >= p_start_date
  AND    rownum = 1;

  -- Start fix for Bug#8522324
  -- This cursor is to check whether element definition is already archieved
  CURSOR csr_check_archived(p_pact_id NUMBER) IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT NULL
  		FROM pay_action_information pai
  		WHERE pai.action_context_id = p_pact_id
  		AND   pai.action_context_type = 'PA'
  		AND action_information_category  =  'EMEA ELEMENT DEFINITION'
  		AND   rownum = 1
  	    );

   l_archived		      NUMBER(1);
   -- end fix for Bug#8522324
  l_proc                            VARCHAR2(50) := g_package || 'archinit';

  l_assignment_set_id               NUMBER;
  l_bg_id                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               NUMBER;
  l_end_date                        VARCHAR2(30);
  l_payroll_id                      NUMBER;
  l_start_date                      VARCHAR2(30);
  l_tax_credit_value                VARCHAR2(30);
  l_std_cut_off_value               VARCHAR2(30);
  l_payroll_type                    VARCHAR2(30);

BEGIN

--
  hr_utility.set_location('Entering ' || l_proc,10);

  g_archive_pact := p_payroll_action_id;

  OPEN csr_archive_effective_date(p_payroll_action_id);

  FETCH csr_archive_effective_date
  INTO  g_archive_effective_date;

  CLOSE csr_archive_effective_date;

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'ASSIGNMENT_SET'
  , p_token_value       => l_assignment_set_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
  hr_utility.set_location('l_start_date = ' || l_start_date,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

 -- Get Payroll Period Type

  hr_utility.set_location('Getting Period Type of the Payroll', 30);

  OPEN csr_payroll_type(l_payroll_id,
                         g_archive_effective_date);

  FETCH csr_payroll_type INTO l_payroll_type;

  CLOSE csr_payroll_type;

  hr_utility.set_location('l_payroll_type = '|| l_payroll_type, 30);

  IF l_payroll_type in ('Week', 'Bi-Week', 'Lunar Month')  THEN
     l_tax_credit_value  := 'Weekly Tax Credit';
     l_std_cut_off_value := 'Weekly Standard Rate Cutoff';

  ELSE

    l_tax_credit_value  := 'Monthly Tax Credit';
    l_std_cut_off_value := 'Monthly Standard Rate Cutoff';

  END IF;

  hr_utility.set_location('l_tax_credit_value = '|| l_tax_credit_value, 30);
  hr_utility.set_location('l_std_cut_off_value = '|| l_std_cut_off_value, 30);

  -- retrieve ids for tax elements

  OPEN csr_input_value_id('IE PAYE details',l_tax_credit_value);

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_tax_credit_id;

  CLOSE csr_input_value_id;

  hr_utility.set_location('g_tax_credit_id  = '|| to_char(g_tax_credit_id), 30);

  OPEN csr_input_value_id('IE PAYE details',l_std_cut_off_value);

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_std_cut_off_id;

  CLOSE csr_input_value_id;

  hr_utility.set_location('g_std_cut_off_id  = '|| to_char(g_std_cut_off_id), 30);

  OPEN csr_input_value_id('IE PAYE details','Tax Basis');

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_tax_basis_id;

  CLOSE csr_input_value_id;


  OPEN csr_input_value_id('IE PRSI Detail','Contribution Class');

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_prsi_cat_id;

  CLOSE csr_input_value_id;


  OPEN csr_input_value_id('IE PRSI Detail','Subclass');

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_prsi_subcat_id;

  CLOSE csr_input_value_id;

  OPEN csr_input_value_id('IE PRSI Detail','Insurable Weeks');

  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_ins_weeks_id;

  CLOSE csr_input_value_id;

  OPEN csr_get_prsi_week_id;

  FETCH csr_get_prsi_week_id INTO g_prsi_week_id;

  CLOSE csr_get_prsi_week_id;

  OPEN csr_get_tax_unit_id(l_bg_id,l_consolidation_set,l_canonical_start_date,l_canonical_end_date);
  FETCH csr_get_tax_unit_id INTO g_tax_unit_id;
  CLOSE csr_get_tax_unit_id;

  hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
  hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
  hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);


    -- retrieve and archive user defintions from EITs

    g_max_user_balance_index := 0;

    hr_utility.set_location('get_eit_definitions - balances',20);

    pay_ie_legislative_archive.get_eit_definitions (
      p_pactid            => p_payroll_action_id
    , p_business_group_id => l_bg_id
    , p_payroll_pact      => NULL
    , p_effective_date    => l_canonical_start_date
    , p_eit_context       => g_balance_context
    , p_archive           => 'N');

    hr_utility.set_location('get_eit_definitions - elements',20);

    pay_ie_legislative_archive.get_eit_definitions (
      p_pactid            => p_payroll_action_id
    , p_business_group_id => l_bg_id
    , p_payroll_pact      => NULL
    , p_effective_date    => l_canonical_start_date
    , p_eit_context       => g_element_context
    , p_archive           => 'N');

   -- Start fix for Bug#8522324
   l_archived := 0;

  OPEN csr_check_archived(p_payroll_action_id);
  FETCH csr_check_archived INTO l_archived;
  CLOSE csr_check_archived;

  fnd_file.put_line (fnd_file.LOG,' ###  l_archived'||l_archived);
 IF l_archived = 0 THEN
     pay_ie_legislative_archive.setup_element_definitions (
      p_pactid            => p_payroll_action_id
    , p_payroll_pact      => NULL
    , p_business_group_id => l_bg_id
    , p_effective_date    => l_canonical_start_date);
end if;
-- End fix for Bug#8522324

    pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                               , p_payroll_action_id);

  -- setup statutory balances pl/sql table

  pay_ie_legislative_archive.setup_standard_balance_table;

  hr_utility.set_location('Leaving ' || l_proc,20);
--

END archinit;

PROCEDURE archive_employee_details (
  p_assactid             IN NUMBER
, p_assignment_id        IN NUMBER
, p_curr_pymt_ass_act_id IN NUMBER
, p_date_earned          IN DATE
, p_effective_date       IN DATE		-- Bug Fix 4260031
, p_curr_pymt_eff_date   IN DATE
, p_time_period_id       IN NUMBER
, p_record_count         IN NUMBER) IS

l_action_info_id NUMBER;
l_ovn            NUMBER;

l_proc           VARCHAR2(60) := g_package || 'archive_employee_details';

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
  -- , p_curr_eff_date        => g_archive_effective_date  -- archive effective_date
  , p_curr_eff_date        => p_effective_date		-- payroll effective_date    -- Bug Fix 4260031
  , p_date_earned          => p_date_earned             -- payroll date_earned
  , p_curr_pymt_eff_date   => p_curr_pymt_eff_date      -- prepayment effective_date
  , p_tax_unit_id          => NULL                      -- only required for US
  , p_time_period_id       => p_time_period_id          -- payroll time_period_id
  , p_ppp_source_action_id => NULL);
--
  hr_utility.set_location('Leaving ' || l_proc,30);
--
END archive_employee_details;

PROCEDURE archive_ie_employee_details (
  p_assactid             IN NUMBER
, p_assignment_id        IN NUMBER
, p_curr_pymt_ass_act_id IN NUMBER
, p_effective_date       IN DATE
, p_ppsn_override        IN VARCHAR2) IS  --6633719

l_action_info_id NUMBER;
l_ovn            NUMBER;
l_tax_basis      VARCHAR2(20);
l_tax_basis_det  VARCHAR2(20);
l_ins_weeks      NUMBER;
l_run_action_id  NUMBER;
l_prsi_week      NUMBER;
l_prsi_cat       VARCHAR2(10);
l_prsi_subcat    VARCHAR2(10);
l_tax_credit     NUMBER;
l_std_cut_off    NUMBER;
--Bug 4025154 Changing l_firstname and l_lastname to varchar2(80) from varchar2(20)
--as accented characters occupy more than 1 byte.
--
l_firstname      VARCHAR2(80);
l_surname        VARCHAR2(80);
l_dob            VARCHAR2(20);

l_proc           VARCHAR2(60) := g_package || 'archive_ie_employee_details';

-- Bug 2569918
-- Added functions get_first_name,get_last_name and get_dob for P35/P60
-- reporting
-- Used per_all_assignments_f 4555600
FUNCTION get_first_name(p_run_assignment_action_id NUMBER) RETURN VARCHAR2
IS
   CURSOR csr_first_name IS
   SELECT substr(papf.first_name||' '||papf.middle_names,1,20)
   FROM   per_people_f         papf,
          per_assignments_f     paf,
          pay_assignment_actions   paa,
          pay_payroll_actions      ppa
   WHERE  paa.assignment_action_id = p_run_assignment_action_id
   AND    paf.assignment_id        = paa.assignment_id
   AND    paf.person_id            = papf.person_id
   AND    paa.payroll_action_id    = ppa.payroll_action_id
   AND    ppa.effective_date between paf.effective_start_date
                             and     paf.effective_end_date
   AND    ppa.effective_date between papf.effective_start_date
                             and     papf.effective_end_date;
--Bug 4025154 Changing l_first_name to varchar2(80) from varchar2(20)
--as accented characters occupy more than 1 byte.Although substr returns 20 chars
--accented char. occupy greater than 20 bytes.They have been made as 80 for future requirement if any.
 l_first_name  varchar2(80);
--
BEGIN
--
--
  OPEN  csr_first_name;
  FETCH csr_first_name INTO l_first_name;
  CLOSE csr_first_name;
--
  RETURN l_first_name;
--
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_first_name := NULL;
                hr_utility.trace('First Name : NULL ');
                return l_first_name;
--
END get_first_name;

-- Used per_all_assignments_f 4555600
FUNCTION get_last_name(p_run_assignment_action_id NUMBER) RETURN VARCHAR2
IS
   CURSOR csr_last_name is
   SELECT substr(papf.last_name,1,20)
   FROM   per_people_f papf,
          per_assignments_f paf,
          pay_assignment_actions   paa,
          pay_payroll_actions      ppa
   WHERE  paa.assignment_action_id = p_run_assignment_action_id
   AND    paf.assignment_id        = paa.assignment_id
   AND    paf.person_id            = papf.person_id
   AND    paa.payroll_action_id    = ppa.payroll_action_id
   AND    ppa.effective_date between paf.effective_start_date
                             and     paf.effective_end_date
   AND    ppa.effective_date between papf.effective_start_date
                             and     papf.effective_end_date;
--Bug 4025154 Changing l_last_name to varchar2(80) from varchar2(20)
--as accented characters occupy more than 1 byte.

 l_last_name  varchar2(80);
--
BEGIN
--
--
  OPEN  csr_last_name;
  FETCH csr_last_name INTO l_last_name;
  CLOSE csr_last_name;
--
  RETURN l_last_name;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_last_name := NULL;
    hr_utility.trace('Last Name : NULL ');
    RETURN l_last_name;
--
END get_last_name;

FUNCTION get_dob(p_run_assignment_action_id NUMBER) RETURN VARCHAR2
IS

  -- Used per_all_assignments_f 4555600
   CURSOR csr_dob IS
   SELECT to_char(papf.date_of_birth,'dd-mon-yyyy')
   FROM   per_people_f         papf,
          per_assignments_f     paf,
          pay_assignment_actions   paa,
          pay_payroll_actions      ppa
   WHERE  paa.assignment_action_id = p_run_assignment_action_id
   AND    paf.assignment_id        = paa.assignment_id
   AND    paf.person_id            = papf.person_id
   AND    paa.payroll_action_id    = ppa.payroll_action_id
   AND    ppa.effective_date between paf.effective_start_date
                             and     paf.effective_end_date
   AND    ppa.effective_date between papf.effective_start_date
                             and     papf.effective_end_date;
--
--
 l_first_name  varchar2(20);
--
BEGIN
--
--
  OPEN  csr_dob;
  FETCH csr_dob INTO l_dob;
  CLOSE csr_dob;
--
  RETURN l_dob;
--
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_dob := NULL;
                hr_utility.trace('DOB : NULL ');
                return l_dob;
--
END get_dob;



BEGIN

    hr_utility.set_location('Entering ' || l_proc,10);

  -- Retrieve and Archive the IE specific employee details

  l_tax_basis := pay_ie_archive_detail_pkg.get_tax_details (
                              p_run_assignment_action_id => p_curr_pymt_ass_act_id
                             ,p_input_value_id           => g_tax_basis_id
                             ,p_date_earned              => to_char(p_effective_date, 'yyyy/mm/dd'));

  hr_utility.set_location('l_tax_basis = ' || l_tax_basis,40);

  l_prsi_cat := pay_ie_archive_detail_pkg.get_tax_details (
                              p_run_assignment_action_id => p_curr_pymt_ass_act_id
                             ,p_input_value_id           => g_prsi_cat_id
                             ,p_date_earned              => to_char(p_effective_date, 'yyyy/mm/dd'));

  hr_utility.set_location('l_prsi_cat = ' || l_prsi_cat,40);

  l_prsi_subcat := pay_ie_archive_detail_pkg.get_tax_details (
                              p_run_assignment_action_id => p_curr_pymt_ass_act_id
                             ,p_input_value_id           => g_prsi_subcat_id
                             ,p_date_earned              => to_char(p_effective_date, 'yyyy/mm/dd'));

  hr_utility.set_location('l_prsi_subcat = ' || l_prsi_subcat,40);

  l_ins_weeks := pay_ie_archive_detail_pkg.get_tax_details (
                              p_run_assignment_action_id => p_curr_pymt_ass_act_id
                             ,p_input_value_id           => g_ins_weeks_id
                             ,p_date_earned              => to_char(p_effective_date, 'yyyy/mm/dd'));

  hr_utility.set_location('l_ins_weeks = ' || l_ins_weeks,40);

  l_tax_credit := pay_ie_archive_detail_pkg.get_tax_details (
                              p_run_assignment_action_id => p_curr_pymt_ass_act_id
                             ,p_input_value_id           => g_tax_credit_id
                             ,p_date_earned              => to_char(p_effective_date, 'yyyy/mm/dd'));

  hr_utility.set_location('l_tax_credit = ' || l_tax_credit,40);

  l_std_cut_off := pay_ie_archive_detail_pkg.get_tax_details (
                              p_run_assignment_action_id => p_curr_pymt_ass_act_id
                             ,p_input_value_id           => g_std_cut_off_id
                             ,p_date_earned              => to_char(p_effective_date, 'yyyy/mm/dd'));

  hr_utility.set_location('l_std_cut_off = ' || l_std_cut_off,40);

  hr_utility.set_location('g_prsi_week_id = ' || g_prsi_week_id,41);
  hr_utility.set_location('p_curr_pymt_ass_act_id = ' || p_curr_pymt_ass_act_id,42);

  l_prsi_week := pay_balance_pkg.get_value (g_prsi_week_id,
                                            p_curr_pymt_ass_act_id,
                                            false);

  hr_utility.set_location('l_prsi_week = ' || l_prsi_week,45);

  l_firstname := get_first_name(p_curr_pymt_ass_act_id);
  l_surname   := get_last_name(p_curr_pymt_ass_act_id);
  l_dob       := get_dob(p_curr_pymt_ass_act_id);


  IF l_tax_basis = 'IE_CUMULATIVE'

  THEN

    l_tax_basis_det := 'Cumulative';

  ELSIF l_tax_basis = 'IE_EMERGENCY'

  THEN

    l_tax_basis_det := 'Emergency';

  ELSIF l_tax_basis = 'IE_WEEK1_MONTH1'

  THEN

    l_tax_basis_det := 'Week/Month 1';

  ELSIF l_tax_basis = 'IE_EXEMPTION'

  THEN

    l_tax_basis_det := 'Exempt-Cumulative';

  ELSIF l_tax_basis = 'IE_EXEMPT_WEEK_MONTH'

  THEN

    l_tax_basis_det := 'Exempt-Week1/Month1';
-- 6266653
  ELSIF l_tax_basis = 'IE_EMERGENCY_NO_PPS'
  THEN
    l_tax_basis_det := 'Emergency No PPS';

  ELSIF l_tax_basis = 'IE_EXCLUDE'
  THEN
    l_tax_basis_det := 'Exclusion';
  ELSE

    l_tax_basis_det := l_tax_basis;

 END IF;

  hr_utility.set_location('Archiving IE EMPLOYEE DETAILS',50);

  pay_action_information_api.create_action_information (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_assactid
  , p_action_context_type          =>  'AAP'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  p_assignment_id
  , p_effective_date               =>  g_archive_effective_date
  , p_source_id                    =>  NULL
  , p_source_text                  =>  NULL
  , p_action_information_category  =>  'IE EMPLOYEE DETAILS'
  , p_action_information1          =>  NULL
  , p_action_information2          =>  NULL
  , p_action_information3          =>  NULL
  , p_action_information20         =>  p_ppsn_override  --6633719
  , p_action_information21         =>  l_tax_basis_det
  , p_action_information22         =>  l_prsi_cat
  , p_action_information23         =>  l_prsi_subcat
  , p_action_information24         =>  l_prsi_week  --l_ins_weeks
  , p_action_information25         =>  l_dob
  , p_action_information26         =>  l_tax_credit
  , p_action_information27         =>  l_std_cut_off
  , p_action_information28         =>  l_firstname
  , p_action_information29         =>  l_surname);

--
    hr_utility.set_location('Leaving ' || l_proc,60);
--
END archive_ie_employee_details;

PROCEDURE process_balance (p_action_context_id IN NUMBER,
                           p_assignment_id     IN NUMBER,
                           p_source_id         IN NUMBER,
                           p_effective_date    IN DATE,
                           p_balance           IN VARCHAR2,
                           p_dimension         IN VARCHAR2,
                           p_defined_bal_id    IN NUMBER,
                           p_record_count      IN NUMBER,
                           p_tax_unit_id       IN NUMBER)

IS
/*Bug No. 3738576*/
  CURSOR Cur_Act_Contexts IS
  SELECT pac.context_id, pac.context_value
    FROM pay_action_contexts pac, ff_contexts ffc
   WHERE pac.assignment_action_id = p_source_id
     AND ffc.context_name = 'SOURCE_TEXT'
     AND ffc.context_id = pac.context_id;
/*
  SELECT Context_ID,Context_Value
  FROM PAY_ACTION_CONTEXTS
  WHERE Assignment_Action_ID = p_source_id;
*/
  v_Cur_Act_Contexts Cur_Act_Contexts%ROWTYPE;

  -- Added for Bug 2545070 to handle PAYROLL REVERSALS
  CURSOR csr_get_reversal_action_id(
                   c_assg_action_id pay_assignment_actions.assignment_action_id%TYPE) IS
  SELECT max(paa_rev.assignment_action_id)
  FROM   pay_assignment_actions paa_src
        ,pay_assignment_actions paa_rev
        ,pay_assignment_actions paa_cur
        ,pay_payroll_actions    ppa_rev
        ,pay_action_interlocks  pai_rev
  WHERE  paa_cur.assignment_action_id     = c_assg_action_id
  AND    paa_src.source_action_id         = paa_cur.source_action_id
  AND    paa_src.assignment_id            = paa_cur.assignment_id
  AND    pai_rev.locked_action_id         = paa_src.assignment_action_id
  AND    ppa_rev.action_type              = 'V'
  AND    ppa_rev.payroll_action_id        = paa_rev.payroll_action_id
  AND    paa_rev.assignment_id            = paa_src.assignment_id
  AND    paa_rev.assignment_action_id     = pai_rev.locking_action_id;

  l_rev_asg_action_id              NUMBER;
  l_source_id                      NUMBER;

  l_action_info_id                 NUMBER;
  l_balance_value                  NUMBER :=0;   -- 4879850
  l_ovn                            NUMBER;
  l_record_count                   VARCHAR2(10);

  l_proc                           VARCHAR2(50) := g_package || 'process_balance';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('p_source_id      = ' || p_source_id,20);
  hr_utility.set_location('p_balance        = ' || p_balance,20);
  hr_utility.set_location('p_dimension      = ' || p_dimension,20);
  hr_utility.set_location('p_defined_bal_id = ' || p_defined_bal_id,20);
  hr_utility.set_location('p_tax_unit_id = ' || p_tax_unit_id,20);
  hr_utility.set_location('p_assignment_id = ' || p_assignment_id,20);

  -- Added for Bug 2545070 to handle PAYROLL REVERSALS
  OPEN csr_get_reversal_action_id(p_source_id);
  FETCH csr_get_reversal_action_id INTO l_rev_asg_action_id;
  CLOSE csr_get_reversal_action_id;
  l_source_id := NVL(l_rev_asg_action_id,p_source_id);

  hr_utility.set_location('l_source_id      = ' || l_source_id,20);

  OPEN Cur_Act_Contexts;
  FETCH Cur_Act_Contexts INTO v_Cur_Act_Contexts;
  CLOSE Cur_Act_Contexts;

hr_utility.set_location('v_Cur_Act_Contexts.CONTEXT_ID= ' || v_Cur_Act_Contexts.CONTEXT_ID,20);
hr_utility.set_location('v_Cur_Act_Contexts.CONTEXT_VALUE= ' || v_Cur_Act_Contexts.CONTEXT_VALUE,20);

  -- Added if condition for 4879850
-- Instead of checking Balance Name we now check the dimension for passing the Source Text Value to support SOE Balances
-- Defined at BG Level which needs Source Text Context 5192325
--  IF p_balance = 'IE PRSI Insurable Weeks' then
-- Added IE PRSI Insurable weeks since p_dimension is not populated for Statutory Balances
    IF ((p_dimension IS NULL AND p_balance = 'IE PRSI Insurable Weeks') OR (p_dimension in ('_PRSI_ASG_YTD','_PRSI_ASG_PTD','_PER_PAYE_REF_PRSI_YTD','_PRSI_ASG_RUN','_ASG_PAYE_REF_PRSI_RUN'))) THEN
	IF v_Cur_Act_Contexts.CONTEXT_ID is not null and v_Cur_Act_Contexts.CONTEXT_VALUE is not null then
		l_balance_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
                     l_source_id,
                     p_tax_unit_id,
                     null,
                     v_Cur_Act_Contexts.CONTEXT_ID,
                     v_Cur_Act_Contexts.CONTEXT_VALUE,
                     null,
                     null);
	end if;
    else
	l_balance_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
                    l_source_id,
                    p_tax_unit_id,
                    null,
                    null,
                    null,
                    null,
                    null);
    end if;

  hr_utility.set_location('l_balance_value = ' || l_balance_value,20);
  IF p_record_count = 0

  THEN

     l_record_count := NULL;

  ELSE

     l_record_count := p_record_count + 1;
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
    , p_source_id                    =>  l_source_id
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'EMEA BALANCES'
    , p_action_information1          =>  p_defined_bal_id
    , p_action_information2          =>  NULL
    , p_action_information3          =>  NULL
    , p_action_information4          =>  fnd_number.number_to_canonical(l_balance_value) -- Changed by rmakhija for 3574741
    , p_action_information5          =>  l_record_count);

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

-- Added for bug 5387406
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
	-- Added for bug 5387406. This checks for UOM, if it is money set the
	-- format mask to '999999999999999990.00'
	  SELECT decode(g_element_table(l_index).uom, 'M',
                      ltrim(rtrim(to_char(fnd_number.canonical_to_number(rec_element_value.result_value), '999999999999999990.00'))),
                      rec_element_value.result_value)
         INTO l_result_value
         FROM dual;


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

--For bug fix 3567562
--Added a new procedure to get the PAYE reference attributed to payrolls within a consolidation set.
PROCEDURE get_paye_reference(p_consolidation_set PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_ID%type
         		      ,g_paye_ref in out nocopy varchar2
			      ,p_business_group_id varchar2
			      ,p_start_date date
			      ,p_end_date date
			      ,l_error out nocopy varchar2)

is
CURSOR get_payrolls is
SELECT ppf.payroll_id
FROM
       pay_all_payrolls_f ppf
WHERE  ppf.consolidation_set_id=p_consolidation_set
AND    ppf.business_group_id =p_business_group_id
AND    ppf.effective_start_date <= p_end_date
AND    ppf.effective_end_date >= p_start_date
ORDER  by payroll_id;
--4369280
--Changed to handle to architecture for Employer
CURSOR get_paye_reference_details(p_payroll_id varchar2) is
SELECT org.org_information2
FROM
       pay_all_payrolls_f ppf,
       hr_soft_coding_keyflex flex,
       hr_organization_information org
WHERE  ppf.soft_coding_keyflex_id=flex.soft_coding_keyflex_id
  AND  ppf.business_group_id =p_business_group_id
  AND  org.org_information_context  = 'IE_EMPLOYER_INFO'
  AND  org.organization_id=flex.segment4
  AND  ppf.consolidation_set_id =p_consolidation_set
  AND  ppf.payroll_id=p_payroll_id
  AND    ppf.effective_start_date <= p_end_date
  AND    ppf.effective_end_date >= p_start_date;

l_paye_ref   hr_organization_information.org_information2%type;
l_paye_value hr_organization_information.org_information2%type;
l_payroll_action_message varchar2(1000);
c_error exception;
error_message               boolean;
l_proc    CONSTANT VARCHAR2(100):= g_package||'get_paye_reference_details';


begin

   hr_utility.set_location('Entering ' || l_proc,10);

   for l_payroll_id in get_payrolls
   loop
        open get_paye_reference_details(l_payroll_id.payroll_id);
        loop
           fetch get_paye_reference_details into l_paye_ref;
           exit when get_paye_reference_details%notfound;

	       if l_paye_value <> l_paye_ref then
		  raise c_error;
	       else
	          l_paye_value:=l_paye_ref;
		  g_paye_ref:=l_paye_value;
               end if;
        end loop;
        close get_paye_reference_details;
	hr_utility.trace('paye ref='||l_paye_value);
   end loop;

   hr_utility.set_location('Leaving ' || l_proc,40);

exception when c_error then
    l_error := 'Y';
    g_paye_ref:=null;
    fnd_message.set_name('PER','HR_IE_PAYE_EOY_ERROR');
    FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);
    error_message:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','HR_IE_PAYE_EOY_ERROR');

END get_paye_reference;

PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT  NOCOPY VARCHAR2)
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
  g_paye_ref                  VARCHAR2(10);

/*  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'IE'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

  CURSOR csr_payrolls (p_payroll_id           NUMBER,
                       p_consolidation_set_id NUMBER,
                       p_effective_date       DATE) IS
  SELECT ppf.payroll_id
  FROM   pay_all_payrolls_f ppf
  WHERE  ppf.consolidation_set_id = p_consolidation_set_id
  AND    ppf.payroll_id = NVL(p_payroll_id,ppf.payroll_id)
  AND    p_effective_date BETWEEN
          ppf.effective_start_date AND ppf.effective_end_date;


  CURSOR csr_payroll_info(p_payroll_id       NUMBER,
                          p_consolidation_id NUMBER,
                          p_start_date       DATE,
                          p_end_date         DATE,
			  g_paye_ref         VARCHAR2) IS
  SELECT pact.payroll_action_id payroll_action_id,
         pact.effective_date effective_date,
         pact.date_earned date_earned,
         pact.payroll_id,
         org.org_information1 tax_details_ref_no,
         org.org_information2 employer_paye_ref_no,
         ppf.payroll_name payroll_name,
         ppf.period_type period_type,
         pact.pay_advice_message payroll_message
  FROM   pay_payrolls_f ppf,
         pay_payroll_actions pact,
         hr_soft_coding_keyflex flex,
         hr_organization_information org
  WHERE  ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
  AND    org.org_information_context = 'IE_ORG_INFORMATION'
  AND    org.org_information1 = flex.segment1
  AND    ppf.business_group_id = org.organization_id
  AND    pact.payroll_id = ppf.payroll_id
  AND    pact.effective_date BETWEEN
               ppf.effective_start_date AND ppf.effective_end_date
  AND    pact.payroll_id = NVL(p_payroll_id,pact.payroll_id)
  AND    ppf.consolidation_set_id = p_consolidation_id
  AND    pact.effective_date BETWEEN
               p_start_date AND p_end_date
  AND    (pact.action_type = 'P' OR
          pact.action_type = 'U')
  AND    pact.action_status = 'C'
  AND    NOT EXISTS (SELECT NULL
                     FROM   pay_action_information pai
                     WHERE  pai.action_context_id = pact.payroll_action_id
                     AND    pai.action_context_type = 'PA'
		     AND    pai.action_information_category = 'EMEA PAYROLL INFO'
		     AND    pai.action_information5 = g_paye_ref ) -- Bug fix 4001540

  -- Added for bug fix 3567562 to restrict details fetched based on PAYE Reference.
  AND    org.org_information2 = flex.segment3
  AND    org.org_information2 = g_paye_ref;


-- cursor csr_get_org_tax_address
CURSOR csr_get_org_tax_address( c_consolidation_set PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_ID%type
                               , g_paye_ref  HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2%type
        ) IS
SELECT   org_info.org_information3 employer_tax_addr1
        ,org_info.org_information4 employer_tax_addr2
        ,org_info.org_information5 employer_tax_addr3
        ,org_info.org_information6 employer_tax_contact
        ,org_info.org_information7 employer_tax_ref_phone
        --,org_all.name            employer_tax_rep_name
	--Added for bug fix 3567562,mofified source of Employer statutory reporting name
	,org_info.org_information8 employer_tax_rep_name
        ,pcs.business_group_id     business_group_id
         --
  FROM   hr_all_organization_units   org_all
        ,hr_organization_information org_info
        ,pay_consolidation_sets pcs
  WHERE  pcs.consolidation_set_id  = c_consolidation_set
  AND    org_all.organization_id   = pcs.business_group_id
  AND    org_info.organization_id  = org_all.organization_id
  AND    org_info.org_information_context  = 'IE_ORG_INFORMATION'
  -- Added for bug fix 3567562 to restrict details fetched based on PAYE Reference.
  AND    org_info.org_information2 = g_paye_ref ;


--
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
                     AND    pai.action_information_category = 'EMPLOYEE OTHER INFORMATION'); */
--
l_assignment_set_id               NUMBER;
l_bg_id                           NUMBER;
l_canonical_end_date              DATE;
l_canonical_start_date            DATE;
l_consolidation_set               NUMBER;
l_end_date                        VARCHAR2(30);
l_legislation_code                VARCHAR2(30) := 'IE';
l_payroll_id                      NUMBER;
l_start_date                      VARCHAR2(30);
l_tax_period_no                   VARCHAR2(30);
l_error                           varchar2(1) ;


BEGIN

  --hr_utility.trace_on(null,'IEPS');
  hr_utility.set_location('Entering ' || l_proc,10);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'ASSIGNMENT_SET'
  , p_token_value       => l_assignment_set_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  pay_ie_legislative_archive.get_parameters (
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

--Added for bug fix 3567562, call to the procedure to get the PAYE reference value
 get_paye_reference (l_consolidation_set,g_paye_ref,l_bg_id,l_canonical_start_date,l_canonical_end_date,l_error);

if l_error ='Y' then
	sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';
else
    -- Start fix for Bug#8522324
    /* Earlier the follwoing element definition archiever logic was in ARCHIVE_DEINIT procedure. Now the
	element defintion details are required in the archive_code procedure to archieve element's run result
	values. To support retry payroll and assignement actions the same code is placed which will excute
	only during retry process. */
    pay_ie_legislative_archive.setup_element_definitions (
      p_pactid            => pactid
    , p_payroll_pact      => NULL
    , p_business_group_id => l_bg_id
    , p_effective_date    => l_canonical_start_date);
    -- End fix for Bug#8522324

/*FOR tax_info_rec IN csr_get_org_tax_address (l_consolidation_set,g_paye_ref) LOOP
--
pay_action_information_api.create_action_information (
  p_action_information_id        => l_action_info_id
, p_action_context_id            => pactid
, p_action_context_type          => 'PA'
, p_object_version_number        => l_ovn
, p_action_information_category  => 'ADDRESS DETAILS'
, p_action_information1          => tax_info_rec.business_group_id
, p_action_information5          => tax_info_rec.employer_tax_addr1
, p_action_information6          => tax_info_rec.employer_tax_addr2
, p_action_information7          => tax_info_rec.employer_tax_addr3
, p_action_information14         => 'IE Employer Tax Address'
, p_action_information26         => tax_info_rec.employer_tax_contact
, p_action_information27         => tax_info_rec.employer_tax_ref_phone
, p_action_information28         => tax_info_rec.employer_tax_rep_name);
--
END LOOP;



    g_max_user_balance_index := 0;

    pay_ie_legislative_archive.get_eit_definitions (
      p_pactid            => pactid
    , p_business_group_id => l_bg_id
    , p_payroll_pact      => NULL
    , p_effective_date    => l_canonical_start_date
    , p_eit_context       => g_balance_context
    , p_archive           => 'Y');

    pay_ie_legislative_archive.get_eit_definitions (
      p_pactid            => pactid
    , p_business_group_id => l_bg_id
    , p_payroll_pact      => NULL
    , p_effective_date    => l_canonical_start_date
    , p_eit_context       => g_element_context
    , p_archive           => 'Y');

    pay_ie_legislative_archive.setup_element_definitions (
      p_pactid            => pactid
    , p_payroll_pact      => NULL
    , p_business_group_id => l_bg_id
    , p_effective_date    => l_canonical_start_date);

  FOR rec_payrolls in csr_payrolls(l_payroll_id,
                                    l_consolidation_set,
                                    l_canonical_end_date)
  LOOP

    hr_utility.set_location('Calling arch_pay_action_level_data',25);
    --

    pay_emp_action_arch.arch_pay_action_level_data (
          p_payroll_action_id => pactid
              , p_payroll_id        => rec_payrolls.payroll_id
                      , p_effective_date    => l_canonical_end_date);

    --
  END LOOP;

  FOR rec_payroll_info in csr_payroll_info(l_payroll_id,
                                           l_consolidation_set,
                                           l_canonical_start_date,
                                           l_canonical_end_date,
					   g_paye_ref)

  LOOP
    pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                               , rec_payroll_info.payroll_action_id);
    hr_utility.set_location('rec_payroll_info.payroll_action_id   = ' || rec_payroll_info.payroll_action_id,30);
    hr_utility.set_location('rec_payroll_info.tax_details_ref     = ' || rec_payroll_info.tax_details_ref_no,30);
    hr_utility.set_location('rec_payroll_info.employers_paye_ref_no    = ' || rec_payroll_info.employer_paye_ref_no,30);

    hr_utility.set_location('Archiving EMEA PAYROLL INFO',30);

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
    , p_action_information3          =>  l_consolidation_set
    , p_action_information4          =>  rec_payroll_info.tax_details_ref_no
    , p_action_information5          =>  rec_payroll_info.employer_paye_ref_no
    , p_action_information6          =>  NULL);

  END LOOP;


    -- The Payroll level message is archived in the generic archive structure
    -- EMPLOYEE OTHER INFORMATION

    FOR rec_payroll_msg in csr_payroll_mesg(l_payroll_id,
                                            l_canonical_start_date,
                                            l_canonical_end_date)

    LOOP

      IF rec_payroll_msg.payroll_message IS NOT NULL
      THEN
        --
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

    END LOOP;

  sqlstr := 'SELECT DISTINCT person_id
             FROM   per_people_f ppf,
                    pay_payroll_actions ppa
             WHERE  ppa.payroll_action_id = :payroll_action_id
             AND    ppa.business_group_id +0= ppf.business_group_id
             ORDER BY ppf.person_id'; */

if l_payroll_id is null then

     -- Use full cursor not restricting by payroll
     --
     -- Used per_all_assignments_f 4555600
       hr_utility.trace('Range Cursor Not using Payroll Restriction');
       sqlstr := 'SELECT distinct asg.person_id
              FROM per_periods_of_service pos,
                   per_assignments_f      asg,
                   pay_payroll_actions    ppa
             WHERE ppa.payroll_action_id = :payroll_action_id
               AND pos.person_id         = asg.person_id
               AND pos.period_of_service_id = asg.period_of_service_id
               AND pos.business_group_id = ppa.business_group_id
               AND asg.business_group_id = ppa.business_group_id
             ORDER BY asg.person_id';
  else
     --
     -- The Payroll ID was used as parameter, so restrict by this
     --
       hr_utility.trace('Range Cursor using Payroll Restriction');
       sqlstr := 'SELECT DISTINCT ppf.person_id
                  FROM   per_people_f ppf,
                         pay_payroll_actions ppa,
                         per_assignments_f paaf
                  WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND    ppf.business_group_id +0 = ppa.business_group_id
                  AND    paaf.person_id = ppf.person_id
                  AND    paaf.payroll_id = '|| to_char(l_payroll_id) ||
                 ' ORDER BY ppf.person_id';
  end if;

  hr_utility.set_location('Leaving ' || l_proc,40);
end if;

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
  and    map.report_type = 'IEPS'
  and    map.report_format = 'IELDGEN'
  and    map.report_qualifier = 'IE'
  and    par.parameter_name = 'RANGE_PERSON_ID';
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
       act1.assignment_action_id prepaid_action_id,
       act.tax_unit_id tax_unit_id
FROM   pay_payroll_actions ppa,
       pay_payroll_actions appa,
       pay_payroll_actions appa2,
       pay_assignment_actions act,
       pay_assignment_actions act1,
       pay_action_interlocks pai,
       per_assignments_f as1
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
-- AND    ppa.effective_date BETWEEN
AND    appa.effective_date BETWEEN				 -- Bug Fix 4260031
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
                   AND    appa3.report_type = 'IEPS')
ORDER BY act.assignment_id, act.assignment_action_id
FOR UPDATE OF as1.assignment_id;

-- csr_range_pre_assignments is a copy of csr_prepaid_assignments
-- but with a join to pay_population_ranges for performance enhancement
-- stperson and endperson are not needed, uses chunk.
--
CURSOR csr_range_pre_assignments(p_pact_id          NUMBER,
                                 chunk              NUMBER,
                                 p_payroll_id       NUMBER,
                                 p_consolidation_id NUMBER) IS
SELECT act.assignment_id assignment_id,
       act.assignment_action_id run_action_id,
       act1.assignment_action_id prepaid_action_id,
       act.tax_unit_id tax_unit_id
FROM   pay_payroll_actions ppa,
       pay_payroll_actions appa,
       pay_payroll_actions appa2,
       pay_assignment_actions act,
       pay_assignment_actions act1,
       pay_action_interlocks pai,
       per_assignments_f as1,
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
-- AND    ppa.effective_date BETWEEN
AND    appa.effective_date BETWEEN				 -- Bug Fix 4260031
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
                   AND    appa3.report_type = 'IEPS')
ORDER BY act.assignment_id, act.assignment_action_id
FOR UPDATE OF as1.assignment_id;

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

  hr_utility.set_location('Entering ' || l_proc,10);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_ie_legislative_archive.get_parameters (
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
  -- Check that the Range Person settings are on, if so,
   -- use csr_range_pre_assignments. If not, use csr_prepaid_assignments.
   --
 IF range_person_on THEN
   FOR csr_rec IN csr_range_pre_assignments(pactid ,
                                 	    chunk,
                                            l_payroll_id,
                                            l_consolidation_set)

   LOOP

     IF l_prepay_action_id <> csr_rec.prepaid_action_id

     THEN

     SELECT pay_assignment_actions_s.NEXTVAL
     INTO   l_actid
     FROM   dual;

     -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION

     hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,csr_rec.tax_unit_id);

     -- CREATE THE ARCHIVE TO PAYROLL MASTER ASSIGNMENT ACTION INTERLOCK AND
     -- THE ARCHIVE TO PREPAYMENT ASSIGNMENT ACTION INTERLOCK

     hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,20);
     hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id,20);

     hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);

     END IF;

     hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);

     l_prepay_action_id := csr_rec.prepaid_action_id;

   END LOOP;

 ELSE

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

    hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,csr_rec.tax_unit_id);

    -- CREATE THE ARCHIVE TO PAYROLL MASTER ASSIGNMENT ACTION INTERLOCK AND
    -- THE ARCHIVE TO PREPAYMENT ASSIGNMENT ACTION INTERLOCK

    hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,20);
    hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id,20);

    hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);

    END IF;

    hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);

    l_prepay_action_id := csr_rec.prepaid_action_id;

  END LOOP;
END IF;

  hr_utility.set_location('Leaving ' || l_proc,20);

END action_creation;

PROCEDURE archive_code (p_assactid       in number,
                        p_effective_date in date) IS

--6633719
cursor csr_ppsn_override(p_assignment_id NUMBER)
is
select  'Y' PPSN_OVERRIDE  --aei_information1 PPSN_OVERRIDE  --6633719
from per_assignment_extra_info
where assignment_id = p_assignment_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;
--6633719

--Bug Fix 4317512
/* Changed the cursor not to archive Period2 details,when one Prepayment is run for Period1 and
   Period2 togther and Archiver is run for Period1 */

CURSOR csr_assignment_actions(p_locking_action_id NUMBER) IS
SELECT pay.locking_action_id      pre_assignment_action_id, -- Bugfix 4567566
       pay.locked_action_id      master_assignment_action_id,
       assact.assignment_id      assignment_id,
       assact.payroll_action_id  pay_payroll_action_id,
       paa.effective_date        effective_date,
       ppaa.effective_date       pre_effective_date,
       paa.date_earned           date_earned,
       ptp.time_period_id        time_period_id
FROM   pay_action_interlocks pre,
       pay_action_interlocks pay,
       pay_payroll_actions paa,
       pay_payroll_actions ppaa,
       pay_assignment_actions assact,
       pay_assignment_actions passact,
       per_time_periods ptp -- added to fetch correct time period id
WHERE  pre.locked_action_id = pay.locked_action_id
AND    pre.locking_action_id = p_locking_action_id
AND    pre.locked_action_id = assact.assignment_action_id
AND    assact.payroll_action_id = paa.payroll_action_id
AND    paa.action_type in ('R','Q')
AND    pay.locking_action_id = passact.assignment_action_id
AND    passact.payroll_action_id = ppaa.payroll_action_id
AND    ppaa.action_type IN ('P','U')
AND    assact.source_action_id IS NULL
AND    paa.payroll_id = ptp.payroll_id
AND    paa.date_earned between ptp.start_date and ptp.end_date
ORDER BY pay.locked_action_id;

-- Bug Fix 3894307
-- Changed the cursor to get latest child assignment action id
/*CURSOR csr_child_actions(p_master_assignment_action NUMBER,
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
                                       prt1.effective_start_date AND prt1.effective_end_date);*/
-- Bug Fix 3894307
-- New Cursor
CURSOR csr_child_actions(p_assignment_id     NUMBER,
                         p_effective_date    DATE  ) IS
/*SELECT paa.assignment_action_id child_assignment_action_id,
       'S' run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method = 'S'
AND    p_effective_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa)
				          fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
				          paa.assignment_action_id),16)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					  pay_payroll_actions    ppa
				   WHERE  paa.assignment_id = p_assignment_id
				   AND    ppa.payroll_action_id = paa.payroll_action_id
				   AND    (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
				   AND    ppa.effective_date <= p_effective_date
				   AND    ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
				   AND    paa.action_status = 'C')
UNION  */
-- Bug Fix 4260031
SELECT paa.assignment_action_id child_assignment_action_id,
       prt.run_method run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    p_effective_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa) */
				          fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
				          paa.assignment_action_id),16)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					  pay_payroll_actions    ppa
				   WHERE  paa.assignment_id = p_assignment_id
				   AND    ppa.payroll_action_id = paa.payroll_action_id
				   AND    (paa.source_action_id is not null or ppa.action_type in ('I','V'))
				   AND    ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
				   AND    ppa.action_type in ('R', 'Q', 'I', 'V') -- Removed B as run type is not populated 4606580
				   AND    paa.action_status = 'C');

-- Bug Fix 3927328
-- Bug Fix 4260031
/*CURSOR csr_np_children (p_assignment_action_id NUMBER,
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
         prt.effective_start_date AND prt.effective_end_date;*/

-- Bug Fix 3927328 Changed Cursor
/*CURSOR csr_np_children (p_assignment_id        NUMBER,
                        p_effective_date       DATE) IS
SELECT paa.assignment_action_id np_assignment_action_id,
       prt.run_method
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    p_effective_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa)
				          fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
				          paa.assignment_action_id),16))
				   FROM   pay_assignment_actions paa,
					      pay_payroll_actions    ppa
				   WHERE  paa.assignment_id = p_assignment_id
				   AND    ppa.payroll_action_id = paa.payroll_action_id
				   AND    (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
				   AND    ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
				   AND    ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
				   AND    paa.action_status = 'C'); */


l_actid                           NUMBER;
l_action_context_id               NUMBER;
l_action_info_id                  NUMBER(15);
l_assignment_action_id            NUMBER;
l_business_group_id               NUMBER;
l_chunk_number                    NUMBER;
l_date_earned                     DATE;
l_ovn                             NUMBER;
l_person_id                       NUMBER;
l_record_count                    NUMBER;
l_child_count                     NUMBER;
l_salary                          VARCHAR2(10);
l_sequence                        NUMBER;

l_proc                            VARCHAR2(50) := g_package || 'archive_code';

BEGIN
 -- hr_utility.trace_on(null,'test123');
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

  FOR csr_rec IN csr_assignment_actions(p_assactid)

  LOOP

    hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.master_assignment_action_id,20);
    hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' || csr_rec.pre_assignment_action_id,20);
    hr_utility.set_location('csr_rec.assignment_id    = ' || csr_rec.assignment_id,20);
    hr_utility.set_location('csr_rec.date_earned    = ' ||to_char( csr_rec.date_earned,'dd-mon-yyyy'),20);
    hr_utility.set_location('csr_rec.pre_effective_date    = ' ||to_char( csr_rec.pre_effective_date,'dd-mon-yyyy'),20);
    hr_utility.set_location('csr_rec.time_period_id    = ' || csr_rec.time_period_id,20);

  IF l_record_count = 0

  THEN

    pay_ie_legislative_archive.archive_employee_details (
      p_assactid             => p_assactid
    , p_assignment_id        => csr_rec.assignment_id
    , p_curr_pymt_ass_act_id => csr_rec.pre_assignment_action_id  -- prepayment assignment_action_id
    , p_date_earned          => csr_rec.date_earned               -- payroll date_earned
    , p_effective_date       => csr_rec.effective_date            -- payroll effective_date Added for Bug Fix 4260031
    , p_curr_pymt_eff_date   => csr_rec.pre_effective_date        -- prepayment effective_date
    , p_time_period_id       => csr_rec.time_period_id            -- payroll time_period_id
    , p_record_count         => l_record_count );

  END IF;

-- Bug Fix 3894307
  /*FOR csr_child_rec IN csr_child_actions(csr_rec.master_assignment_action_id,
                                         csr_rec.pay_payroll_action_id,
                                         csr_rec.assignment_id,
                                         csr_rec.effective_date)*/

    FOR csr_child_rec IN csr_child_actions(csr_rec.assignment_id,
                                           csr_rec.effective_date)

    LOOP

    -- create additional archive assignment actions and interlocks

      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM dual;

      hr_utility.set_location('csr_child_rec.run_type              = ' || csr_child_rec.run_type,30);
      hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.master_assignment_action_id,30);

      hr_nonrun_asact.insact(
        lockingactid => l_actid
      , assignid     => csr_rec.assignment_id
      , pactid       => g_archive_pact
      , chunk        => l_chunk_number
      , greid        => g_tax_unit_id
      , prepayid     => NULL
      , status       => 'C'
      , source_act   => p_assactid);

    --  Bug Fix 4260031

/*
      IF csr_child_rec.run_type = 'S'

      THEN

        hr_utility.set_location('creating lock3 ' || l_actid || ' to ' || csr_child_rec.child_assignment_action_id,30);

        hr_nonrun_asact.insint(
          lockingactid => l_actid
        , lockedactid  => csr_child_rec.child_assignment_action_id);

        l_action_context_id := l_actid;

        IF l_record_count = 0

        THEN

        pay_ie_legislative_archive.archive_employee_details(
          p_assactid             => l_action_context_id
        , p_assignment_id        => csr_rec.assignment_id
        , p_curr_pymt_ass_act_id => csr_rec.pre_assignment_action_id  -- prepayment assignment_action_id
        , p_date_earned          => csr_rec.date_earned               -- payroll date_earned
	, p_effective_date       => csr_rec.effective_date            -- payroll effective_date Added for Bug Fix 4260031
        , p_curr_pymt_eff_date   => csr_rec.pre_effective_date        -- prepayment effective_date
        , p_time_period_id       => csr_rec.time_period_id          -- payroll time_period_id
        , p_record_count         => l_record_count);

        pay_ie_legislative_archive.archive_ie_employee_details (
          p_assactid             => l_action_context_id
        , p_assignment_id        => csr_rec.assignment_id
        , p_curr_pymt_ass_act_id => csr_child_rec.child_assignment_action_id
        , p_effective_date       => csr_rec.effective_date);


       END IF;

        pay_ie_legislative_archive.get_element_info (
          p_action_context_id       => l_action_context_id
        , p_assignment_id           => csr_rec.assignment_id
        , p_child_assignment_action => csr_child_rec.child_assignment_action_id
        , p_effective_date          => csr_rec.effective_date
        , p_record_count            => l_record_count
        , p_run_method              => 'S');

    END IF;
    */

	--6633719
	l_ppsn_override := NULL;
	OPEN csr_ppsn_override(csr_rec.assignment_id);
	FETCH csr_ppsn_override INTO l_ppsn_override;
	CLOSE csr_ppsn_override;

	hr_utility.set_location('l_ppsn_override = ' || l_ppsn_override,35);
	--6633719

      IF csr_child_rec.run_type in ('N','P')

      THEN

        l_child_count := 0;


-- Bug Fix 3927328
       /*FOR csr_np_rec IN csr_np_children(csr_rec.master_assignment_action_id,
                                          csr_rec.pay_payroll_action_id,
                                          csr_rec.assignment_id,
                                          csr_rec.effective_date)*/

	/*FOR csr_np_rec IN csr_np_children(csr_rec.assignment_id,
                                          csr_rec.effective_date)

        LOOP*/

          hr_utility.set_location('creating lock4 ' || l_actid || ' to ' || csr_child_rec.child_assignment_action_id,30);

          hr_nonrun_asact.insint(
            lockingactid => l_actid
          , lockedactid  => csr_child_rec.child_assignment_action_id);

          IF l_child_count = 0

          THEN

          pay_ie_legislative_archive.archive_ie_employee_details (
            p_assactid             => l_action_context_id
          , p_assignment_id        => csr_rec.assignment_id
          , p_curr_pymt_ass_act_id => csr_child_rec.child_assignment_action_id
          , p_effective_date       => csr_rec.effective_date
	    , p_ppsn_override	     => l_ppsn_override);   --6633719

          END IF;

          pay_ie_legislative_archive.get_element_info (
            p_action_context_id       => l_action_context_id
          , p_assignment_id           => csr_rec.assignment_id
          , p_child_assignment_action => csr_child_rec.child_assignment_action_id
          , p_effective_date          => csr_rec.effective_date
          , p_record_count            => l_record_count
          , p_run_method              => csr_child_rec.run_type);

          l_child_count := l_child_count + 1;


        --END LOOP;

      END IF;

    -- Both User and Statutory Balances are archived for all Separate Payment assignment actions
    -- and the last (i.e. highest action_sequence) Process Separately assignment action
    -- (EMEA BALANCES)

    -- archive user balances

      hr_utility.set_location('Archive User Balances - Starting',60);
      hr_utility.set_location('g_max_user_balance_index = '|| g_max_user_balance_index,60);

      FOR l_index IN 1 .. g_max_user_balance_index

      LOOP

        pay_ie_legislative_archive.process_balance (
          p_action_context_id => l_action_context_id
        , p_assignment_id     => csr_rec.assignment_id
        , p_source_id         => csr_child_rec.child_assignment_action_id
        , p_effective_date    => csr_rec.effective_date
        , p_balance           => g_user_balance_table(l_index).balance_name
        , p_dimension         => g_user_balance_table(l_index).database_item_suffix
        , p_defined_bal_id    => g_user_balance_table(l_index).defined_balance_id
        , p_record_count      => l_record_count
        , p_tax_unit_id       => g_tax_unit_id);

      END LOOP;

      hr_utility.set_location('Archive User Balances - Complete',60);

      -- archive statutory balances

      hr_utility.set_location('Archive Statutory Balances - Starting',70);
      hr_utility.set_location('g_max_statutory_balance_index = '|| g_max_statutory_balance_index,70);

      FOR l_index IN 1 .. g_max_statutory_balance_index

      LOOP

        hr_utility.set_location('l_index = ' || l_index,70);
--6633719
        IF g_statutory_balance_table(l_index).database_item_suffix <> '_PER_PAYE_REF_PPSN_YTD'
        OR (l_ppsn_override IS NOT NULL
            AND g_statutory_balance_table(l_index).database_item_suffix = '_PER_PAYE_REF_PPSN_YTD')
        THEN
--6633719
        hr_utility.set_location('AssignmentID = ' || csr_rec.assignment_id,70);
        hr_utility.set_location('suffix = '||g_statutory_balance_table(l_index).database_item_suffix,70);
	  hr_utility.set_location('Balance Name = '||g_statutory_balance_table(l_index).balance_name,70);

        pay_ie_legislative_archive.process_balance (
          p_action_context_id => l_action_context_id
        , p_assignment_id     => csr_rec.assignment_id
        , p_source_id         => csr_child_rec.child_assignment_action_id
        , p_effective_date    => csr_rec.effective_date
        , p_balance           => g_statutory_balance_table(l_index).balance_name
        , p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
        , p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
        , p_record_count      => l_record_count
        , p_tax_unit_id       => g_tax_unit_id);
        END IF;

      END LOOP;

        hr_utility.set_location('Archive Statutory Balances - Complete',70);
     /*****************************************************************
     ** Below call is to address bug #8522324.
     ** It archives the payments and deductions details for the employee
     ** for the given assignment_action_id.
     *****************************************************************/
     PAY_IE_LEGISLATIVE_ARCHIVE.get_pay_deduct_element_info (p_assactid);

     hr_utility.set_location('Archive Payments and Deductions data - Complete',75);

    END LOOP; -- child assignment actions

    l_record_count := l_record_count + 1;


  END LOOP;

hr_utility.set_location('Leaving '|| l_proc,80);

END archive_code;

Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER) IS


  l_proc    CONSTANT VARCHAR2(50):= g_package||'archive_deinit';

  l_archived		      NUMBER(1);
  l_ovn                       NUMBER(15);
  l_request_id                NUMBER;
  l_action_info_id            NUMBER(15);
  l_business_group_id         NUMBER;
  g_paye_ref                  VARCHAR2(10);

  CURSOR csr_check_archived(p_pact_id NUMBER) IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT NULL
  		FROM pay_action_information pai
  		WHERE pai.action_context_id = p_pact_id
  		AND   pai.action_context_type = 'PA'
		AND action_information_category  <>  'EMEA ELEMENT DEFINITION' --  Bug#8522324
  		AND   rownum = 1
  	       );
  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'IE'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

  CURSOR csr_payrolls (p_payroll_id           NUMBER,
                       p_consolidation_set_id NUMBER,
                       p_effective_date       DATE) IS
  SELECT ppf.payroll_id
  FROM   pay_all_payrolls_f ppf
  WHERE  ppf.consolidation_set_id = p_consolidation_set_id
  AND    ppf.payroll_id = NVL(p_payroll_id,ppf.payroll_id)
  AND    p_effective_date BETWEEN
          ppf.effective_start_date AND ppf.effective_end_date;

--4369280
-- Changed to handle new employer architecture
  CURSOR csr_payroll_info(p_pact_id          NUMBER,
  			  p_payroll_id       NUMBER,
                          p_consolidation_id NUMBER,
                          p_start_date       DATE,
                          p_end_date         DATE,
			  g_paye_ref         VARCHAR2) IS
  SELECT pact.payroll_action_id payroll_action_id,
         pact.effective_date effective_date,
         pact.date_earned date_earned,
         pact.payroll_id,
         org.org_information1 tax_details_ref_no,
         org.org_information2 employer_paye_ref_no,
         ppf.payroll_name payroll_name,
         ppf.period_type period_type,
         pact.pay_advice_message payroll_message
  FROM   pay_payrolls_f ppf,
         pay_payroll_actions pact,
         hr_soft_coding_keyflex flex,
         hr_organization_information org
  WHERE  ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
  AND    org.org_information_context = 'IE_EMPLOYER_INFO'
  AND    org.organization_id = flex.segment4
--  AND    ppf.business_group_id = org.organization_id
  AND    pact.payroll_id = ppf.payroll_id
  AND    pact.effective_date BETWEEN
               ppf.effective_start_date AND ppf.effective_end_date
  AND    pact.payroll_id = NVL(p_payroll_id,pact.payroll_id)
  AND    ppf.consolidation_set_id = p_consolidation_id
  AND    (pact.action_type = 'P' OR
          pact.action_type = 'U')
  AND    pact.action_status = 'C'
  AND    exists  		   (SELECT NULL
  				    FROM   pay_assignment_actions paa,
  				    	   pay_action_interlocks pai,
  				    	   pay_assignment_actions paa_arc
  				    WHERE  pai.locked_action_id = paa.assignment_action_id
  				    AND    pai.locking_action_id = paa_arc.assignment_action_id
  				    AND    paa_arc.payroll_action_id = p_pact_id
  				    AND    paa.payroll_action_id  = pact.payroll_action_id)
  AND    NOT EXISTS (SELECT NULL
                     FROM   pay_action_information pai
                     WHERE  pai.action_context_id = pact.payroll_action_id
                     AND    pai.action_context_type = 'PA'
		     AND    pai.action_information_category = 'EMEA PAYROLL INFO'
		     AND    pai.action_information5 = g_paye_ref ) -- Bug fix 4001540

  -- Added for bug fix 3567562 to restrict details fetched based on PAYE Reference.
--  AND    org.org_information2 = flex.segment3
  AND    org.org_information2 = g_paye_ref;


-- cursor csr_get_org_tax_address
CURSOR csr_get_org_tax_address( c_consolidation_set PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_ID%type
                               , g_paye_ref  HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2%type
        ) IS
SELECT   hrl.address_line_1 employer_tax_addr1
        ,hrl.address_line_2 employer_tax_addr2
        ,hrl.address_line_3 employer_tax_addr3
        ,org_info.org_information4 employer_tax_contact
        ,hrl.telephone_number_1 employer_tax_ref_phone
        --,org_all.name            employer_tax_rep_name
	--Added for bug fix 3567562,mofified source of Employer statutory reporting name
	,org_all.name employer_tax_rep_name
        ,pcs.business_group_id     business_group_id
         --
  FROM   hr_all_organization_units   org_all
        ,hr_organization_information org_info
        ,pay_consolidation_sets pcs
        ,hr_locations_all hrl
  WHERE  pcs.consolidation_set_id  = c_consolidation_set
  AND    org_all.business_group_id   = pcs.business_group_id
  AND    org_info.organization_id  = org_all.organization_id
  --Changed to handle new Employer architecture(4369280)
  AND    org_info.org_information_context  = 'IE_EMPLOYER_INFO'

  AND   org_all.location_id = hrl.location_id (+)
  -- Added for bug fix 3567562 to restrict details fetched based on PAYE Reference.
  AND    org_info.org_information2 = g_paye_ref ;


--
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
l_legislation_code                VARCHAR2(30) := 'IE';
l_payroll_id                      NUMBER;
l_start_date                      VARCHAR2(30);
l_tax_period_no                   VARCHAR2(30);
l_error                           varchar2(1) ;


BEGIN

  --hr_utility.trace_on(null,'IEPS');
  hr_utility.set_location('Entering ' || l_proc,10);

  l_archived := 0;

  OPEN csr_check_archived(p_payroll_action_id);
  FETCH csr_check_archived INTO l_archived;
  CLOSE csr_check_archived;
  fnd_file.put_line (fnd_file.LOG,' ###  l_archived'||l_archived);

IF l_archived = 0 THEN

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'PAYROLL'
  , p_token_value       => l_payroll_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'CONSOLIDATION'
  , p_token_value       => l_consolidation_set);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'ASSIGNMENT_SET'
  , p_token_value       => l_assignment_set_id);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_ie_legislative_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

  pay_ie_legislative_archive.get_parameters (
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

--Added for bug fix 3567562, call to the procedure to get the PAYE reference value
 get_paye_reference (l_consolidation_set,g_paye_ref,l_bg_id,l_canonical_start_date,l_canonical_end_date,l_error);

if l_error ='Y' then
   NULL;
else


FOR tax_info_rec IN csr_get_org_tax_address (l_consolidation_set,g_paye_ref) LOOP
--
pay_action_information_api.create_action_information (
  p_action_information_id        => l_action_info_id
, p_action_context_id            => p_payroll_action_id
, p_action_context_type          => 'PA'
, p_object_version_number        => l_ovn
, p_action_information_category  => 'ADDRESS DETAILS'
, p_action_information1          => tax_info_rec.business_group_id
, p_action_information5          => tax_info_rec.employer_tax_addr1
, p_action_information6          => tax_info_rec.employer_tax_addr2
, p_action_information7          => tax_info_rec.employer_tax_addr3
, p_action_information14         => 'IE Employer Tax Address'
, p_action_information26         => tax_info_rec.employer_tax_contact
, p_action_information27         => tax_info_rec.employer_tax_ref_phone
, p_action_information28         => tax_info_rec.employer_tax_rep_name);
--
END LOOP;



    g_max_user_balance_index := 0;

    pay_ie_legislative_archive.get_eit_definitions (
      p_pactid            => p_payroll_action_id
    , p_business_group_id => l_bg_id
    , p_payroll_pact      => NULL
    , p_effective_date    => l_canonical_start_date
    , p_eit_context       => g_balance_context
    , p_archive           => 'Y');

    pay_ie_legislative_archive.get_eit_definitions (
      p_pactid            => p_payroll_action_id
    , p_business_group_id => l_bg_id
    , p_payroll_pact      => NULL
    , p_effective_date    => l_canonical_start_date
    , p_eit_context       => g_element_context
    , p_archive           => 'Y');

   /* commented for Bug#8522324 since it is already archieved in archinit or in
   range code depends on whether it is a retry   process or not */
    /*pay_ie_legislative_archive.setup_element_definitions (
      p_pactid            => p_payroll_action_id
    , p_payroll_pact      => NULL
    , p_business_group_id => l_bg_id
    , p_effective_date    => l_canonical_start_date);    */

  FOR rec_payrolls in csr_payrolls(l_payroll_id,
                                    l_consolidation_set,
                                    l_canonical_end_date)
  LOOP

    hr_utility.set_location('Calling arch_pay_action_level_data',25);
    --

    pay_emp_action_arch.arch_pay_action_level_data (
          p_payroll_action_id => p_payroll_action_id
              , p_payroll_id        => rec_payrolls.payroll_id
                      , p_effective_date    => l_canonical_end_date);

    --
  END LOOP;

  FOR rec_payroll_info in csr_payroll_info(p_payroll_action_id,
  				           l_payroll_id,
                                           l_consolidation_set,
                                           l_canonical_start_date,
                                           l_canonical_end_date,
					   g_paye_ref)

  LOOP
    pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                               , rec_payroll_info.payroll_action_id);
    hr_utility.set_location('rec_payroll_info.payroll_action_id   = ' || rec_payroll_info.payroll_action_id,30);
    hr_utility.set_location('rec_payroll_info.tax_details_ref     = ' || rec_payroll_info.tax_details_ref_no,30);
    hr_utility.set_location('rec_payroll_info.employers_paye_ref_no    = ' || rec_payroll_info.employer_paye_ref_no,30);

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
    , p_action_information3          =>  l_consolidation_set
    , p_action_information4          =>  rec_payroll_info.tax_details_ref_no
    , p_action_information5          =>  rec_payroll_info.employer_paye_ref_no
    , p_action_information6          =>  NULL);

  END LOOP;


    -- The Payroll level message is archived in the generic archive structure
    -- EMPLOYEE OTHER INFORMATION

    FOR rec_payroll_msg in csr_payroll_mesg(l_payroll_id,
                                            l_canonical_start_date,
                                            l_canonical_end_date)

    LOOP

      IF rec_payroll_msg.payroll_message IS NOT NULL
      THEN
      --
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
end if;
END IF;
END ARCHIVE_DEINIT;

END;

/
