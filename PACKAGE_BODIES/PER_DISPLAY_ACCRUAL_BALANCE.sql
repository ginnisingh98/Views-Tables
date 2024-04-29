--------------------------------------------------------
--  DDL for Package Body PER_DISPLAY_ACCRUAL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DISPLAY_ACCRUAL_BALANCE" AS
/* $Header: peraccbal.pkb 120.6.12010000.4 2009/03/23 12:57:56 amunsi ship $ */

PROCEDURE GET_ACCRUAL_BALANCES(p_resource_id IN NUMBER,
                               p_element_set_id in Number,
			       p_evaluation_function in varchar2,
                               p_evaluation_date IN DATE ,
			       p_accrual_balance_table OUT NOCOPY PER_ACCRUAL_BALANCE_TABLE_TYPE,
			       p_error_message OUT NOCOPY VARCHAR2)IS

l_business_group_id per_all_assignments_f.BUSINESS_GROUP_ID%type;
l_element_type_id  pay_element_types_f.ELEMENT_TYPE_ID%type;
l_assignment_id  per_all_assignments_f.ASSIGNMENT_ID%type;
l_payroll_id  pay_element_types_f.ELEMENT_TYPE_ID%type;

l_plan_id pay_accrual_plans.ACCRUAL_PLAN_ID%type;
l_name pay_accrual_plans.ACCRUAL_PLAN_NAME%type;

l_accrual      number;
l_net_accrual  number;
l_start_date Date;
l_end_date Date;
l_acc_end_date Date;
l_index Number ;

l_legislation_code per_business_groups_perf.legislation_code%type;
l_return Number;

l_leave_type_balance pay_accrual_plans.information1%type; /* 4767298 */
l_information_Category pay_accrual_plans.information_category%type;  /* 4767298 */

CURSOR c_element_set(p_element_set IN NUMBER,
                    p_evaluation_date IN DATE,
		    p_business_group_id in varchar2
		    ) IS
  select pet.element_type_id
    from pay_element_types_f pet,
         pay_element_type_rules per
    where per.element_set_id = p_element_set_id
     AND pet.business_group_id=p_business_group_id
     and per.include_or_exclude = 'I'
     and per.element_type_id = pet.element_type_id
     and p_evaluation_date between
         effective_start_date and effective_end_date;

CURSOR c_assignments(p_resource_id In Number,
		     p_evaluation_date In Date) IS
    SELECT pas.ASSIGNMENT_ID,
           pas.payroll_id,
           pas.business_group_id
    FROM PER_ALL_ASSIGNMENTS_F pas,
         per_assignment_status_types typ
    WHERE pas.PERSON_ID = p_resource_id
       AND pas.ASSIGNMENT_TYPE in ('E','C')
       AND pas.PRIMARY_FLAG = 'Y'
       AND pas.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS IN ( 'ACTIVE_ASSIGN','ACTIVE_CWK')
       AND p_evaluation_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE ;

CURSOR c_accrual_plans(p_assignment_id In Number,
		       p_element_type_id In Number,
		       p_evaluation_date In Date)
 IS
 SELECT  pap.accrual_plan_id,
	 pap.accrual_plan_name,
         pap.information1,  /* 4767298 */
         pap.information_Category  /* 4767298 */
 FROM     pay_accrual_plans pap
         ,pay_element_types_f pet
         ,pay_element_links_f pel
         ,pay_element_entries_f pee
 WHERE
  	 pee.assignment_id = p_assignment_id
 AND
 	 pet.ELEMENT_TYPE_ID=p_element_type_id
 AND
 	 pap.accrual_plan_element_type_id = pet.element_type_id
 AND
 	 pap.accrual_plan_element_type_id  = pel.element_type_id
 AND
 	 pel.element_type_id = pet.element_type_id
 AND
 	 pee.element_type_id = pet.element_type_id
 AND
 	 pel.element_link_id = pee.element_link_id
 AND
         p_evaluation_date BETWEEN pee.effective_start_date
                            AND pee.effective_end_date
 AND
 	 pee.effective_start_date BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
 AND
 	 pee.effective_start_date BETWEEN pel.effective_start_date
                                    AND pel.effective_end_date;
l_message_count number;
l_message varchar2(250);

BEGIN

HR_UTIL_MISC_SS.setEffectiveDate(p_evaluation_date);

