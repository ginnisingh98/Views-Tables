--------------------------------------------------------
--  DDL for Package Body PAY_IN_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_PAYSLIP_ARCHIVE" AS
/* $Header: pyinparc.pkb 120.30.12010000.12 2010/02/19 08:22:40 mdubasi ship $ */

  ----------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
  ----------------------------------------------------------------------+

  g_archive_pact         NUMBER;
  g_package              CONSTANT VARCHAR2(100) := 'pay_in_payslip_archive.';
  g_debug                BOOLEAN;
  TYPE pf_org IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE pt_state IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

  g_pf_org_id         pf_org;
  g_pa_act_id         pf_org;
  g_cnt_pf            NUMBER;

  g_esi_org_id        pf_org;
  g_esi_act_id        pf_org;
  g_cnt_esi           NUMBER;

  g_pt_org_id         pf_org;
  g_pt_act_id         pf_org;
  g_pt_jur_code       pt_state;
  g_cnt_pt            NUMBER;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : RANGE_CODE                                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns a sql string to select a     --
  --                  range of assignments eligible for archival.         --
  --                  It calls pay_apac_payslip_archive.range_code that   --
  --                  archives the EIT definition and payroll level data  --
  --                  (Messages, employer address details etc)            --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : p_sql                  VARCHAR2                     --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE range_code(
                        p_payroll_action_id   IN  NUMBER
                       ,p_sql                 OUT NOCOPY VARCHAR2
                      )
  IS
  --

    l_procedure  VARCHAR2(100);
    l_message    VARCHAR2(255);
  --
  BEGIN
  --

    l_procedure  := g_package || 'range_code';
    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    --------------------------------------------------------------------------------+
    -- Call to range_code from common apac package 'pay_apac_payslip_archive'
    -- to archive the payroll action level data  and EIT defintions.
    --------------------------------------------------------------------------------+

    pay_apac_payslip_archive.range_code
                              (
                                p_payroll_action_id => p_payroll_action_id
                              );

    -- Call core package to return SQL string to SELECT a range
    -- of assignments eligible for archival
    --
    pay_in_utils.set_location(g_debug,l_procedure,20);

    pay_core_payslip_utils.range_cursor(p_payroll_action_id
                                       ,p_sql);

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END range_code;


/*--------------------------------------------------------------------------
  -- Name           : GET_PARAMETER					  --
  -- Type           : FUNCTION						  --
  -- Access         : Public						  --
  -- Description    : This function returns the payroll_id for the        --
  --		      payroll_action				          --
  -- Parameters     :                                                     --
  --             IN : p_name             VARCHAR2			  --
                      p_leg_parameters   VARCHAR2                         --
  --         Returns:                    VARCHAR2                         --
  -------------------------------------------------------------------------- */

  FUNCTION get_parameter
  (
    p_name        IN VARCHAR2,
    p_leg_parameters IN VARCHAR2
  )  RETURN VARCHAR2 IS

    start_ptr NUMBER;
    end_ptr   NUMBER;
    token_val pay_payroll_actions.legislative_parameters%TYPE;
    par_value pay_payroll_actions.legislative_parameters%TYPE;

   BEGIN

   token_val := p_name || '=';

   start_ptr := instr(p_leg_parameters, token_val) + length(token_val);
   end_ptr   := instr(p_leg_parameters, ' ', start_ptr);

   /* if there is no spaces, then use the length of the string */
   IF end_ptr = 0 THEN
     end_ptr := length(p_leg_parameters) + 1;
   END IF;

   IF instr(p_leg_parameters, token_val) = 0 THEN
     par_value := NULL;
   ELSE
     par_value := substr(p_leg_parameters, start_ptr, end_ptr - start_ptr);
   END IF;

   RETURN par_value;

END get_parameter;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : INITIALIZATION_CODE                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to set global contexts.      --
  --                  The globals used are PL/SQL tables                  --
  --                  i.e.(g_user_balance_table and g_element_table)      --
  --                  It calls the procedure                              --
  --                  pay_apac_archive.initialization_code that actially  --
  --                  sets the global variables and populates the global  --
  --                  tables.                                             --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------
  --


  PROCEDURE initialization_code (
                                  p_payroll_action_id  IN NUMBER
                                )
  IS
  --
    l_procedure  VARCHAR2(100) ;
    l_message    VARCHAR2(255);
  --
    l_payroll_id NUMBER;
    leg_param    pay_payroll_actions.legislative_parameters%TYPE;
    l_ppa_payroll_id pay_payroll_actions.payroll_id%TYPE;
    l_pactid  pay_payroll_actions.payroll_action_id%TYPE;
  --
  BEGIN
  --
    l_procedure  :=  g_package || 'initialization_code';

    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

--------------------------------------------------------------------------
-- Code to update the payroll_id in the pay_payroll_actions tabel.
--------------------------------------------------------------------------

   SELECT legislative_parameters,payroll_id
     INTO leg_param,l_ppa_payroll_id
     FROM pay_payroll_actions
    WHERE payroll_action_id = p_payroll_action_id ;

   l_payroll_id := get_parameter('PAYROLL', leg_param);

   -- Update the Payroll Action with the Payroll ID

   IF l_ppa_payroll_id IS NULL THEN

      UPDATE pay_payroll_actions
         SET payroll_id = l_payroll_id
       WHERE payroll_action_id = p_payroll_action_id;

   END IF;

    g_archive_pact := p_payroll_action_id;

    ------------------------------------------------------------------+
    -- Call to common package procedure pay_apac_payslip_archive.
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    ------------------------------------------------------------------+

    pay_apac_payslip_archive.initialization_code(
                                                  p_payroll_action_id => p_payroll_action_id
                                                );

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
  --
  EXCEPTION
    WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END initialization_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETERS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure determines the globals applicable    --
  --                  through out the tenure of the process               --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 14-Feb-2006    lnagaraj   Initial Version                      --
  --------------------------------------------------------------------------

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

  l_procedure                      VARCHAR2(50);

BEGIN

 l_procedure :=  g_package || 'get_parameters';

 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


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

  IF g_debug THEN
     pay_in_utils.trace('Token Name  ',p_token_name);
     pay_in_utils.trace('Token Value ',p_token_value);
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);


END get_parameters;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_ACTION_CODE                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure further restricts the assignment_id's--
  --                  returned by range_code.                             --
  --                  It filters the assignments selected by range_code   --
  --                  procedure.                                          --
  --                  Since the Payslip is given for each prepayment,the  --
  --                  data should be archived for each prepayment.        --
  --                  So,the successfully completed prepayments are       --
  --                  selected and locked by the archival action          --
  --                  All the successfully completed prepayments are      --
  --                  selected and locked by archival to make the core    --
  --                  'Choose Payslip' work for IN.                       --
  --                   The archive will not pickup already archived       --
  --                   prepayments                                        --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --                  p_start_person         NUMBER                       --
  --                  p_end_person           NUMBER                       --
  --                  p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE assignment_action_code (
                                     p_payroll_action_id   IN NUMBER
                                    ,p_start_person        IN NUMBER
                                    ,p_end_person          IN NUMBER
                                    ,p_chunk               IN NUMBER
                                   )
  IS
  --
    l_procedure                 VARCHAR2(100);
    l_actid                     NUMBER;
    l_payroll_id                NUMBER;
    l_bg_id                     NUMBER;
    l_end_date                  VARCHAR2(20);
    l_start_date                VARCHAR2(20);
    l_consolidation_set         VARCHAR2(30);
    l_canonical_end_date        DATE;
    l_canonical_start_date       DATE;
    l_message                   VARCHAR2(255);

   CURSOR csr_bal_init(p_payroll_id NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE,
                       p_consolidation_set_id NUMBER) IS
   SELECT paa_init.assignment_id,
          paa_init.assignment_action_id
     FROM pay_assignment_actions paa_init,
          pay_payroll_actions ppa_init,
          per_all_assignments_f paf
    WHERE ppa_init.payroll_action_id = paa_init.payroll_action_id
      AND ppa_init.action_type='I'
      AND ppa_init.business_group_id = l_bg_id
      AND paf.business_group_id = l_bg_id
      AND (paf.payroll_id = p_payroll_id OR p_payroll_id IS NULL)
      AND ppa_init.consolidation_set_id = p_consolidation_set_id
      AND    paf.person_id BETWEEN
           p_start_person AND p_end_person
      AND paf.assignment_id = paa_init.assignment_id
      AND ppa_init.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
      AND ppa_init.effective_date BETWEEN p_start_date AND p_end_date
      AND paa_init.action_sequence = pay_in_utils.get_max_act_sequence(paa_init.assignment_id
                                                                      ,'I'
                                                                      ,ppa_init.effective_date
                                                                       )
      AND NOT EXISTS (SELECT NULL
                       FROM pay_assignment_actions paa_arch
                         ,pay_payroll_actions ppa_arch
                         ,pay_action_interlocks intk
                    WHERE paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                      AND intk.locked_action_id = paa_init.assignment_action_id
                      AND intk.locking_action_id = paa_arch.assignment_action_id
                      AND paf.assignment_id = paa_arch.assignment_id
                      AND ppa_arch.action_type = 'X'
                      AND ppa_arch.report_type ='IN_PAYSLIP_ARCHIVE'
                      AND ppa_arch.report_qualifier='IN')
  ORDER BY paa_init.assignment_id,paa_init.assignment_action_id;
  --
  BEGIN
  --

    l_procedure  :=  g_package || 'assignment_action_code';

    g_debug := hr_utility.debug_enabled;

    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    get_parameters(  p_payroll_action_id => p_payroll_action_id
                   , p_token_name        => 'PAYROLL'
                   , p_token_value       => l_payroll_id);

    get_parameters(  p_payroll_action_id => p_payroll_action_id
                   , p_token_name        => 'BG_ID'
                   , p_token_value       => l_bg_id);

    get_parameters ( p_payroll_action_id => p_payroll_action_id
                   , p_token_name        => 'START_DATE'
                   , p_token_value       => l_start_date);

    get_parameters ( p_payroll_action_id => p_payroll_action_id
                   , p_token_name        => 'END_DATE'
                   , p_token_value       => l_end_date);

    get_parameters ( p_payroll_action_id => p_payroll_action_id
                   , p_token_name        => 'CONSOLIDATION'
                   , p_token_value       => l_consolidation_set);

    l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
    l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

    pay_in_utils.set_location(g_debug,l_procedure,20);
    -- Call core package to create assignment actions
    pay_core_payslip_utils.action_creation (
                                             p_payroll_action_id
                                            ,p_start_person
                                            ,p_end_person
                                            ,p_chunk
                                            ,'IN_PAYSLIP_ARCHIVE'
                                            ,'IN');
    pay_in_utils.set_location(g_debug,l_procedure,30);

    IF g_debug THEN
       pay_in_utils.trace('Canonical Start and End Date ',l_canonical_start_date||' '||l_canonical_end_date );
    END IF;

    FOR i in  csr_bal_init (l_payroll_id,l_canonical_start_date,l_canonical_end_date,l_consolidation_set)
    LOOP
      SELECT pay_assignment_actions_s.NEXTVAL
        INTO   l_actid
        FROM   dual;

       -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE 'I' ASSIGNMENT ACTION

       hr_nonrun_asact.insact(l_actid,i.assignment_id,p_payroll_action_id,p_chunk,NULL);

       -- CREATE THE ARCHIVE ACTION TO 'I' interlock
       hr_nonrun_asact.insint(l_actid,i.assignment_action_id);

    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
    --
  EXCEPTION
    --
  WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
    --
  END assignment_action_code;

    --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ACCRUAL_DETAILS                             --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure is used to archive accrual details   --
  --                  for a given assignment_action_id.                   --
  --                  It calls per_accrual_calc_functions.get_net_accrual --
  --                  to get the net_accrual for the given assignment_id  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id       NUMBER                    --
  --                  p_time_period_id          NUMBER                    --
  --                  p_assignment_id           NUMBER                    --
  --                  p_date_earned             DATE                      --
  --                  p_effective_date          DATE                      --
  --                  p_assact_id               NUMBER                    --
  --                  p_assignment_action_id    NUMBER                    --
  --                  p_period_end_date         DATE                      --
  --                  p_period_start_date       DATE                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_accrual_details (
                                      p_payroll_action_id    IN NUMBER
                                     ,p_time_period_id       IN NUMBER
                                     ,p_assignment_id        IN NUMBER
                                     ,p_date_earned          IN DATE
                                     ,p_effective_date       IN DATE
                                     ,p_assact_id            IN NUMBER
                                     ,p_assignment_action_id IN NUMBER
                                     ,p_period_end_date      IN DATE
                                     ,p_period_start_date    IN DATE
                                    )
  IS
  --

    -- Cursor to get the Leave Balance Details .

    CURSOR  csr_leave_balance
    IS
    --
      SELECT  pap.accrual_plan_name                                                          accrual_plan_name
             ,hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',pap.accrual_category) accrual_category
             ,pap.accrual_units_of_measure                                                   accrual_uom
             ,ppa.payroll_id                                                                 payroll_id
             ,pap.business_group_id                                                          business_group_id
             ,pap.accrual_plan_id                                                            accrual_plan_id
      FROM    pay_accrual_plans             pap
             ,pay_element_types_f           pet
             ,pay_element_links_f           pel
             ,pay_element_entries_f         pee
             ,pay_assignment_actions        paa
             ,pay_payroll_actions           ppa
      WHERE   pet.element_type_id         = pap.accrual_plan_element_type_id
      AND     pel.element_type_id         = pet.element_type_id
      AND     pee.element_link_id         = pel.element_link_id
      AND     paa.assignment_id           = pee.assignment_id
      AND     ppa.payroll_action_id       = paa.payroll_action_id
      AND     ppa.action_type            IN ('R','Q')
      AND     ppa.action_status           = 'C'
      AND     ppa.date_earned       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
      AND     ppa.date_earned       BETWEEN pel.effective_start_date
                                    AND     pel.effective_end_date
      AND     ppa.date_earned       BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
      AND     paa.assignment_id           = p_assignment_id
      AND     paa.assignment_action_id    = p_assignment_action_id;
    --

    l_action_info_id             NUMBER;
    l_accrual_plan_id            pay_accrual_plans.accrual_plan_id%type;
    l_accrual_plan_name          pay_accrual_plans.accrual_plan_name%type;
    l_accrual_category           pay_accrual_plans.accrual_category%type;
    l_accrual_uom                pay_accrual_plans.accrual_units_of_measure%type;
    l_payroll_id                 pay_payrolls_f.payroll_id%type;
    l_business_group_id          NUMBER;
    l_effective_date             DATE;
    l_annual_leave_balance       NUMBER;
    l_ovn                        NUMBER;
    l_leave_taken                NUMBER;
    l_start_date                 DATE;
    l_end_date                   DATE;
    l_accrual_end_date           DATE;
    l_accrual                    NUMBER;
    l_total_leave_taken          NUMBER;
    l_procedure                  VARCHAR2(100);
    l_message   VARCHAR2(255);
  --
  BEGIN
  --

    l_procedure := g_package || 'archive_accrual_details';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Payroll Action id  ',p_payroll_action_id);
       pay_in_utils.trace('Time Period id  ',p_time_period_id);
       pay_in_utils.trace('Assignment id  ',p_assignment_id);
       pay_in_utils.trace('Date Earned  ',p_date_earned);
       pay_in_utils.trace('Action Context id  ',p_assact_id);
       pay_in_utils.trace('Assignment Action id  ',p_assignment_action_id);
       pay_in_utils.trace('Period End Date ',p_period_end_date);
       pay_in_utils.trace('Period Start Date  ',p_period_start_date);
       pay_in_utils.trace('**************************************************','********************');
    END IF;


    FOR rec IN csr_leave_balance
    LOOP
    --
      -- Call to get annual leave balance

      pay_in_utils.set_location(g_debug,l_procedure, 20);

      per_accrual_calc_functions.get_net_accrual
        (
          p_assignment_id     => p_assignment_id          --  number  in
         ,p_plan_id           => rec.accrual_plan_id      --  number  in
         ,p_payroll_id        => rec.payroll_id           --  number  in
         ,p_business_group_id => rec.business_group_id    --  number  in
         ,p_calculation_date  => p_date_earned            --  date    in
         ,p_start_date        => l_start_date             --  date    out
         ,p_end_date          => l_end_date               --  date    out
         ,p_accrual_end_date  => l_accrual_end_date       --  date    out
         ,p_accrual           => l_accrual                --  number  out
         ,p_net_entitlement   => l_annual_leave_balance   --  number  out
        );


      IF l_annual_leave_balance IS NULL THEN
      --
        l_annual_leave_balance := 0;
      --
      END IF;


    pay_in_utils.set_location(g_debug,l_procedure, 30);

      l_leave_taken   :=  per_accrual_calc_functions.get_absence
                            (
                              p_assignment_id
                             ,rec.accrual_plan_id
                             ,p_period_end_date
                             ,p_period_start_date
                            );
      l_ovn :=1;

      IF rec.accrual_plan_name IS NOT NULL THEN
      --

        pay_action_information_api.create_action_information
           (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_assact_id
            ,p_action_context_type          =>  'AAP'
            ,p_object_version_number        =>  l_ovn
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_action_information_category  =>  'APAC ACCRUALS'
            ,p_action_information1          =>  rec.accrual_plan_name
            ,p_action_information2          =>  rec.accrual_category
            ,p_action_information4          =>  fnd_number.number_to_canonical(l_annual_leave_balance)
            ,p_action_information5          =>  rec.accrual_uom
           );
    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Accrual Plan Name  ',rec.accrual_plan_name);
       pay_in_utils.trace('Accrual Category  ',rec.accrual_category);
       pay_in_utils.trace('Annual Leave Balance  ',fnd_number.number_to_canonical(l_annual_leave_balance));
       pay_in_utils.trace('Accrual UOM  ',rec.accrual_uom);
       pay_in_utils.trace('**************************************************','********************');
    END IF;
      --
      END IF;
      --
    --
    END LOOP;
    --

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);

  --
  EXCEPTION
    WHEN OTHERS THEN
      IF csr_leave_balance%ISOPEN THEN
      --
        CLOSE csr_leave_balance;
      --
      END IF;
      --
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

      RAISE;
  --
  END archive_accrual_details;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ABSENCES                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives Absences for the employee   --
  --                  based on Payroll Assignment_action_id               --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_arch_action_id          NUMBER                    --
  --                  p_assg_act_id             NUMBER                    --
  --                  p_pre_effective_date      DATE                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------


  PROCEDURE archive_absences (
                               p_arch_act_id        IN NUMBER
                              ,p_assg_act_id        IN NUMBER
                              ,p_pre_effective_date IN DATE
                             )
  --
  IS
  --
    -- Cursor to fetch absence details for the Assignment
    --
    CURSOR csr_asg_absences
    IS
    --
      SELECT pat.name                                                                                              absence_type
            ,pet.reporting_name                                                                                    reporting_name
            ,decode(pet.processing_type,'R',greatest(pab.date_start,PTP.START_DATE),pab.date_start)                start_date
            ,decode(pet.processing_type,'R',least(pab.date_end,PTP.END_DATE),pab.date_end)                         end_date
            ,decode(pet.processing_type,'R',to_number(prrv.result_value),nvl(pab.absence_days,pab.absence_hours))  absence_days
      FROM   pay_assignment_actions           paa
            ,pay_payroll_actions              ppa
            ,pay_run_results                  prr
            ,pay_run_result_values            prrv
            ,per_time_periods                 ptp
            ,pay_element_types_f              pet
            ,pay_input_values_f               piv
            ,pay_element_entries_f            pee
            ,per_absence_attendance_types     pat
            ,per_absence_attendances          pab
      WHERE  paa.assignment_action_id       = p_assg_act_id
      AND    ppa.payroll_action_id          = paa.payroll_action_id
      AND    ppa.action_type               IN ('Q','R')
      AND    ptp.time_period_id             = ppa.time_period_id
      AND    paa.assignment_action_id       = prr.assignment_action_id
      AND    pet.element_type_id            = prr.element_type_id
      AND    pet.element_type_id            = piv.element_type_id
      AND    piv.input_value_id             = pat.input_value_id
      AND    pat.absence_attendance_type_id = pab.absence_attendance_type_id
      AND    pab.absence_attendance_id      = pee.creator_id
      AND    pee.creator_type               = 'A'
      AND    pee.assignment_id              = paa.assignment_id
      AND    pee.element_entry_id           = prr.source_id
      AND    piv.input_value_id             = prrv.input_value_id
      AND    prr.run_result_id              = prrv.run_result_id
      AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
      AND    ppa.effective_date       BETWEEN pee.effective_start_date
                                          AND pee.effective_end_date
      AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                          AND piv.effective_end_date;

    l_procedure                   VARCHAR2(200);
    l_start_date                  VARCHAR2(20);
    l_end_date                    VARCHAR2(20);
    l_ovn                         NUMBER;
    l_action_info_id              NUMBER;
    l_message                     VARCHAR2(255);
    --
  --
  BEGIN
  --
    l_procedure := g_package || 'archive_absences';

    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

      IF g_debug THEN
        pay_in_utils.trace('Archive Action ID       ',p_arch_act_id);
        pay_in_utils.trace('Assignment Action ID    ',p_assg_act_id);
        pay_in_utils.trace('Effective Date          ',p_pre_effective_date);
      END IF;

    --
    FOR csr_rec in csr_asg_absences
    LOOP
    --
      IF g_debug THEN
        pay_in_utils.trace('Absence Type            ',csr_rec.absence_type);
        pay_in_utils.trace('Element Reporting Name  ',csr_rec.reporting_name);
        pay_in_utils.trace('Start Date              ',to_char(csr_rec.start_date,'DD-MON-YYYY'));
        pay_in_utils.trace('End Date                ',to_char(csr_rec.end_date,'DD-MON-YYYY'));
        pay_in_utils.trace('Absence Days            ',csr_rec.absence_days);
      END IF;

      pay_in_utils.set_location(g_debug,l_procedure, 20);

      l_start_date := fnd_date.date_to_canonical(csr_rec.start_date);
      l_end_date   := fnd_date.date_to_canonical(csr_rec.end_date);

      l_ovn  := 1;

      pay_action_information_api.create_action_information
      (
        p_action_information_id        => l_action_info_id
       ,p_action_context_id            => p_arch_act_id
       ,p_action_context_type          => 'AAP'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => p_pre_effective_date
       ,p_source_id                    => NULL
       ,p_source_text                  => NULL
       ,p_action_information_category  => 'APAC ABSENCES'
       ,p_action_information1          => csr_rec.absence_type
       ,p_action_information2          => csr_rec.reporting_name
       ,p_action_information3          => NULL
       ,p_action_information4          => l_start_date
       ,p_action_information5          => l_end_date
       ,p_action_information6          => fnd_number.number_to_canonical(csr_rec.absence_days) -- Bug 3604206
       ,p_action_information7          => NULL
      );
    --
    END LOOP;
    --
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
  --
  EXCEPTION
  --
    WHEN others THEN
      IF csr_asg_absences%ISOPEN THEN
        CLOSE csr_asg_absences;
      END IF;
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END archive_absences;
  --


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_STAT_ELEMENTS                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives the elements and            --
  --                  run result values. It uses view                     --
  --                  PAY_in_ASG_ELEMENTS_V to get the elements and       --
  --                  correspoding payments.                              --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id    NUMBER                    --
  --                  p_effective_date          DATE                      --
  --                  p_assact_id               NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  -- 115.1 03-May-2006    lnagaraj   Archived 'Employer Excess PF         --
  --                                 Contribution' under Employer Charges --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_stat_elements(
                                   p_assignment_action_id  IN NUMBER
                                  ,p_effective_date        IN DATE
                                  ,p_assact_id             IN NUMBER
                                 )
  IS
  --
    -- Cursor to get all the elements processed for the assignment in the
    -- prepayment.

    CURSOR  csr_std_elements
    IS
      SELECT   element_reporting_name
              ,classification_name
              ,amount
              ,foreign_currency_code
              ,exchange_rate
      FROM     pay_in_asg_elements_v
      WHERE    assignment_action_id  = p_assignment_action_id;


    --

    l_action_info_id          NUMBER;
    l_ovn                     NUMBER;
    l_foreign_currency_amount NUMBER;
    l_rate                    NUMBER;
    l_procedure               VARCHAR2(100);
    l_message   VARCHAR2(255);
    l_def_bal_id NUMBER;
    l_excess_pf NUMBER;
    l_no_value_archived VARCHAR2(255);
    --
  --
  BEGIN
  --

    l_procedure := g_package ||'archive_stat_elements';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('Assignment Action id  ',p_assignment_action_id);
       pay_in_utils.trace('Effective Date        ',p_effective_date);
       pay_in_utils.trace('Assact ID             ',p_assact_id);
    END IF;


    FOR csr_rec IN csr_std_elements
    LOOP
    --
       pay_in_utils.set_location(g_debug,l_procedure, 20);

      IF nvl(csr_rec.exchange_rate,0) <> 0 THEN
        l_foreign_currency_amount := csr_rec.amount / csr_rec.exchange_rate;
      ELSE
        l_foreign_currency_amount := NULL;
      END IF;

      IF ( csr_rec.amount IS NOT NULL) THEN
           IF ((csr_rec.classification_name IN ('Advances','Fringe Benefits')) AND csr_rec.amount = 0) THEN
	      ---Do not archive any value--
	        l_no_value_archived :='Yes';
           ELSE
              pay_in_utils.set_location(g_debug,l_procedure, 30);

              pay_action_information_api.create_action_information
              (
               p_action_information_id         =>  l_action_info_id
              ,p_action_context_id             =>  p_assact_id
              ,p_action_context_type           =>  'AAP'
              ,p_object_version_number         =>  l_ovn
              ,p_effective_date                =>  p_effective_date
              ,p_source_id                     =>  NULL
              ,p_source_text                   =>  NULL
              ,p_action_information_category   =>  'APAC ELEMENTS'
              ,p_action_information1           =>  csr_rec.element_reporting_name
              ,p_action_information2           =>  NULL
              ,p_action_information3           =>  NULL
              ,p_action_information4           =>  csr_rec.classification_name
              ,p_action_information5           =>  fnd_number.number_to_canonical(csr_rec.amount)
              ,p_action_information10          =>  fnd_number.number_to_canonical(csr_rec.exchange_rate)
              ,p_action_information11          =>  fnd_number.number_to_canonical(l_foreign_currency_amount)
              ,p_action_information12          =>  csr_rec.foreign_currency_code
          );
           IF g_debug THEN
           pay_in_utils.trace('Element Name  ',csr_rec.element_reporting_name);
           pay_in_utils.trace('Amount       ',fnd_number.number_to_canonical(csr_rec.amount));
           END IF;
       END IF;

      --
      END IF;
      --
    --
    END LOOP;

