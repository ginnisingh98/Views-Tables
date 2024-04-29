--------------------------------------------------------
--  DDL for Package Body PAY_GB_COURT_ORDER_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_COURT_ORDER_UPGRADE" AS
  /* $Header: pygbupgr.pkb 120.0 2005/06/24 07:39:05 appldev noship $ */
  --
  --
  -- Global variables.
  --
  g_package VARCHAR2(31) := 'pay_gb_court_order_upgrade.';
  --
  --
  -- -------------------------------------------------------------------------------------------
  -- Return the ID for a given context.
  -- -------------------------------------------------------------------------------------------
  --
  FUNCTION get_context_id(p_context_name VARCHAR2) RETURN NUMBER IS

    -- Return the ID for a given context.

    CURSOR csr_context(p_context_name VARCHAR2) IS
      SELECT context_id
      FROM   ff_contexts
      WHERE  context_name = p_context_name;

    -- Local variables.

    l_proc       VARCHAR2(61) := g_package || 'get_context_id';
    l_context_id NUMBER;

  BEGIN

    hr_utility.set_location('Entering: ' || l_proc, 10);

    OPEN csr_context(p_context_name);
    FETCH csr_context INTO l_context_id;
    CLOSE csr_context;

    hr_utility.set_location('Leaving: ' || l_proc, 20);

    RETURN l_context_id;

  END get_context_id;

  -- -------------------------------------------------------------------------------------------
  -- Upgrade the run results.
  -- -------------------------------------------------------------------------------------------
  --
  PROCEDURE upgrade_action_contexts(p_business_group_id number) IS
    --
    --
      CURSOR csr_results (l_context_id NUMBER) IS
      SELECT distinct /*+ INDEX(prr PAY_RUN_RESULTS_N50,PAY_RUN_RESULTS_N1) */
             et.element_type_id
            ,et.element_name
            ,iv.input_value_id
            ,iv.name input_value_name
            ,rr.run_result_id
            ,aa.assignment_action_id
            ,aa.assignment_id
            ,nvl(prrv.result_value,'Unknown') result_value
      FROM   pay_element_types_f    et
            ,pay_input_values_f     iv
            ,pay_run_results        rr
            ,per_assignments_f      paf
            ,pay_assignment_actions aa
            ,pay_run_result_values  prrv
      WHERE  paf.business_group_id   = p_business_group_id
        AND  paf.assignment_id       = aa.assignment_id
        AND  et.element_name         IN ('Court Order','Court Order NTPP')
        AND  et.legislation_code     = 'GB'
        AND  iv.element_type_id      = et.element_type_id
        AND  iv.name                 = 'Reference'
        AND  iv.legislation_code     = 'GB'
        AND  rr.element_type_id      = et.element_type_id
        AND  aa.assignment_action_id = rr.assignment_action_id
        AND  prrv.run_result_id      = rr.run_result_id
        AND  prrv.input_value_id     = iv.input_value_id
        AND  NOT EXISTS (SELECT NULL
                         FROM   pay_action_contexts pac
                         WHERE  pac.assignment_id = aa.assignment_id
                           AND  pac.assignment_action_id = aa.assignment_action_id
                           AND  pac.context_id = l_context_id
                           AND  pac.context_value = nvl(prrv.result_value, 'Unknown'));
       --ORDER BY aa.assignment_action_id;

    -- Local variables.

    l_proc                   VARCHAR2(61) := g_package || 'upgrade_action_contexts';
    l_result_rec             csr_results%ROWTYPE;
    l_assact_id              NUMBER := -1;
    l_assact_count           NUMBER := 0;
    l_context_id             NUMBER;
    l_context_value          VARCHAR2(100) := '-1';
    --
  BEGIN
    --
    hr_utility.set_location('Entering: ' || l_proc, 10);

    -- Get ID for the context

       l_context_id      := get_context_id('SOURCE_TEXT');

    -- Loop through all run results.

    OPEN csr_results(l_context_id);
    LOOP
      --
      -- Get the next run result.
      --
      FETCH csr_results INTO l_result_rec;
      EXIT WHEN csr_results%NOTFOUND;

      -- New assignment action being processed.
      --
      l_assact_id     := l_result_rec.assignment_action_id;
      l_context_value := l_result_rec.result_value;


        --
        --
        -- Store the latest assignmment action and keep count of the total number
        -- of assignment actions that are being processed.
        --


           l_assact_count  := l_assact_count + 1;
        --
        --
        -- Commit every 100 records to reduce the transaction size.
        --
        IF MOD(l_assact_count, 100) = 0 THEN
          COMMIT;
        END IF;
        --
        -- Create missing action contexts.
        --
        INSERT INTO pay_action_contexts
        (assignment_action_id
        ,assignment_id
        ,context_id
        ,context_value)
        (
	  select
	  l_result_rec.assignment_action_id
         ,l_result_rec.assignment_id
          ,l_context_id
          ,l_result_rec.result_value
	   from dual
	   where NOT EXISTS (SELECT NULL
                         FROM   pay_action_contexts pac
                         WHERE  pac.assignment_id  =  l_result_rec.assignment_id
                           AND  pac.assignment_action_id = l_result_rec.assignment_action_id
                           AND  pac.context_id = l_context_id
                           AND  pac.context_value = nvl(l_result_rec.result_value, 'Unknown')));
        --

        -- Update run results with value 'Unknown'.
	 UPDATE pay_run_result_values prrv
	 SET   prrv.result_value =  'Unknown'
	 WHERE prrv.input_value_id = l_result_rec.input_value_id
	 AND   prrv.run_result_id  = l_result_rec.run_result_id
	 AND   prrv.result_value is null;


      --
    END LOOP;
    --
    CLOSE csr_results;
    COMMIT;
    --
    hr_utility.set_location('Leaving: ' || l_proc, 20);
    --
  END upgrade_action_contexts;
  --
  --
  -- -------------------------------------------------------------------------------------------
  -- The main upgrade.
  -- -------------------------------------------------------------------------------------------
  --
  PROCEDURE run(errbuf			OUT	NOCOPY VARCHAR2
	       ,retcode			OUT	NOCOPY NUMBER
	       ,p_bg_id                         IN NUMBER
	       ,p_overpaid  IN VARCHAR2
	       )  IS
    --
    --

