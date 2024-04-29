--------------------------------------------------------
--  DDL for Package Body HXT_TIMECARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIMECARD_API" AS
/* $Header: hxttapi.pkb 120.6.12010000.1 2008/07/25 09:50:46 appldev ship $ */

/* Begin ER180 - accrual balance*/
g_debug boolean := hr_utility.debug_enabled;
PROCEDURE obtain_accrual_balance
               (--HXT11i1 i_employee_number IN VARCHAR2,
                  i_employee_id             IN NUMBER,       --HXT11i1
                  i_calculation_date        IN DATE,
                  i_accrual_plan_name       IN VARCHAR2,
                  o_net_accrual             OUT NOCOPY NUMBER,
                  o_otm_error               OUT NOCOPY VARCHAR2,
                  o_oracle_error            OUT NOCOPY VARCHAR2) IS

CURSOR assignment_cur IS
SELECT asg.payroll_id,
       asg.assignment_number,
       asg.assignment_id,
       asg.business_group_id
  FROM per_assignments_f asg
     --HXT11i1 per_people_f per
 WHERE asg.person_id = i_employee_id  --HXT11i1
     --HXT11i1 per.employee_number = i_employee_number
     --HXT11i1 AND per.person_id = asg.person_id
   AND asg.assignment_type = 'E'     --HXT11i1
   AND asg.primary_flag = 'Y'        --HXT11i1
     --HXT11i1 AND i_calculation_date between per.effective_start_date
     --HXT11i1                           and per.effective_end_date
   AND i_calculation_date between asg.effective_start_date
                              and asg.effective_end_date;

CURSOR accrual_details_cur (p_accrual_plan_name VARCHAR2,
                            p_business_group_id NUMBER)    IS
SELECT pap.accrual_category,
       pap.accrual_plan_id
 FROM pay_accrual_plans pap
WHERE pap.accrual_plan_name=p_accrual_plan_name
  AND pap.business_group_id=p_business_group_id;


 l_accrual_category pay_accrual_plans.accrual_category%TYPE := NULL;
 l_accrual_plan_name pay_accrual_plans.accrual_plan_name%TYPE := NULL;
 l_accrual_plan_id pay_accrual_plans.accrual_plan_id%TYPE := NULL;
 l_payroll_id per_assignments_f.payroll_id%TYPE := NULL;
 l_assignment_number per_assignments_f.assignment_number%TYPE := NULL;
 l_assignment_id per_assignments_f.assignment_id%TYPE := NULL;
 l_business_group_id per_assignments_f.business_group_id%TYPE := NULL;
 l_net_accrual_amt NUMBER (7,3);
 l_calculation_date DATE := i_calculation_date;
 l_display_error VARCHAR2(120);
 l_oracle_error VARCHAR2(512);

 assignment_not_found EXCEPTION;
 accrual_not_found EXCEPTION;

BEGIN

   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	  hr_utility.set_location('hxt_timecard_api.obtain_accrual_balance',10);
   end if;
   OPEN assignment_cur;
   FETCH assignment_cur
    INTO l_payroll_id,
         l_assignment_number,
         l_assignment_id,
         l_business_group_id;
   IF assignment_cur%NOTFOUND THEN
      if g_debug then
      	      hr_utility.set_location('hxt_timecard_api.obtain_accrual_balance',20);
      end if;
      CLOSE assignment_cur;
      RAISE assignment_not_found;
   END IF;
   CLOSE assignment_cur;

   OPEN accrual_details_cur(i_accrual_plan_name, l_business_group_id);
   FETCH accrual_details_cur
    INTO l_accrual_category,
         l_accrual_plan_id;
   IF accrual_details_cur%NOTFOUND THEN
      if g_debug then
      	     hr_utility.set_location('hxt_timecard_api.obtain_accrual_balance',30);
      end if;
      CLOSE accrual_details_cur;
      RAISE accrual_not_found;
   END IF;
   CLOSE accrual_details_cur;

   HXT_UTIL.DEBUG('l_calcuation_datet is '|| (l_calculation_date));

   l_net_accrual_amt := pay_us_pto_accrual.get_net_accrual(
	                     P_assignment_id	=> l_assignment_id,
	                     P_calculation_date	=> l_calculation_date,
	                     P_plan_id		=> l_accrual_plan_id,
	                     P_plan_category	=> NULL);  -- Do not pass Acc Category (ER180)

    o_net_accrual := l_net_accrual_amt;

    HXT_UTIL.DEBUG('The net accrual amount is '|| TO_CHAR(l_net_accrual_amt));
    HXT_UTIL.DEBUG('sysdate '|| (sysdate));

    RETURN;