l_def_bal_id := pay_in_tax_utils.get_defined_balance('Excess Interest Amount','_ASG_PTD');
l_excess_pf := pay_balance_pkg.get_value(l_def_bal_id,p_assignment_action_id);

l_def_bal_id := pay_in_tax_utils.get_defined_balance('Excess PF Amount','_ASG_PTD');
l_excess_pf := l_excess_pf + pay_balance_pkg.get_value(l_def_bal_id,p_assignment_action_id);



IF l_excess_pf <> 0 THEN
      pay_action_information_api.create_action_information
          (
            p_action_information_id         =>  l_action_info_id
           ,p_action_context_id             =>  p_assact_id
           ,p_action_context_type           =>  'AAP'
           ,p_object_version_number         =>  l_ovn
           ,p_effective_date                =>  p_effective_date
           ,p_source_id                     =>  NULL
           ,p_source_text                   =>  NULL
           ,p_action_information_category   =>  'APAC ELEMENTS'
           ,p_action_information1           =>  'Employer Excess PF Contribution'
           ,p_action_information2           =>  NULL
           ,p_action_information3           =>  NULL
           ,p_action_information4           =>  'Employer Charges'
           ,p_action_information5           =>  fnd_number.number_to_canonical(l_excess_pf)
           ,p_action_information10          =>  NULL  /* Balance fed by a seeded element, whose input and output currency is INR */
           ,p_action_information11          =>  NULL
           ,p_action_information12          =>  NULL
          );
END IF;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_std_elements%ISOPEN THEN
      --
        CLOSE csr_std_elements;
      --
      END IF;
      --
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

      RAISE;
  --
  END archive_stat_elements;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_BALANCES                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives the given balance,its       --
  --                  current and YTD value.                              --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_effective_date          DATE                      --
  --                  p_assact_id               NUMBER                    --
  --                  p_narraive                VARCHAR2                  --
  --                  p_value_curr              NUMBER                    --
  --                  p_value_ytd               NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_balances(
                              p_effective_date IN DATE
                             ,p_assact_id      IN NUMBER
                             ,p_narrative      IN VARCHAR2
                             ,p_value_ytd      IN NUMBER
                            )
  IS
  --
    l_action_info_id   NUMBER;
    l_ovn              NUMBER;
    l_procedure        VARCHAR2(80);
    l_message          VARCHAR2(255);
  --
  BEGIN
  --
    l_procedure := g_package || 'archive_balances';

    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    -- Archive Statutory balances
    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Narrative         ',p_narrative);
       pay_in_utils.trace('Action Context ID ',p_assact_id);
       pay_in_utils.trace('Balance value     ',p_value_ytd);
       pay_in_utils.trace('Effective Date    ',p_effective_date);
       pay_in_utils.trace('**************************************************','********************');
     END IF;

    pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
       ,p_action_context_id            =>  p_assact_id
       ,p_action_context_type          =>  'AAP'
       ,p_object_version_number        =>  l_ovn
       ,p_effective_date               =>  p_effective_date
       ,p_source_id                    =>  NULL
       ,p_source_text                  =>  p_narrative
       ,p_action_information_category  =>  'APAC BALANCES'
       ,p_action_information1          =>  p_narrative
       ,p_action_information2          =>  NULL
       ,p_action_information3          =>  NULL
       ,p_action_information4          =>  fnd_number.number_to_canonical(p_value_ytd)
      );

    hr_utility.set_location('Leaving ' || l_procedure,30);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END archive_balances;
  --

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_STAT_BALANCES                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure calls pay_in_payslip.balance_totals  --
  --                  to get the current and YTD values of the following  --
  --                  balances                                            --
  --                    1. Taxable Earnings                               --
  --                    2. Non Taxable Earnings                           --
  --                    3. Statutory Deductions                           --
  --                    4. Voluntary Deductions                           --
  --                  It then calls ARCHIVE_BALANCES to archive           --
  --                  individual balances                                 --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id    NUMBER                    --
  --                  p_assignment_id           NUMBER                    --
  --                  p_date_earned             DATE                      --
  --                  p_effective_date          DATE                      --
  --                  p_assact_id               NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 21-SEP-2004    bramajey   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_stat_balances(
                                   p_assignment_action_id  IN NUMBER
                                  ,p_assignment_id         IN NUMBER
                                  ,p_date_earned           IN DATE
                                  ,p_effective_date        IN DATE
                                  ,p_assact_id             IN NUMBER
                                 )
  IS

    l_value      NUMBER;
    l_procedure  VARCHAR2(100);
    l_message    VARCHAR2(255);
    TYPE t_balance_name IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    g_bal_name  t_balance_name;

  BEGIN
  --
    g_bal_name(1)  := 'F16 Salary Under Section 17';
    g_bal_name(2)  := 'F16 Value of Perquisites';
    g_bal_name(3)  := 'F16 Gross Salary';
    g_bal_name(4)  := 'F16 Allowances Exempt';
    g_bal_name(5)  := 'F16 Deductions under Sec 16';
    g_bal_name(6)  := 'F16 Total Chapter VI A Deductions';
    g_bal_name(7)  := 'F16 Total Income';
    g_bal_name(8)  := 'F16 Tax on Total Income';
    g_bal_name(9)  := 'F16 Total Tax payable';

    l_procedure := g_package || 'archive_stat_balances';

    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Assignment Action id  ',p_assignment_action_id);
    END IF;

    FOR i IN 1..9
    LOOP
      l_value := pay_in_tax_utils.get_balance_value(p_assignment_action_id => p_assignment_action_id,
                                                    p_balance_name         => g_bal_name(i),
                                                    p_dimension_name       => '_ASG_PTD',
                                                    p_context_name         => 'NULL',
                                                    p_context_value        => 'NULL'
                                                   );
      IF (i =4) THEN
         g_bal_name(i) := 'F16 Allowances Exempted u/s 10';
      END IF;

    IF g_debug THEN
       pay_in_utils.trace('Balance Name   ',g_bal_name(i));
       pay_in_utils.trace('Balance Value  ',l_value);
    END IF;

      archive_balances(
                       p_effective_date => p_effective_date,
                       p_assact_id      => p_assact_id,
                       p_narrative      => SUBSTR(g_bal_name(i),5),
                       p_value_ytd      => l_value
                      );

    END LOOP;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  --
  END archive_stat_balances;

--------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_FORM24Q_BALANCES                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure calls pay_in_tax_utils.              --
  --                 get_balance_value to archive individual balances for --
  --                  the following balances                              --
  --                                                                      --
  --                    1. Net Pay                                        --
  --                    2. Income Tax This Pay                            --
  --                    3. TDS on Direct Payments                         --
  --                    4. Surcharge This Pay                             --
  --                    5. Education Cess This Pay                        --
  --          It then calls pay_action_information_api.                   --
  --          create_action_information to archive individual balances    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id    NUMBER                    --
  --                  p_assignment_id           NUMBER                    --
  --                  p_date_earned             DATE                      --
  --                  p_effective_date          DATE                      --
  --                  p_assact_id               NUMBER                    --
  --                  p_payroll_action_id       NUMBER                    --
  --                  p_run_payroll_action_id   NUMBER                    --
  --                  p_pre_assact_id           NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 02-APR-2007    sivanara   Initial Version                      --
  -- 115.1 30-APR-2007    sivanara   The Balance value are been calculate --
  --                                 using dimension _ASG_RUN             --
  -- 115.2 10-MAY-2007    RSAHARAY   Changed cursor c_multi_records       --
  -- 115.3 16-Jun-2008    lnagaraj   Archived Gross Pay instead of Net Pay--
  --------------------------------------------------------------------------