p_accrual_balance_table := PER_ACCRUAL_BALANCE_TABLE_TYPE();


l_index:=0;

OPEN c_assignments(p_resource_id,p_evaluation_date);
  LOOP
    FETCH c_assignments INTO l_assignment_id,l_payroll_id,l_business_group_id;
    EXIT WHEN c_assignments%NOTFOUND;

	OPEN c_element_set(p_element_set_id,p_evaluation_date,l_business_group_id);
	  LOOP
	    FETCH c_element_set INTO l_element_type_id;
	    EXIT WHEN c_element_set%NOTFOUND;
		OPEN c_accrual_plans(l_assignment_id,l_element_type_id,p_evaluation_date);
		  LOOP
		    FETCH c_accrual_plans INTO l_plan_id,l_name, l_leave_type_balance, l_information_category;
		    EXIT WHEN c_accrual_plans%NOTFOUND;
  			    l_index:=l_index+1;
			    p_accrual_balance_table.extend;
                    l_legislation_code := hr_api.return_legislation_code(l_business_group_id);
		    if(	l_legislation_code ='NZ') THEN
			    l_return := hr_nz_holidays.get_accrual_entitlement
				(P_Assignment_ID=>l_assignment_id
                   ,P_Payroll_ID=>l_payroll_id
                   ,P_Business_Group_ID=>l_business_group_id
                   ,P_Plan_ID=>l_plan_id
                   ,P_Calculation_Date=>p_evaluation_date
                   ,P_net_Accrual =>l_accrual
                   ,P_Net_Entitlement => l_net_accrual
	             ,P_calc_Start_Date=>l_start_date
                   ,P_last_accrual =>l_acc_end_date
                   ,P_next_period_End=> l_end_date);

               l_net_accrual := l_net_accrual + l_accrual;
		     p_accrual_balance_table(l_index) := PER_ACCRUAL_BALANCE_TYPE(l_name,round(NVL(l_net_accrual,0), 3));

              ELSIF(l_legislation_code ='AU') THEN
			   l_return := hr_au_holidays.get_accrual_entitlement
				(P_Assignment_ID=>l_assignment_id
				,P_Plan_ID=>l_plan_id
				,P_Payroll_ID=>l_payroll_id
				,P_Business_Group_ID=>l_business_group_id
				,P_Calculation_Date=>p_evaluation_date
				,P_calc_Start_Date=>l_start_date
				,P_next_period_End=> l_end_date
				,P_last_accrual =>l_acc_end_date
				,P_net_Accrual =>l_accrual
				,P_Net_Entitlement => l_net_accrual);

 	/* 4767298 */
                     if l_information_category in ('AU_AUAL' , 'AU_AULSL' , 'AU_AUSL')
                     then
                                if nvl(l_leave_type_balance, 'EA')  = 'EA'
                                then
                                  l_net_accrual := l_net_accrual + l_accrual;
                                else
                                  l_net_accrual := l_net_accrual;
                               end if;
                      else
                            l_net_accrual := l_net_accrual + l_accrual;
                      end if;

                        p_accrual_balance_table(l_index) := PER_ACCRUAL_BALANCE_TYPE(l_name,round(NVL(l_net_accrual,0), 3));

 			ELSE
			    per_accrual_calc_functions.Get_Net_Accrual
				(P_Assignment_ID=>l_assignment_id
				,P_Plan_ID=>l_plan_id
				,P_Payroll_ID=>l_payroll_id
				,P_Business_Group_ID=>l_business_group_id
				,P_Calculation_Date=>p_evaluation_date
				,P_Start_Date=>l_start_date
				,P_End_Date=> l_end_date
				,P_Accrual_End_Date =>l_acc_end_date
				,P_Accrual =>l_accrual
				,P_Net_Entitlement => l_net_accrual);

 				 p_accrual_balance_table(l_index) := PER_ACCRUAL_BALANCE_TYPE(l_name,round(NVL(l_net_accrual,0), 3));
		    end if;

		   END LOOP;
	   	   CLOSE c_accrual_plans;
	  END LOOP;
	  CLOSE c_element_set;
  END LOOP;
 CLOSE c_assignments;
 l_message_count := per_accrual_message_pkg.count_messages;

   for i in 1..l_message_count loop
     l_message := per_accrual_message_pkg.get_message(i);
     if (l_message is not null and (l_message = 'HR_52797_PTO_FML_ACT_ACCRUAL' or l_message = 'HR_52793_PTO_FML_ASG_INELIG') or l_message ='HR_52795_PTO_FML_CALC_DATE') Then
     	p_error_message := l_message;
     end if;
   end loop;
   per_accrual_message_pkg.clear_table;

