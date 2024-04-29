--------------------------------------------------------
--  DDL for Package Body HXT_PA_USER_EXITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_PA_USER_EXITS" AS
/* $Header: hxtpainf.pkb 120.3 2006/10/13 08:58:45 nissharm noship $ */
g_debug boolean := hr_utility.debug_enabled;


/*******************************************************************************
FUNCTION p_a_interface()

The p_a_interface() logic will insert pay data to the PA_Transaction_Interface
table.Details to be inserted will be passed in as parameters to a function
called p_a_interface.Because the interface to Project Accounting will vary on
different installations,the p_a_interface logic will be stored in the
HXT_USER_EXITS package.HXT_USER_EXITS is designed to contain unique code,
specific to a customers needs.

Following is a list of parameters to the p_a_interface function and the source
of each argument:

i_hours_worked  --  HXT_det_hours_worked_x.hours
i_rate          --  per_pay_proposals.proposed_salary
                      (employees hourly rate)
                 or
                    hxt_det_hours_worked_x.hourly_rate
                      (timecard override hourly rate)
                 or
                    per_pay_proposals.proposed_salary *
                      (employees hourly rate)
                    hxt_det_hours_worked_x.rate_multiple
                      (manually entered multiple from timecard)
                 or
                    per_pay_proposals.proposed_salary *
                      (employees hourly rate)
                    hxt_pay_element_types_f_ddf_v.hxt_premium_amount
                      (multiple from pay element flex)
                 or
                    hxt_pay_element_types_f_ddf_v.hxt_premium_amount/
                      (daily amount from element flex)
                    hxt_det_hours_worked_x.hours
                      (hours worked)
                 or
                    per_pay_proposals.proposed_salary *
                      (employees hourly rate)
                    hxt_pay_element_types_f_ddf_v.hxt_premium_amount - 1.0
                      (non-ot premium multiple from pay element flex minus 1.0)
i_premium_amount -- hxt_pay_element_types_f_ddf_v.hxt_premium_amount
                      (premium amount element flex)
                 or
                    hxt_det_hours_worked_x.amount (timecard override amount)
i_trans_source   --  hxt_pay_element_types_f_ddf_v.hxt_earning_category
                       ||hxt_pay_element_types_f_ddf_v.hxt_premium_type
i_period_end     --  per_time_periods.end_date
i_employee_number--  per_people_f.employee_number

--SIR162i_employment_cat --  fnd_common_lookups.meaning(lookup_type = 'EMP_CAT')
--SIR162i_emp_cat_code   --  per_assignments_f.employment_category

i_oganization_name       --  hr_organization_units.name
i_organization_id        --  hr_organization_units.id
i_date_worked            --  hxt_det_hours_worked_x.date_worked
i_effective_start_date   --  hxt_det_hours_worked_x.effective_start_date
i_effective_end_date     --  hxt_det_hours_worked_x.effective_end_date
i_hours_type             --  hxt_det_hours_worked_x.element_name
i_salary_basis           --  per_pay_proposals_v.pay_basis
i_time_detail_id         --  hxt_det_hours_worked_x.id
i_hxt_earning_category   --  hxt_pay_element_types_f_ddf_v.hxt_earning_category
i_retro_transaction      --  TRUE if  Retro Transaction
                         --  FALSE if Normal Transaction
i_standard_rate          --  per_pay_proposals.proposed_salary
                         --     (employees unmodified base hourly rate)
i_project_id             --  hxt_det_hours_worked_x.project_id
i_task_id                --  hxt_det_hours_worked_x.task_id
i_segment1               --  pa_projects.segment1
i_task_number            --  pa_tasks.task_number
i_project_name           --  pa_projects.name
i_task_name              --  pa_tasks.task_name
i_assignment_id          --  per_assignments_f.assignment_id
i_cost_allocation_keyflex_id --  pay_cost_allocation_keyflex.cost_allocation_keyflex_id
i_job_definition_id      --  per_job_definitions.job_definition_id

*******************************************************************************/

