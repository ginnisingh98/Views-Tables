--------------------------------------------------------
--  DDL for Package Body PQP_CLM_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_CLM_BAL" AS
/* $Header: pqpvmbal.pkb 115.2 2003/06/25 11:48:50 jcpereir noship $*/
-- This Function return Element Level balances given the Balance Name, Element Entry Id
-- and Assignment Action Id
FUNCTION get_vehicletype_balance
  (p_assignment_id                    IN number
  ,p_business_group_id                IN number
  ,p_vehicle_type                     IN varchar2
  ,p_ownership                        IN varchar2
  ,p_usage_type                       IN varchar2
  ,p_balance_name                     IN varchar2
  ,p_element_entry_id                 IN NUMBER
  ,p_assignment_action_id             IN NUMBER
  ) RETURN NUMBER IS
  --
  --
CURSOR csr_balance IS
select    pet.element_name
         ,pet.business_group_id
         ,ppa.payroll_action_id
         ,prr.source_type
         ,prr.run_result_id
        FROM pay_element_types_f pet
        ,pay_element_type_extra_info pete
        ,pay_run_results       prr
        ,pay_assignment_actions paas
        ,pay_payroll_actions   ppa
        where
        pete.EEI_INFORMATION_CATEGORY='PQP_VEHICLE_MILEAGE_INFO'
        AND pet.element_type_id=pete.element_type_id
        AND pete.EEI_INFORMATION1 in ('C','P','CM','CP','PP','PM')
        AND pet.business_group_id=p_business_group_id
        AND paas.assignment_id =p_assignment_id
        AND paas.assignment_action_id=prr.assignment_action_id
        AND pete.element_type_id=prr.element_type_id
        AND paas.payroll_action_id=ppa.payroll_action_id
        AND ppa.action_type in ('Q','R','V')
        AND paas.action_status='C'
        AND prr.source_id = p_element_entry_id
        AND paas.assignment_action_id = p_assignment_action_id
        AND pete.EEI_INFORMATION1 = nvl(p_vehicle_type,pete.EEI_INFORMATION1)
        AND substr(pete.EEI_INFORMATION1,0,1) = nvl(p_ownership,substr(pete.EEI_INFORMATION1,0,1));

CURSOR c_src_ele_entry_id(cp_run_result_id NUMBER)
IS
Select rr2.source_id
       FROM pay_run_results rr1,
       pay_run_results rr2
       WHERE
       rr1.run_result_id = cp_run_result_id
       AND rr1.source_id = rr2.run_result_id;

--
  lsr_balance     csr_balance%ROWTYPE;
  l_sum           number;
  l_temp_element_entry_id    number;
--
BEGIN

   open csr_balance;
   fetch csr_balance into lsr_balance;
   close csr_balance;
   hr_utility.set_location('SOURCE TYPE  '||lsr_balance.source_type,10);
   IF lsr_balance.source_type = 'R' or lsr_balance.source_type = 'V' THEN
    open c_src_ele_entry_id(lsr_balance.run_result_id);
     fetch c_src_ele_entry_id into l_temp_element_entry_id;
    close c_src_ele_entry_id;
   ELSE
    l_temp_element_entry_id := p_element_entry_id;
   END IF;
   l_sum := pqp_clm_bal.get_balance_value ( lsr_balance.element_name
                                           ,p_assignment_action_id
                                           ,l_temp_element_entry_id
                                           ,lsr_balance.business_group_id
                                           ,lsr_balance.payroll_action_id
                                           ,p_balance_name);
   /*IF lsr_balance.source_type = 'R' or lsr_balance.source_type = 'V' THEN
    l_sum := -l_sum;
   END IF;*/
   return nvl(l_sum,0);

END get_vehicletype_balance;

--
FUNCTION get_balance_value ( p_element_name          IN VARCHAR2
                    ,p_assignment_action_id  IN NUMBER
                    ,p_element_entry_id      IN NUMBER
                    ,p_business_group_id     IN NUMBER
                    ,p_payroll_action_id     IN NUMBER
                    ,p_balance_name          IN VARCHAR2
                    )