PROCEDURE archive_Form24Q_balances(
                                   p_assignment_action_id  IN NUMBER
                                  ,p_assignment_id         IN NUMBER
                                  ,p_date_earned           IN DATE
                                  ,p_effective_date        IN DATE
                                  ,p_assact_id             IN NUMBER
                                  ,p_payroll_action_id    IN  NUMBER
                                  ,p_run_payroll_action_id IN  NUMBER
                                  ,p_pre_assact_id       IN NUMBER
                                  )
  IS

  /*Cursor for selecting assignment actions in case Single pre payment has been done for multi payroll runs*/
    CURSOR c_multi_rec_count(p_prepayment_lcking_id NUMBER
                            )
    IS
    select count(paa.assignment_action_id)
     from pay_payroll_actions ppa
         ,pay_assignment_actions paa
         ,pay_action_interlocks pal
     where pal.locking_action_id=p_prepayment_lcking_id
     and   paa.assignment_action_id=pal.locked_action_id
     and   ppa.payroll_action_id=paa.payroll_action_id
     and   ppa.action_type in ('Q','R')
     and   ppa.action_status='C'
     and   paa.action_status='C'
     and   paa.source_action_id is not null;

    CURSOR c_multi_records(p_prepayment_lcking_id NUMBER)
    IS
     select paa.assignment_action_id assignment_action_id
            ,ppa.date_earned date_earned
	    ,ppa.effective_date effective_date
     from pay_payroll_actions ppa
         ,pay_assignment_actions paa
        ,pay_action_interlocks pal
     where pal.locking_action_id=p_prepayment_lcking_id
     and   paa.assignment_action_id=pal.locked_action_id
     and   ppa.payroll_action_id=paa.payroll_action_id
     and   ppa.action_type in ('Q','R')
     and   ppa.action_status='C'
     and   paa.action_status='C'
     and   paa.source_action_id is not null
     ORDER BY TO_NUMBER(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id);

  /*Cursor for selecting payroll for the given payroll_action_id*/
    CURSOR c_payroll_id(p_payroll_action_id NUMBER) IS
    SELECT payroll.payroll_id
         , payroll.payroll_name
      FROM pay_payrolls_f payroll
          ,pay_payroll_actions ppa
     WHERE ppa.payroll_action_id = p_run_payroll_action_id
       AND ppa.payroll_id = payroll.payroll_id;

    l_action_info_id   NUMBER;
    l_count            NUMBER;
    l_asg_id           NUMBER;
    l_date             DATE;
    l_eff_date         DATE;
    l_ovn              NUMBER;
    l_value            NUMBER;
    l_multirec_value   NUMBER;
    l_procedure        VARCHAR2(100);
    l_message          VARCHAR2(255);
    l_assessment_year  VARCHAR2(20);
    l_next_year        VARCHAR2(20);
    l_period           NUMBER;
    l_payroll_name     pay_payrolls_f.payroll_name%TYPE;
    l_payroll_id       NUMBER;
    l_tan              hr_organization_information.org_information1%TYPE;
    TYPE r_balance_name_val IS RECORD(l_balance_name pay_balance_types.balance_name%type,
                                      l_balance_val NUMBER);
    TYPE t_balance IS TABLE OF r_balance_name_val INDEX BY PLS_INTEGER;
    l_bal_name_val  t_balance;
  BEGIN

    l_bal_name_val(1).l_balance_name  := 'Net Pay';
    l_bal_name_val(2).l_balance_name  := 'Income Tax This Pay';
    l_bal_name_val(3).l_balance_name  := 'TDS on Direct Payments';
    l_bal_name_val(4).l_balance_name  := 'Surcharge This Pay';
    l_bal_name_val(5).l_balance_name  := 'Education Cess This Pay';
    l_bal_name_val(6).l_balance_name  := 'Sec and HE Cess This Pay';
    l_bal_name_val(7).l_balance_name  := 'Involuntary Deductions';
    l_bal_name_val(8).l_balance_name  := 'Pre Tax Deductions';
    l_bal_name_val(9).l_balance_name  := 'Tax Deductions';
    l_bal_name_val(10).l_balance_name  := 'Voluntary Deductions';
    l_procedure := g_package || 'archive_form24q_balances';


    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Assignment Action id            ',p_assignment_action_id);
       pay_in_utils.trace('Assignment id                   ',p_assignment_id);
       pay_in_utils.trace('Earned date                     ',p_date_earned);
       pay_in_utils.trace('Effective Date                  ',p_effective_date);
       pay_in_utils.trace('Assignment action id            ',p_assact_id);
       pay_in_utils.trace('Payroll action id               ',p_payroll_action_id);
       pay_in_utils.trace('Run Payroll action id           ',p_run_payroll_action_id);
       pay_in_utils.trace('Prepayment assignmentaction id  ',p_pre_assact_id);
    END IF;

     OPEN c_multi_rec_count(p_pre_assact_id);
      FETCH c_multi_rec_count INTO l_count;
      CLOSE c_multi_rec_count;

    l_date := p_date_earned;
    l_eff_date := p_effective_date;
    FOR i IN l_bal_name_val.first..l_bal_name_val.last
    LOOP
    IF l_count > 1 THEN
    l_multirec_value := 0;
    pay_in_utils.set_location(g_debug,l_procedure, 20);

	 FOR rec_multi IN c_multi_records( p_pre_assact_id) LOOP
          l_date :=rec_multi.date_earned;
	  l_eff_date := rec_multi.effective_date;
          pay_in_utils.set_location(g_debug,l_procedure, 30);
          l_multirec_value := l_multirec_value + pay_in_tax_utils.get_balance_value(p_assignment_action_id => rec_multi.assignment_action_id,
                                                    p_balance_name         => l_bal_name_val(i).l_balance_name,
                                                    p_dimension_name       => '_ASG_RUN',
                                                    p_context_name         => 'NULL',
                                                    p_context_value        => 'NULL');

        END LOOP;
     l_bal_name_val(i).l_balance_val := l_multirec_value;
     l_multirec_value :=0;

    ELSE
    l_bal_name_val(i).l_balance_val := pay_in_tax_utils.get_balance_value(p_assignment_action_id => p_assignment_action_id,
                                                    p_balance_name         => l_bal_name_val(i).l_balance_name,
                                                    p_dimension_name       => '_ASG_RUN',
                                                    p_context_name         => 'NULL',
                                                    p_context_value        => 'NULL'
                                                   );
    END IF;

    IF g_debug THEN
       pay_in_utils.trace('Balance Name   ',l_bal_name_val(i).l_balance_name);
       pay_in_utils.trace('Balance Value  ',l_bal_name_val(i).l_balance_val);
    END IF;
    END LOOP;
    /* Bug 7165051 Start */
   l_bal_name_val(1).l_balance_val := l_bal_name_val(1).l_balance_val +
                                     (l_bal_name_val(7).l_balance_val +
                                      l_bal_name_val(8).l_balance_val +
                                      l_bal_name_val(9).l_balance_val +
                                      l_bal_name_val(10).l_balance_val );
    /* Bug 7165051 End */
    OPEN c_payroll_id(p_run_payroll_action_id);
    FETCH c_payroll_id INTO l_payroll_id,l_payroll_name;
    CLOSE c_payroll_id;

    l_next_year := to_char(pay_in_utils.next_tax_year(nvl(TRUNC(l_date),p_effective_date)),'YYYY');
    l_assessment_year := l_next_year || '-' || to_char(to_number(l_next_year)+1);
    l_tan := pay_in_form_24q_web_adi.get_tan_number(p_assignment_id,    nvl(l_date,    p_effective_date));
    l_period := pay_in_tax_utils.get_period_number(l_payroll_id, nvl(TRUNC(l_date), p_effective_date));
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 35);

    pay_action_information_api.create_action_information
      (
        p_action_information_id        =>  l_action_info_id
       ,p_action_context_id            =>  p_assact_id
       ,p_assignment_id                =>  p_assignment_id
       ,p_action_context_type          =>  'AAP'
       ,p_object_version_number        =>  l_ovn
       ,p_effective_date               =>  l_eff_date
       ,p_source_id                    =>  p_assignment_action_id
       ,p_source_text                  =>  NULL
       ,p_action_information_category  =>  'IN_TAX_BALANCES'
       ,p_action_information1          =>  l_assessment_year
       ,p_action_information2          =>  fnd_number.number_to_canonical(l_period)
       ,p_action_information3          =>  l_tan
       ,p_action_information4          =>  fnd_number.number_to_canonical(l_bal_name_val(1).l_balance_val)
       ,p_action_information5          =>  fnd_number.number_to_canonical(l_bal_name_val(2).l_balance_val)
       ,p_action_information6          =>  fnd_number.number_to_canonical(l_bal_name_val(3).l_balance_val)
       ,p_action_information7          =>  fnd_number.number_to_canonical(l_bal_name_val(4).l_balance_val)
       ,p_action_information8          =>  fnd_number.number_to_canonical(l_bal_name_val(5).l_balance_val)
       ,p_action_information9          =>  fnd_number.number_to_canonical(l_bal_name_val(6).l_balance_val)
       ,p_action_information10          => to_char(l_date,'DD/MM/YYYY')
       ,p_action_information11          => p_payroll_action_id
       ,p_action_information12          => p_pre_assact_id
       ,p_action_information13          => l_payroll_name);

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
    l_bal_name_val.delete;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  --
  END archive_Form24Q_balances;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_EMPLOYEE_DETAILS                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure calls                                --
  --                  'pay_emp_action_arch.get_personal_information' that --
  --                  actually archives the employee details,employee     --
  --                  ddress details, Employer Address Details            --
  --                  and Net Pay Distribution information. Procedure     --
  --                  'get_personal_information' is passed tax_unit_id    --
  --                  to make core provided 'Choose Payslip' work for IN. --
  --                  The action DF structures used are                   --
  --                       ADDRESS DETAILS                                --
  --                       EMPLOYEE DETAILS                               --
  --                       EMPLOYEE NET PAY DISTRIBUTION                  --
  --                       EMPLOYEE OTHER INFORMATION                     --
  --                  After core procedure completes the archival, the    --
  --                  information stored for category                     --
  --                  EMPLOYEE_NET_PAY_DISTRIBUTION is updated with       --
  --                  Bank_name,Bank Branch,Account Number,percentage     --
  --                  and currency code.                                  --
  --                  Then EMPLOYEE DETAILS is updated with the           --
  --                  payroll_location available in SOFT_CODING_KEY_FLEX  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id          NUMBER                 --
  --                  p_pay_assignment_action_id   NUMBER                 --
  --                  p_assact_id                  NUMBER                 --
  --                  p_assignment_id              NUMBER                 --
  --                  p_curr_pymt_ass_act_id       NUMBER                 --
  --                  p_date_earned                DATE                   --
  --                  p_latest_period_payment_date DATE                   --
  --                  p_run_effective_date         DATE                   --
  --                  p_time_period_id             NUMBER                 --
  --                  p_pre_effective_date         DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 21-SEP-2004    bramajey   Initial Version                      --
  -- 115.1 27-Dec-2004    aaagarwa   Corrected variable types             --
  -- 115.2 15-Mar-2005    aaagarwa   Corrected variable types             --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_employee_details (
                                       p_payroll_action_id            IN NUMBER
                                      ,p_pay_assignment_action_id     IN NUMBER
                                      ,p_assactid                     IN NUMBER
                                      ,p_assignment_id                IN NUMBER
                                      ,p_curr_pymt_ass_act_id         IN NUMBER
                                      ,p_date_earned                  IN DATE
                                      ,p_latest_period_payment_date   IN DATE
                                      ,p_run_effective_date           IN DATE
                                      ,p_time_period_id               IN NUMBER
                                      ,p_pre_effective_date           IN DATE
                                     )
  IS
  --
    -- Cursor to select the archived information for category 'EMPLOYEE NET PAY DISTRIBUTION'
    -- by core package.

    CURSOR  csr_net_pay_action_info_id
    IS
      SELECT  action_information_id
             ,action_information1
             ,action_information2
      FROM    pay_action_information
      WHERE   action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
      AND     action_context_id           =  p_assactid
      AND     action_context_type         = 'AAP';
    --


    -- Cursor to select the archived information for category 'EMPLOYEE DETAILS'
    -- by core package.

    CURSOR  csr_emp_det_action_info_id
    IS
      SELECT  action_information_id
      FROM    pay_action_information
      WHERE   action_information_category = 'EMPLOYEE DETAILS'
      AND     action_context_id           =  p_assactid
      AND     action_context_type         = 'AAP';

    CURSOR csr_person_id
    IS
      SELECT paa.person_id
      FROM   per_assignments_f paa
      WHERE  paa.assignment_id   = p_assignment_id
      AND    p_date_earned BETWEEN paa.effective_start_date
                           AND     paa.effective_end_date;
    --
    CURSOR csr_person_details (p_person_id IN NUMBER)
    IS
      SELECT fnd_date.date_to_canonical(pap.date_of_birth)     dob
            ,pap.per_information8  pf_number
            ,pap.per_information9  esi_number
            ,pap.per_information4  pan
            ,pap.per_information10 superannuation_number
            ,hr_in_utility.per_in_full_name(pap.first_name,pap.middle_names,pap.last_name,pap.title)
	    ,pap.email_address
      FROM   per_people_f pap
      WHERE  pap.person_id       = p_person_id
      AND    p_date_earned BETWEEN pap.effective_start_date
                           AND     pap.effective_end_date;


    -- Cursor to get Professinal Tax Number
    CURSOR csr_prof_tax_number
    IS
    --
      SELECT hoi.org_information1
      FROM   hr_soft_coding_keyflex      hsck
            ,hr_organization_information hoi
            ,per_assignments_f       paaf
            ,pay_assignment_actions      paa
            ,pay_payroll_actions         ppa
      WHERE  paa.assignment_action_id    = p_assactid
      AND    paa.payroll_action_id       = ppa.payroll_action_id
      AND    paa.assignment_id           = paaf.assignment_id
      AND    hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
      AND    hsck.segment3               = hoi.organization_id
      AND    hoi.org_information_context = 'PER_IN_PROF_TAX_DF'
      AND    ppa.effective_date    BETWEEN paaf.effective_start_date
                                   AND     paaf.effective_end_date;
    --

    -- Cursor to select the tax_unit_id of the prepayment needed for archival

    CURSOR csr_tax_unit_id
    IS
      SELECT tax_unit_id
      FROM pay_assignment_actions
      WHERE assignment_action_id   = p_curr_pymt_ass_act_id;
    --


    -- Cursor to get the bank name,percentage and currency code

    CURSOR csr_bank_details(
                              p_personal_payment_method_id NUMBER
                             ,p_org_payment_method_id      NUMBER
                           )
    IS
      SELECT pea.segment3                   bank_name
            ,pea.segment4                   bank_branch
            ,pea.segment1                   account_number
            ,ppm.percentage                 percentage
            ,pop.currency_code
      FROM   pay_external_accounts          pea
            ,pay_pre_payments               ppp
            ,pay_org_payment_methods_f      pop
            ,pay_personal_payment_methods_f ppm
      WHERE  ppp.assignment_action_id              = p_curr_pymt_ass_act_id
      AND    nvl(ppp.personal_payment_method_id,0) = nvl(p_personal_payment_method_id,0)
      AND    ppp.org_payment_method_id             = p_org_payment_method_id
      AND    ppp.personal_payment_method_id        = ppm.personal_payment_method_id (+)
      AND    ppp.org_payment_method_id             = pop.org_payment_method_id
      AND    ppm.external_account_id               = pea.external_account_id (+)
      AND    p_pre_effective_date BETWEEN pop.effective_start_date
                                  AND     pop.effective_end_date
      AND    p_pre_effective_date BETWEEN nvl(ppm.effective_start_date,p_pre_effective_date)
                                     AND  nvl(ppm.effective_end_date,p_pre_effective_date);
/*  Bug 4159662*/
    -- Cursor to select the archived information for category 'EMPLOYEE DETAILS'
    CURSOR  csr_emp_details
    IS
      SELECT  action_information_id
      FROM    pay_action_information
      WHERE   action_information_category = 'EMPLOYEE DETAILS'
      AND     action_context_id           =  p_assactid
      AND     action_context_type         = 'AAP';

   -- Cursor to get the Registered Name of the GRE/Legal Entity
   Cursor c_reg_name
   IS
      SELECT  hou.name
      FROM  per_assignments_f peaf
           ,hr_soft_coding_keyflex hrscf
	   ,hr_organization_information hoi
	   ,hr_organization_units hou
      WHERE peaf.assignment_id=p_assignment_id
      AND   peaf.soft_coding_keyflex_id=hrscf.soft_coding_keyflex_id
      AND   hoi.organization_id=hrscf.segment1
      AND   hoi.org_information_context='PER_IN_INCOME_TAX_DF'
      AND   hou.organization_id=hoi.org_information4
      AND   p_date_earned between peaf.effective_start_date and peaf.effective_end_date;
--
    --
    l_person_id    per_assignments_f.person_id%TYPE;

    l_action_info_id        NUMBER;
    l_ovn                   NUMBER;
    l_tax_unit_id           NUMBER;
    l_procedure             VARCHAR2(80);
/*4229709*/
    l_bank_name             pay_external_accounts.segment3%TYPE;
    l_bank_branch           pay_external_accounts.segment4%TYPE;
    l_bank                  VARCHAR2(310);
    l_account_number        pay_external_accounts.segment1%TYPE;
    l_percentage            pay_personal_payment_methods_f.percentage%TYPE;
    l_currency_code         pay_org_payment_methods_f.currency_code%TYPE;
    l_prof_tax_number       hr_organization_information.org_information1%TYPE;
 /*4229709*/
    l_emp_det_act_info_id   NUMBER;
    l_tax_area              VARCHAR2(10);
    l_dob                   VARCHAR2(30);
    /* Bug 4089704*/
    l_pf_number             per_people_f.per_information8%TYPE;
    l_esi_number            per_people_f.per_information9%TYPE;
    l_pan                   per_people_f.per_information4%TYPE;
    l_superannuation_number per_people_f.per_information10%TYPE;
    /* Bug 4089704*/

    l_month                 VARCHAR2(30);
    l_year                  VARCHAR2(30);
    /* Bug 4159662*/
    l_reg_name              hr_organization_units.name%TYPE;
    l_act_inf_id            pay_action_information.action_information_id%TYPE;
    l_message                     VARCHAR2(255);
    l_full_name             per_people_f.full_name%TYPE;
    l_email_address         per_people_f.email_address%TYPE;

  --
  BEGIN
  --
    l_procedure := g_package || 'archive_employee_details';

    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    -- call generic procedure to retrieve and archive all data for
    -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('Assignment id  ',p_assignment_id);
      pay_in_utils.trace('Archive Action id  ',p_assactid);
      pay_in_utils.trace('Tax unit id  ',l_tax_unit_id);
      pay_in_utils.trace('Prepayment Assignment Action id  ',p_curr_pymt_ass_act_id);
      pay_in_utils.trace('Run Effective Date  ',p_run_effective_date);
      pay_in_utils.trace('**************************************************','********************');
    END IF;


    OPEN  csr_tax_unit_id;
    FETCH csr_tax_unit_id INTO l_tax_unit_id;
    CLOSE csr_tax_unit_id;

    pay_in_utils.set_location(g_debug,l_procedure, 20);

    pay_emp_action_arch.get_personal_information
      (
        p_payroll_action_id    => p_payroll_action_id           -- archive payroll_action_id
       ,p_assactid             => p_assactid                    -- archive assignment_action_id
       ,p_assignment_id        => p_assignment_id               -- current assignment_id
       ,p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id        -- prepayment assignment_action_id
       ,p_curr_eff_date        => p_run_effective_date          -- run effective_date
       ,p_date_earned          => p_date_earned                 -- payroll date_earned
       ,p_curr_pymt_eff_date   => p_latest_period_payment_date  -- latest payment date
       ,p_tax_unit_id          => l_tax_unit_id                 -- tax_unit_id needed for Choose Payslip region.
       ,p_time_period_id       => p_time_period_id              -- time_period_id from per_time_periods
       ,p_ppp_source_action_id => NULL
       ,p_run_action_id        => p_pay_assignment_action_id
      );
   pay_in_utils.set_location(g_debug,l_procedure, 30);

/* Bug 4159662*/
   --Find the Registered Name of GRE
    OPEN c_reg_name;
    FETCH c_reg_name INTO l_reg_name;
    CLOSE c_reg_name;

   pay_in_utils.set_location(g_debug,l_procedure, 40);

   --Update the name in archived data
   OPEN csr_emp_details;
   FETCH csr_emp_details INTO l_act_inf_id;
   CLOSE csr_emp_details;

     pay_action_information_api.update_action_information
        (
          p_action_information_id     =>  l_act_inf_id
         ,p_object_version_number     =>  l_ovn
         ,p_action_information18      =>  l_reg_name
        );
   pay_in_utils.set_location(g_debug,l_procedure, 50);

    FOR net_pay_rec in csr_net_pay_action_info_id

    LOOP
    --
      pay_in_utils.set_location(g_debug,l_procedure, 60);
      OPEN  csr_bank_details(
                              net_pay_rec.action_information2
                             ,net_pay_rec.action_information1
                            );

      FETCH csr_bank_details INTO   l_bank_name
                                   ,l_bank_branch
                                   ,l_account_number
                                   ,l_percentage
                                   ,l_currency_code;
      CLOSE csr_bank_details;

      IF g_debug THEN
        pay_in_utils.trace('Bank Name    ',l_bank_name);
        pay_in_utils.trace('Bank branch  ',l_bank_branch);
      END IF;

      IF (l_bank_branch IS NULL) OR (l_bank_name IS NULL) THEN
      --
        l_bank := NULL;
      --
      ELSE
      --

         l_bank :=
        hr_general.decode_lookup('IN_BANK',l_bank_name)||','||
        hr_general.decode_lookup('IN_BANK_BRANCH',l_bank_branch);
      --
      END IF;
      pay_in_utils.set_location(g_debug,l_procedure, 70);
      l_ovn := 1;

      pay_action_information_api.update_action_information
        (
          p_action_information_id     =>  net_pay_rec.action_information_id
         ,p_object_version_number     =>  l_ovn
         ,p_action_information5       =>  l_bank
         ,p_action_information7       =>  l_account_number
         ,p_action_information12      =>  l_percentage
         ,p_action_information13      =>  l_currency_code
        );
    --
    END LOOP;

   pay_in_utils.set_location(g_debug,l_procedure, 80);

    OPEN  csr_emp_det_action_info_id;
    FETCH csr_emp_det_action_info_id INTO  l_emp_det_act_info_id;
    CLOSE csr_emp_det_action_info_id;

    pay_in_utils.set_location(g_debug,l_procedure, 90);

    -- Bug 3139966 starts
    -- Added code to archive Expatriate Indicator, Passport
    OPEN csr_person_id;
    FETCH csr_person_id
       INTO l_person_id;
    CLOSE csr_person_id;

   IF g_debug THEN
     pay_in_utils.trace('Person ID         ',l_person_id);
     pay_in_utils.trace('Effective Date    ',p_pre_effective_date);
   END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 100);

    OPEN csr_person_details (l_person_id);
    FETCH csr_person_details
       INTO l_dob
           ,l_pf_number
           ,l_esi_number
           ,l_pan
           ,l_superannuation_number
           ,l_full_name
	   ,l_email_address;
    CLOSE csr_person_details;

    IF l_email_address IS NOT NULL
    THEN
      pay_in_utils.set_location(g_debug,l_procedure, 105);
      pay_action_information_api.create_action_information
       (p_action_context_id              =>  p_assactid
       ,p_action_context_type            =>  'AAP'
       ,p_action_information_category    =>  'IN_EMPLOYEE_DETAILS'
       ,p_effective_date                 =>  p_pre_effective_date
       ,p_assignment_id                  =>  p_assignment_id
       ,p_action_information1            =>  l_email_address
       ,p_action_information_id          =>  l_action_info_id        --OUT Parameters
       ,p_object_version_number          =>  l_ovn                   --OUT Parameters
       );
    END IF;

    l_month := TRIM(TO_CHAR(p_pre_effective_date,'Month'));
    l_year  := TO_CHAR(p_pre_effective_date,'YYYY');

   pay_in_utils.set_location(g_debug,l_procedure, 110);
    -- Fetch Professinal tax Number
    --
    OPEN csr_prof_tax_number;
    FETCH csr_prof_tax_number
      INTO l_prof_tax_number;
    IF csr_prof_tax_number%NOTFOUND THEN
    --
      l_prof_tax_number := NULL;
    --
    END IF;
    CLOSE csr_prof_tax_number;

    -- Update Payroll Location,Tax Area, Passport and Expatriate Indicator
    --

     pay_in_utils.set_location(g_debug,l_procedure, 120);
    l_ovn := 1;
    pay_action_information_api.update_action_information
       (
        p_action_information_id     =>  l_emp_det_act_info_id
       ,p_object_version_number     =>  l_ovn
       ,p_action_information1       =>  l_full_name
       ,p_action_information6       =>  l_esi_number
       ,p_action_information8       =>  l_prof_tax_number
       ,p_action_information13      =>  l_dob
       ,p_action_information23      =>  l_month||','||l_year
       ,p_action_information24      =>  l_pf_number
       ,p_action_information25      =>  l_pan
       ,p_action_information27      =>  l_superannuation_number
     );

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 130);
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_bank_details%ISOPEN THEN
        CLOSE csr_bank_details;
      END IF;
      IF csr_tax_unit_id%ISOPEN THEN
        CLOSE csr_tax_unit_id;
      END IF;
      IF csr_net_pay_action_info_id%ISOPEN THEN
        CLOSE csr_net_pay_action_info_id;
      END IF;
      IF csr_emp_det_action_info_id%ISOPEN THEN
        CLOSE csr_emp_det_action_info_id;
      END IF;
      IF csr_person_id%ISOPEN THEN
        CLOSE csr_person_id;
      END IF;
      IF csr_person_details%ISOPEN THEN
        CLOSE csr_person_details;
      END IF;
      IF csr_prof_tax_number%ISOPEN THEN
        CLOSE csr_prof_tax_number;
      END IF;
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 140);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END archive_employee_details;

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_FORM_DATA                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the data required for form  --
  --                  3A and form 6A                                      --
  -- Parameters     :                                                     --
  --             IN :      p_assignment_action_id   NUMBER                --
  --                       p_payroll_action_id      NUMBER                --
  --                       p_run_payroll_action_id  NUMBER                --
  --                       p_archive_action_id      NUMBER                --
  --                       p_assignment_id          NUMBER                --
  --                       p_payroll_date           DATE                  --
  --                       p_prepayment_date        DATE                  --
  --                                                                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Jan-2005    aaagarwa   Initial Version                      --
  -- 115.1 01-Mar-2005    aaagarwa   Changes done for incorporating PA data-
  -- 115.2 08-Mar-2005    lnagaraj   Archived data needed for Form 7      --
  -- 115.3 01-Apr-2005    abhjain    Removing the archival of remarks     --
  -- 115.4 01-Apr-2005    lnagaraj   Added p_run_payroll_action_id        --
  --------------------------------------------------------------------------
  --

PROCEDURE archive_form_data
    (
      p_assignment_action_id IN  NUMBER
     ,p_payroll_action_id    IN  NUMBER
     ,p_run_payroll_action_id IN NUMBER
     ,p_archive_action_id    IN  NUMBER
     ,p_assignment_id        IN  NUMBER
     ,p_payroll_date         IN  DATE
     ,p_prepayment_date      IN  DATE
    )
IS

