--------------------------------------------------------
--  DDL for Package PQP_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_EXTRACTS" AUTHID CURRENT_USER As
/* $Header: pqglpext.pkh 120.1 2005/10/04 12:01:24 rpinjala noship $ */


g_conc_request_id        number;
g_legislation_code       per_business_groups.legislation_code%TYPE;
g_asg_action_id          pay_assignment_actions.assignment_action_id%TYPE;
g_action_effective_date  date;
g_action_type            varchar2(50);
g_asgrun_dim_id          pay_balance_dimensions.balance_dimension_id%TYPE;
g_ext_dtl_rcd_id         ben_ext_rcd.ext_rcd_id%TYPE;
g_business_group_id      per_business_groups.business_group_id%TYPE;
g_person_id              per_all_assignments_f.person_id%TYPE;
g_total_dtl_lines        number(5);
g_processing_addl_asgs   boolean;
g_gre_org_id             number(15);

TYPE ValTabTyp IS TABLE OF ben_Ext_rslt_dtl.val_01%TYPE
     INDEX BY binary_integer ;

-- This is used to store the conc parameters
TYPE extract_params IS RECORD
    (session_id          number
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
    ,selection_criteria  VARCHAR2(90)
    ,reporting_dimension VARCHAR2(90)
    ,extract_start_date  DATE
    ,extract_end_date    DATE
    ,org_id              hr_all_organization_units.organization_id%TYPE
    ,person_type_id      PER_PERSON_TYPES.PERSON_TYPE_ID%TYPE
    ,location_id         hr_locations_all.location_id%TYPE
    ,benefit_action_id   ben_person_actions.benefit_action_id%TYPE
    );
TYPE t_extract_params IS TABLE OF extract_params INDEX BY BINARY_INTEGER;
g_extract_params  t_extract_params;

-- Used to maintain the element details
TYPE ele_details IS RECORD
    (input_name           pay_input_values_f.NAME%TYPE
    ,input_value_id       pay_input_values_f.input_value_id%TYPE
    ,information_category pay_element_types_f.element_information_category%TYPE
    ,pretax_category      pay_element_types_f.element_information1%TYPE
    ,primary_balance_id   pay_balance_types.balance_type_id%TYPE
    ,primary_balance_name pay_balance_types.balance_name%TYPE
    ,AT_ele_type_id       pay_element_types_f.element_type_id%TYPE
    ,AT_ipv_id            pay_input_values_f.input_value_id%TYPE
    ,AT_balance_id        pay_balance_types.balance_type_id%TYPE
    ,CatchUp_ele_type_id  pay_element_types_f.element_type_id%TYPE
    ,CatchUp_ipv_id       pay_input_values_f.input_value_id%TYPE
    ,CatchUp_Balance_id   pay_balance_types.balance_type_id%TYPE
    ,ER_Balance_id        pay_balance_types.balance_type_id%TYPE
    ,ATER_Balance_id      pay_balance_types.balance_type_id%TYPE
    );

TYPE t_ele_details IS TABLE OF ele_details INDEX BY BINARY_INTEGER;
g_element         t_ele_details;

-- Used to maintain the assignment action details
TYPE assig_details IS RECORD
    (person_id            per_all_assignments_f.person_id%TYPE
    ,organization_id      per_all_assignments_f.organization_id%TYPE
    ,assignment_type      per_all_assignments_f.assignment_type%TYPE
    ,effective_start_date date
    ,effective_end_date   date
    ,Calculate_Amount     VARCHAR2(50)
    ,assignment_status    per_assignment_status_types.user_status%TYPE
    ,employment_category  hr_lookups.meaning%TYPE
    ,normal_hours         per_all_assignments_f.normal_hours%TYPE
    ,date_start           date
    ,termination_date     date
    );

TYPE t_assig_details IS TABLE OF assig_details INDEX BY BINARY_INTEGER;
g_primary_assig         t_assig_details;

-- Used to maintain the assignment details
TYPE leg_rules IS RECORD
    (person_id            per_all_assignments_f.person_id%TYPE
    ,gre_org_id           per_all_assignments_f.organization_id%TYPE
    ,assignment_type      per_all_assignments_f.assignment_type%TYPE
    ,primary_asg_valid    VARCHAR2(2)
    ,secondary_asg_valid  VARCHAR2(2)
    );

TYPE t_leg_rules IS TABLE OF leg_rules INDEX BY BINARY_INTEGER;
g_mx_rules        t_leg_rules;

TYPE ele_count_details IS RECORD
    (count                number
    ,input_value_id       pay_input_values_f.input_value_id%TYPE
    ,assignment_action_id pay_assignment_actions.assignment_action_id%TYPE
    ,ele_type_id          pay_element_types_f.element_type_id%TYPE
     );

