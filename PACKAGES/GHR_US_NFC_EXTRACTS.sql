--------------------------------------------------------
--  DDL for Package GHR_US_NFC_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_US_NFC_EXTRACTS" AUTHID CURRENT_USER as
/* $Header: ghrusnfcpa.pkh 120.8 2005/09/16 11:48:26 sshetty noship $ */

-- =============================================================================
-- Package global variables
-- =============================================================================

   g_conc_request_id        number;
   g_legislation_code       per_business_groups.legislation_code%type;
   g_ext_dtl_rcd_id         ben_ext_rcd.ext_rcd_id%type;
   g_business_group_id      per_business_groups.business_group_id%type;
   g_person_id              per_all_assignments_f.person_id%type;
   g_effective_date         date;
   g_ext_start_dt           date;
   g_ext_end_dt             date;
   g_auth_date              VARCHAR2(24);
   g_rpa_id_apt             NUMBER;

   type rcds_rec is record
        (data_value         varchar2(600)
        ,seq_num            number(15)
        ,col_name           varchar2(600)
        );
   type t_rcds is table of  rcds_rec
        index by binary_integer;
   g_ext_rcd                t_rcds;


   TYPE extract_params IS RECORD
      (session_id             number
      ,business_group_id      per_business_groups.business_group_id%TYPE
      ,concurrent_req_id      ben_ext_rslt.request_id%TYPE
      ,ext_dfn_id             ben_ext_dfn.ext_dfn_id%TYPE
      ,transmission_type      varchar2(30)
      ,date_criteria          varchar2(30)
      ,from_date              date
      ,to_date                date
      ,agency_code            varchar2(30)
      ,personnel_office_id    varchar2(90)
      ,transmission_indicator varchar2(90)
      ,signon_identification  varchar2(30)
      ,user_id                varchar2(30)
      ,dept_code              varchar2(30)
      ,payroll_id             NUMBER
      ,notify                 varchar2(90)
      );
   type t_extract_params is table of extract_params
        index by binary_integer;
   g_extract_params         t_extract_params;

   type pa_req is record
       (person_id           number
       ,assignment_id       number
       ,no_of_rpa           number
       ,effective_date      date
       ,last_update_date    date
       ,pa_request_id       number
       ,pa_notification_id  number
       ,first_noa_code      ghr_pa_requests.first_noa_code%type
       ,second_noa_code     ghr_pa_requests.second_noa_code%type
       ,ext_start_date      date
       ,extract_end_dt      date
       ,remark_code         number(15)
       ,pa_remark_id        number(15)
       );
   type t_pa_req is table of pa_req
        index by binary_integer;
   g_pa_req             t_pa_req;
   g_aw_req             t_pa_req;

   type pa_add_hist is record
      (pa_history_id        number(15)
      ,process_date         date
      ,effective_date       date
      ,person_id            number(15)
      ,assignment_id        number(15)
      ,address_id           number(15)
      );
   type t_pa_req_rec is table of ghr_pa_requests%ROWTYPE
        index by binary_integer;
   g_rpa_rec            t_pa_req_rec;
   g_awd_rec            t_pa_req_rec;
   --
   type t_add_rec is table of ghr_addresses_h_v%ROWTYPE
        index by binary_integer;
   g_address_rec            t_add_rec;
   --
   type pa_rem_rec is record
       (remark_code_1       varchar2(15)
       ,remark_code_2       varchar2(15)
       ,remark_code_3       varchar2(15)
       ,remark_code_4       varchar2(15)
       ,remark_code_5       varchar2(15)
       ,remark_code_6       varchar2(15)
       ,remark_code_7       varchar2(15)
       ,remark_code_8       varchar2(15)
       ,remark_code_9       varchar2(15)
       ,remark_code_10      varchar2(15)
       );
   type t_pa_rem_rec is table of pa_rem_rec
        index by binary_integer;
   g_pa_req_remark          t_pa_rem_rec;
   --
   type valtabtyp is table of ben_ext_rslt_dtl.val_01%type
        index by binary_integer ;

