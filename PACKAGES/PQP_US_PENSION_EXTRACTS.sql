--------------------------------------------------------
--  DDL for Package PQP_US_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_US_PENSION_EXTRACTS" AUTHID CURRENT_USER As
/* $Header: pquspext.pkh 120.2 2005/11/28 14:16:21 rpinjala noship $ */

g_conc_request_id        Number;
g_legislation_code       per_business_groups.legislation_code%TYPE;
g_asg_action_id          pay_assignment_actions.assignment_action_id%TYPE;
g_action_effective_date  Date;
g_action_type            Varchar2(50);
g_asgrun_dim_id          pay_balance_dimensions.balance_dimension_id%TYPE;
g_ext_dtl_rcd_id         ben_ext_rcd.ext_rcd_id%TYPE;
g_business_group_id      per_business_groups.business_group_id%TYPE;
g_person_id              per_all_assignments_f.person_id%TYPE;
g_gre_tax_unit_id        hr_all_organization_units.organization_id%TYPE;
g_total_dtl_lines        Number;

TYPE ValTabTyp IS TABLE OF ben_Ext_rslt_dtl.val_01%TYPE
     INDEX BY Binary_Integer ;

TYPE extract_params IS RECORD
    (session_id          Number
    ,ext_dfn_type        pqp_extract_attributes.ext_dfn_type%TYPE
    ,business_group_id   per_business_groups.business_group_id%TYPE
    ,legislation_code    per_business_groups.legislation_code%TYPE
    ,currency_code       per_business_groups.currency_code%TYPE
    ,concurrent_req_id   ben_ext_rslt.request_id%TYPE
    ,ext_dfn_id          ben_ext_dfn.ext_dfn_id%TYPE
    ,element_set_id      pay_element_sets.element_set_id%TYPE
    ,element_type_id     pay_element_types_f.element_type_id%TYPE
    ,payroll_id          pay_payrolls_f.payroll_id%TYPE
    ,gre_org_id          hr_all_organization_units.organization_id%TYPE
    ,con_set_id          pay_consolidation_sets.consolidation_set_id%TYPE
    ,selection_criteria  Varchar2(90)
    ,reporting_dimension Varchar2(90)
    ,extract_start_date  Date
    ,extract_end_date    Date
    ,benefit_action_id   ben_person_actions.benefit_action_id%TYPE
    );

TYPE t_extract_params IS TABLE OF extract_params INDEX BY Binary_Integer;
g_extract_params  t_extract_params;

TYPE ele_details IS RECORD
      (input_name           pay_input_values_f.NAME%TYPE
      ,Pay_Value_Id         pay_input_values_f.input_value_id%TYPE
      ,input_value_id       pay_input_values_f.input_value_id%TYPE
      ,information_category pay_element_types_f.element_information_category%TYPE
      ,pretax_category      pay_element_types_f.element_information1%TYPE
      ,primary_balance_id   pay_balance_types.balance_type_id%TYPE
      ,primary_balance_name pay_balance_types.balance_name%TYPE
      ,CatchUp_ele_type_id  pay_element_types_f.element_type_id%TYPE
      ,CatchUp_ipv_id       pay_input_values_f.input_value_id%TYPE
      ,CatchUp_Balance_id   pay_balance_types.balance_type_id%TYPE
      ,Roth_Element         Varchar2(90)
      ,Roth_ele_type_id     pay_element_types_f.element_type_id%TYPE
      ,Roth_ipv_id          pay_input_values_f.input_value_id%TYPE
      ,Roth_balance_id      pay_balance_types.balance_type_id%TYPE
      ,AT_ele_type_id       pay_element_types_f.element_type_id%TYPE
      ,AT_ipv_id            pay_input_values_f.input_value_id%TYPE
      ,AT_balance_id        pay_balance_types.balance_type_id%TYPE
      ,ATER_Element         Varchar2(90)
      ,ATER_Element_id      pay_element_types_f.element_type_id%TYPE
      ,ATER_Balance_id      pay_balance_types.balance_type_id%TYPE
      ,ER_Element           Varchar2(90)
      ,ER_Element_id        pay_element_types_f.element_type_id%TYPE
      ,ER_Balance_id        pay_balance_types.balance_type_id%TYPE
      ,Roth_ER_Element      Varchar2(90)
      ,RothER_Element_id    pay_element_types_f.element_type_id%TYPE
      ,RothER_Balance_id    pay_balance_types.balance_type_id%TYPE
      );