g_AfterTax    ele_count_details;
g_CatchUp     ele_count_details;
g_PreTax      ele_count_details;


TYPE balance_details IS RECORD
    (balance_name           pay_balance_types.balance_name%TYPE
    ,balance_type_id        pay_balance_types.balance_type_id%TYPE
    ,defined_balance_id     pay_defined_balances.defined_balance_id%TYPE
     );

TYPE t_balance_details IS TABLE OF balance_details INDEX BY BINARY_INTEGER;
g_balance_detls         t_balance_details;


TYPE eleinv_details IS RECORD
    (element_name      pay_element_types_f.element_name%TYPE
    ,input_name        pay_input_values_f.NAME%TYPE
    ,element_type_id   pay_element_types_f.element_type_id%TYPE
    ,input_value_id    pay_input_values_f.input_value_id%TYPE
     );

TYPE t_eleinv_details IS TABLE OF eleinv_details INDEX BY BINARY_INTEGER;
g_element_input_dets     t_eleinv_details;

-- For concurrent program parameter values
TYPE conc_prog_details IS RECORD
    (extract_name        ben_ext_dfn.NAME%TYPE
    ,reporting_options   hr_lookups.meaning%TYPE
    ,selection_criteria  hr_lookups.meaning%TYPE
    ,elementset          pay_element_sets.element_set_name%TYPE
    ,elementname         pay_element_types_f.element_name%TYPE
    ,beginningdt         date
    ,endingdt            date
    ,grename             hr_organization_units.NAME%TYPE
    ,payrollname         pay_payrolls_f.payroll_name%TYPE
    ,consolset           pay_consolidation_sets.consolidation_set_name%TYPE
    ,org_name            hr_all_organization_units.NAME%TYPE
    ,person_type         per_person_types.user_person_type%TYPE
    ,location            hr_locations_all.location_code%TYPE
     );

TYPE t_conc_prog_details IS TABLE OF conc_prog_details INDEX BY binary_integer;
g_conc_prog_details     t_conc_prog_details;

-- =============================================================================
-- Pension_Extract_Process:
-- =============================================================================
PROCEDURE Pension_Extract_Process
         (errbuf                        OUT nocopy   varchar2
         ,retcode                       OUT nocopy   varchar2
         ,p_benefit_action_id           IN     number
         ,p_ext_dfn_id                  IN     number
         ,p_ext_dfn_data_typ            IN     varchar2
         ,p_reporting_dimension         IN     varchar2
         ,p_is_fullprofile_data_typ     IN     varchar2
         ,p_selection_criteria          IN     varchar2
         ,p_is_element_set              IN     varchar2
         ,p_element_set_id              IN     number
         ,p_is_element                  IN     varchar2
         ,p_element_type_id             IN     number
         ,p_report_dfn_typ_id           IN     varchar2
         ,p_start_date                  IN     varchar2
         ,p_end_date                    IN     varchar2
         ,p_gre_id                      IN     number
         ,p_payroll_id                  IN     number
         ,p_con_ext_dfn_typ_id          IN     varchar2
         ,p_con_is_fullprofile_data_typ IN     varchar2
         ,p_con_set                     IN     number
         ,p_business_group_id           IN     number
         ,p_org_id                      IN     number
         ,p_person_type_id              IN     number
         ,p_location_id                 IN     number
         ,p_ext_rslt_id                 IN     number DEFAULT NULL );
-- =============================================================================
-- ~ Get_Element_Entry_Value: Gets the elements entry value from run-results in
-- ~ in case the reporting dimension is Assig. Run level and for other dimension
-- ~ fetchs the screen entry value based on the extract end-date.
-- =============================================================================
FUNCTION Get_Element_Entry_Value
        (p_assignment_id       IN         number
        ,p_business_group_id   IN         number
        ,p_element_name        IN         varchar2
        ,p_input_name          IN         varchar2
        ,p_error_message       OUT NOCOPY varchar2
         ) RETURN varchar2 ;
-- =============================================================================
-- Get_SIT_Segment:
-- =============================================================================
FUNCTION Get_SIT_Segment
        (p_business_group_id  IN number
        ,p_assignment_id      IN number
        ,p_effective_date     IN date
        ,p_structure_code     IN varchar2
        ,p_segment_name       IN varchar2
        ,p_error_code         OUT NOCOPY varchar2
        ,p_err_message        OUT NOCOPY varchar2
        ) RETURN varchar2;
-- =============================================================================
-- Get_DDF_Value:
-- =============================================================================
FUNCTION Get_DDF_DF_Value
        (p_business_group_id  IN number
        ,p_assignment_id      IN number
        ,p_effective_date     IN date
        ,p_flex_name          IN varchar2
        ,p_flex_context       IN varchar2
        ,p_flex_field_title   IN varchar2
        ,p_error_code         OUT NOCOPY varchar2
        ,p_err_message        OUT NOCOPY varchar2
        ) RETURN varchar2;

