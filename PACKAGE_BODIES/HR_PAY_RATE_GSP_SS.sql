--------------------------------------------------------
--  DDL for Package Body HR_PAY_RATE_GSP_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAY_RATE_GSP_SS" as
/* $Header: hrpaygsp.pkb 120.5.12010000.2 2009/06/12 07:59:16 gpurohit ship $ */

-- get the updated salary because of Grade Ladder assignment
procedure get_employee_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ
) IS

    -- get_employee_salary local variables
    ln_proposed_salary  NUMBER;
    lv_frequency VARCHAR2(100);
    ln_annual_salary NUMBER;
    lv_pay_basis_name VARCHAR2(100);
    lv_reason_cd  VARCHAR2(100);
    ln_currency  VARCHAR2(100);
    ln_status NUMBER;
    l_sal_effective_date date;

begin
       l_sal_effective_date := P_Effective_Date;

       -- get the salary from procedure provided by core API.
       pqh_employee_salary.get_emp_proposed_salary(
                        P_Assignment_id  =>    p_assignment_id,
                        P_Effective_Date  =>    p_effective_date,
                        p_proposed_salary         => ln_proposed_salary,
                        p_sal_chg_dt => l_sal_effective_date,
                        --p_salary =>    ln_proposed_salary,
                        p_frequency =>    lv_frequency,
                        p_annual_salary =>    ln_annual_salary,
                        p_pay_basis =>    lv_pay_basis_name,
                        p_reason_cd =>    lv_reason_cd,
                        p_currency =>    ln_currency,
                        p_status =>    ln_status);

        p_ltt_salary_data(1).proposed_salary  := ln_proposed_salary;
        p_ltt_salary_data(1).proposal_reason := 'GSP';
        p_ltt_salary_data(1).currency        := ln_currency;
        -- need to check pay basis name
        p_ltt_salary_data(1).pay_basis_name  := lv_pay_basis_name;
        -- calculate the annual salary change to display
        -- in the review page
        if(p_ltt_salary_data(1).annual_equivalent is null) then
          p_ltt_salary_data(1).annual_change :=   ln_annual_salary;
        else
          p_ltt_salary_data(1).annual_change :=   ln_annual_salary -
                            p_ltt_salary_data(1).annual_equivalent;
        end if;

        p_ltt_salary_data(1).annual_equivalent := ln_annual_salary;
        p_ltt_salary_data(1).proposed_salary := ln_proposed_salary;
        if(p_ltt_salary_data(1).current_salary is null OR p_ltt_salary_data(1).current_salary = 0) then
            p_ltt_salary_data(1).salary_change_amount := ln_proposed_salary;
            p_ltt_salary_data(1).salary_change_percent := null;
        else
        p_ltt_salary_data(1).salary_change_amount :=
              ln_proposed_salary - p_ltt_salary_data(1).current_salary;
        p_ltt_salary_data(1).salary_change_percent :=
              (p_ltt_salary_data(1).salary_change_amount)*100/
                                                (p_ltt_salary_data(1).current_salary);
        end if;

        p_ltt_salary_data(1).salary_effective_date := l_sal_effective_date;

     EXCEPTION
     WHEN hr_utility.hr_error THEN
          hr_utility.trace('there is a hr_utility.hr_error in get_employee_salary');
          hr_utility.trace('p_error_msg_text');
     WHEN OTHERS THEN
          hr_utility.trace(
                     'there is an OTHERS Exception in process_salary_java_gsp');
          hr_utility.trace('p_error_msg_text' || SQLERRM);
end get_employee_salary;

-- get the current salary , called before updating the assignment
procedure get_employee_current_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ
) IS

    -- get_employee_current_salary local variables
    ln_proposed_salary  NUMBER;
    lv_frequency VARCHAR2(100);
    ln_annual_salary NUMBER;
    lv_pay_basis_name VARCHAR2(100);
    lv_reason_cd  VARCHAR2(100);
    ln_currency  VARCHAR2(100);
    ln_status NUMBER;
    lv_pay_basis_frequency per_pay_bases.pay_basis%TYPE;
    lv_grade_basis	varchar2(100);
    lv_fte_factor 	number;
