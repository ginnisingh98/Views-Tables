--------------------------------------------------------
--  DDL for Package Body BEN_EXT_EVALUATE_INCLUSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_EVALUATE_INCLUSION" as
/* $Header: benxincl.pkb 120.9.12010000.2 2008/08/05 14:58:12 ubhat ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_debug boolean := hr_utility.debug_enabled;
--
-----------------------------------------------------------------------------
-------------------------< initailize_all_cache_area >-----------------------
-----------------------------------------------------------------------------
--
-- The following procedure initialize all the cache area.
--
Procedure Initialize_All_Cache_Area is
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'initialize_all_cache_area';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
  g_person_id_incl_rqd := 'N';
  g_postal_code_incl_rqd := 'N';
  g_org_id_incl_rqd := 'N';
  g_loc_id_incl_rqd := 'N';
  g_gre_incl_rqd := 'N';
  g_state_incl_rqd := 'N';
  g_bnft_grp_incl_rqd := 'N';
  g_ee_status_incl_rqd := 'N';
  g_payroll_id_incl_rqd := 'N';
  g_payroll_rl_incl_rqd := 'N';
  g_payroll_last_date_excld_flag := 'N' ;
  g_enrt_plan_incl_rqd := 'N';
  g_enrt_opt_incl_rqd := 'N';
  g_enrt_rg_plan_incl_rqd := 'N';
  g_enrt_sspndd_incl_rqd := 'N';
  g_enrt_cvg_strt_dt_incl_rqd := 'N';
  g_enrt_cvg_drng_perd_incl_rqd := 'N';
  g_enrt_stat_incl_rqd := 'N';
  g_enrt_mthd_incl_rqd := 'N';
  g_enrt_pgm_incl_rqd := 'N';
  g_enrt_pl_typ_incl_rqd := 'N';
  g_enrt_last_upd_dt_incl_rqd := 'N';
  g_enrt_ler_name_incl_rqd := 'N';
  g_enrt_ler_stat_incl_rqd := 'N';
  g_enrt_ler_ocrd_dt_incl_rqd := 'N';
  g_enrt_ler_ntfn_dt_incl_rqd := 'N';
  g_enrt_rltn_incl_rqd := 'N';  --currently known as misc
  g_enrt_dpnt_rltn_incl_rqd := 'N';  --dependent enrolled on the day
  g_elct_plan_incl_rqd         := 'N';
  g_elct_opt_incl_rqd         := 'N';
  g_elct_rg_plan_incl_rqd      := 'N';
  g_elct_enrt_strt_dt_incl_rqd  := 'N';
  g_elct_yrprd_incl_rqd        := 'N';
  g_elct_pgm_incl_rqd          := 'N';
  g_elct_pl_typ_incl_rqd       := 'N';
  g_elct_last_upd_dt_incl_rqd  := 'N';
  g_elct_ler_name_incl_rqd     := 'N';
  g_elct_ler_stat_incl_rqd     := 'N';
  g_elct_ler_ocrd_dt_incl_rqd  := 'N';
  g_elct_ler_ntfn_dt_incl_rqd  := 'N';
  g_elct_rltn_incl_rqd         := 'N';
 -- g_per_plan_incl_rqd := 'N';  --tvh remove
 -- g_part_type_incl_rqd := 'N';
  g_ele_input_incl_rqd := 'N';
  g_person_rule_incl_rqd := 'N';
  g_per_ler_incl_rqd := 'N';
  g_person_type_incl_rqd := 'N';
  g_chg_evt_incl_rqd := 'N';
  g_chg_pay_evt_incl_rqd := 'N';
  g_chg_eff_dt_incl_rqd := 'N';
  g_chg_actl_dt_incl_rqd := 'N';
  g_chg_login_incl_rqd := 'N';
  g_chg_login_incl_rqd := 'N';
  g_cm_typ_incl_rqd := 'N';
  g_cm_typ_incl_rqd := 'N';
  g_cm_last_upd_dt_incl_rqd := 'N';
  g_cm_pr_last_upd_dt_incl_rqd := 'N';
  g_cm_sent_dt_incl_rqd := 'N';
  g_cm_to_be_sent_dt_incl_rqd := 'N';
  g_cmbn_incl_rqd := 'N';
  g_actn_name_incl_rqd := 'N';
  g_actn_item_rltn_incl_rqd := 'N';
  g_prem_last_updt_dt_rqd  := 'N' ;
  g_prem_month_year_rqd    := 'N' ;
  g_asg_to_use_rqd         := 'N' ;
  g_subhead_rule_rqd       := 'N' ;
  g_subhead_pos_rqd        := 'N' ;
  g_subhead_job_rqd        := 'N' ;
  g_subhead_loc_rqd        := 'N' ;
  g_subhead_pay_rqd        := 'N' ;
  g_subhead_org_rqd        := 'N' ;
  g_subhead_bg_rqd        := 'N' ;
  g_subhead_grd_rqd        := 'N' ;

--  cwb
   g_cwb_pl_prd_rqd := 'N' ;
--
  g_person_id_excld_flag := 'N';
  g_postal_code_excld_flag := 'N';
  g_org_id_excld_flag := 'N';
  g_loc_id_excld_flag := 'N';
  g_gre_excld_flag := 'N';
  g_state_excld_flag := 'N';
  g_bnft_grp_excld_flag := 'N';
  g_ee_status_excld_flag := 'N';
  g_payroll_id_excld_flag := 'N';
  g_payroll_rl_excld_flag := 'N';
  g_payroll_last_Date_excld_flag  := 'N' ;
  g_enrt_plan_excld_flag := 'N';
  g_enrt_rg_plan_excld_flag := 'N';
  g_enrt_sspndd_excld_flag := 'N';
  g_enrt_cvg_strt_dt_excld_flag := 'N';
  g_enrt_cvg_drng_prd_excld_flag := 'N';
  g_enrt_stat_excld_flag := 'N';
  g_enrt_mthd_excld_flag := 'N';
  g_enrt_pgm_excld_flag := 'N';
  g_enrt_pl_typ_excld_flag := 'N';
  g_enrt_last_upd_dt_excld_flag := 'N';
  g_enrt_ler_name_excld_flag := 'N';
  g_enrt_ler_stat_excld_flag := 'N';
  g_enrt_ler_ocrd_dt_excld_flag := 'N';
  g_enrt_ler_ntfn_dt_excld_flag := 'N';
  g_enrt_rltn_excld_flag := 'N';  --currently known as misc
  g_enrt_dpnt_rltn_excld_flag := 'N';
  g_elct_plan_excld_flag         := 'N';
  g_elct_rg_plan_excld_flag      := 'N';
  g_elct_enrt_strt_dt_excld_flag  := 'N';
  g_elct_yrprd_excld_flag        := 'N';
  g_elct_pgm_excld_flag          := 'N';
  g_elct_pl_typ_excld_flag       := 'N';
  g_elct_last_upd_dt_excld_flag  := 'N';
  g_elct_ler_name_excld_flag     := 'N';
  g_elct_ler_stat_excld_flag     := 'N';
  g_elct_ler_ocrd_dt_excld_flag  := 'N';
  g_elct_ler_ntfn_dt_excld_flag  := 'N';
  g_elct_rltn_excld_flag         := 'N';
 -- g_per_plan_excld_flag := 'N'; -- tvh remove
 -- g_part_type_excld_flag := 'N';
  g_ele_input_excld_flag := 'N';
  g_person_rule_excld_flag := 'N';
  g_per_ler_excld_flag := 'N';
  g_person_type_excld_flag := 'N';
  g_chg_evt_excld_flag := 'N';
  g_chg_pay_evt_excld_flag := 'N';
  g_chg_eff_dt_excld_flag := 'N';
  g_chg_actl_dt_excld_flag := 'N';
  g_chg_login_excld_flag := 'N';
  g_chg_login_excld_flag := 'N';
  g_cm_typ_excld_flag := 'N';
  g_cm_typ_excld_flag := 'N';
  g_cm_last_upd_dt_excld_flag := 'N';
  g_cm_pr_last_upd_dt_excld_flag := 'N';
  g_cm_sent_dt_excld_flag := 'N';
  g_cm_to_be_sent_dt_excld_flag := 'N';
  g_actn_name_excld_flag := 'N';
  g_actn_item_rltn_excld_flag := 'N';
  g_prem_last_updt_dt_excld_flag := 'N' ;
  g_prem_month_year_excld_flag   := 'N' ;
  g_subhead_rule_excld_flag      := 'N' ;
  g_subhead_pos_excld_flag        := 'N' ;
  g_subhead_job_excld_flag        := 'N' ;
  g_subhead_loc_excld_flag        := 'N' ;
  g_subhead_pay_excld_flag        := 'N' ;
  g_subhead_org_excld_flag        := 'N' ;
  g_subhead_bg_excld_flag        := 'N' ;
  g_subhead_grd_excld_flag        := 'N' ;
--  cwb
   g_cwb_pl_prd_excld_flag  := 'N' ;

-- Timecard Inclusion Globals

  g_tc_status_excld_flag   := 'N';
  g_tc_deleted_excld_flag  := 'N';
  g_project_id_excld_flag  := 'N';
  g_task_id_excld_flag     := 'N';
  g_exp_typ_id_excld_flag  := 'N';
  g_po_num_excld_flag      := 'N';

  g_tc_status_incl_rqd   := 'N';
  g_tc_deleted_incl_rqd  := 'N';
  g_project_id_incl_rqd  := 'N';
  g_task_id_incl_rqd     := 'N';
  g_exp_typ_id_incl_rqd  := 'N';
  g_po_num_incl_rqd      := 'N';

--
-- Initialize all the lists - May, 99
--
  for i in 1..g_person_id_list.count loop
    if g_person_id_list.exists(i) then
      g_person_id_list(i) := null;
    end if;
  end loop;
  for i in 1..g_postal_code_list1.count loop
    if g_postal_code_list1.exists(i) then
      g_postal_code_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_postal_code_list2.count loop
    if g_postal_code_list2.exists(i) then
      g_postal_code_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_org_id_list.count loop
    if g_org_id_list.exists(i) then
      g_org_id_list(i) := null;
    end if;
  end loop;
  for i in 1..g_loc_id_list.count loop
    if g_loc_id_list.exists(i) then
      g_loc_id_list(i) := null;
    end if;
  end loop;
  for i in 1..g_gre_list.count loop
    if g_gre_list.exists(i) then
      g_gre_list(i) := null;
    end if;
  end loop;
  for i in 1..g_state_list.count loop
    if g_state_list.exists(i) then
      g_state_list(i) := null;
    end if;
  end loop;
  for i in 1..g_bnft_grp_list.count loop
    if g_bnft_grp_list.exists(i) then
      g_bnft_grp_list(i) := null;
    end if;
  end loop;
  for i in 1..g_ee_status_list.count loop
    if g_ee_status_list.exists(i) then
      g_ee_status_list(i) := null;
    end if;
  end loop;
  for i in 1..g_payroll_id_list.count loop
    if g_payroll_id_list.exists(i) then
      g_payroll_id_list(i) := null;
    end if;
  end loop;

  for i in 1..g_payroll_rl_list.count loop
    if g_payroll_rl_list.exists(i) then
      g_payroll_rl_list(i) := null;
    end if;
  end loop;


  for i in 1..g_enrt_plan_list.count loop
    if g_enrt_plan_list.exists(i) then
      g_enrt_plan_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_rg_plan_list.count loop
    if g_enrt_rg_plan_list.exists(i) then
      g_enrt_rg_plan_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_sspndd_list.count loop
    if g_enrt_sspndd_list.exists(i) then
      g_enrt_sspndd_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_cvg_strt_dt_list1.count loop
    if g_enrt_cvg_strt_dt_list1.exists(i) then
      g_enrt_cvg_strt_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_cvg_strt_dt_list2.count loop
    if g_enrt_cvg_strt_dt_list2.exists(i) then
      g_enrt_cvg_strt_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_cvg_drng_perd_list1.count loop
    if g_enrt_cvg_drng_perd_list1.exists(i) then
      g_enrt_cvg_drng_perd_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_cvg_drng_perd_list2.count loop
    if g_enrt_cvg_drng_perd_list2.exists(i) then
      g_enrt_cvg_drng_perd_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_stat_list.count loop
    if g_enrt_stat_list.exists(i) then
      g_enrt_stat_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_mthd_list.count loop
    if g_enrt_mthd_list.exists(i) then
      g_enrt_mthd_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_pgm_list.count loop
    if g_enrt_pgm_list.exists(i) then
      g_enrt_pgm_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_pl_typ_list.count loop
    if g_enrt_pl_typ_list.exists(i) then
      g_enrt_pl_typ_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_last_upd_dt_list1.count loop
    if g_enrt_last_upd_dt_list1.exists(i) then
      g_enrt_last_upd_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_last_upd_dt_list2.count loop
    if g_enrt_last_upd_dt_list2.exists(i) then
      g_enrt_last_upd_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_ler_name_list.count loop
    if g_enrt_ler_name_list.exists(i) then
      g_enrt_ler_name_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_ler_stat_list.count loop
    if g_enrt_ler_stat_list.exists(i) then
      g_enrt_ler_stat_list(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_ler_ocrd_dt_list1.count loop
    if g_enrt_ler_ocrd_dt_list1.exists(i) then
      g_enrt_ler_ocrd_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_ler_ocrd_dt_list2.count loop
    if g_enrt_ler_ocrd_dt_list2.exists(i) then
      g_enrt_ler_ocrd_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_ler_ntfn_dt_list1.count loop
    if g_enrt_ler_ntfn_dt_list1.exists(i) then
      g_enrt_ler_ntfn_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_ler_ntfn_dt_list2.count loop
    if g_enrt_ler_ntfn_dt_list2.exists(i) then
      g_enrt_ler_ntfn_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_enrt_rltn_list.count loop
    if g_enrt_rltn_list.exists(i) then
      g_enrt_rltn_list(i) := null;
    end if;
  end loop;

 for i in 1..g_enrt_dpnt_rltn_list.count loop
    if g_enrt_dpnt_rltn_list.exists(i) then
      g_enrt_dpnt_rltn_list(i) := null;
    end if;
  end loop;

  for i in 1..g_elct_plan_list.count loop
    if g_elct_plan_list.exists(i) then
      g_elct_plan_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_rg_plan_list.count loop
    if g_elct_rg_plan_list.exists(i) then
      g_elct_rg_plan_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_enrt_strt_dt_list1.count loop
    if g_elct_enrt_strt_dt_list1.exists(i) then
      g_elct_enrt_strt_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_enrt_strt_dt_list2.count loop
    if g_elct_enrt_strt_dt_list2.exists(i) then
      g_elct_enrt_strt_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_yrprd_list.count loop
    if g_elct_yrprd_list.exists(i) then
      g_elct_yrprd_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_pgm_list.count loop
    if g_elct_pgm_list.exists(i) then
      g_elct_pgm_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_pl_typ_list.count loop
    if g_elct_pl_typ_list.exists(i) then
      g_elct_pl_typ_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_last_upd_dt_list1.count loop
    if g_elct_last_upd_dt_list1.exists(i) then
      g_elct_last_upd_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_last_upd_dt_list2.count loop
    if g_elct_last_upd_dt_list2.exists(i) then
      g_elct_last_upd_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_ler_name_list.count loop
    if g_elct_ler_name_list.exists(i) then
      g_elct_ler_name_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_ler_stat_list.count loop
    if g_elct_ler_stat_list.exists(i) then
      g_elct_ler_stat_list(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_ler_ocrd_dt_list1.count loop
    if g_elct_ler_ocrd_dt_list1.exists(i) then
      g_elct_ler_ocrd_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_ler_ocrd_dt_list2.count loop
    if g_elct_ler_ocrd_dt_list2.exists(i) then
      g_elct_ler_ocrd_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_ler_ntfn_dt_list1.count loop
    if g_elct_ler_ntfn_dt_list1.exists(i) then
      g_elct_ler_ntfn_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_ler_ntfn_dt_list2.count loop
    if g_elct_ler_ntfn_dt_list2.exists(i) then
      g_elct_ler_ntfn_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_elct_rltn_list.count loop
    if g_elct_rltn_list.exists(i) then
      g_elct_rltn_list(i) := null;
    end if;
  end loop;
  /* for i in 1..g_per_plan_list.count loop  -- tvh remove
    if g_per_plan_list.exists(i) then
      g_per_plan_list(i) := null;
    end if;
  end loop; */
 /* for i in 1..g_part_type_list.count loop
    if g_part_type_list.exists(i) then
      g_part_type_list(i) := null;
    end if;
  end loop; */
  for i in 1..g_ele_input_list.count loop
    if g_ele_input_list.exists(i) then
      g_ele_input_list(i) := null;
      g_ele_type_list(i) := null;
    end if;
  end loop;
  for i in 1..g_person_rule_list.count loop
    if g_person_rule_list.exists(i) then
      g_person_rule_list(i) := null;
    end if;
  end loop;
  for i in 1..g_per_ler_list.count loop
    if g_per_ler_list.exists(i) then
      g_per_ler_list(i) := null;
    end if;
  end loop;
  for i in 1..g_person_type_list.count loop
    if g_person_type_list.exists(i) then
      g_person_type_list(i) := null;
    end if;
  end loop;
  for i in 1..g_chg_evt_list.count loop
    if g_chg_evt_list.exists(i) then
      g_chg_evt_list(i) := null;
    end if;
  end loop;
  for i in 1..g_chg_pay_evt_list.count loop
    if g_chg_pay_evt_list.exists(i) then
      g_chg_pay_evt_list(i) := null;
    end if;
  end loop;

  for i in 1..g_chg_eff_dt_list1.count loop
    if g_chg_eff_dt_list1.exists(i) then
      g_chg_eff_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_chg_eff_dt_list2.count loop
    if g_chg_eff_dt_list2.exists(i) then
      g_chg_eff_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_chg_actl_dt_list1.count loop
    if g_chg_actl_dt_list1.exists(i) then
      g_chg_actl_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_chg_actl_dt_list2.count loop
    if g_chg_actl_dt_list2.exists(i) then
      g_chg_actl_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_chg_login_list.count loop
    if g_chg_login_list.exists(i) then
      g_chg_login_list(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_typ_list.count loop
    if g_cm_typ_list.exists(i) then
      g_cm_typ_list(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_last_upd_dt_list1.count loop
    if g_cm_last_upd_dt_list1.exists(i) then
      g_cm_last_upd_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_last_upd_dt_list2.count loop
    if g_cm_last_upd_dt_list2.exists(i) then
      g_cm_last_upd_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_pr_last_upd_dt_list1.count loop
    if g_cm_pr_last_upd_dt_list1.exists(i) then
      g_cm_pr_last_upd_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_pr_last_upd_dt_list2.count loop
    if g_cm_pr_last_upd_dt_list2.exists(i) then
      g_cm_pr_last_upd_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_sent_dt_list1.count loop
    if g_cm_sent_dt_list1.exists(i) then
      g_cm_sent_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_sent_dt_list2.count loop
    if g_cm_sent_dt_list2.exists(i) then
      g_cm_sent_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_to_be_sent_dt_list1.count loop
    if g_cm_to_be_sent_dt_list1.exists(i) then
      g_cm_to_be_sent_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_cm_to_be_sent_dt_list2.count loop
    if g_cm_to_be_sent_dt_list2.exists(i) then
      g_cm_to_be_sent_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_crit_typ_list.count loop
    if g_crit_typ_list.exists(i) then
      g_crit_typ_list(i) := null;
    end if;
  end loop;
  for i in 1..g_crit_val_list.count loop
    if g_crit_val_list.exists(i) then
      g_crit_val_list(i) := null;
    end if;
  end loop;
  for i in 1..g_oper_list.count loop
    if g_oper_list.exists(i) then
      g_oper_list(i) := null;
    end if;
  end loop;
  for i in 1..g_val1_list.count loop
    if g_val1_list.exists(i) then
      g_val1_list(i) := null;
    end if;
  end loop;
  for i in 1..g_val2_list.count loop
    if g_val2_list.exists(i) then
      g_val2_list(i) := null;
    end if;
  end loop;
  for i in 1..g_val2_list.count loop
    if g_val2_list.exists(i) then
      g_val2_list(i) := null;
    end if;
  end loop;
  for i in 1..g_actn_name_list.count loop
    if g_actn_name_list.exists(i) then
      g_actn_name_list(i) := null;
    end if;
  end loop;
  for i in 1..g_actn_item_rltn_list.count loop
    if g_actn_item_rltn_list.exists(i) then
      g_actn_item_rltn_list(i) := null;
    end if;
  end loop;
  for i in 1..g_prem_month_year_dt_list1.count loop
    if g_prem_month_year_dt_list1.exists(i) then
      g_prem_month_year_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_prem_month_year_dt_list2.count loop
    if g_prem_month_year_dt_list2.exists(i) then
      g_prem_month_year_dt_list2(i) := null;
    end if;
  end loop;
  for i in 1..g_payroll_last_dt_list1.count loop
    if g_payroll_last_dt_list1.exists(i) then
      g_payroll_last_dt_list1(i) := null;
    end if;
  end loop;
  for i in 1..g_payroll_last_dt_list2.count loop
    if g_payroll_last_dt_list2.exists(i) then
      g_payroll_last_dt_list2(i) := null;
    end if;
  end loop;

  for i in 1..g_tc_status_list.count loop
    if g_tc_status_list.exists(i) then
      g_tc_status_list(i) := null;
    end if;
  end loop;
  for i in 1..g_tc_deleted_list.count loop
    if g_tc_deleted_list.exists(i) then
      g_tc_deleted_list(i) := null;
    end if;
  end loop;
  for i in 1..g_project_id_list.count loop
    if g_project_id_list.exists(i) then
      g_project_id_list(i) := null;
    end if;
  end loop;
  for i in 1..g_task_id_list.count loop
    if g_task_id_list.exists(i) then
      g_task_id_list(i) := null;
    end if;
  end loop;
  for i in 1..g_exp_typ_id_list.count loop
    if g_exp_typ_id_list.exists(i) then
      g_exp_typ_id_list(i) := null;
    end if;
  end loop;
  for i in 1..g_po_num_list.count loop
    if g_po_num_list.exists(i) then
      g_po_num_list(i) := null;
    end if;
  end loop;

  --- cwb
  for i in 1..g_cwb_pl_list.count loop
    if g_cwb_pl_list.exists(i) then
      g_cwb_pl_list(i) := null;
    end if;
  end loop;

  for i in 1..g_cwb_prd_list.count loop
    if g_cwb_prd_list.exists(i) then
      g_cwb_prd_list(i) := null;
    end if;
  end loop;


  --- subhead
   for i in 1..g_subhead_rule_list.count loop
    if g_subhead_rule_list.exists(i) then
      g_subhead_rule_list(i) := null;
    end if;
  end loop;

   for i in 1..g_subhead_pos_list.count loop
    if g_subhead_pos_list.exists(i) then
      g_subhead_pos_list(i) := null;
    end if;
  end loop;


   for i in 1..g_subhead_job_list.count loop
    if g_subhead_job_list.exists(i) then
      g_subhead_job_list(i) := null;
    end if;
  end loop;


   for i in 1..g_subhead_loc_list.count loop
    if g_subhead_loc_list.exists(i) then
      g_subhead_loc_list(i) := null;
    end if;
  end loop;


   for i in 1..g_subhead_pay_list.count loop
    if g_subhead_pay_list.exists(i) then
      g_subhead_pay_list(i) := null;
    end if;
  end loop;

   for i in 1..g_subhead_org_list.count loop
    if g_subhead_org_list.exists(i) then
      g_subhead_org_list(i) := null;
    end if;
  end loop;

  for i in 1..g_subhead_bg_list.count loop
    if g_subhead_bg_list.exists(i) then
      g_subhead_bg_list(i) := null;
    end if;
  end loop;

  for i in 1..g_subhead_grd_list.count loop
    if g_subhead_grd_list.exists(i) then
      g_subhead_grd_list(i) := null;
    end if;
  end loop;

-- end of initialization of global lists
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
end initialize_all_cache_area;
-----------------------------------------------------------------------------
-------------------------< result >------------------------------------------
-----------------------------------------------------------------------------
-- This procedure is used to compare the criteria for combination
-- criteria type
--
Procedure result
(p_chg_evt_cd      in varchar2,
 p_chg_evt_source  in varchar2 default null ,
 p_eff_dt          in date,
 p_actl_dt         in date,
 p_crit_typ_cd     in varchar2,
 p_oper_cd         in varchar2,
 p_val1            in varchar2,
 p_val2            in varchar2,
 p_result          out nocopy varchar2)
is
--
  l_eff_dt_1     date;
  l_eff_dt_2     date;
  l_actl_dt_1    date;
  l_actl_dt_2    date;
  l_success      varchar2(1);
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'result';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
  l_success := 'N';
  --
  -- Operator is 'between'
  if p_oper_cd = 'BE' then
    if p_crit_typ_cd = 'CAD' then
      l_actl_dt_1 := trunc(ben_ext_util.calc_ext_date
                           (p_val1,
                            ben_ext_person.g_effective_date,
                            ben_ext_thread.g_ext_dfn_id)
                           );
      l_actl_dt_2 := trunc(ben_ext_util.calc_ext_date
                           (p_val2,
                            ben_ext_person.g_effective_date,
                            ben_ext_thread.g_ext_dfn_id)
                           );
      if trunc(p_actl_dt) >= l_actl_dt_1 and trunc(p_actl_dt) <= l_actl_dt_2 then
        l_success := 'Y';
      else
        l_success := 'N';
      end if;
    elsif p_crit_typ_cd = 'CED' then
      l_eff_dt_1 := trunc(ben_ext_util.calc_ext_date
                          (p_val1,
                           ben_ext_person.g_effective_date,
                           ben_ext_thread.g_ext_dfn_id)
                          );
      l_eff_dt_2 := trunc(ben_ext_util.calc_ext_date
                          (p_val2,
                           ben_ext_person.g_effective_date,
                           ben_ext_thread.g_ext_dfn_id)
                          );
      if trunc(p_eff_dt) >= l_eff_dt_1 and trunc(p_eff_dt) <= l_eff_dt_2 then
        l_success := 'Y';
      else
        l_success := 'N';
      end if;
    end if;
  -- Operator 'between' ends
  -- Operator '='
  elsif p_oper_cd = 'EQ' then
    if p_crit_typ_cd in ( 'CCE' , 'CPE') then
      if p_chg_evt_cd = p_val1 then
        l_success := 'Y';
      else
        l_success := 'N';
      end if;
    elsif p_crit_typ_cd = 'CAD' then
      l_actl_dt_1 := trunc(ben_ext_util.calc_ext_date
                           (p_val1,
                            ben_ext_person.g_effective_date,
                            ben_ext_thread.g_ext_dfn_id)
                           );
      if trunc(p_actl_dt) = l_actl_dt_1 then
        l_success := 'Y';
      else
        l_success := 'N';
      end if;
    elsif p_crit_typ_cd = 'CED' then
      l_eff_dt_1 := trunc(ben_ext_util.calc_ext_date
                          (p_val1,
                           ben_ext_person.g_effective_date,
                           ben_ext_thread.g_ext_dfn_id)
                          );
      if trunc(p_eff_dt) = l_eff_dt_1 then
        l_success := 'Y';
      else
        l_success := 'N';
      end if;
    end if;
  -- Operator '=' ends
  -- Operator '<>'
  elsif p_oper_cd = 'NE' then
    if p_crit_typ_cd in ( 'CCE' , 'CPE') then
      if p_chg_evt_cd <> p_val1 then
        l_success := 'Y';
      else
        l_success := 'N';
      end if;
    end if;
  end if;
  --
  p_result := l_success;
--
--
  if g_debug then
    hr_utility.set_location('Exiting:'||l_proc, 15);
  end if;
--
End;
--
-----------------------------------------------------------------------------
-------------------------< get_incl_crit_values >----------------------------
-----------------------------------------------------------------------------
--
Procedure get_incl_crit_values (p_crit_typ_id  in       number,
                                p_incl_rqd     in out nocopy   varchar2,
                                p_list          out nocopy   num_list)
is
--
  CURSOR get_values IS
  SELECT val_1
  FROM   ben_ext_crit_val
  WHERE  ext_crit_typ_id = p_crit_typ_id;
--
  l_val_1      ben_ext_crit_val.val_1%type;
  l_proc       varchar2(72);
  --- more then one criteria validated for pgm,pl,opt,pl_typ id  so all the crieria will be calling the
  -- same function to store the value
  -- now the dups are not validated , can be done in future
  l_index      binary_integer := nvl(p_list.count(),0);
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_incl_crit_values';
    hr_utility.set_location('Entering:'||l_proc||'num', 5);
  end if;
--
  open get_values;
  loop
    fetch get_values into l_val_1;
    exit when get_values%notfound;
    l_index := l_index + 1;
    p_list(l_index) := to_number(l_val_1);
  end loop;
  if p_list.count > 0 then
    p_incl_rqd := 'Y';
  end if;
  close get_values;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc || p_incl_rqd , 15);
  end if;
--
End get_incl_crit_values;
--
-----------------------------------------------------------------------------
-------------------------< get_incl_crit_values >----------------------------
-----------------------------------------------------------------------------
--
Procedure get_incl_crit_values (p_crit_typ_id in       number,
                                p_incl_rqd    in out nocopy   varchar2,
                                p_list         out nocopy   char_list)
is
--
  CURSOR get_values IS
  SELECT val_1
  FROM   ben_ext_crit_val
  WHERE  ext_crit_typ_id = p_crit_typ_id;
--
  l_val_1      ben_ext_crit_val.val_1%type;
  l_proc       varchar2(72);
  --- more then one criteria validated for pgm,pl,opt,pl_typ id  so all the crieria will be calling the
  -- same function to store the value
  -- now the dups are not validated , can be done in future
  l_index      binary_integer := nvl(p_list.count(),0);

--
Begin
--
  if g_debug then
    l_proc := g_package||'get_incl_crit_values';
    hr_utility.set_location('Entering:'||l_proc || 'char', 5);
  end if;
--
  open get_values;
  loop
    fetch get_values into l_val_1;
    exit when get_values%notfound;
    l_index := l_index + 1;
    p_list(l_index) := l_val_1;
  end loop;
  if p_list.count > 0 then
    p_incl_rqd := 'Y';
  end if;
  close get_values;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
End get_incl_crit_values;
--
-----------------------------------------------------------------------------
-------------------------< get_incl_crit_values >----------------------------
-----------------------------------------------------------------------------
--
Procedure get_incl_crit_values (p_crit_typ_id in      number,
                                p_incl_rqd   in out nocopy   varchar2,
                                p_list1       out nocopy   num_list,
                                p_list2       out nocopy   num_list)
is
--
  CURSOR get_values IS
  SELECT val_1, val_2
  FROM   ben_ext_crit_val
  WHERE  ext_crit_typ_id = p_crit_typ_id;
--
  l_val_1      ben_ext_crit_val.val_1%type;
  l_val_2      ben_ext_crit_val.val_2%type;
  l_proc       varchar2(72);
  l_index      binary_integer := 0;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_incl_crit_values';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
  open get_values;
  loop
    fetch get_values into l_val_1, l_val_2;
    exit when get_values%notfound;
    l_index := l_index + 1;
    p_list1(l_index) := to_number(l_val_1);
    p_list2(l_index) := to_number(l_val_2);
  end loop;
  if p_list1.count > 0 then
    p_incl_rqd := 'Y';
  end if;
  close get_values;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
End get_incl_crit_values;
--
-----------------------------------------------------------------------------
-------------------------< get_incl_crit_values >----------------------------
-----------------------------------------------------------------------------
--
Procedure get_incl_crit_values (p_crit_typ_id in      number,
                                p_incl_rqd   in out nocopy   varchar2,
                                p_list1       out nocopy   char_list,
                                p_list2       out nocopy   char_list)
is
--
  CURSOR get_values IS
  SELECT val_1, val_2
  FROM   ben_ext_crit_val
  WHERE  ext_crit_typ_id = p_crit_typ_id;
--
  l_val_1      ben_ext_crit_val.val_1%type;
  l_val_2      ben_ext_crit_val.val_2%type;
  l_proc       varchar2(72);
  l_index      binary_integer := 0;
--
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_incl_crit_values';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
  open get_values;
  loop
    fetch get_values into l_val_1, l_val_2;
    exit when get_values%notfound;
    l_index := l_index + 1;
    p_list1(l_index) := l_val_1;
    p_list2(l_index) := l_val_2;
  end loop;
  if p_list1.count > 0 then
    p_incl_rqd := 'Y';
  end if;
  close get_values;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
End get_incl_crit_values;
--
-----------------------------------------------------------------------------
-------------------------< get_incl_crit_values >----------------------------
-----------------------------------------------------------------------------
--
Procedure get_incl_crit_values (p_crit_typ_id in     number,
                                p_incl_rqd           in out nocopy   varchar2,
                                p_crit_typ_list       out nocopy   char_list,
                                p_crit_val_list       out nocopy   num_list,
                                p_oper_list           out nocopy   char_list,
                                p_val1_list           out nocopy   char_list,
                                p_val2_list           out nocopy   char_list)
is
--
  CURSOR get_values IS
  SELECT ext_crit_val_id
  FROM   ben_ext_crit_val
  WHERE  ext_crit_typ_id = p_crit_typ_id
  ORDER BY ext_crit_val_id;
--
  CURSOR get_cmbn(p_crit_val_id ben_ext_crit_val.ext_crit_val_id%type) IS
  SELECT ext_crit_val_id,
         crit_typ_cd,
         oper_cd,
         val_1,
         val_2
  FROM   ben_ext_crit_cmbn
  WHERE  ext_crit_val_id = p_crit_val_id;

  l_get_cmbn get_cmbn%rowtype;
--
  l_crit_val_id    ben_ext_crit_val.ext_crit_val_id%type;
  l_proc           varchar2(72);
  l_index_val      binary_integer := 0;
  l_index_cmbn     binary_integer := 0;
--
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_incl_crit_values';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
  open get_values;
  loop
    fetch get_values into l_crit_val_id;
    exit when get_values%notfound;
    l_index_val := l_index_val + 1;
    open get_cmbn(l_crit_val_id);
    loop
      fetch get_cmbn into l_get_cmbn;
      exit when get_cmbn%notfound;
      l_index_cmbn := l_index_cmbn + 1;
      p_crit_val_list(l_index_cmbn) := l_get_cmbn.ext_crit_val_id;
      p_crit_typ_list(l_index_cmbn) := l_get_cmbn.crit_typ_cd;
      p_oper_list(l_index_cmbn)     := l_get_cmbn.oper_cd;
      p_val1_list(l_index_cmbn)     := l_get_cmbn.val_1;
      p_val2_list(l_index_cmbn)     := l_get_cmbn.val_2;
    end loop;
    close get_cmbn;
  end loop;
  if p_crit_val_list.count > 0 then
    p_incl_rqd := 'Y';
  end if;
  close get_values;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
End get_incl_crit_values;
--
-----------------------------------------------------------------------------
-------------------------< get_incl_crit_values_rg >----------------------------
-----------------------------------------------------------------------------
--
Procedure get_incl_crit_values_rg (p_crit_typ_id  in       number,
                                   p_incl_rqd     in out nocopy   varchar2,
                                   p_list         out nocopy      num_list)
is
--
--
  CURSOR get_values is
  SELECT pl_id
  FROM   ben_popl_rptg_grp_f rg,
         ben_ext_crit_val xcv
  WHERE to_char(rg.rptg_grp_id) = xcv.val_1
               and xcv.ext_crit_typ_id = p_crit_typ_id
               and rg.pl_id is not null
               and ben_ext_person.g_benefits_ext_dt between rg.effective_start_date
                       and rg.effective_end_date;
--
  l_val_1      ben_popl_rptg_grp_f.pl_id%type;
  l_proc       varchar2(72);
  l_index      binary_integer := 0;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_incl_crit_values_rg';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
  open get_values;
  loop
    fetch get_values into l_val_1;
    exit when get_values%notfound;
    l_index := l_index + 1;
    p_list(l_index) := to_number(l_val_1);
  end loop;
  if p_list.count > 0 then
    p_incl_rqd := 'Y';
  end if;
  close get_values;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
End get_incl_crit_values_rg;
--
-----------------------------------------------------------------------------
---------------------< determine_incl_crit_to_check >------------------------
-----------------------------------------------------------------------------
--
-- The following procedure sets the cache area.
--
Procedure determine_incl_crit_to_check
  (p_ext_crit_prfl_id in ben_ext_crit_prfl.ext_crit_prfl_id%type) is
--
  l_proc    varchar2(72);
--
  CURSOR get_incldd_incl_crit IS
  SELECT ext_crit_typ_id, crit_typ_cd, excld_flag
  FROM   ben_ext_crit_typ
  WHERE  ext_crit_prfl_id = p_ext_crit_prfl_id
  ORDER BY excld_flag ;
--
  l_crit_typ_id      ben_ext_crit_typ.ext_crit_typ_id%type;
  l_crit_typ_cd      ben_ext_crit_typ.crit_typ_cd%type;
--
  l_excld_flag       varchar2(1);
--
Begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'determine_incl_crit_to_check';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;



--
  Initialize_All_Cache_Area;
--
  open get_incldd_incl_crit;
  loop
    fetch get_incldd_incl_crit into l_crit_typ_id, l_crit_typ_cd, l_excld_flag;
    exit when get_incldd_incl_crit%notfound;

      if g_debug then
         hr_utility.set_location('crit_typ_cd:'|| l_crit_typ_cd, 5);
      end if;

    if l_crit_typ_cd = 'PID' then  -- specific person
      g_person_id_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_person_id_incl_rqd,
                           g_person_id_list);
    elsif l_crit_typ_cd = 'PPC' then  -- postal code
      g_postal_code_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_postal_code_incl_rqd,
                           g_postal_code_list1,
                           g_postal_code_list2);
    elsif l_crit_typ_cd = 'POR' then  -- assignment organization
      g_org_id_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_org_id_incl_rqd,
                           g_org_id_list);
    elsif l_crit_typ_cd = 'PLO' then -- assignment location
      g_loc_id_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_loc_id_incl_rqd,
                           g_loc_id_list);
    elsif l_crit_typ_cd = 'PLE' then  -- assignmnet legal entity
      g_gre_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_gre_incl_rqd,
                           g_gre_list);
    elsif l_crit_typ_cd = 'PST' then  -- state
      g_state_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_state_incl_rqd,
                           g_state_list);
    elsif l_crit_typ_cd = 'PBG' then  -- benefits group
      g_bnft_grp_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_bnft_grp_incl_rqd,
                           g_bnft_grp_list);
    elsif l_crit_typ_cd = 'PAS' then  -- assignment status
      g_ee_status_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_ee_status_incl_rqd,
                           g_ee_status_list);
    elsif l_crit_typ_cd = 'RRL' then  -- assignmnet payroll
      g_payroll_id_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_payroll_id_incl_rqd,
                           g_payroll_id_list);

    elsif l_crit_typ_cd = 'RFFRL' then  -- payroll rule
      g_payroll_rl_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_payroll_rl_incl_rqd,
                           g_payroll_rl_list);

   elsif l_crit_typ_cd in ( 'BNFOPN','BNFOPC') then  -- enrollment result - option
      g_enrt_opt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_opt_incl_rqd,
                           g_enrt_opt_list);

        --2732104  whether short name or pln name or short code  the pgm id is validated
    elsif l_crit_typ_cd in ( 'BPL','BNFPLN','BNFPLC') then  -- enrollment result - plan
      g_enrt_plan_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_plan_incl_rqd,
                           g_enrt_plan_list);
    elsif l_crit_typ_cd = 'BRG' then  -- enrollment result - reporting group
      g_enrt_rg_plan_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values_rg(l_crit_typ_id,
                           g_enrt_rg_plan_incl_rqd,
                           g_enrt_rg_plan_list);
    elsif l_crit_typ_cd = 'BSE' then  -- enrollment result - suspended flag
      g_enrt_sspndd_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_sspndd_incl_rqd,
                           g_enrt_sspndd_list);
    elsif l_crit_typ_cd = 'BERCSD' then  -- enrollment result - coverage start date
      g_enrt_cvg_strt_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_cvg_strt_dt_incl_rqd,
                           g_enrt_cvg_strt_dt_list1,
                           g_enrt_cvg_strt_dt_list2);
    elsif l_crit_typ_cd = 'BERCDP' then  -- enrollment result - coverage during period
      g_enrt_cvg_drng_prd_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_cvg_drng_perd_incl_rqd,
                           g_enrt_cvg_drng_perd_list1,
                           g_enrt_cvg_drng_perd_list2);
    elsif l_crit_typ_cd = 'BERSTA' then  -- enrollment result - status
      g_enrt_stat_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_stat_incl_rqd,
                           g_enrt_stat_list);
    elsif l_crit_typ_cd = 'BERENM' then  -- enrollment result - enrollment method
      g_enrt_mthd_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_mthd_incl_rqd,
                           g_enrt_mthd_list);
      --2732104  whether short name or pgm name or short code  the pgm id is validated
    elsif l_crit_typ_cd in ( 'BERPGN','BNFPGC','BNFPGN')  then  -- enrollment result - program name
      g_enrt_pgm_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_pgm_incl_rqd,
                           g_enrt_pgm_list);
       --2732104  whether short name or plan type name or short code  the pgm id is validated
    elsif l_crit_typ_cd in ('BERPTN','BNFPTN','BNFPTC')  then  -- enrollment result - plan type name
      g_enrt_pl_typ_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_pl_typ_incl_rqd,
                           g_enrt_pl_typ_list);
    elsif l_crit_typ_cd = 'BERLUD' then  -- enrollment result - last update date
      g_enrt_last_upd_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_last_upd_dt_incl_rqd,
                           g_enrt_last_upd_dt_list1,
                           g_enrt_last_upd_dt_list2);
    elsif l_crit_typ_cd = 'BERLEN' then  -- enrollment result - life event name
      g_enrt_ler_name_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_ler_name_incl_rqd,
                           g_enrt_ler_name_list);
    elsif l_crit_typ_cd = 'BERLES' then  -- enrollment result - life event status
      g_enrt_ler_stat_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_ler_stat_incl_rqd,
                           g_enrt_ler_stat_list);
    elsif l_crit_typ_cd = 'BERLOD' then  -- enrollment result - life event occurred date
      g_enrt_ler_ocrd_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_ler_ocrd_dt_incl_rqd,
                           g_enrt_ler_ocrd_dt_list1,
                           g_enrt_ler_ocrd_dt_list2);
    elsif l_crit_typ_cd = 'BERLND' then  -- enrollment result - life event notif date
      g_enrt_ler_ntfn_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_ler_ntfn_dt_incl_rqd,
                           g_enrt_ler_ntfn_dt_list1,
                           g_enrt_ler_ntfn_dt_list2);
    elsif l_crit_typ_cd = 'BERMIS' then  -- enrollment result - relation
      g_enrt_rltn_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_rltn_incl_rqd,
                           g_enrt_rltn_list);
    elsif l_crit_typ_cd = 'BEDPLN' then  -- dependent  - relation
      g_enrt_dpnt_rltn_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_enrt_dpnt_rltn_incl_rqd,
                           g_enrt_dpnt_rltn_list);

    elsif l_crit_typ_cd = 'BACN' then  -- action item - name
      g_actn_name_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_actn_name_incl_rqd,
                           g_actn_name_list);
    elsif l_crit_typ_cd = 'BACMIS' then  -- action item - relation
      g_actn_item_rltn_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_actn_item_rltn_incl_rqd,
                           g_actn_item_rltn_list);
    elsif l_crit_typ_cd = 'BECESD' then  -- electable choice - enrollment period start date
      g_elct_enrt_strt_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_enrt_strt_dt_incl_rqd,
                           g_elct_enrt_strt_dt_list1,
                           g_elct_enrt_strt_dt_list2);
    elsif l_crit_typ_cd = 'BECLEN' then  -- electable choice - life event name
      g_elct_ler_name_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_ler_name_incl_rqd,
                           g_elct_ler_name_list);
    elsif l_crit_typ_cd = 'BECLES' then  -- electable choice - life event status
      g_elct_ler_stat_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_ler_stat_incl_rqd,
                           g_elct_ler_stat_list);
    elsif l_crit_typ_cd = 'BECLUD' then  -- electable choice - last update date
      g_elct_last_upd_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_last_upd_dt_incl_rqd,
                           g_elct_last_upd_dt_list1,
                           g_elct_last_upd_dt_list2);
    elsif l_crit_typ_cd = 'BECLND' then  -- electable choice - life event notification date
      g_elct_ler_ntfn_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_ler_ntfn_dt_incl_rqd,
                           g_elct_ler_ntfn_dt_list1,
                           g_elct_ler_ntfn_dt_list2);
    elsif l_crit_typ_cd = 'BECLED' then  -- electable choice - life event occurred date
      g_elct_ler_ocrd_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_ler_ocrd_dt_incl_rqd,
                           g_elct_ler_ocrd_dt_list1,
                           g_elct_ler_ocrd_dt_list2);


     elsif l_crit_typ_cd in ( 'BEFOPN' , 'BEFOPC')  then  -- electable choice option z

            g_elct_opt_excld_flag := l_excld_flag;
            Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_opt_incl_rqd,
                           g_elct_opt_list);

         --2732104  whether short name or pl name or short code  the pgm id is validated
    elsif l_crit_typ_cd in ( 'BECPLN','BEFPLN','BEFPLC') then  -- electable choice - plan name
      g_elct_plan_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_plan_incl_rqd,
                           g_elct_plan_list);
    elsif l_crit_typ_cd = 'BECRPG' then  -- electable choice - reporting group
      g_elct_rg_plan_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values_rg(l_crit_typ_id,
                           g_elct_rg_plan_incl_rqd,
                           g_elct_rg_plan_list);
        --2732104  whether short name or pgm name or short code  the pgm id is validated
    elsif l_crit_typ_cd in ( 'BECPGN','BEFPGN','BEFPGC')  then  -- electable choice - program name
      g_elct_pgm_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_pgm_incl_rqd,
                           g_elct_pgm_list);
          --2732104  whether short name or plan type name or short code  the pl_type id is validated
    elsif l_crit_typ_cd in ('BECPTN','BEFPTN','BEFPTC') then  -- electable choice - plan type name
      g_elct_pl_typ_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_pl_typ_incl_rqd,
                           g_elct_pl_typ_list);
    elsif l_crit_typ_cd = 'BECYRP' then  -- electable choice - year period
      g_elct_yrprd_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_yrprd_incl_rqd,
                           g_elct_yrprd_list);
    elsif l_crit_typ_cd = 'BECMIS' then  -- electable choice - misc
      g_elct_rltn_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_elct_rltn_incl_rqd,
                           g_elct_rltn_list);

   /*   Get_Incl_Crit_Values(l_crit_typ_id,
                           g_per_plan_incl_rqd,
                           g_per_plan_list); */
  /*  elsif l_crit_typ_cd = 'BPT' then -- tvh remove this altogether.
      g_part_type_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_part_type_incl_rqd,
                           g_part_type_list); */

    elsif l_crit_typ_cd = 'REE' then  -- element input
      g_ele_input_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_ele_input_incl_rqd,
                           g_ele_input_list,
                           g_ele_type_list);
    elsif l_crit_typ_cd = 'PRL' then -- person rule
      g_person_rule_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_person_rule_incl_rqd,
                           g_person_rule_list);
    elsif l_crit_typ_cd = 'PLV' then  -- person life event ?
      g_per_ler_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_per_ler_incl_rqd,
                           g_per_ler_list);
    elsif l_crit_typ_cd = 'PPT' then  -- person type
      g_person_type_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_person_type_incl_rqd,
                           g_person_type_list);
    elsif l_crit_typ_cd = 'CCE' then  -- change event
      g_chg_evt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_chg_evt_incl_rqd,
                           g_chg_evt_list);
     elsif l_crit_typ_cd = 'CPE' then  -- change event
      g_chg_pay_evt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_chg_pay_evt_incl_rqd,
                           g_chg_pay_evt_list);

    elsif l_crit_typ_cd = 'CED' then  -- change effective date
      g_chg_eff_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_chg_eff_dt_incl_rqd,
                           g_chg_eff_dt_list1,
                           g_chg_eff_dt_list2);
    elsif l_crit_typ_cd = 'CAD' then  -- change actual date
      g_chg_actl_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_chg_actl_dt_incl_rqd,
                           g_chg_actl_dt_list1,
                           g_chg_actl_dt_list2);
    elsif l_crit_typ_cd = 'CBU' then  -- changed by user
      g_chg_login_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_chg_login_incl_rqd,
                           g_chg_login_list);
    elsif l_crit_typ_cd = 'MTP' then  -- communication type
      g_cm_typ_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cm_typ_incl_rqd,
                           g_cm_typ_list);
    elsif l_crit_typ_cd = 'MPCLUD' then  -- per communication last update date
      g_cm_last_upd_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cm_last_upd_dt_incl_rqd,
                           g_cm_last_upd_dt_list1,
                           g_cm_last_upd_dt_list2);
    elsif l_crit_typ_cd = 'MPCPLUD' then  -- per communication provided last update date
      g_cm_pr_last_upd_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cm_pr_last_upd_dt_incl_rqd,
                           g_cm_pr_last_upd_dt_list1,
                           g_cm_pr_last_upd_dt_list2);
    elsif l_crit_typ_cd = 'MSDT' then  -- per communication provided sent date
      g_cm_sent_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cm_sent_dt_incl_rqd,
                           g_cm_sent_dt_list1,
                           g_cm_sent_dt_list2);
    elsif l_crit_typ_cd = 'MTBSDT' then  -- per communication provided to be sent date
      g_cm_to_be_sent_dt_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cm_to_be_sent_dt_incl_rqd,
                           g_cm_to_be_sent_dt_list1,
                           g_cm_to_be_sent_dt_list2);
    elsif l_crit_typ_cd = 'ADV' then  -- combination criteria

      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cmbn_incl_rqd,
                           g_crit_typ_list,
                           g_crit_val_list,
                           g_oper_list,
                           g_val1_list,
                           g_val2_list);
    elsif l_crit_typ_cd = 'EPLDT' then    -- premium last update date
            if g_debug then
              hr_utility.set_location('crit_type ' ||'EPLDT',16);
            end if;
            g_prem_last_updt_dt_excld_flag := l_excld_flag;
            Get_Incl_Crit_Values(l_crit_typ_id,
                           g_prem_last_updt_dt_rqd ,
                           g_prem_last_upd_dt_list1,
                           g_prem_last_upd_dt_list2);

    elsif l_crit_typ_cd = 'EPMNYR' then    -- premium month and year
          g_prem_month_year_excld_flag := l_excld_flag;
            if g_debug then
              hr_utility.set_location('crit_type ' ||'EPMNYR',16);
            end if;
          Get_Incl_Crit_Values(l_crit_typ_id,
                            g_prem_month_year_rqd,
                           g_prem_month_year_dt_list1,
                           g_prem_month_year_dt_list2) ;

    elsif l_crit_typ_cd = 'RPPEDT' then    -- pay period end date
          g_payroll_last_Date_excld_flag := l_excld_flag;
            if g_debug then
              hr_utility.set_location('crit_type ' ||'EPMNYR',16);
            end if;
          Get_Incl_Crit_Values(l_crit_typ_id,
                           g_payroll_last_date_incl_rqd,
                           g_payroll_last_dt_list1,
                           g_payroll_last_dt_list2) ;

           ---intilise the gloabl variable
          if g_payroll_last_dt_list1.count > 0 and g_payroll_last_dt_list2.count > 0 then
               ben_ext_person.g_pay_last_start_date  := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_payroll_last_dt_list1(1),
                      p_abs_date => ben_extract.g_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);

               ben_ext_person.g_pay_last_end_date  := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_payroll_last_dt_list2(1),
                      p_abs_date => ben_extract.g_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);

          end if ;

    elsif l_crit_typ_cd = 'PASU' then    --person assignment to use
           Get_Incl_Crit_Values(l_crit_typ_id,
                     g_asg_to_use_rqd,
                     g_asg_to_use_list);


     elsif l_crit_typ_cd = 'WPLPR' then -- CWB
      g_cwb_pl_prd_excld_flag  := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_cwb_pl_prd_rqd,
                           g_cwb_prd_list,
                           g_cwb_pl_list ) ;

    elsif l_crit_typ_cd = 'HRL' then -- subheader rule
      g_subhead_rule_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_rule_rqd,
                           g_subhead_rule_list);

    elsif l_crit_typ_cd = 'HJOB' then -- subheader job
      g_subhead_job_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_job_rqd,
                           g_subhead_job_list);

    elsif l_crit_typ_cd = 'HPOS' then -- subheader POS
      g_subhead_pos_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_pos_rqd,
                           g_subhead_pos_list);

    elsif l_crit_typ_cd = 'HLOC' then -- subheader LOC
      g_subhead_loc_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_loc_rqd,
                           g_subhead_loc_list);

    elsif l_crit_typ_cd = 'HPY' then -- subheader PAY
      g_subhead_pay_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_pay_rqd,
                           g_subhead_pay_list);

    elsif l_crit_typ_cd = 'HORG' then -- subheader ORG
      g_subhead_org_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_org_rqd,
                           g_subhead_org_list);


    elsif l_crit_typ_cd = 'HBG' then -- subheader business group
      g_subhead_bg_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_bg_rqd,
                           g_subhead_bg_list);


  elsif l_crit_typ_cd = 'HGRD' then -- subheader grade group
      g_subhead_grd_excld_flag := l_excld_flag;
      Get_Incl_Crit_Values(l_crit_typ_id,
                           g_subhead_grd_rqd,
                           g_subhead_grd_list);

	-- OTL inclusion criteria


    elsif l_crit_typ_cd = 'OTL_TC_STATUS' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_tc_status_incl_rqd,
                           g_tc_status_list);

    elsif l_crit_typ_cd = 'OTL_TC_DELETED' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_tc_deleted_incl_rqd,
                           g_tc_deleted_list);

    elsif l_crit_typ_cd = 'OTL_PROJECT_ID' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_project_id_incl_rqd,
                           g_project_id_list);

    elsif l_crit_typ_cd = 'OTL_TASK_ID' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_task_id_incl_rqd,
                           g_task_id_list);

    elsif l_crit_typ_cd = 'OTL_EXP_TYP_ID' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_exp_typ_id_incl_rqd,
                           g_exp_typ_id_list);

    elsif l_crit_typ_cd = 'OTL_ELEMENT_TYPE_ID' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_element_type_id_incl_rqd,
                           g_element_type_list);

    elsif l_crit_typ_cd = 'OTL_PO_NUM' then
           Get_Incl_Crit_Values(l_crit_typ_id,
                           g_po_num_incl_rqd,
                           g_po_num_list);

    end if;