EXCEPTION
    WHEN assignment_not_found THEN
        if g_debug then
        	hr_utility.set_location('hxt_timecard_api.obtain_accrual_balance',40);
        end if;
        FND_MESSAGE.SET_NAME('HXT','HXT_39306_ASSIGN_NF');
        --HXT11iiFND_MESSAGE.SET_TOKEN('EMP_NUMBER',i_employee_number);
		FND_MESSAGE.SET_TOKEN('EMP_NUMBER',l_assignment_number);
        l_display_error := FND_MESSAGE.GET;
        l_oracle_error := SQLERRM;
        HXT_UTIL.DEBUG(l_display_error);
        HXT_UTIL.DEBUG(l_oracle_error);
        o_otm_error := l_display_error;
        o_oracle_error := l_oracle_error;
        RETURN;
    WHEN accrual_not_found THEN
        if g_debug then
        	hr_utility.set_location('hxt_timecard_api.obtain_accrual_balance',50);
        end if;
        FND_MESSAGE.SET_NAME('HXT','HXT_39511_ACCRUAL_PLAN_NF');
        l_display_error := FND_MESSAGE.GET;
        l_oracle_error := SQLERRM;
        HXT_UTIL.DEBUG(l_display_error);
        HXT_UTIL.DEBUG(l_oracle_error);
        o_otm_error := l_display_error;
        o_oracle_error := l_oracle_error;
        RETURN;
    WHEN OTHERS THEN
        if g_debug then
        	hr_utility.set_location('hxt_timecard_api.obtain_accrual_balance',60);
        end if;
        FND_MESSAGE.SET_NAME('HXT','HXT_39512_OTH_OAB_ERROR');
        l_display_error := FND_MESSAGE.GET;
        l_oracle_error := SQLERRM;
        HXT_UTIL.DEBUG(l_display_error);
        HXT_UTIL.DEBUG(l_oracle_error);
        o_otm_error := l_display_error;
	o_oracle_error := l_oracle_error;
	RETURN;
END obtain_accrual_balance;
-------------------------------------------------------------------------------
/* Begin ER180 - accrual balance*/
PROCEDURE accrual_plan_name(p_element_type_id        IN  NUMBER,
                            p_date_worked            IN  DATE,
                            p_assignment_id          IN  NUMBER,
                            o_accrual_plan_name      OUT NOCOPY VARCHAR2,
                            o_return_code            OUT NOCOPY NUMBER,
                            o_otm_error              OUT NOCOPY VARCHAR2,
                            o_oracle_error           OUT NOCOPY VARCHAR2) IS

/* -------------------- New Query for Acc plan for an Emp --------------------*/

  CURSOR acc_plan_cur IS
  SELECT PAP.ACCRUAL_PLAN_NAME
  FROM  PAY_ACCRUAL_PLANS PAP,
        PAY_ELEMENT_TYPES_F PETF,
        HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV,
        PAY_NET_CALCULATION_RULES PNC,
        PAY_INPUT_VALUES_F PIV
  WHERE PETF.ELEMENT_TYPE_ID  = p_element_type_id
	AND PETF.ELEMENT_TYPE_ID = ELTV.ELEMENT_TYPE_ID
	AND ELTV.hxt_earning_category = 'ABS'
 	AND  ((PNC.ACCRUAL_PLAN_ID = PAP.ACCRUAL_PLAN_ID)
	AND  ( PNC.INPUT_VALUE_ID  = PIV.INPUT_VALUE_ID)
	AND  ( PIV.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID)
	AND (P_DATE_WORKED BETWEEN PIV.EFFECTIVE_START_DATE AND PIV.EFFECTIVE_END_DATE))
	AND  p_date_worked  BETWEEN PETF.EFFECTIVE_START_DATE
	AND  PETF.EFFECTIVE_END_DATE
	AND  p_date_worked  BETWEEN ELTV.EFFECTIVE_START_DATE
	AND  ELTV.EFFECTIVE_END_DATE
	AND  EXISTS
       		(SELECT 1
		        FROM 	PAY_ELEMENT_TYPES_F PETF1,
			PAY_ELEMENT_CLASSIFICATIONS PEC,
			PAY_ELEMENT_ENTRIES_F PEEF,
			PAY_ELEMENT_LINKS_F PELF,
			PAY_ACCRUAL_PLANS PAP1
        	WHERE
		    PEEF.ASSIGNMENT_ID = p_assignment_id
	        AND PETF1.CLASSIFICATION_ID=PEC.CLASSIFICATION_ID
        	-- AND UPPER(PEC.CLASSIFICATION_NAME) LIKE UPPER('PTO Accrual%')
	 	AND PETF1.ELEMENT_TYPE_ID=PELF.ELEMENT_TYPE_ID
 		AND PEEF.ELEMENT_LINK_ID=PELF.ELEMENT_LINK_ID
		AND p_date_worked  BETWEEN PETF1.EFFECTIVE_START_DATE
		AND PETF1.EFFECTIVE_END_DATE
		AND p_date_worked  BETWEEN PEEF.EFFECTIVE_START_DATE -- Bug fix for st.date
		AND PEEF.EFFECTIVE_END_DATE			     -- and end.date ...
		AND PETF1.ELEMENT_TYPE_ID = PAP1.ACCRUAL_PLAN_ELEMENT_TYPE_ID
		AND PAP1.ACCRUAL_PLAN_NAME=PAP.ACCRUAL_PLAN_NAME);

