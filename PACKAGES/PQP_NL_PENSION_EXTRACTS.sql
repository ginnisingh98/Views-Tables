--------------------------------------------------------
--  DDL for Package PQP_NL_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_PENSION_EXTRACTS" AUTHID CURRENT_USER AS
/* $Header: pqpnlpext.pkh 120.8.12010000.3 2010/02/11 04:56:14 rsahai ship $ */

g_conc_request_id         NUMBER;
g_legislation_code        per_business_groups.legislation_code%TYPE;
g_asg_action_id           pay_assignment_actions.assignment_action_id%TYPE;
g_action_effective_date   DATE;
g_action_type             VARCHAR2(50);
g_asgrun_dim_id           pay_balance_dimensions.balance_dimension_id%TYPE;
g_ext_dtl_rcd_id          ben_ext_rcd.ext_rcd_id%TYPE;
g_business_group_id       per_business_groups.business_group_id%TYPE;
g_person_id               per_all_assignments_f.person_id%TYPE;
g_index_fur               NUMBER := 0;
g_count_fur               NUMBER := 0;
g_index_ipap              NUMBER := 0;
g_count_ipap              NUMBER := 0;
g_fur_contribution        NUMBER := 0;
g_fur_contrib_kind        VARCHAR2(2);
g_ipap_contribution       NUMBER := 0;
g_ins_cd_anw_ipap         VARCHAR2(2);
g_count_05                NUMBER := 0;
g_index_05                NUMBER := 0;
g_retro_ptp_count         NUMBER := 0;
g_retro_si_ptp_count      NUMBER := 0;
g_retro_21_count          NUMBER := 0;
g_retro_21_index          NUMBER := 0;
g_retro_22_count          NUMBER := 0;
g_retro_22_index          NUMBER := 0;
g_si_index                NUMBER := 0;
g_si_count                NUMBER := 0;
g_si_days                 NUMBER := 0;
g_retro_ptp_element_id    NUMBER;
g_retro_ptp_iv_id         NUMBER;
g_retro_vop_iv_id         NUMBER;
g_retro_si_ptp_element_id NUMBER;
g_retro_si_ptp_iv_id      NUMBER;
g_retro_siw_element_id    NUMBER;
g_retro_siw_iv_id         NUMBER;
g_retro_sit_iv_id         NUMBER;
g_retro_sit_iv_id1        NUMBER;
g_retro_sid_element_id    NUMBER;
g_retro_sid_iv_id         NUMBER;
g_retro_pv_iv_id          NUMBER;
g_er_index                NUMBER;
g_er_child_index          NUMBER;

--6501898
g_abp_ptp_iv_id           NUMBER;
g_abp_ptp_ele_id          NUMBER;
--6501898

g_sort_position           NUMBER := 1;  --9278285

TYPE extract_params IS RECORD
      (session_id          NUMBER
      ,ext_dfn_type        pqp_extract_attributes.ext_dfn_type%TYPE
      ,business_group_id   per_business_groups.business_group_id%TYPE
      ,legislation_code    per_business_groups.legislation_code%TYPE
      ,currency_code       per_business_groups.currency_code%TYPE
      ,concurrent_req_id   ben_ext_rslt.request_id%TYPE
      ,ext_dfn_id          ben_ext_dfn.ext_dfn_id%TYPE
      ,element_set_id      pay_element_sets.element_set_id%TYPE
      ,element_type_id     pay_element_types_f.element_type_id%TYPE
      ,payroll_id          pay_payrolls_f.payroll_id%TYPE
      ,org_id              hr_all_organization_units.organization_id%TYPE
      ,gre_org_id          hr_all_organization_units.organization_id%TYPE
      ,con_set_id          pay_consolidation_sets.consolidation_set_id%TYPE
      ,selection_criteria  VARCHAR2(90)
      ,reporting_dimension VARCHAR2(90)
      ,extract_start_date  DATE
      ,extract_end_date    DATE
      ,extract_rec_01      VARCHAR2(1)
      );

TYPE t_extract_params IS TABLE OF extract_params INDEX BY Binary_Integer;
g_extract_params  t_extract_params;