TYPE t_ele_details IS TABLE OF ele_details INDEX BY Binary_Integer;
g_element         t_ele_details;

TYPE assig_details IS RECORD
      (person_id            per_all_assignments_f.person_id%TYPE
      ,organization_id      per_all_assignments_f.organization_id%TYPE
      ,assignment_type      per_all_assignments_f.assignment_type%TYPE
      ,effective_start_date Date
      ,effective_end_date   Date
      ,Calculate_Amount     Varchar2(50)
      ,assignment_status    per_assignment_status_types.user_status%TYPE
      ,employment_category  hr_lookups.meaning%TYPE
      ,normal_hours         per_all_assignments_f.normal_hours%TYPE
      ,date_start           Date
      ,termination_date     Date
      ,payroll_id           pay_payrolls_f.payroll_id%TYPE
      ,PPG_Billing_Code     Varchar2(150)
      ,Payment_Mode         Varchar2(150)
      );
TYPE t_assig_details IS TABLE OF assig_details INDEX BY Binary_Integer;
g_primary_assig         t_assig_details;

TYPE ele_count_details IS RECORD
      (ele_Count            Number
      ,input_value_id       pay_input_values_f.input_value_id%TYPE
      ,assignment_action_id pay_assignment_actions.assignment_action_id%TYPE
      ,ele_type_id          pay_element_types_f.element_type_id%TYPE
      );
g_AfterTax    ele_count_details;
g_Roth        ele_count_details;
g_CatchUp     ele_count_details;
g_PreTax      ele_count_details;


TYPE balance_details IS RECORD
      ( balance_name           pay_balance_types.balance_name%TYPE
       ,balance_type_id        pay_balance_types.balance_type_id%TYPE
       ,defined_balance_id     pay_defined_balances.defined_balance_id%TYPE
       ,balance_dimension_id   pay_balance_dimensions.balance_dimension_id%TYPE
       ,dimension_name         pay_balance_dimensions.dimension_name%TYPE
      );
TYPE t_balance_details IS TABLE OF balance_details INDEX BY Binary_Integer;
g_balance_detls         t_balance_details;

TYPE balance_dimension IS RECORD
      ( dimension_name         pay_balance_dimensions.dimension_name%TYPE
       ,balance_dimension_id   pay_balance_dimensions.balance_dimension_id%TYPE
      );
TYPE t_balance_dim IS TABLE OF balance_dimension INDEX BY Binary_Integer;
g_balance_dim         t_balance_dim;


TYPE eleinv_details IS RECORD
      ( element_name      pay_element_types_f.element_name%TYPE
       ,input_name        pay_input_values_f.NAME%TYPE
       ,element_type_id   pay_element_types_f.element_type_id%TYPE
       ,input_value_id    pay_input_values_f.input_value_id%TYPE
      );
TYPE t_eleinv_details IS TABLE OF eleinv_details INDEX BY Binary_Integer;
g_element_input_dets     t_eleinv_details;


-- Added for concurrent program parameter
TYPE conc_prog_details IS RECORD
      ( extract_name        ben_ext_dfn.NAME%TYPE
       ,reporting_options   hr_lookups.meaning%TYPE
       ,selection_criteria  hr_lookups.meaning%TYPE
       ,elementset     PAY_ELEMENT_SETS.ELEMENT_SET_NAME%TYPE
       ,elementname     pay_element_types_f.element_name%TYPE
       ,beginningdt         Date
       ,endingdt     Date
       ,grename      hr_organization_units.NAME%TYPE
       ,payrollname     PAY_PAYROLLS_F.PAYROLL_NAME%TYPE
       ,consolset     PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_NAME%TYPE
      );
TYPE t_conc_prog_details IS TABLE OF conc_prog_details INDEX BY Binary_Integer;
g_conc_prog_details     t_conc_prog_details;

