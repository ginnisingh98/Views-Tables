--------------------------------------------------------
--  DDL for Package Body PAY_FR_INSURANCE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_INSURANCE_PROCESS" AS
  /* $Header: pyfrtpin.pkb 115.3 2002/11/25 13:25:37 vsjain noship $ */
  --
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
  -- g_ins                    - Holds information for insurance record.
  --
  -- NB. the blank versions are used when the corresponding global variable needs to
  --     be cleared out.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  g_ctl                    t_ctl;
  g_ins                    t_ins;

  --
  blank_ctl                t_ctl;
  blank_ins		   t_ins;

  l_mode                   VARCHAR2(1);

  g_trace Number := 0;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Initialise the data structures for the processing of a new insurance payment
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

  PROCEDURE initialise_insurance
  (p_assignment_id     NUMBER
  ,p_net_pay           NUMBER
  ,p_element_entry_id  NUMBER
  ,p_date_earned       DATE
  ,p_subject_insurance NUMBER
  ,p_exempt_insurance  NUMBER
  ,p_recipient         Varchar2) IS


    BEGIN

    hr_utility.set_location('Initialise insurance',10);

    --
    --
    -- Setup basic absence information.
    --
    hr_utility.set_location('p_recipient ='||p_recipient,95);

    g_ins.assignment_id 	:= p_assignment_id;
    g_ins.element_entry_id 	:= p_element_entry_id;
    g_ins.date_earned      	:= p_date_earned;
    g_ins.insurance_subject  	:= p_subject_insurance;
    g_ins.insurance_exempt    	:= p_exempt_insurance;

    IF p_recipient = 'EMPLOYEE' then
        g_ins.base_net		   := 0 - (g_ins.insurance_subject + g_ins.insurance_exempt);
        g_ins.insurance_reduction  := 0 - (g_ins.insurance_subject + g_ins.insurance_exempt);
    ELSE
    	g_ins.base_net		:= 0;
    END IF;



    hr_utility.set_location('Initialise Insurance',100);

  END initialise_insurance;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Insurance Element has been processed to completion so clear down the data structures in
  -- preparation for a new Insurance Element NB.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE reset_data_structures IS
  BEGIN
    g_ctl       := blank_ctl;
    g_ins       := blank_ins;
    hr_utility.set_location('Reset Data Str',100);
  END reset_data_structures;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- co-ordination for the three levels of initialisation - assignment and insurance payment
  -- or date earned. It also identifies if an initialisation has taken place.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

  FUNCTION initialise
  (p_assignment_id    NUMBER
  ,p_element_entry_id NUMBER
  ,p_date_earned      DATE
  ,p_net_pay          NUMBER
  ,p_subject_insurance  NUMBER
  ,p_exempt_insurance    NUMBER
  ,p_recipient        VARCHAR2	) RETURN BOOLEAN IS

    --
    --
    -- Local variables.
    --

    l_initialised BOOLEAN := FALSE;

  BEGIN

  hr_utility.set_location('p_recipient ='||p_recipient,95);
    --
    --
    -- A new assignment is being processed so reset information and
    -- initialise the information for insurance record.
    --
    hr_utility.set_location('Initialise',10);
    IF NOT (NVL(g_ins.assignment_id, -1) = p_assignment_id) THEN

      initialise_insurance(p_assignment_id,
                           p_net_pay,
                           p_element_entry_id,
                           p_date_earned,
                           p_subject_insurance,
                           p_exempt_insurance,
                           p_recipient);


      l_initialised := TRUE;
      hr_utility.set_location('Initialise',20);
    --
    --
    -- A new insurance element is being processed so initialise information for insurance.
    --

    ELSIF g_ins.element_entry_id IS NULL THEN

      initialise_insurance(p_assignment_id,
                           p_net_pay,
                           p_element_entry_id,
                           p_date_earned,
                           p_subject_insurance,
                           p_exempt_insurance,
                           p_recipient);

      l_initialised := TRUE;
      hr_utility.set_location('Initialise',30);

    ELSIF NOT (g_ins.date_earned = p_date_earned) THEN
      initialise_insurance(p_assignment_id,
                           p_net_pay,
                           p_element_entry_id,
                           p_date_earned,
                           p_subject_insurance,
                           p_exempt_insurance,
                           p_recipient);

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

      hr_utility.set_location('Stop Processing',10);
    --
    --
    --Check to see if the currently calculated net pay is close enough to the target net.
    --
      l_target_net := g_ins.base_net;
      RETURN (l_target_net + cs_MARGIN >= p_net_pay AND l_target_net - cs_MARGIN <= p_net_pay);
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
    l_ins_adj   NUMBER;
    l_init     NUMBER := 0;
  BEGIN
  hr_utility.set_location('Set Adjustment',10);
    --
    --
    -- Get the target net for the current guarantee.
    --
    l_target_net := g_ins.base_net;

    select decode(nvl(g_ins.insurance_subject,0),0,1,g_ins.insurance_subject) into l_init from dual;
    --
    --
    -- There has not been an adjustment so set an initial value.
    --
    IF g_ins.insurance_adjustment IS NULL THEN
      l_dummy    := pay_iterate.initialise(g_ins.element_entry_id, l_target_net, -1 * l_init, l_init);
      l_ins_adj  := pay_iterate.get_interpolation_guess(g_ins.element_entry_id, 0);
      hr_utility.set_location('Set Adjustment',20);
    --
    --
    -- Refine the adjustment.
    --
    ELSE

      l_diff     := l_target_net - p_net_pay;
      l_ins_adj  := pay_iterate.get_interpolation_guess(g_ins.element_entry_id, l_diff);
      hr_utility.set_location('Target net ='||l_target_net,90);
      hr_utility.set_location('Net pay ='||p_net_pay,90);
      hr_utility.set_location('Difference ='||l_diff,90);
      hr_utility.set_location('Adjustment ='||l_ins_adj,100);
      hr_utility.set_location('Set Adjustment',30);

    END IF;
    --
    --
    -- Set the insurance adjustment.
    --
    g_ins.insurance_adjustment := l_ins_adj;
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
    g_ins.base_net := p_net_pay;
  END set_net_pay;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Controls the iteration of the iterative formula associated with the sickness
  -- element.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

  FUNCTION iterate
  (p_assignment_id       NUMBER
  ,p_element_entry_id    NUMBER
  ,p_date_earned         DATE
  ,p_net_pay             NUMBER
  ,p_subject_insurance   NUMBER
  ,p_exempt_insurance	 NUMBER
  ,p_recipient           VARCHAR2
  ,p_stop_processing OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  BEGIN

   -- hr_utility.trace_on(NULL,'INSURANCE');


       --
       --
       -- Checking for a change in assignment or absnece and initialising the processing
       -- as appropriate. If no initialisation then simply increment the iteration.

     hr_utility.set_location('Assignment Id = '||p_assignment_id,80);
     hr_utility.set_location('Element_entry_id ='||p_element_entry_id,81);
     hr_utility.set_location('p_net_pay     ='||p_net_pay,83);
     hr_utility.set_location('p_subject_insurance ='||p_subject_insurance,84);
     hr_utility.set_location('p_exempt_insurance ='||p_exempt_insurance,85);
     hr_utility.set_location('p_exempt_insurance ='||p_recipient,95);



    hr_utility.set_location('Iterate',10);
    --
    --
    -- Checking for a change in assignment or absnece and initialising the processing
    -- as appropriate. If no initialisation then simply increment the iteration.
    --
    IF initialise(p_assignment_id,
                      p_element_entry_id,
                      p_date_earned,
                      p_net_pay,
                      p_subject_insurance,
                      p_exempt_insurance,
                      p_recipient)    THEN

      increment_iteration;

      hr_utility.set_location('Iterate',20);
    END IF;

    IF stop_processing(p_net_pay) then

      -- set_net_pay(p_net_pay);

       reset_data_structures;
       p_stop_processing := 'Y';


        hr_utility.set_location('p_stop_processing ='||p_stop_processing,02);

       hr_utility.set_location('Iterate',70);

    ELSE
        set_adjustment(p_net_pay);
        hr_utility.set_location('Iterate',50);

    END IF;

        hr_utility.set_location('Iterate',80);

    --
    --
    -- Simply return a value NB. declared as a function so it cab be used via a formula function.
    --

    hr_utility.set_location('Iterate',90);

   -- hr_utility.trace_off;

    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('iterate ',-10);
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      -- hr_utility.trace_off;
      RAISE;

  END iterate;

  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Returns the values to be processed for the current iteration for the guarantee.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

  FUNCTION indirects
  (p_ins_subject      OUT NOCOPY NUMBER
  ,p_ins_exempt       OUT NOCOPY NUMBER
  ,p_ins_adjustment   OUT NOCOPY NUMBER
  ,p_ins_reduction    OUT NOCOPY NUMBER) RETURN NUMBER IS

  BEGIN

    --
    --
    -- Pass value for the sickness adjustment when appropriate.
    --

      hr_utility.set_location('Indirects',10);

    --
    --
    -- Pass values for the third party insurance payment when appropriate.
    --

      p_ins_subject      := NVL(g_ins.insurance_subject, 0);
      p_ins_exempt       := NVL(g_ins.insurance_exempt, 0);
      p_ins_adjustment   := NVL(g_ins.insurance_adjustment, 0);
      p_ins_reduction    := NVL(g_ins.insurance_reduction , 0);


      hr_utility.set_location('Indirects',50);

      hr_utility.set_location('p_ins_subject(o) ='||p_ins_subject,100);
      hr_utility.set_location('p_ins_exempt(o) ='||p_ins_exempt,100);
      hr_utility.set_location('p_ins_adjustment(o) ='||p_ins_adjustment,100);


    --
    --
    -- Simply return a value NB. declared as a function so it can be used via a formula function.
    --

    hr_utility.set_location('Indirects',100);
    -- hr_utility.trace_off;
    RETURN 0;
  END indirects;
    --
BEGIN

  hr_utility.set_location('PAY_FR_INSURANCE_PROCESS',100);

END pay_fr_insurance_process;

/