-- Cursor to find Employee details
  CURSOR c_name_pfno_fh_name(p_assignment_action_id NUMBER)
  IS
  SELECT hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) Employee_Name
        ,pep.per_information8 PF_Number
        ,pep.per_information13 Pension_Number
        ,pep.person_id   person_id
        ,con.contact_person_id contact
  FROM per_assignments_f asg
      ,per_people_f pep
      ,pay_assignment_actions paa
      ,per_contact_relationships con
  WHERE asg.PERSON_ID=pep.person_id
  AND asg.assignment_id=paa.assignment_id
  AND paa.assignment_action_id= p_assignment_action_id
  AND con.person_id(+) = pep.person_id
  AND con.contact_type(+) = decode(pep.sex,'M','JP_FT','F',decode(pep.marital_status,'M','S','JP_FT'))
  AND p_payroll_date between pep.effective_start_date and pep.effective_end_date
  AND p_payroll_date between asg.effective_start_date and asg.effective_end_date;

  CURSOR csr_contact_details(p_contact_person_id NUMBER)
  IS
  SELECT  hr_in_utility.per_in_full_name(pea.first_name,pea.middle_names,pea.last_name,pea.title) Father_Husbannd
    FROM  per_people_f pea
   WHERE pea.person_id = p_contact_person_id
     AND p_payroll_date between pea.effective_start_date and pea.effective_end_date;

--  Cursor to find PF Organization Id
  CURSOR c_pf_org_id(p_assignment_action_id NUMBER)
  IS
  select DISTINCT hoi.organization_id source_id
  from hr_organization_units hoi
      ,hr_soft_coding_keyflex scf
      ,per_assignments_f asg
     ,pay_assignment_actions paa
  where asg.assignment_id=paa.assignment_id
  and   paa.assignment_action_id=p_assignment_action_id
  and   asg.SOFT_CODING_KEYFLEX_ID=scf.SOFT_CODING_KEYFLEX_ID
  and   hoi.ORGANIZATION_ID=scf.segment2
  and (to_char(asg.effective_start_date,'Month-YYYY')=to_char(p_payroll_date,'Month-YYYY')
  or   to_char(asg.effective_end_date,'Month-YYYY')=to_char(p_payroll_date,'Month-YYYY')
  or   p_payroll_date between asg.effective_start_date and asg.effective_end_date
      );

--Cursor to find balance value
  Cursor c_defined_balance_id(p_balance_name VARCHAR2
                             ,p_dimension VARCHAR2)
  IS
   select pdb.defined_balance_id
   from  pay_balance_types pbt
        ,pay_balance_dimensions pbd
        ,pay_defined_balances pdb
   where pbt.balance_name=p_balance_name
   and pbd.dimension_name=p_dimension
   and pbt.legislation_code = 'IN'
   and pbd.legislation_code = 'IN'
   and pbt.balance_type_id = pdb.balance_type_id
   and pbd.balance_dimension_id  = pdb.balance_dimension_id;

--Cursor to find the PF Organization Name
  Cursor c_pf_name(p_organization_id NUMBER
                  ,p_effective_date  DATE)
  IS
  SELECT hou.name
  FROM   hr_organization_units hou
  WHERE hou.organization_id=p_organization_id
  AND   p_effective_date BETWEEN hou.date_from AND nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'));

-- Bug 4033745 Start
 /* In case of transfer with Pension number change, we need to archive the PF org id with the correct
   pension number.The data as on date earned of payroll cant be used in this case*/
  -- Get the latest date in current pay period on which the assignment was attached to this PF Org
  CURSOR csr_asg_effective_date(p_assignment_id NUMBER
                               ,p_source_id     NUMBER
                               ,p_pay_start     DATE
                               ,p_pay_end       DATE)
  IS
  SELECT MAX(paf.effective_end_date)
    FROM per_assignments_f paf
        ,hr_soft_coding_keyflex scl
  WHERE paf.soft_coding_keyflex_id=scl.soft_coding_keyflex_id
    AND paf.assignment_id=p_assignment_id
    AND scl.segment2 = p_source_id
    AND paf.effective_start_date <= p_pay_end
    AND paf.effective_end_date >= p_pay_start;

-- Cursor to find the Pension Number as on a given date. We cannot use the date earned of payroll run
-- Modified this cursor to include the PF Number also
  CURSOR csr_pension_number(p_assigment_id NUMBER
                           ,p_date         DATE)
  IS
  SELECT ppf.per_information13 pension_num
        ,ppf.per_information8 PF_Number
    FROM per_people_f ppf
        ,per_assignments_f paf
   WHERE ppf.person_id = paf.person_id
     AND paf.assignment_id = p_assignment_id
     AND p_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
     AND p_date BETWEEN paf.effective_start_date AND paf.effective_end_date;


  /* Find the earliest date on which the person was attached to this PF Organization */
  CURSOR csr_asg_pforg_start(l_person_id NUMBER
                            ,l_source_id NUMBER)
  IS
  SELECT min(paf.effective_start_date)
    FROM per_people_f ppf
        ,per_assignments_f paf
        ,hr_soft_coding_keyflex scl
   WHERE ppf.person_id = l_person_id
     AND paf.person_id =ppf.person_id
     AND paf.soft_coding_keyflex_id =scl.soft_coding_keyflex_id
     AND scl.segment2 = l_source_id;

 /* Find if the person has been transferred out from some other PF Organziation */
  CURSOR csr_chk_trsfr_pforg(l_person_id NUMBER
                          ,l_source_id NUMBER
                          ,l_asg_start_date varchar2)
  IS
  SELECT '1'
    FROM per_people_f ppf
        ,per_assignments_f paf
        ,hr_soft_coding_keyflex scl
   WHERE ppf.person_id = l_person_id
     AND paf.person_id =ppf.person_id
     AND paf.soft_coding_keyflex_id =scl.soft_coding_keyflex_id
     and scl.segment2 IS NOT NULL
     AND scl.segment2 <> l_source_id
     AND paf.effective_end_date < l_asg_start_date
     AND ROWNUM <2;

 /*In case of transfer out from some other organization,find out the pension number on the date
 just before transfer.*/
  CURSOR csr_chk_pension_number_change(l_person_id NUMBER
                                      ,l_asg_start_date varchar2)
  IS
  SELECT ppf.per_information13
    FROM per_people_f ppf
   WHERE ppf.person_id =l_person_id
     AND ppf.per_information13 IS NOT NULL
     AND ppf.effective_start_date < l_asg_start_date
   ORDER BY ppf.effective_start_date desc;

 /*Find hire or rehire date  based on whether pension number was changed during rehire or not */
  CURSOR csr_hire_date(p_person_id NUMBER
                      ,p_pension_number VARCHAR2)
  IS
  SELECT MAX(pos.date_start)
   FROM per_periods_of_service pos
  WHERE pos.person_id = p_person_id
    AND pos.date_start <= (SELECT MIN(effective_start_date)
                             FROM per_people_f ppf
                             WHERE ppf.person_id = p_person_id
                              AND ppf.per_information13  = p_pension_number);

-- Bug 4033745 End


   l_action_info_id           NUMBER;
   l_ovn                      NUMBER;
   l_asg_id                   NUMBER;
   l_balance_defined_id       NUMBER;
   l_VPF_value                NUMBER;
   l_APF_value                NUMBER;
   wage_value                 NUMBER;
   employee_pf_value          NUMBER;
   pension_fund               NUMBER;
   pf_sal                     NUMBER;
   l_epf_diff                 NUMBER;
   l_contribution_rate        NUMBER;
   l_absence                  NUMBER;
   l_contr_period             VARCHAR2(10);
   l_full_name                per_people_f.full_name%TYPE;
   l_pf_number                per_people_f.per_information8%TYPE;
   l_fh_hus                   per_people_f.full_name%TYPE;
   l_source_id                hr_organization_units.organization_id%TYPE;
   l_pf_org_name              hr_organization_units.name%TYPE;
   l_pension_num              per_people_f.per_information13%TYPE;
   flag                       BOOLEAN;
   l_start_date               DATE;
   l_end_date                 DATE;
   l_person_id                NUMBER;
   l_asg_start_date           VARCHAR2(30);
   l_exists                   per_people_f.per_information13%TYPE;
   l_pf_comp_salary           NUMBER;
   l_pf_ytd                   NUMBER;
   l_excluded_employee_status NUMBER;
   l_contact_id               NUMBER;
   l_procedure                VARCHAR2(100);
   l_message                  VARCHAR2(255);




BEGIN


   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'archive_form_data';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('Assignment Action id  ',p_assignment_action_id);
     pay_in_utils.trace('Assignment id         ',p_assignment_id);
     pay_in_utils.trace('Payroll Date          ',p_payroll_date);
     pay_in_utils.trace('**************************************************','********************');
  END IF;


--V
   FOR c_rec IN c_pf_org_id(p_assignment_action_id)
   LOOP
   pay_in_utils.set_location(g_debug,l_procedure, 20);
   l_source_id:=c_rec.source_id;

   IF g_debug THEN
     pay_in_utils.trace('Source id  ',l_source_id);
   END IF;

--A,B,C
   OPEN c_name_pfno_fh_name(p_assignment_action_id);
   FETCH c_name_pfno_fh_name INTO l_full_name,l_pf_number,l_pension_num,l_person_id,l_contact_id;
   CLOSE c_name_pfno_fh_name;

   pay_in_utils.set_location(g_debug,l_procedure, 30);

   OPEN csr_contact_details(l_contact_id);
   FETCH csr_contact_details INTO l_fh_hus;
   CLOSE csr_contact_details;

   IF g_debug THEN
     pay_in_utils.trace('Person id  ',l_person_id);
     pay_in_utils.trace('Full Name  ',l_full_name);
     pay_in_utils.trace('Contact id  ',l_contact_id);
   END IF;


-- Bug 4033745
   l_start_date := trunc(p_payroll_date,'MM');
   l_end_date   := ADD_MONTHS(l_start_date,1) - 1;

     IF g_debug THEN
       pay_in_utils.trace('Start Date  ',l_start_date);
       pay_in_utils.trace('End Date    ',l_end_date);
     END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 40);

   OPEN csr_asg_effective_date(p_assignment_id,l_source_id,l_start_date,l_end_date);
   FETCH csr_asg_effective_date INTO l_asg_start_date;
   CLOSE csr_asg_effective_date;

   l_asg_start_date  := LEAST(l_asg_start_date,l_end_date);

     IF g_debug THEN
       pay_in_utils.trace('Assignment Start Date  ',l_asg_start_date);
     END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 50);

   OPEN csr_pension_number(p_assignment_id,l_asg_start_date);
   FETCH csr_pension_number INTO l_pension_num,l_pf_number;
   CLOSE csr_pension_number;

   -- Bug 4033745
   pay_in_utils.set_location(g_debug,l_procedure, 60);

   IF (l_pf_number IS NULL) AND (l_pension_num IS NULL) THEN
         RETURN;
   END IF;

   IF g_debug THEN
     pay_in_utils.trace('PF Number  ',l_pf_number);
     pay_in_utils.trace('Pension Number  ',l_pension_num);
   END IF;


   -- Hire date is dependent on pension number change and PF organization change. So, we will archive it only
   -- when pension number is entered.In case of PF org change followed by pension number change, the transfer-in date
   -- will be archived. Otherwise hire/rehire date will be used

   --Pension Start
    pay_in_utils.set_location(g_debug,l_procedure, 70);

   IF (l_pension_num IS NOT NULL AND l_source_id IS NOT NULL) THEN
     pay_in_utils.set_location(g_debug,l_procedure, 80);
     OPEN csr_asg_pforg_start(l_person_id,l_source_id);
     FETCH csr_asg_pforg_start INTO l_asg_start_date;
     CLOSE csr_asg_pforg_start;

     IF g_debug THEN
       pay_in_utils.trace('Asg Earliest Start Date  ',l_asg_start_date);
     END IF;


     OPEN csr_chk_trsfr_pforg(l_person_id
                             ,l_source_id
                             ,l_asg_start_date);
     FETCH csr_chk_trsfr_pforg INTO l_exists;
     CLOSE csr_chk_trsfr_pforg;

     pay_in_utils.set_location(g_debug,l_procedure, 90);

     IF l_exists IS NOT NULL THEN
       pay_in_utils.set_location(g_debug,l_procedure, 100);
       OPEN csr_chk_pension_number_change(l_person_id
                                         ,l_asg_start_date);
       FETCH csr_chk_pension_number_change INTO l_exists;
       CLOSE csr_chk_pension_number_change ;
     END IF;

     IF g_debug THEN
       pay_in_utils.trace('Pension Change Exists ',l_exists);
     END IF;

    pay_in_utils.set_location(g_debug,l_procedure, 120);
     IF (nvl(l_exists,l_pension_num) = l_pension_num) THEN
        OPEN csr_hire_date(l_person_id
                          ,l_pension_num);
        FETCH csr_hire_date INTO l_asg_start_date;
        CLOSE csr_hire_date;

        pay_in_utils.set_location(g_debug,l_procedure,130);

     END IF;

   END IF;

  -- Bugfix 4270904
  l_excluded_employee_status := pay_in_ff_pkg.check_retainer(p_assignment_id,p_run_payroll_action_id);


  -- Pension End
  --

-- Populating the PL/SQL Tables
   flag:=TRUE;
   FOR i IN 1..g_cnt_pf LOOP
       IF g_pf_org_id(i)=l_source_id THEN
          flag:=FALSE;
          EXIT;
       END IF;
   END  LOOP;

   IF flag THEN
       g_cnt_pf := g_cnt_pf+1;
       g_pf_org_id(g_cnt_pf):=l_source_id;
       g_pa_act_id(g_cnt_pf):=p_payroll_action_id;
   END IF;
--
   l_balance_defined_id :=0;
--
   pay_in_utils.set_location(g_debug,l_procedure, 140);
--F
   OPEN c_defined_balance_id('PF Actual Salary','_ASG_ORG_MAR_FEB_YTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   l_APF_value:=pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          => null,
                            p_jurisdiction_code    => null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);

   pay_in_utils.set_location(g_debug,l_procedure, 150);

   OPEN c_defined_balance_id('Employee Voluntary PF Contribution','_ASG_ORG_MAR_FEB_YTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   l_VPF_value:=pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          => null,
                            p_jurisdiction_code    => null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                           p_date_earned          =>null);

   IF l_APF_value = 0 THEN
        l_contribution_rate:=0;
   ELSE
        l_contribution_rate:=round((l_VPF_value/l_APF_value)*100,2);
   END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 160);

--H
   OPEN c_defined_balance_id('PF Actual Salary','_ASG_ORG_PTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   wage_value :=pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          =>null,
                            p_jurisdiction_code    =>null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);

     IF g_debug THEN
       pay_in_utils.trace('PF Actual Salary PTD ',wage_value);
     END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 170);

--K
   OPEN c_defined_balance_id('EPS Contribution','_ASG_ORG_PTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   pension_fund:=pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          =>null,
                            p_jurisdiction_code    =>null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);

     IF g_debug THEN
       pay_in_utils.trace('PF Actual Salary PTD  ',wage_value);
     END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 180);
--I,J
   OPEN c_defined_balance_id('Employee Statutory PF Contribution','_ASG_ORG_PTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   employee_pf_value := pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          =>null,
                            p_jurisdiction_code    =>null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);

   l_epf_diff:=employee_pf_value-pension_fund;

     IF g_debug THEN
       pay_in_utils.trace('Employee Statutory PF Contribution PTD  ',employee_pf_value);
     END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 190);

   OPEN c_defined_balance_id('Employee Voluntary PF Contribution','_ASG_ORG_PTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;
   pay_in_utils.set_location(g_debug,l_procedure, 200);
   employee_pf_value := employee_pf_value+pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          =>null,
                            p_jurisdiction_code    =>null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);

     IF g_debug THEN
       pay_in_utils.trace('Employee Voluntary PF Contribution PTD  ',employee_pf_value);
     END IF;



--M
   OPEN c_defined_balance_id('Non Contributory Period','_ASG_PTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;
   pay_in_utils.set_location(g_debug,l_procedure, 210);
   l_absence := pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id);

     IF g_debug THEN
       pay_in_utils.trace('Absence  ',l_absence);
     END IF;

--N

  l_asg_id:=p_assignment_id;

--PF Organization Name
  OPEN c_pf_name(l_source_id,p_payroll_date);
  FETCH c_pf_name INTO l_pf_org_name;
  CLOSE c_pf_name;

   pay_in_utils.set_location(g_debug,l_procedure, 220);

--Contribution Period
  l_start_date := p_payroll_date;
  l_end_date   := p_payroll_date;
  IF(to_number(to_char(l_start_date,'MM'))) = 3 THEN
     l_start_date:=add_months(l_start_date,1);
     l_end_date  :=l_start_date;
  END IF;

  l_contr_period:=to_char(pay_in_tax_utils.get_financial_year_start(l_start_date),'YYYY')||'-'||to_char(pay_in_tax_utils.get_financial_year_end(l_end_date),'YYYY');


  OPEN c_defined_balance_id('PF Computation Salary','_ASG_PTD');
  FETCH c_defined_balance_id INTO l_balance_defined_id;
  CLOSE c_defined_balance_id;

  pay_in_utils.set_location(g_debug,l_procedure, 230);

  l_pf_comp_salary :=pay_balance_pkg.get_value(p_defined_balance_id   =>l_balance_defined_id,
                                               p_assignment_action_id =>p_assignment_action_id);

     IF g_debug THEN
       pay_in_utils.trace('PF Computation Salary PTD  ',l_pf_comp_salary);
     END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 240);

pay_action_information_api.create_action_information
  (p_action_context_id              =>     p_archive_action_id  --Archive Action id
  ,p_action_context_type            =>     'AAP'
  ,p_action_information_category    =>     'IN_PF_ASG'
  ,p_tax_unit_id                    =>     null
  ,p_jurisdiction_code              =>     null
  ,p_source_id                      =>     null
  ,p_source_text                    =>     null
  ,p_tax_group                      =>     null
  ,p_effective_date                 =>     p_prepayment_date      --Prepayment Effective Date
  ,p_assignment_id                  =>     l_asg_id               --Asg Id
  ,p_action_information1            =>     l_contr_period         --Contribution Period
  ,p_action_information2            =>     l_source_id            --PF Organization
  ,p_action_information3            =>     l_pf_number            --PF Number
  ,p_action_information4            =>     l_full_name            --Full Name
  ,p_action_information5            =>     l_fh_hus               --Father/Husband Name
  ,p_action_information6            =>     l_contribution_rate    --Voluntary Higher Contr Rate
  ,p_action_information7            =>     wage_value             --PF Salary  _ASG_ORG_PTD
  ,p_action_information8            =>     employee_pf_value      --Total Employee Contr
  ,p_action_information9            =>     l_epf_diff             --Employer Contr towards PF
  ,p_action_information10           =>     pension_fund           --Employer Contr towards Pension
  ,p_action_information11           =>     l_absence              --Absence
--  ,p_action_information12           =>     l_remarks              --Remarks
  ,p_action_information13           =>     p_payroll_date         --Payroll Date
  ,p_action_information14           =>     l_pf_org_name          --PF Org Name
  ,p_action_information15           =>     l_pension_num          --Pension Number
  ,p_action_information16           =>     l_asg_start_date       --Hire Date
  ,p_action_information17           =>     l_pf_comp_salary       --PF Computation Salary
  ,p_action_information18           =>     l_excluded_employee_status -- Excluded Employee status
  ,p_action_information19           =>     null
  ,p_action_information20           =>     null
  ,p_action_information21           =>     null
  ,p_action_information22           =>     null
  ,p_action_information23           =>     null
  ,p_action_information24           =>     null
  ,p_action_information25           =>     null
  ,p_action_information26           =>     null
  ,p_action_information27           =>     null
  ,p_action_information28           =>     null
  ,p_action_information29           =>     null
  ,p_action_information30           =>     null
  ,p_action_information_id          =>     l_action_info_id        --OUT Parameters
  ,p_object_version_number          =>	   l_ovn                   --OUT Parameters
  );
   pay_in_utils.set_location(g_debug,l_procedure, 250);
   END LOOP;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 260);

   EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 270);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;

END archive_form_data;

 ---------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ESI_DATA                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the data required for form 6--
  -- Parameters     :                                                     --
  --             IN :      p_assignment_action_id   NUMBER                --
  --                       p_payroll_action_id      NUMBER                --
  --                       p_archive_action_id      NUMBER                --
  --                       p_assignment_id          NUMBER                --
  --                       p_payroll_date           DATE                  --
  --                       p_prepayment_date        DATE                  --
  --                                                                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 10-Mar-2005    aaagarwa   Initial Version                      --
  -- 115.1 01-Apr-2005    abhjain    Removed the archival of remarks      --
  -- 115.2 04-Sep-2008    lnagaraj   Added for disabled employee          --
  --------------------------------------------------------------------------
  --
  PROCEDURE archive_esi_data
    (
      p_assignment_action_id IN  NUMBER
     ,p_payroll_action_id    IN  NUMBER
     ,p_archive_action_id    IN  NUMBER
     ,p_assignment_id        IN  NUMBER
     ,p_payroll_date         IN  DATE
     ,p_prepayment_date      IN  DATE
     )