--
  end loop;
--
  close get_incldd_incl_crit;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
end determine_incl_crit_to_check;
--





-----------------------------------------------------------------------------
------------------------< chk_person_id_incl >-------------------------------
-----------------------------------------------------------------------------
--
Procedure chk_person_id_incl
(p_person_id   in  per_all_people_f.person_id%type,
 p_excld_flag  in  varchar2)
is
--
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_person_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  for i in 1..g_person_id_list.count
  loop
    if p_person_id = g_person_id_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Person_Id_Incl;
--
-----------------------------------------------------------------------------
------------------------< chk_postal_code_incl >-----------------------------
-----------------------------------------------------------------------------
--
Procedure chk_postal_code_incl
(p_person_id   in  per_all_people_f.person_id%type,
 p_postal_code in per_addresses.postal_code%type,
 p_effective_date in date,
 p_excld_flag in varchar2)
is
--
  cursor get_postal_code is
  SELECT postal_code
  FROM   per_addresses addr
  WHERE  addr.person_id = p_person_id
  AND    primary_flag = 'Y'
  AND    p_effective_date between date_from
         and nvl(date_to, p_effective_date);
--
  l_postal_code   per_addresses.postal_code%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_postal_code_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_postal_code is null then
    open get_postal_code;
    fetch get_postal_code into l_postal_code;
    close get_postal_code;
  else
    l_postal_code := p_postal_code;
  end if;
  for i in 1..g_postal_code_list1.count
  loop
    if l_postal_code >=
        g_postal_code_list1(i)
        and l_postal_code <=
        nvl(g_postal_code_list2(i), g_postal_code_list1(i)) then -- 3108106 added nvl
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Postal_Code_Incl;
--
-----------------------------------------------------------------------------
-----------------------------< chk_org_id_incl >-----------------------------
-----------------------------------------------------------------------------
--
Procedure chk_org_id_incl
(p_person_id   in  per_all_people_f.person_id%type,
 p_org_id in per_all_assignments_f.organization_id%type,
 p_effective_date in date,
 p_excld_flag in varchar2)
