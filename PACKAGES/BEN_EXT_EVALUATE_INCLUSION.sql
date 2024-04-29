--------------------------------------------------------
--  DDL for Package BEN_EXT_EVALUATE_INCLUSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_EVALUATE_INCLUSION" AUTHID CURRENT_USER as
/* $Header: benxincl.pkh 120.3 2005/12/23 13:47:05 tjesumic noship $ */
--
-- Cache area for each inclusion criteria for whether to check
-- the criteria for this extract.
--
  g_person_id_incl_rqd         varchar2(1);
  g_postal_code_incl_rqd       varchar2(1);
  g_org_id_incl_rqd            varchar2(1);
  g_loc_id_incl_rqd            varchar2(1);
  g_gre_incl_rqd               varchar2(1);
  g_state_incl_rqd             varchar2(1);
  g_bnft_grp_incl_rqd          varchar2(1);
  g_ee_status_incl_rqd         varchar2(1);
  g_payroll_id_incl_rqd        varchar2(1);
  g_payroll_rl_incl_rqd        varchar2(1);
  g_payroll_last_date_incl_rqd varchar2(1);
  g_enrt_plan_incl_rqd         varchar2(1);
  g_enrt_rg_plan_incl_rqd      varchar2(1);
  g_enrt_sspndd_incl_rqd       varchar2(1);
  g_enrt_cvg_strt_dt_incl_rqd  varchar2(1);
  g_enrt_cvg_drng_perd_incl_rqd varchar2(1);
  g_enrt_stat_incl_rqd         varchar2(1);
  g_enrt_mthd_incl_rqd         varchar2(1);
  g_enrt_pgm_incl_rqd          varchar2(1);
  g_enrt_opt_incl_rqd          varchar2(1);
  g_enrt_pl_typ_incl_rqd       varchar2(1);
  g_enrt_last_upd_dt_incl_rqd  varchar2(1);
  g_enrt_ler_name_incl_rqd     varchar2(1);
  g_enrt_ler_stat_incl_rqd     varchar2(1);
  g_enrt_ler_ocrd_dt_incl_rqd  varchar2(1);
  g_enrt_ler_ntfn_dt_incl_rqd  varchar2(1);
  g_enrt_rltn_incl_rqd         varchar2(1);
  g_enrt_dpnt_rltn_incl_rqd    varchar2(1);
  g_elct_plan_incl_rqd         varchar2(1);
  g_elct_rg_plan_incl_rqd      varchar2(1);
  g_elct_enrt_strt_dt_incl_rqd  varchar2(1);
  g_elct_yrprd_incl_rqd        varchar2(1);
  g_elct_pgm_incl_rqd          varchar2(1);
  g_elct_opt_incl_rqd          varchar2(1);
  g_elct_pl_typ_incl_rqd       varchar2(1);
  g_elct_last_upd_dt_incl_rqd  varchar2(1);
  g_elct_ler_name_incl_rqd     varchar2(1);
  g_elct_ler_stat_incl_rqd     varchar2(1);
  g_elct_ler_ocrd_dt_incl_rqd  varchar2(1);
  g_elct_ler_ntfn_dt_incl_rqd  varchar2(1);
  g_elct_rltn_incl_rqd         varchar2(1);
  g_ele_input_incl_rqd         varchar2(1);
  g_person_rule_incl_rqd       varchar2(1);
  g_per_ler_incl_rqd           varchar2(1);
  g_person_type_incl_rqd       varchar2(1);
  g_chg_evt_incl_rqd varchar2(1);
  g_chg_pay_evt_incl_rqd varchar2(1);
  g_chg_eff_dt_incl_rqd varchar2(1);
  g_chg_actl_dt_incl_rqd varchar2(1);
  g_chg_login_incl_rqd varchar2(1);
  g_cm_typ_incl_rqd varchar2(1);
  g_cm_last_upd_dt_incl_rqd varchar2(1);
  g_cm_pr_last_upd_dt_incl_rqd varchar2(1);
  g_cm_sent_dt_incl_rqd varchar2(1);
  g_cm_to_be_sent_dt_incl_rqd varchar2(1);
  g_cmbn_incl_rqd              varchar2(1);
  g_actn_name_incl_rqd  varchar2(1);
  g_actn_item_rltn_incl_rqd   varchar2(1);
  g_prem_last_updt_dt_rqd     varchar2(1);
  g_prem_month_year_rqd       varchar2(1);
  g_asg_to_use_rqd            varchar2(1);
  g_subhead_rule_rqd            varchar2(1);
  g_subhead_pos_rqd            varchar2(1);
  g_subhead_job_rqd            varchar2(1);
  g_subhead_loc_rqd            varchar2(1);
  g_subhead_pay_rqd            varchar2(1);
  g_subhead_org_rqd            varchar2(1);
  g_subhead_bg_rqd            varchar2(1);
  g_subhead_grd_rqd          varchar2(1);

 -- CWB

  g_cwb_pl_prd_rqd            varchar2(1);