TYPE org_details IS RECORD
      (business_group_id   per_business_groups.business_group_id%TYPE
      ,legislation_code    per_business_groups.legislation_code%TYPE
      ,gre_org_id          hr_all_organization_units.organization_id%TYPE
      );
TYPE t_org_details IS TABLE OF org_details INDEX BY Binary_Integer;
g_ord_details  t_org_details;
g_ord_details1 t_org_details;

--Table contains all the employers
TYPE employer_list IS RECORD
      (gre_org_id          hr_all_organization_units.organization_id%TYPE
      );
TYPE t_employer_list IS TABLE OF employer_list INDEX BY Binary_Integer;
g_employer_list  t_employer_list;

-- Table contains subgroups of organizations which has to be totalled
TYPE employer_child_list IS RECORD
      (gre_org_id          hr_all_organization_units.organization_id%TYPE
      );
TYPE t_employer_child_list IS TABLE OF employer_child_list INDEX BY Binary_Integer;
g_employer_child_list  t_employer_child_list;

--Tables contains count of child organizations for each employer
TYPE org_grp_list_cnt IS RECORD
      ( org_grp_count  NUMBER
      );
TYPE t_org_grp_list_cnt IS TABLE OF org_grp_list_cnt INDEX BY Binary_Integer;
g_org_grp_list_cnt  t_org_grp_list_cnt;





TYPE assig_details IS RECORD
      (person_id            per_all_assignments_f.person_id%TYPE
      ,organization_id      per_all_assignments_f.organization_id%TYPE
      ,assignment_type      per_all_assignments_f.assignment_type%TYPE
      ,effective_start_date DATE
      ,effective_end_date   DATE
      ,assignment_status    per_assignment_status_types.user_status%TYPE
      ,employment_category  hr_lookups.meaning%TYPE
      ,date_start           DATE
      ,termination_date     DATE
      ,payroll_id           pay_payrolls_f.payroll_id%TYPE
      ,abp_er_num           VARCHAR2(10)
      ,ee_num               per_all_people_f.employee_number%TYPE
      ,asg_seq_num          per_all_assignments_f.assignment_sequence%TYPE
      ,ni_num               per_all_people_f.national_identifier%TYPE
      ,per_ln               per_all_people_f.last_name%TYPE
      ,per_initials         per_all_people_f.per_information1%TYPE
      ,per_prefix           per_all_people_f.pre_name_adjunct%TYPE
      ,gender               per_all_people_f.sex%TYPE
      ,dob                  per_all_people_f.date_of_birth%TYPE
      ,partner_last_name    per_all_people_f.last_name%TYPE
      ,partner_prefix       per_all_people_f.pre_name_adjunct%TYPE
      ,address_fem_ee       per_all_people_f.per_information14%TYPE
      ,marital_status       per_all_people_f.marital_status%TYPE
      ,primary_flag         per_all_assignments_f.primary_flag%TYPE
      );

TYPE t_assig_details IS TABLE OF assig_details INDEX BY BINARY_INTEGER;
g_primary_assig         t_assig_details;

TYPE retro_hires IS RECORD
(person_id   number
,new_hire    date
,old_hire    date
,type        number);

TYPE t_retro_hires IS TABLE OF retro_hires INDEX BY BINARY_INTEGER;
g_retro_hires t_retro_hires;


TYPE ben_ext_rcds IS RECORD
      (record_number       Varchar2(3)
      ,record_seqnum       ben_ext_rcd_in_file.seq_num%TYPE
      ,hide_flag           ben_ext_rcd_in_file.hide_flag%TYPE
      ,ext_rcd_id          ben_ext_rcd.ext_rcd_id%TYPE
   	  ,rcd_type_cd         ben_ext_rcd.rcd_type_cd%TYPE
      );
TYPE t_g_ext_rcds IS TABLE OF ben_ext_rcds INDEX BY Binary_Integer;
g_ext_rcds  t_g_ext_rcds;

TYPE balance_details IS RECORD
      ( balance_name           pay_balance_types.balance_name%TYPE
       ,balance_type_id        pay_balance_types.balance_type_id%TYPE
       ,defined_balance_id     pay_defined_balances.defined_balance_id%TYPE
      );