FUNCTION p_a_interface(  i_hours_worked               IN     NUMBER
                        ,i_rate                       IN     NUMBER
                        ,i_premium_amount             IN     NUMBER
                        ,i_trans_source               IN     VARCHAR2
                        ,i_period_end                 IN     DATE
                        ,i_employee_number            IN     VARCHAR2
                        ,i_employment_cat             IN     VARCHAR2
                        ,i_element_type_id            IN     NUMBER   --SIR162
--SIR162                ,i_emp_cat_code               IN     VARCHAR2
                        ,i_organization_name          IN     VARCHAR2
                        ,i_organization_id            IN     NUMBER
                        ,i_date_worked                IN     DATE
                        ,i_effective_start_date       IN     DATE
                        ,i_effective_end_date         IN     DATE
                        ,i_hours_type                 IN     VARCHAR2
                        ,i_salary_basis               IN     VARCHAR2
                        ,i_time_detail_id             IN     NUMBER
                        ,i_hxt_earning_category       IN     VARCHAR2
                        ,i_retro_transaction          IN     BOOLEAN
                        ,i_standard_rate              IN     NUMBER
                        ,i_project_id                 IN     NUMBER
                        ,i_task_id                    IN     NUMBER
                        ,i_segment1                   IN     VARCHAR2
                        ,i_task_number                IN     VARCHAR2
                        ,i_project_name               IN     VARCHAR2
                        ,i_task_name                  IN     VARCHAR2
                        ,i_assignment_id              IN     NUMBER
                        ,i_cost_allocation_keyflex_id IN     NUMBER
                        ,i_job_definition_id          IN     NUMBER
                        ,o_location                      OUT NOCOPY VARCHAR2
                        ,o_error_text                    OUT NOCOPY VARCHAR2
                        ,o_system_text                   OUT NOCOPY VARCHAR2)
          RETURN NUMBER IS

-- Define local variables for each coloumn to ease customizations

l_trans_source    pa_transaction_interface.transaction_source%TYPE DEFAULT NULL;
l_batch_name      pa_transaction_interface.batch_name%TYPE DEFAULT NULL;
l_employee_number pa_transaction_interface.employee_number%TYPE DEFAULT NULL;
l_project_number  pa_transaction_interface.project_number%TYPE DEFAULT NULL;
l_task_number     pa_transaction_interface.task_number%TYPE DEFAULT NULL;
l_quantity        pa_transaction_interface.quantity%TYPE DEFAULT NULL;
l_raw_cost        pa_transaction_interface.raw_cost%TYPE DEFAULT NULL;
l_expenditure_id  pa_transaction_interface.expenditure_id%TYPE DEFAULT NULL;
l_attribute1      pa_transaction_interface.attribute1%TYPE DEFAULT NULL;
l_attribute2      pa_transaction_interface.attribute2%TYPE DEFAULT NULL;
l_attribute3      pa_transaction_interface.attribute3%TYPE DEFAULT NULL;
l_attribute4      pa_transaction_interface.attribute4%TYPE DEFAULT NULL;
l_attribute5      pa_transaction_interface.attribute5%TYPE DEFAULT NULL;
l_attribute6      pa_transaction_interface.attribute6%TYPE DEFAULT NULL;
l_attribute7      pa_transaction_interface.attribute7%TYPE DEFAULT NULL;
l_attribute8      pa_transaction_interface.attribute8%TYPE DEFAULT NULL;
l_attribute9      pa_transaction_interface.attribute9%TYPE DEFAULT NULL;
l_attribute10     pa_transaction_interface.attribute10%TYPE DEFAULT NULL;
l_raw_cost_rate   pa_transaction_interface.raw_cost_rate%TYPE DEFAULT NULL;
l_interface_id    pa_transaction_interface.interface_id%TYPE DEFAULT NULL;
l_org_id          pa_transaction_interface.org_id%TYPE DEFAULT NULL;
l_gl_date         pa_transaction_interface.gl_date%TYPE DEFAULT NULL;

l_sub_loc           VARCHAR2(10);
l_organization_name VARCHAR2(240) DEFAULT NULL;
l_expenditure_type  pa_transaction_interface.expenditure_type%TYPE DEFAULT NULL;

l_non_labor_resource_org_name VARCHAR2(240) DEFAULT NULL;
l_non_labor_resource pa_transaction_interface.non_labor_resource%TYPE DEFAULT NULL;