--
-- Flags for checking whether the criterion is inclusion or exclusion one
--
  g_person_id_excld_flag       varchar2(1);
  g_postal_code_excld_flag     varchar2(1);
  g_org_id_excld_flag          varchar2(1);
  g_loc_id_excld_flag          varchar2(1);
  g_gre_excld_flag             varchar2(1);
  g_state_excld_flag           varchar2(1);
  g_bnft_grp_excld_flag        varchar2(1);
  g_ee_status_excld_flag       varchar2(1);
  g_payroll_id_excld_flag      varchar2(1);
  g_payroll_rl_excld_flag      varchar2(1);
  g_payroll_last_Date_excld_flag  varchar2(1);
  g_enrt_plan_excld_flag       varchar2(1);
  g_enrt_rg_plan_excld_flag    varchar2(1);
  g_enrt_sspndd_excld_flag     varchar2(1);
  g_enrt_cvg_strt_dt_excld_flag varchar2(1);
  g_enrt_cvg_drng_prd_excld_flag varchar2(1);
  g_enrt_stat_excld_flag       varchar2(1);
  g_enrt_mthd_excld_flag       varchar2(1);
  g_enrt_pgm_excld_flag        varchar2(1);
  g_enrt_opt_excld_flag        varchar2(1);
  g_enrt_pl_typ_excld_flag     varchar2(1);
  g_enrt_last_upd_dt_excld_flag varchar2(1);
  g_enrt_ler_name_excld_flag   varchar2(1);
  g_enrt_ler_stat_excld_flag   varchar2(1);
  g_enrt_ler_ocrd_dt_excld_flag varchar2(1);
  g_enrt_ler_ntfn_dt_excld_flag varchar2(1);
  g_enrt_rltn_excld_flag       varchar2(1);
  g_enrt_dpnt_rltn_excld_flag  varchar2(1);
  g_elct_plan_excld_flag         varchar2(1);
  g_elct_rg_plan_excld_flag      varchar2(1);
  g_elct_enrt_strt_dt_excld_flag  varchar2(1);
  g_elct_yrprd_excld_flag        varchar2(1);
  g_elct_pgm_excld_flag          varchar2(1);
  g_elct_opt_excld_flag          varchar2(1);
  g_elct_pl_typ_excld_flag       varchar2(1);
  g_elct_last_upd_dt_excld_flag  varchar2(1);
  g_elct_ler_name_excld_flag     varchar2(1);
  g_elct_ler_stat_excld_flag     varchar2(1);
  g_elct_ler_ocrd_dt_excld_flag  varchar2(1);
  g_elct_ler_ntfn_dt_excld_flag  varchar2(1);
  g_elct_rltn_excld_flag         varchar2(1);
  g_ele_input_excld_flag       varchar2(1);
  g_person_rule_excld_flag     varchar2(1);
  g_per_ler_excld_flag         varchar2(1);
  g_person_type_excld_flag     varchar2(1);
  g_chg_evt_excld_flag varchar2(1);
  g_chg_pay_evt_excld_flag varchar2(1);
  g_chg_eff_dt_excld_flag varchar2(1);
  g_chg_actl_dt_excld_flag varchar2(1);
  g_chg_login_excld_flag varchar2(1);
  g_cm_typ_excld_flag varchar2(1);
  g_cm_last_upd_dt_excld_flag varchar2(1);
  g_cm_pr_last_upd_dt_excld_flag varchar2(1);
  g_cm_sent_dt_excld_flag varchar2(1);
  g_cm_to_be_sent_dt_excld_flag varchar2(1);
  g_actn_name_excld_flag varchar2(1);
  g_actn_item_rltn_excld_flag varchar2(1);
  g_prem_last_updt_dt_excld_flag varchar2(1) ;
  g_prem_month_year_excld_flag  varchar2(1) ;
  g_subhead_rule_excld_flag     varchar2(1);
  g_subhead_pos_excld_flag            varchar2(1);
  g_subhead_job_excld_flag            varchar2(1);
  g_subhead_loc_excld_flag            varchar2(1);
  g_subhead_pay_excld_flag            varchar2(1);
  g_subhead_org_excld_flag            varchar2(1);
  g_subhead_bg_excld_flag            varchar2(1);
  g_subhead_grd_excld_flag            varchar2(1);
  -- cwb
  g_cwb_pl_prd_excld_flag            varchar2(1);