TYPE pa_extract_params IS RECORD
      (session_id             number
      ,business_group_id      per_business_groups.business_group_id%TYPE
      ,concurrent_req_id      ben_ext_rslt.request_id%TYPE
      ,ext_dfn_id             ben_ext_dfn.ext_dfn_id%TYPE
      ,transmission_type      varchar2(30)
      ,date_criteria          varchar2(30)
      ,from_date              date
      ,to_date                date
      ,agency_code            varchar2(30)
      ,personnel_office_id    varchar2(90)
      ,transmission_indicator varchar2(90)
      ,signon_identification  varchar2(30)
      ,payroll_id             NUMBER
      ,notify                 varchar2(90)
      );
TYPE t_pa_extract_params IS TABLE OF pa_extract_params INDEX BY Binary_Integer;
g_pa_extract_params  t_pa_extract_params;


TYPE r_rpa_add_attr IS RECORD (assignment_id               NUMBER
                              ,request_id                  NUMBER
                              ,nfc_agency_code             VARCHAR2(4)
                              ,dept_code                   VARCHAR2(2)
                              ,pay_per_num                 NUMBER
                              ,poi                         VARCHAR2(4)
                              ,ssn                         VARCHAR2(9)
                              ,address_line1               VARCHAR2(240)
                              ,address_line2               VARCHAR2(240)
                              ,address_line3               VARCHAR2(240)
                              ,add_city                    VARCHAR2(4)
                              ,add_county                  VARCHAR2(15)
                              ,add_state                   VARCHAR2(6)
                              ,zip_cd                      VARCHAR2(15)
                              ,address_line1_chk           VARCHAR2(240)
                              ,address_line2_chk           VARCHAR2(240)
                              ,address_line3_chk           VARCHAR2(240)
                              ,add_city_chk                VARCHAR2(4)
                              ,add_county_chk              VARCHAR2(15)
                              ,add_state_chk               VARCHAR2(6)
                              ,zip_cd_chk                  VARCHAR2(15)
                              );
TYPE r_rpa_awd_attr IS RECORD (assignment_id               NUMBER
                              ,request_id                  NUMBER
                              ,nfc_agency_code             VARCHAR2(80)
                              ,dept_code                   VARCHAR2(80)
                              ,pay_per_num                 NUMBER
                              ,dt_cash_awd_from            DATE
                              ,dt_cash_awd_to              DATE
                              ,tangible_ben                VARCHAR2(80)
                              ,current_cash_award          VARCHAR2(30)
                              ,first_yr_savings            NUMBER(10)
                              ,intangible_ben              VARCHAR2(80)
                              ,cash_award_agency           VARCHAR2(80)
                              ,nat_act_2nd_3pos            VARCHAR2(80)
                              ,csc_auth_code_2nd_noa       VARCHAR2(80)
                              ,csc_auth_2ndcode_2nd_noa    VARCHAR2(80)
                              ,cash_awd_cd                 VARCHAR2(80)
                              ,chk_mail_addr_ind           VARCHAR2(80)
                              ,chk_mail_addr_ln1           VARCHAR2(80)
                              ,chk_mail_desg_agnt          VARCHAR2(80)
                              ,chk_mail_addr_ln2           VARCHAR2(80)
                              ,nat_act_1st_3_pos           VARCHAR2(80)
                              ,csc_auth_code_2nd_noa1      VARCHAR2(80)
                              ,csc_auth_2ndcode_2nd_noa1   VARCHAR2(80)
                              ,chk_mail_addr_city_name     VARCHAR2(80)
                              ,chk_mail_addr_state_name    VARCHAR2(80)
                              ,chk_mail_addr_zip_5         VARCHAR2(80)
                              ,chk_mail_addr_zip_4         VARCHAR2(80)
                              ,chk_mail_addr_zip_2         VARCHAR2(80)
                              ,authentication_dt           VARCHAR2(80)
                              ,awd_case_num                VARCHAR2(30)
                              ,awd_store_act_ind           VARCHAR2(30)
                              ,awd_csh_awd_typ_cd          VARCHAR2(30)
                              ,awd_fir_yr_sav              VARCHAR2(30)
                              ,awd_csh_awd_pay_cd          VARCHAR2(30)
                              ,awd_no_per_csh_awd          VARCHAR2(30)
                              ,awd_acctg_dist_fisyr_cd     VARCHAR2(30)
                              ,awd_acctg_dist_appn_cD      VARCHAR2(30)
                              ,awd_acctg_dist_slev_cd      VARCHAR2(30)
                              ,awd_csh_awd_accst_chg       VARCHAR2(30)
                              ,awd_csh_awd_cd              VARCHAR2(30)
                              );