begin
       -- populate default values
       hr_pay_rate_ss.my_get_defaults(
         p_assignment_id               => P_Assignment_id
         ,p_date                        => p_ltt_salary_data(1).effective_date
         ,p_business_group_id           => p_ltt_salary_data(1).default_bg_id
         ,p_currency                    => p_ltt_salary_data(1).default_currency
         ,p_format_string               =>
                               p_ltt_salary_data(1).default_format_string
         ,p_salary_basis_name           =>
                               p_ltt_salary_data(1).default_salary_basis_name
         ,p_pay_basis_name              =>
                               p_ltt_salary_data(1).default_pay_basis_name
         ,p_pay_basis                   => p_ltt_salary_data(1).default_pay_basis
         ,p_grade_basis                   => lv_grade_basis
         ,p_fte_factor    =>	lv_fte_factor
         ,p_pay_annualization_factor    =>
                               p_ltt_salary_data(1).default_pay_annual_factor
         ,p_grade                       => p_ltt_salary_data(1).default_grade
         ,p_grade_annualization_factor  =>
                               p_ltt_salary_data(1).default_grade_annual_factor
         ,p_minimum_salary              =>
                               p_ltt_salary_data(1).default_minimum_salary
         ,p_maximum_salary              =>
                               p_ltt_salary_data(1).default_maximum_salary
         ,p_midpoint_salary             =>
                               p_ltt_salary_data(1).default_midpoint_salary
         ,p_prev_salary                 =>
                               p_ltt_salary_data(1).default_prev_salary
         ,p_last_change_date            =>
                               p_ltt_salary_data(1).default_last_change_date
         ,p_element_entry_id            =>
                               p_ltt_salary_data(1).default_element_entry_id
         ,p_basis_changed               =>
                               p_ltt_salary_data(1).default_basis_changed
         ,p_uom                         => p_ltt_salary_data(1).default_uom
         ,p_grade_uom                   => p_ltt_salary_data(1).default_grade_uom
         ,p_change_amount               =>
                               p_ltt_salary_data(1).default_change_amount
         ,p_change_percent              =>
                               p_ltt_salary_data(1).default_change_percent
         ,p_quartile                    => p_ltt_salary_data(1).default_quartile
         ,p_comparatio                  => p_ltt_salary_data(1).default_comparatio
         ,p_last_pay_change             =>
                               p_ltt_salary_data(1).default_last_pay_change
         ,p_flsa_status                 =>
                               p_ltt_salary_data(1).default_flsa_status
         ,p_currency_symbol             =>
                               p_ltt_salary_data(1).default_currency_symbol
         ,p_precision                   => p_ltt_salary_data(1).default_precision
         ,p_job_id                      =>  null
         );
       -- End of my defaults

       -- get the salary from procedure provided by core API.
       pqh_employee_salary.get_employee_salary(
                        P_Assignment_id  =>    p_assignment_id,
                        P_Effective_Date  =>    p_effective_date,
                        p_salary =>    ln_proposed_salary,
                        p_frequency =>    lv_frequency,
                        p_annual_salary =>    ln_annual_salary,
                        p_pay_basis =>    lv_pay_basis_name,
                        p_reason_cd =>    lv_reason_cd,
                        p_currency =>    ln_currency,
                        p_status =>    ln_status,
                        p_pay_basis_frequency =>    lv_pay_basis_frequency);


        p_ltt_salary_data(1).proposed_salary  := ln_proposed_salary;
        p_ltt_salary_data(1).proposal_reason := 'GSP';
        p_ltt_salary_data(1).currency        := ln_currency;
        p_ltt_salary_data(1).pay_basis_name  := lv_pay_basis_name;
        p_ltt_salary_data(1).annual_equivalent := ln_annual_salary;
        p_ltt_salary_data(1).current_salary := ln_proposed_salary;

     EXCEPTION
     WHEN hr_utility.hr_error THEN
          hr_utility.trace('there is a hr_utility.hr_error in get_employee_salary');
          hr_utility.trace('p_error_msg_text');
     WHEN OTHERS THEN
          hr_utility.trace(
                     'there is an OTHERS Exception in process_salary_java_gsp');
          hr_utility.trace('p_error_msg_text' || SQLERRM);
