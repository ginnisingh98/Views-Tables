--------------------------------------------------------
--  DDL for Package Body PAY_CN_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_PAYSLIP_ARCHIVE" AS
/* $Header: pycnparc.pkb 120.11.12010000.4 2008/12/05 06:06:49 rsaharay ship $ */

  ----------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
  ----------------------------------------------------------------------+

  g_archive_pact         NUMBER;
  g_package              CONSTANT VARCHAR2(100) := 'pay_cn_payslip_archive';

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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Removed 'distinct' from SQL statement--
  --                                 returned.                            --
  --                                 Added csr_leave_balance%FOUND        --
  --                                 condition                            --
  --------------------------------------------------------------------------
  --

  PROCEDURE range_code(
                        p_payroll_action_id   IN  NUMBER
                       ,p_sql                 OUT NOCOPY VARCHAR2
                      )
  IS
  --
    l_procedure  VARCHAR2(100);
  --
  BEGIN
  --
    l_procedure  := g_package || '.range_code';
    hr_utility.set_location('Entering ' || l_procedure,10);

    --------------------------------------------------------------------------------+
    -- Call to range_code from common apac package 'pay_apac_payslip_archive'
    -- to archive the payroll action level data  and EIT defintions.
    --------------------------------------------------------------------------------+

    pay_apac_payslip_archive.range_code
                              (
                                p_payroll_action_id => p_payroll_action_id
                              );

    --
    --  sql string to SELECT a range of assignments eligible for archival.
    --

    -- Bug 3580609
    -- Call core package to return SQL statement
    pay_core_payslip_utils.range_cursor(p_payroll_action_id
                                       ,p_sql);

    hr_utility.set_location('Leaving ' || l_procedure,20);
  --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in ' || l_procedure,30);
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
  --                  HThe globals used are PL/SQL tables                 --
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Replaced %TYPE with actual data type --
  --                                 in parameter list.                   --
  -- 115.2 14-Nov-2008    mdubasi    Added code to update payroll_id in   --
  --				     pay_payroll_actions table.
  --------------------------------------------------------------------------
  --


  PROCEDURE initialization_code (
                                  p_payroll_action_id  IN NUMBER
                                )
  IS
  --
    l_procedure  VARCHAR2(100) ;
  --
    l_payroll_id NUMBER;
    leg_param    pay_payroll_actions.legislative_parameters%TYPE;
    l_ppa_payroll_id pay_payroll_actions.payroll_id%TYPE;
    l_pactid  pay_payroll_actions.payroll_action_id%TYPE;
  --
  BEGIN
  --
    l_procedure  :=  g_package || '.initialization_code';
    hr_utility.set_location('Entering ' || l_procedure,10);


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

    hr_utility.set_location('Leaving ' || l_procedure,20);
  --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in ' || l_procedure,10);
      RAISE;
  --
  END initialization_code;

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
  --                  'Choose Payslip' work for CN.                       --
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Replaced %TYPE with actual data type --
  --                                 in parameter list.                   --
  -- 115.10 07-Nov-2003   statkar    Removed one date-effective check from--
  --                                 the cursor for ppa1.effective_date   --
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
    -- Bug 3580609
    -- Removed cursors and local variable declarations

    l_procedure                 VARCHAR2(100);
  --
  BEGIN
  --
    l_procedure  :=  g_package || '.assignment_action_code';
    hr_utility.set_location('Entering ' || l_procedure,10);

    -- Bug 3580609
    -- Call core package to create assignment actions
    pay_core_payslip_utils.action_creation (
                                             p_payroll_action_id
                                            ,p_start_person
                                            ,p_end_person
                                            ,p_chunk
                                            ,'CN_PAYSLIP_ARCHIVE'
                                            ,'CN');

  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      hr_utility.set_location('Error in ' || l_procedure,10);
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Changed parameter list in cursor.    --
  --                                 Included  csr_leave_balance%FOUND    --
  --                                 condition                            --
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
      SELECT  pap.accrual_plan_name
             ,hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',pap.accrual_category)
             ,pap.accrual_units_of_measure
             ,ppa.payroll_id
             ,pap.business_group_id
             ,pap.accrual_plan_id
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
    l_payroll_id                 pay_all_payrolls_f.payroll_id%type;
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
  --
  BEGIN
  --
    l_procedure := g_package || '.archive_accrual_details';
    hr_utility.set_location('Entering ' || l_procedure,10);

    hr_utility.set_location('Opening Cursor csr_leave_balance',20);

    OPEN  csr_leave_balance;
    FETCH csr_leave_balance INTO
          l_accrual_plan_name
         ,l_accrual_category
         ,l_accrual_uom
         ,l_payroll_id
         ,l_business_group_id
         ,l_accrual_plan_id;

    IF csr_leave_balance%FOUND THEN
    --
      -- Call to get annual leave balance

      hr_utility.set_location('Archiving Annual leave Balance information',30);

      per_accrual_calc_functions.get_net_accrual
        (
          p_assignment_id     => p_assignment_id          --  number  in
         ,p_plan_id           => l_accrual_plan_id        --  number  in
         ,p_payroll_id        => l_payroll_id             --  number  in
         ,p_business_group_id => l_business_group_id      --  number  in
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


      hr_utility.set_location('Archiving Leave Taken information',40);

      l_leave_taken   :=  per_accrual_calc_functions.get_absence
                            (
                              p_assignment_id
                             ,l_accrual_plan_id
                             ,p_period_end_date
                             ,p_period_start_date
                            );
      l_ovn :=1;

      IF l_accrual_plan_name IS NOT NULL THEN
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
            ,p_action_information1          =>  l_accrual_plan_name
            ,p_action_information2          =>  l_accrual_category
            ,p_action_information4          =>  fnd_number.number_to_canonical(l_annual_leave_balance) -- Bug 3604206
            ,p_action_information5          =>  l_accrual_uom
           );
      --
      END IF;
      --
    --
    END IF;
    --
    CLOSE csr_leave_balance;
    hr_utility.set_location('Closing Cursor csr_leave_balance',50);

    hr_utility.set_location('Leaving ' || l_procedure,60);

  --
  EXCEPTION
    WHEN OTHERS THEN
      IF csr_leave_balance%ISOPEN THEN
      --
        CLOSE csr_leave_balance;
      --
      END IF;
      --
      hr_utility.set_location('Error in ' || l_procedure,70);
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Changed parameter list in cursor.    --
  -- 115.2 27-Sep-2005    snekkala   Removed use of pay_element_entry     --
  --                                 values_f in the cursor csr_asg_absences --
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
      SELECT pat.name                                                                               absence_type
            ,pet.reporting_name                                                                     reporting_name
            ,decode(pet.processing_type,'R',greatest(pab.date_start,PTP.START_DATE),pab.date_start) start_date
            ,decode(pet.processing_type,'R',least(pab.date_end,PTP.END_DATE),pab.date_end)          end_date
            ,decode(pet.processing_type,'R',to_number(prrv.result_value),nvl(pab.absence_days,pab.absence_hours)) absence_days
      FROM   pay_assignment_actions       paa
            ,pay_payroll_actions          ppa
            ,pay_run_results              prr
            ,pay_run_result_values        prrv
            ,per_time_periods             ptp
            ,pay_element_types_f          pet
            ,pay_input_values_f           piv
            ,pay_element_entries_f        pee
            ,per_absence_attendance_types pat
            ,per_absence_attendances      pab
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

    l_procedure                   varchar2(200);
    l_start_date                  VARCHAR2(20);
    l_end_date                    VARCHAR2(20);
    l_ovn                         NUMBER;
    l_action_info_id              NUMBER;
    --
  --
  BEGIN
  --
    l_procedure := g_package || '.archive_absences';
    hr_utility.set_location('Entering Procedure ' || l_procedure,10);
    --
    FOR csr_rec in csr_asg_absences
    LOOP
    --
      hr_utility.set_location('csr_rec.name..................= ' ||csr_rec.absence_type,50);
      hr_utility.set_location('csr_rec.element_reporting_name.= '||csr_rec.reporting_name,50);
      hr_utility.set_location('csr_rec.start_date.............= '||to_char(csr_rec.start_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.end_date...............= '||to_char(csr_rec.end_date,'DD-MON-YYYY'),50);
      hr_utility.set_location('csr_rec.absence_days.......... = '||csr_rec.absence_days,50);

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
    hr_utility.set_location('Leaving Procedure ' || l_procedure,20);
  --
  EXCEPTION
  --
    WHEN others THEN
      IF csr_asg_absences%ISOPEN THEN
        close csr_asg_absences;
      END IF;
      hr_utility.set_location('Error in ' || l_procedure,30);
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
  --                  PAY_CN_ASG_ELEMENTS_V to get the elements and       --
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Changed parameter list in cursor.    --
  -- 115.2 20-Dec-2005    snekkala   Removed cursor csr_std_elements      --
  --                                 Added csr_std_elements1, 		  --
  --                                 csr_std_elements2                    --
  --                                 and csr_locking_exists               --
  -- 115.3 24-Feb-2006    lnagaraj   Used csr_stat_elements in place      --
  --                                 of changes in previous version       --
  -- 115.4 27-May-2008    dduvvuri   7121458- Added fnd_number.canonical_to_number in the
  --                                 cursor csr_stat_elements ro remove
  --                                 invalid number issues
  -- 115.5 01-Dec-2008    rsaharay   Added code for Pre Tax Non Statutory --
  --                                 Deductions                           --
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

    CURSOR  csr_stat_elements
    IS
       SELECT nvl(petl.reporting_name,petl.element_name)                     element_reporting_name
            , decode(pec.classification_name ,'Special Payments','Taxable Earnings'
	                                     ,'Annual Bonus','Taxable Earnings'
					     ,'Retro Taxable Earnings','Taxable Earnings'
					     ,'Retro Special Payments','Taxable Earnings'
					     ,'Retro Annual Bonus','Taxable Earnings'
					     ,'Voluntary Deductions','Voluntary Dedn'
					     ,'Severance Payments','Taxable Earnings'
					     ,'Direct Payments','Non Taxable Earnings'
					     ,'Retro Statutory Deductions','Statutory Deductions'
					     ,'Retro Variable Yearly Earnings','Taxable Earnings'
					     ,'Variable Yearly Earnings','Taxable Earnings'
					     ,'Retro Pre Tax Non Statutory Deductions' , 'Pre Tax Non Statutory Deductions'
					     ,pec.classification_name
					     )                               classification_name
	    , sum(decode(substr(piv.uom,1,1), 'M', fnd_number.canonical_to_number(prrv.result_value), null)) amount
	    , decode(pet.input_currency_code, 'CNY',NULL
	                                    , pet.input_currency_code)       foreign_currency_code
	    , pay_cn_payslip.get_exchange_rate(pet.input_currency_code
	                                      ,pet.output_currency_code
					      ,ppa.effective_date
					      ,ppa.business_group_id
					      )                              exchange_rate
       FROM pay_payroll_actions         ppa
	    , pay_assignment_actions      paa
	    , pay_run_results             prr
	    , pay_run_result_values       prrv
	    , pay_input_values_f          piv
	    , pay_element_types_f         pet
	    , pay_element_types_f_tl      petl
	    , pay_element_classifications pec
            ,pay_action_interlocks pai
        WHERE ppa.action_type in ('R','Q')
	  AND ppa.action_status = 'C'
	  AND ppa.payroll_action_id       = paa.payroll_action_id
	  AND paa.assignment_action_id    = prr.assignment_action_id
          AND pai.locking_action_id    = p_assignment_action_id
	  AND pec.classification_name IN  ('Taxable Earnings'
                                          ,'Voluntary Deductions'
                                          ,'Non Taxable Earnings'
                                          ,'Statutory Deductions'
                                          ,'Special Payments'
                                          ,'Annual Bonus'
                                          ,'Severance Payments'
                                          ,'Direct Payments'
                                          ,'Retro Taxable Earnings'
                                          ,'Retro Statutory Deductions'
                                          ,'Retro Special Payments'
                                          ,'Retro Annual Bonus'
                                          ,'Variable Yearly Earnings'
                                          ,'Retro Variable Yearly Earnings'
					  ,'Pre Tax Non Statutory Deductions'
					  ,'Retro Pre Tax Non Statutory Deductions'
                                          )
          AND pec.legislation_code        = 'CN'
	  AND pec.classification_id       = pet.classification_id
	  AND pet.element_name            <> 'Special Payments Normal'
	  AND pet.element_type_id         = petl.element_type_id
	  AND petl.language               = USERENV('LANG')
	  AND pet.element_type_id         = piv.element_type_id
	  AND piv.name                    = decode(pec.classification_name,'Special Payments','Payment Amount'
	                                                                  ,'Pay Value')
	  AND pet.element_type_id         = prr.element_type_id
	  AND prr.run_result_id           = prrv.run_result_id
	  AND piv.input_value_id          = prrv.input_value_id
	  AND ppa.effective_date    BETWEEN pet.effective_start_date
	                                AND pet.effective_end_date
	  AND ppa.effective_date    BETWEEN piv.effective_start_date
	                                AND piv.effective_end_date
          AND pai.locked_action_id    = paa.assignment_action_id
     GROUP BY pet.rowid
	    , decode(pec.classification_name ,'Special Payments','Taxable Earnings'
	                                     ,'Annual Bonus','Taxable Earnings'
					     ,'Retro Taxable Earnings','Taxable Earnings'
					     ,'Retro Special Payments','Taxable Earnings'
					     ,'Retro Annual Bonus','Taxable Earnings'
					     ,'Voluntary Deductions','Voluntary Dedn'
					     ,'Severance Payments','Taxable Earnings'
					     ,'Direct Payments','Non Taxable Earnings'
					     ,'Retro Statutory Deductions','Statutory Deductions'
					     ,'Retro Variable Yearly Earnings','Taxable Earnings'
					     ,'Variable Yearly Earnings','Taxable Earnings'
					     ,'Retro Pre Tax Non Statutory Deductions' , 'Pre Tax Non Statutory Deductions'
					     ,pec.classification_name
					     )
            , nvl(petl.reporting_name,petl.element_name)
	    , pet.processing_priority
	    , pet.input_currency_code
	    , pay_cn_payslip.get_exchange_rate(pet.input_currency_code
	                                      ,pet.output_currency_code
					      ,ppa.effective_date
					      , ppa.business_group_id
					      );


    l_action_info_id          NUMBER;
    l_ovn                     NUMBER;
    l_foreign_currency_amount NUMBER;
    l_rate                    NUMBER;
    l_procedure          VARCHAR2(100);
    --
  --
  BEGIN
  --

    l_procedure := g_package ||'.archive_stat_elements';
    hr_utility.set_location('Entering ' || l_procedure,10);

    hr_utility.set_location('Opening Cursor csr_std_elements',20);


    FOR csr_rec IN csr_stat_elements
    LOOP
    --
      hr_utility.set_location('Archiving  Details of Element ' ||csr_rec.element_reporting_name ,30);

      IF nvl(csr_rec.exchange_rate,0) <> 0 THEN
        l_foreign_currency_amount := csr_rec.amount / csr_rec.exchange_rate;
      ELSE
        l_foreign_currency_amount := NULL;
      END IF;

      IF ( csr_rec.amount IS NOT NULL) THEN
      --
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
           ,p_action_information5           =>  fnd_number.number_to_canonical(csr_rec.amount)             -- Bug 3604206
           ,p_action_information10          =>  fnd_number.number_to_canonical(csr_rec.exchange_rate)      -- Bug 3604206
           ,p_action_information11          =>  fnd_number.number_to_canonical(l_foreign_currency_amount)  -- Bug 3604206
           ,p_action_information12          =>  csr_rec.foreign_currency_code
          );
      --
      END IF;
      --
    --
    END LOOP;
    --


    hr_utility.set_location('Closing Cursor csr_std_elements',40);
    hr_utility.set_location('End of archive Standard Element',50);
    hr_utility.set_location('Leaving ' || l_procedure,80);

  --
  EXCEPTION
  --
    WHEN OTHERS THEN
           --
      IF csr_stat_elements%ISOPEN THEN
      --
        CLOSE csr_stat_elements;
      --
      END IF;
      --
      hr_utility.set_location('Error in ' || l_procedure,70);
      RAISE;
  --
  END archive_stat_elements;

  -- Bug 3116630 starts
  --
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_INFO_ELEMENTS                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives given 'Information'         --
  --                  elements                                            --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id    NUMBER                    --
  --                  p_assact_id               NUMBER                    --
  --                  p_effective_date          DATE                      --
  --                  p_element_name            VARCHAR2                  --
  --                  p_input_value_name        VARCHAR2                  --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 03-SEP-2003    bramajey   Initial Version                      --
  -- 115.1 18-Dec-2006    rpalli     Element name to be archived as per   --
  --                                 session language                     --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_info_element (
                                   p_assignment_action_id  IN NUMBER
                                  ,p_assact_id             IN NUMBER
                                  ,p_effective_date        IN DATE
                                  ,p_element_name          IN VARCHAR2
                                  ,p_input_value_name      IN VARCHAR2
                                )
  IS
       CURSOR csr_elem_name IS
         SELECT petl.element_name
         FROM  pay_element_types_f pet,
               pay_element_types_f_tl petl
         WHERE pet.element_name  = p_element_name
         AND   pet.legislation_code = 'CN'
         AND   pet.element_type_id = petl.element_type_id
         AND   petl.language = userenv('LANG');
  --
    l_action_info_id   NUMBER;
    l_ovn              NUMBER;
    l_value            NUMBER;
    l_procedure        VARCHAR2(80);
    l_element_name     VARCHAR2(255);
  --

  BEGIN
  --
     l_procedure := g_package || '.archive_special_elements';
     hr_utility.set_location('Entering ' || l_procedure,10);

     pay_cn_payslip.get_run_result_value (
                                           p_assignment_action_id  => p_assignment_action_id
                                          ,p_element_name          => p_element_name
                                          ,p_input_value_name      => p_input_value_name
                                          ,p_value                 => l_value
                                         );

     hr_utility.set_location('Archiving '|| p_element_name || p_input_value_name,20);

     OPEN csr_elem_name;
     FETCH csr_elem_name
       INTO  l_element_name;
     CLOSE csr_elem_name;

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
         ,p_action_information1           =>  l_element_name
         ,p_action_information2           =>  NULL
         ,p_action_information3           =>  NULL
         ,p_action_information4           =>  'Information'
         ,p_action_information5           =>  fnd_number.number_to_canonical(l_value) -- Bug 3604206
         ,p_action_information7           =>  p_input_value_name
         ,p_action_information10          =>  null
         ,p_action_information11          =>  null
         ,p_action_information12          =>  null
        );
     hr_utility.set_location('Leaving ' || l_procedure,30);
  --
  END archive_info_element;
  --


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_SPECIAL_ELEMENTS                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives elements required           --
  --                  for Tax Reporting purposes                          --
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
  -- 115.0 03-SEP-2003    bramajey   Initial Version                      --
  -- 115.1 20-Jul-2005    rpalli     Bug4303538: Added code to archive    --
  --						 "Bonus Taxable Income"   --
  -- 115.2 03-Mar-2006    rpalli    4994788  Modified code to archive     --
  --                                elements useful in annual bonus tax   --
  --                                reporting                             --
  -- 115.3 26-Apr-2006    rpalli    5160582  Modified code to archive     --
  --                                some more input values for elements   --
  --                                useful in annual bonus tax reporting  --
  --                                and removed code for above fix for    --
  --                                bug 4994788                           --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_special_elements(
                                      p_assignment_action_id  IN NUMBER
                                     ,p_effective_date        IN DATE
                                     ,p_assact_id             IN NUMBER
                                    )
  IS
  --
    l_procedure            VARCHAR2(80);
  --
  BEGIN
  --
    l_procedure := g_package || '.archive_special_elements';
    hr_utility.set_location('Entering ' || l_procedure,10);

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'QD Amount'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Separate QD Amount'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Separate Tax Rate'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Severance QD Amount'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Severance Tax Rate'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Severance Taxable Income'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Tax Exempt Amount'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Tax Rate'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax Report Information'
                          ,p_input_value_name      => 'Taxable Income'
                         );