IS
--  Cursor to find ESI Organization Id
  CURSOR c_esi_org_id(p_assignment_action_id NUMBER)
  IS
  SELECT DISTINCT hoi.organization_id source_id
  FROM hr_organization_units hoi
      ,hr_soft_coding_keyflex scf
      ,per_assignments_f asg
     ,pay_assignment_actions paa
  WHERE asg.assignment_id=paa.assignment_id
  AND   paa.assignment_action_id=p_assignment_action_id
  AND   asg.SOFT_CODING_KEYFLEX_ID=scf.SOFT_CODING_KEYFLEX_ID
  AND   hoi.ORGANIZATION_ID=scf.segment4
  AND (to_char(asg.effective_start_date,'Month-YYYY')=to_char(p_payroll_date,'Month-YYYY')
  OR   to_char(asg.effective_end_date,'Month-YYYY')=to_char(p_payroll_date,'Month-YYYY')
  OR   p_payroll_date BETWEEN asg.effective_start_date AND asg.effective_end_date
      );

CURSOR csr_hire_date
IS
SELECT	SERVICE.date_start
FROM
	/* Person current period of service date details */
        per_all_assignments_f                   ASSIGN
,       per_periods_of_service                  SERVICE
WHERE   p_payroll_date BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND     ASSIGN.assignment_id                  = p_assignment_id
AND     SERVICE.period_of_Service_id       = ASSIGN.period_of_service_id;

-- Cursor to find full name, ESI number, Person Id
  CURSOR c_name_esino_fh_name(p_assignment_action_id NUMBER)
  IS
  SELECT hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) Employee_Name
        ,pep.per_information9 ESI_Number
        ,pep.person_id  person_id
  FROM per_assignments_f asg
      ,per_people_f pep
      ,pay_assignment_actions paa
  WHERE asg.PERSON_ID=pep.person_id
  AND asg.assignment_id=paa.assignment_id
  AND paa.assignment_action_id= p_assignment_action_id
  AND p_payroll_date BETWEEN pep.effective_start_date AND pep.effective_end_date
  AND p_payroll_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

--Cursor to find balance value
  CURSOR c_defined_balance_id(p_balance_name VARCHAR2
                             ,p_dimension VARCHAR2)
  IS
   SELECT pdb.defined_balance_id
   FROM  pay_balance_types pbt
        ,pay_balance_dimensions pbd
        ,pay_defined_balances pdb
   WHERE pbt.balance_name=p_balance_name
   AND pbd.dimension_name=p_dimension
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.balance_dimension_id  = pdb.balance_dimension_id;


--Cursor to find the remarks entered by the user in that payroll run

  --Find the element type id
  CURSOR c_element_type_id
  IS
   SELECT  element_type_id
     FROM  pay_element_types_f
    WHERE  element_name='ESI Information'
      AND  legislation_code = 'IN'
      AND  p_payroll_date between effective_start_date and effective_end_date;

  --Find the input value id for Reason for Exemption, Organization and Remarks
  CURSOR c_iv_id(p_element_type_id NUMBER,p_name VARCHAR2)
  IS
    SELECT  input_value_id
      FROM  pay_input_values_f
     WHERE  element_type_id = p_element_type_id
       AND  name = p_name
       AND  p_payroll_date BETWEEN effective_start_date AND effective_end_date;

  --Find the run result id
  CURSOR c_run_result_id(p_element_type_id NUMBER)
  IS
   SELECT  run_result_id
     FROM  pay_run_results
    WHERE  assignment_action_id=p_assignment_action_id
      AND  element_type_id=p_element_type_id;

  --Find the actual remarks
  CURSOR c_remarks(p_run_result_id NUMBER,p_org_iv_id NUMBER,p_rem_iv_id NUMBER,p_org_id NUMBER)
  IS
    SELECT  prr2.result_value
      FROM  pay_run_result_values prr1
           ,pay_run_result_values prr2
     WHERE prr1.run_result_id   = p_run_result_id
       AND prr1.input_value_id  = p_org_iv_id
       AND prr2.run_result_id   = prr1.run_result_id
       AND prr2.input_value_id  = p_rem_iv_id
       AND prr1.result_value    = p_org_id;

--Cursor to find the ESI Organization Name
  Cursor c_esi_name(p_organization_id NUMBER
                  ,p_effective_date  DATE)
  IS
  SELECT hou.name
  FROM   hr_organization_units hou
  WHERE hou.organization_id=p_organization_id
  AND   p_effective_date BETWEEN hou.date_from AND nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'));

--Cursor to find date of death
  CURSOR c_death_date(p_person_id      NUMBER
                     ,p_effective_date DATE)
  IS
  SELECT  '1'
  FROM    per_people_f
  WHERE   person_id= p_person_id
  AND     date_of_death	<= p_effective_date ;

--Cursor to find termination status
 CURSOR c_term_check(p_person_id      NUMBER
                    ,p_effective_date DATE)
  IS
  SELECT  '1'
  FROM    per_periods_of_service
  WHERE   actual_termination_date <= p_effective_date
  AND     person_id = p_person_id
  AND     date_start = (SELECT  MAX(TO_DATE(date_start,'DD-MM-YY'))
                         FROM    per_periods_of_service
                         WHERE   person_id = p_person_id
                         AND     business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                        );

--Cursor to find the asg end date
  CURSOR csr_asg_effective_date(p_assignment_id NUMBER
                               ,p_source_id     NUMBER
                               ,p_pay_start     DATE
                               ,p_pay_end       DATE)
  IS
  SELECT MAX(paf.effective_end_date)
    FROM per_assignments_f paf
        ,hr_soft_coding_keyflex scl
  WHERE paf.soft_coding_keyflex_id=scl.soft_coding_keyflex_id
    AND paf.assignment_id=p_assignment_id
    AND scl.segment4 = p_source_id
    AND paf.effective_start_date <= p_pay_end
    AND paf.effective_end_date >= p_pay_start;

--Cursor to find ESI Number at asg date
  CURSOR csr_esi_number(p_assigment_id NUMBER
                       ,p_date         DATE)
  IS
  SELECT ppf.per_information9 ESI_Number
    FROM per_people_f ppf
        ,per_assignments_f paf
   WHERE ppf.person_id = paf.person_id
     AND paf.assignment_id = p_assignment_id
     AND p_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
     AND p_date BETWEEN paf.effective_start_date AND paf.effective_end_date;

--------Cursor ---to get the ceiling value-------
CURSOR c_esi_ceiling_value(c_global_value VARCHAR2)
IS
SELECT global_value
FROM   ff_globals_f
WHERE  legislation_code='IN'
AND    global_name = c_global_value
AND    p_payroll_date BETWEEN effective_start_date AND effective_end_date;


  CURSOR csr_emplr_class IS
  SELECT target.org_information3	FROM
       per_all_assignments_f assign,
       hr_soft_coding_keyflex scl,
       hr_organization_information target
  WHERE assign.assignment_id   = p_assignment_id
  AND   p_payroll_date BETWEEN ASSIGN.effective_start_date AND ASSIGN.effective_end_date
  AND   assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND   scl.segment1  = target.organization_id
  AND   target.org_information_context = 'PER_IN_INCOME_TAX_DF';




   l_action_info_id           NUMBER;
   l_ovn                      NUMBER;
   l_asg_id                   NUMBER;
   l_balance_defined_id       NUMBER;
   wage_value                 NUMBER;
   l_esi_ytd                  NUMBER;
   l_employee_contribution    NUMBER;
   l_employer_contribution    NUMBER;
   l_absence                  NUMBER;
   l_contr_period             VARCHAR2(30);
   l_full_name                per_people_f.full_name%TYPE;
   l_person_id                per_people_f.person_id%TYPE;
   l_esi_number               per_people_f.per_information9%TYPE;
   l_source_id                hr_organization_units.organization_id%TYPE;
   l_esi_org_name             hr_organization_units.name%TYPE;
   flag                       BOOLEAN;
   l_reason_for_exem          VARCHAR2(60);
   l_exempted_frm_esi         VARCHAR2(5);
   l_temp                     VARCHAR2(5);
   l_element_type_id          NUMBER;
   l_org_iv_id                NUMBER;
   l_reason_iv_id             NUMBER;
   l_start_date               DATE;
   l_end_date                 DATE;
   l_asg_start_date           DATE;
   l_eligible_salary          NUMBER ;
   l_esi_ceiling_value        NUMBER ;
   l_esi_con_salary           NUMBER ;
   l_hire_date                DATE;
   l_disable_proof            VARCHAR2(10);
   l_emplr_class              hr_organization_information.org_information3%TYPE;
   l_global_value             ff_globals_f.global_name%TYPE;
   l_dummy                    NUMBER;

   l_message   VARCHAR2(255);
   l_procedure VARCHAR2(100);

BEGIN

 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'archive_esi_data';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
       pay_in_utils.trace('Assignment Action id  ',p_assignment_action_id);
       pay_in_utils.trace('Payroll Action id     ',p_payroll_action_id);
       pay_in_utils.trace('Archive Action id     ',p_archive_action_id);
       pay_in_utils.trace('Assignment id         ',p_assignment_id);
       pay_in_utils.trace('Payroll Date          ',p_payroll_date);
       pay_in_utils.trace('Prepayment_date       ',p_prepayment_date);
   END IF;


--Determine the distinct ESI Organizations for that assignment in that payroll run
   FOR c_rec IN c_esi_org_id(p_assignment_action_id)
   LOOP

   l_source_id:=c_rec.source_id;
   IF g_debug THEN
       pay_in_utils.trace('ESI Organization id  ',l_source_id);
   END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 20);

--Find the assignments's full name and esi number
   OPEN c_name_esino_fh_name(p_assignment_action_id);
   FETCH c_name_esino_fh_name INTO l_full_name,l_esi_number,l_person_id;
   CLOSE c_name_esino_fh_name;

   l_start_date := TRUNC(p_payroll_date,'MM');
   l_end_date   := ADD_MONTHS(l_start_date,1) - 1;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

   OPEN csr_asg_effective_date(p_assignment_id,l_source_id,l_start_date,l_end_date);
   FETCH csr_asg_effective_date INTO l_asg_start_date;
   CLOSE csr_asg_effective_date;

   pay_in_utils.set_location(g_debug,l_procedure, 30);

   l_asg_start_date  := LEAST(l_asg_start_date,l_end_date);

    IF g_debug THEN
       pay_in_utils.trace('Assignment Start Date  ',l_asg_start_date);
       pay_in_utils.trace('End Date               ',l_end_date);
    END IF;

   OPEN csr_esi_number(p_assignment_id,l_asg_start_date);
   FETCH csr_esi_number INTO l_esi_number;
   CLOSE csr_esi_number;

   pay_in_utils.set_location(g_debug,l_procedure, 40);


   IF (l_esi_number IS NULL)THEN
      pay_in_utils.set_location(g_debug,l_procedure, 50);
    RETURN;
   END IF;

    IF g_debug THEN
       pay_in_utils.trace('ESI Number        ',l_esi_number);
    END IF;


-- Populating the PL/SQL Tables with ESI Number and corresponding payroll action id
   flag:=TRUE;

   pay_in_utils.set_location(g_debug,l_procedure, 60);

   FOR i IN 1..g_cnt_esi LOOP
      pay_in_utils.set_location(g_debug,l_procedure, 70);
       IF g_esi_org_id(i)=l_source_id THEN
          flag:=FALSE;
          EXIT;
       END IF;
   END  LOOP;
      pay_in_utils.set_location(g_debug,l_procedure, 80);
   IF flag THEN
       g_cnt_esi:=g_cnt_esi+1;
       g_esi_org_id(g_cnt_esi):=l_source_id;
       g_esi_act_id(g_cnt_esi):=p_payroll_action_id;

       IF g_debug THEN
         pay_in_utils.trace('g_esi_org_id table       ',g_esi_org_id(g_cnt_esi));
       END IF;

   END IF;
--
   l_balance_defined_id :=0;
--
      pay_in_utils.set_location(g_debug,l_procedure, 90);