TYPE r_rpa_attr IS RECORD(assignment_id                    NUMBER
                         ,request_id                       NUMBER
                         ,Previous_agency_code             VARCHAR2(80)
                         ,Date_entered_present_grade       VARCHAR2(80)
                         ,phy_handicap_code                VARCHAR2(80)
                         ,Date_last_pay_status_retired     VARCHAR2(80)
                         ,Frozen_CSRS_service              VARCHAR2(80)
                         ,CSRS_coverage_at_appointment     VARCHAR2(80)
                         ,Date_sick_leave_exp_ret          VARCHAR2(80)
                         ,Annual_leave_category            VARCHAR2(80)
                         ,Annual_leave_45_day_code         VARCHAR2(80)
                         ,Leave_ear_stat_py_period         VARCHAR2(80)
                         ,Date_SCD_CSR                     VARCHAR2(80)
                         ,Date_SCD_RIF                     VARCHAR2(80)
                         ,Date_TSP_vested                  VARCHAR2(80)
                         ,Date_SCD_SES                     VARCHAR2(80)
                         ,Date_Supv_Mgr_Prob               VARCHAR2(80)
                         ,Date_Spvr_Mgr_Prob_Ends          VARCHAR2(80)
                         ,Date_Prob_period_start           VARCHAR2(80)
                         ,Supv_mgr_prob_period_req         VARCHAR2(80)
                         ,Date_Career_perma_Ten_St         VARCHAR2(80)
                         ,Date_Ret_Rght_end                VARCHAR2(80)
                         ,Citizenship_code                 VARCHAR2(80)
                         ,Uniform_Svc_Status               VARCHAR2(80)
                         ,Creditable_Military_Svc          VARCHAR2(80)
                         ,Date_Ret_Military                VARCHAR2(80)
                         ,Saved_Grd_Pay_Plan               VARCHAR2(80)
                         ,Saved_Grade                      VARCHAR2(80)
                         ,Date_Corr_NoA                    VARCHAR2(80)
                         ,Date_NTE_SF50                    VARCHAR2(80)
                         ,Retention_Percent                VARCHAR2(80)
                         ,Retention_allowance              VARCHAR2(80)
                         ,Name_Corr_code                   VARCHAR2(80)
                         ,SSNO_Old                         VARCHAR2(80)
                         ,Recruitment_Percent              VARCHAR2(80)
                         ,Recruitment_bonus                VARCHAR2(80)
                         ,Relocation_percent               VARCHAR2(80)
                         ,Relocation_bonus                 VARCHAR2(80)
                         ,Supervisory_Percent              VARCHAR2(80)
                         ,Supervisory_Differential_Rate    VARCHAR2(80)
                         ,action_code                      VARCHAR2(80)
                         ,poi                              VARCHAR2(80)
                         ,nfc_agency                       VARCHAR2(80)
                         ,pmso_agency                      VARCHAR2(80)
                         ,pmso_dept                        VARCHAR2(80)
                         ,pmso_poi                         VARCHAR2(80)
                         ,pos_num                          VARCHAR2(80)
                         ,gender_code                      VARCHAR2(80)
                         ,pay_period_num                   NUMBER
                         ,mrn                              VARCHAR2(80)
                         ,race                             VARCHAR2(80)
                         ,civil_service_annuitant_share    NUMBER(9,2)
                         ,dt_scd_wgi                       VARCHAR2(80)
                         ,fehb_cov_cd                      VARCHAR2(80)
                         ,authentication_dt                VARCHAR2(80)
                         ,nat_act_prev                     VARCHAR2(80)
                         ,gain_lose_dept_non_usda          VARCHAR2(80)
                         ,csc_auth_prev_noa                VARCHAr2(80)
                         ,csc_auth_prev_2noa               VARCHAr2(80)
                         ,date_retain_rate_exp             VARCHAr2(80)
                         ,special_emp_code                 VARCHAR2(80)
                         ,special_emp_prg_code             VARCHAR2(8)
                         ,tsp_elig_cd                      VARCHAR2(80)
                         ,typ_apt_cd                       VARCHAR2(80)
                         ,veterans_pref_for_rif            VARCHAR2(1)
                         ,position_class_cd                VARCHAR2(1)
                         ,for_lang_perc                    VARCHAR2(2)
                         ,for_lang_all                     VARCHAR2(7)
                         ,wage_grd_shft_var                VARCHAR2(4)
                         ,coop_emp_ctrl_cd                 VARCHAR2(4)
                         ,coop_ann_shr_cd                  VARCHAR2(4)
                         ,coop_st_shr_sal                  VARCHAR2(8)
                         ,coop_emp_otrt_fur                VARCHAR2(8)
                         ,coop_emp_holrt_fur               VARCHAR2(8)
                         ,quart_ded_rt                     VARCHAR2(8)
                         ,quart_ded_cd                     VARCHAR2(8)
                         ,env_diff_rt                      VARCHAR2(8)
                         ,sav_grd_occ_ser                  VARCHAR2(8)
                         ,sav_grd_occ_ser_funcd            VARCHAR2(8)
                         ,agency_use                       VARCHAR2(12)
                          );


