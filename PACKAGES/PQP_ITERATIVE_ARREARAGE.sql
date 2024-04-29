--------------------------------------------------------
--  DDL for Package PQP_ITERATIVE_ARREARAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ITERATIVE_ARREARAGE" AUTHID CURRENT_USER As
/* $Header: pqpitarr.pkh 115.1 2003/05/29 23:43:06 rpinjala noship $ */

Type Ele_Data_Rec Is Record
         (ele_entry_id         Number
         ,assignment_id        Number
         ,assignment_action_id Number
         ,iter_count           Number
         ,max_amount           Number
         ,min_amount           Number
         ,maxdesired_amt       Number
         ,deduction_amount     Number
         ,actual_usercalc_amt  Number
         ,arrears_allowed      Varchar2(2)
         ,partial_allowed      Varchar2(2)
         ,stopper_flag         Varchar2(2)
         ,inserted_flag        Varchar2(2)
         ,calc_method          Varchar2(150)
         ,to_within            Number
         ,clr_add_amt          Number
         ,clr_rep_amt          Number
         ,formula_warning      Varchar2(255)
         ,warning_code         Varchar2(10)
         );
Type Ele_Data_Info Is Table Of Ele_Data_Rec
     Index By Binary_Integer;
g_Element_Values     Ele_Data_Info;

Type Arr_Data_Rec Is Record
         (element_type_id      Number
         ,arrears_allowed      Varchar2(2)
         ,partial_allowed      Varchar2(2)
          );
Type Arr_Data_Info Is Table Of Arr_Data_Rec
     Index By Binary_Integer;
g_Element_Arr_Values Arr_Data_Info;

Type Itr_Data_Rec Is Record
         (iterative_method      hr_organization_information.org_information1%TYPE
         ,adjust_to_within      Number
          );
Type Itr_Data_Info Is Table Of Itr_Data_Rec
     Index By Binary_Integer;
g_Itr_Method    Itr_Data_Info;

g_pkg_name           Varchar2(70):= 'PQP_Iterative_Arrearage.';
g_legislation_code   Varchar2(3);

Function Arrearage
         (p_eletype_id           In Number   -- Context Parameter 1
         ,p_ele_entryid          In Number   -- Context Parameter 2
         ,p_assignment_id        In Number   -- Context Parameter 3
         ,p_business_grp_id      In Number   -- Context Parameter 4
         ,p_assignment_action_Id In Number   -- Context Parameter 5
         ,p_date_earned          In Date     -- Context Parameter 6
         ,p_net_asg_run          In Number   -- 1
         ,p_maxarrears           In Number
         ,p_dedn_amt             In Number
         ,p_to_arrears           In Out NoCopy Number
         ,p_not_taken            In Out NoCopy Number
         ,p_arrears_taken        In Out NoCopy Number
         ,p_remaining_amount     In Number   Default  0   -- Optional Parameter  7
         ,p_guaranteed_net       In Number   Default  0   -- Optional Parameter  8
	     ,p_partial_allowed      In Varchar2 Default Null -- Optional Parameter  9
         ,p_arrears_allowed      In Varchar2 Default Null -- Optional Parameter 10
         ) Return Number;

Function Iterative_Arrearage
         (p_eletype_id           In Number -- Context Parameter 1
         ,p_ele_entryid          In Number -- Context Parameter 2
         ,p_assignment_id        In Number -- Context Parameter 3
         ,p_business_grp_id      In Number -- Context Parameter 4
         ,p_assignment_action_Id In Number -- Context Parameter 5
         ,p_date_earned          In Date   -- Context Parameter 6
         ,p_net_asg_run          In Number -- 1
         ,p_maxarrears           In Number
         ,p_dedn_amt             In Number
         ,p_maxdesired_amt       In Number
         ,p_iter_count           In Number
         ,p_inserted_flag        In Varchar2
         ,p_to_arrears           In Out NoCopy Number
         ,p_not_taken            In Out NoCopy Number
         ,p_arrears_taken        In Out NoCopy Number
         ,p_error_message        Out NoCopy Varchar2
         ,p_warning_message      Out NoCopy Varchar2
         ,p_remaining_amount     In Number   Default  0   -- Optional Parameter 12
         ,p_guaranteed_net       In Number   Default  0   -- Optional Parameter 13
         ,p_partial_allowed      In Varchar2 Default Null -- Optional Parameter 14
         ,p_arrears_allowed      In Varchar2 Default Null -- Optional Parameter 15
         ) Return Number;

