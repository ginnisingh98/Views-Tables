--------------------------------------------------------
--  DDL for Package BEN_CWB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_UTILS" AUTHID CURRENT_USER as
/* $Header: bencwbutils.pkh 120.6.12010000.3 2009/12/17 09:24:31 sgnanama ship $ */
FUNCTION get_task_access (
      p_hidden_cd            IN   VARCHAR2,
      p_task_access_cd       IN   VARCHAR2,
      p_plan_access_cd       IN   VARCHAR2,
      p_wksht_grp_cd         IN   VARCHAR2,
      p_population_cd        IN   VARCHAR2,
      p_status_cd            IN   VARCHAR2,
      p_dist_bdgt_iss_dt     IN   DATE,
      p_ss_update_start_dt   IN   DATE,
      p_ss_update_end_dt     IN   DATE,
      p_effective_dt         IN   DATE
   )
      RETURN VARCHAR2;
--
FUNCTION is_task_enabled
  	 (p_access_cd 		in varchar2,
	  p_population_cd 	in varchar2,
	  p_status_cd 		in varchar2,
	  p_dist_bdgt_iss_dt in date,
	  p_wksht_grp_cd	in varchar2)
      return varchar2;

FUNCTION get_manager_name(p_emp_per_in_ler_id in number,
	                  p_level in number) return varchar2;

FUNCTION get_profile(p_profile_name in varchar2)
return varchar2;

PROCEDURE  get_site_profile (
                  p_profile_1                in varchar2 default null,
                  p_value_1                  out nocopy varchar2);

PROCEDURE  get_resp_profile (
                  p_resp_id                  in number default null,
                  p_profile_1                in varchar2 default null,
                  p_value_1                  out nocopy varchar2);

PROCEDURE  get_user_profile (
                  p_user_id                  in number default null,
                  p_profile_1                in varchar2 default null,
                  p_profile_2                in varchar2 default null,
                  p_profile_3                in varchar2 default null,
                  p_profile_4                in varchar2 default null,
                  p_profile_5                in varchar2 default null,
                  p_profile_6                in varchar2 default null,
                  p_profile_7                in varchar2 default null,
                  p_profile_8                in varchar2 default null,
                  p_profile_9                in varchar2 default null,
                  p_profile_10               in varchar2 default null,
                  p_value_1                  out nocopy varchar2,
                  p_value_2                  out nocopy varchar2,
                  p_value_3                  out nocopy varchar2,
                  p_value_4                  out nocopy varchar2,
                  p_value_5                  out nocopy varchar2,
                  p_value_6                  out nocopy varchar2,
                  p_value_7                  out nocopy varchar2,
                  p_value_8                  out nocopy varchar2,
                  p_value_9                  out nocopy varchar2,
                  p_value_10                 out nocopy varchar2);

FUNCTION get_bdgt_pct_of_elig_sal_decs return number;
FUNCTION get_alloc_pct_of_elig_sal_decs return number;

FUNCTION get_eligibility(p_plan_status in varchar2,
                         p_opt1_status in varchar2,
                         p_opt2_status in varchar2,
                         p_opt3_status in varchar2,
                         p_opt4_status in varchar2
                        )
return varchar2;

FUNCTION is_person_switchable(p_person_id in number,
                              p_effective_date in date)
return varchar2;

function add_number_with_null_check(p_orig_val in number,
                                    p_new_val  in number) return number;

/* ---------------------------------------------------------------------
   Procedures/Functions Below are defined for Document Management
   Enhancements to support Printable Documents (PDF)
   BEGIN
   --------------------------------------------------------------------- */

g_person_rates_rec        ben_cwb_person_rates%RowType;
g_prior_person_rates_rec  ben_cwb_person_rates%RowType;
g_opt1_person_rates_rec   ben_cwb_person_rates%RowType;
g_opt2_person_rates_rec   ben_cwb_person_rates%RowType;
g_opt3_person_rates_rec   ben_cwb_person_rates%RowType;
g_opt4_person_rates_rec   ben_cwb_person_rates%RowType;

-- Added to support worksheet manager name
g_ws_mgr_full_name   ben_cwb_person_info.full_name%TYPE;
g_ws_mgr_brief_name  ben_cwb_person_info.brief_name%TYPE;
g_ws_mgr_custom_name ben_cwb_person_info.custom_name%TYPE;
--