/* ------------------- End of New Query for Acc plan for an Emp --------------*/

  l_accrual_plan_name  VARCHAR2(80);
  l_accrual_plan_element_type_id NUMBER;
  l_display_error VARCHAR2(120);
  l_oracle_error VARCHAR2(512);
  l_count        NUMBER :=0 ;

  no_element_for_accrual_plan   EXCEPTION;
  employee_not_tied_to_accrual  EXCEPTION;


  /*Note: for finding the accrual plan name.*/

BEGIN

   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	  hr_utility.set_location('hxt_timecard_api.accrual_plan_name',10);
   end if;
   o_return_code := 0;
   o_accrual_plan_name := NULL;

   OPEN acc_plan_cur;
   LOOP
      if g_debug then
      	      hr_utility.set_location('hxt_timecard_api.accrual_plan_name',20);
      end if;
      FETCH acc_plan_cur  INTO l_accrual_plan_name;
      EXIT WHEN acc_plan_cur%NOTFOUND;
   END LOOP;

   IF acc_plan_cur%ROWCOUNT = 0 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_timecard_api.accrual_plan_name',30);
      end if;
      CLOSE acc_plan_cur;
      o_return_code := 2;             -- Element Not Tied to Accrual Plan
      RETURN;
   END IF;

   HXT_UTIL.DEBUG('rowcount is:'|| to_char(acc_plan_cur%ROWCOUNT));    --DEBUG

   IF acc_plan_cur%ROWCOUNT > 1 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_timecard_api.accrual_plan_name',40);
      end if;

      CLOSE acc_plan_cur;
      o_return_code := 1; -- Too many Accrual Plans linked to the element type
      RETURN;
   END IF;

   o_accrual_plan_name := l_accrual_plan_name;
   o_return_code := 0;
   RETURN;

EXCEPTION

/*WHEN no_element_for_accrual_plan THEN
   o_return_code := 1;
   RETURN;
  WHEN no_data_found THEN
   o_return_code := 2;-- ER 180 Give a Warning Msg, when an element not tied to
   o_return_code := 0;-- Accruals...
   RETURN;  */

  WHEN others THEN
        if g_debug then
        	hr_utility.set_location('hxt_timecard_api.accrual_plan_name',50);
        end if;
        FND_MESSAGE.SET_NAME('HXT','HXT_39513_OTH_APN_ERROR');
        l_display_error := FND_MESSAGE.GET;
        l_oracle_error := SQLERRM;
        HXT_UTIL.DEBUG(l_display_error);
        HXT_UTIL.DEBUG(l_oracle_error);
        o_otm_error := l_display_error;
	o_oracle_error := l_oracle_error;
        o_return_code := 3;
    RETURN;

