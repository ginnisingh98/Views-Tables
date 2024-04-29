--------------------------------------------------------
--  DDL for Package Body PAY_NZ_SSCWT_RATE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_SSCWT_RATE_ARCHIVE" AS
/* $Header: paynzssc.pkb 120.6.12010000.3 2009/02/06 11:01:35 dduvvuri ship $ */

  ----------------------------------------------------------------------+
  -- Global Variables Section
  ----------------------------------------------------------------------+



  /*Global variable to enable trace conditionally*/
  g_debug                BOOLEAN;

  -- This is a global variable used to store Archive assignment action id
  g_archive_pact         NUMBER;

  g_package              VARCHAR2(100);

  g_payroll_id           pay_payrolls_f.payroll_id%TYPE;
  g_assignment_set_id    hr_assignment_sets.assignment_set_id%TYPE;
  g_business_group_id    per_people_f.business_group_id%TYPE;
  g_financial_year       DATE;
  g_processing_mode      VARCHAR2(1);

  g_element_type_id      pay_element_types_f.element_type_id%TYPE ;
  g_input_value_id       pay_input_values_f.input_value_id%TYPE ;

  g_def_balance_tab      pay_balance_pkg.t_balance_value_tab;

  g_start_dd_mm          VARCHAR(6) ;
  g_legislation_code     VARCHAR2(30) ;

  g_report_short_name    VARCHAR2(25) ;
  -----------------------------------------------------------------------
  -- List of private functions/procedures which are used in the package--
  -----------------------------------------------------------------------

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : SUBMIT_SSCWT_REPORT                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : The procedure executes the SSCWT report and is      --
  --                  called by the deinitialize_code of the archive.     --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : N/A                                                 --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  -- 115.1 28-JAN-2004    sshankar   Removed hr_utility.debug_enabled call--
  --------------------------------------------------------------------------
  --
  PROCEDURE submit_sscwt_report
  IS
     l_request_id   NUMBER ;
     l_procedure    VARCHAR2(200);
     --
  BEGIN
     --

     IF g_debug THEN
        l_procedure := g_package||'submit_sscwt_report';
        hr_utility.set_location('Entering '      ||l_procedure, 10);
        hr_utility.trace('Report Name -> '       || g_report_short_name);
        hr_utility.trace('Business Group ID -> ' || g_business_group_id);
        hr_utility.trace('Financial Year -> '    || g_financial_year);
        hr_utility.trace('Processing Mode -> '   || g_processing_mode);
        hr_utility.trace('Archive ID -> '        || g_archive_pact);
        hr_utility.trace('Payroll ID -> '        || g_payroll_id);
        hr_utility.trace('Assignment Set ID -> ' || g_assignment_set_id);
     END IF;

     --
     -- Submit the SSCWT text report using fnd_request.submit_request
     -- function.
     --
     l_request_id := fnd_request.submit_request
        (APPLICATION => 'PER',
         PROGRAM     =>  g_report_short_name,
         ARGUMENT1   => 'P_BUSINESS_GROUP_ID='||g_business_group_id,
         ARGUMENT2   => 'P_FINANCIAL_YEAR='||to_char(g_financial_year,'YYYY'),
         ARGUMENT3   => 'P_PROCESS_TYPE='||g_processing_mode,
         ARGUMENT4   => 'P_ARCHIVE_PAYROLL_ACTION_ID='||g_archive_pact,
         ARGUMENT5   => 'P_PAYROLL_ID='||g_payroll_id,
         ARGUMENT6   => 'P_ASSIGNMENT_SET_ID='||g_assignment_set_id);

     --
     -- If the request is not submitted, then error out.
     --
     IF l_request_id = 0 THEN
        hr_utility.set_location('Error submitting report', 20);
        hr_utility.raise_error;
     END IF;
     --
     IF g_debug THEN
        hr_utility.set_location('Leaving '||l_procedure,30);
     END IF;
     --
  EXCEPTION
     WHEN OTHERS THEN
        IF g_debug THEN
           hr_utility.set_location('Error in ' ||l_procedure, 40);
        END IF;
        RAISE;

  END submit_sscwt_report;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : UPDATE_SSCWT_RATE                                   --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    : Function to update the details of SSCWT Information --
  --                  element.                                            --
  --                  The funciton uses dt_api to get the updation_mode.  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_sscwt_rate           NUMBER                       --
  -- p_sscwt_element_entry_id pay_element_entries_f.element_entry_id%TYPE --
  --                  p_effective_date       DATE                         --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  -- 115.1 28-JAN-2004    sshankar   Removed hr_utility.debug_enabled call--
  --                                 Removed using l_update_change_insert --
  --                                 as update mode.                      --
  --------------------------------------------------------------------------
  --

  FUNCTION update_sscwt_rate
     (p_sscwt_rate IN NUMBER
     ,p_sscwt_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
     ,p_effective_date IN DATE)
  RETURN BOOLEAN
  IS
     --
     -- Local variables
     --
     l_correction           BOOLEAN;
     l_update               BOOLEAN;
     l_update_override      BOOLEAN;
     l_update_change_insert BOOLEAN;
     l_warning              BOOLEAN;
     l_update_mode          VARCHAR2(30);
     l_procedure            VARCHAR2(100);
     l_effective_start_date DATE;
     l_effective_end_date   DATE;
     --
     l_object_version_number pay_element_entries_f.object_version_number%TYPE;

     --
     CURSOR csr_get_object_version
     IS
     SELECT object_version_number
     FROM   pay_element_entries_f
     WHERE  element_entry_id = p_sscwt_element_entry_id
     AND    p_effective_date between effective_start_date
                                   and effective_end_date;
     --

  BEGIN
     --

     IF g_debug THEN
        l_procedure := g_package || 'update_sscwt_rate';
        hr_utility.set_location('Entering '||l_procedure, 10);
        hr_utility.trace('SSCWT Rate -> '       || p_sscwt_rate);
        hr_utility.trace('Element Entry ID -> ' || p_sscwt_element_entry_id);
     END IF;
     --
     --
     -- Determine the update mode to be used in element entry value updation.
     -- This procedure will set updation mode either to one of these values as true:
     --  Update, Correction, update Override or Update Change Imsert.
     --
     DT_Api.Find_DT_Upd_Modes
        (p_effective_date      => p_effective_date
        ,p_base_table_name     => 'pay_element_entries_f'
        ,p_base_key_column     => 'element_entry_id'
        ,p_base_key_value      => p_sscwt_element_entry_id
        ,p_correction          => l_correction
        ,p_update              => l_update
        ,p_update_override     => l_update_override
        ,p_update_change_insert=> l_update_change_insert);
     --

     IF g_debug THEN
        hr_utility.set_location('After calling DT_Api.Find_DT_Upd_MOdes', 20);
     END IF;
     --
     --
     -- Check which flag has been set by DT_API.Find_DT_Upd_Modes
     -- Correction is always set to true hence check it's value at last as default.
     -- If effective start date is not same as effective date, then
     -- If any future row exists for element, then Update is false and Update override and
     -- Update Change Insert is set to true.
     -- If there are no future row exists then Update mode is used.
     --
     -- No need to use update_change_insert mode as both update_override and update_change_insert
     -- are always set to true or false.
     --
     IF l_update THEN
        l_update_mode := hr_api.g_update;
     ELSIF l_update_override THEN
        l_update_mode := hr_api.g_update_override;
     ELSIF l_correction THEN
        l_update_mode := hr_api.g_correction;
     ELSE
        return FALSE;
     END IF;
     --
     IF g_debug THEN
        hr_utility.set_location('Update Mode -> ' || l_update_mode, 30);
     END IF;
     --
     OPEN csr_get_object_version;
     FETCH csr_get_object_version INTO l_object_version_number;
     CLOSE csr_get_object_version;
     --
     IF g_debug THEN
        hr_utility.set_location('Object Version Number -> ' || l_object_version_number, 40);
     END IF;
     --
     --
     IF g_debug THEN
        hr_utility.set_location('G_Input Value ID -> ' || g_input_value_id, 50);
     END IF;
     --
     pay_element_entry_api.update_element_entry
        (p_datetrack_update_mode  => l_update_mode
        ,p_effective_date         => p_effective_date
        ,p_business_group_id      => g_business_group_id
        ,p_element_entry_id       => p_sscwt_element_entry_id
        ,p_object_version_number  => l_object_version_number
        ,p_input_value_id1        => g_input_value_id
        ,p_entry_value1           => p_sscwt_rate
        ,p_effective_start_date   => l_effective_start_date
        ,p_effective_end_date     => l_effective_end_date
        ,p_update_warning         => l_warning);
     --

     IF g_debug THEN
        hr_utility.set_location('After calling update_element_entry ', 60);
        hr_utility.trace('Effective Start -> '||l_effective_start_date);
        hr_utility.trace('Effective End -> '  ||l_effective_end_date);

     END IF;
     --
     RETURN true;

  EXCEPTION
     WHEN OTHERS THEN
        IF g_debug THEN
           hr_utility.set_location('Error in '|| l_procedure, 70);
        END IF;
        RETURN false;
  END update_sscwt_rate;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_LEGISLATIVE_PARAMETERS                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                              --
  -- Description    : Sets the global variables which will be used by     --
  --                  assignment actions code. Values for global          --
  --                  variables are fetched from  pay_payroll_actions     --
  --                  'Legislative_parameters' column.                    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  -- 115.1 28-JAN-2004    sshankar   Removed hr_utility.debug_enabled call--
  --                                                                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE get_legislative_parameters(p_payroll_action_id IN NUMBER)
  IS
    l_procedure VARCHAR2(100) := null;
    l_financial_year  VARCHAR2(30);
    --
    CURSOR csr_get_parameters(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
    IS
      SELECT pay_core_utils.get_parameter('PAYROLL_ID'
                                          ,legislative_parameters)  payroll_id,
             pay_core_utils.get_parameter('ASSIGNMENT_SET'
                                          ,legislative_parameters)  assignment_set_id,
             pay_core_utils.get_parameter('BUSINESS_GROUP_ID'
                                          ,legislative_parameters)  business_group_id,
             pay_core_utils.get_parameter('FINANCIAL_YEAR'
                                          ,legislative_parameters)  financial_year,
             pay_core_utils.get_parameter('PROCESSING_MODE'
                                          ,legislative_parameters)  processing_mode
      FROM   pay_payroll_actions ppa
      WHERE  ppa.payroll_action_id  =  p_payroll_action_id;


    --
  BEGIN
  --

    IF g_debug THEN
      l_procedure := g_package||'get_legislative_parameters';
      hr_utility.set_location('Entering '||l_procedure, 10);
    END IF;
    --
    -- Set the global variables
    --
    g_archive_pact := p_payroll_action_id;

    OPEN  csr_get_parameters(p_payroll_action_id);
    FETCH csr_get_parameters INTO g_payroll_id
                                , g_assignment_set_id
                                , g_business_group_id
                                , l_financial_year
                                , g_processing_mode;
    CLOSE csr_get_parameters;
    --

    -- Append 'DD-MM-' part to the Year part obtained from legislative parameters
    g_financial_year := TO_DATE(g_start_dd_mm || l_financial_year, 'DD-MM-YYYY') ;

    IF g_debug THEN
       hr_utility.set_location('In '||l_procedure, 20);
       hr_utility.trace('Payroll Action ID -> ' || g_archive_pact);
       hr_utility.trace('G_Financial Year -> '  || g_financial_year);
       hr_utility.trace('L_Financial Year -> '  || l_financial_year);
       hr_utility.trace('Processing Mode -> '   || g_processing_mode);
       hr_utility.trace('Payroll ID -> '        || g_payroll_id);
       hr_utility.trace('Assignment set ID -> ' || g_assignment_set_id);
       hr_utility.trace('Business Group ID -> ' || g_business_group_id);
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
     IF csr_get_parameters%ISOPEN THEN
        CLOSE csr_get_parameters;
     END IF;
     IF g_debug THEN
        hr_utility.set_location('Error in '||l_procedure, 30);
     END IF;
     RAISE;
  END get_legislative_parameters;
  --

  -----------------------------------------------------------------------
  -- End of private function/procedure                                 --
  -----------------------------------------------------------------------


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : PERIODS_IN_SPAN                                     --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function returns the number of periods for which    --
  --                  the payroll is run for a given assignment and given --
  --                  period.                                             --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_start_date           DATE                         --
  --                  p_start_date           DATE                         --
  --            p_assignment_id     per_assignments_f.assignment_id%TYPE  --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  -- 115.1 01-Aug-2004    snekkala   Modified csr_pay_periods as part of  --
  --                                 bug 4259438                          --
  --------------------------------------------------------------------------
  --

  FUNCTION periods_in_span
            ( p_start_date IN DATE
            , p_end_date   IN DATE
            , p_assignment_id IN per_assignments_f.assignment_id%TYPE)
  RETURN NUMBER
  IS
  --
    l_year         NUMBER(4);
    l_start        DATE;
    l_periods      NUMBER;
    l_procedure    VARCHAR2(100);
    --
    CURSOR csr_pay_periods(c_start_date date)
    IS
      SELECT count(*)
        FROM pay_payroll_actions    ppa
	   , per_time_periods       ptp
	   , pay_assignment_actions paa
	   , per_assignments_f      paf
	   , pay_payrolls_f         ppf
       WHERE paa.assignment_id      = paf.assignment_id
         AND paa.payroll_action_id  = ppa.payroll_action_id
         AND ppa.action_type        IN ('R', 'Q')
         AND ptp.time_period_id     = ppa.time_period_id
         AND ppf.payroll_id         = ppa.payroll_id
         AND ppf.payroll_id         = ptp.payroll_id
         AND ppf.payroll_id         = paf.payroll_id
         AND paa.action_status      = 'C'
         AND ppa.action_status      = 'C'
         AND ppa.payroll_id         = ptp.payroll_id
         AND ptp.end_date           BETWEEN c_start_date
                                        AND p_end_date
         AND p_end_date            BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date
         AND p_end_date            BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
         AND paf.assignment_id      = p_assignment_id;
  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    IF g_debug THEN
       l_procedure := g_package||'periods_in_span';
       hr_utility.set_location('Entering '  ||l_procedure, 10);
       hr_utility.trace('Assignment ID -> ' || p_assignment_id);
       hr_utility.trace('Start Date -> '    || p_start_date);
       hr_utility.trace('End Date -> '      || p_end_date);
    END IF;

    -- Get the previous Fiscal year.
    l_year := TO_NUMBER(TO_CHAR(p_end_date,'YYYY'))-1;

    --
    -- If start date is greater than the '01-APR' of the previous Year
    -- then start would be from the p_start_date and not 01-APR of previous year.
    IF p_start_date >= to_date(g_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY')
    THEN
      l_start := p_start_date;
    ELSE
      l_start := TO_DATE(g_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY');
    END IF;
    --
    IF g_debug THEN
       hr_utility.trace('Modified Start Date -> ' || l_start);
    END IF;
    OPEN  csr_pay_periods(l_start);
    FETCH csr_pay_periods INTO l_periods;
    CLOSE csr_pay_periods;
    --
    IF g_debug THEN
       hr_utility.set_location('Periods: ' || l_periods, 30);
    END IF;
    RETURN l_periods;
  --
  EXCEPTION
    WHEN OTHERS THEN
      IF csr_pay_periods%ISOPEN THEN
  	IF g_debug THEN
  	   hr_utility.set_location('Error Closing cursor csr_pay_periods', 40);
  	END IF;
        CLOSE csr_pay_periods;
      END IF;
      IF g_debug THEN
         hr_utility.set_location('Error in periods_in_span', 50);
      END IF;
      RAISE;
  END periods_in_span;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : RANGE_CODE                                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns a sql string to select all   --
  --                  employees who belong to the business group.         --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : p_sql                  VARCHAR2                     --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  --                                                                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE range_code(
                        p_payroll_action_id   IN  NUMBER
                       ,p_sql                 OUT NOCOPY VARCHAR2
                      )
  IS

  --
    l_procedure  VARCHAR2(100) ;
  --
  BEGIN
  --
  --
  -- print the debug messages if debug is enabled.
  --
  g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
       l_procedure := g_package || 'range_code' ;
       hr_utility.set_location('Entering ' || l_procedure,10);
    END IF;
    --
    --  sql string to SELECT a range of assignments eligible for archival.
    --

    p_sql := ' SELECT distinct ppf.person_id'                          ||
             ' FROM   per_people_f ppf'                                ||
             ',pay_payroll_actions ppa'                                ||
             ' WHERE  ppa.payroll_action_id = :payroll_action_id'      ||
             ' AND    ppa.business_group_id =  ppf.business_group_id'  ||
             ' ORDER  BY ppf.person_id';

    IF g_debug THEN
       hr_utility.set_location('Leaving ' || l_procedure,20);
    END IF;

  --
  EXCEPTION
    WHEN OTHERS THEN
      IF g_debug THEN
        hr_utility.set_location('Error in ' || l_procedure,30);
      END IF;

      RAISE;
  --
  END range_code;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_ACTION_CODE                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure further restricts the assignment_ids --
  --                  returned by range_code.                             --
  --                  It filters the assignments selected by range_code   --
  --                  procedure by applying further selection criteria.   --
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
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  --------------------------------------------------------------------------
  --

  PROCEDURE assignment_action_code (
                                     p_payroll_action_id   IN NUMBER
                                    ,p_start_person        IN NUMBER
                                    ,p_end_person          IN NUMBER
                                    ,p_chunk               IN NUMBER
                                   )
  IS


    CURSOR csr_next_action_id
    IS
      SELECT pay_assignment_actions_s.nextval FROM dual;


    CURSOR  csr_get_assignments
    IS
      SELECT DISTINCT assignment.assignment_id
      FROM   per_people_f       person
            ,per_assignments_f  assignment
            ,per_periods_of_service service
            ,pay_element_types_f    element
            ,pay_element_links_f    link
            ,pay_element_entries_f  entry
      WHERE  person.person_id BETWEEN p_start_person
                              AND     p_end_person
      AND    assignment.person_id         = person.person_id
      AND    assignment.business_group_id = person.business_group_id
      AND    service.period_of_service_id = assignment.period_of_service_id
      AND    element.element_name         = 'SSCWT Information'
      AND    element.element_type_id      = link.element_type_id
      AND    entry.element_link_id        = link.element_link_id
      AND    entry.assignment_id          = assignment.assignment_id
      AND    link.business_group_id       = person.business_group_id
      AND    (g_payroll_id is null OR assignment.payroll_id = g_payroll_id)
      AND    hr_assignment_set.assignment_in_set(g_assignment_set_id, assignment.assignment_id) = 'Y'
      AND    g_financial_year    BETWEEN   person.effective_start_date
                                  AND       person.effective_end_date
      AND    g_financial_year    BETWEEN   assignment.effective_start_date
                                  AND       assignment.effective_end_date
      AND    g_financial_year    BETWEEN   element.effective_start_date
                                  AND       element.effective_end_date
      AND    g_financial_year    BETWEEN   link.effective_start_date
                                  AND       link.effective_end_date
      AND    g_financial_year    BETWEEN   entry.effective_start_date
                                  AND       entry.effective_end_date
      AND    g_financial_year    BETWEEN   service.date_start
             AND NVL(service.actual_termination_date, TO_DATE('31-12-4712', 'DD-MM-YYYY')) ;


    --
    l_next_assignment_action_id NUMBER;
    l_procedure                 VARCHAR2(100) ;
    --



  BEGIN
  --
  --
  -- print the debug messages if debug is enabled.
  --
  g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
       l_procedure := g_package || 'assignment_action_code' ;
       hr_utility.set_location('Entering ' || l_procedure,10);
    END IF;

    -- Get the legislative parameters of the concurrent request for archive
    -- and store them in global variables.
    get_legislative_parameters(p_payroll_action_id);

    IF g_debug THEN
       hr_utility.set_location('Opening Cursor csr_get_assignments.',20);
    END IF;

    FOR  csr_record IN csr_get_assignments

    LOOP
    --

      IF g_debug THEN
         hr_utility.set_location('For Assignment id.....:'||csr_record.assignment_id,30);
         hr_utility.set_location('Creating new archive assignment action id',40);
      END IF;

      OPEN   csr_next_action_id ;
      FETCH  csr_next_action_id INTO l_next_assignment_action_id ;
      CLOSE  csr_next_action_id ;

      IF g_debug THEN
         hr_utility.set_location('New archive assignment action id:'||l_next_assignment_action_id,50);
         hr_utility.set_location('Creating the archive assignment action id for the ...:'||csr_record.assignment_id,60);
      END IF;

      -- Insert the new assignment actions



      hr_nonrun_asact.insact(
                             l_next_assignment_action_id
                            ,csr_record.assignment_id
                            ,p_payroll_action_id
                            ,p_chunk
                            ,null
                            );



    END LOOP;
    IF g_debug THEN
       hr_utility.set_location('Leaving ' || l_procedure,70);
    END IF;


    EXCEPTION
      WHEN OTHERS THEN
        IF g_debug THEN
           hr_utility.trace('Error occured in '||l_procedure);
        END IF;

        IF csr_get_assignments%ISOPEN THEN
        --
          CLOSE csr_get_assignments;
        --
        END IF;

        RAISE;

  END assignment_action_code ;



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : INITIALIZATION_CODE                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to set global contexts.      --
  --                  It stores defined balance IDs and element IDs and   --
  --                  Element Input value Ids into global variables.      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar  Initial Version                       --
  -- 115.1 22-JAN-2004    sshankar  Modified csr_defined_balances to      --
  --                                include all three balances at once    --
  --                                instead of calling it thrice.         --
  -- 115.2 31-MAY-2004    sshankar  Changed cursor csr_defined_balances   --
  --                                so as not to include balance 'Employer--
  --                                Specified Superannuation              --
  --                                Contributions'. (Bug 3609069)         --
  -- 115.10 12-Apr-2007   dduvvuri  Changed cursor csr_defined_balances   --
  --				    so as to include "KiwiSaver Employer  --
  --				    Contributions" balance		  --
  -- 115.11 02-Feb-2009   dduvvuri  7668520 - Changed cursor csr_defined_balances   --
  --                                so as to include "Employer Specified  --
  --                                Superannuation Cont" balance          --
  --------------------------------------------------------------------------
  --

  PROCEDURE initialization_code (
                                  p_payroll_action_id  IN NUMBER
                                )
  IS
  --
    l_procedure           VARCHAR2(100) ;
    l_balance_name        pay_balance_types.balance_name%TYPE;
    l_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;
  --

  --
  -- Cursor to fetch element type id and input value id for 'SSCWT Information' element
  -- which are later used to fetch input value of the element for corresponding assignments.
  --
    CURSOR csr_get_element_ids(c_financial_year DATE)
    IS
      SELECT pet.element_type_id, piv.input_value_id
      FROM   pay_element_types_f pet
            ,pay_input_values_f  piv
      WHERE  pet.element_name    = 'SSCWT Information'
      AND    pet.element_type_id = piv.element_type_id
      AND    piv.name            = 'SSCWT Rate'
      AND    c_financial_year   BETWEEN pet.effective_start_date
                                AND     pet.effective_end_date
      AND    c_financial_year   BETWEEN piv.effective_start_date
                                AND     piv.effective_end_date ;
  --

  --
  -- Modified the cursor to have all three balances name and Dimension so as to
  -- avoid executing it thrice for three balances.
  --
  -- Cursor to fetch defined Balance ID
  --

  --
  -- Bug 3609069
  -- Removed Balance 'Employer Specified Superannuation Contributions'
  --
  -- Bug 5846247
  -- Added Balance 'KiwiSaver Employer Contributions'

    CURSOR csr_defined_balances
    IS
      SELECT defined.defined_balance_id
            ,bal.balance_name balance_name
      FROM   pay_balance_types bal
           , pay_balance_dimensions dim
           , pay_defined_balances defined
      WHERE  bal.legislation_code     = g_legislation_code
      AND    bal.balance_name         IN ( 'Ordinary Taxable Earnings'
                                          ,'Extra Emolument Taxable Earnings'
					  ,'KiwiSaver Employer Contributions'
					  ,'Employer Specified Superannuation Contributions'  /* Added for bug 7668520 */
                                         )
      AND    dim.legislation_code     = g_legislation_code
      AND    dim.dimension_name       = '_ASG_YTD'
      AND    bal.balance_type_id      = defined.balance_type_id
      AND    dim.balance_dimension_id = defined.balance_dimension_id;
  --

  BEGIN
  --
  --
  -- print the debug messages if debug is enabled.
  --
  g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
       l_procedure := g_package || 'initialization_code'  ;
       hr_utility.set_location('Entering ' || l_procedure,10);
    END IF;

    -- Get the legislative parameters and store them in global variables.
    get_legislative_parameters(p_payroll_action_id);

    IF g_debug THEN
       hr_utility.set_location('p_payroll_action_id -> ' || p_payroll_action_id, 15);
    END IF;

    -- Fetch element_type_id and input_value_id into global variables.
    OPEN  csr_get_element_ids(g_financial_year) ;
    FETCH csr_get_element_ids INTO g_element_type_id, g_input_value_id ;
    CLOSE csr_get_element_ids ;

    IF g_debug THEN
       hr_utility.set_location('g_element_type_id -> ' ||g_element_type_id ,20);
       hr_utility.set_location('g_input_value_id  -> ' ||g_input_value_id ,30);
    END IF;

    --
    -- Modified the cursor to have all three balances name and Dimension so as to
    -- avoid executing it thrice for three balances.
    --
    -- Fetch Balance IDs into global variables.

    FOR csr_bal_rec IN csr_defined_balances
    LOOP
      IF csr_bal_rec.balance_name = 'Ordinary Taxable Earnings' THEN
         g_def_balance_tab(1).defined_balance_id := csr_bal_rec.defined_balance_id;

      -- Bug 3609069
      -- Removed code to handle balance 'Employer Specified Superannuation Contributions'
      --

      ELSIF csr_bal_rec.balance_name = 'Extra Emolument Taxable Earnings' THEN
         g_def_balance_tab(2).defined_balance_id := csr_bal_rec.defined_balance_id;

      -- Bug 5846247
      -- Added Balance 'KiwiSaver Employer Contributions'
      ELSIF csr_bal_rec.balance_name = 'KiwiSaver Employer Contributions' THEN
         g_def_balance_tab(3).defined_balance_id := csr_bal_rec.defined_balance_id;
       -- Bug 7668520
       -- Added Balance 'Employer Specified Superannuation Contributions'
       ELSIF csr_bal_rec.balance_name = 'Employer Specified Superannuation Contributions' THEN
         g_def_balance_tab(4).defined_balance_id := csr_bal_rec.defined_balance_id;

      END IF;
      IF g_debug THEN
         hr_utility.set_location('Balance Name -> ' || csr_bal_rec.balance_name,40);
         hr_utility.set_location('Defined Balance ID -> ' ||csr_bal_rec.defined_balance_id ,50);
      END IF;

    END LOOP;

    IF g_debug THEN
       hr_utility.set_location('Leaving ' || l_procedure,60);
    END IF;

  --
  EXCEPTION
    WHEN OTHERS THEN

      IF csr_get_element_ids%ISOPEN THEN
      --
        CLOSE csr_get_element_ids;
      --
      END IF;

      IF csr_defined_balances%ISOPEN THEN
      --
        CLOSE csr_defined_balances;
      --
      END IF;

      IF g_debug THEN
         hr_utility.set_location('Error in ' || l_procedure,30);
      END IF;

      RAISE;
  --
  END initialization_code;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : ARCHIVE_CODE                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to archive the details of an employees    --
--                  SSCWT Rates.                                        --
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
-- 115.0 22-JAN-2004    sshankar  Initial Version                       --
-- 115.1 28-JAN-2004    sshankar  Modified cursor csr_assignment_action --
--                                to handle cases where Balance         --
--                                adjustment is also run.               --
-- 115.2 31-MAY-2004    sshankar  Changed code so as not to include     --
--                                SSCWT contributions for last year     --
--                                while calculating last year earnings. --
--                                (Bug 3609069)                         --
-- 115.8 01-MAR-2007    dduvvuri  Changed  g_def_balance_tab(3).balance_value --
--                                to g_def_balance_tab(2).balance_value --
-- 115.9 02-MAR-2007    dduvvuri  Added Bug Reference,Fix Description at --
--                                place of change in the previous version --
-- 115.10 12-Apr-2007   dduvvuri  Added KiwiSaver Employer Contributions to the
--				  Yearly Earnings.
-- 115.11 02-feb-2009   dduvvuri  7668520 - Added Employer Specified Superannuation
--                                Cont to the Yearly Earnings
--------------------------------------------------------------------------
--

PROCEDURE archive_code(p_assignment_action_id  IN NUMBER
                      ,p_effective_date        IN DATE)
IS
--
-- Local Variables
--
  l_next_assignment_action_id NUMBER;
  l_procedure                 VARCHAR2(100);
  l_flag                      BOOLEAN;

  l_yearly_value              NUMBER ;
  l_action_info_id            NUMBER ;
  l_ovn                       NUMBER ;

  l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
  l_assignment_id             per_assignments_f.assignment_id%TYPE;
  l_sscwt_new_rate            NUMBER;
  l_sscwt_old_rate            NUMBER;
  l_periods                   NUMBER;
  l_total_periods             NUMBER;
  l_employee_full_name        per_people_f.full_name%TYPE;
  l_assignment_number         per_assignments_f.assignment_number%TYPE;
  l_element_entry_id          pay_element_entries_f.element_entry_id%TYPE;
--
-- Cursor Declarations
--
  CURSOR csr_employees
   (c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE
   ,c_business_group_id per_people_f.business_group_id%TYPE)
  IS
    SELECT person.full_name
          ,assignment.assignment_number
          ,assignment.assignment_id
          ,periods_in_span(service.date_start, g_financial_year
                        , assignment.assignment_id) periods
          ,period_types.number_per_fiscal_year total_periods
    FROM   per_people_f person,
           per_assignments_f assignment,
           per_periods_of_service service,
           pay_payrolls_f payroll,
           per_time_period_types period_types,
           pay_assignment_actions actions
    WHERE  person.business_group_id     = c_business_group_id
    AND    actions.assignment_action_id = c_assignment_action_id
    AND    assignment.assignment_id     = actions.assignment_id
    AND    assignment.person_id         = person.person_id
    AND    assignment.business_group_id = person.business_group_id
    AND    service.period_of_service_id = assignment.period_of_service_id
    AND    payroll.business_group_id    = person.business_group_id
    AND    payroll.payroll_id       = assignment.payroll_id
    AND    period_types.period_type = payroll.period_type
    AND    g_financial_year BETWEEN person.effective_start_date
                            AND     person.effective_end_date
    AND    g_financial_year BETWEEN assignment.effective_start_date
                            AND     assignment.effective_end_date
    AND    g_financial_year BETWEEN payroll.effective_start_date
                            AND     payroll.effective_end_date
    AND    g_financial_year BETWEEN service.date_start
           AND NVL(service.actual_termination_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'));

  --
  CURSOR csr_assignment_action(c_financial_year DATE
                              ,c_assignment_id per_assignments_f.assignment_id%TYPE
                              )
  IS
    SELECT max_asg_act.assignment_action_id
    FROM   pay_assignment_actions max_asg_act
    WHERE  max_asg_act.assignment_id = c_assignment_id
    AND    max_asg_act.action_sequence = (
           SELECT max(asg_action.action_sequence) action_sequence
           FROM   pay_assignment_actions asg_action,
                  pay_payroll_actions    pay_action
           WHERE  asg_action.assignment_id = c_assignment_id
           AND    asg_action.payroll_action_id = pay_action.payroll_action_id
           AND    asg_action.action_status = 'C'
           AND    pay_action.action_status = 'C'
           AND    pay_action.action_type in ('R', 'Q', 'B')
           AND    pay_action.effective_date  BETWEEN add_months(c_financial_year,-12)
                                             AND     c_financial_year-1);
  --
  CURSOR csr_get_old_sscwt_rate
   (c_input_value_id  pay_input_values_f.input_value_id%TYPE
   ,c_element_type_id pay_input_values_f.element_type_id%TYPE
   ,c_assignment_id   per_assignments_f.assignment_id%TYPE )
  IS
    SELECT DECODE(inputv.hot_default_flag,'Y'
          ,NVL(entry_value.screen_entry_value, NVL(link.default_value
          ,inputv.default_value)),'N',entry_value.screen_entry_value) value
          ,entry.element_entry_id element_entry_id
    FROM   pay_element_entry_values_f entry_value,
           pay_element_entries_f entry,
           pay_link_input_values_f link,
           pay_input_values_f inputv
    WHERE  inputv.input_value_id = c_input_value_id
    AND    g_financial_year between inputv.effective_start_date
                               and inputv.effective_end_date
    AND    inputv.element_type_id + 0 = c_element_type_id
    AND    link.input_value_id = inputv.input_value_id
    AND    g_financial_year between link.effective_start_date
                                and link.effective_end_date
    AND    entry_value.input_value_id + 0 = inputv.input_value_id
    AND    entry_value.element_entry_id = entry.element_entry_id
    AND    entry_value.effective_start_date = entry.effective_start_date
    AND    entry_value.effective_end_date = entry.effective_end_date
    AND    entry.element_link_id = link.element_link_id
    AND    entry.assignment_id = c_assignment_id
    AND    g_financial_year between entry.effective_start_date
                                and entry.effective_end_date
    AND    NVL(entry.entry_type, 'E') = 'E';
  --

BEGIN
  --
  -- print the debug messages if debug is enabled.
  --
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
     l_procedure := g_package||'archive_code';
     hr_utility.set_location('Entering '||l_procedure, 10);
     hr_utility.trace('Assignment Action ID-> ' || p_assignment_action_id);
     hr_utility.trace('Effective Date-> '       || p_effective_date);
  END IF;

  --
  -- Fetch employee details like name, assignment number, number of periods
  -- for which the payroll is run and total number of pay periods in that
  -- financial year.
  --
  OPEN  csr_employees(p_assignment_action_id, g_business_group_id);
  FETCH csr_employees INTO l_employee_full_name
                         , l_assignment_number
                         , l_assignment_id
                         , l_periods
                         , l_total_periods;
  CLOSE csr_employees;
  --
  IF g_debug THEN
     hr_utility.set_location('In '||l_procedure, 20);
     hr_utility.trace('Employee Full Name -> ' || l_employee_full_name);
     hr_utility.trace('Assignment Number -> '  || l_assignment_number);
     hr_utility.trace('Assignment ID -> '      || l_assignment_id);
     hr_utility.trace('Periods -> '            || l_periods);
     hr_utility.trace('Total Periods -> '      || l_total_periods);
  END IF;

  --
  IF l_periods = 0 THEN
     --
     IF g_debug THEN
        hr_utility.set_location('Before creating action Information' || l_procedure, 30);
     END IF;
     --

     pay_action_information_api.create_action_information
     (
       p_action_information_id       => l_action_info_id,
       p_object_version_number       => l_ovn,
       p_action_context_id           => p_assignment_action_id,
       p_action_context_type         => 'AAP',
       p_action_information_category => 'NZ SSCWT DETAILS',
       p_effective_date              => g_financial_year,
       p_assignment_id               => l_assignment_id,
       p_action_information1         => l_assignment_number,
       p_action_information2         => l_employee_full_name,
       p_action_information3         => null,
       p_action_information4         => null,
       p_action_information5         => null,
       p_action_information6         => 'FAILURE'
     );

     return;
   END IF;
   --
   -- Archive the details of the employee. The steps are:-
   -- 1. Get the lastest assignment action id.
   -- 2. Use a local copy of defined_balance_lst table so the data is
   --    consistent across mutliple threads.
   -- 3. Calculate the balance value
   -- 4. Calculate the Yearly Value
   -- 5. Calculate the New SSCWT Rate
   -- 6. Fetch the value of the current SSCWT Rate using route code.
   -- 7. Archive the details if the Rate is to be changed.
   --

   -- 1. Get the lastest assignment action id.
   --
   OPEN  csr_assignment_action(g_financial_year, l_assignment_id);
   FETCH csr_assignment_action INTO l_assignment_action_id;
   CLOSE csr_assignment_action;
   --
   IF g_debug THEN
     hr_utility.set_location('l_assignment_action_id -> '||l_assignment_action_id, 40);
     hr_utility.set_location('Before calling procedure pay_balance_pkg.get_value', 50);
   END IF;

   -- 3. Calculate the YTD balance values for the required balances.
   --

   pay_balance_pkg.get_value
      (p_assignment_action_id => l_assignment_action_id
      ,p_defined_balance_lst  => g_def_balance_tab
      );

   --
   IF g_debug THEN
      hr_utility.set_location('In '||l_procedure, 60);
      hr_utility.trace('Ordinary Taxable Earnings -> ' || g_def_balance_tab(1).balance_value);

      /* Change for Bug 5904043 start*/
      -- Changed g_def_balance_tab(3).balance_value to g_def_balance_tab(2).balance_value
      hr_utility.trace('Extra Emoluments Taxable Earanings -> ' || g_def_balance_tab(2).balance_value);
      /* Change for Bug 5904043 end*/
      /* Change for Bug 5846247 */
      hr_utility.trace('KiwiSaver Employer Contributions -> ' || g_def_balance_tab(3).balance_value);
      /* Added below condition for bug 7668520 */
      if g_financial_year >= TO_DATE(g_start_dd_mm ||'2009', 'DD-MM-YYYY') then
           hr_utility.trace('Employer Specified Superannuation Contributions -> ' || g_def_balance_tab(4).balance_value);
      end if;
   END IF;

   -- 4. Calculate the Yearly Value
   --

   -- Bug 3609069
   -- Removed code which includes SSCWT contributions for last year
   -- Bug 5846247
   -- Added "KiwiSaver Employer Contributions" to Yearly Value.
   l_yearly_value := g_def_balance_tab(1).balance_value -- Ordinary Ear
                   + g_def_balance_tab(2).balance_value -- Extra Emol Ear
		   + g_def_balance_tab(3).balance_value; -- KiwiSaver Employer Contributions
    /* Added below condition for bug 7668520 */
    if g_financial_year >= TO_DATE(g_start_dd_mm || '2009', 'DD-MM-YYYY') then
           l_yearly_value := l_yearly_value + g_def_balance_tab(4).balance_value;
    end if;
   --
   -- Req: Employee's who have commenced during the previous financial year
   --      must have their earnings converted to a yearly figure to ensure
   --      a correct rate of calculation.
   --
   l_yearly_value := (l_yearly_value / l_periods) * l_total_periods;
   IF g_debug THEN
      hr_utility.set_location('l_yearly_value ->' ||l_yearly_value, 70);
   END IF;

   --
   -- 5. Calculate the New SSCWT Rate

   l_sscwt_new_rate := hruserdt.get_table_value
                           (g_business_group_id
                           ,'NZ SSCWT Rate Ranges'
                           ,'SSCWT Rate'
                           ,trunc(l_yearly_value, 2)
                           ,g_financial_year);

   -- 6. Fetch the current value of SSCWT Rate using route code.
   --
   OPEN  csr_get_old_sscwt_rate(g_input_value_id
                        ,g_element_type_id
                        ,l_assignment_id);
   FETCH csr_get_old_sscwt_rate into l_sscwt_old_rate, l_element_entry_id;
   CLOSE csr_get_old_sscwt_rate;
   --
   IF g_debug = true THEN
      hr_utility.set_location('In '|| l_procedure,80);
      hr_utility.trace('Old SSCWT Rate -> ' || l_sscwt_old_rate);
      hr_utility.trace('New SSCWT Rate -> ' || l_sscwt_new_rate);
      hr_utility.trace('Yearly Value -> '   || l_yearly_value);
   END IF;

   --
   -- 7. Archive the details if the Rate is to be changed.
   --
   IF l_sscwt_old_rate <> l_sscwt_new_rate THEN
   --
      IF g_processing_mode = 'A' THEN
      --
        IF g_debug THEN
           hr_utility.set_location('Processing Automatic mode in '||l_procedure, 90);
        END IF;
        --
        -- 1. Update the SSCWT Rate in SSCWT Information element.
        --
        l_flag := update_sscwt_rate(p_sscwt_rate => l_sscwt_new_rate
                                   ,p_sscwt_element_entry_id => l_element_entry_id
                                   ,p_effective_date => g_financial_year);
        --
        IF l_flag = true THEN
           IF g_debug THEN
              hr_utility.set_location('On successful update of element entry value', 100);
           END IF;

           pay_action_information_api.create_action_information
           (
             p_action_information_id       => l_action_info_id,
             p_object_version_number       => l_ovn,
             p_action_context_id           => p_assignment_action_id,
             p_action_context_type         => 'AAP',
             p_action_information_category => 'NZ SSCWT DETAILS',
             p_effective_date              => g_financial_year,
             p_assignment_id               => l_assignment_id,
             p_action_information1         => l_assignment_number,
             p_action_information2         => l_employee_full_name,
             p_action_information3         => l_sscwt_old_rate,
             p_action_information4         => l_sscwt_new_rate,
             p_action_information5         => l_yearly_value,
             p_action_information6         => 'AUTOMATIC'
           );

        ELSE --if updation failed.
           IF g_debug THEN
              hr_utility.set_location('On failure of update of element entry value', 110);
           END IF;

	   pay_action_information_api.create_action_information
           (
             p_action_information_id       => l_action_info_id,
             p_object_version_number       => l_ovn,
             p_action_context_id           => p_assignment_action_id,
             p_action_context_type         => 'AAP',
             p_action_information_category => 'NZ SSCWT DETAILS',
             p_effective_date              => g_financial_year,
             p_assignment_id               => l_assignment_id,
             p_action_information1         => l_assignment_number,
             p_action_information2         => l_employee_full_name,
             p_action_information3         => l_sscwt_old_rate,
             p_action_information4         => l_sscwt_new_rate,
             p_action_information5         => l_yearly_value,
             p_action_information6         => 'FAILURE'
           );

        END IF; --l_flag is true

      ELSE --If processing mode is manual
         IF g_debug THEN
            hr_utility.set_location('Processing Manual Mode', 110);
         END IF;

         pay_action_information_api.create_action_information
         (
           p_action_information_id       => l_action_info_id,
           p_object_version_number       => l_ovn,
           p_action_context_id           => p_assignment_action_id,
           p_action_context_type         => 'AAP',
           p_action_information_category => 'NZ SSCWT DETAILS',
           p_effective_date              => g_financial_year,
           p_assignment_id               => l_assignment_id,
           p_action_information1         => l_assignment_number,
           p_action_information2         => l_employee_full_name,
           p_action_information3         => l_sscwt_old_rate,
           p_action_information4         => l_sscwt_new_rate,
           p_action_information5         => l_yearly_value,
           p_action_information6         => 'MANUAL'
         );

      END IF; --l_processing mode is automatic
     --
     IF g_debug THEN
        hr_utility.set_location('After Creating action Information in Maual mode', 120);
     END IF;
     --
   END IF; -- old sscwt rate not equal to new sscwt rate

  IF g_debug THEN
     hr_utility.set_location('Leaving ' ||l_procedure, 130);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF csr_assignment_action%ISOPEN THEN
        IF g_debug THEN
          hr_utility.set_location('Error: Closing cursor csr_assignment_action', 140);
        END IF;
        CLOSE csr_assignment_action;
      END IF;
      IF csr_get_old_sscwt_rate%ISOPEN THEN
        IF g_debug THEN
           hr_utility.set_location('Error: Closing cursor csr_sscwt_route', 140);
        END IF;
        CLOSE csr_get_old_sscwt_rate;
      END IF;
      IF csr_employees%ISOPEN THEN
        IF g_debug THEN
           hr_utility.set_location('Error: Closing cursor csr_employees', 140);
        END IF;
        CLOSE csr_employees;
      END IF;
      IF g_debug THEN
         hr_utility.set_location('Error: In archive_code', 150);
      END IF;
      RAISE;
END archive_code;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : DEINITIALIZE_CODE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to submit request for running report,     --
--                  SSCWT Report.                                       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_payroll_action_id          NUMBER                 --
--                                                                      --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 22-JAN-2004    sshankar  Initial Version                       --
-- 115.1 22-JAN-2004    sshankar  Added hr_utility.debug_enabled call to--
--                                initialize g_debug variable.          --
--------------------------------------------------------------------------
--
PROCEDURE deinitialize_code (p_payroll_action_id IN NUMBER)
IS

   l_procedure         VARCHAR2(100);
--
BEGIN
  --
  -- print the debug messages if debug is enabled.
  --
   g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
     l_procedure := g_package || 'deinitialize_code' ;
     hr_utility.set_location('Entering '||l_procedure,10);
   END IF;

   get_legislative_parameters(p_payroll_action_id);

   IF g_debug THEN
     hr_utility.set_location('After Calling get_legislative_parameters',20);
   END IF;

   -- Call procedure to submit request for report.
   submit_sscwt_report;

   IF g_debug THEN
   hr_utility.set_location('Leaving '||l_procedure,30);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF g_debug THEN
         hr_utility.set_location('Error in '||l_procedure,40);
      END IF;
      RAISE;

END deinitialize_code;

--
-- Assign Global variables in this unnamed block. This is to avoid assigning global variables within procedures
-- for each thread that executes the procedure.
--
Begin
  g_debug             := hr_utility.debug_enabled ;
  g_package           := 'pay_nz_sscwt_rate_archive.' ;
  g_start_dd_mm       := '01-04-' ;
  g_legislation_code  := 'NZ' ;
  g_report_short_name := 'PYNZSSRP' ;
  g_element_type_id   := null ;
  g_input_value_id    := null ;
--
END pay_nz_sscwt_rate_archive;

/
