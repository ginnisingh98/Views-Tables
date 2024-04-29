--------------------------------------------------------
--  DDL for Package Body PAY_FR_SICK_PAY_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_SICK_PAY_PROCESSING" AS
  /* $Header: pyfrsppr.pkb 120.1 2005/08/29 07:42:08 ayegappa noship $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Constants identifying the processing mode.
  --
  -- cs_PROCESS        - Currently trying to process each guarantee.
  -- cs_FINAL_PROCESS  - Processing to completion the best guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  cs_PROCESS                 CONSTANT NUMBER := 10;
  cs_FINAL_PROCESS           CONSTANT NUMBER := 20;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  cs_MARGIN           CONSTANT NUMBER := 1;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Global variables
  --
  -- g_ctl                    - Holds control information used to manage the processing.
  -- g_rules                  - Enumerated set of rules covering all possible types of
  --                            guarantee.
  -- g_iter_rules             - Enumerated set of rules identifying which elements are
  --                            relevant to be processed on a particular iteration for each
  --                            type of guarantee.
  -- g_asg                    - Holds information on the current assignment being processed.
  -- g_absence                - Holds information on the current absence being processed.
  -- g_coverages              - Holds information on all the guarantees that cover the
  --                            absence being processed.
  -- g_guarantee_type_lookups - Holds a mapping between between the internal reference
  --                            for each type of guarantee (numeric) and a corresponding
  --                            lookup code for external use.
  --
  -- NB. the blank versions are used when the corresponding global variable needs to
  --     be cleared out.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  g_ctl                    t_ctl;
  g_asg                    t_asg;
  g_absence                t_absence_arch;
  g_rules                  t_rules;
  g_iter_rules             t_iter_rules;
  g_coverages              t_coverages;
  g_guarantee_type_lookups t_guarantee_type_lookups;
  --
  blank_ctl                t_ctl;
  blank_absence            t_absence_arch;
  blank_coverages          t_coverages;
  l_mode                   VARCHAR2(1);
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Defines the processing rules for each type of guarantee. Broken down into basic
  -- rules dictating their overall processing and further iteration rules which identify
  -- which elements need to be processed on each iteration for that guarantee -
  --
  -- Basic Rules (g_rules):
  --
  -- stop   - Iteration on which to stop the processing.
  -- repeat - Iteration from which to start repeating the processing. This is used to
  --          control access to the iteration rules e.g. an value of 3 means the
  --          following -
  --
  --          Iteration     : 1 2 3 4 5 6 7 etc...
  --          Iteration Rule: 1 2 3 3 3 3 3 etc...
  --
  --          The overall affect is to use the third iteration rule for all processing
  --          of the guarantee once the actual iteration has reached 3.
  --
  -- Iteration Rules (g_iter_rules):
  --
  -- ijss_payment    - Y/N flag indicating inclusion of the ijss payment.
  -- deduct_for_sick - Y/N flag indicating inclusion of the deduction for sickness.
  -- gi_payment      - Y/N flag indicating inclusion of the guaranteed income payment.
  -- sick_adj        - Y/N flag indicating that an adjsutment is required (net to
  --                   gross processing).
  -- sick_ins        - Y/N flag indicating inclusion of the third party insurance payment.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE initialise_processing_rules IS
  BEGIN

   hr_utility.set_location('initialise_processing_rules ',10);
    --
    --
    -- Garantie au net processing rules.
    --
    g_rules(cs_GN).repeat := 1;
    g_rules(cs_GN).stop   := NULL;
    --
    g_iter_rules(cs_GN + 1).ijss_payment    := 'Y';
    g_iter_rules(cs_GN + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_GN + 1).gi_payment      := 'N';
    g_iter_rules(cs_GN + 1).sick_adj        := 'Y';
    g_iter_rules(cs_GN + 1).gi_adj          := 'N';
    g_iter_rules(cs_GN + 1).gross_ijss_adj  := 'N';

    --
    --
    -- Legal processing rules.
    --
    g_rules(cs_LE).repeat := NULL;
    g_rules(cs_LE).stop   := 2;
    --
    g_iter_rules(cs_LE + 1).ijss_payment    := 'Y';
    g_iter_rules(cs_LE + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_LE + 1).gi_payment      := 'Y';
    g_iter_rules(cs_LE + 1).sick_adj        := 'N';
    g_iter_rules(cs_LE + 1).gi_adj          := 'N';
    g_iter_rules(cs_LE + 1).gross_ijss_adj  := 'N';

    --
    --
    -- Collectively agreed gross with adjustment processing rules.
    --
    g_rules(cs_CA_G_ADJ).repeat := 2;
    g_rules(cs_CA_G_ADJ).stop   := NULL;
    --
    g_iter_rules(cs_CA_G_ADJ + 1).ijss_payment    := 'N';
    g_iter_rules(cs_CA_G_ADJ + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_CA_G_ADJ + 1).gi_payment      := 'Y';
    g_iter_rules(cs_CA_G_ADJ + 1).sick_adj        := 'N';
    g_iter_rules(cs_CA_G_ADJ + 1).gi_adj          := 'N';
    g_iter_rules(cs_CA_G_ADJ + 1).gross_ijss_adj  := 'N';

    --
    g_iter_rules(cs_CA_G_ADJ + 2).ijss_payment    := 'Y';
    g_iter_rules(cs_CA_G_ADJ + 2).deduct_for_sick := 'Y';
    g_iter_rules(cs_CA_G_ADJ + 2).gi_payment      := 'Y';
    g_iter_rules(cs_CA_G_ADJ + 2).sick_adj        := 'Y';
    g_iter_rules(cs_CA_G_ADJ + 2).gi_adj          := 'N';
    g_iter_rules(cs_CA_G_ADJ + 2).gross_ijss_adj  := 'N';

    --
    --
    -- Collectively agreed gross without adjustment processing rules.
    --
    g_rules(cs_CA_G_NOADJ).repeat := NULL;
    g_rules(cs_CA_G_NOADJ).stop   := 2;
    --
    g_iter_rules(cs_CA_G_NOADJ + 1).ijss_payment    := 'Y';
    g_iter_rules(cs_CA_G_NOADJ + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_CA_G_NOADJ + 1).gi_payment      := 'Y';
    g_iter_rules(cs_CA_G_NOADJ + 1).sick_adj        := 'N';
    g_iter_rules(cs_CA_G_NOADJ + 1).gi_adj          := 'N';
    g_iter_rules(cs_CA_G_NOADJ + 1).gross_ijss_adj  := 'N';

    --
    --
    -- Collectively agreed net processing rules.
    --
    g_rules(cs_CA_N).repeat := 1;
    g_rules(cs_CA_N).stop   := NULL;
    --
    g_iter_rules(cs_CA_N + 1).ijss_payment    := 'Y';
    g_iter_rules(cs_CA_N + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_CA_N + 1).gi_payment      := 'N';
    g_iter_rules(cs_CA_N + 1).sick_adj        := 'Y';
    g_iter_rules(cs_CA_N + 1).gi_adj          := 'N';
    g_iter_rules(cs_CA_N + 1).gross_ijss_adj  := 'N';

    --
    --
    -- No guarantee processing rules.
    --
    g_rules(cs_NO_G).repeat := NULL;
    g_rules(cs_NO_G).stop   := 2;
    --
    g_iter_rules(cs_NO_G + 1).ijss_payment    := 'Y';
    g_iter_rules(cs_NO_G + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_NO_G + 1).gi_payment      := 'N';
    g_iter_rules(cs_NO_G + 1).sick_adj        := 'N';
    g_iter_rules(cs_NO_G + 1).gi_adj          := 'N';
    g_iter_rules(cs_NO_G + 1).gross_ijss_adj  := 'N';


    --
    -- Final Run Processing Rules
    --
    g_rules(cs_FINAL).repeat := NULL;
    g_rules(cs_FINAL).stop   := 2;
    --

    g_iter_rules(cs_FINAL + 1).ijss_payment    := 'Y';
    g_iter_rules(cs_FINAL + 1).deduct_for_sick := 'Y';
    g_iter_rules(cs_FINAL + 1).gi_payment      := 'Y';
    g_iter_rules(cs_FINAL + 1).sick_adj        := 'Y';
    g_iter_rules(cs_FINAL + 1).gi_adj          := 'Y';
    g_iter_rules(cs_FINAL + 1).gross_ijss_adj  := 'Y';
    --
hr_utility.set_location('initialise_processing_rules ',100);

  END initialise_processing_rules;
  --
  --
  -- Defines the mapping between the interanl reference to each type of guarantee (numeric)
  -- to a corresponding LOOKUP_CODE within the LOOKUP_TYPE of FR_GI_TYPES.
  --
  PROCEDURE initialise_guarantee_lookups IS
  BEGIN
  hr_utility.set_location('initialise_guarantee_lookup ',10);
    g_guarantee_type_lookups(cs_GN)         := 'GN';
    g_guarantee_type_lookups(cs_LE)         := 'LE';
    g_guarantee_type_lookups(cs_CA_G_ADJ)   := 'CA_G_ADJ';
    g_guarantee_type_lookups(cs_CA_G_NOADJ) := 'CA_G_NOADJ';
    g_guarantee_type_lookups(cs_CA_N)       := 'CA_N';
    g_guarantee_type_lookups(cs_NO_G)       := 'NO_G';

   hr_utility.set_location('initialise_guarantee_lookup ',100);
  END initialise_guarantee_lookups;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Placeholder for the external procedure.It is used to initialise the various data

  -- Structures required to process an absence. The following values are populated
  -- prior to calling this -
  --
  -- p_mode   - Initialise Value or  Compare and indicate the best one
  --
  -- g_asg:
  --
  -- assignment_id - The assignment being processed.
  -- base_net      - The net pay the employee would receive this period (independent of
  --                 any sickness absences).
  --
  -- g_absence:
  --
  -- element_entry_id - The sickness element entry being processed
  -- date_earned      - The processing date.
  -- ID               - The ID of the absence linked to the element entry.
  --
  -- The following values are populated by the call -
  --
  -- g_absence:
  --
  -- sick_deduction   - Deduction for sickness (gross)
  -- ijss_estimated   - Y/N flag identifying if the above payment details were estimated
  --                    or based on a notification from CPAM.
  -- sick_ins_gross   - Third party insurance payment information.
  -- sick_ins_net     - Third party insurance payment information.
  -- sick_ins_payment - Third party insurance payment information.
  --
  -- NB. The actual values that are set will vary based on the particular absence.
  --
  -- g_coverages:
  --
  -- g_type       - Type of guarantee.
  -- cagr_id      - Collective agreement from which the guarantee was granted.
  -- gi_payment   - Guaranteed income payment.
  -- net          - Net to be paid to the employee.
  -- ijss_gross       - IJSS payment information.
  -- ijss_net         - IJSS payment information.
  -- ijss_payment     - IJSS payment information.
  --                guaranteed income.
  -- band1        - Number of days drawn from band 1 compensation that were involved in
  --                the calculation of the guaranteed income.
  -- band2        - As above.
  -- band3        - As above.
  -- band4        - As above.
  -- best_method  'Y' or 'N' Flag to identify Final run and Pointing Best Method
  -- NB. This is actually a list of all the guarantees that cover the absence. The actual
  --     values will vary based on the type of guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

  PROCEDURE external_procedure
  (p_mode      IN OUT NOCOPY VARCHAR2
  ,p_asg       IN OUT NOCOPY t_asg
  ,p_absence   IN OUT NOCOPY t_absence_arch
  ,p_coverages IN OUT NOCOPY t_coverages) IS
  BEGIN

  hr_utility.set_location('External Procedure ',10);
  pay_fr_sickness_calc.CALC_SICKNESS(p_mode,p_asg,p_absence,p_coverages);

  hr_utility.set_location('External Procedure ',100);
  END external_procedure;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- it initiates the processing of each coverage type and also of best one with
  -- required adjustment values.
  --
  -- It is used at initialisation time and also when the  best guarantee is active.
  --
  -- The processing mode (g_ctl.p_mode) is used to identify the current mode NB. once
  -- set to cs_FINAL_PROCESS,only best coverage will be processed for final net.
  -- Detected by a call to the function final_processing() in the main controlling
  --  logic iterate().
  --
  -- It should be noted that the actual processing control for a guarantee is
  -- defined in iterate(). This logic simply decides pointer for best guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE process_control_info IS
    --
    --
    -- Local variables.
    --
    l_calculate      BOOLEAN;
    l_idx            NUMBER := 0;
    l_best_net_g_idx NUMBER;
    l_best           BOOLEAN;

  BEGIN
    --
    -- Search through all the guarantees to see if any do not have a net amount. The
    -- three possible options are
    --
    -- 1. ALL guarantees have a net amount so pick the best one for processing.
    -- 2. The guarantee with no net amount is currently being processed so do nothing.
    -- 3. Process the guarantee with no net amount.
    --
    hr_utility.set_location('Process Control info ',10);
      l_idx := g_coverages.FIRST;

      LOOP

        --
        --  Find the first type which has not been processed.
        --
        hr_utility.set_location('Process Control info Inside Loop',l_idx);
        l_calculate := (NVL(g_coverages(l_idx).processed_flag,'N') = 'Y');

        --
        --
        -- Finish looping if ALL coverages have been checked OR there is a coverage
        -- that needs to be processed.
        --

        EXIT WHEN l_idx = g_coverages.LAST OR NOT l_calculate;
        --
        --
        -- Move onto next guarantee.
        --
        l_idx := g_coverages.NEXT(l_idx);

      END LOOP;
      --
      --
      -- All guarantees has not been processed then process current one.
      --
      IF NOT l_calculate THEN

         --
         --
         -- The processing to find the net for this guarantee is already in progress.
         --
	hr_utility.set_location('Process Control info inside not calculate',20);

         IF NVL(g_ctl.g_idx,-1) = l_idx THEN
		NULL;
         --
         --
         -- Find the net for this guarantee.
         --
         ELSE

            g_ctl.p_mode := cs_PROCESS;
            g_ctl.g_idx  := l_idx;
            g_ctl.iter   := 1;
            hr_utility.set_location('Process Control info after cs_process',30);
         END IF;

      ELSE
       hr_utility.set_location('Process Control info',40);
         l_mode := 'C';
         external_procedure(l_mode, g_asg, g_absence, g_coverages);

         l_idx := g_coverages.FIRST;

       LOOP

        --
        --  Find the best method.
        --
        l_best := (NVL(g_coverages(l_idx).best_method,'N') = 'Y');
        hr_utility.set_location('Process Control info',50);

        --
        --
        -- Finish looping if All have been checked OR there is a best coverage
        --

        EXIT WHEN l_idx = g_coverages.LAST OR l_best;
        --
        --
        -- Move onto next guarantee.
        --
        l_idx := g_coverages.NEXT(l_idx);

      hr_utility.set_location('Process Control info',60);
      END LOOP;

      -- Process the best one and set mode to Final
         g_ctl.p_mode := cs_FINAL_PROCESS;
         g_ctl.g_idx  := l_idx;
         g_ctl.iter   := 1;
      hr_utility.set_location('Process Control info',70);

    END IF;

    hr_utility.set_location('Process Control info',100);
  END process_control_info;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Initialise the data structures for the processing of a new absence (see description
  -- for external_procedure() for details).
  --
  -- Having initialised the data structures setup the processing control information
  -- based on this.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE initialise_absence
  (p_element_entry_id NUMBER
  ,p_date_earned      DATE) IS
    --
    --
    -- Returns the ID for the absence linked to the element entry.
    --
    CURSOR csr_absence_id(p_element_entry_id NUMBER, p_date_earned DATE) IS
      SELECT creator_id ID
      FROM   pay_element_entries_f
      WHERE  element_entry_id = p_element_entry_id
        AND  creator_type     = 'A'
        AND  creator_id       IS NOT NULL;
  BEGIN
    --
    --
    -- Setup basic absence information.
    --
    g_absence.element_entry_id := p_element_entry_id;
    g_absence.date_earned      := p_date_earned;
    --
    --
    -- Get the absence ID linked to the element entry being processed.
    --
    hr_utility.set_location('Initialise Absence',10);
    -- Added lines for CPAM Processing
    IF pay_fr_sickness_calc.g_absence_calc.initiator = 'CPAM' THEN
       g_absence.ID := pay_fr_sickness_calc.g_absence_calc.ID;
    ELSE
       OPEN  csr_absence_id(p_element_entry_id, p_date_earned);
       FETCH csr_absence_id INTO g_absence.ID;
       CLOSE csr_absence_id;
    END IF;
    --
    hr_utility.set_location('Initialise Absence',20);
    --
    -- Initialise information required to process the absence.
    --
    l_mode := 'I';
    hr_utility.set_location('Initialise Absence',30);
    external_procedure(l_mode, g_asg, g_absence, g_coverages);
    hr_utility.set_location('Initialise Absence',40);
    --
    --
    -- Initialise the control information.
    --
    process_control_info();
    hr_utility.set_location('Initialise Absence',100);
  END initialise_absence;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Absence has been processed to completion so clear down the data structures in
  -- preparation for a new absnece NB. the assignment information is not cleared down as
  -- it may be relevant for the processing of the next absence.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE reset_data_structures IS
  BEGIN
    g_ctl       := blank_ctl;
    g_absence   := blank_absence;
    g_coverages := blank_coverages;
    hr_utility.set_location('Reset Data Str',100);
  END reset_data_structures;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Initialise the data structures for processing a new assignment NB. this also means a
  -- new absence is being procxessed so initialise for that as well.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE initialise_assignment
  (p_assignment_id         NUMBER
  ,p_net_pay               NUMBER
  ,p_element_entry_id      NUMBER
  ,p_date_earned           DATE
  ,p_assignment_action_id  NUMBER
  ,p_business_group_id     NUMBER
  ,p_payroll_action_id     NUMBER
  ,p_payroll_id            NUMBER
  ,p_element_type_id       NUMBER
  ,p_deduct_formula        NUMBER
  ,p_action_start_date     DATE
  ,p_action_end_date       DATE
  ,p_ded_ref_salary        NUMBER
  ,p_lg_ref_salary	   NUMBER) IS

  BEGIN
    --
    --
    -- Record assignment information.
    --
    g_asg.assignment_id 	:= p_assignment_id;
    g_asg.base_net      	:= p_net_pay;
    g_asg.payroll_id    	:= p_payroll_id;
    g_asg.assignment_action_id  := p_assignment_action_id;
    g_asg.business_group_id     := p_business_group_id;
    g_asg.payroll_action_id     := p_payroll_action_id;
    g_asg.element_type_id       := p_element_type_id;
    g_asg.deduct_formula        := p_deduct_formula;
    g_asg.action_start_date     := p_action_start_date;
    g_asg.action_end_date       := p_action_end_date;
    g_asg.ded_ref_salary	:= p_ded_ref_salary;
    g_asg.lg_ref_salary		:= p_lg_ref_salary;
    g_asg.sick_net              := p_net_pay;

    --
    --
    -- Retrieve information for processing the new absence.
    --
    hr_utility.set_location('Initialise Assignment',10);
    initialise_absence(p_element_entry_id, p_date_earned);
    hr_utility.set_location('Initialise Assignment',100);
  END initialise_assignment;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- co-ordination for the two levels of initialisation - assignment and absence. It also
  -- identifies if an initialisation has taken place.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION initialise
  (p_assignment_id    	   NUMBER
  ,p_element_entry_id      NUMBER
  ,p_date_earned           DATE
  ,p_assignment_action_id  NUMBER
  ,p_business_group_id     NUMBER
  ,p_payroll_action_id     NUMBER
  ,p_payroll_id            NUMBER
  ,p_element_type_id       NUMBER
  ,p_net_pay               NUMBER
  ,p_deduct_formula        NUMBER
  ,p_action_start_date     DATE
  ,p_action_end_date       DATE
  ,p_ded_ref_salary        NUMBER
  ,p_lg_ref_salary	   NUMBER

  ) RETURN BOOLEAN IS
    --
    --
    -- Local variables.
    --
    l_initialised BOOLEAN := FALSE;
  BEGIN
    --
    --
    -- A new assignment is being processed so reset the assignment information and
    -- initialise the information for the absence.
    -- bug 99999999 added action_start_date check as g_asg not being initialized
    -- in retropay covering multiple periods
    --
    hr_utility.set_location('Initialise',10);
    IF NOT (NVL(g_asg.assignment_id, -1) = p_assignment_id
            and (g_asg.action_start_date = p_action_start_date) ) THEN
      initialise_assignment(p_assignment_id,
                            p_net_pay,
                            p_element_entry_id,
                            p_date_earned,
                            p_assignment_action_id,
                            p_business_group_id,
                            p_payroll_action_id,
                            p_payroll_id,
                            p_element_type_id,
                            p_deduct_formula,
                            p_action_start_date,
                            p_action_end_date,
                            p_ded_ref_salary,
			    p_lg_ref_salary  );
      l_initialised := TRUE;
      hr_utility.set_location('Initialise ',20);
    --
    --
    -- A new absence is being processed so initialise the information for the absence.
    --
    ELSIF NOT ( NVL(g_absence.element_entry_id, -1) = p_element_entry_id) THEN
      g_asg.sick_net := p_net_pay;
      initialise_absence(p_element_entry_id, p_date_earned);
      l_initialised := TRUE;
      hr_utility.set_location('Initialise',30);

    ELSIF NOT (g_absence.date_earned = p_date_earned) THEN

    initialise_assignment(p_assignment_id,
                            p_net_pay,
                            p_element_entry_id,
                            p_date_earned,
                            p_assignment_action_id,
                            p_business_group_id,
                            p_payroll_action_id,
                            p_payroll_id,
                            p_element_type_id,
                            p_deduct_formula,
                            p_action_start_date,
                            p_action_end_date,
                            p_ded_ref_salary,
			    p_lg_ref_salary  );

      l_initialised := TRUE;
      hr_utility.set_location('Initialise',40);

     END IF;

    --
    --
    -- Return indicator identifying if initialisation occured.
    --
    hr_utility.set_location('Initialise',100);
    RETURN l_initialised;
  END initialise;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Increments the iteration.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE increment_iteration IS
  BEGIN
      hr_utility.set_location('Increment Iteration',10);
    g_ctl.iter := g_ctl.iter + 1;
    hr_utility.set_location('Increment Iteration',100);
  END increment_iteration;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Identfies if the processing mode is cs_FINAL_PROCESS i.e. now processing the best
  -- guarantee to completion.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION final_processing RETURN BOOLEAN IS
  BEGIN
  hr_utility.set_location('Final Processing',10);
    RETURN (g_ctl.p_mode = cs_FINAL_PROCESS);
  END final_processing;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Identifies the type for the current guarantee NB. this is enumerated as a numeric
  -- constant which allows access to processing information for that guarantee type.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION g_type RETURN NUMBER IS
  BEGIN
  hr_utility.set_location('g_type',10);

    IF final_processing THEN

    	RETURN cs_FINAL;
    ELSE
    hr_utility.set_location('g_type',11);
    	RETURN g_coverages(g_ctl.g_idx).g_type;

    END IF;
  END g_type;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Idnetifies when the processing should stop for the current guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION stop_processing
  (p_net_pay NUMBER) RETURN BOOLEAN IS
    --
    --
    -- Local variables.
    --
    l_target_net NUMBER;

  BEGIN
    --
    --
    -- Simple case where the processing is stopped at a specified iteration.
    --
    hr_utility.set_location('Stop Processing',10);
    hr_utility.set_location('Stop Processing Iterate No is'|| to_char(g_ctl.iter) , 15);
    IF g_rules(g_type).stop IS NOT NULL THEN
      RETURN (g_rules(g_type).stop = g_ctl.iter);
    --
    --
    -- Check to see if the currently calculated net pay is close enough to the target net.
    --
    ELSE
    hr_utility.set_location('Stop Processing',20);
      l_target_net := nvl(g_coverages(g_ctl.g_idx).net,0);
 hr_utility.set_location('Stop Processing'||l_target_net || p_net_pay,25);
      RETURN (l_target_net + cs_MARGIN >= p_net_pay AND l_target_net - cs_MARGIN <= p_net_pay);
    END IF;
    hr_utility.set_location('Stop Processing',100);
  END stop_processing;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Sets an adjustment as required for the processing of the current guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE set_adjustment
  (p_net_pay NUMBER) IS
    --
    --
    -- Local variables
    --
    l_dummy      NUMBER;
    l_target_net NUMBER;
    l_diff       NUMBER;
    l_sick_adj   NUMBER;
    l_init       NUMBER;
  BEGIN
  hr_utility.set_location('Set Adjustment',10);
    --
    --
    -- Get the target net for the current guarantee.
    --
    l_target_net := nvl(g_coverages(g_ctl.g_idx).net,0);

select decode(l_target_net,0,1,l_target_net) into l_init from dual;

 hr_utility.set_location('Set Adjustment target net: ' || l_target_net,15);
 hr_utility.set_location('Set Adjustment init: ' || l_init,17);

 --
    --
    -- There has not been an adjustment so set an initial value.
    --
    IF g_coverages(g_ctl.g_idx).sick_adj IS NULL THEN
 hr_utility.set_location('Set Adjustment target net: ' || l_target_net,18);

      l_dummy    := pay_iterate.initialise(g_absence.element_entry_id, l_init, -1 * l_init, l_init);
      l_sick_adj := pay_iterate.get_interpolation_guess(g_absence.element_entry_id, 0);
      hr_utility.set_location('Set Adjustment',20);
    --
    --
    -- Refine the adjustment.
    --
    ELSE
 hr_utility.set_location('Set Adjustment target net: ' || l_target_net,25);

      l_diff     := l_target_net - p_net_pay;

hr_utility.set_location('Set Adjustment diff: ' || l_diff,25);

      l_sick_adj := pay_iterate.get_interpolation_guess(g_absence.element_entry_id, l_diff);
      hr_utility.set_location('Set Adjustment',30);
    END IF;
    --
    --
    -- Set the sickness adjustment.
    --
    g_coverages(g_ctl.g_idx).sick_adj := l_sick_adj;
    hr_utility.set_location('Set Adjustment',100);
  END;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Sets the net pay for the current guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE set_net_pay
  (p_net_pay NUMBER) IS
  BEGIN
  hr_utility.set_location('Set Net Pay',10);
    g_coverages(g_ctl.g_idx).net := p_net_pay;
  END set_net_pay;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Identifies if an adjustment is required for the processing of the current guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION adjustment_needed RETURN BOOLEAN IS
  BEGIN
  hr_utility.set_location('Adjustment Needed',10);

    RETURN (g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).sick_adj = 'Y');


  END adjustment_needed;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Controls the iteration of the iterative formula associated with the sickness
  -- element.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
 FUNCTION iterate
   (p_assignment_id         NUMBER
   ,p_element_entry_id      NUMBER
   ,p_date_earned           DATE
   ,p_assignment_action_id  NUMBER
   ,p_business_group_id     NUMBER
   ,p_payroll_action_id     NUMBER
   ,p_payroll_id            NUMBER
   ,p_element_type_id       NUMBER
   ,p_net_pay               NUMBER
   ,p_deduct_formula        NUMBER
   ,p_action_start_date     DATE
   ,p_action_end_date       DATE
   ,p_ded_ref_salary        NUMBER
   ,p_lg_ref_salary	    NUMBER
   ,p_stop_processing OUT NOCOPY   VARCHAR2)  RETURN NUMBER IS

  BEGIN

 -- hr_utility.trace_on(NULL,'REQID');
  hr_utility.set_location('Iterate',10);

hr_utility.set_location('base net' || g_asg.base_net,10);
hr_utility.set_location('sick net' || g_asg.sick_net,10);
hr_utility.set_location('present net'|| p_net_pay,10);

    --
    --
    -- Checking for a change in assignment or absnece and initialising the processing
    -- as appropriate. If no initialisation then simply increment the iteration.
    --
    IF NOT initialise(p_assignment_id,
                      p_element_entry_id,
                      p_date_earned,
                      p_assignment_action_id,
                      p_business_group_id,
                      p_payroll_action_id,
                      p_payroll_id,
                      p_element_type_id,
                      p_net_pay,
                      p_deduct_formula,
                      p_action_start_date,
                      p_action_end_date,
                      p_ded_ref_salary,
                      p_lg_ref_salary   ) THEN

          increment_iteration;

    hr_utility.set_location('Iterate',20);
    --
    --
    -- Processing the guarantee that pays the best net.
    --
    IF final_processing THEN
      --
      --
      -- Check to see if processing should stop.
      --
      hr_utility.set_location('Iterate',30);
      IF stop_processing(p_net_pay) THEN
        reset_data_structures;
   hr_utility.set_location('Iterate',40);
        p_stop_processing := 'Y';
      END IF;
    --
    --
    -- Finding the best net to pay the employee.
    --
    ELSE

IF (g_coverages(g_ctl.g_idx).g_type = 30 and g_ctl.iter= 2) then

         IF ((nvl(g_coverages(g_ctl.g_idx).gi_payment1,0) + nvl(g_coverages(g_ctl.g_idx).gi_payment2,0)) = 0) then
             set_net_pay(nvl(p_net_pay,0) + nvl(g_absence.ijss_net,0)+nvl(g_absence.ijss_payment,0));
             hr_utility.set_location('net pay' || p_net_pay,18);
             hr_utility.set_location(' totnet pay' || g_coverages(g_ctl.g_idx).net,20);
         ELSE
             set_net_pay(nvl(p_net_pay,0)+ nvl(g_coverages(g_ctl.g_idx).ijss_net_adjustment,0));
             hr_utility.set_location('net pay' || p_net_pay,19);
             hr_utility.set_location(' totnet pay' || g_coverages(g_ctl.g_idx).net,21);

         END IF;

      END IF;

      IF stop_processing(p_net_pay) then

         set_net_pay(p_net_pay);
         g_coverages(g_ctl.g_idx).processed_flag := 'Y';
  	 hr_utility.set_location('Iterate',70);

      ELSIF adjustment_needed THEN

        set_adjustment(p_net_pay);
        hr_utility.set_location('Iterate',50);

      END IF;

      --
      --
      -- Check to see if there are any more guarantees that need to be processed to get their net amount.
      --
      process_control_info();

      hr_utility.set_location('Iterate',80);

    END IF;

  END IF;

    --
    --
    -- Simply return a value NB. declared as a function so it cab be used via a formula function.
    --
    hr_utility.set_location('Iterate',90);
 -- hr_utility.trace_off;

    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('iterate',-10);
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      -- hr_utility.trace_off;
      RAISE;


  END iterate;
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Returns the values to be processed for the current iteration for the guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION indirects
  (
  P_ABSENCE_ID			         OUT NOCOPY NUMBER,
  P_ijss_net 				 OUT NOCOPY NUMBER,
  P_ijss_payment 			 OUT NOCOPY NUMBER,
  P_ijss_gross1 			 OUT NOCOPY NUMBER,
  P_ijss_gross2 			 OUT NOCOPY NUMBER,
  p_ijss_estmtd                          OUT NOCOPY VARCHAR2,
  P_ijss_gross1_rate			 OUT NOCOPY NUMBER,
  P_ijss_gross2_rate			 OUT NOCOPY NUMBER,
  P_ijss_gross1_base			 OUT NOCOPY NUMBER,
  P_ijss_gross2_base			 OUT NOCOPY NUMBER,
  P_ijss_gross1_fromdate		 OUT NOCOPY DATE,
  P_ijss_gross2_fromdate		 OUT NOCOPY DATE,
  P_ijss_gross1_todate			 OUT NOCOPY DATE,
  P_ijss_gross2_todate			 OUT NOCOPY DATE,
  P_gi_payment1 			 OUT NOCOPY NUMBER,
  P_gi_payment2 			 OUT NOCOPY NUMBER,
  P_gi_payment1_rate			 OUT NOCOPY NUMBER,
  P_gi_payment2_rate			 OUT NOCOPY NUMBER,
  P_gi_payment1_base			 OUT NOCOPY NUMBER,
  P_gi_payment2_base			 OUT NOCOPY NUMBER,
  P_gi_payment1_fromdate		 OUT NOCOPY DATE,
  P_gi_payment2_fromdate		 OUT NOCOPY DATE,
  P_gi_payment1_todate			 OUT NOCOPY DATE,
  P_gi_payment2_todate			 OUT NOCOPY DATE,
  P_sick_adj				 OUT NOCOPY NUMBER,
  P_sick_deduct   			 OUT NOCOPY NUMBER,
  P_sick_deduct_rate			 OUT NOCOPY NUMBER,
  P_sick_deduct_base			 OUT NOCOPY NUMBER,
  P_gi_adjustment 			 OUT NOCOPY NUMBER,
  P_gross_ijss_adj 			 OUT NOCOPY NUMBER,
  P_audit			         OUT NOCOPY VARCHAR2,
  P_deduct_start_date                    OUT NOCOPY DATE,
  P_deduct_end_date                      OUT NOCOPY DATE,
  -- added for paid days balances
  p_red_partial_days                     OUT NOCOPY NUMBER,
  p_red_unpaid_days                      OUT NOCOPY NUMBER,
  -- Obtains the current Rate Input value 4504304
  p_net                                  OUT NOCOPY NUMBER
  --
)	    RETURN NUMBER IS



  BEGIN


    --
    --
    -- Pass values for the IJSS payment when appropriate.
    --
    -- hr_utility.trace_on(NULL,'REQID');

    hr_utility.set_location('Indirects',10);


    IF g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).ijss_payment = 'Y' THEN

      		p_ijss_net             	:= NVL(g_absence.ijss_net, 0);
                p_ijss_payment         	:= NVL(g_absence.ijss_payment, 0);
                 hr_utility.set_location('Indirects',11);
                p_ijss_gross1          	:= NVL(g_coverages(g_ctl.g_idx).ijss_gross1, 0);
                p_ijss_gross2          	:= NVL(g_coverages(g_ctl.g_idx).ijss_gross2, 0);
                 hr_utility.set_location('Indirects',12);
                p_ijss_gross1_rate     	:= NVL(g_coverages(g_ctl.g_idx).ijss_gross_rate1, 0);
                p_ijss_gross2_rate     	:= NVL(g_coverages(g_ctl.g_idx).ijss_gross_rate2, 0);
                 hr_utility.set_location('Indirects',13);
                p_ijss_gross1_base     	:= NVL(g_coverages(g_ctl.g_idx).ijss_gross_days1, 0);
                p_ijss_gross2_base     	:= NVL(g_coverages(g_ctl.g_idx).ijss_gross_days2, 0);
                 hr_utility.set_location('Indirects',14);
                p_ijss_gross1_fromdate 	:= g_coverages(g_ctl.g_idx).ijss_from_date1;
                p_ijss_gross2_fromdate 	:= g_coverages(g_ctl.g_idx).ijss_from_date2;
                p_ijss_gross1_todate   	:= g_coverages(g_ctl.g_idx).ijss_to_date1;
                p_ijss_gross2_todate   	:= g_coverages(g_ctl.g_idx).ijss_to_date2;
                 hr_utility.set_location('Indirects',15);
                p_ijss_estmtd           := NVL(g_absence.ijss_estimated, 'N');
                 hr_utility.set_location('Indirects',16);

    ELSE
     		p_ijss_net	       	:= 0;
        	p_ijss_payment	       	:= 0;
     		p_ijss_gross1          	:= 0;
               	p_ijss_gross2          	:= 0;
               	p_ijss_gross1_rate     	:= 0;
               	p_ijss_gross2_rate     	:= 0;
               	p_ijss_gross1_base     	:= 0;
               	p_ijss_gross2_base     	:= 0;
               	p_ijss_estmtd        	:= 'U';

     END IF;

    hr_utility.set_location('Indirects',20);

    --
    --
    -- Pass value for the guaranteed income payment when appropriate.
    --

    IF g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).gi_payment = 'Y' THEN

                p_gi_payment1          	:= NVL(g_coverages(g_ctl.g_idx).gi_payment1, 0);
                p_gi_payment2          	:= NVL(g_coverages(g_ctl.g_idx).gi_payment2, 0);
                p_gi_payment1_rate     	:= NVL(g_coverages(g_ctl.g_idx).gi_rate1, 0);
                p_gi_payment2_rate     	:= NVL(g_coverages(g_ctl.g_idx).gi_rate2, 0);
                p_gi_payment1_base     	:= NVL(g_coverages(g_ctl.g_idx).gi_days1, 0);
                p_gi_payment2_base     	:= NVL(g_coverages(g_ctl.g_idx).gi_days2, 0);
                p_gi_payment1_fromdate 	:= g_coverages(g_ctl.g_idx).gi_from_date1;
                p_gi_payment2_fromdate 	:= g_coverages(g_ctl.g_idx).gi_from_date2;
                p_gi_payment1_todate   	:= g_coverages(g_ctl.g_idx).gi_to_date1;
                p_gi_payment2_todate   	:= g_coverages(g_ctl.g_idx).gi_to_date2;
                -- Added for days paid balances
                p_red_partial_days      := g_absence.partial_paid_days;
                p_red_unpaid_days       := g_absence.unpaid_days;
                --

    ELSE

    		p_gi_payment1        	:= 0;
		p_gi_payment2        	:= 0;
		p_gi_payment1_rate   	:= 0;
		p_gi_payment2_rate   	:= 0;
		p_gi_payment1_base   	:= 0;
		p_gi_payment2_base   	:= 0;
		-- Added for days paid balances
		p_red_partial_days      := 0;
		p_red_unpaid_days       := 0;
                --



    END IF;

    hr_utility.set_location('Indirects',30);

    --
    --
    -- Pass value for the sickness adjustment when appropriate.
    --

    IF g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).sick_adj = 'Y' THEN

    		p_sick_adj := NVL(g_coverages(g_ctl.g_idx).sick_adj, 0);

    ELSE

    		p_sick_adj := 0;

    END IF;

    hr_utility.set_location('Indirects',40);

    --
    --
    -- Pass value for the sickness deduction when appropriate.
    --

    IF g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).deduct_for_sick = 'Y' THEN

    	          p_sick_deduct 	  := NVL(g_absence.sick_deduction, 0);
	          p_sick_deduct_rate      := NVL(g_absence.sick_deduction_rate, 0);
	          p_sick_deduct_base      := NVL(g_absence.sick_deduction_base, 0);
                  p_deduct_start_date     := g_absence.sick_deduct_start_date;
                  p_deduct_end_date       := g_absence.sick_deduct_end_date;

     ELSE
    	          p_sick_deduct	  := 0;
        	  p_sick_deduct_rate   := 0;
	      	  p_sick_deduct_base   := 0;

    END IF;

    hr_utility.set_location('Indirects',60);

    --
    --
    -- Pass value for the guaranteed income adjustment when appropriate.
    --

    IF g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).gi_adj = 'Y' THEN

    		  p_gi_adjustment 		   := NVL(g_absence.gi_adjustment, 0);

    ELSE

    		  p_gi_adjustment 		   := 0;

    END IF;

    --
    --
    -- Pass value for the gross IJSS adjustment when appropriate.
    --

    IF g_iter_rules(g_type + LEAST(NVL(g_rules(g_type).repeat,g_ctl.iter), g_ctl.iter)).gross_ijss_adj = 'Y' THEN

        	   p_gross_ijss_adj := NVL(g_absence.gross_ijss_adjustment, 0);

    ELSE

        	   p_gross_ijss_adj := 0;

    END IF;

    hr_utility.set_location('Indirects',65);

    --
    --
    -- Trigger the auditing when processing the final result NB. it is not needed when
    -- finding the best to pay to the employee.
    --
    IF final_processing THEN
      p_audit           := 'Y';
      g_ctl.audit_g_idx := g_coverages.FIRST;
      -- Obtain current record rate value
      p_net             := NVL(g_coverages(g_ctl.audit_g_idx).net,0);
    ELSE
      p_audit := 'N';
      -- Assign 0 to p_net
      p_net   := 0;
    END IF;
    hr_utility.set_location('Indirects',70);
    --
    --
    -- Pass the ID for the absence.
    --
    p_absence_id := g_absence.ID;
    --
    --
    -- Simply return a value NB. declared as a function so it cab be used via a formula function.
    --

    hr_utility.set_location('Indirects',100);

    -- hr_utility.trace_off;


    RETURN 0;
     EXCEPTION
        WHEN OTHERS THEN
          hr_utility.set_location('iterate ',-10);
          hr_utility.trace(SQLCODE);
          hr_utility.trace(SQLERRM);
    --      hr_utility.trace_off;
      RAISE;

  END indirects;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Returns the values to be processed for the current iteration for the guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION audit
  (p_parent_abs_id           OUT NOCOPY NUMBER
  ,p_guarantee_type          OUT NOCOPY VARCHAR2
  ,p_cagr_id                 OUT NOCOPY NUMBER
  ,p_net                     OUT NOCOPY NUMBER
  ,p_gi_payment              OUT NOCOPY NUMBER
  ,p_band1                   OUT NOCOPY NUMBER
  ,p_band2                   OUT NOCOPY NUMBER
  ,p_band3                   OUT NOCOPY NUMBER
  ,p_band4                   OUT NOCOPY NUMBER
  ,p_best_method             OUT NOCOPY VARCHAR2
  ,p_sick_adjustment         OUT NOCOPY NUMBER
  ,p_gi_adjustment           OUT NOCOPY NUMBER
  ,p_gross_ijss_adj          OUT NOCOPY NUMBER
  ,p_ijss_gross              OUT NOCOPY NUMBER
  ,p_audit                   OUT NOCOPY VARCHAR2
  ,p_payment_start_date      OUT NOCOPY DATE
  ,P_payment_end_date        OUT NOCOPY DATE
  ) RETURN NUMBER IS

  BEGIN
    --
    --
    -- Return the audit values.
    --
    -- hr_utility.trace_on(NULL,'REQID');
    p_parent_abs_id           := NVL(g_absence.parent_absence_id,0);
    p_guarantee_type          := NVL(g_guarantee_type_lookups(g_coverages(g_ctl.audit_g_idx).g_type),'U');
    p_cagr_id                 := NVL(g_coverages(g_ctl.audit_g_idx).cagr_id,0);
    p_gi_payment              := NVL(g_coverages(g_ctl.audit_g_idx).gi_payment1,0) + NVL(g_coverages(g_ctl.audit_g_idx).gi_payment2,0);
    p_band1                   := NVL(g_coverages(g_ctl.audit_g_idx).band1,0);
    p_band2                   := NVL(g_coverages(g_ctl.audit_g_idx).band2,0);
    p_band3                   := NVL(g_coverages(g_ctl.audit_g_idx).band3,0);
    p_band4                   := NVL(g_coverages(g_ctl.audit_g_idx).band4,0);
    p_best_method	      := NVL(g_coverages(g_ctl.audit_g_idx).best_method,'N');
    p_payment_start_date      := g_coverages(g_ctl.audit_g_idx).gi_from_date1;
    p_payment_end_date        := NVL(g_coverages(g_ctl.audit_g_idx).gi_to_date2, g_coverages(g_ctl.audit_g_idx).gi_to_date1);
    p_sick_adjustment         := NVL(g_coverages(g_ctl.audit_g_idx).sick_adj,0);
    p_gi_adjustment           := NVL(g_absence.gi_adjustment,0);
    p_gross_ijss_adj          := NVL(g_absence.gross_ijss_adjustment,0);
    p_ijss_gross              := NVL(g_coverages(g_ctl.audit_g_idx).ijss_gross2,0) + NVL(g_coverages(g_ctl.audit_g_idx).ijss_gross1,0);

    --
    if p_best_method <> 'Y' then p_best_method := 'N' ;
       end if;
    --
    -- All the coverages have been audited so stop.
    --
    hr_utility.set_location('Audit',10);
    IF g_ctl.audit_g_idx = g_coverages.LAST THEN
     /* Assign 0 for Rate input */
      p_net   := 0;
      p_audit := 'N';
    --
    --
    -- Move to the next coverage.
    --
    ELSE
      g_ctl.audit_g_idx := g_coverages.NEXT(g_ctl.audit_g_idx);
      /* Obtain the new Rate value */
      p_net             := NVL(g_coverages(g_ctl.audit_g_idx).net,0);
      p_audit := 'Y';
    END IF;
    --
    --
    -- Simply return a value NB. declared as a function so it cab be used via a formula function.
    --
    RETURN 0;

    hr_utility.set_location('Audit',100);
    -- hr_utility.trace_off;
  END audit;