END accrual_plan_name;
-------------------------------------------------------------------------------
/* Begin ER180 - accrual balance*/
PROCEDURE total_accrual_for_week
                    (p_tim_id                 IN  NUMBER
                    ,p_edit_date              IN  DATE
                  --,HXT11i1 p_empl_number    IN  VARCHAR2
                    ,p_empl_id                IN  NUMBER --HXT11i1
                    ,o_tot_hours              OUT NOCOPY NUMBER
                    ,o_accrual_plan_name      OUT NOCOPY VARCHAR2
                    ,o_return_code            OUT NOCOPY NUMBER
                    ,o_otm_error              OUT NOCOPY VARCHAR2
                    ,o_oracle_error           OUT NOCOPY VARCHAR2
                    ,o_lookup_code            OUT NOCOPY VARCHAR2) IS

 Cursor do_accrual_cur is
    SELECT hours
    FROM   hxt_pay_element_types_f_ddf_v eltv
          ,pay_element_types_f elt
          ,PAY_ACCRUAL_PLANS pap
          ,PAY_NET_CALCULATION_RULES net
          ,PAY_INPUT_VALUES_F piv
          ,hxt_sum_hours_worked sm
          ,per_assignments_f asm
    WHERE elt.element_type_id = eltv.element_type_id
    AND   eltv.hxt_earning_category = 'ABS'
    AND   sm.date_worked  BETWEEN ELT.EFFECTIVE_START_DATE
                              AND ELT.EFFECTIVE_END_DATE
    AND   sm.date_worked  BETWEEN ELTV.EFFECTIVE_START_DATE
                              AND ELTV.EFFECTIVE_END_DATE
    AND   net.ACCRUAL_PLAN_ID = pap.ACCRUAL_PLAN_ID
    AND   net.INPUT_VALUE_ID = piv.INPUT_VALUE_ID
    AND   piv.ELEMENT_TYPE_ID = elt.ELEMENT_TYPE_ID
    AND   sm.element_type_id = elt.element_type_id
    AND   asm.assignment_id = sm.assignment_id
    AND   sm.date_worked between asm.effective_start_date
    AND   asm.effective_end_date
    AND   sm.tim_id = p_tim_id
 -- Begin ER180, to find accrual plan assigned for an emp.
    AND   PAP.ACCRUAL_PLAN_NAME IN
     	    (SELECT PAP1.ACCRUAL_PLAN_NAME
	     FROM   PAY_ELEMENT_TYPES_F PETF1,
	            PAY_ELEMENT_CLASSIFICATIONS PEC,
		    PAY_ELEMENT_ENTRIES_F PEEF,
		    PAY_ELEMENT_LINKS_F PELF,
		    PAY_ACCRUAL_PLANS PAP1
             WHERE  PEEF.ASSIGNMENT_ID = sm.assignment_id
	     AND    PETF1.CLASSIFICATION_ID=PEC.CLASSIFICATION_ID
             -- AND    UPPER(PEC.CLASSIFICATION_NAME) LIKE UPPER('PTO Accrual%')
	     AND    PETF1.ELEMENT_TYPE_ID=PELF.ELEMENT_TYPE_ID
 	     AND    PEEF.ELEMENT_LINK_ID=PELF.ELEMENT_LINK_ID
	     AND    sm.date_worked  BETWEEN PETF1.EFFECTIVE_START_DATE
	     AND    PETF1.EFFECTIVE_END_DATE
	     AND    sm.date_worked  BETWEEN PEEF.EFFECTIVE_START_DATE
	     AND    PEEF.EFFECTIVE_END_DATE
	     AND    PETF1.ELEMENT_TYPE_ID = PAP1.ACCRUAL_PLAN_ELEMENT_TYPE_ID);
 -- End ER180

 CURSOR accrual_cur(p_date_worked hxt_sum_hours_worked.date_worked%TYPE) IS
   SELECT distinct pap.accrual_plan_name
   FROM   hxt_pay_element_types_f_ddf_v eltv
         ,pay_element_types_f elt
         ,PAY_ACCRUAL_PLANS pap
         ,PAY_NET_CALCULATION_RULES net
         ,PAY_INPUT_VALUES_F piv
         ,hxt_sum_hours_worked sm
         ,per_assignments_f asm
         ,per_people_f ppl                              -- ER180 Bug Fix
   WHERE  elt.element_type_id = eltv.element_type_id
   AND    eltv.hxt_earning_category = 'ABS'
   AND    sm.date_worked = p_date_worked
   AND    sm.date_worked  BETWEEN ELT.EFFECTIVE_START_DATE
                              AND ELT.EFFECTIVE_END_DATE
   AND    sm.date_worked  BETWEEN ELTV.EFFECTIVE_START_DATE
                              AND ELTV.EFFECTIVE_END_DATE
   AND    net.ACCRUAL_PLAN_ID = pap.ACCRUAL_PLAN_ID
   AND    net.INPUT_VALUE_ID  = piv.INPUT_VALUE_ID
   AND    piv.ELEMENT_TYPE_ID = elt.ELEMENT_TYPE_ID
   AND    sm.element_type_id  = elt.element_type_id
   AND    asm.assignment_id   = sm.assignment_id
   AND    sm.tim_id           = p_tim_id
   AND    sm.date_worked between asm.effective_start_date
                             and asm.effective_end_date
   AND    asm.person_id       = ppl.person_id