-- =============================================================================
-- Pension_Extract_Process:
-- =============================================================================
PROCEDURE Pension_Extract_Process
         (errbuf                        OUT NOCOPY   Varchar2
         ,retcode                       OUT NOCOPY   Varchar2
         ,p_benefit_action_id           IN     Number
         ,p_ext_dfn_id                  IN     Number
         ,p_ext_dfn_typ_id              IN     Varchar2
         ,p_ext_dfn_data_typ            IN     Varchar2
         ,p_reporting_dimension         IN     Varchar2
         ,p_is_fullprofile_data_typ     IN     Varchar2
         ,p_selection_criteria          IN     Varchar2
         ,p_is_element_set              IN     Varchar2
         ,p_element_set_id              IN     Number
         ,p_is_element                  IN     Number
         ,p_is_ext_dfn_type             IN     Varchar2
         ,p_element_type_id             IN     Number
         ,p_report_dfn_typ_id           IN     Varchar2
         ,p_start_date                  IN     Varchar2
         ,p_end_date                    IN     Varchar2
         ,p_gre_id                      IN     Number
         ,p_payroll_id                  IN     Number
         ,p_con_ext_dfn_typ_id          IN     Varchar2
         ,p_con_is_fullprofile_data_typ IN     Varchar2
         ,p_con_set                     IN     Number
         ,p_business_group_id           IN     Number
         ,p_ext_rslt_id                 IN     Number DEFAULT NULL
          );
-- =============================================================================
-- Get_Indicative_DateSwitch:
-- =============================================================================
FUNCTION Get_Indicative_DateSwitch
        (p_business_group_id       IN Number
        ,p_assignment_id           IN Number
        ,p_effective_date          IN Date
        ,p_original_hire_date      OUT NOCOPY Date
        ,p_recent_hire_date        OUT NOCOPY Date
        ,p_actual_termination_date OUT NOCOPY Date
        ,p_extract_date            OUT NOCOPY Date
        ,p_error_code              OUT NOCOPY Varchar2
        ,p_err_message             OUT NOCOPY Varchar2
         ) RETURN Number;
-- =============================================================================
-- Get_SIT_Segment:
-- =============================================================================
FUNCTION Get_SIT_Segment
        (p_business_group_id  IN Number
        ,p_assignment_id      IN Number
        ,p_effective_date     IN Date
        ,p_structure_code     IN Varchar2
        ,p_segment_name       IN Varchar2
        ,p_error_code         OUT NOCOPY Varchar2
        ,p_err_message        OUT NOCOPY Varchar2
        ) RETURN Varchar2;
-- =============================================================================
-- Get_Participant_Status_Code:
-- =============================================================================
FUNCTION Get_Participant_Status_Code
        (p_business_group_id       IN Number
        ,p_assignment_id           IN Number
        ,p_effective_date          IN Date
        ,p_original_hire_date      OUT NOCOPY Date
        ,p_recent_hire_date        OUT NOCOPY Date
        ,p_actual_termination_date OUT NOCOPY Date
        ,p_extract_date            OUT NOCOPY Date
        ,p_person_type             OUT NOCOPY Varchar2
        ,p_401k_entry_value        OUT NOCOPY Varchar2
        ,p_entry_eff_date          OUT NOCOPY Date
        ,p_error_code              OUT NOCOPY Varchar2
        ,p_err_message             OUT NOCOPY Varchar2
         )RETURN Number;
-- =============================================================================
-- Get_DDF_Value:
-- =============================================================================
FUNCTION Get_DDF_DF_Value
        (p_business_group_id  IN Number
        ,p_assignment_id      IN Number
        ,p_effective_date     IN Date
        ,p_flex_name          IN Varchar2
        ,p_flex_context       IN Varchar2
        ,p_flex_field_title   IN Varchar2
        ,p_error_code         OUT NOCOPY Varchar2
        ,p_err_message        OUT NOCOPY Varchar2
         ) RETURN Varchar2;