l_cdl_system_reference1   pa_transaction_interface.cdl_system_reference1%TYPE DEFAULT NULL;
l_cdl_system_reference2   pa_transaction_interface.cdl_system_reference2%TYPE DEFAULT NULL;
l_cdl_system_reference3   pa_transaction_interface.cdl_system_reference3%TYPE DEFAULT NULL;
l_expenditure_comment     pa_transaction_interface.expenditure_comment%TYPE DEFAULT NULL;
l_expenditure_ending_date pa_transaction_interface.expenditure_ending_date%TYPE DEFAULT NULL;
l_expenditure_item_date   pa_transaction_interface.expenditure_item_date%TYPE DEFAULT NULL;
l_transaction_status_code pa_transaction_interface.transaction_status_code%TYPE DEFAULT NULL;
l_attribute_category      pa_transaction_interface.attribute_category%TYPE DEFAULT NULL;
l_expenditure_item_id     pa_transaction_interface.expenditure_item_id%TYPE DEFAULT NULL;
l_dr_code_combination_id  pa_transaction_interface.dr_code_combination_id%TYPE DEFAULT NULL;
l_cr_code_combination_id  pa_transaction_interface.cr_code_combination_id%TYPE DEFAULT NULL;

l_transaction_rejection_code  pa_transaction_interface.transaction_rejection_code%TYPE DEFAULT NULL;
l_orig_transaction_reference  pa_transaction_interface.orig_transaction_reference%TYPE DEFAULT NULL;
l_unmatched_negative_txn_flag pa_transaction_interface.unmatched_negative_txn_flag%TYPE DEFAULT NULL;

l_operating_unit_id   NUMBER(15);
l_resource_id         NUMBER;

-- BEGIN SIR162

-- BEGIN GLOBAL
-- CURSOR  exp_type IS
--  SELECT eltv.hxt_expenditure_type
--  FROM   hxt_pay_element_types_f_ddf_v eltv
--        ,pay_element_types_f elt
--  where  elt.element_type_id = i_element_type_id
--  and    eltv.row_id         = elt.rowid;

   CURSOR  exp_type IS
    SELECT eltv.hxt_expenditure_type
    FROM   hxt_pay_element_types_f_ddf_v eltv
    WHERE  eltv.element_type_id = i_element_type_id
    AND    i_date_worked BETWEEN eltv.effective_start_date
                             AND eltv.effective_end_date;
-- END GLOBAL

   exp_type_nf   EXCEPTION;

-- END SIR162

-- Begin Bug 2177304
   CURSOR  c_denom_currency_code IS
    SELECT hoi.org_information10
    FROM   hr_organization_information hoi
    WHERE  hoi.org_information_context = 'Business Group Information'
    AND    hoi.organization_id         = i_organization_id;

   l_denom_currency_code  hr_organization_information.org_information10%TYPE;
-- End Bug 2177304