END GET_ACCRUAL_BALANCES;
function IsTerminatedEmployee(p_resource_id IN NUMBER,
                      p_evaluation_date IN DATE)
return varchar2
is
l_assignment_id  per_all_assignments_f.ASSIGNMENT_ID%type;
  CURSOR c_assignments(p_resource_id In Number,
		     p_evaluation_date In Date) IS
    SELECT pas.ASSIGNMENT_ID
    FROM PER_ALL_ASSIGNMENTS_F pas,
         per_assignment_status_types typ
    WHERE pas.PERSON_ID = p_resource_id
       AND pas.ASSIGNMENT_TYPE in ('E','C')
       AND pas.PRIMARY_FLAG = 'Y'
       AND pas.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS IN ( 'ACTIVE_ASSIGN','ACTIVE_CWK')
       AND p_evaluation_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE ;
begin

    OPEN c_assignments(p_resource_id,p_evaluation_date);
    FETCH c_assignments INTO l_assignment_id;
    IF c_assignments%NOTFOUND Then
    return 'Y';
    else
    return 'N';
    end if;

exception
  when others then
    raise;
end  IsTerminatedEmployee;
PROCEDURE GET_ACCRUAL_BALANCES(p_resource_id IN NUMBER,
                               p_evaluation_function in varchar2,
                               p_evaluation_date IN DATE ,
			       p_accrual_balance_table OUT NOCOPY PER_ACCRUAL_BALANCE_TABLE_TYPE)IS

l_business_group_id per_all_assignments_f.BUSINESS_GROUP_ID%type;
l_element_type_id  pay_element_types_f.ELEMENT_TYPE_ID%type;
l_assignment_id  per_all_assignments_f.ASSIGNMENT_ID%type;
l_payroll_id  pay_element_types_f.ELEMENT_TYPE_ID%type;

l_plan_id pay_accrual_plans.ACCRUAL_PLAN_ID%type;
l_name pay_accrual_plans.ACCRUAL_PLAN_NAME%type;

l_accrual      number;
l_net_accrual  number;
l_start_date Date;
l_end_date Date;
l_acc_end_date Date;
l_index Number ;

l_legislation_code per_business_groups_perf.legislation_code%type;
l_return Number;

l_leave_type_balance pay_accrual_plans.information1%type; /* 4767298 */
l_information_Category pay_accrual_plans.information_category%type;  /* 4767298 */

CURSOR c_assignments(p_resource_id In Number,
		     p_evaluation_date In Date) IS
    SELECT pas.ASSIGNMENT_ID,
           pas.payroll_id,
           pas.business_group_id
    FROM PER_ASSIGNMENTS_F2 pas,
         per_assignment_status_types typ
    WHERE pas.PERSON_ID = p_resource_id
       AND pas.ASSIGNMENT_TYPE in ('E','C')
      -- AND pas.PRIMARY_FLAG = 'Y'
       AND pas.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS IN ( 'ACTIVE_ASSIGN','ACTIVE_CWK')
       AND p_evaluation_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE ;

CURSOR c_accrual_plans(p_assignment_id In Number,
		       p_evaluation_date In Date)
 IS
 SELECT  accrual_plan_id,
	 accrual_plan_name,
         information1,  /* 4767298 */
         information_Category  /* 4767298 */
FROM
 	PAY_VIEW_ACCRUAL_PLANS_V
WHERE ASSIGNMENT_ID = p_assignment_id
	AND p_evaluation_date BETWEEN ASG_EFFECTIVE_START_DATE AND ASG_EFFECTIVE_END_DATE
    	AND p_evaluation_date BETWEEN IV_EFFECTIVE_START_DATE AND IV_EFFECTIVE_END_DATE
    	AND p_evaluation_date BETWEEN E_ENTRY_EFFECTIVE_START_DATE AND E_ENTRY_EFFECTIVE_END_DATE
    	AND p_evaluation_date BETWEEN E_TYPE_EFFECTIVE_START_DATE AND E_TYPE_EFFECTIVE_END_DATE
    	AND p_evaluation_date BETWEEN E_LINK_EFFECTIVE_START_DATE AND E_LINK_EFFECTIVE_END_DATE ;