-- =============================================================================
-- ~ Get_Element_Entry_Value: Gets the elements entry value from run-results in
-- ~ in case the reporting dimension is Assig. Run level and for other dimension
-- ~ fetchs the screen entry value based on the extract end-date.
-- =============================================================================
FUNCTION Get_Element_Entry_Value
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_element_name        IN         Varchar2
        ,p_input_name          IN         Varchar2
        ,p_error_message       OUT NOCOPY Varchar2
         ) RETURN Varchar2 ;
-- =============================================================================
-- Get_Balance_Value:
-- =============================================================================
FUNCTION Get_Balance_Value
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_balance_name        IN         Varchar2
        ,p_error_message       OUT NOCOPY Varchar2
         ) RETURN Number;

FUNCTION Get_Balance_Value
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_balance_name        IN         VARCHAR2
        ,p_dimension_name      IN         VARCHAR2
        ,p_error_message       OUT NOCOPY Varchar2
         ) RETURN Number;
-- =============================================================================
-- Get_ConcProg_Information:
-- =============================================================================
FUNCTION Get_ConcProg_Information
        (p_header_type IN Varchar2
        ,p_error_message OUT NOCOPY Varchar2
         )RETURN Varchar2 ;

-- =============================================================================
-- Get_Contr_AmtPer:
-- =============================================================================
FUNCTION Get_Contr_AmtPer
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_effective_date      IN         Date
        ,p_ele_type            IN         Varchar2
        ,p_error_message       OUT NOCOPY Varchar2
        ) RETURN Number;
-- =============================================================================
-- Get_Data_Elements:
-- =============================================================================
FUNCTION Get_Data_Elements
        (p_assignment_id       IN  Number
        ,p_business_group_id   IN  Number
        ,p_effective_date      IN  Date
        ,p_data_ele_name       IN  Varchar2
        ,p_error_message       OUT NOCOPY Varchar2
         ) RETURN Varchar2;
-- =============================================================================
-- Get_Payroll_Date:
-- =============================================================================
FUNCTION Get_Payroll_Date
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_effective_date      IN         Date
        ,p_error_message       OUT NOCOPY Varchar2
         ) RETURN Varchar2;
-- =============================================================================
-- Get_Deduction_Amount:
-- =============================================================================
FUNCTION Get_Deduction_Amount
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_effective_date      IN         Date
        ,p_balance_name        IN         Varchar2
        ,p_error_message       OUT NOCOPY Varchar2
        ) RETURN Number;
-- =============================================================================
-- Check_Asg_Actions:
-- =============================================================================
FUNCTION Check_Asg_Actions
        (p_assignment_id       IN         Number
        ,p_business_group_id   IN         Number
        ,p_effective_date      IN         Date
        ,p_error_message       OUT NOCOPY Varchar2
        ) RETURN Varchar2;
-- =============================================================================
-- Pay_US_Pension_Criteria: The Main extract criteria that would be used for the
-- pension extract.
-- =============================================================================
FUNCTION Pension_Criteria_Full_Profile
        (p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date       IN Date
        ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
        ,p_warning_message      OUT NOCOPY Varchar2
        ,p_error_message        OUT NOCOPY Varchar2
         ) RETURN Varchar2;
-- =============================================================================
-- Del_Service_Detail_Recs:
-- =============================================================================
FUNCTION Del_Service_Detail_Recs
        (p_business_group_id IN ben_ext_rslt_dtl.business_group_id%TYPE
         ) RETURN Number;

-- =============================================================================
-- Get_Current_Extract_Result:
-- =============================================================================
FUNCTION get_current_extract_result RETURN Number;
-- =============================================================================
-- Get_Current_Extract_Person:
-- =============================================================================
FUNCTION Get_Current_Extract_Person
        (p_assignment_id     IN Number  -- context
         ) RETURN Number;

-- =============================================================================
-- Raise_Extract_Warning:
-- =============================================================================
FUNCTION Raise_Extract_Warning
        (p_assignment_id     IN     Number    -- context
        ,p_error_text        IN     Varchar2
        ,p_error_number      IN     Number    DEFAULT NULL
         ) RETURN Number;

END Pqp_Us_Pension_Extracts;

 

/