-- Timecard Globals

  g_tc_status_excld_flag   VARCHAR2(1);
  g_tc_deleted_excld_flag  VARCHAR2(1);
  g_project_id_excld_flag  VARCHAR2(1);
  g_task_id_excld_flag     VARCHAR2(1);
  g_exp_typ_id_excld_flag  VARCHAR2(1);
  g_po_num_excld_flag      VARCHAR2(1);
  g_element_type_id_excld_flag      VARCHAR2(1);

  g_tc_status_incl_rqd   VARCHAR2(1);
  g_tc_deleted_incl_rqd  VARCHAR2(1);
  g_project_id_incl_rqd  VARCHAR2(1);
  g_task_id_incl_rqd     VARCHAR2(1);
  g_exp_typ_id_incl_rqd  VARCHAR2(1);
  g_po_num_incl_rqd      VARCHAR2(1);
  g_element_type_id_incl_rqd      VARCHAR2(1);

--
-- Cache area for each inclusion criteria for storing the criteria
-- values. For range type inclusion criteria, e.g. postal code, there
-- will be two cache area for storing value1 and value2.
--
  Type num_list is Table of number
  Index by binary_integer;
--
  Type char_list is Table of ben_ext_rslt_Dtl.val_01%type
  Index by binary_integer;
--
  g_person_id_list             num_list;
--
  g_postal_code_list1          char_list;
  g_postal_code_list2          char_list;
--
  g_org_id_list                num_list;
--
  g_loc_id_list                num_list;
--
  g_gre_list                   char_list;
--
  g_state_list                 char_list;
--
  g_bnft_grp_list              num_list;
--
  g_ee_status_list             num_list;
--
  g_payroll_id_list            num_list;
--
  g_payroll_rl_list            num_list;
--
  g_enrt_plan_list             num_list;
--
  g_enrt_rg_plan_list          num_list;
--
  g_enrt_sspndd_list           char_list;
--
  g_enrt_cvg_strt_dt_list1     char_list;
  g_enrt_cvg_strt_dt_list2     char_list;
--
  g_enrt_cvg_drng_perd_list1   char_list;
  g_enrt_cvg_drng_perd_list2   char_list;
--
  g_enrt_stat_list             char_list;
--
  g_enrt_mthd_list             char_list;
--
  g_enrt_pgm_list              num_list;
--
  g_enrt_pl_typ_list           num_list;
--
  g_enrt_opt_list              num_list;
--
  g_enrt_last_upd_dt_list1     char_list;
  g_enrt_last_upd_dt_list2     char_list;
--
  g_enrt_ler_name_list         num_list;
--
  g_enrt_ler_stat_list         char_list;
--
  g_enrt_ler_ocrd_dt_list1     char_list;
  g_enrt_ler_ocrd_dt_list2     char_list;