--TYPE r_noa_code IS RECORD (noa_code  VARCHAR(4));
TYPE t_gen_code is Table OF VARCHAR2(10)
                   INDEX BY BINARY_INTEGER;
TYPE t_noa_code is Table OF NUMBER
                   INDEX BY BINARY_INTEGER;

TYPE t_rpa_attr is Table OF r_rpa_attr
                  INDEX BY BINARY_INTEGER;
TYPE t_rpa_awd_attr is Table OF r_rpa_awd_attr
                  INDEX BY BINARY_INTEGER;

TYPE t_rpa_add_attr IS Table OF r_rpa_add_attr
                 INDEX BY BINARY_INTEGER;
g_rpa_add_attr  t_rpa_add_attr;
g_rpa_attr     t_rpa_attr;
g_rpa_awd_attr t_rpa_awd_attr;
g_psr_month    t_noa_code;
g_sler_month   t_noa_code;
g_NTE_SF50     t_noa_code;
g_retention    t_noa_code;
g_recruitment  t_noa_code;
g_relocation   t_noa_code;
g_Supervisory  t_noa_code;
g_apt_cd       t_gen_code;

-- =============================================================================
-- Build Rules
-- ============================================================================


PROCEDURE build_rules;

-- =============================================================================
-- get generic pay period number
-- ============================================================================
FUNCTION get_gen_pay_period_number (p_payroll_id             IN  NUMBER
                                   ,p_business_group_id      IN NUMBER
                                   ,p_effective_date         IN  DATE
                                   ,p_start_date             IN DATE
                                   ,p_end_date               IN DATE
                                    )
RETURN NUMBER;
-- =============================================================================
-- Populate_attr
-- ============================================================================
PROCEDURE populate_attr (p_person_id              NUMBER
                       ,p_assignment_id           NUMBER
                       ,p_business_group_id       NUMBER
                       ,p_effective_date          DATE
                       ,p_first_noa_cd            VARCHAR2
                       ,p_sec_noa_cd              VARCHAR2
                       ,p_request_id              NUMBER
                       ,p_notification_id         NUMBER
                       );