is
--
  cursor get_org_id is
  SELECT organization_id
  FROM   per_all_assignments_f asn
  WHERE  asn.person_id = p_person_id
  and    asn.assignment_id = ben_ext_person.g_assignment_id   --1969853
  AND    asn.primary_flag = 'Y'
  AND    p_effective_date between effective_start_date
         and effective_end_date;
--
  l_org_id   per_all_assignments_f.organization_id%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_org_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_org_id is null then
    open get_org_id;
    fetch get_org_id into l_org_id;
    close get_org_id;
  else
    l_org_id := p_org_id;
  end if;
  for i in 1..g_org_id_list.count
  loop
    if l_org_id = g_org_id_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Org_Id_Incl;
--
-----------------------------------------------------------------------------
-----------------------------< chk_loc_id_incl >-----------------------------
-----------------------------------------------------------------------------
--
Procedure chk_loc_id_incl
(p_person_id   in  per_all_people_f.person_id%type,
 p_loc_id in per_all_assignments_f.location_id%type,
 p_effective_date in date,
 p_excld_flag in varchar2)
is
--
  cursor get_loc_id is
  SELECT location_id
  FROM   per_all_assignments_f asn
  WHERE  asn.person_id = p_person_id
  and    asn.assignment_id = ben_ext_person.g_assignment_id   --1969853
  AND    asn.primary_flag = 'Y'
  AND    p_effective_date between effective_start_date
         and effective_end_date;