/*Bug 4303538 starts */
    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax on Annual Bonus'
                          ,p_input_value_name      => 'Bonus Taxable Income'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Retro Tax on Annual Bonus'
                          ,p_input_value_name      => 'Bonus Taxable Income'
                         );
/*Bug 4303538 ends */


/*Bug 5160582 starts */
    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax on Annual Bonus'
                          ,p_input_value_name      => 'Bonus Tax Rate'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Tax on Annual Bonus'
                          ,p_input_value_name      => 'Bonus QD Amount'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Retro Tax on Annual Bonus'
                          ,p_input_value_name      => 'Bonus Tax Rate'
                         );

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Retro Tax on Annual Bonus'
                          ,p_input_value_name      => 'Bonus QD Amount'
                         );

/*Bug 5160582 ends */

    archive_info_element (
                           p_assignment_action_id  => p_assignment_action_id
                          ,p_assact_id             => p_assact_id
                          ,p_effective_date        => p_effective_date
                          ,p_element_name          => 'Special Payments Separate'
                          ,p_input_value_name      => 'Process Separate Amount'
                         );

    hr_utility.set_location('Leaving ' || l_procedure,20);

  --
  END archive_special_elements;
  --
  -- Bug 3116630 ends

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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 09-JUL-2004    sshankar   Bug 3746275. Archived balance name   --
  --                                 under source text coulmn and balance --
  --                                 reporting name under information1    --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_balances(
                              p_effective_date IN DATE
                             ,p_assact_id      IN NUMBER
                             ,p_narrative      IN VARCHAR2
                             ,p_value_curr     IN NUMBER
                             ,p_value_ytd      IN NUMBER
			     ,p_bal_rpt_name   IN VARCHAR2
                            )
  IS
  --
    l_action_info_id   NUMBER;
    l_ovn              NUMBER;
    l_procedure        VARCHAR2(80);
  --
  BEGIN
  --
    l_procedure := g_package || '.archive_balances';
    hr_utility.set_location('Entering ' || l_procedure,10);
    hr_utility.set_location('Archiving balance : ' || p_narrative,20);
    hr_utility.set_location('Balance reporting name : ' || p_bal_rpt_name,25);

    -- Archive Statutory balances

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
       ,p_action_information1          =>  p_bal_rpt_name
       ,p_action_information2          =>  NULL
       ,p_action_information3          =>  NULL
       ,p_action_information4          =>  fnd_number.number_to_canonical(p_value_ytd)    -- Bug 3604206
       ,p_action_information5          =>  fnd_number.number_to_canonical(p_value_curr)   -- Bug 3604206
      );

    hr_utility.set_location('Leaving ' || l_procedure,30);
  --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in ' || l_procedure,40);
      RAISE;
  --
  END archive_balances;
  --

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_STAT_BALANCES                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure calls pay_cn_payslip.balance_totals  --
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 09-JUL-2004    sshankar   Added code to archive balances       --
  --                                 reporting name from translated table.--
  --                                 Bug 3746275.                         --
  -- 115.2 03-Mar-2006    rpalli    4994788  Modified code to archive     --
  --                                balances useful in annual bonus tax   --
  --                                reporting                             --
  -- 115.3 18-Dec-2006    rpalli    5717755  Modified code to archive     --
  --                                balance names for annnual bonus       --
  --                                based on session language             --
  -- 115.4 19-Dec-2006    rpalli    5724500  Modified code to archive     --
  --                                balance report names for annnual bonus--
  -- 115.5 01-Dec-2008    rsaharay  Added code for Pre Tax Non Statutory  --
  --                                Deductions                            --
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
  --
    l_taxable_earnings_current       NUMBER;
    l_non_taxable_earnings_current   NUMBER;
    l_voluntary_deductions_current   NUMBER;
    l_statutory_deductions_current   NUMBER;
    l_pre_tax_deductions_current     NUMBER;
    l_taxable_earnings_ytd           NUMBER;
    l_non_taxable_earnings_ytd       NUMBER;
    l_statutory_deductions_ytd       NUMBER;
    l_voluntary_deductions_ytd       NUMBER;
    l_pre_tax_deductions_ytd         NUMBER;
    l_narrative                      VARCHAR2(150);
    l_procedure                      VARCHAR2(80);
    --
    -- Bug 3746275. Start
    --
    l_balance_rpt_name               VARCHAR2(200);

    l_annual_bonus_current            NUMBER;
    l_annual_bonus_ytd                NUMBER;
    l_retro_ann_bonus_current         NUMBER;
    l_retro_ann_bonus_ytd             NUMBER;
    l_tax_ann_bonus_current          NUMBER;
    l_tax_ann_bonus_ytd              NUMBER;

    CURSOR csr_balance_rpt_name(c_balance_name VARCHAR2)
    IS
      SELECT nvl(bal_tl.reporting_name, bal_tl.balance_name)
      FROM   pay_balance_types bal
            ,pay_balance_types_tl bal_tl
      WHERE bal.balance_name = c_balance_name
      AND   bal.legislation_code = 'CN'
      AND   bal.balance_type_id = bal_tl.balance_type_id
      AND   bal_tl.language = USERENV('LANG');
    --
    -- Bug 3746275. End
    --
  --
  BEGIN
  --
    l_procedure := g_package || '.archive_stat_balances';
    hr_utility.set_location('Entering ' || l_procedure,10);
    hr_utility.set_location('Calling balance_total from pay_cn_payslip',20);

    -- Get the totals of all the balances

    pay_cn_payslip.balance_totals(
                                   p_prepaid_tag                  => 'Y'
                                  ,p_assignment_action_id         => p_assignment_action_id
                                  ,p_taxable_earnings_current     => l_taxable_earnings_current
                                  ,p_non_taxable_earnings_current => l_non_taxable_earnings_current
                                  ,p_voluntary_deductions_current => l_voluntary_deductions_current
                                  ,p_statutory_deductions_current => l_statutory_deductions_current
                                  ,p_pre_tax_deductions_current   => l_pre_tax_deductions_current
                                  ,p_taxable_earnings_ytd         => l_taxable_earnings_ytd
                                  ,p_non_taxable_earnings_ytd     => l_non_taxable_earnings_ytd
                                  ,p_voluntary_deductions_ytd     => l_voluntary_deductions_ytd
                                  ,p_statutory_deductions_ytd     => l_statutory_deductions_ytd
                                  ,p_pre_tax_deductions_ytd       => l_pre_tax_deductions_ytd
                                 );

    l_narrative := 'Taxable Earnings';
    --
    -- Bug 3746275. Start
    -- Fetch Balance's reporting name from translated table for Userenv language
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,30);

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_taxable_earnings_current
                     ,p_value_ytd      => l_taxable_earnings_ytd
		     ,p_bal_rpt_name   => l_balance_rpt_name
                    );

    --
    -- Bug 3746275. End
    --
    l_narrative := 'Non Taxable Earnings';
    --
    -- Bug 3746275. Start
    -- Fetch Balance's reporting name from translated table for Userenv language
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,30);

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_non_taxable_earnings_current
                     ,p_value_ytd      => l_non_taxable_earnings_ytd
                     ,p_bal_rpt_name   => l_balance_rpt_name
                    );

    --
    -- Bug 3746275. End
    --
    l_narrative := 'Voluntary Deductions';
    --
    -- Bug 3746275. Start
    -- Fetch Balance's reporting name from translated table for Userenv language
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,30);

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_voluntary_deductions_current
                     ,p_value_ytd      => l_voluntary_deductions_ytd
                     ,p_bal_rpt_name   => l_balance_rpt_name
                    );
    --
    -- Bug 3746275. End
    --

    l_narrative := 'Statutory Deductions';
    --
    -- Bug 3746275. Start
    -- Fetch Balance's reporting name from translated table for Userenv language
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;

    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,30);

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_statutory_deductions_current
                     ,p_value_ytd      => l_statutory_deductions_ytd
                     ,p_bal_rpt_name   => l_balance_rpt_name
                    );
    --
    -- Bug 3746275. End
    --

    l_narrative := 'Pre Tax Non Statutory Deductions';
    --
    -- Bug 3746275. Start
    -- Fetch Balance's reporting name from translated table for Userenv language
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,35);

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_pre_tax_deductions_current
                     ,p_value_ytd      => l_pre_tax_deductions_ytd
		     ,p_bal_rpt_name   => l_balance_rpt_name
                    );


    l_narrative := 'Annual Bonus';
    --
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,40);

    pay_cn_payslip.current_and_ytd_balances (
                                 p_prepaid_tag           => 'Y'
                                ,p_assignment_action_id  => p_assact_id
                                ,p_balance_name          => l_narrative
                                ,p_current_balance       => l_annual_bonus_current
                                ,p_ytd_balance           => l_annual_bonus_ytd
                               );

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_annual_bonus_current
                     ,p_value_ytd      => l_annual_bonus_ytd
		     ,p_bal_rpt_name   => l_balance_rpt_name
                    );


    l_narrative := 'Retro Annual Bonus';
    --
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,45);

    pay_cn_payslip.current_and_ytd_balances (
                               p_prepaid_tag           => 'Y'
                              ,p_assignment_action_id  => p_assact_id
                              ,p_balance_name          => l_narrative
                              ,p_current_balance       => l_retro_ann_bonus_current
                              ,p_ytd_balance           => l_retro_ann_bonus_ytd
                             );

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_retro_ann_bonus_current
                     ,p_value_ytd      => l_retro_ann_bonus_ytd
		     ,p_bal_rpt_name   => l_balance_rpt_name
                    );

    l_narrative := 'Tax on Annual Bonus';
    --
    --
    OPEN csr_balance_rpt_name(l_narrative);
    FETCH csr_balance_rpt_name INTO l_balance_rpt_name;
    CLOSE csr_balance_rpt_name;
    hr_utility.set_location('Archiving value for  ' || l_balance_rpt_name,45);

    pay_cn_payslip.current_and_ytd_balances (
                               p_prepaid_tag           => 'Y'
                              ,p_assignment_action_id  => p_assact_id
                              ,p_balance_name          => l_narrative
                              ,p_current_balance       => l_tax_ann_bonus_current
                              ,p_ytd_balance           => l_tax_ann_bonus_ytd
                             );

    archive_balances(
                      p_effective_date => p_effective_date
                     ,p_assact_id      => p_assact_id
                     ,p_narrative      => l_narrative
                     ,p_value_curr     => l_tax_ann_bonus_current
                     ,p_value_ytd      => l_tax_ann_bonus_ytd
		     ,p_bal_rpt_name   => l_balance_rpt_name
                    );

    hr_utility.set_location('End of Archiving Stat Balances ',100);

    hr_utility.set_location('Leaving ' || l_procedure,110);
  --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in ' || l_procedure,120);
      RAISE;
  --
  END archive_stat_balances;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_LEGAL_EMPLOYER_DETAILS                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives the legal employer address  --
  --                  and withholding file number of the Employer         --
  --                  The action DF structures used are                   --
  --                       ADDRESS DETAILS                                --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id          NUMBER                 --
  --                  p_tax_unit_id                NUMBER                 --
  --                  p_effective_date             DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 17-SEP-2003    bramajey   Initial Version                      --
  -- 115.1 18-SEP-2003    bramajey   Added code to archive telephone      --
  --                                 number                               --
  --------------------------------------------------------------------------
  PROCEDURE  archive_legal_employer_details
                       (
                          p_payroll_action_id          IN NUMBER
                         ,p_employer_id                IN NUMBER
                         ,p_effective_date             IN DATE
                       )
  IS
     CURSOR csr_arch_address IS
       SELECT 'exists'
       FROM   pay_action_information
       WHERE  action_context_id           = p_payroll_action_id
       AND    action_context_type         = 'PA'
       AND    action_information_category = 'ADDRESS DETAILS'
       AND    action_information1         = p_employer_id
       AND    action_information14        = 'Legal Employer Address'
       AND    effective_date              = p_effective_date;

     CURSOR csr_le_address IS
       SELECT hl.address_line_1
             ,hl.address_line_2
             ,hr_general.decode_lookup('CN_PROVINCE',hl.town_or_city) province
             ,ft.territory_short_name country
             ,hl.postal_code
             ,hl.telephone_number_1
       FROM   hr_all_organization_units hou
             ,hr_locations hl
             ,fnd_territories_tl ft
       WHERE  hou.organization_id = p_employer_id
       AND    hou.location_id     = hl.location_id
       AND    hl.country          = ft.territory_code
       AND    ft.language         = userenv ('LANG');

    --
    CURSOR csr_file_number
    IS
       SELECT hoi.org_information8
       FROM   hr_organization_information hoi
       WHERE  hoi.organization_id = p_employer_id
       AND    hoi.org_information_context like 'PER_EMPLOYER_INFO_CN' ;
    --
    l_dummy               VARCHAR2(10);
    l_address_line_1      hr_locations.address_line_1%TYPE;
    l_address_line_2      hr_locations.address_line_2%TYPE;
    l_province            hr_lookups.meaning%TYPE;
    l_country             fnd_territories_tl.territory_short_name%TYPE;
    l_postal_code         hr_locations.postal_code%TYPE;
    l_telephone_no        hr_locations.telephone_number_1%TYPE;
    l_file_number         hr_organization_information.org_information8%TYPE;
    l_procedure           VARCHAR2(80);
    l_ovn                 NUMBER;
    l_action_info_id      NUMBER;

  BEGIN
    l_procedure := g_package || '.archive_employee_details';
    l_ovn := TO_NUMBER(NULL);
    l_action_info_id := TO_NUMBER(NULL);

    hr_utility.set_location('Entering ' || l_procedure,10);

    hr_utility.set_location('Opening cursor csr_arch_address',20);
    OPEN csr_arch_address;
    FETCH csr_arch_address
        INTO l_dummy;
    IF csr_arch_address%NOTFOUND THEN
    --

       hr_utility.set_location('Opening cursor csr_le_address',30);

       OPEN csr_le_address;
       FETCH csr_le_address
         INTO l_address_line_1, l_address_line_2, l_province, l_country, l_postal_code,l_telephone_no;
       CLOSE csr_le_address;

       hr_utility.set_location('Closing cursor csr_le_address',40);

       hr_utility.set_location('Opening cursor csr_file_number',50);

       OPEN csr_file_number;
       FETCH csr_file_number
         INTO l_file_number;
       CLOSE csr_file_number;

       hr_utility.set_location('Closing cursor csr_file_number',60);
       --
       -- Archiving the Employer Address only if it doesnot exists
       --
          hr_utility.set_location('Archiving Legal Employer Address',70);

       pay_action_information_api.create_action_information
       (
         p_action_information_id       => l_action_info_id,
         p_object_version_number       => l_ovn,
         p_action_information_category => 'ADDRESS DETAILS',
         p_action_context_id           => p_payroll_action_id,
         p_action_context_type         => 'PA',
         p_effective_date              => p_effective_date,
         p_action_information1         => p_employer_id,
         p_action_information5         => l_address_line_1,
         p_action_information6         => l_address_line_2,
         p_action_information8         => l_province,
         p_action_information9         => l_telephone_no,
         p_action_information12        => l_postal_code,
         p_action_information13        => l_country,
         p_action_information14        => 'Legal Employer Address',
         p_action_information26        => l_file_number
       );

          hr_utility.set_location('After archival of Legal Employer Address',80);
    --
    END IF;

    CLOSE csr_arch_address;

    hr_utility.set_location('Leaving ' || l_procedure,200);
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_arch_address%ISOPEN THEN
        CLOSE csr_arch_address;
      END IF;
      IF csr_le_address%ISOPEN THEN
        CLOSE csr_le_address;
      END IF;
      IF csr_file_number%ISOPEN THEN
        CLOSE csr_file_number;
      END IF;

  END archive_legal_employer_details;



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
  --                  to make core provided 'Choose Payslip' work for CN. --
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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 03-JUL-2003    bramajey   Changed Parameter list in cursors    --
  -- 115.2 03-SEP-2003    bramajey   Changed code to archive Tax area and --
  --                                 meaning of Payout Location           --
  -- 115.3 15-Sep-2003    bramajey   Modified csr_bank_details to archive --
  --                                 currency_code for Cheque/Cash PPMs   --
  --                                 Changed code to archive Expatriate & --
  --                                 Passport.                            --
  -- 115.4 18-Sep-2003    bramajey   Made changes in effective date check --
  --                                 csr_bank_details                     --
  -- 115.5 30-Sep-2003    vinaraya   Included the decode in the select    --
  --                                 clause in csr_bank_details           --
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

    -- Cursor to select the archived information for category 'EMPLOYEE NET PAY DISTRIBUTION'
    -- by core package.

    CURSOR  csr_emp_det_action_info_id
    IS
      SELECT  action_information_id
      FROM    pay_action_information
      WHERE   action_information_category = 'EMPLOYEE DETAILS'
      AND     action_context_id           =  p_assactid
      AND     action_context_type         = 'AAP';

    -- Cursor to select the tax_unit_id of the prepayment needed for archival

    CURSOR csr_tax_unit_id
    IS
      SELECT tax_unit_id
      FROM pay_assignment_actions
      WHERE assignment_action_id          = p_curr_pymt_ass_act_id;
    --


    -- Cursor to get the bank name,percentage and currency code

   /*********** Bug 3166092 ***************************************/
   /* Modified the query to fetch bank details only when the payment
      type is Direct Deposit */

    CURSOR csr_bank_details(
                              p_personal_payment_method_id NUMBER
                             ,p_org_payment_method_id      NUMBER
                           )
    IS
      SELECT pea.segment1                   bank_name
            ,pea.segment2                   bank_branch
            ,pea.segment3                   account_number
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


    --
    CURSOR csr_soft_key
    IS
      SELECT hsck.segment20                                                -- Tax Area
            ,hr_general.decode_lookup('CN_PAYOUT_LOCATION',hsck.segment22) -- Payout Location
      FROM   hr_soft_coding_keyflex   hsck
            ,per_all_assignments_f    paaf
            ,pay_assignment_actions   paa
            ,pay_payroll_actions      ppa
      WHERE  paa.assignment_action_id    = p_assactid
      AND    paa.payroll_action_id       = ppa.payroll_action_id
      AND    paa.assignment_id           = paaf.assignment_id
      AND    hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
      AND    ppa.effective_date    BETWEEN paaf.effective_start_date
                                   AND     paaf.effective_end_date;
    --
    -- Bug 3139966 starts
    --
    CURSOR csr_person_id
    IS
      SELECT paa.person_id
      FROM   per_all_assignments_f paa
      WHERE  paa.assignment_id   = p_assignment_id
      AND    p_date_earned BETWEEN paa.effective_start_date
                           AND     paa.effective_end_date;
    --
    CURSOR csr_expatriate (p_person_id IN NUMBER)
    IS
      SELECT pap.per_information8 expatriate
      FROM   per_all_people_f pap
      WHERE  pap.person_id       = p_person_id
      AND    p_date_earned BETWEEN pap.effective_start_date
                           AND     pap.effective_end_date;
    --
    CURSOR csr_passport (p_person_id IN NUMBER)
    IS
      SELECT pei.pei_information2
      FROM   per_people_extra_info pei
      WHERE  pei.person_id                = p_person_id
      AND    pei.pei_information_category = 'PER_PASSPORT_INFO_CN' ;
    --
    l_passport     per_people_extra_info.pei_information2%TYPE;
    l_person_id    per_all_assignments_f.person_id%TYPE;
    l_expatriate   per_all_people_f.per_information8%TYPE;

    -- Bug 3139966 ends

    l_action_info_id      NUMBER;
    l_ovn                 NUMBER;
    l_tax_code            VARCHAR2(5);
    l_tax_unit_id         NUMBER;
    l_procedure           VARCHAR2(80);
    l_bank_name           VARCHAR2(100);
    l_bank_branch         VARCHAR2(100);
    l_account_number      VARCHAR2(100);
    l_percentage          NUMBER;
    l_currency_code       VARCHAR2(15);
    l_emp_det_act_info_id NUMBER;
    l_tax_area            VARCHAR2(10);
    l_payroll_location    VARCHAR2(100);

  --
  BEGIN
  --
    l_procedure := g_package || '.archive_employee_details';
    hr_utility.set_location('Entering ' || l_procedure,10);

    -- call generic procedure to retrieve and archive all data for
    -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION

    hr_utility.set_location('Opening Cursor csr_tax_unit_id',20);

    OPEN  csr_tax_unit_id;
    FETCH csr_tax_unit_id INTO l_tax_unit_id;
    CLOSE csr_tax_unit_id;

    hr_utility.set_location('Closing Cursor csr_tax_unit_id',30);

    hr_utility.set_location('Calling pay_emp_action_arch.get_personal_information ',40);

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

    hr_utility.set_location('Returned from pay_emp_action_arch.csr_personal_information ',50);

    hr_utility.set_location('Calling update Net Pay Distribution',60);

    hr_utility.set_location('Opening Cursor csr_net_pay_action_info_id',70);

    FOR net_pay_rec in csr_net_pay_action_info_id

    LOOP
    --
      hr_utility.set_location('Opening Cursor csr_bank_details',80);
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
      hr_utility.set_location('Closing Cursor csr_bank_details',90);

      l_ovn := 1;

      hr_utility.set_location('Archiving Bank Details',95);

      pay_action_information_api.update_action_information
        (
          p_action_information_id     =>  net_pay_rec.action_information_id
         ,p_object_version_number     =>  l_ovn
         ,p_action_information5       =>  l_bank_name
         ,p_action_information6       =>  l_bank_branch
         ,p_action_information7       =>  l_account_number
         ,p_action_information12      =>  l_percentage
         ,p_action_information13      =>  l_currency_code
        );
    --
    END LOOP;

    hr_utility.set_location('Closing Cursor csr_net_pay_action_info_id',100);

    --
    -- Payroll Location available in soft coding key flexfield needs to be archived
    -- as this is not archived by the Core Package
    --

    --
    -- Fetch the action_information_id of action information category EMPLOYEE DETAILS
    --

    hr_utility.set_location('Opening Cursor csr_emp_det_action_info_id',110);


    OPEN  csr_emp_det_action_info_id;
    FETCH csr_emp_det_action_info_id INTO  l_emp_det_act_info_id;
    CLOSE csr_emp_det_action_info_id;


    hr_utility.set_location('Closing Cursor csr_emp_det_action_info_id',120);

    --
    -- Fetch Payroll Location
    --

    hr_utility.set_location('Opening Cursor csr_soft_key',130);

    -- Bug 3116630 starts
    -- Added code to archive Tax Area
    --
    OPEN  csr_soft_key;
    FETCH csr_soft_key
      INTO l_tax_area,l_payroll_location;
    CLOSE csr_soft_key;

    hr_utility.set_location('Closing Cursor csr_soft_key',140);
    -- Bug 3139966 starts
    -- Added code to archive Expatriate Indicator, Passport
    OPEN csr_person_id;
    FETCH csr_person_id
       INTO l_person_id;
    CLOSE csr_person_id;

    hr_utility.set_location('Opening Cursor csr_expatriate', 150);

    OPEN csr_expatriate (l_person_id);
    FETCH csr_expatriate
       INTO l_expatriate;
    CLOSE csr_expatriate;

    hr_utility.set_location('Closing Cursor csr_expatriate', 160);

    hr_utility.set_location('Opening Cursor csr_passport', 170);

    OPEN csr_passport (l_person_id);
    FETCH csr_passport
        INTO l_passport;
    CLOSE csr_passport;
    hr_utility.set_location('Closing Cursor csr_passport', 180);

    --
    -- Update Payroll Location,Tax Area, Passport and Expatriate Indicator
    --

    hr_utility.set_location('Updating Tax area, Payroll location, Passport and Expat',190);
    l_ovn := 1;
    pay_action_information_api.update_action_information
       (
        p_action_information_id     =>  l_emp_det_act_info_id
       ,p_object_version_number     =>  l_ovn
       ,p_action_information23      =>  l_tax_area
       ,p_action_information24      =>  l_payroll_location
       ,p_action_information25      =>  l_expatriate
       ,p_action_information26      =>  l_passport
     );

    -- Bug 3116630 ends

    hr_utility.set_location('Archiving the Legal Employer Details',200);
    archive_legal_employer_details
       (
         p_payroll_action_id      => p_payroll_action_id
        ,p_employer_id            => l_tax_unit_id
        ,p_effective_date         => p_pre_effective_date
       );

    -- Bug 3139966 ends
    hr_utility.set_location('Leaving ' || l_procedure,200);
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
      IF csr_soft_key%ISOPEN THEN
        CLOSE csr_soft_key;
      END IF;
      IF csr_person_id%ISOPEN THEN
        CLOSE csr_person_id;
      END IF;
      IF csr_passport%ISOPEN THEN
        CLOSE csr_passport;
      END IF;
      IF csr_expatriate%ISOPEN THEN
        CLOSE csr_expatriate;
      END IF;

      hr_utility.set_location('Error in ' || l_procedure,10);
      RAISE;
  --
  END archive_employee_details;


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
  -- 115.0 30-JUN-2003    bramajey   Initial Version                      --
  -- 115.1 11-AUG-2003    bramajey   Changed condition to                 --
  --                                 pre.locked_action_id =               --
  --                                 passact.assignment_action_id         --
  --                                 in csr_assignment_actions            --
  -- 115.2 03-SEP-2003    bramajey   Added code to Archive Special        --
  --                                 elements                             --
  -- 115.3 20-Sep-2005    snekkala   Modified cursor get_payslip_aa       --
  --                                 for performance
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_code (
                           p_assignment_action_id  IN NUMBER
                          ,p_effective_date        IN DATE
                         )
  IS
  --
    -- Cursor to select all the locked prepayment and payrolls by the archive
    -- assignment action. The records are ordered descending as we only need
    -- latest payroll run in the prepayment.

    -- Bug 3580609
    -- Changed cursor as suggested by core

    CURSOR get_payslip_aa(p_master_aa_id NUMBER)
    IS
    SELECT paa_arch_chd.assignment_action_id   chld_arc_assignment_action_id
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
    FROM   pay_assignment_actions              paa_arch_chd
          ,pay_assignment_actions              paa_arch_mst
          ,pay_assignment_actions              paa_pre
          ,pay_action_interlocks               pai_pre
          ,pay_assignment_actions              paa_run
          ,pay_action_interlocks               pai_run
          ,pay_payroll_actions                 ppa_pre
          ,pay_payroll_actions                 ppa_run
          ,per_time_periods                    ptp
	  ,per_business_groups                 pbg
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

    /* Bug No:5634390
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


    --
    l_procedure                       VARCHAR2(100);
    l_payment_date                    DATE   :=NULL;
  --
  BEGIN
  --
    l_procedure := g_package || '.archive_code';
    hr_utility.set_location('Entering ' || l_procedure,10);

    -- Bug 3580609
    -- Create Child Assignment Actions
    pay_core_payslip_utils.generate_child_actions(p_assignment_action_id
                                                 ,p_effective_date);

    hr_utility.set_location('Opening Cursor get_payslip_aa',15);

    -- Bug 3580609
    -- use cursor suggested by core
    FOR csr_rec IN get_payslip_aa(p_assignment_action_id)
    LOOP
    --

      hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.run_assignment_action_id,20);
      hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' || csr_rec.pre_assignment_action_id,30);

      -- Added for bug 5634390
      open csr_payment_date(csr_rec.run_assignment_action_id);
      fetch csr_payment_date into l_payment_date;
      if csr_payment_date%NOTFOUND then
         l_payment_date := csr_rec.regular_payment_date;
      end if;
      close csr_payment_date;

      --
      -- Call to procedure to archive User Configurable Balances
      --

      pay_apac_payslip_archive.archive_user_balances
      (
        p_arch_assignment_action_id  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
       ,p_run_assignment_action_id   => csr_rec.run_assignment_action_id        -- payroll assignment action id
       ,p_pre_effective_date         => csr_rec.pre_effective_date              -- prepayment effecive date
      );


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


      --
      -- Call to procedure to archive Statutory Elements
      --

      archive_stat_elements
      (
        p_assignment_action_id       => csr_rec.pre_assignment_action_id        -- prepayment assignment action id
       ,p_effective_date             => csr_rec.pre_effective_date              -- prepayment effective date
       ,p_assact_id                  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
      );


      -- Bug 3116630 starts
      -- Call to procedure to archive Special Elements
      --

      archive_special_elements
      (
        p_assignment_action_id       => csr_rec.run_assignment_action_id        -- payroll assignment action id
       ,p_effective_date             => csr_rec.pre_effective_date              -- prepayment effective date
       ,p_assact_id                  => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
      );

      -- Bug 3116630 ends


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


      --
      -- Call to procedure to archive absences
      --

      archive_absences
      (
        p_arch_act_id                 => csr_rec.chld_arc_assignment_action_id   -- archive assignment action id
       ,p_assg_act_id                 => csr_rec.run_assignment_action_id        -- payroll run action id
       ,p_pre_effective_date          => csr_rec.pre_effective_date              -- prepayment effective date
      );

    --
    END LOOP;

    hr_utility.set_location('Closing Cursor csr_assignment_actions',40);
    hr_utility.set_location('Leaving ' || l_procedure,50);
  --
  EXCEPTION
    WHEN OTHERS THEN
      IF  get_payslip_aa%ISOPEN THEN
         close get_payslip_aa;
      END IF;
      hr_utility.set_location('Error in ' || l_procedure,50);
      RAISE;
  --
  END archive_code;
--
END pay_cn_payslip_archive;

/