-- HXT11i1AND ppl.employee_number = p_empl_number        -- ER180 Bug Fix
   AND    ppl.person_id       = p_empl_id                -- HXT11i1
   AND    sm.date_worked between ppl.effective_start_date-- ER180 Bug Fix
                             and ppl.effective_end_date  -- ER180 Bug Fix
-- Begin ER180, to find accrual plan assigned for an emp
   AND    PAP.ACCRUAL_PLAN_NAME IN
   	   (SELECT PAP1.ACCRUAL_PLAN_NAME
            FROM   PAY_ELEMENT_TYPES_F PETF1
                  ,PAY_ELEMENT_CLASSIFICATIONS PEC
                  ,PAY_ELEMENT_ENTRIES_F PEEF
	          ,PAY_ELEMENT_LINKS_F PELF
	          ,PAY_ACCRUAL_PLANS PAP1
            WHERE  PEEF.ASSIGNMENT_ID = sm.assignment_id
	    AND    PETF1.CLASSIFICATION_ID=PEC.CLASSIFICATION_ID
            -- AND    UPPER(PEC.CLASSIFICATION_NAME) LIKE UPPER('PTO Accrual%')
	    AND    PETF1.ELEMENT_TYPE_ID=PELF.ELEMENT_TYPE_ID
 	    AND    PEEF.ELEMENT_LINK_ID=PELF.ELEMENT_LINK_ID
	    AND    sm.date_worked  BETWEEN PETF1.EFFECTIVE_START_DATE
	    AND    PETF1.EFFECTIVE_END_DATE
	    AND    sm.date_worked  BETWEEN PEEF.EFFECTIVE_START_DATE
	    AND    PEEF.EFFECTIVE_END_DATE
	    AND    PETF1.ELEMENT_TYPE_ID = PAP1.ACCRUAL_PLAN_ELEMENT_TYPE_ID);
-- End ER180

 Cursor on_timecard_cur(p_accrual_plan_name VARCHAR2) is
  SELECT sum(sm.hours*(-1)*(net.add_or_subtract))
  FROM   hxt_pay_element_types_f_ddf_v eltv
        ,pay_element_types_f elt
        ,PAY_ACCRUAL_PLANS pap
        ,PAY_NET_CALCULATION_RULES net
        ,PAY_INPUT_VALUES_F piv
        ,hxt_sum_hours_worked sm
        ,per_assignments_f asm
  WHERE  elt.element_type_id = eltv.element_type_id
  AND    eltv.hxt_earning_category = 'ABS'
  AND    net.ACCRUAL_PLAN_ID = pap.ACCRUAL_PLAN_ID
  AND    pap.accrual_plan_name = p_accrual_plan_name
  AND    net.INPUT_VALUE_ID = piv.INPUT_VALUE_ID
  AND    piv.ELEMENT_TYPE_ID = elt.ELEMENT_TYPE_ID
  AND    sm.element_type_id = elt.element_type_id
  AND    asm.assignment_id = sm.assignment_id
  AND    sm.date_worked between asm.effective_start_date
                            and asm.effective_end_date
  AND    sm.date_worked between piv.effective_start_date
	              and piv.effective_end_date
  AND    sm.tim_id = p_tim_id;


cursor get_max_retro_batch is
  select max(batch_id) from pay_batch_headers pbh
  where pbh.batch_status='T'
  and pbh.batch_id in (select distinct retro_batch_id from hxt_det_hours_worked_f
  where tim_id=p_tim_id);


cursor chk_retro_batch_status is
  select batch_id from pay_batch_headers pbh
  where pbh.batch_status='T'
  and pbh.batch_id in (select distinct retro_batch_id from hxt_det_hours_worked_f
  where tim_id=p_tim_id);