-- =============================================================================
-- NFC_Extract_Process:
-- =============================================================================
PROCEDURE NFC_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_business_group_id           IN     NUMBER
           ,p_benefit_action_id           IN     NUMBER
           ,p_ext_dfn_id                  IN     NUMBER
	   ,p_ext_jcl_id                  IN     NUMBER
           ,p_ext_dfn_typ_id              IN     VARCHAR2
           ,p_ext_dfn_data_typ            IN     VARCHAR2
           ,p_transmission_type           IN     VARCHAR2
           ,p_date_criteria               IN     VARCHAR2
	   ,p_dummy1			  IN     VARCHAR2
	   ,p_dummy2			  IN     VARCHAR2
	   ,p_dummy3			  IN     VARCHAR2
           ,p_from_date                   IN     VARCHAR2
           ,p_to_date                     IN     VARCHAR2
           ,p_agency_code                 IN     VARCHAR2
           ,p_personnel_office_id         IN     VARCHAR2
           ,p_transmission_indicator      IN     VARCHAR2
           ,p_signon_identification       IN     VARCHAR2
           ,p_user_id                     IN     VARCHAR2
	   ,p_dept_code                   IN     VARCHAR2
	   ,p_payroll_id                  IN     NUMBER
	   ,p_notify     		  IN     VARCHAR2
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL ) ;
-- =============================================================================
-- ~ Evaluate_Person_Inclusion: The Main extract criteria that would be used
-- ~ for the Personnel Action Records like RPA, Remarks, Awards and Address. This
-- ~ function would return (Y)es or (N)o.
-- =============================================================================
function Evaluate_Person_Inclusion
        (p_assignment_id        in per_all_assignments_f.assignment_id%type
        ,p_effective_date       in date
        ,p_business_group_id    in per_all_assignments_f.business_group_id%type
        ,p_warning_code         in out NoCopy varchar2
        ,p_warning_message      in out NoCopy varchar2
        ,p_error_code           in out NoCopy varchar2
        ,p_error_message        in out NoCopy varchar2
         )
         return varchar2;
-- =============================================================================
-- ~ Evaluate_Formula:
-- =============================================================================
function Evaluate_Formula
        (p_assignment_id     in number
        ,p_effective_date    in date
        ,p_business_group_id in number
        ,p_input_value       in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )
         return varchar2;
-- =============================================================================
-- ~ Extract_Exception:
-- =============================================================================
function Extract_Exception
        (p_assignment_id     in number
        ,p_business_group_id in number
        ,p_effective_date    in date
        ,p_msg_type          in out nocopy varchar2
        ,p_msg_code          in out nocopy varchar2
        ,p_msg_text          in out nocopy varchar2
         )
         return Varchar2;
-- =============================================================================
-- ~ Extract_Post_Process:
-- =============================================================================
function Extract_Post_Process
        (p_business_group_id  in number
         )
         return varchar2;

-- =============================================================================
-- ~ Get_NFC_ConcProg_Information: Common function to get the conc.prg parameters
-- =============================================================================
FUNCTION Get_NFC_ConcProg_Information
                     (p_header_type IN VARCHAR2
                     ,p_error_message OUT NOCOPY VARCHAR2) RETURN Varchar2;



--==============================================================================
--Gets payperiod number
---============================================================================
FUNCTION get_pay_period_number (p_person_id              IN  NUMBER
                               ,p_assignment_id          IN  NUMBER DEFAULT NULL
                               ,p_business_group_id      IN  NUMBER
                               ,p_effective_date         IN  DATE
                               ,p_position_id            OUT NOCOPY  NUMBER
                               ,p_start_date             OUT NOCOPY  DATE
                               ,p_end_date               OUT NOCOPY  DATE
                               )
RETURN NUMBER;
end GHR_US_NFC_Extracts;

 

/