TYPE t_balance_details IS TABLE OF balance_details INDEX BY Binary_Integer;
g_balance_detls         t_balance_details;

--Record ID s with Seq numbers
TYPE rcd_dtls IS RECORD
      ( ext_rcd_id  ben_ext_rcd.ext_rcd_id%TYPE
      );
TYPE t_rcd_dtls IS TABLE OF rcd_dtls INDEX BY Binary_Integer;
g_rcd_dtls  t_rcd_dtls;
g_retro_rcd t_rcd_dtls;

--Added for concurrent program parameter
TYPE conc_prog_details IS RECORD
      ( extract_name        ben_ext_dfn.name%TYPE
       ,reporting_options   hr_lookups.meaning%TYPE
       ,selection_criteria  hr_lookups.meaning%TYPE
       ,elementset	        pay_element_sets.element_set_name%TYPE
       ,elementname	        pay_element_types_f.element_name%TYPE
       ,beginningdt         DATE
       ,endingdt	        DATE
       ,grename		        hr_organization_units.name%TYPE
       ,payrollname	        pay_payrolls_f.payroll_name%TYPE
       ,consolset	        pay_consolidation_sets.consolidation_set_name%TYPE
       ,orgname             hr_all_organization_units.name%TYPE
       ,orgid		        hr_all_organization_units.organization_id%TYPE
      );

TYPE t_conc_prog_details IS TABLE OF conc_prog_details INDEX BY Binary_Integer;
g_conc_prog_details     t_conc_prog_details;

TYPE assignment_seq_rec_type IS RECORD(assignment_sequence varchar2(2));

TYPE t_asg_seq IS TABLE OF assignment_seq_rec_type INDEX BY Binary_Integer;
g_assignment_seq_rec t_asg_seq;

TYPE date_rows IS RECORD
    (old_start     ben_ext_chg_evt_log.old_val1%TYPE
    ,new_start     ben_ext_chg_evt_log.new_val1%TYPE
    ,old_end       ben_ext_chg_evt_log.old_val2%TYPE
    ,new_end       ben_ext_chg_evt_log.new_val2%TYPE
    );
TYPE t_date_rows IS TABLE OF date_rows INDEX BY Binary_Integer;

g_fur_dates t_date_rows;
g_ipap_dates t_date_rows;

TYPE rec_05_rows IS RECORD
     (old_start    ben_ext_chg_evt_log.old_val1%TYPE
     ,new_start    ben_ext_chg_evt_log.new_val1%TYPE
     ,old_end      ben_ext_chg_evt_log.old_val2%TYPE
     ,new_end      ben_ext_chg_evt_log.new_val2%TYPE
     ,partn_kind   varchar2(30)
     ,partn_value  varchar2(30)
     ,dt_chg       ben_ext_chg_evt_log.prmtr_07%TYPE
     ,eddt_chg     ben_ext_chg_evt_log.prmtr_07%TYPE
     ,end_reason   ben_ext_chg_evt_log.prmtr_09%TYPE
     ,part_time_perc number(9,2)
     ,ppp_kind     varchar2(1)
     ,opnp_kind    varchar2(1)
     ,fpu_kind     varchar2(1)
     ,pos_id       per_periods_of_service.period_of_service_id%TYPE
     );
TYPE t_rec_05_rows IS TABLE OF rec_05_rows INDEX BY Binary_Integer;

g_rec05_rows t_rec_05_rows;

TYPE si_date_rows IS RECORD
    (start_date      ben_ext_chg_evt_log.new_val1%TYPE
    ,end_date        ben_ext_chg_evt_log.new_val2%TYPE
    ,new_start       ben_ext_chg_evt_log.new_val1%TYPE
    ,old_start       ben_ext_chg_evt_log.old_val1%TYPE
    ,new_end         ben_ext_chg_evt_log.new_val2%TYPE
    ,old_end         ben_ext_chg_evt_log.old_val2%TYPE
    ,end_reason      ben_ext_chg_evt_log.prmtr_09%TYPE
    ,part_time_perc  NUMBER(9,2)
    ,display_si_flag VARCHAR2(1)
    );