--
  l_loc_id  per_all_assignments_f.location_id%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_loc_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_loc_id is null then
    open get_loc_id;
    fetch get_loc_id into l_loc_id;
    close get_loc_id;
  else
    l_loc_id := p_loc_id;
  end if;
  for i in 1..g_loc_id_list.count
  loop
    if l_loc_id = g_loc_id_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Loc_Id_Incl;
--
-----------------------------------------------------------------------------
--------------------------------< chk_gre_incl >-----------------------------
-----------------------------------------------------------------------------
--
Procedure chk_gre_incl
(p_person_id   in  per_all_people_f.person_id%type,
 p_gre in hr_soft_coding_keyflex.segment1%type,
 p_effective_date in date,
 p_excld_flag in varchar2)
is
--
  cursor get_gre is
  SELECT flex.segment1
  FROM   per_all_assignments_f asn, hr_soft_coding_keyflex flex
  WHERE  asn.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
  and    asn.assignment_id = ben_ext_person.g_assignment_id        --1969853
  AND    asn.person_id = p_person_id
  AND    asn.primary_flag = 'Y'
  AND    p_effective_date between asn.effective_start_date
         and asn.effective_end_date
  AND    p_effective_date between nvl(flex.start_date_active, p_effective_date)
         and nvl(flex.end_date_active, p_effective_date);
--
  l_gre  hr_soft_coding_keyflex.segment1%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_gre_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_gre is null then
    open get_gre;
    fetch get_gre into l_gre;
    close get_gre;
  else
    l_gre := p_gre;
  end if;
  for i in 1..g_gre_list.count
  loop
    if l_gre = g_gre_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Gre_Incl;
--
-----------------------------------------------------------------------------
------------------------------< chk_state_incl >-----------------------------
-----------------------------------------------------------------------------
--
Procedure chk_state_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_state          in per_addresses.region_2%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
  cursor get_state is
  SELECT addr.region_2
  FROM   per_all_people_f per, per_addresses addr
  WHERE  per.person_id = addr.person_id
  AND    per.person_id = p_person_id
  AND    addr.primary_flag = 'Y'
  AND    p_effective_date between per.effective_start_date
         and per.effective_end_date
  AND    p_effective_date between addr.date_from
         and nvl(addr.date_to, p_effective_date);
--
  l_state  per_addresses.region_2%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_state_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_state is null then
    open get_state;
    fetch get_state into l_state;
    close get_state;
  else
    l_state := p_state;
  end if;
  for i in 1..g_state_list.count
  loop
    if l_state = g_state_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_State_Incl;
--
-----------------------------------------------------------------------------
------------------------------< chk_bnft_grp_incl >--------------------------
-----------------------------------------------------------------------------
--
Procedure chk_bnft_grp_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_bnft_grp       in per_all_people_f.benefit_group_id%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
  cursor get_bnft_grp is
  SELECT benefit_group_id
  FROM   per_all_people_f per
  WHERE  per.person_id = p_person_id
  AND    p_effective_date between per.effective_start_date
         and per.effective_end_date;
--
  l_bnft_grp per_all_people_f.benefit_group_id%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_bnft_grp_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_bnft_grp is null then
    open get_bnft_grp;
    fetch get_bnft_grp into l_bnft_grp;
    close get_bnft_grp;
  else
    l_bnft_grp := p_bnft_grp;
  end if;
  for i in 1..g_bnft_grp_list.count
  loop
    if l_bnft_grp = g_bnft_grp_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Bnft_Grp_Incl;
--
-----------------------------------------------------------------------------
------------------------------< chk_ee_status_incl >-------------------------
-----------------------------------------------------------------------------
--
Procedure chk_ee_status_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_ee_status      in per_all_assignments_f.assignment_status_type_id%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
  cursor get_ee_status is
  SELECT assignment_status_type_id
  FROM   per_all_assignments_f asn
  WHERE  asn.person_id = p_person_id
  and   asn.assignment_id = ben_ext_person.g_assignment_id       --1969853
  AND    asn.primary_flag = 'Y'
  AND    p_effective_date between effective_start_date and effective_end_date;
--
  l_ee_status  per_all_assignments_f.assignment_status_type_id%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_ee_status_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_ee_status is null then
    open get_ee_status;
    fetch get_ee_status into l_ee_status;
    close get_ee_status;
  else
    l_ee_status := p_ee_status;
  end if;
  for i in 1..g_ee_status_list.count
  loop
    if l_ee_status = g_ee_status_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Ee_Status_Incl;
--
-----------------------------------------------------------------------------
------------------------------< chk_payroll_id_incl >-------------------------
-----------------------------------------------------------------------------
--
Procedure chk_payroll_id_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_payroll_id     in per_all_assignments_f.payroll_id%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
  cursor c_pay is
  SELECT payroll_id
  FROM   per_all_assignments_f asn
  WHERE  asn.person_id = p_person_id
  and   asn.assignment_id = ben_ext_person.g_assignment_id    --1969853
  AND    asn.primary_flag = 'Y'
  AND    p_effective_date between effective_start_date and effective_end_date;
--
  l_payroll_id  per_all_assignments_f.payroll_id%type;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_payroll_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_payroll_id is null then
    open c_pay;
    fetch c_pay into l_payroll_id;
    close c_pay;
  else
    l_payroll_id := p_payroll_id;
  end if;
  for i in 1..g_payroll_id_list.count
  loop
    if l_payroll_id = g_payroll_id_list(i) then
      if p_excld_flag = 'N' then
        raise g_include;
      else
        raise g_not_include;
      end if;
    end if;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_payroll_id_Incl;
--
-----------------------------------------------------------------------------
------------------------------< chk_person_rule_incl >-----------------------
-----------------------------------------------------------------------------
--
Procedure chk_person_rule_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  cursor c_asg is
  SELECT asg.assignment_id, asg.business_group_id
  FROM   per_all_assignments_f asg
  WHERE  asg.person_id = p_person_id
   and   asg.assignment_id = ben_ext_person.g_assignment_id   --1969853
  AND    (asg.primary_flag = 'Y' or asg.assignment_type = 'A' )  -- if the asg type is A dont validate the primary flag
  AND    p_effective_date between asg.effective_start_date
         and asg.effective_end_date
  order by  decode(asg.primary_flag , 'Y', 1, 2)  ;
--
  l_asg      c_asg%rowtype;
  l_outputs  ff_exec.outputs_t;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_person_rule_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  open c_asg;
  fetch c_asg into l_asg;
  close c_asg;
--
  if l_asg.assignment_id is not null then
    for i in 1..g_person_rule_list.count
    loop
      l_outputs := benutils.formula
                   (p_formula_id => g_person_rule_list(i),
                    p_effective_date => p_effective_date,
                    p_assignment_id => l_asg.assignment_id,
                    p_business_group_id => l_asg.business_group_id
                    --RChase pass extract definition id as input value
                    ,p_param1             => 'EXT_DFN_ID'
                    ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                    ,p_param2             => 'EXT_RSLT_ID'
                    ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                    ,p_param3             => 'EXT_PROCESS_BUSINESS_GROUP'
                    ,p_param3_value       =>  to_char(ben_extract.g_proc_business_group_id)
                   );
      if l_outputs(l_outputs.first).value = 'Y' then
        if p_excld_flag = 'N' then
          raise g_include;
        else
          raise g_not_include;
        end if;
      end if;
    end loop;
  end if;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Person_Rule_Incl;
--
-----------------------------------------------------------------------------
------------------------------< chk_per_ler_incl >---------------------------
-----------------------------------------------------------------------------
--
Procedure chk_per_ler_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
  cursor get_per_ler is
  SELECT ler_id
  FROM   ben_per_in_ler pil
  WHERE  pil.person_id = p_person_id
  AND    pil.per_in_ler_stat_cd = 'STRTD';
--
  l_ler_id ben_per_in_ler.ler_id%type;
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_per_ler_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  open get_per_ler;
  loop
    fetch get_per_ler into l_ler_id;
    exit when get_per_ler%notfound;
    for i in 1..g_per_ler_list.count
    loop
      if l_ler_id = g_per_ler_list(i) then
        if p_excld_flag = 'N' then
          raise g_include;
        else
          raise g_not_include;
        end if;
      end if;
    end loop;
  end loop;
  close get_per_ler;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Per_Ler_Incl;