end get_employee_current_salary;

-- save the GSP Txn , which will be called hr_process_assignment_api
procedure save_gsp_txn
(
    p_item_type                   IN wf_items.item_type%type,
    p_item_key                    IN wf_items.item_key%TYPE,
    p_Act_id                      IN NUMBER,
    p_ltt_salary_data             IN sshr_sal_prop_tab_typ,
    p_review_proc_call            IN     VARCHAR2,
    p_flow_mode                   IN OUT nocopy varchar2,  -- 2355929
    p_step_id                     OUT NOCOPY NUMBER,
     p_rptg_grp_id                IN VARCHAR2 DEFAULT NULL,
     p_plan_id                    IN VARCHAR2 DEFAULT NULL,
     p_effective_date_option      IN VARCHAR2  DEFAULT NULL
) IS

    -- save_gsp_txn local variables
    ln_transaction_id       NUMBER ;
    lv_result    VARCHAR2(100);
    li_count     INTEGER ;
    lv_api_name  hr_api_transaction_steps.api_name%type ;
    ln_ovn       hr_api_transaction_steps.object_version_number%TYPE;
    ln_transaction_step_id  hr_api_transaction_steps.transaction_step_id%TYPE default null;
    ltt_trans_step_ids      hr_util_web.g_varchar2_tab_type;
    ltt_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
    ln_trans_step_rows      number  default 0;
    lv_activity_name        wf_item_activity_statuses_v.activity_name%TYPE;
    ln_no_of_components     NUMBER ;
    lv_review_url           VARCHAR2(1000) ;
    lv_activity_display_name VARCHAR2(100);
    message VARCHAR2(10000) := '';
    ln_creator_person_id NUMBER;
    result VARCHAR2(100);

    cursor get_transaction_step_id(
        c_item_type  in wf_items.item_type%type
	   ,c_item_key in wf_items.item_key%type
    ) IS
    SELECT transaction_step_id
    FROM   hr_api_transaction_steps
    WHERE  item_type = c_item_type
    AND    item_key  = c_item_key
    --AND    api_name = 'HR_PAY_RATE_SS.process_api_java';
    AND    api_name = 'HR_PAY_RATE_SS.PROCESS_API';

   BEGIN
     -- bug # 1641590

     hr_utility.trace('Start save_gsp_txn');

     lv_review_url := gv_package_name||'.salary_review';
     lv_api_name := gv_package_name||'.PROCESS_API' ;

     ln_creator_person_id := wf_engine.GetItemAttrNumber(p_item_type,
                           p_item_key,
                           'CREATOR_PERSON_ID');

     hr_utility.trace('Creator Person Id ' || ln_creator_person_id);

     -- prepare salary proposal data to be stored in transaction table
     li_count := 1 ;

     gtt_trans_steps(li_count).param_name := 'P_REVIEW_PROC_CALL' ;
     gtt_trans_steps(li_count).param_value := p_review_proc_call;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'P_REVIEW_ACTID' ;
     gtt_trans_steps(li_count).param_value := p_Act_id;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;

     -- 04/24/02 Change Begins
     gtt_trans_steps(li_count).param_name := 'P_FLOW_MODE' ;
     gtt_trans_steps(li_count).param_value := p_flow_mode;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;
     -- 04/24/02 Change Ends

     gtt_trans_steps(li_count).param_name := 'p_current_salary' ;
     gtt_trans_steps(li_count).param_value :=
                p_ltt_salary_data(1).current_salary ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;
     li_count := li_count+1 ;


     -- This variable indicates that, this is GSP PayRate Txn
     gtt_trans_steps(li_count).param_name := 'p_gsp_dummy_txn' ;
     gtt_trans_steps(li_count).param_value := 'YES';
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;
     li_count := li_count+1 ;


     gtt_trans_steps(li_count).param_name := 'p_assignment_id' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).assignment_id  ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;
     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'p_bus_group_id' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).business_group_id  ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;
     li_count := li_count+1 ;


     gtt_trans_steps(li_count).param_name := 'p_effective_date' ;
     gtt_trans_steps(li_count).param_value :=
       to_char(p_ltt_salary_data(1).effective_date,hr_transaction_ss.g_date_format);
     gtt_trans_steps(li_count).param_data_type := 'DATE' ;
     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'p_salary_effective_date' ;
     gtt_trans_steps(li_count).param_value :=
       to_char(p_ltt_salary_data(1).salary_effective_date,hr_transaction_ss.g_date_format);
     gtt_trans_steps(li_count).param_data_type := 'DATE' ;
     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'p_change_amount' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).salary_change_amount ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_proposed_salary' ;
     gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).proposed_salary;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_proposal_reason' ;
     gtt_trans_steps(li_count).param_value :=
                                p_ltt_salary_data(1).proposal_reason;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name   := 'p_no_of_components';
     -- for gsp this is Zero
     -- for avoiding Char to Numeric conversion Error
     -- in the get_transaction_details procedure
     gtt_trans_steps(li_count).param_value  := 0;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER';

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_multiple_components' ;
     gtt_trans_steps(li_count).param_value := 'N';
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;


     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_currency' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).currency;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_pay_basis_name' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).pay_basis_name;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_annual_equivalent' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).annual_equivalent;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_annual_change' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).annual_change;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    -- added default values to the Txn
    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_date';
    gtt_trans_steps(li_count).param_value :=
        to_char(p_ltt_salary_data(1).default_date,
                hr_transaction_ss.g_date_format);
    gtt_trans_steps(li_count).param_data_type := 'DATE' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_bg_id';
    gtt_trans_steps(li_count).param_value := p_ltt_salary_data(1).default_bg_id;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_currency';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_currency;

    if ((p_flow_mode is not null and
      p_flow_mode = hr_process_assignment_ss.g_new_hire_registration) or
       p_ltt_salary_data(1).default_currency is null)
    then
       gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).currency;
    end if;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_format_string';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_format_string;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_salary_basis_name';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_salary_basis_name;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_pay_basis_name';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_pay_basis_name;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_pay_basis';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_pay_basis;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name :=
                      'p_default_pay_annual_factor';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_pay_annual_factor;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_grade';
    gtt_trans_steps(li_count).param_value := p_ltt_salary_data(1).default_grade;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name :=
                      'p_default_grade_annual_factor';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_grade_annual_factor;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_minimum_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_minimum_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_maximum_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_maximum_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_midpoint_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_midpoint_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_prev_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_prev_salary;
    if p_flow_mode is not null and
      p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
       gtt_trans_steps(li_count).param_value :=  0;
    end if;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_last_change_date';
    gtt_trans_steps(li_count).param_value :=
              to_char(p_ltt_salary_data(1).default_last_change_date,
                      hr_transaction_ss.g_date_format);
    gtt_trans_steps(li_count).param_data_type := 'DATE' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_element_entry_id';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_element_entry_id;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_basis_changed';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_basis_changed;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_uom';
    gtt_trans_steps(li_count).param_value := p_ltt_salary_data(1).default_uom;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_grade_uom';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_grade_uom;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_change_amount';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_change_amount;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_change_percent';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_change_percent;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_quartile';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_quartile;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_comparatio';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_comparatio;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_last_pay_change';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_last_pay_change;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_flsa_status';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_flsa_status;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_currency_symbol';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_currency_symbol;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_precision';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_precision;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;


     -- save the txn data
      hr_utility.trace('Create Transaction and Transaction Step ');

      open  get_transaction_step_id
        (c_item_type => p_item_type
        ,c_item_key => p_item_key
        );

      fetch get_transaction_step_id into ln_transaction_step_id;
      close get_transaction_step_id;

      hr_utility.trace(' existing ln_transaction_step_id ' || ln_transaction_step_id);

      hr_transaction_ss.save_transaction_step(
       p_Item_Type              => p_item_type
       ,p_Item_Key              => p_item_key
       ,p_ActID                 => p_act_id
       ,p_login_person_id       => ln_creator_person_id
       ,p_transaction_step_id   => ln_transaction_step_id
       ,p_transaction_data      => gtt_trans_steps
       ,p_api_name              => lv_api_name
       ,p_plan_id               => p_plan_id
       ,p_rptg_grp_id           => p_rptg_grp_id
       ,p_effective_date_option => p_effective_date_option);

      p_step_id := ln_transaction_step_id;

  EXCEPTION
       WHEN OTHERS THEN
         message := 'Exception in maintain_txn_java_for_gsp' || SQLERRM;

         hr_utility.trace(message);
         raise;