TYPE t_si_date_rows IS TABLE OF si_date_rows INDEX BY Binary_Integer;

g_si_rec t_si_date_rows;

TYPE org_list IS RECORD
    ( org_id      hr_all_organization_units.organization_id%TYPE);

TYPE t_org_list IS TABLE OF org_list INDEX BY Binary_Integer;
g_org_list  t_org_list;

TYPE si_wages IS RECORD
    ( WAO           VARCHAR2(1)
     ,ZW            VARCHAR2(1)
     ,ZFW           VARCHAR2(1));

TYPE t_si_wages IS TABLE OF si_wages INDEX BY Binary_Integer;
g_si_wages  t_si_wages;

-- =============================================================================
-- Pension_Extract_Process:
-- =============================================================================
PROCEDURE Pension_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_benefit_action_id           IN     NUMBER
           ,p_ext_dfn_id                  IN     NUMBER
           ,p_org_id                      IN     NUMBER
           ,p_payroll_id                  IN     NUMBER
           ,p_start_date                  IN     VARCHAR2
           ,p_end_date                    IN     VARCHAR2
           ,p_extract_rec_01              IN     VARCHAR2
           ,p_business_group_id           IN     NUMBER
	     ,p_sort_position               IN     NUMBER DEFAULT 1 --9278285
           ,p_consolidation_set           IN     NUMBER
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL
           );

-- =============================================================================
-- Get_Balance_Value:
-- =============================================================================
FUNCTION Get_Balance_Value
           (p_assignment_id       IN         NUMBER
           ,p_business_group_id   IN         NUMBER
           ,p_balance_name        IN         VARCHAR2
           ,p_error_message       OUT NOCOPY VARCHAR2
            ) RETURN NUMBER;

-- =============================================================================
-- Get_ConcProg_Information:
-- =============================================================================
FUNCTION Get_ConcProg_Information
           (p_header_type IN VARCHAR2
           ,p_error_message OUT NOCOPY VARCHAR2
	    )RETURN Varchar2 ;


-- =============================================================================
-- Pension_Criteria_Full_Profile: The Main extract criteria that would be used
-- for the pension extract.
-- =============================================================================
FUNCTION Pension_Criteria_Full_Profile
          (p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
          ,p_effective_date       IN date
          ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
          ,p_warning_message      OUT NOCOPY VARCHAR2
          ,p_error_message        OUT NOCOPY VARCHAR2
           ) RETURN VARCHAR2;

-- ====================================================================
-- Get_Current_Extract_Result:
-- ====================================================================
FUNCTION get_current_extract_result RETURN NUMBER;

-- ====================================================================
-- Get_Current_Extract_Person:
-- ====================================================================
FUNCTION Get_Current_Extract_Person
          (p_assignment_id     IN NUMBER  -- context
           ) RETURN NUMBER;

-- ====================================================================
-- Raise_Extract_Warning:
-- ====================================================================
FUNCTION Raise_Extract_Warning
          (p_assignment_id     IN     NUMBER    -- context
          ,p_error_text        IN     VARCHAR2
          ,p_error_number      IN     NUMBER    DEFAULT NULL
           ) RETURN NUMBER;

-- ====================================================================
-- pqp_nl_get_data_element_value:
-- ====================================================================
FUNCTION pqp_nl_get_data_element_value
         ( p_assignment_id      IN NUMBER
          ,p_business_group_id  IN NUMBER
          ,p_date_earned        IN DATE
          ,p_data_element_cd    IN VARCHAR2
          ,p_error_message      OUT NOCOPY VARCHAR2
          ,p_data_element_value OUT NOCOPY VARCHAR2
         ) RETURN NUMBER ;

-- ====================================================================
-- Sort_Post_Process
-- ====================================================================
FUNCTION Sort_Post_Process
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
          )RETURN NUMBER;

-- ====================================================================
-- Sort_Post_Process
-- ====================================================================
FUNCTION Get_Header_Information
           (p_header_type IN VARCHAR2
           ,p_error_message OUT NOCOPY VARCHAR2) RETURN Varchar2;

END PQP_NL_Pension_Extracts;

/