--
-----------------------------------------------------------------------------
-------------------------< chk_person_type_incl >-----------------------
-----------------------------------------------------------------------------
--
Procedure chk_person_type_incl
(p_person_id      in  per_all_people_f.person_id%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
  cursor get_person_type is
  SELECT person_type_id
  FROM   per_person_type_usages_f ptu
  WHERE  ptu.person_id = p_person_id
  AND    p_effective_date between ptu.effective_start_date and
             ptu.effective_end_date;
--
  l_person_type_id per_person_type_usages_f.person_type_id%type;
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_person_type_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  open get_person_type;
  loop
    fetch get_person_type into l_person_type_id;
    exit when get_person_type%notfound;
    for i in 1..g_person_type_list.count
    loop
      if l_person_type_id = g_person_type_list(i) then
        if p_excld_flag = 'N' then
          raise g_include;
        else
          raise g_not_include;
        end if;
      end if;
    end loop;
  end loop;
  close get_person_type;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End Chk_Person_Type_Incl;
--
-----------------------------------------------------------------------------
---------------------------------< chk_cmbn_incl >---------------------------
-----------------------------------------------------------------------------
--
--The following procedure checks combination criteria inclusion
--
Procedure chk_cmbn_incl
(p_person_id        per_all_people_f.person_id%type,
 p_chg_evt_cd       varchar2,
 p_chg_evt_source   varchar2,
 p_effective_date   date,
 p_actl_date        date)
is
--
  l_success             varchar2(1);
  l_current_success     varchar2(1);
  l_current_crit_val    number := 0;
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cmbn_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  l_success := 'N';
  l_current_success := 'N';

  for i in 1..g_crit_val_list.count
    loop
      if g_crit_val_list(i) <> l_current_crit_val then
        l_current_crit_val := g_crit_val_list(i);
        if l_current_success = 'Y' then
          raise g_include;
        else
          result(p_chg_evt_cd,
                 p_chg_evt_source,
                 p_effective_date,
                 p_actl_date,
                 g_crit_typ_list(i),
                 g_oper_list(i),
                 g_val1_list(i),
                 g_val2_list(i),
                 l_success);
          if l_success = 'Y' then
            l_current_success := 'Y';
          else
            l_current_success := 'N';
          end if;
        end if;
      else
        result(p_chg_evt_cd,
               p_chg_evt_source,
               p_effective_date,
               p_actl_date,
               g_crit_typ_list(i),
               g_oper_list(i),
               g_val1_list(i),
               g_val2_list(i),
               l_success);
        if l_current_success = 'Y' and l_success = 'Y' then
          l_current_success := 'Y';
        else
          l_current_success := 'N';
        end if;

      end if;
    end loop;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  if l_current_success = 'Y' then
    raise g_include;
  else
    raise g_not_include;
  end if;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cmbn_incl;


-----------------------------------------------------------------------------
---------------------------< chk_enrt_opt_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_enrt_opt_incl
(p_opt_id        in  ben_opt_f.opt_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_opt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_opt_id is null then error, it must be passed in!
--
    for i in 1..g_enrt_opt_list.count
    loop
      if p_opt_id = g_enrt_opt_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_opt_incl;

--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_plan_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_enrt_plan_incl
(p_pl_id        in  ben_prtt_enrt_rslt_f.pl_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_plan_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_pl_id is null then error, it must be passed in!
--
    for i in 1..g_enrt_plan_list.count
    loop
      if p_pl_id = g_enrt_plan_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_plan_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_rg_plan_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plans of a particular reporting group id.
--
Procedure chk_enrt_rg_plan_incl
(p_pl_id        in  ben_prtt_enrt_rslt_f.pl_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_rg_plan_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_pl_id is null then error, it must be passed in!
--
    for i in 1..g_enrt_rg_plan_list.count
    loop
      if p_pl_id = g_enrt_rg_plan_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_rg_plan_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_sspndd_incl >---------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plans of a particular reporting group id.
--
Procedure chk_enrt_sspndd_incl
(p_sspndd_flag    in ben_prtt_enrt_rslt_f.sspndd_flag%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_sspndd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
if p_sspndd_flag is null then  -- sspndd_flag will always be null for eligiblity.
   raise g_include;
end if;
--
    for i in 1..g_enrt_sspndd_list.count
    loop
      if p_sspndd_flag = g_enrt_sspndd_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_sspndd_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_cvg_strt_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates enrt_cvg_strt_dt id.
--
Procedure chk_enrt_cvg_strt_dt_incl
(p_enrt_cvg_strt_dt in ben_prtt_enrt_rslt_f.enrt_cvg_strt_dt%type,
 p_effective_date   in date,
 p_excld_flag       in varchar2,
 p_pl_id            in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_cvg_strt_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_cvg_strt_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_cvg_strt_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id,
                      p_pl_id      => p_pl_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_cvg_strt_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id,
                      p_pl_id      => p_pl_id
                      );
      if p_enrt_cvg_strt_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_cvg_strt_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_cvg_drng_perd_incl >-------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates if a person was covered any time during
--  a period.
--
Procedure chk_enrt_cvg_drng_perd_incl
(p_enrt_cvg_strt_dt in  ben_prtt_enrt_rslt_f.enrt_cvg_strt_dt%type,
 p_enrt_cvg_thru_dt in  ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%type,
 p_effective_date     in  date,
 p_excld_flag     in varchar2,
 p_pl_id          in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_cvg_drng_perd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_cvg_drng_perd_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_cvg_drng_perd_list1(i),
                      p_abs_date    => p_effective_date,
                      p_ext_dfn_id  => ben_extract.g_ext_dfn_id,
                      p_pl_id       => p_pl_id );
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_cvg_drng_perd_list2(i),
                      p_abs_date    => p_effective_date,
                      p_ext_dfn_id  => ben_extract.g_ext_dfn_id,
                      p_pl_id       => p_pl_id );
      l_high_date := nvl(l_high_date,l_low_date);
      -- out of range if both dates are less than low date or greater than high date.
      if (p_enrt_cvg_strt_dt < l_low_date and p_enrt_cvg_thru_dt < l_low_date) or
         (p_enrt_cvg_strt_dt > l_high_date and p_enrt_cvg_thru_dt > l_high_date) or
         ( p_enrt_cvg_strt_dt > p_enrt_cvg_thru_dt )  then
          null;
      else
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_cvg_drng_perd_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_stat_incl >---------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates enrollment status code.
--
Procedure chk_enrt_stat_incl
(p_prtt_enrt_rslt_stat_cd in ben_prtt_enrt_rslt_f.prtt_enrt_rslt_stat_cd%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_stat_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
if p_prtt_enrt_rslt_stat_cd is null then
   raise g_include;
end if;
--
    for i in 1..g_enrt_stat_list.count
    loop
      if p_prtt_enrt_rslt_stat_cd = g_enrt_stat_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_stat_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_mthd_incl >---------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates enrollment method
--
Procedure chk_enrt_mthd_incl
(p_enrt_mthd_cd in ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_mthd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
if p_enrt_mthd_cd is null then
   raise g_include;
end if;
--
    for i in 1..g_enrt_mthd_list.count
    loop
      if p_enrt_mthd_cd = g_enrt_mthd_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_mthd_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_pgm_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates pgm id.
--
Procedure chk_enrt_pgm_incl
(p_pgm_id        in  ben_prtt_enrt_rslt_f.pgm_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_pgm_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_pgm_list.count
    loop
      if p_pgm_id = g_enrt_pgm_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_pgm_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_pl_typ_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates pl_typ id.
--
Procedure chk_enrt_pl_typ_incl
(p_pl_typ_id      in  ben_prtt_enrt_rslt_f.pl_typ_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_pl_typ_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_pl_typ_list.count
    loop
      if p_pl_typ_id = g_enrt_pl_typ_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_pl_typ_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_last_upd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates enrt_last_upd_dt id.
--
Procedure chk_enrt_last_upd_dt_incl
(p_last_update_date in  ben_prtt_enrt_rslt_f.last_update_date%type,
 p_effective_date   in  date,
 p_excld_flag       in varchar2 ,
 p_pl_id            in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_last_upd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_last_upd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_last_upd_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id ,
                      p_pl_id      => p_pl_id );

      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_last_upd_dt_list2(i),
                      p_abs_date    => p_effective_date,
                      p_ext_dfn_id  => ben_extract.g_ext_dfn_id ,
                      p_pl_id       => p_pl_id );

      if p_last_update_date between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_last_upd_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_ler_name_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates ler_name id.
--
Procedure chk_enrt_ler_name_incl
(p_ler_id        in  ben_per_in_ler.ler_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_ler_name_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_ler_name_list.count
    loop
      if p_ler_id = g_enrt_ler_name_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_ler_name_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_ler_stat_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates per in ler status cd
--
Procedure chk_enrt_ler_stat_incl
(p_per_in_ler_stat_cd in  ben_per_in_ler.per_in_ler_stat_cd%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_ler_stat_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_ler_stat_list.count
    loop
      if p_per_in_ler_stat_cd = g_enrt_ler_stat_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_ler_stat_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_ler_ocrd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates enrt_ler_ocrd_dt id.
--
Procedure chk_enrt_ler_ocrd_dt_incl
(p_lf_evt_ocrd_dt    in  ben_per_in_ler.lf_evt_ocrd_dt%type,
 p_effective_date    in  date,
 p_excld_flag        in varchar2,
 p_pl_id             in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_ler_ocrd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_ler_ocrd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_ler_ocrd_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id ,
                      p_pl_id      => p_pl_id );
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_ler_ocrd_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id,
                      p_pl_id      => p_pl_id );
      if p_lf_evt_ocrd_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_ler_ocrd_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_ler_ntfn_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates enrt_ler_ntfn_dt id.
--
Procedure chk_enrt_ler_ntfn_dt_incl
(p_ntfn_dt        in  ben_per_in_ler.ntfn_dt%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2,
 p_pl_id          in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_ler_ntfn_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_ler_ntfn_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_ler_ntfn_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_enrt_ler_ntfn_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id ,
                      p_pl_id      => p_pl_id );
      if p_ntfn_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_ler_ntfn_dt_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_enrt_dpnt_rltn_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates the relationships between enrtollment
-- dependent
--
Procedure   chk_enrt_dpnt_rltn_incl
      (p_per_in_ler_id     in ben_prtt_enrt_rslt_f.per_in_ler_id%type,
       p_prtt_enrt_rslt_id in ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
       p_dpnt_person_id    in number,
       p_effective_date    in date,
       p_excld_flag        in varchar2) is

  l_proc      varchar2(72);
  l_dummy  varchar2(1);


begin
  if g_debug then
    l_proc := g_package||'chk_enrt_dpnt_rltn_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;

  --link the entrolled dependent with change even dependent
  if p_dpnt_person_id = nvl(ben_ext_person.g_chg_prmtr_06,'-1') then
     if p_excld_flag = 'N' then
        raise g_include;
     else
        raise g_not_include;
     end if;
  end if;

  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_dpnt_rltn_incl;





-----------------------------------------------------------------------------
---------------------------< chk_enrt_rltn_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates the relationships between enrtollment
-- results and other tables.
--
Procedure chk_enrt_rltn_incl
(p_per_in_ler_id in  ben_prtt_enrt_rslt_f.per_in_ler_id%type,
 p_prtt_enrt_rslt_id  in  ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
 p_pl_id in ben_prtt_enrt_rslt_f.pl_id%type,
 p_pl_typ_id in ben_prtt_enrt_rslt_f.pl_typ_id%type,
 p_pgm_id in ben_prtt_enrt_rslt_f.pgm_id%type,
 p_effective_date in date,
 p_excld_flag     in varchar2)
is
--
cursor c_cm_usg (p_per_cm_id number,
                 p_pl_id number,
                 p_pl_typ_id number,
                 p_pgm_id number) is
  select null
  from ben_per_cm_usg_f pcu,
       ben_cm_typ_usg_f ctu
  where pcu.per_cm_id = p_per_cm_id
  and   pcu.cm_typ_usg_id = ctu.cm_typ_usg_id
  and   nvl(ctu.pl_id,p_pl_id) = p_pl_id
  and   nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id
  and   nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id
  and   p_effective_date between pcu.effective_start_date and pcu.effective_end_date
  and   p_effective_date between ctu.effective_start_date and ctu.effective_end_date;
--
  l_proc      varchar2(72);
  l_dummy  varchar2(1);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_enrt_rltn_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_enrt_rltn_list.count
    loop
      if g_enrt_rltn_list(i) = 'EERCEP' then
        if ben_ext_person.g_chg_enrt_rslt_id is null then
          raise g_include;
        end if;
        if p_prtt_enrt_rslt_id = ben_ext_person.g_chg_enrt_rslt_id then
          if p_excld_flag = 'N' then
            raise g_include;
          else
            raise g_not_include;
          end if;
        end if;
      elsif g_enrt_rltn_list(i) = 'EERCMP' then
        if ben_ext_person.g_cm_per_in_ler_id is null then
          raise g_include;
        end if;
        if p_per_in_ler_id = ben_ext_person.g_cm_per_in_ler_id then
          if p_excld_flag = 'N' then
            raise g_include;
          else
            raise g_not_include;
          end if;
        end if;
      -- Enrt Rslt Comp Object must match that the communication usage.
      elsif g_enrt_rltn_list(i) = 'EERCMU' then
        open c_cm_usg (ben_ext_person.g_per_cm_id, p_pl_id, p_pl_typ_id, p_pgm_id);
        fetch c_cm_usg into l_dummy;
        if c_cm_usg%found then
          if p_excld_flag = 'N' then
            close c_cm_usg;
            raise g_include;
          else
            close c_cm_usg;
            raise g_not_include;
          end if;
        end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_enrt_rltn_incl;
--

-----------------------------------------------------------------------------
---------------------------< chk_elct_opt_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_elct_opt_incl
(p_opt_id          in  ben_opt_f.opt_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_opt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_pl_id is null then error, it must be passed in!
--
    for i in 1..g_elct_opt_list.count
    loop
     if g_debug then
        hr_utility.set_location(' option id '|| p_opt_id || ':'||g_elct_opt_list(i), 5);
     end if;

      if p_opt_id = g_elct_opt_list(i) then
         if p_excld_flag = 'N' then
            hr_utility.set_location(' rise incl  ', 5);
           raise g_include;
         else
            hr_utility.set_location(' rise excl  ', 5);
          raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
      if g_debug then
        hr_utility.set_location(' option id include ', 5);
     end if;

    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_opt_incl;
--



--
-----------------------------------------------------------------------------
---------------------------< chk_elct_plan_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_elct_plan_incl
(p_pl_id          in  ben_elig_per_elctbl_chc.pl_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_plan_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_pl_id is null then error, it must be passed in!
--
    for i in 1..g_elct_plan_list.count
    loop
      if p_pl_id = g_elct_plan_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_plan_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_rg_plan_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plans of a particular reporting group id.
--
Procedure chk_elct_rg_plan_incl
(p_pl_id          in  ben_elig_per_elctbl_chc.pl_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_rg_plan_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_pl_id is null then error, it must be passed in!
--
    for i in 1..g_elct_rg_plan_list.count
    loop
      if p_pl_id = g_elct_rg_plan_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_rg_plan_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_enrt_strt_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates elct_enrt_strt_dt id.
--
Procedure chk_elct_enrt_strt_dt_incl
(p_elct_enrt_strt_dt  in  ben_elig_per_elctbl_chc.enrt_cvg_strt_dt%type,
 p_effective_date     in  date,
 p_excld_flag         in varchar2 ,
 p_pl_id              in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date  date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_enrt_strt_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_enrt_strt_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_enrt_strt_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id,
                      p_pl_id      => p_pl_id );
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_enrt_strt_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id ,
                      p_pl_id      => p_pl_id );
      if p_elct_enrt_strt_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_enrt_strt_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_pgm_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates pgm id.
--
Procedure chk_elct_pgm_incl
(p_pgm_id         in ben_elig_per_elctbl_chc.pgm_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_pgm_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_pgm_list.count
    loop
      if p_pgm_id = g_elct_pgm_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_pgm_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_pl_typ_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates pl_typ id.
--
Procedure chk_elct_pl_typ_incl
(p_pl_typ_id      in ben_elig_per_elctbl_chc.pl_typ_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_pl_typ_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_pl_typ_list.count
    loop
      if p_pl_typ_id = g_elct_pl_typ_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_pl_typ_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_last_upd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates elct_last_upd_dt id.
--
Procedure chk_elct_last_upd_dt_incl
(p_last_update_date   in ben_elig_per_elctbl_chc.last_update_date%type,
 p_effective_date     in date,
 p_excld_flag         in varchar2,
 p_pl_id              in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_last_upd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_last_upd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_last_upd_dt_list1(i),
                      p_abs_date    => p_effective_date,
                      p_ext_dfn_id  => ben_extract.g_ext_dfn_id,
                      p_pl_id       => p_pl_id  );
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_last_upd_dt_list2(i),
                      p_abs_date    => p_effective_date,
                      p_ext_dfn_id  => ben_extract.g_ext_dfn_id ,
                      p_pl_id       => p_pl_id );
      if p_last_update_date between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_last_upd_dt_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_ler_name_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates ler_name id.
--
Procedure chk_elct_ler_name_incl
(p_ler_id         in ben_per_in_ler.ler_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_ler_name_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_ler_name_list.count
    loop
      if p_ler_id = g_elct_ler_name_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_ler_name_incl;

--
-----------------------------------------------------------------------------
---------------------------< chk_elct_ler_stat_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates per in ler status cd
--
Procedure chk_elct_ler_stat_incl
(p_per_in_ler_stat_cd in ben_per_in_ler.per_in_ler_stat_cd%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_ler_stat_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_ler_stat_list.count
    loop
      if p_per_in_ler_stat_cd = g_elct_ler_stat_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_ler_stat_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_yrprd_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates year period
--
Procedure chk_elct_yrprd_incl
(p_yrprd_id           in ben_elig_per_elctbl_chc.yr_perd_id%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_yrprd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_yrprd_list.count
    loop
      if p_yrprd_id = g_elct_yrprd_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_yrprd_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_ler_ocrd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates elct_ler_ocrd_dt id.
--
Procedure chk_elct_ler_ocrd_dt_incl
(p_lf_evt_ocrd_dt    in  ben_per_in_ler.lf_evt_ocrd_dt%type,
 p_effective_date     in  date,
 p_excld_flag     in varchar2,
 p_pl_id          in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_ler_ocrd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_ler_ocrd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_ler_ocrd_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id,
                      p_pl_id      => p_pl_id );
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_ler_ocrd_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id,
                      p_pl_id      => p_pl_id );
      if p_lf_evt_ocrd_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_ler_ocrd_dt_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_ler_ntfn_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates elct_ler_ntfn_dt id.
--
Procedure chk_elct_ler_ntfn_dt_incl
(p_ntfn_dt        in  ben_per_in_ler.ntfn_dt%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2 ,
 p_pl_id          in number default null )
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_ler_ntfn_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_ler_ntfn_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_ler_ntfn_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id ,
                      p_pl_id      => p_pl_id );
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_elct_ler_ntfn_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id ,
                      p_pl_id      => p_pl_id );
      if p_ntfn_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_ler_ntfn_dt_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_elct_rltn_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates the relationships between enrtollment
-- results and other tables.
--
Procedure chk_elct_rltn_incl
(p_per_in_ler_id in  ben_prtt_enrt_rslt_f.per_in_ler_id%type,
 p_prtt_enrt_rslt_id  in  ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_elct_rltn_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_elct_rltn_list.count
    loop
      if g_elct_rltn_list(i) = 'EECCMP' then
        if ben_ext_person.g_cm_per_in_ler_id is null then
          raise g_include;
        end if;
        if p_per_in_ler_id = ben_ext_person.g_cm_per_in_ler_id then
          if p_excld_flag = 'N' then
            raise g_include;
          else
            raise g_not_include;
          end if;
        end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_elct_rltn_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_chg_evt_cd_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates change event code
--
Procedure chk_chg_evt_cd_incl
(p_chg_evt_cd     in ben_ext_chg_evt_log.chg_evt_cd%type,
 p_chg_evt_source in ben_ext_chg_evt_log.chg_evt_cd%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_chg_evt_cd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  if p_chg_evt_source is null or p_chg_evt_source = 'BEN' then
    for i in 1..g_chg_evt_list.count
    loop
      if p_chg_evt_cd = g_chg_evt_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  end if ;

  if p_chg_evt_source = 'PAY' then
     for i in 1..g_chg_pay_evt_list.count
     loop
       if p_chg_evt_cd = g_chg_pay_evt_list(i) then
          if p_excld_flag = 'N' then
            raise g_include;
          else
            raise g_not_include;
          end if;
       end if;
     end loop;

  end if ;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_chg_evt_cd_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_chg_eff_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates chg_eff_dt.
--
Procedure chk_chg_eff_dt_incl
(p_chg_eff_dt  in  ben_ext_chg_evt_log.chg_eff_dt%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_chg_eff_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_chg_eff_dt_list1.count
    loop
      --- if the concurrent manager param is passed in then use that
      if ben_ext_thread.g_effective_start_date is not null then
         l_low_date  := ben_ext_thread.g_effective_start_date ;
         l_high_date := ben_ext_thread.g_effective_end_date ;
         hr_utility.set_location( ' param chg eff date ' || l_low_date || '  /' || l_high_date, 99 );
      else
          l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_chg_eff_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
          l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_chg_eff_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      end if ;
      ---
      if p_chg_eff_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_chg_eff_dt_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_chg_actl_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates chg_actl_dt.
--
Procedure chk_chg_actl_dt_incl
(p_chg_actl_dt  in  ben_ext_chg_evt_log.chg_actl_dt%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_chg_actl_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_chg_actl_dt_list1.count
    loop
      --- when the date passed from param use the param date
      if ben_ext_thread.g_actual_start_date is not null then
         l_low_date  := ben_ext_thread.g_actual_start_date ;
         l_high_date := ben_ext_thread.g_actual_end_date ;
         hr_utility.set_location( ' param chg act  date ' || l_low_date || '  /' || l_high_date, 99 );
      else
         l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_chg_actl_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
         l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_chg_actl_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      end if ;
      if p_chg_actl_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_chg_actl_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_chg_login_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates change last_updated_login
--
Procedure chk_chg_login_incl
(p_last_update_login in ben_ext_chg_evt_log.last_update_login%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_chg_login_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_chg_login_list.count
    loop
      if p_last_update_login = g_chg_login_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_chg_login_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_cm_typ_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates communication type
--
Procedure chk_cm_typ_incl
(p_cm_typ_id in ben_per_cm_f.cm_typ_id%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cm_typ_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_cm_typ_list.count
    loop
      if p_cm_typ_id = g_cm_typ_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cm_typ_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_cm_last_upd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates cm_last_upd_dt.
--
Procedure chk_cm_last_upd_dt_incl
(p_last_update_date in  ben_per_cm_f.last_update_date%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cm_last_upd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_cm_last_upd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_last_upd_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_last_upd_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      if p_last_update_date between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cm_last_upd_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_cm_pr_last_upd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates cm_pr_last_upd_dt.
--
Procedure chk_cm_pr_last_upd_dt_incl
(p_pvdd_last_update_date  in  ben_per_cm_prvdd_f.last_update_date%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cm_pr_last_upd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_cm_pr_last_upd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_pr_last_upd_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_pr_last_upd_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      if p_pvdd_last_update_date between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cm_pr_last_upd_dt_incl;

-----------------------------------------------------------------------------
---------------------------< chk_payroll_end_date_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates chk_payroll_end_date_incl;.
-- payrill payperiod end date
--
Procedure chk_payroll_end_date_incl
(p_pay_end_date  in  pay_payroll_actions.effective_date%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_payroll_end_date_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_payroll_last_dt_list1.count
    loop

      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_payroll_last_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);

      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_payroll_last_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
       if g_debug then
         hr_utility.set_location(' hight date '||  l_high_date,51);
         hr_utility.set_location(' low  date ' ||  l_low_date,51);
       end if;

      if p_pay_end_date between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           if g_debug then
             hr_utility.set_location('Y Exiting:'||l_proc, 51);
           end if;
           raise g_include;
         else
           if g_debug then
             hr_utility.set_location('N Exiting:'||l_proc, 51);
           end if;
           raise g_not_include;
         end if;
      end if;
    end loop;
---
  if p_excld_flag = 'Y' then
      if g_debug then
        hr_utility.set_location('Y Exiting:'||l_proc, 15);
      end if;
      raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Y  Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_payroll_end_date_incl;




-----------------------------------------------------------------------------
---------------------------< chk_prem_last_upd_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates cm_pr_last_upd_dt.
-- premuim last updated date
--
Procedure chk_prem_last_upd_dt_incl
(p_last_update_date  in  ben_prtt_prem_by_mo_f.last_update_date%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_prem_last_upd_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_prem_last_upd_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_prem_last_upd_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_prem_last_upd_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
       if g_debug then
         hr_utility.set_location(' hight date '||  l_high_date,16);
         hr_utility.set_location(' low  date ' ||  l_low_date,16);
         hr_utility.set_location(' update dte '||  p_last_update_date,16);
       end if;
      if p_last_update_date between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           if g_debug then
             hr_utility.set_location('Y Exiting:'||l_proc, 15);
           end if;
           raise g_include;
         else
           if g_debug then
             hr_utility.set_location('N Exiting:'||l_proc, 15);
           end if;
           raise g_not_include;
         end if;
      end if;
    end loop;
---
  if p_excld_flag = 'Y' then
    if g_debug then
      hr_utility.set_location('Y Exiting:'||l_proc, 15);
    end if;
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Y  Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_prem_last_upd_dt_incl;


-----------------------------------------------------------------------------
---------------------------< chk_prem_month_year_no_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates chk_prem_month_year_no_incl.
-- premuim month No and year no
--
Procedure chk_prem_month_year_no_incl
(p_mo_num  in  ben_prtt_prem_by_mo_f.mo_num%type default null,
 p_yr_num  in  ben_prtt_prem_by_mo_f.yr_num%type default null,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
  l_low_mo_no  number ;
  l_high_mo_no number ;
  l_low_yr_no  number ;
  l_high_yr_no number ;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_prem_month_year_no_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_prem_month_year_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_prem_month_year_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_prem_month_year_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      ---converting to month no and year no
      l_low_mo_no :=  to_number(to_char(l_low_date,'MM')) ;
      l_low_yr_no :=  to_number(to_char(l_low_date,'RRRR')) ;

      l_high_mo_no :=  to_number(to_char(l_high_date,'MM')) ;
      l_high_yr_no :=  to_number(to_char(l_high_date,'RRRR')) ;

      if g_debug then
        hr_utility.set_location(' hight month ' || l_low_mo_no  ,161);
        hr_utility.set_location(' low  month '  || l_high_mo_no,161);
        hr_utility.set_location(' hight year '  || l_low_yr_no  ,161);
        hr_utility.set_location(' low  year '   || l_high_yr_no,161);
        hr_utility.set_location(' month '       || p_mo_num,161);
        hr_utility.set_location(' year '        || p_yr_num,161);
      end if;
      ---validate month   year no
      if p_mo_num between l_low_mo_no and nvl(l_high_mo_no,l_low_mo_no) and
         p_yr_num between l_low_yr_no and nvl(l_high_yr_no,l_low_yr_no)  then
          if p_excld_flag = 'N' then
             raise g_include;
          else
            raise g_not_include;
          end if;
      end if ;

    end loop;
  ---
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_prem_month_year_no_incl;


--
-----------------------------------------------------------------------------
---------------------------< chk_cm_sent_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates cm_sent_dt.
--
Procedure chk_cm_sent_dt_incl
(p_sent_dt  in  ben_per_cm_prvdd_f.sent_dt%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cm_sent_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_cm_sent_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_sent_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_sent_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      if p_sent_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cm_sent_dt_incl;
--
-----------------------------------------------------------------------------
---------------------------< chk_cm_to_be_sent_dt_incl >----------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates cm_to_be_sent_dt.
--
Procedure chk_cm_to_be_sent_dt_incl
(p_to_be_sent_dt  in  ben_per_cm_prvdd_f.to_be_sent_dt%type,
 p_effective_date in  date,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
  l_low_date date;
  l_high_date date;
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cm_to_be_sent_dt_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_cm_to_be_sent_dt_list1.count
    loop
      l_low_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_to_be_sent_dt_list1(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      l_high_date := ben_ext_util.calc_ext_date
                     (p_ext_date_cd => g_cm_to_be_sent_dt_list2(i),
                      p_abs_date => p_effective_date,
                      p_ext_dfn_id => ben_extract.g_ext_dfn_id);
      if p_to_be_sent_dt between l_low_date and nvl(l_high_date,l_low_date) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cm_to_be_sent_dt_incl;
--
--
-----------------------------------------------------------------------------
---------------------------< chk_actn_name_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates communication type
--
Procedure chk_actn_name_incl
(p_actn_typ_id in ben_prtt_enrt_actn_f.actn_typ_id%type,
 p_excld_flag         in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_actn_name_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_actn_name_list.count
    loop
      if p_actn_typ_id = g_actn_name_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_actn_name_incl;
--
-----------------------------------------------------------------------------
-----------------------< chk_actn_item_rltn_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates the relationships between communications
-- and prtt action items.
--
Procedure chk_actn_item_rltn_incl
(p_prtt_enrt_actn_id   in ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type,
 p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_actn_item_rltn_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_actn_item_rltn_list.count
    loop
      if g_actn_item_rltn_list(i) = 'EAICMP' then
        if ben_ext_person.g_cm_prtt_enrt_actn_id is null then
          raise g_include;
        end if;
        if p_prtt_enrt_actn_id = ben_ext_person.g_cm_prtt_enrt_actn_id then
          if p_excld_flag = 'N' then
            raise g_include;
          else
            raise g_not_include;
          end if;
        end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_actn_item_rltn_incl;
--

-- Timecard (OTL) Inclusion Function



-----------------------------------------------------------------------------
---------------------------< chk_tc_status_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_tc_status_incl
(p_tc_status      in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_tc_status_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_tc_status_id is null then error, it must be passed in!
--
    for i in 1..g_tc_status_list.count
    loop
      if p_tc_status = g_tc_status_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_tc_status_incl;
--


-----------------------------------------------------------------------------
---------------------------< chk_tc_deleted_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_tc_deleted_incl
(p_tc_deleted      in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_tc_deleted_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_tc_deleted is null then error, it must be passed in!
--
    for i in 1..g_tc_deleted_list.count
    loop
      if p_tc_deleted = g_tc_deleted_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_tc_deleted_incl;
--


-----------------------------------------------------------------------------
---------------------------< chk_project_id_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_project_id_incl
(p_project_id      in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_project_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_project_id is null then error, it must be passed in!
--
    for i in 1..g_project_id_list.count
    loop
      if p_project_id = g_project_id_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_project_id_incl;
--


-----------------------------------------------------------------------------
---------------------------< chk_task_id_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_task_id_incl
(p_task_id      in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_task_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_task_id is null then error, it must be passed in!
--
    for i in 1..g_task_id_list.count
    loop
      if p_task_id = g_task_id_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_task_id_incl;
--


-----------------------------------------------------------------------------
---------------------------< chk_exp_typ_id_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_exp_typ_id_incl
(p_exp_typ_id      in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_exp_typ_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_exp_typ_id is null then error, it must be passed in!
--
    for i in 1..g_exp_typ_id_list.count
    loop
      if p_exp_typ_id = g_exp_typ_id_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_exp_typ_id_incl;
--


-----------------------------------------------------------------------------
---------------------------< chk_element_type_id_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_element_type_id_incl
(p_element_type_id      in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_element_type_id_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_element_type_id is null then error, it must be passed in!
--
    for i in 1..g_element_type_list.count
    loop
      if p_element_type_id = g_element_type_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_element_type_id_incl;
--


-----------------------------------------------------------------------------
---------------------------< chk_po_num_incl >----------------------------
-----------------------------------------------------------------------------
-- The following procedure evaluates plan id.
--
Procedure chk_po_num_incl
(p_po_num         in  VARCHAR2
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_po_num_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
-- if p_po_num is null then error, it must be passed in!
--
    for i in 1..g_po_num_list.count
    loop
      if p_po_num = g_po_num_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_po_num_incl;
-- cwb

Procedure chk_cwb_pl_prd_incl
(p_pl_id           in  number ,
 p_LF_EVT_OCRD_DT  in  date   ,
 p_effective_date  in date,
 p_excld_flag in varchar2)
is
--
  cursor c1 (l_val  number)   is
  SELECT enp.ASND_LF_EVT_DT
  FROM   ben_enrt_perd enp
  WHERE  enp.enrt_perd_id  = l_val
  ;
--
  l_ASND_LF_EVT_DT  date ;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_cwb_pl_prd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
 for i in 1..g_cwb_pl_list.count
 loop
    if p_pl_id  = g_cwb_pl_list(i) then
       open c1 (to_number(g_cwb_prd_list(i)))  ;
       fetch c1 into l_ASND_LF_EVT_DT  ;
       close c1 ;
       if l_ASND_LF_EVT_DT = p_LF_EVT_OCRD_DT  then
          if p_excld_flag = 'N' then
             raise g_include;
          else
            raise g_not_include;
          end if;
       end if;
     end if ;
  end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_cwb_pl_prd_incl;





---- subheader


Procedure chk_subhead_pos_incl
(p_position_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_pos_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
-- if p_position_id is null then error, it must be passed in!
--
    for i in 1..g_subhead_pos_list.count
    loop
      if p_position_id = g_subhead_pos_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_pos_incl;
--

Procedure chk_subhead_job_incl
(p_job_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_job_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
  for i in 1..g_subhead_job_list.count
    loop
      if p_job_id = g_subhead_job_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_job_incl;



Procedure chk_subhead_loc_incl
(p_location_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_loc_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
  for i in 1..g_subhead_loc_list.count
    loop
      if p_location_id = g_subhead_loc_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_loc_incl;


Procedure chk_subhead_pay_incl
(p_payroll_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_pay_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
  for i in 1..g_subhead_pay_list.count
    loop
      if p_payroll_id = g_subhead_pay_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_pay_incl;


Procedure chk_subhead_org_incl
(p_organization_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_org_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
  for i in 1..g_subhead_org_list.count
    loop
      if p_organization_id = g_subhead_org_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_org_incl;


Procedure chk_subhead_bg_incl
(p_business_group_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_bg_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
  for i in 1..g_subhead_bg_list.count
    loop
      if p_business_group_id = g_subhead_bg_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_bg_incl;


Procedure chk_subhead_grd_incl
(p_grade_id    in  number
,p_excld_flag     in varchar2)
is
--
  l_proc      varchar2(72);
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_grd_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    for i in 1..g_subhead_grd_list.count
    loop
      if p_grade_id = g_subhead_grd_list(i) then
         if p_excld_flag = 'N' then
           raise g_include;
         else
           raise g_not_include;
         end if;
      end if;
    end loop;
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
  raise g_not_include;
--
Exception
  when g_include then
    null;
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
End chk_subhead_grd_incl;


--------------------------------- chck_subhead_rule_incl ----------------------

Procedure chk_subhead_rule_incl
(p_business_group_id  in  number ,
 p_effective_date in  date,
 p_excld_flag     in varchar2,
 p_param_1        in varchar2 ,
 p_param_val_1     in varchar2 ,
 p_param_2        in varchar2 ,
 p_param_val_2     in varchar2
)
is
--
  l_outputs  ff_exec.outputs_t;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_subhead_rule_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
    hr_utility.set_location( p_param_2 || ' ' || p_param_val_2 , 5);
    for i in 1..g_subhead_rule_list.count
    loop

      hr_utility.set_location( 'formula id   ' || g_subhead_rule_list(i) , 5);
      l_outputs := benutils.formula
                   (p_formula_id => g_subhead_rule_list(i)
                    ,p_effective_date => p_effective_date
                    ,p_business_group_id => p_business_group_id
                    ,p_param1             => 'EXT_DFN_ID'
                    ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                    ,p_param2             => 'EXT_RSLT_ID'
                    ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                    ,p_param3             => p_param_1
                    ,p_param3_value       => p_param_val_1
                    ,p_param4             => p_param_2
                    ,p_param4_value       => p_param_val_2
                    ,p_param5             => 'EXT_PROCESS_BUSINESS_GROUP'
                    ,p_param5_value       =>  to_char(ben_extract.g_proc_business_group_id)
                   );
    hr_utility.set_location(' out of rl :'||l_outputs(l_outputs.first).value , 5);
    if l_outputs(l_outputs.first).value = 'Y' then
        if p_excld_flag = 'N' then
          raise g_include;
        else
          raise g_not_include;
        end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_subhead_rule_incl;
--


--------------------------------- chck_payroll_rule_incl ----------------------

Procedure chk_payroll_rule_incl
(p_business_group_id    in  number ,
 p_person_id            in  number ,
 p_effective_date       in  date,
 p_excld_flag           in varchar2,
 p_input_value_id       in number ,
 p_processing_type      in varchar2 ,
 p_element_type_id      in number ,
 p_source_id            in number ,
 p_source_type          in varchar2 ,
 p_element_entry_id     in number
)
is
--
  cursor c_asg is
  SELECT asg.assignment_id, asg.business_group_id
  FROM   per_all_assignments_f asg
  WHERE  asg.person_id = p_person_id
   and   asg.assignment_id = ben_ext_person.g_assignment_id   --1969853
  AND    asg.primary_flag = 'Y'
  AND    p_effective_date between asg.effective_start_date
         and asg.effective_end_date;
--
  l_asg      c_asg%rowtype;

  l_outputs  ff_exec.outputs_t;
--
  l_proc    varchar2(72);
--
Begin
--
  if g_debug then
    l_proc := g_package||'chk_payroll_rule_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;

 --
  open c_asg;
  fetch c_asg into l_asg;
  close c_asg;
--

--
    for i in 1..g_payroll_rl_list.count
    loop


      hr_utility.set_location( 'formula id   ' || g_payroll_rl_list(i) , 5);
      hr_utility.set_location( 'asg  id   ' || l_asg.assignment_id , 5);
      hr_utility.set_location( 'bg  id   ' || p_business_group_id , 5);

      l_outputs := benutils.formula
                   (p_formula_id => g_payroll_rl_list(i)
                    ,p_effective_date     => p_effective_date
                    ,p_assignment_id      => l_asg.assignment_id
                    ,p_business_group_id  => p_business_group_id
                    ,p_param1             => 'EXT_DFN_ID'
                    ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                    ,p_param2             => 'EXT_RSLT_ID'
                    ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                    ,p_param3             => 'EXT_PAY_INPUT_VALUE'
                    ,p_param3_value       => to_char(p_input_value_id)
                    ,p_param4             => 'EXT_PAY_PROCESSING_TYPE'
                    ,p_param4_value       => p_processing_type
                    ,p_param5             => 'EXT_PAY_ELEMENT_TYPE'
                    ,p_param5_value       => to_char(p_element_type_id)
                    ,p_param6             => 'EXT_PAY_ENTRY_SOURCE'
                    ,p_param6_value       => to_char(p_source_id)
                    ,p_param7             => 'EXT_PAY_ENTRY_SOURCE_TYPE'
                    ,p_param7_value       => p_source_type
                    ,p_param8             => 'EXT_PAY_ELEMENT_ENTRY'
                    ,p_param8_value       => to_char(p_element_entry_id )
                    ,p_param9             => 'EXT_PROCESS_BUSINESS_GROUP'
                    ,p_param9_value       =>  to_char(ben_extract.g_proc_business_group_id)
                   );
    hr_utility.set_location(' out of rl :'||l_outputs(l_outputs.first).value , 5);
    if l_outputs(l_outputs.first).value = 'Y' then
        if p_excld_flag = 'N' then
          raise g_include;
        else
          raise g_not_include;
        end if;
      end if;
    end loop;
--
  if p_excld_flag = 'Y' then
    raise g_include;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
--
  raise g_not_include;
--
Exception
--
  when g_include then
    null;
--
  when g_not_include then
    raise g_not_include; --- will be handled in the calling program
--
End chk_payroll_rule_incl;
--


--
-----------------------------------------------------------------------------
---------------------------< evaluate_person_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates person inclusion criteria
--
Procedure evaluate_person_incl
(p_person_id       in per_all_people_f.person_id%type,
 p_postal_code     in per_addresses.postal_code%type default null,
 p_org_id          in per_all_assignments_f.organization_id%type default null,
 p_loc_id          in per_all_assignments_f.location_id%type default null,
 p_gre             in hr_soft_coding_keyflex.segment1%type default null,
 p_state           in per_addresses.region_2%type default null,
 p_bnft_grp        in per_all_people_f.benefit_group_id%type default null,
 p_ee_status       in per_all_assignments_f.assignment_status_type_id%type default null,
 p_payroll_id      in per_all_assignments_f.payroll_id%type default null,
 p_chg_evt_cd      in varchar2 default null,
 p_chg_evt_source  in varchar2 default null,
 p_effective_date  in date,
 --RCHASE
 p_eff_date        in date default null,
 --End RCHASE
 p_actl_date       in date,
 p_include         out nocopy varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_person_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_person_id_incl_rqd = 'Y' then
    Chk_Person_Id_Incl
      (p_person_id,
       g_person_id_excld_flag);
  end if;
  if g_postal_code_incl_rqd = 'Y' then
    Chk_Postal_Code_Incl
      (p_person_id,
       p_postal_code,
       p_effective_date,
       g_postal_code_excld_flag);
  end if;
  if g_org_id_incl_rqd = 'Y' then
    Chk_Org_Id_Incl
      (p_person_id,
       p_org_id,
       p_effective_date,
       g_org_id_excld_flag);
  end if;
  if g_loc_id_incl_rqd = 'Y' then
    Chk_Loc_Id_Incl
      (p_person_id,
       p_loc_id,
       p_effective_date,
       g_loc_id_excld_flag);
  end if;
  if g_gre_incl_rqd = 'Y' then
    Chk_Gre_Incl
      (p_person_id,
       p_gre,
       p_effective_date,
       g_gre_excld_flag);
  end if;
  if g_state_incl_rqd = 'Y' then
    Chk_State_Incl
      (p_person_id,
       p_state,
       p_effective_date,
       g_state_excld_flag);
  end if;
  if g_bnft_grp_incl_rqd = 'Y' then
    Chk_bnft_grp_Incl
      (p_person_id,
       p_bnft_grp,
       p_effective_date,
       g_bnft_grp_excld_flag);
  end if;
  if g_ee_status_incl_rqd = 'Y' then
    Chk_Ee_Status_Incl
      (p_person_id,
       p_ee_status,
       p_effective_date,
       g_ee_status_excld_flag);
  end if;
  if g_payroll_id_incl_rqd = 'Y' then
    Chk_payroll_id_Incl
      (p_person_id,
       p_payroll_id,
       p_effective_date,
       g_payroll_id_excld_flag);
  end if;
  if g_person_rule_incl_rqd = 'Y' then
    Chk_Person_Rule_Incl
      (p_person_id,
       p_effective_date,
       g_person_rule_excld_flag);
  end if;
  if g_per_ler_incl_rqd = 'Y' then
    Chk_Per_Ler_Incl
      (p_person_id,
       p_effective_date,
       g_per_ler_excld_flag);
  end if;
  if g_person_type_incl_rqd = 'Y' then
    Chk_Person_Type_Incl
      (p_person_id,
       p_effective_date,
       g_person_type_excld_flag);
  end if;
--
 /* if g_per_plan_incl_rqd = 'Y'
     and p_chg_evt_cd is null then
    Evaluate_Per_Plan_Incl
    (p_person_id => p_person_id,
     p_effective_date  => p_effective_date,
     p_excld_flag => g_per_plan_excld_flag);
  end if; */
--
 /* if g_rptg_grp_incl_rqd = 'Y'
     and p_chg_evt_cd is null then
    Evaluate_Per_Rptg_Grp_Incl
    (p_person_id => p_person_id,
     p_effective_date  => p_effective_date,
     p_excld_flag => g_rptg_grp_excld_flag);
  end if; */
--
 /* if g_ele_input_incl_rqd = 'Y' then
    Evaluate_Per_Elm_Entry_Incl
    (p_person_id => p_person_id,
     p_effective_date  => p_effective_date,
     p_excld_flag => g_ele_input_excld_flag);
  end if; */
--
  if g_cmbn_incl_rqd = 'Y'  /*and p_chg_evt_cd is not null */  then
    Chk_Cmbn_Incl
    (p_person_id   => p_person_id,
     p_chg_evt_cd  => p_chg_evt_cd,
     p_chg_evt_source => p_chg_evt_source,
     --RCHASE
     p_effective_date => nvl(p_eff_date,p_effective_date), -- p_effective_date
     --End RCHASE
     p_actl_date => p_actl_date);
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End Evaluate_Person_Incl;
--
-----------------------------------------------------------------------------
---------------------------< evaluate_benefit_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates person inclusion criteria
--
Procedure evaluate_benefit_incl
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
 p_ntfn_dt          in ben_per_in_ler.ntfn_dt%type default null,
 p_lf_evt_ocrd_dt   in ben_per_in_ler.lf_evt_ocrd_dt%type default null,
 p_per_in_ler_stat_cd in ben_per_in_ler.per_in_ler_stat_cd%type default null,
 p_per_in_ler_id    in ben_per_in_ler.per_in_ler_id%type default null,
 p_prtt_enrt_rslt_id in ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type default null,
 p_effective_date   in date default null,
 p_dpnt_id          in number default null,
 p_include          out nocopy varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_benefit_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_enrt_plan_incl_rqd = 'Y' then
    chk_enrt_plan_incl
      (p_pl_id            => p_pl_id,
       p_excld_flag       => g_enrt_plan_excld_flag);
  end if;
  if g_enrt_opt_incl_rqd = 'Y' then
    chk_enrt_opt_incl
      (p_opt_id            => p_opt_id,
       p_excld_flag       => g_enrt_opt_excld_flag);
  end if;

  if g_enrt_rg_plan_incl_rqd = 'Y' then
    chk_enrt_rg_plan_incl
      (p_pl_id            => p_pl_id,
       p_excld_flag       => g_enrt_rg_plan_excld_flag);
  end if;
  if g_enrt_sspndd_incl_rqd = 'Y' then
    chk_enrt_sspndd_incl
      (p_sspndd_flag      => p_sspndd_flag,
       p_excld_flag       => g_enrt_sspndd_excld_flag);
  end if;
  if g_enrt_cvg_strt_dt_incl_rqd = 'Y' then
    chk_enrt_cvg_strt_dt_incl
      (p_enrt_cvg_strt_dt => p_enrt_cvg_strt_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_enrt_cvg_strt_dt_excld_flag,
       p_pl_id            => p_pl_id );
  end if;
  if g_enrt_cvg_drng_perd_incl_rqd = 'Y' then
    chk_enrt_cvg_drng_perd_incl
      (p_enrt_cvg_strt_dt => p_enrt_cvg_strt_dt,
       p_enrt_cvg_thru_dt => p_enrt_cvg_thru_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_enrt_cvg_drng_prd_excld_flag,
        p_pl_id           => p_pl_id );
  end if;
  if g_enrt_stat_incl_rqd = 'Y' then
    chk_enrt_stat_incl
      (p_prtt_enrt_rslt_stat_cd => p_prtt_enrt_rslt_stat_cd,
       p_excld_flag       => g_enrt_stat_excld_flag);
  end if;
  if g_enrt_mthd_incl_rqd = 'Y' then
    chk_enrt_mthd_incl
      (p_enrt_mthd_cd     => p_enrt_mthd_cd,
       p_excld_flag       => g_enrt_mthd_excld_flag);
  end if;
  if g_enrt_pgm_incl_rqd = 'Y' then
    chk_enrt_pgm_incl
      (p_pgm_id            => p_pgm_id,
       p_excld_flag       => g_enrt_pgm_excld_flag);
  end if;
  if g_enrt_pl_typ_incl_rqd = 'Y' then
    chk_enrt_pl_typ_incl
      (p_pl_typ_id        => p_pl_typ_id,
       p_excld_flag       => g_enrt_pl_typ_excld_flag);
  end if;
  if g_enrt_last_upd_dt_incl_rqd = 'Y' then
    chk_enrt_last_upd_dt_incl
      (p_last_update_date => p_last_update_date,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_enrt_last_upd_dt_excld_flag ,
       p_pl_id            => p_pl_id );
  end if;
  if g_enrt_ler_name_incl_rqd = 'Y' then
    chk_enrt_ler_name_incl
      (p_ler_id           => p_ler_id,
       p_excld_flag       => g_enrt_ler_name_excld_flag);
  end if;
  if g_enrt_ler_stat_incl_rqd = 'Y' then
    chk_enrt_ler_stat_incl
      (p_per_in_ler_stat_cd => p_per_in_ler_stat_cd,
       p_excld_flag       => g_enrt_ler_stat_excld_flag);
  end if;
  if g_enrt_ler_ocrd_dt_incl_rqd = 'Y' then
    chk_enrt_ler_ocrd_dt_incl
      (p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_enrt_ler_ocrd_dt_excld_flag ,
       p_pl_id            => p_pl_id );
  end if;
  if g_enrt_ler_ntfn_dt_incl_rqd = 'Y' then
    chk_enrt_ler_ntfn_dt_incl
      (p_ntfn_dt          => p_ntfn_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_enrt_ler_ntfn_dt_excld_flag,
       p_pl_id           => p_pl_id );
  end if;
  if g_enrt_rltn_incl_rqd = 'Y' then
    chk_enrt_rltn_incl
      (p_per_in_ler_id    => p_per_in_ler_id,
       p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
       p_pl_id            => p_pl_id,
       p_pl_typ_id        => p_pl_typ_id,
       p_pgm_id           => p_pgm_id,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_enrt_rltn_excld_flag);
  end if;
--
 if g_enrt_dpnt_rltn_incl_rqd = 'Y'
    and p_dpnt_id is not null  then
    chk_enrt_dpnt_rltn_incl
      (p_per_in_ler_id     => p_per_in_ler_id,
       p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
       p_dpnt_person_id    => p_dpnt_id,
       p_effective_date    => p_effective_date,
       p_excld_flag        => g_enrt_dpnt_rltn_excld_flag);
  end if;

  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End Evaluate_benefit_Incl;
--
-----------------------------------------------------------------------------
---------------------------< evaluate_eligibility_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates person inclusion criteria
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
 p_elct_ler_id    in ben_per_in_ler.ler_id%type default null,
 p_elct_per_in_ler_stat_cd in ben_per_in_ler.per_in_ler_stat_cd%type default null,
 p_elct_lf_evt_ocrd_dt   in ben_per_in_ler.lf_evt_ocrd_dt%type default null,
 p_elct_ntfn_dt          in ben_per_in_ler.ntfn_dt%type default null,
 p_prtt_enrt_rslt_id in ben_elig_per_elctbl_chc.prtt_enrt_rslt_id%type default null,
 p_effective_date   in date default null,
 p_include          out nocopy varchar2)

is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_eligibility_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_elct_plan_incl_rqd = 'Y' then
    chk_elct_plan_incl
      (p_pl_id            => p_elct_pl_id,
       p_excld_flag       => g_elct_plan_excld_flag);
  end if;

  --
  if g_debug then
    hr_utility.set_location(' opt incl :'||g_elct_opt_excld_flag ||  p_elct_opt_id, 5);
  end if;

  if g_elct_opt_incl_rqd = 'Y' then
    chk_elct_opt_incl
      (p_opt_id           => p_elct_opt_id,
       p_excld_flag       => g_elct_opt_excld_flag);
  end if;
   if g_debug then
    hr_utility.set_location(' opt incl :'||g_elct_opt_incl_rqd, 6);
  end if;

  if g_elct_rg_plan_incl_rqd = 'Y' then
    chk_elct_rg_plan_incl
      (p_pl_id            => p_elct_pl_id,
       p_excld_flag       => g_elct_rg_plan_excld_flag);
  end if;
  if g_elct_enrt_strt_dt_incl_rqd = 'Y' then
    chk_elct_enrt_strt_dt_incl
      (p_elct_enrt_strt_dt => p_elct_enrt_strt_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_elct_enrt_strt_dt_excld_flag ,
       p_pl_id            => p_elct_pl_id );
  end if;
  if g_elct_pgm_incl_rqd = 'Y' then
    chk_elct_pgm_incl
      (p_pgm_id            => p_elct_pgm_id,
       p_excld_flag       => g_elct_pgm_excld_flag);
  end if;
  if g_elct_pl_typ_incl_rqd = 'Y' then
    chk_elct_pl_typ_incl
      (p_pl_typ_id        => p_elct_pl_typ_id,
       p_excld_flag       => g_elct_pl_typ_excld_flag);
  end if;
  if g_elct_last_upd_dt_incl_rqd = 'Y' then
    chk_elct_last_upd_dt_incl
      (p_last_update_date => p_elct_last_upd_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_elct_last_upd_dt_excld_flag,
       p_pl_id            => p_elct_pl_id );
  end if;
  if g_elct_ler_name_incl_rqd = 'Y' then
    chk_elct_ler_name_incl
      (p_ler_id           => p_elct_ler_id,
       p_excld_flag       => g_elct_ler_name_excld_flag);
  end if;
  if g_elct_ler_stat_incl_rqd = 'Y' then
    chk_elct_ler_stat_incl
      (p_per_in_ler_stat_cd => p_elct_per_in_ler_stat_cd,
       p_excld_flag       => g_elct_ler_stat_excld_flag);
  end if;
  if g_elct_yrprd_incl_rqd = 'Y' then
    chk_elct_yrprd_incl
      (p_yrprd_id => p_elct_yrprd_id,
       p_excld_flag       => g_elct_yrprd_excld_flag);
  end if;
  if g_elct_ler_ocrd_dt_incl_rqd = 'Y' then
    chk_elct_ler_ocrd_dt_incl
      (p_lf_evt_ocrd_dt   => p_elct_lf_evt_ocrd_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_elct_ler_ocrd_dt_excld_flag,
       p_pl_id            => p_elct_pl_id );
  end if;
  if g_elct_ler_ntfn_dt_incl_rqd = 'Y' then
    chk_elct_ler_ntfn_dt_incl
      (p_ntfn_dt          => p_elct_ntfn_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_elct_ler_ntfn_dt_excld_flag,
       p_pl_id            => p_elct_pl_id );
  end if;
  if g_elct_rltn_incl_rqd = 'Y' then
    chk_elct_rltn_incl
      (p_per_in_ler_id    => p_elct_per_in_ler_id,
       p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
       p_excld_flag       => g_elct_rltn_excld_flag);
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End evaluate_eligibility_incl;
--
-----------------------------------------------------------------------------
------------------------< evaluate_change_log_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates the extract change log inclusion criteria
--
  Procedure evaluate_change_log_incl
  (p_chg_evt_cd        in ben_ext_chg_evt_log.chg_evt_cd%type,
   p_chg_evt_source    in ben_ext_chg_evt_log.chg_evt_cd%type,
   p_chg_eff_dt        in ben_ext_chg_evt_log.chg_eff_dt%type,
   p_chg_actl_dt       in ben_ext_chg_evt_log.chg_actl_dt%type,
   p_last_update_login in ben_ext_chg_evt_log.last_update_login%type,
   p_effective_date    in date default null,
   p_include           out nocopy varchar2)
  is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_change_log_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_chg_evt_incl_rqd = 'Y' then
    chk_chg_evt_cd_incl
      (p_chg_evt_cd       => p_chg_evt_cd,
       p_chg_evt_source   => p_chg_evt_source,
       p_excld_flag       => g_chg_evt_excld_flag);
  end if;
  if g_chg_eff_dt_incl_rqd = 'Y' then
    chk_chg_eff_dt_incl
      (p_chg_eff_dt       => p_chg_eff_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_chg_eff_dt_excld_flag);
  end if;
  -- for payroll dont validate the actual date without parameter date
  if g_chg_actl_dt_incl_rqd = 'Y' and  ( p_chg_evt_source = 'BEN' or p_chg_actl_dt is not null   )    then
    chk_chg_actl_dt_incl
      (p_chg_actl_dt      => p_chg_actl_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_chg_actl_dt_excld_flag);
  end if;
  -- for payroll dont validate the actual date without last_update_login
  if g_chg_login_incl_rqd = 'Y' and  ( p_chg_evt_source = 'BEN' or p_last_update_login  is not null   )  then
    chk_chg_login_incl
      (p_last_update_login => p_last_update_login,
       p_excld_flag        => g_chg_login_excld_flag);
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End evaluate_change_log_incl;
--
-----------------------------------------------------------------------------
------------------------< evaluate_comm_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates the extract change log inclusion criteria
--
  Procedure evaluate_comm_incl
  (p_cm_typ_id        in ben_per_cm_f.cm_typ_id%type,
   p_last_update_date in ben_per_cm_f.last_update_date%type,
   p_pvdd_last_update_date in ben_per_cm_prvdd_f.last_update_date%type,
   p_sent_dt          in ben_per_cm_prvdd_f.sent_dt%type,
   p_to_be_sent_dt    in ben_per_cm_prvdd_f.to_be_sent_dt%type,
   p_effective_date   in date default null,
   p_include          out nocopy varchar2)
  is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_comm_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_cm_typ_incl_rqd = 'Y' then
    chk_cm_typ_incl
      (p_cm_typ_id        => p_cm_typ_id,
       p_excld_flag       => g_cm_typ_excld_flag);
  end if;
  if g_cm_last_upd_dt_incl_rqd = 'Y' then
    chk_cm_last_upd_dt_incl
      (p_last_update_date => p_last_update_date,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_cm_last_upd_dt_excld_flag);
  end if;
  if g_cm_pr_last_upd_dt_incl_rqd = 'Y' then
    chk_cm_pr_last_upd_dt_incl
      (p_pvdd_last_update_date => p_pvdd_last_update_date,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_cm_pr_last_upd_dt_excld_flag);
  end if;
  if g_cm_sent_dt_incl_rqd = 'Y' then
    chk_cm_sent_dt_incl
      (p_sent_dt => p_sent_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_cm_sent_dt_excld_flag);
  end if;
  if g_cm_to_be_sent_dt_incl_rqd = 'Y' then
    chk_cm_to_be_sent_dt_incl
      (p_to_be_sent_dt => p_to_be_sent_dt,
       p_effective_date   => p_effective_date,
       p_excld_flag       => g_cm_to_be_sent_dt_excld_flag);
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End evaluate_comm_incl;
--




-----------------------------------------------------------------------------
------------------------< evaluate_prem_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates the extract premium inclusion criteria
--
  Procedure evaluate_prem_incl
  (p_last_update_date in ben_prtt_prem_by_mo_f.last_update_date%type,
   p_mo_num           in ben_prtt_prem_by_mo_f.mo_num%type default null ,
   p_yr_num           in ben_prtt_prem_by_mo_f.yr_num%type default null,
   p_effective_date   in date default null,
   p_include          out nocopy varchar2)
  is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_prem_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_prem_last_updt_dt_rqd = 'Y' then
      chk_prem_last_upd_dt_incl
        (p_last_update_date  => p_last_update_date,
         p_effective_date    => p_effective_date,
         p_excld_flag        => g_prem_last_updt_dt_excld_flag);

  end if;
  if g_prem_month_year_rqd = 'Y' then
     chk_prem_month_year_no_incl
        (p_mo_num         => p_mo_num,
         p_yr_num         => p_yr_num,
         p_effective_date => p_effective_date,
         p_excld_flag     => g_prem_month_year_excld_flag) ;
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End evaluate_prem_incl;




-----------------------------------------------------------------------------
------------------------< evaluate_elm_entry_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates element entry inclusion criteria
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
   )
is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_elm_entry_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';

  if g_payroll_last_date_incl_rqd = 'Y' then
     -- when the evaliation is called from payroll/element
     -- the pay period date is not sent as parameter
     -- validated only for run result
     if p_pay_period_date is not null then
        if g_debug then
          hr_utility.set_location(' calling chk_payroll_end_date_incl '||p_pay_period_date, 51);
          hr_utility.set_location(' effective date  '||p_effective_date, 51);
        end if;
        chk_payroll_end_date_incl
          (p_pay_end_date      => p_pay_period_date,
           p_effective_date    => p_effective_date,
           p_excld_flag        => g_payroll_last_Date_excld_flag );
      end if ;

  end if;

  if  g_payroll_rl_incl_rqd = 'Y'  then

       chk_payroll_rule_incl
           (p_business_group_id    =>  p_business_group_id ,
            p_person_id            =>  p_person_id ,
            p_effective_date       =>  p_effective_date,
            p_excld_flag           =>  g_payroll_rl_excld_flag,
            p_input_value_id       =>  p_input_value_id  ,
            p_processing_type      =>  p_processing_type ,
            p_element_type_id      =>  p_element_type_id  ,
            p_source_id            =>  p_source_id ,
            p_source_type          =>  p_source_type  ,
            p_element_entry_id     =>  p_element_entry_id
            ) ;

  end if ;
  --
  if g_ele_input_incl_rqd = 'Y' then
    --
    for i in 1..g_ele_input_list.count
    loop
      if p_input_value_id = g_ele_input_list(i) then
         if g_ele_input_excld_flag = 'Y'  then
            raise g_not_include;
         else
            raise g_include;
         end if ;
      end if;
    end loop;
    --
    if g_debug then
      hr_utility.set_location(' Exiting:'||l_proc, 15);
    end if;
    --
    if g_ele_input_excld_flag = 'Y' then
       raise g_include;
    else
       raise g_not_include;
    end if ;
    --
  end if;

  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
    --

--
Exception
--
  when g_include then
    p_include := 'Y';
--
  when g_not_include then
    p_include := 'N';
--
End Evaluate_Elm_Entry_Incl;
--
-----------------------------------------------------------------------------
------------------------< evaluate_action_item_incl >--------------------------
-----------------------------------------------------------------------------
--
-- The following procedure evaluates action item inclusion criteria
--
Procedure evaluate_action_item_incl
  (p_actn_typ_id in ben_prtt_enrt_actn_f.actn_typ_id%type,
   p_prtt_enrt_actn_id   in ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type,
   p_include          out nocopy varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_action_item_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;
--
  p_include := 'Y';
--
  if g_actn_name_incl_rqd = 'Y' then
    chk_actn_name_incl
    (p_actn_typ_id        => p_actn_typ_id,
     p_excld_flag         => g_actn_name_excld_flag);
  end if;
  if g_actn_item_rltn_incl_rqd = 'Y' then
    chk_actn_item_rltn_incl
      (p_prtt_enrt_actn_id   => p_prtt_enrt_actn_id,
       p_excld_flag          => g_actn_item_rltn_excld_flag);
  end if;
--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End Evaluate_action_item_Incl;
--

-----------------------------------------------------------------------------
-------------------------  cwb  ---------------------------------------

 Procedure Evaluate_cwb_incl
  (p_group_pl_id      in number  ,
   p_lf_evt_ocrd_dt   in date    ,
   p_include          out nocopy varchar2 ,
   p_effective_date     in date  ) is

 l_proc      varchar2(72);

begin


  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'Evaluate_cwb_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;

  p_include := 'Y';
  if g_cwb_pl_prd_rqd  = 'Y'  then
      chk_cwb_pl_prd_incl
          (p_pl_id           => p_group_pl_id ,
           p_LF_EVT_OCRD_DT  => p_lf_evt_ocrd_dt   ,
           p_effective_date  => p_effective_date,
           p_excld_flag      =>  g_cwb_pl_prd_excld_flag
          ) ;
  end if ;

--
  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--

end  Evaluate_cwb_incl ;




-----------------------------------------------------------------------------
-------------------------  Subheader  ---------------------------------------

 Procedure Evaluate_subhead_incl
  (p_organization_id     in number default null  ,
   p_position_id         in number default null  ,
   p_job_id              in number default null  ,
   p_payroll_id          in number default null  ,
   p_location_id         in number default null  ,
   p_grade_id            in number default null  ,
   p_business_group_id   in number               ,
   p_include          out nocopy varchar2 ,
   p_effective_date     in date  ,
   p_eff_date           in date default null   ,
   p_actl_date          in date default null ) is


  l_proc      varchar2(72);
  l_rl_param1         varchar2(100) ;
  l_rl_param1_value   varchar2(100) ;
  l_rl_param2         varchar2(100) ;
  l_rl_param2_value   varchar2(100) ;
begin

  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'Evaluate_subhead_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;

  p_include := 'Y';

  if g_subhead_rule_rqd  = 'Y' then
     -- call formula
     if  p_organization_id is not null then
         l_rl_param1 := 'EXT_SUBHDR_ORG_ID' ;
         l_rl_param1_value  :=  p_organization_id  ;
     end if ;

     if p_position_id is not null then
         l_rl_param2 := 'EXT_SUBHDR_POS_ID' ;
         l_rl_param2_value  :=  p_position_id  ;
      elsif p_job_id  is not null   then
         l_rl_param2 := 'EXT_SUBHDR_JOB_ID' ;
         l_rl_param2_value  :=  p_job_id  ;
      elsif p_payroll_id  is not null   then
         l_rl_param2 := 'EXT_SUBHDR_PAY_ID' ;
         l_rl_param2_value  :=  p_payroll_id  ;
      elsif p_location_id  is not null   then
         l_rl_param2 := 'EXT_SUBHDR_LOC_ID' ;
         l_rl_param2_value  :=  p_location_id  ;
      elsif p_grade_id  is not null   then
         l_rl_param2 := 'EXT_SUBHDR_GRADE_ID' ;
         l_rl_param2_value  :=  p_grade_id  ;

      end if ;

      --- call formula with the above two values
      chk_subhead_rule_incl
                (p_business_group_id   =>  p_business_group_id ,
                 p_effective_date      =>  p_effective_date,
                 p_excld_flag          =>  g_subhead_rule_excld_flag,
                 p_param_1             =>  l_rl_param1 ,
                 p_param_val_1         =>  l_rl_param1_value ,
                 p_param_2             =>  l_rl_param2 ,
                 p_param_val_2         =>  l_rl_param2_value
                ) ;
      ---

  end if ;

  --- validate business group  -- for future
  if g_subhead_bg_rqd  = 'Y' and p_business_group_id is not null  then
      chk_subhead_bg_incl
      (p_business_group_id    =>  p_business_group_id
      ,p_excld_flag           =>  g_subhead_bg_excld_flag  )  ;
  end if  ;


  --- validate position
  if g_subhead_pos_rqd  = 'Y' and p_position_id is not null  then
      chk_subhead_pos_incl
      (p_position_id     =>  p_position_id
      ,p_excld_flag      =>  g_subhead_pos_excld_flag  )  ;
  end if  ;


    --- validate position
  if g_subhead_job_rqd  = 'Y' and p_job_id is not null  then
      chk_subhead_job_incl
      (p_job_id     =>  p_job_id
      ,p_excld_flag      =>  g_subhead_job_excld_flag  )  ;
  end if  ;

  --- validate location
  if g_subhead_loc_rqd  = 'Y' and p_location_id is not null  then
      chk_subhead_loc_incl
      (p_location_id     =>  p_location_id
      ,p_excld_flag      =>  g_subhead_loc_excld_flag  )  ;
  end if  ;


   --- validate payroll
  if g_subhead_pay_rqd  = 'Y' and p_payroll_id is not null  then
      chk_subhead_pay_incl
      (p_payroll_id     =>  p_payroll_id
      ,p_excld_flag      =>  g_subhead_pay_excld_flag  )  ;
  end if  ;


  --- validate organizarion
  if g_subhead_org_rqd  = 'Y' and p_organization_id is not null  then
      chk_subhead_org_incl
      (p_organization_id     =>  p_organization_id
      ,p_excld_flag      =>  g_subhead_org_excld_flag  )  ;
  end if  ;


  --- validate Grqade
  if g_subhead_grd_rqd  = 'Y' and p_grade_id is not null  then
      chk_subhead_grd_incl
      (p_grade_id     =>  p_grade_id
      ,p_excld_flag      =>  g_subhead_grd_excld_flag  )  ;
  end if  ;



  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;

Exception
--
  when g_not_include then
    p_include := 'N';
    if g_debug then
       hr_utility.set_location(' Exiting:'||l_proc, 5);
    end if  ;
--

end ;



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
,p_include          out nocopy varchar2)
is
--
  l_proc      varchar2(72);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'evaluate_timecard_incl';
    hr_utility.set_location(' Entering:'||l_proc, 5);
  end if;

  p_include := 'Y';

IF ( p_otl_lvl = 'SUMMARY' )
THEN

	IF g_tc_status_incl_rqd = 'Y'
	THEN
		chk_tc_status_incl
			( p_tc_status  => p_tc_status
			, p_excld_flag => g_tc_status_excld_flag );
	END IF;

	IF ( g_tc_deleted_incl_rqd = 'Y' )
	THEN
		chk_tc_deleted_incl
			( p_tc_deleted  => p_tc_deleted
			, p_excld_flag  => g_tc_deleted_excld_flag );

	END IF;

ELSE -- ( p_otl_lvl = 'DETAIL' )

	IF ( g_project_id_incl_rqd = 'Y' )
	THEN
		chk_project_id_incl
			( p_project_id  => p_project_id
			, p_excld_flag  => g_project_id_excld_flag );

	END IF;

	IF ( g_task_id_incl_rqd = 'Y' )
	THEN
		chk_task_id_incl
			( p_task_id  => p_task_id
			, p_excld_flag  => g_task_id_excld_flag );

	END IF;

	IF ( g_exp_typ_id_incl_rqd = 'Y' )
	THEN
		chk_exp_typ_id_incl
			( p_exp_typ_id  => p_exp_typ_id
			, p_excld_flag  => g_exp_typ_id_excld_flag );

	END IF;

	IF ( g_element_type_id_incl_rqd = 'Y' )
	THEN
		chk_element_type_id_incl
			( p_element_type_id  => p_element_type_id
			, p_excld_flag  => g_element_type_id_excld_flag );

	END IF;

	IF ( g_po_num_incl_rqd = 'Y' )
	THEN
		chk_po_num_incl
			( p_po_num  => p_po_num
			, p_excld_flag  => g_po_num_excld_flag );

	END IF;


END IF; -- p_otl_lvl


  if g_debug then
    hr_utility.set_location(' Exiting:'||l_proc, 15);
  end if;
--
Exception
--
  when g_not_include then
    p_include := 'N';
--
End Evaluate_timecard_Incl;
--


end ben_ext_evaluate_inclusion;

/