--ESI Actual Salary for dimension _ASG_ORG_HYTD
   OPEN c_defined_balance_id('ESI Actual Salary','_ASG_ORG_HYTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;
    pay_in_utils.set_location(g_debug,l_procedure, 90);

   wage_value := pay_balance_pkg.get_value(
                            p_defined_balance_id   => l_balance_defined_id,
                            p_assignment_action_id => p_assignment_action_id,
                            p_tax_unit_id          => null,
                            p_jurisdiction_code    => null,
                            p_source_id            => l_source_id,
                            p_tax_group            => null,
                            p_date_earned          => null
    );

    IF g_debug THEN
       pay_in_utils.trace('ESI Wages        ',wage_value);
    END IF;

--Employee Contribution
   OPEN c_defined_balance_id('Employee ESI Contribution','_ASG_ORG_HYTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

      pay_in_utils.set_location(g_debug,l_procedure, 100);

   l_employee_contribution :=pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          => null,
                            p_jurisdiction_code    => null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);

    IF g_debug THEN
       pay_in_utils.trace('ESI Employee Contribution ',l_employee_contribution);
    END IF;


--Employer Contribution
   OPEN c_defined_balance_id('Employer ESI Contribution','_ASG_ORG_HYTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   pay_in_utils.set_location(g_debug,l_procedure, 110);

   l_employer_contribution :=pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id,
                            p_tax_unit_id          =>null,
                            p_jurisdiction_code    =>null,
                            p_source_id            =>l_source_id,
                            p_tax_group            =>null,
                            p_date_earned          =>null);
    IF g_debug THEN
       pay_in_utils.trace('ESI Employer Contribution ',l_employer_contribution);
    END IF;



--Absence
   OPEN c_defined_balance_id('Non Contributory Period','_ASG_RUN');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

      pay_in_utils.set_location(g_debug,l_procedure, 100);

   l_absence := pay_balance_pkg.get_value(
                            p_defined_balance_id   =>l_balance_defined_id,
                            p_assignment_action_id =>p_assignment_action_id
                            );

    IF g_debug THEN
       pay_in_utils.trace('Employee absence ',l_absence);
    END IF;



   ----------get ESI Eligible salary-------------

   OPEN c_defined_balance_id('ESI Eligible Salary','_ASG_PTD');
   FETCH c_defined_balance_id INTO l_balance_defined_id;
   CLOSE c_defined_balance_id;

   pay_in_utils.set_location(g_debug,l_procedure, 120);



   l_eligible_salary := pay_balance_pkg.get_value(
                            p_defined_balance_id   => l_balance_defined_id,
                            p_assignment_action_id => p_assignment_action_id,
                            p_tax_unit_id          => null,
                            p_jurisdiction_code    => null,
                            p_source_id            => null,
                            p_tax_group            => null,
                            p_date_earned          => null
                            );

    IF g_debug THEN
       pay_in_utils.trace('Esi Eligible Salary ',l_eligible_salary);
    END IF;


--Reason for Exemption, Remarks and ESI Coverage Status
  l_temp := NULL;
  OPEN  c_death_date(l_person_id,p_payroll_date);
  FETCH c_death_date INTO l_temp;
  CLOSE c_death_date;

  pay_in_utils.set_location(g_debug,l_procedure, 130);

  OPEN  c_term_check(l_person_id,p_payroll_date);
  FETCH c_term_check INTO l_temp;
  CLOSE c_term_check;

  pay_in_utils.set_location(g_debug,l_procedure, 140);

  l_asg_id := p_assignment_id;
--  l_remarks         := NULL;
  l_reason_for_exem := NULL;

  OPEN  c_element_type_id;
  FETCH c_element_type_id INTO l_element_type_id;
  CLOSE c_element_type_id;

  OPEN  c_iv_id(l_element_type_id,'Organization');
  FETCH c_iv_id INTO l_org_iv_id;
  CLOSE c_iv_id;

  OPEN  c_iv_id(l_element_type_id,'Reason for Exemption');
  FETCH c_iv_id INTO l_reason_iv_id;
  CLOSE c_iv_id;


  pay_in_utils.set_location(g_debug,l_procedure, 150);

  FOR c_rec IN c_run_result_id(l_element_type_id)
  LOOP

     pay_in_utils.set_location(g_debug,l_procedure, 160);

    OPEN  c_remarks(c_rec.run_result_id,l_org_iv_id,l_reason_iv_id,l_source_id);
    FETCH c_remarks INTO l_reason_for_exem;
    CLOSE c_remarks;

  END LOOP;

   IF g_debug THEN
       pay_in_utils.trace('ESI Reason for Exemption ',l_reason_for_exem);
    END IF;

  IF (l_reason_for_exem IS NOT NULL)
     OR
     (l_employer_contribution = 0 AND l_employee_contribution = 0 )
     OR
     (l_temp IS NOT NULL )
  THEN
       l_exempted_frm_esi:='Yes';
  ELSE
       l_exempted_frm_esi:='No';
  END IF;

--ESI Organization Name
  OPEN  c_esi_name(l_source_id,p_payroll_date);
  FETCH c_esi_name INTO l_esi_org_name;
  CLOSE c_esi_name;
  pay_in_utils.set_location(g_debug,l_procedure, 170);



-----get salary in a specified contribution period ---------

 l_esi_con_salary := pay_in_ff_pkg.get_esi_cont_amt(p_assignment_action_id =>p_assignment_action_id
                         ,p_assignment_id =>p_assignment_id
                         ,p_date_earned   =>p_payroll_date
                         ,p_eligible_amt  =>l_eligible_salary
                          );

   IF g_debug THEN
       pay_in_utils.trace('Eligibility Salary in Contribution Period ',l_esi_con_salary);
    END IF;

l_dummy := pay_in_ff_pkg.get_esi_disability_details(p_assignment_id => p_assignment_id
                                        ,p_date_earned   => p_payroll_date
                                        ,p_disable_proof => l_disable_proof);

--Esi Ceiling  Value--
  ------ESI eligible salary------




  OPEN csr_hire_date;
  FETCH csr_hire_date INTO l_hire_date;
  CLOSE csr_hire_date;

  OPEN csr_emplr_class;
  FETCH csr_emplr_class INTO l_emplr_class;
  CLOSE csr_emplr_class;



  IF(l_hire_date >= to_date('01-04-2008','DD-mm-yyyy') and
     l_emplr_class IN('NSCG' , 'FIRM' , 'OTHR') and
     l_disable_proof = 'Y') THEN
        l_global_value := 'IN_ESI_DISABLED_WAGE_CEILING';
   ELSE
        l_global_value := 'IN_ESI_ELIGIBILITY_WAGE_CEILING';

  END IF;


  OPEN c_esi_ceiling_value(l_global_value);
  FETCH c_esi_ceiling_value INTO l_esi_ceiling_value;
  CLOSE c_esi_ceiling_value;


  pay_in_utils.set_location(g_debug,l_procedure, 180);

IF (l_esi_con_salary > l_esi_ceiling_value)THEN
       RETURN ;
END IF ;

      pay_in_utils.set_location(g_debug,l_procedure, 190);


--Contribution Period
  IF(to_number(to_char(p_payroll_date,'MM'))) > 3 AND (to_number(to_char(p_payroll_date,'MM'))) < 10 THEN
         l_contr_period :='Apr-'||to_char(p_payroll_date,'YYYY')||' - '||'Sep-'||to_char(p_payroll_date,'YYYY');
  ELSE
         l_contr_period :='Oct-'||to_char(pay_in_tax_utils.get_financial_year_start(p_payroll_date),'YYYY')||' - '||'Mar-'||to_char(pay_in_tax_utils.get_financial_year_end(p_payroll_date),'YYYY');
  END IF;
--ESI Coverage

   IF g_debug THEN
       pay_in_utils.trace('Contribution Period End ',l_contr_period);
    END IF;


        pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_archive_action_id   --Archive Action id
                  ,p_action_context_type            =>     'AAP'
                  ,p_action_information_category    =>     'IN_ESI_ASG'
                  ,p_tax_unit_id                    =>     null
                  ,p_jurisdiction_code              =>     null
                  ,p_source_id                      =>     null
                  ,p_source_text                    =>     null
                  ,p_tax_group                      =>     null
                  ,p_effective_date                 =>     p_prepayment_date      --Prepayment Effective Date
                  ,p_assignment_id                  =>     l_asg_id               --Asg Id
                  ,p_action_information1            =>     l_contr_period         --Contribution Period
                  ,p_action_information2            =>     l_source_id            --ESI Organization
                  ,p_action_information3            =>     l_esi_number           --ESI Number
                  ,p_action_information4            =>     l_full_name            --Full Name
                  ,p_action_information5            =>     l_absence              --Absence
                  ,p_action_information6            =>     wage_value             --ESI Salary  _ASG_ORG_PTD
                  ,p_action_information7            =>     l_employee_contribution--Employee Contribution
                  ,p_action_information8            =>     l_employer_contribution--Employer Contribution
                  ,p_action_information9            =>     l_exempted_frm_esi     --ESI Coverage
                --  ,p_action_information10           =>     l_remarks              --Remarks
                  ,p_action_information11           =>     p_payroll_date         --Payroll Date
                  ,p_action_information12           =>     null
                  ,p_action_information13           =>     l_esi_org_name         --Local ESI Office
                  ,p_action_information14           =>     null
                  ,p_action_information15           =>     null
                  ,p_action_information16           =>     null
                  ,p_action_information17           =>     null
                  ,p_action_information18           =>     null
                  ,p_action_information19           =>     null
                  ,p_action_information20           =>     null
                  ,p_action_information21           =>     null
                  ,p_action_information22           =>     null
                  ,p_action_information23           =>     null
                  ,p_action_information24           =>     null
                  ,p_action_information25           =>     null
                  ,p_action_information26           =>     null
                  ,p_action_information27           =>     null
                  ,p_action_information28           =>     null
                  ,p_action_information29           =>     null
                  ,p_action_information30           =>     null
                  ,p_action_information_id          =>     l_action_info_id        --OUT Parameters
                  ,p_object_version_number          =>	   l_ovn                   --OUT Parameters
  );
      pay_in_utils.set_location(g_debug,l_procedure, 200);

   END LOOP;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 210);

   EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 220);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
 END archive_esi_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PAYROLL_DATA                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the data required for PF form-
  --                  3A,6A and ESI Form 6 data at PA Level               --
  -- Parameters     :                                                     --
  --             IN : p_context VARCHAR2                                  --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Mar-2005    aaagarwa  Initial Version                       --
  -- 115.1 07-Mar-2005    aaagarwa  Modified it to handle ESI Org's also  --
  -- 115.2 22-Apr-2005    sukukuma  Added new join condition to the       --
  --                                cursor c_rep_adr to show              --
  --                                resedential address                   --
  -- 115.3 25-Sep-2007    rsaharay  Modified c_rep_pos                    --
  --------------------------------------------------------------------------
  PROCEDURE archive_payroll_data(p_context IN VARCHAR2)
  IS
   --Cursor to find the effective date
   CURSOR c_effective_date(p_payroll_action_id NUMBER)
   IS
      SELECT effective_date
      FROM pay_payroll_actions
      WHERE payroll_action_id=p_payroll_action_id;

  --Cursor to find the PF/ESI Organization Name
  Cursor c_org_name(p_organization_id NUMBER
                  ,p_effective_date  DATE)
  IS
  SELECT hou.name
  FROM   hr_organization_units hou
  WHERE  hou.organization_id=p_organization_id
  AND    p_effective_date BETWEEN hou.date_from AND nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'));

   --Cursor to find the Registered name, Code of the PF/ESI Organization , Classification and its address
  CURSOR c_registered_name(p_organization_id NUMBER
                          ,p_effective_date  DATE)
  IS
       SELECT hou.name
             ,hoi.org_information1
             ,hoi.org_information3
             ,substr(
              hla.address_line_1||
              decode(hla.address_line_2,null,null,','||hla.address_line_2)||
              decode(hla.address_line_3,null,null,','||hla.address_line_3)||
              decode(hla.loc_information14,null,null,','||hla.loc_information14)||
              decode(hla.loc_information15,null,null,','||hla.loc_information15)||
              decode(hr_general.decode_lookup('IN_STATES',hla.loc_information16),null,null,','||hr_general.decode_lookup('IN_STATES',hla.loc_information16))||
              decode(hla.postal_code,null,null,','||hla.postal_code)
              ,1,240)
       FROM hr_organization_information hoi
           ,hr_organization_units hou
           ,hr_organization_units hou1
           ,hr_locations_all hla
       WHERE hoi.organization_id=p_organization_id
       AND   hoi.org_information_context = DECODE(p_context,'PF','PER_IN_PF_DF','ESI','PER_IN_ESI_DF')
       AND   hou.organization_id = DECODE (p_context,'PF',hoi.org_information8,'ESI',hoi.org_information2)
       AND   hla.location_id=hou1.location_id
       AND   hou.organization_id=hou1.organization_id
       AND   p_effective_date BETWEEN  hou.date_from AND  nvl(hou.date_to,to_date('31-12-4712','DD-MM-YYYY'));

   --Cursor to find the PF/ESI Representative Name
   CURSOR c_rep_name(p_pf_org_id      NUMBER
                    ,p_effective_date DATE)
   IS
     SELECT DISTINCT hr_in_utility.per_in_full_name(peap.first_name,peap.middle_names,peap.last_name,peap.title)      rep_name
           ,peap.person_id               person_id
     FROM   hr_organization_information hoi
	   ,per_people_f peap
     WHERE hoi.ORGANIZATION_ID=p_pf_org_id
     AND   hoi.ORG_INFORMATION_CONTEXT = DECODE (p_context,'PF','PER_IN_PF_REP_DF','ESI','PER_IN_ESI_REP_DF')
     AND   peap.person_id=hoi.ORG_INFORMATION1
     AND   p_effective_date BETWEEN fnd_date.canonical_to_date(hoi.org_information2)
     AND   NVL(fnd_date.canonical_to_date(hoi.org_information3),TO_DATE('31-12-4712','DD-MM-YYYY'));

   -- Cursor to find ESI Rep's Address
   CURSOR c_rep_adr(p_person_id      NUMBER
                   ,p_effective_date DATE)
   IS
    SELECT SUBSTR(
        address_line1||
                DECODE(address_line2,NULL,NULL,','||address_line2)||
                DECODE(address_line3,NULL,NULL,','||address_line3)||
                DECODE(add_information13,NULL,NULL,','||add_information13)||
                DECODE(add_information14,NULL,NULL,','||add_information14)||
                DECODE(hr_general.decode_lookup('IN_STATES',add_information15),NULL,NULL,','||hr_general.decode_lookup('IN_STATES',add_information15))||
                DECODE(postal_code,NULL,NULL,','||postal_code)
                ,1,240) address
     FROM   per_addresses
    WHERE  person_id=p_person_id
      AND    address_type='HK_R'
      AND    p_effective_date BETWEEN date_from AND nvl(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

   --Cursor to find the Position of ESI Rep
   /*Bug 4278673*/
   CURSOR c_rep_pos(p_person_id      NUMBER
                   ,p_effective_date DATE)
   IS
   SELECT nvl(pos.name,job.name) name
   FROM   per_positions     pos
         ,per_assignments_f asg
         ,per_jobs          job
   WHERE  asg.position_id=pos.position_id(+)
   AND    asg.job_id=job.job_id(+)
   AND    asg.person_id = p_person_id
   AND    asg.primary_flag = 'Y'
   AND    p_effective_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
   AND    p_effective_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
   AND    p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

   --Cursor to find the PA level data presence
     CURSOR c_pa_data(p_context             VARCHAR2
                     ,p_organization_id     NUMBER
                     ,p_payroll_action_id   NUMBER
                     ,p_contribution_period VARCHAR2
                     )
     IS
         SELECT 1
         FROM   pay_action_information
         WHERE  action_context_id = p_payroll_action_id
         AND    action_information_category = 'IN_'||p_context||'_PAY'
         AND    action_information1 = p_contribution_period
         AND    action_information2 = p_organization_id
         AND    action_context_type = 'PA';

     l_org_rep_name         per_people_f.full_name%TYPE;
     l_reg_name             hr_organization_units.name%TYPE;
     l_code                 hr_organization_information.org_information1%TYPE;
     l_org_name             hr_organization_units.name%TYPE;
     l_address              VARCHAR2(240);
     l_contr_period         VARCHAR2(35);
     l_class                VARCHAR2(10);
     l_action_info_id       NUMBER;
     l_ovn                  NUMBER;
     l_rep_person_id        NUMBER;
     l_rep_addr             VARCHAR2(240);
     l_rep_pos              PER_ALL_POSITIONS.NAME%TYPE;
     l_effective_date       DATE;
     l_start_date           DATE;
     l_end_date             DATE;
     l_count                NUMBER;
     l_org_id               NUMBER;
     l_act_id               NUMBER;
     l_act_inf_cat          VARCHAR2(30);
     l_context              VARCHAR2(240);
     l_flag                 NUMBER := 0;

     l_message   VARCHAR2(255);
     l_procedure VARCHAR2(100);

BEGIN

 l_procedure := g_package ||'archive_payroll_data';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_count := 0;
   IF p_context = 'PF' THEN
       l_count:= g_cnt_pf;
       l_act_inf_cat:='IN_PF_PAY';
   ELSE
       l_count:=g_cnt_esi;
       l_act_inf_cat:='IN_ESI_PAY';
   END IF;

   IF g_debug THEN
       pay_in_utils.trace('Context ',p_context);
   END IF;

   FOR i IN 1..l_count LOOP
   pay_in_utils.set_location(g_debug,l_procedure, 20);
     IF p_context = 'PF' THEN
       l_act_id:=g_pa_act_id(i);
       l_org_id:=g_pf_org_id(i);
     ELSE
       l_act_id:=g_esi_act_id(i);
       l_org_id:=g_esi_org_id(i);
     END IF;

   IF g_debug THEN
       pay_in_utils.trace('Payroll_Level Asg ID  ',l_act_id);
       pay_in_utils.trace('Payroll_Level Org ID  ',l_org_id);
   END IF;

     --Effective Date
     OPEN c_effective_date(l_act_id);
     FETCH c_effective_date INTO l_effective_date;
     CLOSE c_effective_date;

   pay_in_utils.set_location(g_debug,l_procedure, 30);

   IF g_debug THEN
       pay_in_utils.trace('Effective Date  ',l_effective_date);
   END IF;


     --Contribution Period
     IF p_context = 'PF' THEN
        pay_in_utils.set_location(g_debug,l_procedure, 40);
        l_start_date := l_effective_date;
        l_end_date   := l_effective_date;

        IF(TO_NUMBER(TO_CHAR(l_start_date,'MM'))) = 3 THEN
          l_start_date:=add_months(l_start_date,1);
          l_end_date  :=l_start_date;
        END IF;

        l_contr_period := TO_CHAR(pay_in_tax_utils.get_financial_year_start(l_start_date),'YYYY')||'-'||to_char(pay_in_tax_utils.get_financial_year_end(l_end_date),'YYYY');
     ELSIF p_context = 'ESI' THEN
         pay_in_utils.set_location(g_debug,l_procedure, 50);
       IF(TO_NUMBER(TO_CHAR(l_effective_date,'MM'))) > 3 AND (TO_NUMBER(TO_CHAR(l_effective_date,'MM'))) < 10 THEN
                 l_contr_period:='Apr-'||to_char(l_effective_date,'YYYY')||' - '||'Sep-'||to_char(l_effective_date,'YYYY');
           ELSE
                 l_contr_period:='Oct-'||to_char(pay_in_tax_utils.get_financial_year_start(l_effective_date),'YYYY')||' - '||'Mar-'||to_char(pay_in_tax_utils.get_financial_year_end(l_effective_date),'YYYY');

           END IF;
     END IF;

         pay_in_utils.set_location(g_debug,l_procedure, 50);

--Checking for PA level Data's presence in the already archived data
    OPEN  c_pa_data(p_context,l_org_id,l_act_id,l_contr_period);
    FETCH c_pa_data INTO l_flag;
    CLOSE c_pa_data;

          pay_in_utils.set_location(g_debug,l_procedure, 60);

    /* If l_flag is 0 then archive else skip this org as its already there*/
    IF (l_flag = 0)
    THEN
          pay_in_utils.set_location(g_debug,l_procedure, 70);
     --Registered Name
     OPEN c_registered_name(l_org_id,l_effective_date);
     FETCH c_registered_name INTO l_reg_name,l_code,l_class,l_address;
     CLOSE c_registered_name;

     --Representative Name
     OPEN c_rep_name(l_org_id,l_effective_date);
     FETCH c_rep_name INTO l_org_rep_name,l_rep_person_id;
     CLOSE c_rep_name;

     --PF/ESI Org Name
     OPEN c_org_name(l_org_id,l_effective_date);
     FETCH c_org_name INTO l_org_name;
     CLOSE c_org_name;

          pay_in_utils.set_location(g_debug,l_procedure, 60);
  IF g_debug THEN
       pay_in_utils.trace('Registered Name  ',l_reg_name);
       pay_in_utils.trace('Representative Name        ',l_org_rep_name);
   END IF;

    IF p_context = 'ESI' THEN
      pay_in_utils.set_location(g_debug,l_procedure, 70);
      OPEN  c_rep_adr(l_rep_person_id,l_effective_date);
      FETCH c_rep_adr INTO l_rep_addr;
      CLOSE c_rep_adr;

      OPEN  c_rep_pos(l_rep_person_id,l_effective_date);
      FETCH c_rep_pos INTO l_rep_pos;
      CLOSE c_rep_pos;

      l_class := NULL;
    ELSE
      pay_in_utils.set_location(g_debug,l_procedure, 80);
      l_rep_pos := NULL;
      l_rep_addr:= NULL;
    END IF;

   SELECT DECODE(p_context,'PF',l_class,l_rep_addr) INTO l_context
     FROM dual;--case p_context when 'PF' then l_class else l_rep_addr end --PF CLass or ESI Org Rep Addr

     pay_action_information_api.create_action_information
                  (p_action_context_id              =>     l_act_id              --Payroll Action id
                  ,p_action_context_type            =>     'PA'
                  ,p_action_information_category    =>     l_act_inf_cat
                  ,p_tax_unit_id                    =>     null
                  ,p_jurisdiction_code              =>     null
                  ,p_source_id                      =>     null
                  ,p_source_text                    =>     null
                  ,p_tax_group                      =>     null
                  ,p_effective_date                 =>     l_effective_date       --Prepayment Effective Date
                  ,p_assignment_id                  =>     null
                  ,p_action_information1            =>     l_contr_period         --Contribution Period
                  ,p_action_information2            =>     l_org_id               --PF/ESI Org ID
                  ,p_action_information3            =>     l_reg_name             --Registered Name
                  ,p_action_information4            =>     l_org_rep_name         --Representative Name
                  ,p_action_information5            =>     l_address              --Address
                  ,p_action_information6            =>     l_code                 --Code
                  ,p_action_information7            =>     l_context
                  ,p_action_information8            =>     l_org_name             --PF/ESI Org Name
                  ,p_action_information9            =>     l_rep_pos              --ESI Org Rep Pos
                  ,p_action_information_id          =>     l_action_info_id       --OUT Parameters
                  ,p_object_version_number          =>	   l_ovn                  --OUT Parameters
                  );
    END IF;
   END LOOP;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
   EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;

END archive_payroll_data;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : ARCHIVE_PT_DATA                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : This procedure archives the data required for PT    --
--                  Form III                                            --
-- Parameters     :                                                     --
--             IN :      p_assignment_action_id   NUMBER                --
--                       p_payroll_action_id      NUMBER                --
--                       p_archive_action_id      NUMBER                --
--                       p_assignment_id          NUMBER                --
--                       p_payroll_date           DATE                  --
--                       p_prepayment_date        DATE                  --
--                                                                      --
--                                                                      --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 12-May-2005    abhjain    Created                              --
--------------------------------------------------------------------------
--
PROCEDURE archive_pt_data
    (
      p_assignment_action_id  IN  NUMBER
     ,p_payroll_action_id     IN  NUMBER
     ,p_archive_action_id     IN  NUMBER
     ,p_assignment_id         IN  NUMBER
     ,p_payroll_date          IN  DATE
     ,p_prepayment_date       IN  DATE
    )
IS

--  Cursor to find PT Organization State
  CURSOR c_pt_state(p_assignment_action_id NUMBER)
  IS
  SELECT DISTINCT pay_in_prof_tax_pkg.get_state(hoi.organization_id)   jurisdiction_code
    FROM hr_organization_units    hoi
        ,hr_soft_coding_keyflex   scf
        ,per_assignments_f    asg
        ,pay_assignment_actions   paa
   WHERE asg.assignment_id = paa.assignment_id
     AND paa.assignment_action_id = p_assignment_action_id
     AND asg.soft_coding_keyflex_id = scf.soft_coding_keyflex_id
     AND hoi.organization_id = scf.segment3
     AND (TO_CHAR(asg.effective_start_date, 'Month-YYYY') = TO_CHAR(p_payroll_date, 'Month-YYYY')
       OR TO_CHAR(asg.effective_end_date, 'Month-YYYY') = TO_CHAR(p_payroll_date, 'Month-YYYY')
       OR p_payroll_date BETWEEN asg.effective_start_date AND asg.effective_end_date);

--  Cursor to find PT Organization Id and Name
  CURSOR c_pt_org_id(p_assignment_action_id NUMBER
                    ,p_jur_code             VARCHAR2)
  IS/* Modified as per bug 4774108. Reduced share memory from 1,108,508 to 389,825.
  SELECT source_id
        ,name
    FROM ( */SELECT hoi.organization_id                                         source_id
                 ,hoi.name                                                      name
                 ,asg.effective_end_date
             FROM hr_organization_units    hoi
                 ,hr_soft_coding_keyflex   scf
                 ,per_assignments_f    asg
                 ,pay_assignment_actions   paa
            WHERE asg.assignment_id = paa.assignment_id
              AND paa.assignment_action_id = p_assignment_action_id
              AND asg.soft_coding_keyflex_id = scf.soft_coding_keyflex_id
              AND hoi.organization_id = scf.segment3
              AND (TO_CHAR(asg.effective_start_date, 'Month-YYYY') = TO_CHAR(p_payroll_date, 'Month-YYYY')
                OR TO_CHAR(asg.effective_end_date, 'Month-YYYY') = TO_CHAR(p_payroll_date, 'Month-YYYY')
                OR p_payroll_date BETWEEN asg.effective_start_date AND asg.effective_end_date)
              AND pay_in_prof_tax_pkg.get_state(hoi.organization_id) = p_jur_code
              ORDER BY asg.effective_end_date DESC;/*)
   WHERE ROWNUM = 1;*/

-- Cursor to find full name, Person Id
  CURSOR c_person_full_name(p_assignment_action_id NUMBER)
  IS
  SELECT hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)           Employee_Name
        ,pep.person_id           person_id
    FROM per_assignments_f   asg
        ,per_people_f        pep
        ,pay_assignment_actions  paa
   WHERE asg.person_id = pep.person_id
     AND asg.assignment_id = paa.assignment_id
     AND paa.assignment_action_id = p_assignment_action_id
     AND p_payroll_date BETWEEN pep.effective_start_date AND pep.effective_end_date
     AND p_payroll_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


--Cursors to find the Exemption Reason entered by the user in that payroll run

  --Find the element type id
  CURSOR c_element_type_id
  IS
  SELECT element_type_id
    FROM pay_element_types_f
   WHERE element_name ='Professional Tax Information'
     AND legislation_code = 'IN'
     AND p_payroll_date BETWEEN effective_start_date AND effective_end_date;

  --Find the input value id for Reason for Exemption, Organization, State
  CURSOR c_iv_id(p_element_type_id NUMBER
                ,p_name            VARCHAR2)
  IS
  SELECT input_value_id
    FROM pay_input_values_f
   WHERE element_type_id = p_element_type_id
     AND name = p_name
     AND p_payroll_date BETWEEN effective_start_date AND effective_end_date;

  --Find the run result id
  CURSOR c_run_result_id(p_element_type_id NUMBER)
  IS
  SELECT run_result_id
    FROM pay_run_results
   WHERE assignment_action_id = p_assignment_action_id
     AND element_type_id = p_element_type_id;

  --Find the actual Exemption Reason
  CURSOR c_exempt_reason(p_run_result_id NUMBER
                        ,p_state_iv_id   VARCHAR2
                        ,p_rem_iv_id     NUMBER
                        ,p_jur_code      VARCHAR2)
  IS
  SELECT prr2.result_value
    FROM pay_run_result_values prr1
        ,pay_run_result_values prr2
   WHERE prr1.run_result_id   = p_run_result_id
     AND prr1.input_value_id  = p_state_iv_id
     AND prr2.run_result_id   = prr1.run_result_id
     AND prr2.input_value_id  = p_rem_iv_id
     AND prr1.result_value    = p_jur_code;


   l_action_info_id           NUMBER;
   l_ovn                      NUMBER;
   pt_salary                  NUMBER;
   pt                         NUMBER;
   l_reason_for_exem          VARCHAR2(60);
   l_exempted_frm_pt          VARCHAR2(10);
   l_jur_code                 VARCHAR2(10);
   l_contrib_month            VARCHAR2(20);
   l_contrib_year             VARCHAR2(20);
   l_start_date               DATE;
   l_end_date                 DATE;
   l_full_name                per_people_f.full_name%TYPE;
   l_person_id                per_people_f.person_id%TYPE;
   l_source_id                hr_organization_units.organization_id%TYPE;
   l_pt_org_name              hr_organization_units.name%TYPE;
   l_element_type_id          pay_element_types_f.element_type_id%TYPE;
   l_state_iv_id              pay_input_values_f.input_value_id%TYPE;
   l_reason_iv_id             pay_input_values_f.input_value_id%TYPE;
   l_asg_id                   per_assignments_f.assignment_id%TYPE;
   l_message   VARCHAR2(255);
   l_procedure VARCHAR2(100);