BEGIN
  g_debug :=hr_utility.debug_enabled;

  -- For bug: 5559930
  BEGIN
    SELECT for_person_id
    INTO   l_resource_id
    FROM   hxt_timecards_x tim
    WHERE  tim.id = (SELECT det.tim_id
                     FROM   hxt_det_hours_worked_x det
		     WHERE  det.id = i_time_detail_id
		    );
  EXCEPTION
   WHEN OTHERS THEN
     hr_utility.set_location('Exception in HXT_PA_USER_EXITS.P_A_INTERFACE', 5);
  END;

  -- ONLY CALL THIS FOR RELEASE 12

  l_operating_unit_id := hxc_timecard_properties.setup_mo_global_params(l_resource_id);

  l_sub_loc := 'Step 0';

  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',10);
  end if;

  --begin SIR94
  IF i_retro_transaction = TRUE THEN
     if g_debug then
       	   hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',20);
     end if;
     l_batch_name := 'ADJUSTMENT';   -- no more than 10 characters!
  ELSE
     if g_debug then
     	   hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',30);
     end if;
     l_batch_name := 'INITIAL';   -- no more than 10 characters!
  END IF;

  -- HXT111  l_trans_source := 'TIMECARD';
  l_trans_source := 'Time Management';  --HXT111
  --end SIR94

  l_sub_loc := 'Step 1';

  -- SIR151  l_expenditure_ending_date := i_period_end;
  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',40);
  end if;
  l_expenditure_ending_date := pa_misc.get_week_ending_date(i_date_worked);
  -- SIR151
  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',50);
  	hr_utility.trace('l_expenditure_ending_date :'||l_expenditure_ending_date);
  end if;
  l_employee_number       := i_employee_number;
  l_organization_name     := i_organization_name;
  l_expenditure_item_date := i_date_worked;

  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',50);
  	hr_utility.trace('l_employee_number      :'||l_employee_number);
  	hr_utility.trace('l_organization_name    :'||l_organization_name);
  	hr_utility.trace('l_expenditure_item_date:'||l_expenditure_item_date);
  end if;

  l_sub_loc := 'Step 2';

  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',60);
  end if;
  l_project_number        := i_segment1;       -- SIR80
  l_task_number           := i_task_number;    -- SIR80
  if g_debug then
  	hr_utility.trace('l_project_number :'||l_project_number);
  	hr_utility.trace('l_task_number    :'||l_task_number);
  end if;

  OPEN  c_denom_currency_code;
  FETCH c_denom_currency_code into l_denom_currency_code;

  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',70);
  	hr_utility.trace('l_denom_currency_code :'||l_denom_currency_code);
  end if;

  CLOSE c_denom_currency_code;

  -- SIR162  l_expenditure_type := i_employment_cat;
  -- begin SIR162
  OPEN  exp_type;
  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',80);
  end if;
  FETCH exp_type INTO l_expenditure_type;
  if g_debug then
  	hr_utility.trace('l_expenditure_type :'||l_expenditure_type);
  end if;
     IF exp_type%NOTFOUND OR l_expenditure_type IS NULL THEN
        if g_debug then
              hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',90);
        end if;
        raise exp_type_nf;
     END IF;
  -- end SIR162

  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',100);
  end if;
  l_transaction_status_code := 'P';

  l_sub_loc := 'Step 3';
  -- HXT111  l_expenditure_id := i_cost_allocation_keyflex_id;
  -- begin SIR77
  l_orig_transaction_reference := fnd_date.date_to_chardate(i_effective_start_date)|| fnd_date.date_to_chardate(i_effective_end_date)|| to_char(i_time_detail_id);-- FORMS60
  -- end SIR77

  if g_debug then
  	hr_utility.trace('l_orig_transaction_reference :'
                         ||l_orig_transaction_reference);
  end if;
  l_sub_loc := 'Step 4';
  -- SIR151  l_org_id := i_organization_id;

  l_sub_loc := 'Step 5';

  IF (nvl(fnd_profile.value('HXT_TO_PA_INCLUDE_PREM_HRS'),'Y') = 'Y') THEN
  -- no change in the existing functionality.

  -- Process flat premium amounts separately
     IF i_premium_amount IS NOT NULL THEN
        if g_debug then
        	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',110);
        end if;
        l_sub_loc       := 'Step 6a';
        l_quantity      := 1;
        l_raw_cost      := i_premium_amount;
        l_raw_cost_rate := NULL;
        l_sub_loc       := 'Step 6b';
     -- Process all others as rate x hours
     -- All rates have already been
     -- properly adjusted if necessary
     ELSE
        if g_debug then
        	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',115);
        end if;
        l_sub_loc       := 'Step 6c';
        l_quantity      := i_hours_worked;
        l_raw_cost      := i_hours_worked * i_rate;
        l_raw_cost_rate := i_rate;
        l_sub_loc       := 'Step 6d';
     END IF;

  ELSIF  fnd_profile.value('HXT_TO_PA_INCLUDE_PREM_HRS') = 'N' THEN

  -- Process flat premium amounts separately
     IF i_premium_amount IS NOT NULL THEN
        if g_debug then
        	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',120);
        end if;
        l_sub_loc       := 'Step 7a';
        l_quantity      := 0 ; --1;
        l_raw_cost      := i_premium_amount;
        l_raw_cost_rate := NULL;
        l_sub_loc       := 'Step 7b';
     -- Process all others as rate x hours
     -- All rates have already been
     -- properly adjusted if necessary
     ELSE
        if g_debug then
        	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',125);
        	hr_utility.trace('i_hxt_earning_category:'||i_hxt_earning_category);
        end if;
        l_sub_loc       := 'Step 7c';

        IF i_hxt_earning_category in ('OSP','OTH','SDF') THEN
          if g_debug then
          	  hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',126);
          end if;
          l_quantity      := 0; --i_hours_worked;
        ELSE
          if g_debug then
             	  hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',127);
          end if;
          l_quantity      := i_hours_worked;
        END IF;

        l_raw_cost      := i_hours_worked * i_rate;
        l_raw_cost_rate := i_rate;

        l_sub_loc       := 'Step 7d';
     END IF;

  END IF; -- endif fnd_profile.value('HXT_TO_PA_INCLUDE_PREM_HRS')

  l_sub_loc                     := 'Step 8';
  l_unmatched_negative_txn_flag := 'Y';      --SIR94
  l_sub_loc                     := 'Step 9';

  if g_debug then
    	  hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',130);
  end if;