-- To get business_group name
  CURSOR csr_business_group
  is
  SELECT name
  FROM   per_business_groups
  WHERE  business_group_id =p_bg_id;

-- To get date
  CURSOR csr_date
  is
  SELECT to_date(SYSDATE,'DD-MM-YYYY')
  FROM dual;


-- To get defined balance id
     CURSOR csr_defined_balance_id
      IS
         SELECT pdb.defined_balance_id
           FROM pay_balance_dimensions pbd,
                pay_balance_types pbt,
                pay_defined_balances pdb
          WHERE pbd.dimension_name = '_PER_CO_TD_REF_ITD'
            AND pbd.business_group_id IS NULL
            AND pbd.legislation_code = 'GB'
            AND pbt.balance_name = 'Court Order'
            AND pbt.business_group_id IS NULL
            AND pbt.legislation_code = 'GB'
            AND pdb.balance_type_id = pbt.balance_type_id
            AND pdb.balance_dimension_id = pbd.balance_dimension_id
            AND pdb.business_group_id IS NULL
            AND pdb.legislation_code = 'GB';


 -- To get person details
    CURSOR csr_person_det
    is
    SELECT     distinct  ppf.full_name ,
	       ppf.person_id,
	       ppf.national_identifier
    FROM       per_people_f           ppf
              ,pay_payrolls_f         pf
              ,per_assignments_f      paf
    WHERE      ppf.business_group_id = p_bg_id
    AND        pf.payroll_id = paf.payroll_id
    AND        paf.person_id = ppf.person_id
    ORDER      by ppf.full_name;

 -- To get the payroll name
    CURSOR csr_get_payroll(p_person_id in number)
    IS
    SELECT     distinct  pf.payroll_name
    FROM       per_people_f           ppf
              ,pay_payrolls_f         pf
              ,per_assignments_f      paf
    WHERE      ppf.business_group_id = p_bg_id
    AND        pf.payroll_id = paf.payroll_id
    AND        paf.person_id = ppf.person_id
    AND        ppf.person_id = p_person_id;
   -- ORDER      by pf.payroll_id;


 -- To get the paid value
    CURSOR csr_asg_actions(p_person_id in number
                          ,p_defined_balance_id in number) is
    SELECT max(paa.assignment_action_id) assignment_action_id,
           pac.context_value context_value,
	   nvl(pay_balance_pkg.get_value(p_defined_balance_id, max(pac.assignment_action_id), null,null, fc.context_id, pac.context_value,null,null),0) paid_value
    FROM       per_assignments_f paf,
	       pay_assignment_actions paa,
	       pay_action_contexts pac,
	       ff_contexts fc,
	       pay_element_types_f pet,
	       pay_input_values_f piv,
	       pay_run_results prr,
	       pay_run_result_values prrv
	      ,pay_input_values_f     piv1
              ,pay_run_results        prr1
       	      ,pay_run_result_values  prrv1
    WHERE   paf.assignment_id     = paa.assignment_id
        AND paf.person_id           = p_person_id
        AND fc.context_id           = pac.context_id
        AND fc.context_name         = 'SOURCE_TEXT'
        AND paa.assignment_id       =  pac.assignment_id
        AND paa.action_status       = 'C'
        AND pet.element_name        IN ('Court Order','Court Order NTPP')
        AND pet.legislation_code     = 'GB'
        AND pet.element_type_id      = piv.element_type_id
        AND piv.name                 = 'Reference'
        AND prr.run_result_id        = prrv.run_result_id
        AND prrv.input_value_id      = piv.input_value_id
        AND prr.assignment_action_id =  paa.assignment_action_id
        AND piv.legislation_code     = 'GB'
        AND paa.assignment_action_id = prr1.assignment_action_id
        AND prrv1.run_result_id      = prr1.run_result_id
        AND prr1.element_type_id     = pet.element_type_id
        AND prr.run_result_id        = prr1.run_result_id
        AND prrv1.input_value_id     = piv1.input_value_id
        AND prrv1.result_value       in ('CTO','CCAEO')
        AND piv1.name                = 'Type'
        AND piv1.legislation_code    = 'GB'
	AND pac.context_value        not in ('Unknown')
	group by fc.context_id, pac.context_value;