-- Added as a part of bug fix 4774108.
   l_asg_end_date             DATE;
BEGIN

 l_procedure := g_package ||'archive_pt_data';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
       pay_in_utils.trace('Assignment Action id  ',p_assignment_action_id);
       pay_in_utils.trace('Payroll Action id  ',p_payroll_action_id);
       pay_in_utils.trace('Archive Action id  ',p_archive_action_id);
       pay_in_utils.trace('Assignment id  ',p_assignment_id);
       pay_in_utils.trace('Payroll Date  ',p_payroll_date);
       pay_in_utils.trace('Prepayment Date  ',p_prepayment_date);
   END IF;



   --For each PT State for that assignment in that payroll run
   FOR c_rec_state IN c_pt_state(p_assignment_action_id)
   LOOP
     pay_in_utils.set_location(g_debug,l_procedure, 20);

     l_jur_code  := c_rec_state.jurisdiction_code;

  IF g_debug THEN
       pay_in_utils.trace('Jurisdiction Code  ',l_jur_code);
   END IF;

/* Removed this as a part of bug fix 4774108
     FOR c_rec IN c_pt_org_id(p_assignment_action_id
                             ,l_jur_code)
     LOOP
       l_source_id := c_rec.source_id;
       hr_utility.set_location('PT-III Source Id:                  '||l_source_id, 12);
       l_pt_org_name := c_rec.name;
       hr_utility.set_location('PT-III Org Name:                   '||l_pt_org_name, 12);
     END LOOP;
*/
  -- Added as a part of bug fix 4774108.
     OPEN  c_pt_org_id(p_assignment_action_id,l_jur_code);
     FETCH c_pt_org_id INTO l_source_id,l_pt_org_name,l_asg_end_date;
     CLOSE c_pt_org_id;

     pay_in_utils.set_location(g_debug,l_procedure, 20);

     --Find the assignments's full name
     OPEN c_person_full_name(p_assignment_action_id);
     FETCH c_person_full_name INTO l_full_name, l_person_id;
     CLOSE c_person_full_name;

     IF g_debug THEN
       pay_in_utils.trace('Jurisdiction Code  ',l_jur_code);
     END IF;


     l_start_date := TRUNC(p_payroll_date, 'MM');
     l_end_date   := ADD_MONTHS(l_start_date, 1) - 1;

     IF g_debug THEN
       pay_in_utils.trace('PT-III l_start_date  ',l_start_date);
       pay_in_utils.trace('PT-III l_end_date  ',l_end_date);
     END IF;


     -- Populating the PL/SQL Tables with State and payroll action id

   pay_in_utils.set_location(g_debug,l_procedure, 30);

     g_cnt_pt := g_cnt_pt + 1;

     g_pt_org_id(g_cnt_pt)   := l_source_id;

     g_pt_act_id(g_cnt_pt)   := p_payroll_action_id;

     g_pt_jur_code(g_cnt_pt) := l_jur_code;


     IF g_debug THEN
       pay_in_utils.trace('PT-III g_pt_org_id  ',g_pt_org_id(g_cnt_pt));
       pay_in_utils.trace('PT-III  g_pt_org_id  ',g_pt_act_id(g_cnt_pt));
       pay_in_utils.trace('PT-III  g_pt_jur_code ',g_pt_jur_code(g_cnt_pt));
     END IF;

     --PT Salary
     pt_salary := pay_in_tax_utils.get_balance_value(
                            p_assignment_action_id => p_assignment_action_id
                           ,p_balance_name         => 'PT Actual Salary'
                           ,p_dimension_name       => '_ASG_STATE_PTD'
                           ,p_context_name         => 'JURISDICTION_CODE'
                           ,p_context_value        => l_jur_code
                            );
   pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF g_debug THEN
       pay_in_utils.trace('PT Salary ',pt_salary);
   END IF;

     --Professional Tax
     pt := pay_in_tax_utils.get_balance_value(
                            p_assignment_action_id => p_assignment_action_id
                           ,p_balance_name         => 'Professional Tax'
                           ,p_dimension_name       => '_ASG_STATE_PTD'
                           ,p_context_name         => 'JURISDICTION_CODE'
                           ,p_context_value        => l_jur_code
                            );
   pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF g_debug THEN
       pay_in_utils.trace('PT  ',pt);
   END IF;

     l_asg_id := p_assignment_id;
     l_reason_for_exem := NULL;

     OPEN  c_element_type_id;
     FETCH c_element_type_id INTO l_element_type_id;
     CLOSE c_element_type_id;



     OPEN  c_iv_id(l_element_type_id, 'State');
     FETCH c_iv_id INTO l_state_iv_id;
     CLOSE c_iv_id;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

     OPEN  c_iv_id(l_element_type_id, 'Exemption Reason');
     FETCH c_iv_id INTO l_reason_iv_id;
     CLOSE c_iv_id;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

     FOR c_rec IN c_run_result_id(l_element_type_id)
     LOOP
         pay_in_utils.set_location(g_debug,l_procedure, 20);
         OPEN  c_exempt_reason(c_rec.run_result_id
                              ,l_state_iv_id
                              ,l_reason_iv_id
                              ,l_jur_code);
        FETCH c_exempt_reason INTO l_reason_for_exem;
        CLOSE c_exempt_reason;

     END LOOP;

   pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF g_debug THEN
       pay_in_utils.trace('PT Exemption Reason  ',l_reason_for_exem);
   END IF;

     IF (l_reason_for_exem IS NOT NULL) THEN
        l_exempted_frm_pt := 'Yes';
     ELSE
        l_exempted_frm_pt := 'No';
     END IF;

     l_contrib_month := TO_CHAR(ADD_MONTHS(p_payroll_date, -3), 'MM');
     l_contrib_year := TO_CHAR(pay_in_tax_utils.get_financial_year_start(p_payroll_date), 'YYYY')||'-'|| TO_CHAR(pay_in_tax_utils.get_financial_year_end(p_payroll_date), 'YYYY');

     pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_archive_action_id          --Archive Action id
                  ,p_action_context_type            =>     'AAP'
                  ,p_action_information_category    =>     'IN_PT_ASG'
                  ,p_tax_unit_id                    =>     null
                  ,p_jurisdiction_code              =>     l_jur_code                   --Jur Code (PT Org State)
                  ,p_source_id                      =>     l_source_id                  --Source Id (PT Org Id)
                  ,p_source_text                    =>     null
                  ,p_tax_group                      =>     null
                  ,p_effective_date                 =>     p_prepayment_date            --Prepayment Effective Date
                  ,p_assignment_id                  =>     l_asg_id                     --Asg Id
                  ,p_action_information1            =>     l_contrib_year               --Financial Year
                  ,p_action_information2            =>     l_contrib_month              --Month of the Financial Year
                  ,p_action_information3            =>     l_full_name                  --Full Name
                  ,p_action_information4            =>     pt_salary                    --PT Salary  _ASG_STATE_PTD
                  ,p_action_information5            =>     pt                           --PT
                  ,p_action_information6            =>     l_exempted_frm_pt            --Exempted Flag
                  ,p_action_information7            =>     l_reason_for_exem            --Exemption Reason
                  ,p_action_information8            =>     to_char(p_payroll_date, 'DD-MM-YYYY') --Payroll Date
                  ,p_action_information9            =>     l_pt_org_name                --Local PT Office
                  ,p_action_information10           =>     null
                  ,p_action_information11           =>     null
                  ,p_action_information12           =>     null
                  ,p_action_information13           =>     null
                  ,p_action_information14           =>     null
                  ,p_action_information15           =>     null
                  ,p_action_information16           =>     null
                  ,p_action_information17           =>     null
                  ,p_action_information18           =>     null
                  ,p_action_information19           =>     null
                  ,p_action_information20           =>     null
                  ,p_action_information21           =>     null
                  ,p_action_information22           =>     null
                  ,p_action_information23           =>     null
                  ,p_action_information24           =>     null
                  ,p_action_information25           =>     null
                  ,p_action_information26           =>     null
                  ,p_action_information27           =>     null
                  ,p_action_information28           =>     null
                  ,p_action_information29           =>     null
                  ,p_action_information30           =>     null
                  ,p_action_information_id          =>     l_action_info_id             --OUT Parameters
                  ,p_object_version_number          =>     l_ovn                        --OUT Parameters
                  );

   END LOOP;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
   EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;

END archive_pt_data;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ARCHIVE_PT_PAYROLL_DATA                             --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure archives the data required for PT form-
--                  III data at PA Level                                --
-- Parameters     :                                                     --
--             IN :                                                     --
--                                                                      --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 12-May-2005    abhjain   Created                               --
-- 115.1 25-Sep-2007    rsaharay  Modified c_rep_pos                    --
-------------------------------------------------------------------------
PROCEDURE archive_pt_payroll_data
IS
 --Cursor to find the effective date
 CURSOR c_effective_date(p_payroll_action_id NUMBER)
 IS
     SELECT effective_date
       FROM pay_payroll_actions
      WHERE payroll_action_id = p_payroll_action_id;

--Cursor to find the PT Organization Name
Cursor c_org_name(p_organization_id NUMBER
                 ,p_effective_date  DATE)
IS
     SELECT hou.name
       FROM hr_organization_units hou
      WHERE hou.organization_id = p_organization_id
        AND p_effective_date BETWEEN hou.date_from AND NVL(date_to, TO_DATE('31-12-4712', 'DD-MM-YYYY'));

 --Cursor to find the Registered name, Code of the PF/ESI Organization , Classification and its address
CURSOR c_registered_name(p_organization_id NUMBER
                        ,p_effective_date  DATE)
IS
     SELECT hou.name
           ,hoi.org_information1
           ,hoi.org_information3
           ,SUBSTR(
            hla.address_line_1||
            DECODE(hla.address_line_2, null, null, ',' || hla.address_line_2)||
            DECODE(hla.address_line_3, null, null, ',' || hla.address_line_3)||
            DECODE(hla.loc_information14, null, null, ',' || hla.loc_information14)||
            DECODE(hla.loc_information15, null, null, ',' || hla.loc_information15)||
            DECODE(hr_general.decode_lookup('IN_STATES', hla.loc_information16)
                 , null, null, ',' || hr_general.decode_lookup('IN_STATES', hla.loc_information16))||
            DECODE(hla.postal_code, null, null, ','||hla.postal_code)
            ,1,240)
       FROM hr_organization_information hoi
           ,hr_organization_units hou
           ,hr_organization_units hou1
           ,hr_locations_all hla
      WHERE hoi.organization_id = p_organization_id
        AND hoi.org_information_context = 'PER_IN_PROF_TAX_DF'
        AND hou.organization_id =  hoi.org_information2
        AND hla.location_id = hou1.location_id
        AND hou.organization_id = hou1.organization_id
        AND p_effective_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712', 'DD-MM-YYYY'));

 --Cursor to find the PF/ESI Representative Name
CURSOR c_rep_name(p_pf_org_id      NUMBER
                  ,p_effective_date DATE)
 IS
     SELECT DISTINCT hr_in_utility.per_in_full_name(peap.first_name,peap.middle_names,peap.last_name,peap.title)      rep_name
           ,peap.person_id               person_id
       FROM hr_organization_information  hoi
           ,per_people_f             peap
      WHERE hoi.organization_id = p_pf_org_id
        AND hoi.org_information_context = 'PER_IN_PROF_TAX_REP_DF'
        AND peap.person_id = hoi.org_information1
        AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi.org_information2)
                                 AND NVL(fnd_date.canonical_to_date(hoi.org_information3)
                                      , TO_DATE('31-12-4712', 'DD-MM-YYYY'));

 --Cursor to find the Position of PT Rep
CURSOR c_rep_pos(p_person_id      NUMBER
                ,p_effective_date DATE)
 IS
 SELECT nvl(pos.name,job.name) name
 FROM   per_positions     pos
       ,per_assignments_f asg
       ,per_jobs          job
 WHERE  asg.position_id=pos.position_id(+)
 AND    asg.job_id=job.job_id(+)
 AND    asg.person_id = p_person_id
 AND    asg.primary_flag = 'Y'
 AND    p_effective_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
 AND    p_effective_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
 AND    p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


   l_count                NUMBER;
   l_act_id               NUMBER;
   l_action_info_id       NUMBER;
   l_ovn                  NUMBER;
   l_jur_code             VARCHAR2(10);
   l_contr_month          VARCHAR2(10);
   l_bsrtc_no             VARCHAR2(50);
   l_address              VARCHAR2(240);
   l_contr_year           VARCHAR2(10);
   l_rep_pos              PER_ALL_POSITIONS.NAME%TYPE;
   l_act_inf_cat          VARCHAR2(30);
   l_effective_date       DATE;
   l_reg_name             hr_organization_units.name%TYPE;
   l_reg_no               hr_organization_information.org_information1%TYPE;
   l_org_name             hr_organization_units.name%TYPE;
   l_org_rep_name         per_people_f.full_name%TYPE;
   l_rep_person_id        per_people_f.person_id%TYPE;
   l_org_id               hr_organization_units.organization_id%TYPE;
   l_source_id            hr_organization_units.organization_id%TYPE;
   l_message   VARCHAR2(255);
   l_procedure VARCHAR2(100);


BEGIN

 l_count := 0;
 l_count := g_cnt_pt;
 l_act_inf_cat := 'IN_PT_PAY';


 l_procedure := g_package ||'archive_pt_payroll_data';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


 FOR i IN 1..l_count LOOP
   pay_in_utils.set_location(g_debug,l_procedure, 20);

   -- Getting Action Id, Organization Id, Jurisdiction Code
   l_act_id := g_pt_act_id(i);
   l_org_id := g_pt_org_id(i);
   l_jur_code := g_pt_jur_code(i);
   l_source_id := l_org_id;

   IF g_debug THEN
       pay_in_utils.trace('PT-III Payroll_Level Org ID ',l_org_id);
   END IF;



   --Effective Date
   OPEN c_effective_date(l_act_id);
   FETCH c_effective_date INTO l_effective_date;
   CLOSE c_effective_date;

      pay_in_utils.set_location(g_debug,l_procedure, 30);


   --Contribution Period
   l_contr_year := TO_CHAR(pay_in_tax_utils.get_financial_year_start(l_effective_date), 'YYYY')||'-'||to_char(pay_in_tax_utils.get_financial_year_end(l_effective_date), 'YYYY');
   l_contr_month := TO_CHAR(ADD_MONTHS(l_effective_date, -3), 'MM');

   --Registered Name
   OPEN c_registered_name(l_org_id
                         ,l_effective_date);
   FETCH c_registered_name INTO l_reg_name
                               ,l_reg_no
                               ,l_bsrtc_no
                               ,l_address;
   CLOSE c_registered_name;

   pay_in_utils.set_location(g_debug,l_procedure, 40);

   --PT Org Name
   OPEN c_org_name(l_org_id
                  ,l_effective_date);
   FETCH c_org_name INTO l_org_name;
   CLOSE c_org_name;


   --Representative Name
   OPEN c_rep_name(l_org_id
                  ,l_effective_date);
   FETCH c_rep_name INTO l_org_rep_name
                       , l_rep_person_id;
   CLOSE c_rep_name;

   pay_in_utils.set_location(g_debug,l_procedure, 50);

   -- Representative Designation
   OPEN  c_rep_pos(l_rep_person_id
                  ,l_effective_date);
   FETCH c_rep_pos INTO l_rep_pos;
   CLOSE c_rep_pos;

   pay_in_utils.set_location(g_debug,l_procedure, 60);

   pay_action_information_api.create_action_information
                (p_action_context_id              =>     l_act_id              --Payroll Action id
                ,p_action_context_type            =>     'PA'
                ,p_action_information_category    =>     l_act_inf_cat
                ,p_tax_unit_id                    =>     null
                ,p_jurisdiction_code              =>     l_jur_code
                ,p_source_id                      =>     l_source_id
                ,p_source_text                    =>     null
                ,p_tax_group                      =>     null
                ,p_effective_date                 =>     l_effective_date       --Prepayment Effective Date
                ,p_assignment_id                  =>     null
                ,p_action_information1            =>     l_contr_year           --Financial Year
                ,p_action_information2            =>     l_contr_month          --Month of the Financial Year
                ,p_action_information3            =>     l_bsrtc_no             --BSRTC No
                ,p_action_information4            =>     l_reg_name             --Registered Name
                ,p_action_information5            =>     l_org_rep_name         --Representative Name
                ,p_action_information6            =>     l_address              --Address
                ,p_action_information7            =>     l_reg_no               --Registration No
                ,p_action_information8            =>     l_org_name             --PT Org Name
                ,p_action_information9            =>     l_rep_pos              --PT Org Rep Pos
                ,p_action_information_id          =>     l_action_info_id       --OUT Parameters
                ,p_object_version_number          =>     l_ovn                  --OUT Parameters
                );
 END LOOP;

   IF g_debug THEN
       pay_in_utils.trace('Payroll Action id                   ',l_act_id);
       pay_in_utils.trace('Action Information Category         ',l_act_inf_cat);
       pay_in_utils.trace('Jurisdiction Code                   ',l_jur_code);
       pay_in_utils.trace('Source ID                           ',l_source_id);
       pay_in_utils.trace('Effective Date                      ',l_effective_date);
       pay_in_utils.trace('Contribution year                   ',l_contr_year);
       pay_in_utils.trace('Contribution Month                  ',l_contr_month);
       pay_in_utils.trace('bsrtc number                        ',l_bsrtc_no);
       pay_in_utils.trace('Registered name                     ',l_reg_name);
       pay_in_utils.trace('Representative Name                 ',l_org_rep_name);
       pay_in_utils.trace('Address                             ',l_address);
       pay_in_utils.trace('Registration No                     ',l_reg_no);
       pay_in_utils.trace('PT Org Name                         ',l_org_name);
       pay_in_utils.trace('PT Org Rep Pos                      ',l_rep_pos);
       pay_in_utils.trace('Action information id               ',l_action_info_id);
       pay_in_utils.trace('Next Period Date                    ',l_ovn);

   END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 70);
 EXCEPTION
  WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 80);
       pay_in_utils.trace(l_message,l_procedure);

    RAISE;