cursor chk_original_batch_status is
  select null from pay_batch_headers pbh
  where pbh.batch_status='T'
  and pbh.batch_id in (select distinct batch_id from hxt_timecards_f
  where id=p_tim_id);

cursor get_retro_total(p_accrual_plan_name VARCHAR2,p_batch_id number) is
SELECT nvl(sum(det.hours*(-1)*(net.add_or_subtract)),0)
  FROM   hxt_pay_element_types_f_ddf_v eltv
        ,pay_element_types_f elt
        ,PAY_ACCRUAL_PLANS pap
        ,PAY_NET_CALCULATION_RULES net
        ,PAY_INPUT_VALUES_F piv
        ,hxt_det_hours_worked_f det
        ,per_assignments_f asm
  WHERE  elt.element_type_id = eltv.element_type_id
  AND    eltv.hxt_earning_category = 'ABS'
  AND    net.ACCRUAL_PLAN_ID = pap.ACCRUAL_PLAN_ID
  AND    pap.accrual_plan_name = p_accrual_plan_name
  AND    net.INPUT_VALUE_ID = piv.INPUT_VALUE_ID
  AND    piv.ELEMENT_TYPE_ID = elt.ELEMENT_TYPE_ID
  AND    det.element_type_id = elt.element_type_id
  AND    asm.assignment_id = det.assignment_id
  AND    det.date_worked between asm.effective_start_date
                            and asm.effective_end_date
  AND    det.date_worked between piv.effective_start_date
	              and piv.effective_end_date
  AND    det.tim_id = p_tim_id
  and    det.retro_batch_id=p_batch_id;


cursor get_org_total(p_accrual_plan_name VARCHAR2) is
SELECT nvl(sum(det.hours*(-1)*(net.add_or_subtract)),0)
  FROM   hxt_pay_element_types_f_ddf_v eltv
        ,pay_element_types_f elt
        ,PAY_ACCRUAL_PLANS pap
        ,PAY_NET_CALCULATION_RULES net
        ,PAY_INPUT_VALUES_F piv
        ,hxt_det_hours_worked_f det
        ,per_assignments_f asm
  WHERE  elt.element_type_id = eltv.element_type_id
  AND    eltv.hxt_earning_category = 'ABS'
  AND    net.ACCRUAL_PLAN_ID = pap.ACCRUAL_PLAN_ID
  AND    pap.accrual_plan_name = p_accrual_plan_name
  AND    net.INPUT_VALUE_ID = piv.INPUT_VALUE_ID
  AND    piv.ELEMENT_TYPE_ID = elt.ELEMENT_TYPE_ID
  AND    det.element_type_id = elt.element_type_id
  AND    asm.assignment_id = det.assignment_id
  AND    det.date_worked between asm.effective_start_date
                            and asm.effective_end_date
  AND    det.date_worked between piv.effective_start_date
	              and piv.effective_end_date
  AND    det.tim_id = p_tim_id
  and    det.retro_batch_id is null;

  cursor get_tc_dates(p_tim_id NUMBER) is
   SELECT date_worked
   FROM hxt_det_hours_worked_f det,
	hxt_pay_element_types_f_ddf_v eltv
   WHERE det.tim_id=p_tim_id
     AND    eltv.hxt_earning_category = 'ABS'
     AND    det.element_type_id = eltv.element_type_id
   ORDER BY det.date_worked;





  l_hours              NUMBER;
  l_accrual_plan_name  VARCHAR2(80);
  l_net_accrual        NUMBER (7,3);
  l_display_error      VARCHAR2(1200);
  l_oracle_error       VARCHAR2(512);
  v_otm_error          VARCHAR2(1200);
  v_oracle_error       VARCHAR2(512);
  l_batch_id           NUMBER;
  l_old_total          NUMBER;
  l_date_worked        hxt_det_hours_worked_f.date_worked%TYPE;
  l_flag_acc_exceeded  NUMBER(1);

--no_accrual_plan      EXCEPTION;
  no_summary_rows      EXCEPTION;
  accrual_exceeded     EXCEPTION;
  obtain_error         EXCEPTION;


BEGIN

   l_flag_acc_exceeded := 0;
   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	  hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',10);
   end if;
   open do_accrual_cur;
-- HXT_UTIL.DEBUG('do acc cur :'||to_char(l_hours));
   fetch do_accrual_cur into l_hours;
