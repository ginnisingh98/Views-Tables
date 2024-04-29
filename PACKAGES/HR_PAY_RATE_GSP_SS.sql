--------------------------------------------------------
--  DDL for Package HR_PAY_RATE_GSP_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_RATE_GSP_SS" AUTHID CURRENT_USER as
/* $Header: hrpaygsp.pkh 120.2 2008/02/21 12:28:59 gpurohit ship $ */
--
Procedure get_employee_salary
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date,
 p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ
);

-- get the current salary , called before updating the assignment
Procedure get_employee_current_salary
(P_Assignment_id   IN Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  IN DATE,
 p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ
);

procedure save_gsp_txn
(
    p_item_type                   IN wf_items.item_type%type,
    p_item_key                    IN wf_items.item_key%TYPE,
    p_Act_id                      IN NUMBER,
    p_ltt_salary_data             IN sshr_sal_prop_tab_typ,
    p_review_proc_call            IN     VARCHAR2,
    p_flow_mode                   IN OUT NOCOPY varchar2,  -- 2355929
    p_step_id                     OUT NOCOPY NUMBER,
    p_rptg_grp_id                 IN VARCHAR2 DEFAULT NULL,
    p_plan_id                     IN VARCHAR2 DEFAULT NULL,
    p_effective_date_option       IN VARCHAR2  DEFAULT NULL
);

-- This method saves data in per_pay_transactions table
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
   p_old_pay_basis_id       in  Per_All_Assignments_F.pay_basis_id%TYPE,
   p_business_group_id    in  Per_All_Assignments_F.business_group_id%TYPE
);

Procedure check_grade_ladder_exists(p_business_group_id IN NUMBER,
                                    p_effective_date    IN DATE ,
                                    p_grd_ldr_exists_flag out nocopy boolean);

-- newly added grade_ladder_id attribute decode function
-----------------------------------------------------------------------
function getGradeLadderName ( p_grade_ladder_id  IN  NUMBER) return varchar2 ;


    -- declare a table for storing txn steps
    gtt_transaction_steps  hr_transaction_ss.transaction_table ;

    gtt_trans_steps  hr_transaction_ss.transaction_table ;

    gv_package_name          VARCHAR2(30) := 'HR_PAY_RATE_SS' ;

    gv_activity_name         wf_item_activity_statuses_v.activity_name%TYPE
                            :='HR_MAINTAIN_SALARY' ;
    gv_process_name          wf_process_activities.process_name%TYPE
                             := 'HR_SALARY_PRC' ;

end hr_pay_rate_gsp_ss;

/