END archive_pt_payroll_data;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CODE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to call the internal procedures to        --
  --                  actually the archive the data. The procedure        --
  --                  called are                                          --
  --                    pay_apac_payslip_archive.archive_user_balances    --
  --                    pay_apac_payslip_archive.archive_user_elements    --
  --                    archive_stat_balances                             --
  --                    archive_stat_elements                             --
  --                    archive_employee_details                          --
  --                    archive_accrual_details                           --
  --                    archive_absences                                  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id       NUMBER                 --
  --                  p_effective_date             DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 04-NOV-2004    bramajey   Initial Version                      --
  -- 115.1 11-JAN-2005    aaagarwa   Added Code for archiving Form 3A	  --
  --				     and 6A data			  --
  -- 115.2 1-MAR-2005    aaagarwa    Added Code for archiving Form 3A	  --
    --				     and 6A data at Pyaroll level         --
  --------------------------------------------------------------------------
  --

   PROCEDURE archive_code (
                           p_assignment_action_id  IN NUMBER
                          ,p_effective_date        IN DATE
                         )
  IS
  --

    CURSOR get_bal_init_aa(p_init_arch_action_id IN NUMBER)
    IS
    SELECT paa_arch.assignment_action_id arch_assignment_action_id
          ,paa_arch.payroll_action_id    arch_payroll_action_id
          ,paa_init.assignment_action_id init_assignment_action_id
          ,ppa_init.payroll_action_id init_payroll_action_id
          ,ppa_init.effective_date    init_effective_date
          ,paa_arch.assignment_id
      FROM pay_assignment_actions paa_arch
          ,pay_action_interlocks intk
          ,pay_assignment_actions paa_init
          ,pay_payroll_actions ppa_init
    WHERE paa_arch.assignment_action_id = p_init_arch_action_id
      AND intk.locking_action_id = paa_arch.assignment_action_id
      AND intk.locked_action_id = paa_init.assignment_action_id
      AND paa_init.payroll_action_id = ppa_init.payroll_action_id
      AND ppa_init.action_type ='I';

    -- Cursor to select all the locked prepayment and payrolls by the archive
    -- assignment action. The records are ordered descending as we only need
    -- latest payroll run in the prepayment.

    CURSOR get_payslip_aa(p_master_aa_id NUMBER)
    IS
    SELECT    /*+ ORDERED */
           paa_arch_chd.assignment_action_id   chld_arc_assignment_action_id
          ,paa_arch_chd.payroll_action_id      arc_payroll_action_id
          ,paa_pre.assignment_action_id        pre_assignment_action_id
          ,paa_run.assignment_action_id        run_assignment_action_id
          ,paa_run.payroll_action_id           run_payroll_action_id
          ,ppa_pre.effective_date              pre_effective_date
          ,paa_arch_chd.assignment_id
          ,ppa_run.effective_date              run_effective_date
          ,ppa_run.date_earned                 run_date_earned
          ,ptp.end_date                        period_end_date
          ,ptp.time_period_id
          ,ptp.start_date                      period_start_date
          ,ptp.regular_payment_date
    FROM   pay_assignment_actions              paa_arch_mst
          ,pay_assignment_actions              paa_arch_chd
          ,pay_action_interlocks               pai_pre
          ,pay_assignment_actions              paa_pre
          ,pay_payroll_actions                 ppa_pre
          ,per_business_groups                 pbg
          ,pay_action_interlocks               pai_run
          ,pay_assignment_actions              paa_run
          ,pay_payroll_actions                 ppa_run
          ,per_time_periods                    ptp
    WHERE  paa_arch_mst.assignment_action_id = p_master_aa_id
    AND    paa_arch_chd.source_action_id     = paa_arch_mst.assignment_action_id
    AND    paa_arch_chd.payroll_action_id    = paa_arch_mst.payroll_action_id
    AND    ppa_pre.business_group_id         = pbg.business_group_id
    AND    pbg.business_group_id             = ppa_run.business_group_id
    AND    ppa_pre.payroll_id                = ppa_run.payroll_id
    AND    paa_arch_chd.assignment_id        = paa_arch_mst.assignment_id
    AND    pai_pre.locking_action_id         = paa_arch_mst.assignment_action_id
    AND    pai_pre.locked_action_id          = paa_pre.assignment_action_id
    AND    pai_run.locking_action_id         = paa_arch_chd.assignment_action_id
    AND    pai_run.locked_action_id          = paa_run.assignment_action_id
/* Asg  start */
    and    paa_run.assignment_id             = paa_arch_chd.assignment_id
    and    paa_pre.assignment_id             = paa_arch_mst.assignment_id
/* Asg end */
    AND    ppa_pre.payroll_action_id         = paa_pre.payroll_action_id
    AND    ppa_pre.action_type              IN ('P','U')
    AND    ppa_run.payroll_action_id         = paa_run.payroll_action_id
    AND    ppa_run.action_type              IN ('R','Q')
    AND    ptp.payroll_id                    = ppa_run.payroll_id
    AND    ppa_run.date_earned         BETWEEN ptp.start_date
                                       AND     ptp.end_date
     -- Get the highest in sequence for this payslip
     AND paa_run.action_sequence             =
             (
               SELECT MAX(paa_run2.action_sequence)
               FROM  pay_assignment_actions paa_run2
                    ,pay_action_interlocks  pai_run2
               WHERE pai_run2.locking_action_id = paa_arch_chd.assignment_action_id
               AND   pai_run2.locked_action_id  = paa_run2.assignment_action_id
             );

    --
    /*Cursor for selecting assignment actions in case Single pre payment has been done for multi payroll runs*/
    CURSOR c_multi_rec_count(p_prepayment_lcking_id NUMBER
                            )
    IS
     select count(paa.assignment_action_id)
     from pay_payroll_actions ppa
         ,pay_assignment_actions paa
         ,pay_action_interlocks pal
     where pal.locking_action_id=p_prepayment_lcking_id
     and   paa.assignment_action_id=pal.locked_action_id
     and   ppa.payroll_action_id=paa.payroll_action_id
     and   ppa.action_type in ('Q','R')
     and   ppa.action_status='C'
     and   paa.action_status='C'
     and   paa.source_action_id is not null;

    CURSOR c_multi_records(p_prepayment_lcking_id NUMBER
                          ,p_date_earned          DATE
                          ,i                      NUMBER
                          )
    IS
     select paa.assignment_action_id
           ,ppa.date_earned
     from pay_payroll_actions ppa
         ,pay_assignment_actions paa
        ,pay_action_interlocks pal
     where pal.locking_action_id=p_prepayment_lcking_id
     and   paa.assignment_action_id=pal.locked_action_id
     and   ppa.payroll_action_id=paa.payroll_action_id
     and   ppa.action_type in ('Q','R')
     and   ppa.action_status='C'
     and   paa.action_status='C'
     and   paa.source_action_id is not null
     and   to_char(ppa.date_earned,'MM-YYYY')=to_char(add_months(p_date_earned,-i),'MM-YYYY')
     order by paa.assignment_action_id desc;

     CURSOR get_rvsl_records(c_assignment_action_id number
                         ,c_assignment_id   NUMBER
			 ,c_payroll_date date)
     IS
     SELECT paa.assignment_action_id
		FROM pay_payroll_actions ppa,pay_assignment_actions paa,
		pay_action_interlocks pai1,pay_action_interlocks pai2

		WHERE ppa.PAYROLL_ACTION_ID = paa.PAYROLL_ACTION_ID
		AND paa.ASSIGNMENT_ID = c_assignment_id
		AND paa.payroll_action_id = ppa.payroll_action_id
		AND paa.action_status = 'C'
		AND ACTION_TYPE = 'V'
		AND ppa.action_status = 'C'
		AND pai1.LOCKING_ACTION_ID = c_assignment_action_id
		AND pai2.LOCKING_ACTION_ID = paa.assignment_action_id
		AND pai1.locked_action_id = pai2.locked_action_id
		AND TO_CHAR(ppa.date_earned ,'MM-YYYY') = to_char(c_payroll_date,'MM-YYYY');


     /* Bug No:5593925
     This cursor returns actual termination date if it falls in the pay period */

     CURSOR csr_payment_date(p_assignment_action_id  NUMBER)
     IS
     SELECT pps.actual_termination_date
     FROM   pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_time_periods ptp,
            per_all_assignments_f paf,
            per_periods_of_service pps
     WHERE  paa.assignment_action_id = p_assignment_action_id
     AND    ppa.payroll_action_id = paa.payroll_action_id
     AND    ptp.payroll_id = ppa.payroll_id
     AND    paf.assignment_id = paa.assignment_id
     AND    pps.period_of_service_id = paf.period_of_service_id
     AND    ppa.date_earned between ptp.start_date AND ptp.end_date
     AND    pps.actual_termination_date between ptp.start_date AND ptp.end_date;



    l_procedure                       VARCHAR2(100);
    l_asg_id                          NUMBER;
    l_date                            DATE;
    l_count                           NUMBER;
    l_init_exists                     NUMBER;
    l_message                         VARCHAR2(255);
    l_reversal_asg_action_id	      NUMBER;
    l_payment_date                    DATE   :=NULL;

  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure := g_package || '.archive_code';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF g_debug THEN

       pay_in_utils.trace('Assignment Action id ',p_assignment_action_id);
       pay_in_utils.trace('Effective Date       ',p_effective_date);

   END IF;


    g_cnt_pf := 0;
    g_cnt_esi := 0;
    g_cnt_pt := 0;

    l_init_exists := 0;
    -- use cursor suggested by core
    FOR csr_init_rec IN get_bal_init_aa(p_assignment_action_id)
    LOOP
       pay_in_utils.set_location(g_debug,l_procedure, 30);

 IF g_debug THEN

       pay_in_utils.trace('p_assignment_action_id      ',csr_init_rec.init_assignment_action_id);
       pay_in_utils.trace('p_archive_action_id         ',csr_init_rec.arch_assignment_action_id);
       pay_in_utils.trace('p_assignment_id             ',csr_init_rec.assignment_id);
       pay_in_utils.trace('p_payroll_date              ',csr_init_rec.init_effective_date);
       pay_in_utils.trace('p_payroll_action_id         ',csr_init_rec.arch_payroll_action_id);
       pay_in_utils.trace('p_run_payroll_action_id     ',csr_init_rec.init_payroll_action_id );
   END IF;

	archive_form_data(  p_assignment_action_id => csr_init_rec.init_assignment_action_id
                          ,p_archive_action_id     => csr_init_rec.arch_assignment_action_id
                          ,p_assignment_id         => csr_init_rec.assignment_id
                          ,p_payroll_date          => csr_init_rec.init_effective_date
                          ,p_prepayment_date       => csr_init_rec.init_effective_date
                          ,p_payroll_action_id     => csr_init_rec.arch_payroll_action_id
                          ,p_run_payroll_action_id => csr_init_rec.init_payroll_action_id
                        );

       pay_in_utils.set_location(g_debug,l_procedure, 40);

       archive_esi_data( p_assignment_action_id => csr_init_rec.init_assignment_action_id
                        ,p_archive_action_id    => csr_init_rec.arch_assignment_action_id
                        ,p_assignment_id        => csr_init_rec.assignment_id
                        ,p_payroll_date         => csr_init_rec.init_effective_date
                        ,p_prepayment_date      => csr_init_rec.init_effective_date
                        ,p_payroll_action_id    => csr_init_rec.arch_payroll_action_id
                       );

    pay_in_utils.set_location(g_debug,l_procedure, 50);

       archive_pt_data( p_assignment_action_id => csr_init_rec.init_assignment_action_id
                       ,p_archive_action_id    => csr_init_rec.arch_assignment_action_id
                       ,p_assignment_id        => csr_init_rec.assignment_id
                       ,p_payroll_date         => csr_init_rec.init_effective_date
                       ,p_prepayment_date      => csr_init_rec.init_effective_date
                       ,p_payroll_action_id    => csr_init_rec.arch_payroll_action_id
                        );
   pay_in_utils.set_location(g_debug,l_procedure, 60);

      archive_form24q_balances
      (
        p_assignment_action_id       => csr_init_rec.init_assignment_action_id
       ,p_assignment_id              => csr_init_rec.assignment_id
       ,p_date_earned                => csr_init_rec.init_effective_date
       ,p_effective_date             => csr_init_rec.init_effective_date
       ,p_assact_id                  => csr_init_rec.arch_assignment_action_id
       ,p_payroll_action_id          => csr_init_rec.arch_payroll_action_id
       ,p_run_payroll_action_id      => csr_init_rec.init_payroll_action_id
       ,p_pre_assact_id              => csr_init_rec.init_assignment_action_id
      );
     pay_in_utils.set_location(g_debug,l_procedure, 70);

       l_init_exists := 1;
    END LOOP;



     pay_in_utils.set_location(g_debug,l_procedure, 80);

  IF l_init_exists = 0 THEN
     pay_in_utils.set_location(g_debug,l_procedure, 90);
    -- Create Child Assignment Actions
    pay_core_payslip_utils.generate_child_actions(p_assignment_action_id
                                                   ,p_effective_date);

    FOR csr_rec IN get_payslip_aa(p_assignment_action_id)
    LOOP
    --
      pay_in_utils.set_location(g_debug,l_procedure, 100);
      -- Added for bug 5593925
      open csr_payment_date(csr_rec.run_assignment_action_id);
      fetch csr_payment_date into l_payment_date;
      if csr_payment_date%NOTFOUND then
         l_payment_date := csr_rec.regular_payment_date;
      end if;
      close csr_payment_date;

  IF g_debug THEN
       pay_in_utils.trace('Pre assignment_action_id        ',csr_rec.pre_assignment_action_id);
       pay_in_utils.trace('Run Date Earned                 ',csr_rec.run_date_earned);
       pay_in_utils.trace('Child assignment_action_id      ',csr_rec.chld_arc_assignment_action_id);
       pay_in_utils.trace('Assignment id                   ',csr_rec.assignment_id);
       pay_in_utils.trace('Pre Effective Date              ',csr_rec.pre_effective_date);
       pay_in_utils.trace('Arc payroll action_id           ',csr_rec.arc_payroll_action_id);
       pay_in_utils.trace('Run Payroll action_id           ',csr_rec.run_payroll_action_id);
   END IF;

      OPEN c_multi_rec_count(csr_rec.pre_assignment_action_id);
      FETCH c_multi_rec_count INTO l_count;
      CLOSE c_multi_rec_count;
      FOR i IN 0..l_count
      LOOP
         pay_in_utils.set_location(g_debug,l_procedure, 110);
          l_asg_id:=NULL;
          l_date:=NULL;
          OPEN c_multi_records(csr_rec.pre_assignment_action_id,csr_rec.run_date_earned,i);
          FETCH c_multi_records INTO l_asg_id,l_date;
          CLOSE c_multi_records;

	  OPEN get_rvsl_records(csr_rec.chld_arc_assignment_action_id,csr_rec.assignment_id,csr_rec.run_date_earned);
	  FETCH get_rvsl_records INTO l_reversal_asg_action_id;
	  CLOSE get_rvsl_records;

          IF (l_asg_id IS NOT NULL)AND(l_date IS NOT NULL) THEN
             pay_in_utils.set_location(g_debug,l_procedure, 120);
             archive_form_data(
                p_assignment_action_id => nvl(l_reversal_asg_action_id,l_asg_id)
               ,p_archive_action_id    => csr_rec.chld_arc_assignment_action_id
               ,p_assignment_id        => csr_rec.assignment_id
               ,p_payroll_date         => l_date
               ,p_prepayment_date      => csr_rec.pre_effective_date
               ,p_payroll_action_id    => csr_rec.arc_payroll_action_id
               ,p_run_payroll_action_id => csr_rec.run_payroll_action_id
       );




  IF g_debug THEN
       pay_in_utils.trace('l_date      ',l_date);
   END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 130);

            archive_esi_data(
                        p_assignment_action_id =>nvl(l_reversal_asg_action_id,l_asg_id)
                       ,p_archive_action_id    =>csr_rec.chld_arc_assignment_action_id
                       ,p_assignment_id        =>csr_rec.assignment_id
                       ,p_payroll_date         =>l_date
                       ,p_prepayment_date      =>csr_rec.pre_effective_date
                       ,p_payroll_action_id    =>csr_rec.arc_payroll_action_id
                       );
   pay_in_utils.set_location(g_debug,l_procedure, 140);

             archive_pt_data(
                        p_assignment_action_id =>nvl(l_reversal_asg_action_id,l_asg_id)
                       ,p_archive_action_id    =>csr_rec.chld_arc_assignment_action_id
                       ,p_assignment_id        =>csr_rec.assignment_id
                       ,p_payroll_date         =>l_date
                       ,p_prepayment_date      =>csr_rec.pre_effective_date
                       ,p_payroll_action_id    =>csr_rec.arc_payroll_action_id
                       );
          ELSE
              EXIT;
          END IF;
      END LOOP;
   pay_in_utils.set_location(g_debug,l_procedure, 150);
      --
      -- Call to procedure to archive User Configurable Balances
      --

      pay_apac_payslip_archive.archive_user_balances
      (
        p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
       ,p_run_assignment_action_id   => csr_rec.run_assignment_action_id        -- payroll assignment action id
       ,p_pre_effective_date         => csr_rec.pre_effective_date              -- prepayment effecive date
      );

   pay_in_utils.set_location(g_debug,l_procedure, 160);
      --
      -- Call to procedure to archive User Configurable Elements
      --

      pay_apac_payslip_archive.archive_user_elements
      (
        p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action
       ,p_pre_assignment_action_id   => csr_rec.pre_assignment_action_id        -- prepayment assignment action id
       ,p_latest_run_assact_id       => csr_rec.run_assignment_action_id        -- payroll assignment action id
       ,p_pre_effective_date         => csr_rec.pre_effective_date              -- prepayment effective date
      );

   pay_in_utils.set_location(g_debug,l_procedure, 170);
      --
      -- Call to procedure to archive Statutory Elements
      --

      archive_stat_elements
      (
        p_assignment_action_id       => csr_rec.pre_assignment_action_id        -- prepayment assignment action id
       ,p_effective_date             => csr_rec.pre_effective_date              -- prepayment effective date
       ,p_assact_id                  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
      );

   pay_in_utils.set_location(g_debug,l_procedure, 180);
      --
      -- Call to procedure to archive Statutory Balances
      --

      archive_stat_balances
      (
        p_assignment_action_id       => csr_rec.run_assignment_action_id        -- payroll assignment action
       ,p_assignment_id              => csr_rec.assignment_id                   -- assignment id
       ,p_date_earned                => csr_rec.run_date_earned                 -- payroll date earned
       ,p_effective_date             => csr_rec.pre_effective_date              -- prepayments effective date
       ,p_assact_id                  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
      );

   pay_in_utils.set_location(g_debug,l_procedure, 190);
      --
      -- Call to procedure to archive Employee Details
      --

      archive_employee_details
      (
        p_payroll_action_id          => csr_rec.arc_payroll_action_id           -- archive payroll action id
       ,p_assactid                   => csr_rec.chld_arc_assignment_action_id   -- archive action id
       ,p_pay_assignment_action_id   => csr_rec.run_assignment_action_id        -- payroll run action id
       ,p_assignment_id              => csr_rec.assignment_id                   -- assignment_id
       ,p_curr_pymt_ass_act_id       => csr_rec.pre_assignment_action_id        -- prepayment assignment_action_id
       ,p_date_earned                => csr_rec.run_date_earned                 -- payroll date_earned
       ,p_latest_period_payment_date => l_payment_date                          -- latest payment date
       ,p_run_effective_date         => csr_rec.run_effective_date              -- run effective Date
       ,p_time_period_id             => csr_rec.time_period_id                  -- time_period_id from per_time_periods
       ,p_pre_effective_date         => csr_rec.pre_effective_date              -- prepayment effective date
      );
   pay_in_utils.set_location(g_debug,l_procedure, 200);

      --
      -- Call to procedure to archive accrual details
      --

      archive_accrual_details
      (
        p_payroll_action_id          => csr_rec.run_payroll_action_id           -- latest payroll action id
       ,p_time_period_id             => csr_rec.time_period_id                  -- latest period time period id
       ,p_assignment_id              => csr_rec.assignment_id                   -- assignment id
       ,p_date_earned                => csr_rec.run_date_earned                 -- latest payroll date earned
       ,p_effective_date             => csr_rec.pre_effective_date              -- prepayment effective date
       ,p_assact_id                  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
       ,p_assignment_action_id       => csr_rec.run_assignment_action_id        -- payroll run action id
       ,p_period_end_date            => csr_rec.period_end_date                 -- latest period end date
       ,p_period_start_date          => csr_rec.period_start_date               -- latest period start date
      );

   pay_in_utils.set_location(g_debug,l_procedure, 210);
      --
      -- Call to procedure to archive absences
      --

      archive_absences
      (
        p_arch_act_id                 => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
       ,p_assg_act_id                 => csr_rec.run_assignment_action_id        -- payroll run action id
       ,p_pre_effective_date          => csr_rec.pre_effective_date              -- prepayment effective date
      );
   pay_in_utils.set_location(g_debug,l_procedure, 220);

      --
      -- Call to procedure to archive form24 tax Balances
      --
   archive_form24q_balances
      (
        p_assignment_action_id       => csr_rec.run_assignment_action_id     -- payroll assignment action
       ,p_assignment_id              => csr_rec.assignment_id                   -- assignment id
       ,p_date_earned                => csr_rec.run_date_earned               -- payroll date earned
       ,p_effective_date             =>csr_rec.run_effective_date              -- pre effective date
       ,p_assact_id                  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
       ,p_payroll_action_id          => csr_rec.arc_payroll_action_id
       ,p_run_payroll_action_id      =>csr_rec.run_payroll_action_id
       ,p_pre_assact_id              => csr_rec.pre_assignment_action_id
      );
      pay_in_utils.set_location(g_debug,l_procedure, 230);
     --
    END LOOP;
  END IF;
    archive_payroll_data('PF');
    pay_in_utils.set_location(g_debug,l_procedure, 240);

    archive_payroll_data('ESI');
    pay_in_utils.set_location(g_debug,l_procedure, 250);

    archive_pt_payroll_data;
    pay_in_utils.set_location(g_debug,l_procedure, 260);

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 270);
      --

  EXCEPTION
    WHEN OTHERS THEN
      IF  get_payslip_aa%ISOPEN THEN
         CLOSE get_payslip_aa;
      END IF;
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 280);
       pay_in_utils.trace(l_message,l_procedure);

      RAISE;
  --
  END archive_code;
--
END pay_in_payslip_archive;

/