--
  g_enrt_ler_ntfn_dt_list1     char_list;
  g_enrt_ler_ntfn_dt_list2     char_list;
--
  g_enrt_rltn_list             char_list;
--
  g_actn_item_rltn_list        char_list;
--
  g_enrt_dpnt_rltn_list        char_list;
--
  g_actn_name_list           num_list;
--
  g_elct_plan_list         num_list;
--
  g_elct_rg_plan_list      num_list;
--
  g_elct_enrt_strt_dt_list1  char_list;
  g_elct_enrt_strt_dt_list2  char_list;
--
  g_elct_yrprd_list        num_list;
--
  g_elct_pgm_list          num_list;
--
  g_elct_pl_typ_list       num_list;
--
  g_elct_opt_list          num_list;
--
  g_elct_last_upd_dt_list1  char_list;
  g_elct_last_upd_dt_list2  char_list;
--
  g_elct_ler_name_list     num_list;
--
  g_elct_ler_stat_list     char_list;
--
  g_elct_ler_ocrd_dt_list1  char_list;
  g_elct_ler_ocrd_dt_list2  char_list;
--
  g_elct_ler_ntfn_dt_list1  char_list;
  g_elct_ler_ntfn_dt_list2  char_list;
--
  g_elct_rltn_list         char_list;
--
  g_ele_input_list            num_list;
  g_ele_type_list             num_list;
--
  g_person_rule_list           num_list;
--
  g_per_ler_list               num_list;
--
  g_person_type_list           num_list;
--
  g_chg_evt_list               char_list;
--
  g_chg_pay_evt_list           char_list;
--
  g_chg_eff_dt_list1           char_list;
  g_chg_eff_dt_list2           char_list;
--
  g_chg_actl_dt_list1          char_list;
  g_chg_actl_dt_list2          char_list;
--
  g_chg_login_list             num_list;
--
  g_cm_typ_list                num_list;
--
  g_cm_last_upd_dt_list1       char_list;
  g_cm_last_upd_dt_list2       char_list;
--
  g_cm_pr_last_upd_dt_list1    char_list;
  g_cm_pr_last_upd_dt_list2    char_list;
--
  g_cm_sent_dt_list1           char_list;
  g_cm_sent_dt_list2           char_list;
--
  g_cm_to_be_sent_dt_list1     char_list;
  g_cm_to_be_sent_dt_list2     char_list;
--
  g_prem_last_upd_dt_list1     char_list;
  g_prem_last_upd_dt_list2     char_list;
--
  g_prem_month_year_dt_list1   char_list;
  g_prem_month_year_dt_list2   char_list;
--
 g_payroll_last_dt_list1       char_list;
 g_payroll_last_dt_list2       char_list;
--
 g_asg_to_use_list             char_list;
---
 g_subhead_rule_list           num_list;
 g_subhead_pos_list           num_list;
 g_subhead_job_list           num_list;
 g_subhead_loc_list           num_list;
 g_subhead_pay_list           num_list;
 g_subhead_org_list           num_list;
 g_subhead_bg_list           num_list;
 g_subhead_grd_list           num_list;
---
 g_cwb_pl_list               num_list;
 g_cwb_prd_list              num_list;

  g_crit_typ_list              char_list;
  g_crit_val_list              num_list;
  g_oper_list                  char_list;
  g_val1_list                  char_list;
  g_val2_list                  char_list;

  g_tc_status_list   char_list;
  g_tc_deleted_list  char_list;
  g_project_id_list  char_list;
  g_task_id_list     char_list;
  g_exp_typ_id_list  char_list;
  g_po_num_list      char_list;
  g_element_type_list char_list;

--
  g_package     varchar2(33) := '  ben_ext_evaluate_inclusion.';
--
  g_include     exception;
--
  g_not_include exception;
--
-- The following procedure sets the cache area.
--
  Procedure Determine_Incl_Crit_To_Check
  (p_ext_crit_prfl_id   in ben_ext_crit_prfl.ext_crit_prfl_id%type);