-- HXT_UTIL.DEBUG('do acc cur :'||to_char(l_hours));
   if do_accrual_cur%NOTFOUND then
      if g_debug then
      	      hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',20);
      end if;
      close do_accrual_cur;
      o_return_code  := 0;
      o_otm_error    := NULL;
      o_oracle_error := NULL;
      o_lookup_code  := NULL;
      return;
   end if;
   close do_accrual_cur;

  FOR tc_rec IN get_tc_dates(p_tim_id) LOOP
   l_date_worked := tc_rec.date_worked;
   FOR accrual_rec IN accrual_cur(l_date_worked) LOOP
      if g_debug then
              hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',30);
      end if;
      l_accrual_plan_name := accrual_rec.accrual_plan_name;
      HXT_UTIL.DEBUG('Acc plan is:'||l_accrual_plan_name);
    --HXT_UTIL.DEBUG('accrual_rec.element_type_id is '||to_char(accrual_rec.element_type_id));

      open on_timecard_cur(l_accrual_plan_name);
      fetch on_timecard_cur into l_hours;
    --HXT_UTIL.DEBUG('timecard cur:'||to_char(l_hours));
      if on_timecard_cur%NOTFOUND  then
         if g_debug then
         	hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',40);
         end if;
         close on_timecard_cur;
         RAISE no_summary_rows;
      end if;
      close on_timecard_cur;

     l_batch_id:=0;
     l_old_total:=0;

	--check if timecard has been retro edited and is transferred to payroll

     open chk_retro_batch_status ;
     fetch chk_retro_batch_status  into l_batch_id;

     	if chk_retro_batch_status %notfound then

            -- if timecard has been retro edited but not transferred to payroll
            -- or it is new timecard

     	    l_batch_id :=0;
  	    open chk_original_batch_status  ;
  	    fetch chk_original_batch_status   into l_batch_id;
  	    if chk_original_batch_status  %notfound then

	 --it is new timecard

  	       l_batch_id :=0;
  	    end if;
     	    close chk_original_batch_status  ;
     	else

             -- since the retro batch exists get the last batch_id

     	  open get_max_retro_batch  ;
	  fetch get_max_retro_batch into l_batch_id;
        close get_max_retro_batch  ;
     	end if;
     close chk_retro_batch_status ;



      if(l_batch_id is not null )  then

         -- get the hours corresponding to retro batch

      open get_retro_total(l_accrual_plan_name,l_batch_id);
      fetch get_retro_total into l_old_total;

        if(get_retro_total%notfound) then
         l_old_total:=0;
        end if;
      close get_retro_total;

else
      -- get the hours corresponding to non retro timecard

      open get_org_total(l_accrual_plan_name);
         fetch get_org_total into l_old_total;
            if(get_org_total%notfound) then
             l_old_total:=0;
      	end if;
      close get_org_total;
      end if;

      if g_debug then
      	     hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',50);
      end if;
      HXT_TIMECARD_API.obtain_accrual_balance
                             (--HXT11i1 p_empl_number,
                                p_empl_id              --HXT11i1
                               ,l_date_worked
                               ,l_accrual_plan_name
                               ,l_net_accrual
                               ,v_otm_error
                               ,v_oracle_error);

      HXT_UTIL.DEBUG('params for o a b is:'||p_empl_id||
        ':'||fnd_date.date_to_chardate(l_date_worked)||'Net acc is:'||to_char(l_net_accrual));
      HXT_UTIL.DEBUG('Erros from ob acc bal :'||v_otm_error||v_oracle_error);
      if v_otm_error is not null then
         if g_debug then
         	hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',60);
         end if;
         raise obtain_error;
      end if;
      if (nvl((l_hours-l_old_total),0) > l_net_accrual) then
          if g_debug then
          	 hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',70);
          end if;

          if(l_display_error IS NULL) then
               if g_debug then
                     hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',70.1);
               end if;

	       -- CREATE AND ADD THE MESSAGE
               FND_MESSAGE.SET_NAME('HXT','HXT_39509_ACCRUAL_EXCEEDED');
               FND_MESSAGE.SET_TOKEN('ACCPLAN', l_accrual_plan_name);
               FND_MESSAGE.SET_TOKEN('ACCHRS', to_char(l_net_accrual));

	       l_display_error := FND_MESSAGE.GET;
	  else
	       -- IF A MESSAGE HAS BEEN ALREADY ADDED FOR AN ACCRUAL PLAN, DO NOT ADD IT
               if(instr(l_display_error, l_accrual_plan_name) = 0) then
                     if g_debug then
                          hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',70.2);
                     end if;
	             FND_MESSAGE.SET_NAME('HXT','HXT_39509_ACCRUAL_EXCEEDED');
	             FND_MESSAGE.SET_TOKEN('ACCPLAN', l_accrual_plan_name);
	             FND_MESSAGE.SET_TOKEN('ACCHRS', to_char(l_net_accrual));
		     --ADD MESSAGE WITH A NEW LINE
	             l_display_error := l_display_error ||'