-- =============================================================================
-- Get_Balance_Value:
-- =============================================================================
FUNCTION Get_Balance_Value
        (p_assignment_id       IN         number
        ,p_business_group_id   IN         number
        ,p_balance_name        IN         varchar2
        ,p_error_message       OUT NOCOPY varchar2
         ) RETURN number;

-- =============================================================================
-- Get_ConcProg_Information:
-- =============================================================================
FUNCTION Get_ConcProg_Information
        (p_header_type IN varchar2
        ,p_error_message OUT NOCOPY varchar2) RETURN varchar2;
-- =============================================================================
-- Get_Participant_Status_Code:
-- =============================================================================
FUNCTION Get_Participant_Status_Code
        (p_business_group_id       IN number
        ,p_assignment_id           IN number
        ,p_effective_date          IN date
        ,p_original_hire_date      OUT NOCOPY date
        ,p_recent_hire_date        OUT NOCOPY date
        ,p_actual_termination_date OUT NOCOPY date
        ,p_extract_date            OUT NOCOPY date
        ,p_person_type             OUT NOCOPY varchar2
        ,p_401k_entry_value        OUT NOCOPY varchar2
        ,p_entry_eff_date          OUT NOCOPY date
        ,p_error_code              OUT NOCOPY varchar2
        ,p_err_message             OUT NOCOPY varchar2
        )RETURN number;

-- =============================================================================
-- Get_Pay_value:
-- =============================================================================
FUNCTION Get_Pay_value
        (p_assignment_id       IN number
        ,p_business_group_id   IN number
        ,p_effective_date      IN date
        ,p_error_message       OUT NOCOPY varchar2
        ) RETURN number;

-- =============================================================================
-- Get_Data_Elements:
-- =============================================================================
FUNCTION Get_Data_Elements
        (p_assignment_id       IN  number
        ,p_business_group_id   IN  number
        ,p_effective_date      IN  date
        ,p_data_ele_name       IN  varchar2
        ,p_error_message       OUT nocopy varchar2
        ) RETURN varchar2;
-- =============================================================================
-- Get_Payroll_Date:
-- =============================================================================
FUNCTION Get_Payroll_Date
        (p_assignment_id       IN number
        ,p_business_group_id   IN number
        ,p_effective_date      IN date
        ,p_error_message       OUT nocopy varchar2
        ) RETURN varchar2;
-- =============================================================================
-- Check_Asg_Actions:
-- =============================================================================
FUNCTION Check_Asg_Actions
        (p_assignment_id       IN number
        ,p_business_group_id   IN number
        ,p_effective_date      IN date
        ,p_error_message       OUT nocopy varchar2
        ) RETURN varchar2;

-- =============================================================================
-- Check_Asg_Actions:This is used to check the person id is valid for passed
-- orgId,locationId and person type id.
-- =============================================================================
FUNCTION Chk_Person_Asg
        (p_assignment_id  IN number
        ,p_person_id      IN number
        ,p_bus_grp_id     IN number
        ,p_gre_org_id     IN number Default Null
        ,p_org_id         IN number
        ,p_person_type_id IN number
        ,p_location_id    IN number
        ,p_effective_date IN date
         ) RETURN varchar2 ;

-- =============================================================================
-- Pay_US_Pension_Criteria: The Main extract criteria that would be used for the
-- pension extract.
-- =============================================================================
FUNCTION Pension_Criteria_Full_Profile
        (p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date       IN date
        ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
        ,p_warning_message      OUT NOCOPY varchar2
        ,p_error_message        OUT NOCOPY varchar2
         ) RETURN varchar2;
-- =============================================================================
-- Del_Service_Detail_Recs:
-- =============================================================================
FUNCTION Del_Service_Detail_Recs
        (p_business_group_id IN ben_ext_rslt_dtl.business_group_id%TYPE
         ) RETURN number;

-- ====================================================================
-- Get_Current_Extract_Result:
-- ====================================================================
FUNCTION get_current_extract_result RETURN number;
-- ====================================================================
-- Get_Current_Extract_Person:
-- ====================================================================
FUNCTION Get_Current_Extract_Person
        (p_assignment_id     IN number  -- context
         ) RETURN number;

-- ====================================================================
-- Raise_Extract_Warning:
-- ====================================================================
FUNCTION Raise_Extract_Warning
        (p_assignment_id   IN number    -- context
        ,p_error_text      IN varchar2
        ,p_error_number    IN number    DEFAULT NULL
         ) RETURN number;

End PQP_Pension_Extracts;

 

/