--
-- The following procedure evaluates person inclusion criteria
--
  Procedure Evaluate_Person_Incl
  (p_person_id   in  per_all_people_f.person_id%type,
   p_postal_code in per_addresses.postal_code%type default null,
   p_org_id  in per_all_assignments_f.organization_id%type default null,
   p_loc_id  in per_all_assignments_f.location_id%type default null,
   p_gre     in hr_soft_coding_keyflex.segment1%type default null,
   p_state   in per_addresses.region_2%type default null,
   p_bnft_grp in per_all_people_f.benefit_group_id%type default null,
   p_ee_status in per_all_assignments_f.assignment_status_type_id%type default null,
   p_payroll_id in per_all_assignments_f.payroll_id%type default null,
   p_chg_evt_cd in varchar2 default null,
   p_chg_evt_source in varchar2 default null,
   p_effective_date  in date,
   --RCHASE
   p_eff_date  in date default null,
   --End RCHASE
   p_actl_date       in date,
   p_include out nocopy varchar2);
--
-- The following procedure evaluates plan inclusion criteria
--
  Procedure Evaluate_Benefit_Incl
(p_pl_id            in ben_prtt_enrt_rslt_f.pl_id%type default null,
 p_sspndd_flag      in ben_prtt_enrt_rslt_f.sspndd_flag%type default null,
 p_enrt_cvg_strt_dt in ben_prtt_enrt_rslt_f.enrt_cvg_strt_dt%type default null,
 p_enrt_cvg_thru_dt in ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%type default null,
 p_prtt_enrt_rslt_stat_cd in ben_prtt_enrt_rslt_f.prtt_enrt_rslt_stat_cd%type default null,
 p_enrt_mthd_cd     in ben_prtt_enrt_rslt_f.enrt_mthd_cd%type default null,
 p_pgm_id           in ben_prtt_enrt_rslt_f.pgm_id%type default null,
 p_pl_typ_id        in ben_prtt_enrt_rslt_f.pl_typ_id%type default null,
 p_opt_id           in ben_opt_f.opt_id%type default null,
 p_last_update_date in ben_prtt_enrt_rslt_f.last_update_date%type default null,
 p_ler_id    in ben_per_in_ler.ler_id%type default null,
 p_ntfn_dt      in ben_per_in_ler.ntfn_dt%type default null,
 p_lf_evt_ocrd_dt   in ben_per_in_ler.lf_evt_ocrd_dt%type default null,
 p_per_in_ler_stat_cd in ben_per_in_ler.per_in_ler_stat_cd%type default null,
 p_per_in_ler_id    in ben_per_in_ler.per_in_ler_id%type default null,
 p_prtt_enrt_rslt_id in ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type default null,
 p_effective_date   in date default null,
 p_dpnt_id          in number default null ,
 p_include          out nocopy varchar2);
--
Procedure evaluate_eligibility_incl
(p_elct_pl_id         in ben_elig_per_elctbl_chc.pl_id%type default null,
 p_elct_enrt_strt_dt  in ben_elig_per_elctbl_chc.enrt_cvg_strt_dt%type default null,
 p_elct_yrprd_id      in ben_elig_per_elctbl_chc.yr_perd_id%type default null,
 p_elct_pgm_id        in ben_elig_per_elctbl_chc.pgm_id%type default null,
 p_elct_pl_typ_id     in ben_elig_per_elctbl_chc.pl_typ_id%type default null,
 p_elct_opt_id        in ben_opt_f.opt_id%type default null,
 p_elct_last_upd_dt   in ben_elig_per_elctbl_chc.last_update_date%type default null,
 p_elct_per_in_ler_id in ben_per_in_ler.per_in_ler_id%type default null,
 p_elct_ler_id        in ben_per_in_ler.ler_id%type default null,
 p_elct_per_in_ler_stat_cd in ben_per_in_ler.per_in_ler_stat_cd%type default null,
 p_elct_lf_evt_ocrd_dt in ben_per_in_ler.lf_evt_ocrd_dt%type default null,
 p_elct_ntfn_dt       in ben_per_in_ler.ntfn_dt%type default null,
 p_prtt_enrt_rslt_id  in ben_elig_per_elctbl_chc.prtt_enrt_rslt_id%type default null,
 p_effective_date     in date default null,
 p_include            out nocopy varchar2);