end save_gsp_txn;

procedure create_pay_txn
(
   p_item_type                   IN wf_items.item_type%type,
   p_item_key                    IN wf_items.item_key%TYPE,
   p_ltt_salary_data           IN sshr_sal_prop_tab_typ,
   P_Assignment_id          In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
   P_Effective_Date           In Date,
   p_transaction_id            in number,
   p_transaction_step_id   in number,
   p_pay_basis_id             in  Per_All_Assignments_F.pay_basis_id%TYPE,
   p_old_pay_basis_id      in Per_All_Assignments_F.pay_basis_id%TYPE,
   p_business_group_id   in  Per_All_Assignments_F.business_group_id%TYPE
)
is

cursor pay_txn is
select pay_transaction_id from per_pay_transactions where
item_type=p_item_type and item_key=p_item_key and status='NEW';

cursor proposals_id is
select pay_proposal_id from per_pay_proposals where assignment_id=p_assignment_id and
P_Effective_Date between change_date and date_to;

message VARCHAR2(10000) := '';
l_pay_basis_id  Per_All_Assignments_F.pay_basis_id%TYPE;
l_old_pay_basis_id  Per_All_Assignments_F.pay_basis_id%TYPE;
pay_txn_id per_pay_transactions.pay_transaction_id%type;
pay_prop_id per_pay_proposals.pay_proposal_id%type;