return NUMBER
IS
CURSOR c_get_balance_det
IS
SELECT pbt.balance_name,pbt.balance_type_id ,pbd.balance_dimension_id
  FROM pay_balance_types pbt
      ,pay_defined_balances pdb
       ,pay_balance_dimensions pbd
 WHERE balance_name like p_element_name||' '||p_balance_name
   AND pbd.legislation_code='GB'
   AND pbd.dimension_name='_ELEMENT_ITD'
   AND pdb.balance_type_id=pbt.balance_type_id
   AND pdb.balance_dimension_id=pbd.balance_dimension_id
   AND pbt.balance_type_id=pdb.balance_type_id;

cursor c_get_balance_val(cp_balance_type_id       NUMBER
          ,cp_assignment_action_id NUMBER
          ,cp_element_entry_id     NUMBER
          ,cp_payroll_action_id    NUMBER)
is
SELECT  nvl((fnd_number.canonical_to_number(TARGET.result_value)
        * FEED.scale),0) tot
FROM pay_run_result_values   TARGET
,      pay_balance_feeds_f     FEED
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_assignment_actions  BAL_ASSACT
,      pay_payroll_actions     PACT
WHERE  BAL_ASSACT.assignment_action_id = cp_assignment_action_id
AND    FEED.balance_type_id  = cp_balance_type_id
AND    FEED.input_value_id     = TARGET.input_value_id
AND    TARGET.run_result_id    = RR.run_result_id
AND    RR.assignment_action_id = ASSACT.assignment_action_id
AND    ASSACT.payroll_action_id = PACT.payroll_action_id
AND    assact.payroll_action_id = cp_payroll_action_id
AND    PACT.effective_date between FEED.effective_start_date
                               AND FEED.effective_end_date
AND    RR.status in ('P','PA')
AND    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
AND    ASSACT.assignment_id = BAL_ASSACT.assignment_id
AND    (( RR.source_id = cp_element_entry_id and source_type in ( 'E','I'))
 OR    ( rr.source_type in ('R','V') /* reversal */
                AND exists
                ( SELECT null from pay_run_results rr1
                  WHERE rr1.source_id = cp_element_entry_id
                  AND   rr1.run_result_id = rr.source_id
                  AND   rr1.source_type in ( 'E','I'))));




l_get_balance_det        c_get_balance_det%ROWTYPE;
l_get_balance_val        c_get_balance_val%ROWTYPE;
l_balance_type_id        NUMBER := NULL;
l_cache_count            NUMBER;
BEGIN

--Check the Balance Cache for Balance Type Id
 FOR i in 1..g_balance_cache.count
 LOOP
  IF g_balance_cache(i).balance_name = p_element_name||' '||p_balance_name THEN
   l_balance_type_id := g_balance_cache(i).balance_type_id;
   exit;
  END IF;
 END LOOP;

 IF l_balance_type_id IS NULL THEN
  OPEN c_get_balance_det;
  FETCH c_get_balance_det INTO l_get_balance_det;
  CLOSE c_get_balance_det;
  l_balance_type_id := l_get_balance_det.balance_type_id;
  -- Make An Entry in Balance Cache
  l_cache_count := g_balance_cache.count+1;
  g_balance_cache(l_cache_count).balance_name := p_element_name||' '||p_balance_name;
  g_balance_cache(l_cache_count).balance_type_id := l_balance_type_id;
END IF;

 OPEN c_get_balance_val(l_balance_type_id
         ,p_assignment_action_id
         ,p_element_entry_id
         ,p_payroll_action_id);
 FETCH c_get_balance_val INTO l_get_balance_val;
     return(NVL(l_get_balance_val.tot,0));
 CLOSE c_get_balance_val;


return(0);
END;
END PQP_CLM_BAL;

/