--
  Procedure evaluate_change_log_incl
  (p_chg_evt_cd        in ben_ext_chg_evt_log.chg_evt_cd%type,
   p_chg_evt_source    in ben_ext_chg_evt_log.chg_evt_cd%type,
   p_chg_eff_dt        in ben_ext_chg_evt_log.chg_eff_dt%type,
   p_chg_actl_dt       in ben_ext_chg_evt_log.chg_actl_dt%type,
   p_last_update_login in ben_ext_chg_evt_log.last_update_login%type,
   p_effective_date    in date default null,
   p_include           out nocopy varchar2);

--- procedure to evaluate extract premium
  Procedure evaluate_prem_incl
  (p_last_update_date in ben_prtt_prem_by_mo_f.last_update_date%type,
   p_mo_num           in ben_prtt_prem_by_mo_f.mo_num%type default null ,
   p_yr_num           in ben_prtt_prem_by_mo_f.yr_num%type default null,
   p_effective_date   in date default null,
   p_include          out nocopy varchar2) ;



--
  Procedure evaluate_comm_incl
  (p_cm_typ_id        in ben_per_cm_f.cm_typ_id%type,
   p_last_update_date in ben_per_cm_f.last_update_date%type,
   p_pvdd_last_update_date in ben_per_cm_prvdd_f.last_update_date%type,
   p_sent_dt          in ben_per_cm_prvdd_f.sent_dt%type,
   p_to_be_sent_dt    in ben_per_cm_prvdd_f.to_be_sent_dt%type,
   p_effective_date   in date default null,
   p_include          out nocopy varchar2);
--

  Procedure Evaluate_Elm_Entry_Incl
  (p_processing_type  in pay_element_types_f.processing_type%type, --future use
   p_input_value_id   in pay_input_values_f.input_value_id%type,
   p_business_group_id in number ,
   p_pay_period_date  in date  default null ,
   p_effective_date   in date  default null,
   p_person_id        in number  default null,
   p_source_id        in number  default null,
   p_source_Type      in varchar2  default null,
   p_element_type_id  in number  default null,
   p_element_entry_id in number  default null,
   p_include          out nocopy varchar2
   ) ;

--
  Procedure Evaluate_Action_Item_Incl
  (p_actn_typ_id in ben_prtt_enrt_actn_f.actn_typ_id%type,
   p_prtt_enrt_actn_id   in ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type,
   p_include          out nocopy varchar2);


  Procedure Evaluate_subhead_incl
  (p_organization_id     in number default null  ,
   p_position_id         in number default null  ,
   p_job_id              in number default null  ,
   p_payroll_id          in number default null  ,
   p_location_id         in number default null  ,
   p_grade_id            in number default null  ,
   p_business_group_id  in number               ,
   p_include          out nocopy varchar2,
   p_effective_date     in date ,
   p_eff_date           in date default null   ,
   p_actl_date          in date default null
  );


-- cwb

  Procedure Evaluate_cwb_incl
  (p_group_pl_id      in number  ,
   p_lf_evt_ocrd_dt   in date    ,
   p_include          out nocopy varchar2 ,
   p_effective_date     in date  ) ;


-----------------------------------------------------------------------------
---------------------------< evaluate_timecard_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates timecard inclusion criteria
--
Procedure evaluate_timecard_incl
(p_otl_lvl             IN VARCHAR2
,p_tc_status           IN VARCHAR2 DEFAULT NULL
,p_tc_deleted          IN VARCHAR2 DEFAULT NULL
,p_project_id          IN VARCHAR2 DEFAULT NULL
,p_task_id             IN VARCHAR2 DEFAULT NULL
,p_exp_typ_id          IN VARCHAR2 DEFAULT NULL
,p_element_type_id     IN VARCHAR2 DEFAULT NULL
,p_po_num              IN VARCHAR2 DEFAULT NULL
,p_include          out nocopy varchar2);

end ; -- ben_ext_evaluate_inclusion

 

/