begin
l_pay_basis_id := p_pay_basis_id;
l_old_pay_basis_id := p_old_pay_basis_id;

if p_pay_basis_id is null then
    l_pay_basis_id := -1;
end if;

if l_old_pay_basis_id is null then
    l_old_pay_basis_id := -1;
end if;

open pay_txn;
fetch pay_txn into pay_txn_id;

if pay_txn%found then
    update per_pay_transactions set
     PAY_BASIS_ID       = l_pay_basis_id,
     change_amount_n    = p_ltt_salary_data(1).salary_change_amount,
     change_percentage  = p_ltt_salary_data(1).salary_change_percent,
     PROPOSED_SALARY_N  = p_ltt_salary_data(1).proposed_salary
    where PAY_TRANSACTION_ID = pay_txn_id;
    close pay_txn;
    return;
end if;

close pay_txn;

open proposals_id;
fetch proposals_id into pay_prop_id;
close proposals_id;

if pay_prop_id is not null then
           insert into per_pay_transactions(
               	            PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            pay_proposal_id,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            business_group_id,
	            CHANGE_DATE,
	            DATE_TO,
	            last_change_date,
                	            reason,
	            multiple_components,
    	            change_amount_n,
	            change_percentage,
	            PROPOSED_SALARY_N,
	            parent_pay_transaction_id,
	            prior_pay_proposal_id,
	            PRIOR_PAY_TRANSACTION_ID,
	            PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,
	            approved,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
           	            object_version_number)
         values(
	            PER_PAY_TRANSACTIONS_S.NEXTVAL ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            pay_prop_id,
	            p_assignment_id,
	            l_old_pay_basis_id,
	            p_business_group_id,
             	            p_ltt_salary_data(1).default_last_change_date,
	            p_ltt_salary_data(1).salary_effective_date - 1,
	            null,
	            'GSP',
	            'N',  -- change_amount_n,
	            null,
	            null,
	            p_ltt_salary_data(1).current_salary,
	            null,
	            null,
	            null,
	            null,
	            null,
	            'Y',
	            'DATE_ADJUSTED',-- STATUS,
	            'UPDATE',-- DML_OPERATION,
	            1);