Function Get_Arrearage_Options
           (p_ele_type_id     In Number -- Context Parameter 1
           ,p_assignment_id   In Number -- Context Parameter 2
           ,p_business_grp_id In Number -- Context Parameter 3
           ,p_effective_date  In Date   -- Context Parameter 4
           ,p_arrears_allowed Out NoCopy Varchar2 --1
           ,p_partial_allowed Out NoCopy Varchar2 --2
           ,p_error_message   Out NoCopy Varchar2 --3
           ) Return Number;

Function Get_Formula_Warning_Mesg
         (p_ele_entryid         In  Number -- Context Parameter
         ,p_assignment_id       In  Number -- Context Parameter
         ,p_business_grp_id     In  Number -- Context Parameter
         ,p_eletype_id	        In  Number -- Context Parameter
         ,p_date_earned	        In  Date   -- Context Parameter
         ,p_warning_message     Out NoCopy Varchar2
         ,p_warning_code        Out NoCopy Varchar2
         ) Return Number;

Function Get_Iteration_Values
         (p_ele_entryid         In  Number -- Context Parameter 1
         ,p_assignment_id       In  Number -- Context Parameter 2
         ,p_business_grp_id     In  Number -- Context Parameter 3
         ,p_eletype_id	        In  Number -- Context Parameter 4
         ,p_date_earned	        In  Date   -- Context Parameter 5
         ,p_iter_count          Out NoCopy Number -- 1
         ,p_max_amount          Out NoCopy Number
         ,p_min_amount          Out NoCopy Number
         ,p_maxdesired_amt      Out NoCopy Number
         ,p_deduction_amount    Out NoCopy Number
         ,p_actual_usercalc_amt Out NoCopy Number
         ,p_clr_add_amt         Out NoCopy Number
         ,p_clr_rep_amt         Out NoCopy Number
         ,p_stopper_flag        Out NoCopy Varchar2
         ,p_inserted_flag       Out NoCopy Varchar2
         ,p_arrears_allowed     Out NoCopy Varchar2
         ,p_partial_allowed     Out NoCopy Varchar2
         ,p_calc_method         Out NoCopy Varchar2
         ,p_to_within           Out NoCopy Number
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2 -- 16
         ) Return Number;

Function Set_Formula_Warning_Mesg
         (p_ele_entryid         In  Number -- Context Parameter
         ,p_assignment_id       In  Number -- Context Parameter
         ,p_business_grp_id     In  Number -- Context Parameter
         ,p_eletype_id	        In  Number -- Context Parameter
         ,p_date_earned	        In  Date   -- Context Parameter
         ,p_warning_message     In  Varchar2
         ,p_warning_code        In  Varchar2
         ) Return Number;

Function Set_Iteration_Values
         (p_ele_entryid          In Number -- Context Parameter
         ,p_assignment_id        In Number -- Context Parameter
         ,p_business_grp_id      In Number -- Context Parameter
         ,p_assignment_action_Id In Number -- Context Parameter
         ,p_eletype_id	         In Number -- Context Parameter
         ,p_date_earned	         In Date   -- Context Parameter
         ,p_iter_count           In Number
         ,p_max_amount           In Number
         ,p_min_amount           In Number
         ,p_maxdesired_amt       In Number
         ,p_deduction_amount     In Number
         ,p_actual_usercalc_amt  In Number
         ,p_clr_add_amt          In Number
         ,p_clr_rep_amt          In Number
         ,p_stopper_flag         In Varchar2
         ,p_inserted_flag        In Varchar2
         ,p_calc_method          In Varchar2
         ,p_to_within            In Number
         ,p_error_message        Out NoCopy Varchar2
         ,p_warning_message      Out NoCopy Varchar2
         ) Return Number;

Function Clear_Iteration_Values
         (p_ele_entryid          In Number -- Context Parameter
         ,p_assignment_id        In Number -- Context Parameter
         ,p_assignment_action_id In Number -- Context Parameter
         ,p_error_message        Out NoCopy Varchar2
         ,p_warning_message      Out NoCopy Varchar2
         ) Return Number;

Function Incr_Iteration_Count
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2
         ) Return Number;

Function Stop_Iteration
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2
         ) Return Number;

Function Get_Iteration_Count
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2
         ) Return Number;

Function Get_Stopper_Flag
         (p_ele_entryid         In Number -- Context Parameter
         ,p_assignment_id       In Number -- Context Parameter
         ,p_error_message       Out NoCopy Varchar2
         ,p_warning_message     Out NoCopy Varchar2
         ) Return Varchar2;

End PQP_Iterative_Arrearage;


 

/