--Insert Project Accounting entry to the PA Interface Table
  if g_debug then
	  hr_utility.trace('l_trans_source :'||l_trans_source);
	  hr_utility.trace('l_batch_name   :'||l_batch_name);
	  hr_utility.trace('l_expenditure_ending_date :'||l_expenditure_ending_date);
	  hr_utility.trace('i_period_end              :'||i_period_end);
	  hr_utility.trace('l_employee_number         :'||l_employee_number);
	  hr_utility.trace('l_organization_name       :'||l_organization_name);
	  hr_utility.trace('l_expenditure_item_date   :'||l_expenditure_item_date);
	  hr_utility.trace('l_project_number          :'||l_project_number);
	  hr_utility.trace('l_task_number             :'||l_task_number);
	  hr_utility.trace('l_expenditure_type        :'||l_expenditure_type);
	  hr_utility.trace('l_non_labor_resource      :'||l_non_labor_resource);
	  hr_utility.trace('l_non_labor_resource_org_name :'
			  ||l_non_labor_resource_org_name);
	  hr_utility.trace('l_quantity                    :'||l_quantity);
	  hr_utility.trace('l_raw_cost                    :'||l_raw_cost);
	  hr_utility.trace('l_expenditure_comment         :'||l_expenditure_comment);
	  hr_utility.trace('l_transaction_status_code     :'
			  ||l_transaction_status_code);
	  hr_utility.trace('l_transaction_rejection_code  :'
			  ||l_transaction_rejection_code);
	  hr_utility.trace('l_expenditure_id              :'||l_expenditure_id);
	  hr_utility.trace('l_orig_transaction_reference  :'
			  ||l_orig_transaction_reference);
	  hr_utility.trace('l_attribute_category          :'||l_attribute_category);
	  hr_utility.trace('l_attribute1                  :'||l_attribute1);
	  hr_utility.trace('l_attribute2                  :'||l_attribute2);
	  hr_utility.trace('l_attribute3                  :'||l_attribute3);
	  hr_utility.trace('l_attribute4                  :'||l_attribute4);
	  hr_utility.trace('l_attribute5                  :'||l_attribute5);
	  hr_utility.trace('l_attribute6                  :'||l_attribute6);
	  hr_utility.trace('l_attribute7                  :'||l_attribute7);
	  hr_utility.trace('l_attribute8                  :'||l_attribute8);
	  hr_utility.trace('l_attribute9                  :'||l_attribute9);
	  hr_utility.trace('l_attribute10                 :'||l_attribute10);
	  hr_utility.trace('l_raw_cost_rate               :'||l_raw_cost_rate);
	  hr_utility.trace('l_denom_currency_code         :'||l_denom_currency_code);
	  hr_utility.trace('l_raw_cost                    :'||l_raw_cost);
	  hr_utility.trace('l_interface_id                :'||l_interface_id);
	  hr_utility.trace('l_unmatched_negative_txn_flag :'
			  ||l_unmatched_negative_txn_flag);
	  hr_utility.trace('l_org_id                      :'||l_org_id);
	  hr_utility.trace('l_dr_code_combination_id      :'||l_dr_code_combination_id);
	  hr_utility.trace('l_cr_code_combination_id      :'||l_cr_code_combination_id);
	  hr_utility.trace('l_cdl_system_reference1       :'||l_cdl_system_reference1);
	  hr_utility.trace('l_cdl_system_reference2       :'||l_cdl_system_reference2);
	  hr_utility.trace('l_cdl_system_reference3       :'||l_cdl_system_reference3);
	  hr_utility.trace('l_gl_date                     :'||l_gl_date);
   end if;
  INSERT INTO pa_transaction_interface_all
            ( TRANSACTION_SOURCE
             ,BATCH_NAME
             ,EXPENDITURE_ENDING_DATE
             ,EMPLOYEE_NUMBER
             ,ORGANIZATION_NAME
             ,EXPENDITURE_ITEM_DATE
             ,PROJECT_NUMBER
             ,TASK_NUMBER
             ,EXPENDITURE_TYPE
             ,NON_LABOR_RESOURCE
             ,NON_LABOR_RESOURCE_ORG_NAME
             ,QUANTITY
             ,RAW_COST
             ,EXPENDITURE_COMMENT
             ,TRANSACTION_STATUS_CODE
             ,TRANSACTION_REJECTION_CODE
             ,EXPENDITURE_ID
             ,ORIG_TRANSACTION_REFERENCE
             ,ATTRIBUTE_CATEGORY
             ,ATTRIBUTE1
             ,ATTRIBUTE2
             ,ATTRIBUTE3
             ,ATTRIBUTE4
             ,ATTRIBUTE5
             ,ATTRIBUTE6
             ,ATTRIBUTE7
             ,ATTRIBUTE8
             ,ATTRIBUTE9
             ,ATTRIBUTE10
             ,RAW_COST_RATE
	     ,DENOM_CURRENCY_CODE
	     ,DENOM_RAW_COST
             ,INTERFACE_ID
             ,UNMATCHED_NEGATIVE_TXN_FLAG
             ,EXPENDITURE_ITEM_ID
             ,ORG_ID
             ,DR_CODE_COMBINATION_ID
             ,CR_CODE_COMBINATION_ID
             ,CDL_SYSTEM_REFERENCE1
             ,CDL_SYSTEM_REFERENCE2
             ,CDL_SYSTEM_REFERENCE3
             ,GL_DATE)
  VALUES(     l_trans_source
             ,l_batch_name
           -- need the NVL on the following line where
           -- pa_misc.get_week_ending_date() might return NULL.
           -- This would happen in Columbia,or anywhere else that ExpEndDates
           -- not set up in ProjAccting.However,i_period_end will be WRONG for
           -- any Payroll Type other than Weekly.SIR151
	     ,nvl(l_expenditure_ending_date,i_period_end) --SIR151
             ,l_employee_number
             ,l_organization_name
             ,l_expenditure_item_date
             ,l_project_number
             ,l_task_number
             ,l_expenditure_type
             ,l_non_labor_resource
             ,l_non_labor_resource_org_name
             ,l_quantity
             ,l_raw_cost
             ,l_expenditure_comment
             ,l_transaction_status_code
             ,l_transaction_rejection_code
             ,l_expenditure_id
             ,l_orig_transaction_reference
             ,l_attribute_category
             ,l_attribute1
             ,l_attribute2
             ,l_attribute3
             ,l_attribute4
             ,l_attribute5
             ,l_attribute6
             ,l_attribute7
             ,l_attribute8
             ,l_attribute9
             ,l_attribute10
             ,l_raw_cost_rate
--Bug2177304 ,'USD'
             ,l_denom_currency_code
	     ,l_raw_cost
             ,l_interface_id
             ,l_unmatched_negative_txn_flag
             ,l_expenditure_item_id
--Bug:5559930,ORG_ID
	     ,l_operating_unit_id
             ,l_dr_code_combination_id
             ,l_cr_code_combination_id
             ,l_cdl_system_reference1
             ,l_cdl_system_reference2
             ,l_cdl_system_reference3
             ,l_gl_date);

  if g_debug then
  	hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',140);
  end if;
  HXT_UTIL.DEBUG('after insert to pa_transaction_interface.'); --HXT115
  RETURN 0;

  EXCEPTION
    WHEN exp_type_nf THEN
      if g_debug then
      	    hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',150);
      end if;
      HXT_UTIL.DEBUG('exp_type not found. element_id '||to_char(i_element_type_id)||' '||l_sub_loc||' '||SQLERRM); --HXT115
      o_location := 'hxt_pa_user_exits.p_a_interface '||l_sub_loc;
      FND_MESSAGE.SET_NAME('HXT','HXT_39464_EXP_TYP_NOT_FND');     --HXT111
      FND_MESSAGE.SET_TOKEN('ELEM_ID',to_char(i_element_type_id)); --HXT111
      o_error_text := FND_MESSAGE.GET;                             --HXT111
      FND_MESSAGE.CLEAR;                                           --HXT111
      o_system_text := SQLERRM;
      RETURN 1;

    WHEN OTHERS THEN
      if g_debug then
      	    hr_utility.set_location('HXT_PA_USER_EXITS.p_a_interface',160);
      end if;
      HXT_UTIL.DEBUG('exception in hxt_pa_user_exits.p_a_interface:'||l_sub_loc||' '||SQLERRM); --HXT115
      o_location := 'hxt_pa_user_exits.p_a_interface '||l_sub_loc;
      o_error_text := NULL;
      o_system_text := SQLERRM;
      RETURN 1;

END p_a_interface;

--

END HXT_PA_USER_EXITS;

/
