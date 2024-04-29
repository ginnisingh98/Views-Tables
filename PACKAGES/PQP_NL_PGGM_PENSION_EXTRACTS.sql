--------------------------------------------------------
--  DDL for Package PQP_NL_PGGM_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_PGGM_PENSION_EXTRACTS" AUTHID CURRENT_USER AS
/* $Header: pqpnlpggmpext.pkh 120.2 2006/08/29 17:26:30 sashriva noship $ */
g_conc_request_id         NUMBER;
g_asg_action_id           pay_assignment_actions.assignment_action_id%TYPE;
g_action_effective_date   DATE;
g_action_type             VARCHAR2(50);
g_asgrun_dim_id           pay_balance_dimensions.balance_dimension_id%TYPE;
g_ext_dtl_rcd_id          ben_ext_rcd.ext_rcd_id%TYPE;
g_person_id               per_all_assignments_f.person_id%TYPE;
g_retro_ptp_count         NUMBER := 0;
g_debug                   BOOLEAN := FALSE;
g_legislation_code        per_business_groups.legislation_code%TYPE;
g_business_group_id       per_business_groups.business_group_id%TYPE;
g_ptp_index               NUMBER:=0;
g_ptp_chg_date            DATE;
g_ptp_chg_screen_value    VARCHAR2(50);

g_rec_060_count           NUMBER:=0;
g_060_index               NUMBER:=0;
g_rec060_mult_flag        VARCHAR2(1):='N';

g_rec_080_type1_count     NUMBER:=0;
g_rec_080_type2_count     NUMBER:=0;
g_rec_080_type3_count     NUMBER:=0;
g_rec_080_type4_count     NUMBER:=0;
g_080_index               NUMBER:=0;
g_rec080_mult_flag        VARCHAR2(1):='N';
g_080_display_flag        varchaR2(1):='N';
--Index for storing result detail ids which will be delete in post process
g_index_rslt_dtl          NUMBER:=0;
g_pggm_employer_num       varchar2(6):='000000';
g_main_rec_081            varchar2(1):='N';
g_rec_081_type            varchar2(1):='C';
g_rec_081_count           NUMBER:=0;
g_081_index               NUMBER:=0;




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
      ,extract_type        VARCHAR2(1)
      );
TYPE t_extract_params IS TABLE OF extract_params INDEX BY Binary_Integer;
g_extract_params  t_extract_params;

TYPE org_details IS RECORD
      (business_group_id   per_business_groups.business_group_id%TYPE
      ,legislation_code    per_business_groups.legislation_code%TYPE
      ,gre_org_id          hr_all_organization_units.organization_id%TYPE
      );
TYPE t_org_details IS TABLE OF org_details INDEX BY Binary_Integer;
g_ord_details   t_org_details;
g_ord_details1  t_org_details;

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
      ,pggm_er_num          VARCHAR2(10)
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

--Retro Hire
TYPE retro_hires IS RECORD
(person_id   number
,new_hire    date
,old_hire    date
,type        number);

TYPE t_retro_hires IS TABLE OF retro_hires INDEX BY BINARY_INTEGER;
g_retro_hires t_retro_hires;

--Extract Records
TYPE ben_ext_rcds IS RECORD
      (record_number       Varchar2(3)
      ,record_seqnum       ben_ext_rcd_in_file.seq_num%TYPE
      ,hide_flag           ben_ext_rcd_in_file.hide_flag%TYPE
      ,ext_rcd_id          ben_ext_rcd.ext_rcd_id%TYPE
      ,rcd_type_cd         ben_ext_rcd.rcd_type_cd%TYPE
      );
TYPE t_g_ext_rcds IS TABLE OF ben_ext_rcds INDEX BY Binary_Integer;
g_ext_rcds  t_g_ext_rcds;

--Balance Details
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
       ,elementset	    pay_element_sets.element_set_name%TYPE
       ,elementname	    pay_element_types_f.element_name%TYPE
       ,beginningdt         DATE
       ,endingdt	    DATE
       ,extract_type        VARCHAR2(1)
       ,payrollname	    pay_payrolls_f.payroll_name%TYPE
       ,consolset	    pay_consolidation_sets.consolidation_set_name%TYPE
       ,orgname             hr_all_organization_units.name%TYPE
       ,orgid		    hr_all_organization_units.organization_id%TYPE
      );