CURSOR g_cursor_asgn_txn (c_assignment_id number, c_asg_updt_eff_date varchar2) is
select transaction_id assignment_id,
         attribute1  asg_updt_eff_Date,
         attribute5  job_id,
         attribute6  position_id,
         attribute7  grade_id,
         attribute8  people_group_id,
         attribute11 asgn_flex1, attribute12 asgn_flex2, attribute13 asgn_flex3, attribute14 asgn_flex4,
         attribute15 asgn_flex5, attribute16 asgn_flex6, attribute17 asgn_flex7, attribute18 asgn_flex8,
         attribute19 asgn_flex9, attribute20 asgn_flex10,attribute21 asgn_flex11,attribute22 asgn_flex12,
         attribute23 asgn_flex13,attribute24 asgn_flex14,attribute25 asgn_flex15,attribute26 asgn_flex16,
         attribute27 asgn_flex17,attribute28 asgn_flex18,attribute29 asgn_flex19,attribute30 asgn_flex20,
         attribute31 asgn_flex21,attribute32 asgn_flex22,attribute33 asgn_flex23,attribute34 asgn_flex24,
         attribute35 asgn_flex25,attribute36 asgn_flex26,attribute37 asgn_flex27,attribute38 asgn_flex28,
         attribute39 asgn_flex29,attribute40 asgn_flex30
From  ben_transaction
where transaction_id = c_assignment_id
and   transaction_type = 'CWBASG'||c_asg_updt_eff_date;
--
g_asgn_txn_rec            g_cursor_asgn_txn%rowType;
--
Function get_option1_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;


Function get_option1_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;


Function get_option1_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;


Function get_option1_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option1_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;


Function get_option2_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option2_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;


Function get_option2_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;


Function get_option2_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option2_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;


Function get_option3_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;



Function get_option3_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;


Function get_option3_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;


Function get_option3_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option3_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_name(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;



Function get_option4_rate_ws_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_unit(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;


Function get_option4_elg_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_elg_per_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_rate_reco_amt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_rate_oth_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_rate_sta_sal(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_rate_tot_comp(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;


Function get_option4_rate_misc1(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_rate_misc2(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

Function get_option4_rate_misc3(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

FUNCTION get_plan_rate_misc3 (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number ;

FUNCTION get_plan_rate_misc2 (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;

FUNCTION get_plan_rate_misc1 (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;
FUNCTION get_plan_rate_total_comp (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number ;

FUNCTION get_plan_rate_stat_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;

FUNCTION get_plan_rate_other_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;


FUNCTION get_plan_rate_rec_amt (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;
FUNCTION get_plan_percent_elig_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;

FUNCTION get_plan_rate_elig_sal (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;
FUNCTION get_plan_rate_ws_amt (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return number;
FUNCTION get_pay_rate_basis (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return Varchar2 ;

FUNCTION get_pay_rate_change_percent (
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

FUNCTION get_pay_rate_change_amount (
      p_group_plan_id in number,
      p_lf_evt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return number;

FUNCTION get_pay_rate (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2,
      p_new_or_prior  in varchar2) return number;

FUNCTION get_pay_rate_change_date (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2,
      p_new_or_prior  in varchar2) return varchar2;

function get_new_perf_rating (
    p_assignment_id     in number,
    p_perf_revw_strt_dt in date,
    p_emp_interview_typ_cd in varchar2 ) return varchar2 ;


FUNCTION get_new_asgn_flex(
    p_assignment_id     in number,
    p_asg_updt_eff_date in date,
    p_asg_flex_num      in number
    ) return varchar2 ;

FUNCTION get_new_people_group(
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2;

FUNCTION get_new_grade (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2;

FUNCTION get_new_position (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2;

FUNCTION get_new_job (
    p_assignment_id     in number,
    p_asg_updt_eff_date in date) return varchar2;
--
FUNCTION get_group_short_name (
                 p_plan_id                in number ,
                 p_lf_evt_ocrd_dt         in date   ) return varchar2;



FUNCTION get_ws_mgr_full_name(p_group_per_in_ler_id in number) return varchar2;
FUNCTION get_ws_mgr_brief_name(p_group_per_in_ler_id in number) return varchar2;
FUNCTION get_ws_mgr_custom_name(p_group_per_in_ler_id in number) return varchar2;

Function get_option1_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option2_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option3_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option4_currency(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

FUNCTION get_plan_rate_start_dt (
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2 ) return varchar2;

Function get_option1_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option2_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option3_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_option4_rate_start_dt(
      p_group_plan_id in number,
      p_lf_evnt_ocrd_dt in Date,
      p_oipl_id        in number,
      p_group_per_in_ler_id in number,
      p_pl_id            in number,
      p_ws_sub_acty_typ_cd in varchar2) return varchar2;

Function get_custom_segment_message(
    p_custom_seg_text in varchar2 ) return varchar2;

--
/* ---------------------------------------------------------------------
   END -- Changes for Printable document
   --------------------------------------------------------------------- */
END ben_cwb_utils;

/