FUNCTION get_guarantee_id(
P_type      IN  VARCHAR2 )  RETURN NUMBER is

    --
    -- Local variables.
    --
    l_idx            NUMBER := 0;
    l_best           BOOLEAN;

BEGIN
--
  l_idx :=   g_guarantee_type_lookups.FIRST;

 LOOP
        --
        --  Find the best method.
        --
        l_best :=  (NVL(g_guarantee_type_lookups(l_idx),'U') = p_type) ;

        hr_utility.set_location('Get Guarantee ID',50);

        --
        --
        -- Finish looping if All have been checked OR there is a best coverage
        --

        EXIT WHEN l_idx = g_guarantee_type_lookups.LAST OR l_best;
        --
        --
        -- Move onto next guarantee.
        --
        l_idx := g_guarantee_type_lookups.NEXT(l_idx);

      hr_utility.set_location('Get Gurantee ID',60);

END LOOP;

IF(l_best) then

  return l_idx;

else

  return -1;

END IF;

END get_guarantee_id;

  --
BEGIN
  --
  --
  -- Setup the processing rules which control how each type of income guarantee is processed.
  --
  hr_utility.set_location('PAY_FR_SICK_PAY_PROCESSING',50);
  initialise_processing_rules;
  --
  --
  -- Setup the mapping between internal constants identifying each guarantee type with an
  -- external reference (LOOKUP_CODE).
  --
  initialise_guarantee_lookups;

  hr_utility.set_location('PAY_FR_SICK_PAY_PROCESSING',100);
END pay_fr_sick_pay_processing;

/