TYPE t_conc_prog_details IS TABLE OF conc_prog_details INDEX BY Binary_Integer;
g_conc_prog_details     t_conc_prog_details;

--Child organizations
TYPE org_list IS RECORD
    ( org_id      hr_all_organization_units.organization_id%TYPE);

TYPE t_org_list IS TABLE OF org_list INDEX BY Binary_Integer;
g_org_list  t_org_list;

--Record 040 details
TYPE rcd_040 IS RECORD
      (  address_dt_chg  DATE
      );
TYPE t_rcd_040 IS TABLE OF rcd_040 INDEX BY Binary_Integer;
g_rcd_040  t_rcd_040;

--Record 060 details
TYPE rcd_060 IS RECORD
      (  pension_sal_amount     Number,
         pension_sal_dt_change  DATE,
	 element_type           varchar2(1)
      );
TYPE t_rcd_060 IS TABLE OF rcd_060 INDEX BY Binary_Integer;
g_rcd_060  t_rcd_060;


--Record 080 details
TYPE rcd_080 IS RECORD
      (  part_time_pct_dt_change  DATE,
         part_time_factor        Number,
	 incidental_code         Number
      );
TYPE t_rcd_080 IS TABLE OF rcd_080 INDEX BY Binary_Integer;
g_rcd_080  t_rcd_080;

--Record 081 details
TYPE rcd_081 IS RECORD
      (  year_of_change  varchar2(10)
      );
TYPE t_rcd_081 IS TABLE OF rcd_081 INDEX BY Binary_Integer;
g_rcd_081  t_rcd_081;

--Delete Result Records Detail
TYPE delete_rslt_dtl IS RECORD
      (  ext_rslt_dtl_id  NUMBER
      );
TYPE t_delete_rslt_dtl IS TABLE OF delete_rslt_dtl INDEX BY Binary_Integer;
g_delete_rslt_dtl  t_delete_rslt_dtl;



--Delete Result Records Detail
TYPE per_details IS RECORD
      (  national_identifier varchar2(9),
         date_of_birth  varchar2(6),
	 last_name      varchar2(18),
         prefix         varchar2(7)
      );
TYPE t_per_details IS TABLE OF per_details INDEX BY Binary_Integer;
g_per_details  t_per_details;

-- =============================================================================
-- Pension_Extract_Process:This function is called from Concurrent Request
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
           ,p_extract_type                IN     VARCHAR2
           ,p_business_group_id           IN     NUMBER
           ,p_consolidation_set           IN     NUMBER
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL
           );

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
-- pqp_nl_get_data_element_value:
-- ====================================================================
FUNCTION PQP_NL_Get_Data_Element_Value
         ( p_assignment_id      IN NUMBER
          ,p_business_group_id  IN NUMBER
          ,p_date_earned        IN DATE
          ,p_data_element_cd    IN VARCHAR2
          ,p_error_message      OUT NOCOPY VARCHAR2
          ,p_data_element_value OUT NOCOPY VARCHAR2
         ) RETURN NUMBER ;
-- =============================================================================
-- Chk_If_Req_To_Extract: For a given assignment check to see the record needs to
-- be extracted or not.
-- =============================================================================
FUNCTION Chk_If_Req_To_Extract
          (p_assignment_id     IN Number
          ,p_business_group_id IN Number
          ,p_effective_date    IN Date
          ,p_record_num        IN Varchar2
          ,p_error_message     OUT NOCOPY Varchar2) RETURN Varchar2;

-- =============================================================================
-- Get_Conc_Prog_Information: Get Header Information
-- =============================================================================
FUNCTION Get_Conc_Prog_Information
           (p_header_type        IN Varchar2
           ,p_error_message      OUT NOCOPY Varchar2
	   ,p_data_element_value OUT NOCOPY Varchar2)
RETURN Number;
-- ====================================================================
-- Post Process
-- ====================================================================
FUNCTION Sort_Post_Process
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
          )RETURN Number;
-- ====================================================================
-- Raise_Extract_Warning:
-- ====================================================================
FUNCTION Raise_Extract_Warning
          (p_assignment_id     IN     NUMBER    -- context
          ,p_error_text        IN     VARCHAR2
          ,p_error_number      IN     NUMBER    DEFAULT NULL
           ) RETURN NUMBER;

END PQP_NL_PGGM_Pension_Extracts;

/