BEGIN

HR_UTIL_MISC_SS.setEffectiveDate(p_evaluation_date);

p_accrual_balance_table := PER_ACCRUAL_BALANCE_TABLE_TYPE();


l_index:=0;

OPEN c_assignments(p_resource_id,p_evaluation_date);
  LOOP
    FETCH c_assignments INTO l_assignment_id,l_payroll_id,l_business_group_id;
    EXIT WHEN c_assignments%NOTFOUND;

    	OPEN c_accrual_plans(l_assignment_id,p_evaluation_date);
		  LOOP
		    FETCH c_accrual_plans INTO l_plan_id,l_name, l_leave_type_balance, l_information_category;
		    EXIT WHEN c_accrual_plans%NOTFOUND;
  			    l_index:=l_index+1;
			    p_accrual_balance_table.extend;
                    l_legislation_code := hr_api.return_legislation_code(l_business_group_id);
		    if(	l_legislation_code ='NZ') THEN
			    l_return := hr_nz_holidays.get_accrual_entitlement
				(P_Assignment_ID=>l_assignment_id
                   ,P_Payroll_ID=>l_payroll_id
                   ,P_Business_Group_ID=>l_business_group_id
                   ,P_Plan_ID=>l_plan_id
                   ,P_Calculation_Date=>p_evaluation_date
                   ,P_net_Accrual =>l_accrual
                   ,P_Net_Entitlement => l_net_accrual
	             ,P_calc_Start_Date=>l_start_date
                   ,P_last_accrual =>l_acc_end_date
                   ,P_next_period_End=> l_end_date);

               l_net_accrual := l_net_accrual + l_accrual;
		     p_accrual_balance_table(l_index) := PER_ACCRUAL_BALANCE_TYPE(l_name,round(NVL(l_net_accrual,0), 3));

              ELSIF(l_legislation_code ='AU') THEN
			   l_return := hr_au_holidays.get_accrual_entitlement
				(P_Assignment_ID=>l_assignment_id
				,P_Plan_ID=>l_plan_id
				,P_Payroll_ID=>l_payroll_id
				,P_Business_Group_ID=>l_business_group_id
				,P_Calculation_Date=>p_evaluation_date
				,P_calc_Start_Date=>l_start_date
				,P_next_period_End=> l_end_date
				,P_last_accrual =>l_acc_end_date
				,P_net_Accrual =>l_accrual
				,P_Net_Entitlement => l_net_accrual);

 	/* 4767298 */
                     if l_information_category in ('AU_AUAL' , 'AU_AULSL' , 'AU_AUSL')
                     then
                                if nvl(l_leave_type_balance, 'EA')  = 'EA'
                                then
                                  l_net_accrual := l_net_accrual + l_accrual;
                                else
                                  l_net_accrual := l_net_accrual;
                               end if;
                      else
                            l_net_accrual := l_net_accrual + l_accrual;
                      end if;

                        p_accrual_balance_table(l_index) := PER_ACCRUAL_BALANCE_TYPE(l_name,round(NVL(l_net_accrual,0), 3));

 			ELSE
			    per_accrual_calc_functions.Get_Net_Accrual
				(P_Assignment_ID=>l_assignment_id
				,P_Plan_ID=>l_plan_id
				,P_Payroll_ID=>l_payroll_id
				,P_Business_Group_ID=>l_business_group_id
				,P_Calculation_Date=>p_evaluation_date
				,P_Start_Date=>l_start_date
				,P_End_Date=> l_end_date
				,P_Accrual_End_Date =>l_acc_end_date
				,P_Accrual =>l_accrual
				,P_Net_Entitlement => l_net_accrual);

 				 p_accrual_balance_table(l_index) := PER_ACCRUAL_BALANCE_TYPE(l_name,round(NVL(l_net_accrual,0), 3));
		    end if;

		   END LOOP;
	   	   CLOSE c_accrual_plans;
  END LOOP;
 CLOSE c_assignments;
END GET_ACCRUAL_BALANCES;
END PER_DISPLAY_ACCRUAL_BALANCE;

/