end if;

           insert into per_pay_transactions(
               	            PAY_TRANSACTION_ID ,--PAY_TRANSACTION_ID,
	            TRANSACTION_ID, -- TRANSACTION_ID,
	            TRANSACTION_STEP_ID,-- TRANSACTION_STEP_ID,
	            ITEM_TYPE,--  ITEM_TYPE,
	            ITEM_KEY,--  ITEM_KEY,
	            pay_proposal_id,
	            ASSIGNMENT_ID,-- ASSIGNMENT_ID,
	            PAY_BASIS_ID,-- PAY_BASIS_ID,
	            business_group_id,
	            CHANGE_DATE,
	            DATE_TO,
	            last_change_date,
                	            reason,
	            multiple_components,
	            change_amount_n,
	            change_percentage,
	            PROPOSED_SALARY_N,
	            parent_pay_transaction_id,
	            prior_pay_proposal_id,
	            PRIOR_PAY_TRANSACTION_ID,
	            PRIOR_PROPOSED_SALARY_N,
	            PRIOR_PAY_BASIS_ID,
	            approved,
	            STATUS,-- STATUS,
	            DML_OPERATION,-- DML_OPERATION,
          	            object_version_number)
         values(
	            PER_PAY_TRANSACTIONS_S.NEXTVAL ,--PAY_TRANSACTION_ID,
	            p_transaction_id, -- TRANSACTION_ID,
	            p_transaction_step_id,-- TRANSACTION_STEP_ID,
	            p_item_type,--  ITEM_TYPE,
	            p_item_key,--  ITEM_KEY,
	            null,
	            p_assignment_id,
	            l_pay_basis_id,
	            p_business_group_id,
          	            p_ltt_salary_data(1).salary_effective_date,
	            null,
	            null,
	            'GSP',
	            'N',  -- change_amount_n,
	            p_ltt_salary_data(1).salary_change_amount,
	            p_ltt_salary_data(1).salary_change_percent,
	            p_ltt_salary_data(1).proposed_salary,
	            null,
	            pay_prop_id,
	            null,
	            p_ltt_salary_data(1).current_salary,
	            l_old_pay_basis_id,
	            'Y',
	            'NEW',-- STATUS,
	            'INSERT',-- DML_OPERATION,
	            1);

  EXCEPTION
       WHEN OTHERS THEN
         message := 'Exception in create_pay_txn' || SQLERRM;

         hr_utility.trace(message);
         raise;
end create_pay_txn;
--
--
-- Follwing procedure returns true if there is a grade ladder setup for the
-- given business group.
--
Procedure check_grade_ladder_exists(p_business_group_id in number,
                                    p_effective_date    in date ,
                                    p_grd_ldr_exists_flag out nocopy boolean)
is
--
l_status  boolean := false;
l_proc  varchar2(72) := 'check_grade_ladder_exists';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 pqh_employee_salary.check_grade_ladder_exists
                          (p_business_group_id => p_business_group_id,
                           p_effective_date    => p_effective_date,
                           p_grd_ldr_exists_flag => l_status);

 --
 p_grd_ldr_exists_flag:= l_status;
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 --
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 200);
  raise;
  --
End check_grade_ladder_exists;

-- newly added grade_ladder_id attribute decode function
---------------------------------------------------------------
function getGradeLadderName (

--
         p_grade_ladder_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      ben_pgm_f
         where     pgm_id      = p_grade_ladder_id;
--
v_meaning          ben_pgm_f.name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_grade_ladder_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
end getGradeLadderName;
--------------------------------------------------------------

end hr_pay_rate_gsp_ss;

/