--To get initial debt value
  CURSOR  csr_intial_debt(p_assignment_action_id number
                         ,p_paid_value number
			 ,p_context_value varchar2) is
    SELECT nvl(PRRV.result_value ,'0') result_value,
           nvl((prrv.result_value - p_paid_value),'0') overpaid
    FROM
	pay_element_types_f pet,
	pay_input_values_f piv,
	pay_run_results prr,
	pay_run_result_values prrv,
	pay_input_values_f piv1,
	pay_run_results prr1,
	pay_run_result_values prrv1
    WHERE      pet.element_name  IN ('Court Order','Court Order NTPP')
        AND    pet.legislation_code = 'GB'
        AND    piv.element_type_id  = pet.element_type_id
        AND    piv.name             = 'Initial Debt'
        AND    prr.run_result_id    = prrv.run_result_id
        AND    prrv.input_value_id  = piv.input_value_id
        AND    prr.assignment_action_id  in (p_assignment_action_id)
        AND    prrv.result_value is not null
        AND    prr1.assignment_action_id in (p_assignment_action_id)
        AND    prrv1.run_result_id      = prr1.run_result_id
        AND    prr1.element_type_id     = pet.element_type_id
        AND    prr.run_result_id        = prr1.run_result_id
        AND    prrv1.input_value_id     = piv1.input_value_id
        AND    prrv1.result_value       in (p_context_value)
        AND    piv1.name                = 'Reference'
        AND    piv1.legislation_code    = 'GB';
       -- order  by 2 desc;

       -- Local variables.
       --
	 l_proc VARCHAR2(61) ;
	 l_date  date;


	v_initial_det         csr_intial_debt%rowtype;
	l_defined_balance_id  pay_defined_balances.defined_balance_id%type;
	l_business_group_name per_business_groups.name%type;
	v_payroll             pay_payrolls_f.payroll_name%type;

	l_overpaid_flag varchar2(1);
	l_no_data_found varchar2(1);

  BEGIN
    --
    l_proc  := g_package || 'run';
    retcode := 0;
    l_overpaid_flag := 'N';
    l_no_data_found := 'Y';

    hr_utility.set_location('Entering: ' || l_proc, 10);


    -- Correct the action contexts.
       upgrade_action_contexts(p_bg_id);
    --

    OPEN  csr_business_group;
    FETCH csr_business_group into l_business_group_name;
    CLOSE csr_business_group;

    OPEN  csr_date;
    FETCH csr_date into l_date;
    CLOSE csr_date;

    hr_utility.set_location('Leaving: ' || l_proc, 20);
    fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,'                                  Court order details for employees in : '||rpad(l_business_group_name,30));
    fnd_file.put_line(FND_FILE.OUTPUT,'                                                   report date : '|| l_date);
    fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');
    fnd_file.put_line(FND_FILE.OUTPUT, rpad('Payroll Name',20)||'  '||rpad('Employee Name',20)||'  '||rpad('National Identifier',20)||'  '||rpad(lpad('Initial Debt',12),12)||'  '||
    rpad('Reference',20)||'  '||rpad(lpad('Paid to Date',15), 15)||'  '||rpad('Overpaid',8));
    fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');


    OPEN  csr_defined_balance_id;
    FETCH csr_defined_balance_id into l_defined_balance_id;
    CLOSE csr_defined_balance_id;

    for v_csr_person in csr_person_det
    loop
       OPEN  csr_get_payroll(v_csr_person.person_id);
       FETCH csr_get_payroll into v_payroll;
       CLOSE csr_get_payroll;

        for v_csr_actions in csr_asg_actions(v_csr_person.person_id, l_defined_balance_id)
        loop
           OPEN  csr_intial_debt(v_csr_actions.assignment_action_id,v_csr_actions.paid_value,v_csr_actions.context_value);
	   FETCH csr_intial_debt into v_initial_det;
	   l_no_data_found := 'N';
	   CLOSE csr_intial_debt;

	   if  nvl(v_csr_actions.paid_value,'0') > nvl(v_initial_det.result_value,'0')  then
                   l_overpaid_flag := 'Y';
           else
	           l_overpaid_flag := 'N';
	   end if;

	IF p_overpaid = 'Y' then
	/* To print only over paid employees*/
	 if  nvl(v_csr_actions.paid_value,'0') > nvl(v_initial_det.result_value,'0')  then
          if csr_asg_actions%rowcount = 1 then

            fnd_file.put_line(FND_FILE.OUTPUT,rpad(v_payroll,20)||'  '||rpad(v_csr_person.full_name,20)||'  '||rpad(v_csr_person.national_identifier,20)||'  '||
            rpad(lpad(to_char(to_number(v_initial_det.result_value),'FM999999990D00'),12),12,' ')||'  '||
	    rpad(v_csr_actions.context_value,20)||'  '||rpad(lpad(to_char(to_number(v_csr_actions.paid_value),'FM999999999990D00'),15),15, ' ')||'  '||l_overpaid_flag);
          else
	    fnd_file.put_line(FND_FILE.OUTPUT,rpad(' ',20)||'  '||rpad(' ',20)||'  '||rpad(' ',20)||'  '||
	    rpad(lpad(to_char(to_number(v_initial_det.result_value),'FM999999990D00'),12),12,' ')||'  '||
	    rpad(v_csr_actions.context_value,20)||'  '||rpad(lpad(to_char(to_number(v_csr_actions.paid_value),'FM999999999990D00'),15),15,' ')||'  '||l_overpaid_flag);
	  end if;
	  end if;
         ELSE
          if csr_asg_actions%rowcount = 1 then

           fnd_file.put_line(FND_FILE.OUTPUT,rpad(v_payroll,20)||'  '||rpad(v_csr_person.full_name,20)||'  '||rpad(v_csr_person.national_identifier,20)||'  '||
           rpad(lpad(to_char(to_number(v_initial_det.result_value),'FM999999990D00'),12),12,' ')||'  '||
	   rpad(v_csr_actions.context_value,20)||'  '||rpad(lpad(to_char(to_number(v_csr_actions.paid_value),'FM999999999990D00'),15),15,' ')||'  '||l_overpaid_flag);
          else
           fnd_file.put_line(FND_FILE.OUTPUT,rpad(' ',20)||'  '||rpad(' ',20)||'  '||rpad(' ',20)||'  '||
	   rpad(lpad(to_char(to_number(v_initial_det.result_value),'FM999999990D00'),12),12,' ')||'  '||
           rpad(v_csr_actions.context_value,20)||'  '||rpad(lpad(to_char(to_number(v_csr_actions.paid_value),'FM999999999990D00'),15),15, ' ')||'  '||l_overpaid_flag);
          end if;
	 END IF;
       end loop;
    end loop;

if l_no_data_found = 'Y' THEN
    fnd_file.put_line(FND_FILE.OUTPUT,'--------------------------------------------------------No Data Found --------------------------------------------------------------');
end if;

    --
  EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		errbuf  := NULL;
		retcode := 2;
		RAISE_APPLICATION_ERROR(-20001, SQLERRM);
  END run;
  --
END pay_gb_court_order_upgrade;

/