'|| FND_MESSAGE.GET;
	       end if;
	  end if;

         l_flag_acc_exceeded := 1;
	 --RAISE ERROR ONLY AFTER ADDING VALIDATION MESSAGES FOR ALL THE ACCRUAL PLANS
         --raise obtain_error;
      end if;
   END LOOP;
  END LOOP;

  if(l_flag_acc_exceeded = 1) then
     raise accrual_exceeded;
  end if;



   o_return_code  := 0;
   o_otm_error    := NULL;
   o_oracle_error := NULL;
   o_lookup_code  := NULL;
-- HXT_UTIL.DEBUG('l_accrual_plan_name is '|| (l_accrual_plan_name));
-- HXT_UTIL.DEBUG('l_tot_hours is '||to_char(l_tot_hours));

RETURN;

EXCEPTION
--  WHEN no_accrual_plan THEN
--     o_return_code := 1;
--	l_display_error := 'Other error from total_accrual_for_week procedure';
--        l_oracle_error := SQLERRM;
--        HXT_UTIL.DEBUG(l_display_error);
--        HXT_UTIL.DEBUG(l_oracle_error);
--        o_otm_error := l_display_error;
--	o_oracle_error := l_oracle_error;
--     o_return_code := 3;
--     RETURN;

  WHEN no_summary_rows THEN
       if g_debug then
       	      hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',80);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39514_NO_TIMECARD_ROWS');
       l_display_error := FND_MESSAGE.GET;
       HXT_UTIL.DEBUG(l_display_error);
       o_otm_error     := l_display_error;
       o_oracle_error  := NULL;
       o_return_code   := 1;
       o_lookup_code   := NULL;
       RETURN;

  WHEN accrual_exceeded THEN
       if g_debug then
       	      hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',90);
       end if;
       -- FND_MESSAGE.SET_NAME('HXT','HXT_39509_ACCRUAL_EXCEEDED');
       -- FND_MESSAGE.SET_TOKEN('ACCPLAN', l_accrual_plan_name);
       -- FND_MESSAGE.SET_TOKEN('ACCHRS', to_char(l_net_accrual));
       -- l_display_error     := FND_MESSAGE.GET;
       HXT_UTIL.DEBUG(l_display_error);
       o_otm_error         := l_display_error;
       o_oracle_error      := NULL;
       o_accrual_plan_name := l_accrual_plan_name;
       o_return_code       := 1;
       o_lookup_code       := 'ACCRUAL_EXCEEDED';
       RETURN;

  WHEN obtain_error THEN
       if g_debug then
       	      hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',100);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39515_TAFW_OAB_ERROR');
       l_display_error := FND_MESSAGE.GET || ' ' || v_otm_error;
       l_oracle_error  := v_oracle_error;
       HXT_UTIL.DEBUG(l_display_error);
       HXT_UTIL.DEBUG(l_oracle_error);
       o_otm_error     := l_display_error;
       o_oracle_error  := l_oracle_error;
       o_return_code   := 1;
       o_lookup_code   := NULL;
       RETURN;

  WHEN others THEN
       if g_debug then
       	      hr_utility.set_location('hxt_timecard_api.total_accrual_for_week',110);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39516_OTH_TAFW_ERROR');
       l_display_error := FND_MESSAGE.GET;
       l_oracle_error  := SQLERRM;
       HXT_UTIL.DEBUG(l_display_error);
       HXT_UTIL.DEBUG(l_oracle_error);
       o_otm_error     := l_display_error;
       o_oracle_error  := l_oracle_error;
       o_return_code   := 1;
       o_lookup_code   := NULL;
       RETURN;

END total_accrual_for_week;
/*End ER180 - accrual balance*/

END HXT_TIMECARD_API;

/
