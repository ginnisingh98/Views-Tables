--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ENRT" as
/* $Header: benxenrt.pkb 120.4 2008/02/22 05:15:00 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_enrt.';  -- Global package name
--
-- procedure to initialize enrt globals - May, 99
-- ----------------------------------------------------------------------------
-- |------< initialize_enrt_globals >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure initialize_enrt_globals IS
--
  l_proc      varchar2(72) := g_package||'initialize_enrt_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
    --
    /* Start of Changes for WWBUG: 1828349:   addition		*/
    ben_ext_person.g_enrt_prtt_enrt_rslt_id  := null;
    /* End of Changes for WWBUG: 1828349			*/
    ben_ext_person.g_enrt_pl_name            := null;
    ben_ext_person.g_enrt_opt_name           := null;
    ben_ext_person.g_enrt_orgcovg_strdt      := null;
    ben_ext_person.g_enrt_prt_orgcovg_strdt  := null;
    ben_ext_person.g_enrt_status_cd          := null;
    ben_ext_person.g_enrt_pl_id              := null;
    ben_ext_person.g_enrt_pl_seq_num         := null;
    ben_ext_person.g_enrt_pip_seq_num        := null;
    ben_ext_person.g_enrt_ptp_seq_num        := null;
    ben_ext_person.g_enrt_oip_seq_num        := null;
    ben_ext_person.g_enrt_opt_id             := null;
    ben_ext_person.g_enrt_cvg_strt_dt        := null;
    ben_ext_person.g_enrt_cvg_thru_dt        := null;
    ben_ext_person.g_enrt_method             := null;
    ben_ext_person.g_enrt_ovrd_flag          := null;
    ben_ext_person.g_enrt_ovrd_thru_dt       := null;
    ben_ext_person.g_enrt_ovrd_reason        := null;
    ben_ext_person.g_enrt_suspended_flag     := null;
    ben_ext_person.g_enrt_rslt_effct_strdt   := null;
    ben_ext_person.g_enrt_total_premium_amt  := null;
    ben_ext_person.g_enrt_total_premium_uom  := null;
    ben_ext_person.g_enrt_mntot_prem_amt     := null;
    ben_ext_person.g_enrt_mntot_prem_cramt   := null;
    ben_ext_person.g_enrt_cvg_amt            := null;
    ben_ext_person.g_enrt_benefit_order_num  := null;
    ben_ext_person.g_enrt_pgm_id             := null;
    ben_ext_person.g_enrt_pgm_name           := null;
    ben_ext_person.g_enrt_pl_typ_id          := null;
    ben_ext_person.g_enrt_pl_typ_name        := null;
    ben_ext_person.g_enrt_rpt_group_name     := null;
    ben_ext_person.g_enrt_rpt_group_id       := null;
    ben_ext_person.g_enrt_pl_yr_strdt        := null;
    ben_ext_person.g_enrt_pl_yr_enddt        := null;
    ben_ext_person.g_enrt_elec_made_dt       := null;
    ben_ext_person.g_enrt_intrcovg_flag      := null;
    ben_ext_person.g_enrt_attr_1             := null;
    ben_ext_person.g_enrt_attr_2             := null;
    ben_ext_person.g_enrt_attr_3             := null;
    ben_ext_person.g_enrt_attr_4             := null;
    ben_ext_person.g_enrt_attr_5             := null;
    ben_ext_person.g_enrt_attr_6             := null;
    ben_ext_person.g_enrt_attr_7             := null;
    ben_ext_person.g_enrt_attr_8             := null;
    ben_ext_person.g_enrt_attr_9             := null;
    ben_ext_person.g_enrt_attr_10            := null;
    ben_ext_person.g_enrt_ler_id             := null;
    ben_ext_person.g_enrt_assignment_id      := null;
    ben_ext_person.g_enrt_uom                := null;
    ben_ext_person.g_pl_attr_1               := null;
    ben_ext_person.g_pl_attr_2               := null;
    ben_ext_person.g_pl_attr_3               := null;
    ben_ext_person.g_pl_attr_4               := null;
    ben_ext_person.g_pl_attr_5               := null;
    ben_ext_person.g_pl_attr_6               := null;
    ben_ext_person.g_pl_attr_7               := null;
    ben_ext_person.g_pl_attr_8               := null;
    ben_ext_person.g_pl_attr_9               := null;
    ben_ext_person.g_pl_attr_10              := null;
    ben_ext_person.g_pgm_attr_1              := null;
    ben_ext_person.g_pgm_attr_2              := null;
    ben_ext_person.g_pgm_attr_3              := null;
    ben_ext_person.g_pgm_attr_4              := null;
    ben_ext_person.g_pgm_attr_5              := null;
    ben_ext_person.g_pgm_attr_6              := null;
    ben_ext_person.g_pgm_attr_7              := null;
    ben_ext_person.g_pgm_attr_8              := null;
    ben_ext_person.g_pgm_attr_9              := null;
    ben_ext_person.g_pgm_attr_10             := null;
    ben_ext_person.g_ptp_attr_1              := null;
    ben_ext_person.g_ptp_attr_2              := null;
    ben_ext_person.g_ptp_attr_3              := null;
    ben_ext_person.g_ptp_attr_4              := null;
    ben_ext_person.g_ptp_attr_5              := null;
    ben_ext_person.g_ptp_attr_6              := null;
    ben_ext_person.g_ptp_attr_7              := null;
    ben_ext_person.g_ptp_attr_8              := null;
    ben_ext_person.g_ptp_attr_9              := null;
    ben_ext_person.g_ptp_attr_10             := null;
    ben_ext_person.g_plip_attr_1             := null;
    ben_ext_person.g_plip_attr_2             := null;
    ben_ext_person.g_plip_attr_3             := null;
    ben_ext_person.g_plip_attr_4             := null;
    ben_ext_person.g_plip_attr_5             := null;
    ben_ext_person.g_plip_attr_6             := null;
    ben_ext_person.g_plip_attr_7             := null;
    ben_ext_person.g_plip_attr_8             := null;
    ben_ext_person.g_plip_attr_9             := null;
    ben_ext_person.g_plip_attr_10            := null;
    ben_ext_person.g_oipl_attr_1             := null;
    ben_ext_person.g_oipl_attr_2             := null;
    ben_ext_person.g_oipl_attr_3             := null;
    ben_ext_person.g_oipl_attr_4             := null;
    ben_ext_person.g_oipl_attr_5             := null;
    ben_ext_person.g_oipl_attr_6             := null;
    ben_ext_person.g_oipl_attr_7             := null;
    ben_ext_person.g_oipl_attr_8             := null;
    ben_ext_person.g_oipl_attr_9             := null;
    ben_ext_person.g_oipl_attr_10            := null;
    ben_ext_person.g_opt_attr_1              := null;
    ben_ext_person.g_opt_attr_2              := null;
    ben_ext_person.g_opt_attr_3              := null;
    ben_ext_person.g_opt_attr_4              := null;
    ben_ext_person.g_opt_attr_5              := null;
    ben_ext_person.g_opt_attr_6              := null;
    ben_ext_person.g_opt_attr_7              := null;
    ben_ext_person.g_opt_attr_8              := null;
    ben_ext_person.g_opt_attr_9              := null;
    ben_ext_person.g_opt_attr_10             := null;
    ben_ext_person.g_enrt_plcy_r_grp         := null;
    ben_ext_person.g_ppr_name                := null;
    ben_ext_person.g_ppr_ident               := null;
    ben_ext_person.g_ppr_typ                 := null;
    ben_ext_person.g_ppr_strt_dt             := null;
    ben_ext_person.g_ppr_end_dt              := null;
    ben_ext_person.g_enrt_lfevt_name         := null;
    ben_ext_person.g_enrt_lfevt_status       := null;
    ben_ext_person.g_enrt_lfevt_note_dt      := null;
    ben_ext_person.g_enrt_lfevt_ocrd_dt      := null;
  --
    ben_ext_person.g_enrt_pl_fd_name         := null;
    ben_ext_person.g_enrt_pl_fd_code         := null;
    ben_ext_person.g_enrt_pgm_fd_name        := null;
    ben_ext_person.g_enrt_pgm_fd_code        := null;
    ben_ext_person.g_enrt_pl_typ_fd_name     := null;
    ben_ext_person.g_enrt_pl_typ_fd_code     := null;
    ben_ext_person.g_enrt_opt_fd_name        := null;
    ben_ext_person.g_enrt_opt_fd_code        := null;
    ben_ext_person.g_enrt_opt_pl_fd_name     := null;
    ben_ext_person.g_enrt_opt_pl_fd_code     := null;
    ben_ext_person.g_enrt_pl_pgm_fd_name     := null;
    ben_ext_person.g_enrt_pl_pgm_fd_code     := null;
    ben_ext_person.g_enrt_pl_typ_pgm_fd_name := null;
    ben_ext_person.g_enrt_pl_typ_pgm_fd_code := null;



  hr_utility.set_location('Exiting'||l_proc, 15);
--
End initialize_enrt_globals;
--
-- procedure to initialize rt info globals - May, 99
-- ----------------------------------------------------------------------------
-- |------< initialize_rt_info_globals >--------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure initialize_rt_info_globals IS
--
  l_proc      varchar2(72) := g_package||'initialize_rt_info_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
    --
    ben_ext_person.g_ee_pre_tax_cost          := null;
    ben_ext_person.g_ee_after_tax_cost        := null;
    ben_ext_person.g_ee_ttl_cost              := null;
    ben_ext_person.g_er_ttl_cost              := null;
    ben_ext_person.g_ee_ttl_distribution      := null;
    ben_ext_person.g_er_ttl_distribution      := null;
    ben_ext_person.g_ttl_other_rate           := null;
    ben_ext_person.g_pev_ee_pre_tax_contr     := null;
    ben_ext_person.g_pev_ee_after_tax_contr   := null;
    ben_ext_person.g_pev_ee_ttl_contr         := null;
    ben_ext_person.g_pev_er_ttl_contr         := null;
    ben_ext_person.g_pev_ee_ttl_distribution  := null;
    ben_ext_person.g_pev_er_ttl_distribution  := null;
    ben_ext_person.g_pev_ttl_other_rate       := null;
    ---cwb 2832419
    ben_ext_person.g_er_cwb_dst_bdgt                    :=    null ;
    ben_ext_person.g_er_cwb_misc_rate_1                 :=    null ;
    ben_ext_person.g_er_cwb_elig_salary                 :=    null ;
    ben_ext_person.g_er_cwb_misc_rate_2                 :=    null ;
    ben_ext_person.g_er_cwb_grant_price                 :=    null ;
    ben_ext_person.g_er_cwb_other_salary                :=    null ;
    ben_ext_person.g_er_cwb_reserve                     :=    null ;
    ben_ext_person.g_er_cwb_recomond_amt                :=    null ;
    ben_ext_person.g_er_cwb_stated_salary               :=    null ;
    ben_ext_person.g_er_cwb_tot_compensation            :=    null ;
    ben_ext_person.g_er_cwb_worksheet_bdgt              :=    null ;
    ben_ext_person.g_er_cwb_elig_salary                 :=    null ;
    ben_ext_person.g_er_cwb_misc_rate_3                 :=    null ;
    ben_ext_person.g_er_reimbursement                   :=    null ;
    ben_ext_person.g_pev_er_reimbursement               :=    null ;
    ben_ext_person.g_er_forfeited                       :=    null ;
    ben_ext_person.g_pev_er_forfeited                   :=    null ;


  --
  hr_utility.set_location('Exiting'||l_proc, 15);
--
End initialize_rt_info_globals;
--
-- ----------------------------------------------------------------------------
-- |------< get_rt_info >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_rt_info(
                      p_prtt_enrt_rslt_id    in number,
                      p_effective_date       in date
                      ) IS
--
cursor ee_pre_tax_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.tx_typ_cd = 'PRETAX'
    and b.acty_typ_cd IN ('EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2', 'PXC')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
--
 cursor ee_after_tax_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.tx_typ_cd = 'AFTERTAX'
    and b.acty_typ_cd IN ('EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2', 'PXC')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
--
cursor ee_ttl_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.acty_typ_cd IN ('EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2', 'PXC')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
--
cursor er_ttl_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.acty_typ_cd IN ('ERPYC', 'ERMPLC', 'ERC')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
--
cursor ee_ttl_dist_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.acty_typ_cd IN ('EEPYD', 'EEPRIID', 'PBD', 'PXD', 'PXD1')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
--
cursor er_ttl_dist_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.acty_typ_cd IN ('ERPYD', 'ERD')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
--
cursor ttl_oth_rt_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date)
    and b.acty_typ_cd NOT IN ('EEPYD', 'EEPRIID', 'PBD', 'PXD', 'PXD1', 'ERPYD',
                            'ERD', 'EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2',
                            'PXC', 'ERPYC', 'ERMPLC', 'ERC')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);
-- cwb 2832419
  cursor ttl_type_cd_c (c_acty_typ_cd varchar2)  is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  /* if the type is non recirring rate is creatted for one day so it may not return any row
    and p_effective_date between nvl(b.rt_strt_dt, p_effective_date)
                             and nvl(b.rt_end_dt, p_effective_date) */
    and b.acty_typ_cd  = c_acty_typ_cd
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between p.effective_start_date (+)
                             and p.effective_end_date (+);

  cursor ttl_reimb_c is
  select sum(b.rt_val), sum(p.screen_entry_value)
  from ben_prtt_rt_val b, pay_element_entry_values_f p
  where b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and b.acty_typ_cd  IN ('PRDPER', 'PRDPPR', 'PRDPR')
    and b.element_entry_value_id = p.element_entry_value_id (+)
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                             and nvl(p.effective_end_date, p_effective_date);

  l_dummy      ben_prtt_rt_val.rt_val%TYPE;

  l_proc      varchar2(72) := g_package||'get_rt_info';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
  --
  --
  -- Initialize rt info globals - May, 99
  initialize_rt_info_globals;
  --
  open ee_pre_tax_c;
  fetch ee_pre_tax_c into ben_ext_person.g_ee_pre_tax_cost, ben_ext_person.g_pev_ee_pre_tax_contr;
  close ee_pre_tax_c;
  --
  open ee_after_tax_c;
  fetch ee_after_tax_c into ben_ext_person.g_ee_after_tax_cost, ben_ext_person.g_pev_ee_after_tax_contr;
  close ee_after_tax_c;
  --
  open ee_ttl_c;
  fetch ee_ttl_c into ben_ext_person.g_ee_ttl_cost, ben_ext_person.g_pev_ee_ttl_contr;
  close ee_ttl_c;
  --
  open er_ttl_c;
  fetch er_ttl_c into ben_ext_person.g_er_ttl_cost, ben_ext_person.g_pev_er_ttl_contr;
  close er_ttl_c;
  --
  open ee_ttl_dist_c;
  fetch ee_ttl_dist_c into ben_ext_person.g_ee_ttl_distribution, ben_ext_person.g_pev_ee_ttl_distribution;
  close ee_ttl_dist_c;
  --
  open er_ttl_dist_c;
  fetch er_ttl_dist_c into ben_ext_person.g_er_ttl_distribution, ben_ext_person.g_pev_er_ttl_distribution;
  close er_ttl_dist_c;
  --
  open ttl_oth_rt_c;
  fetch ttl_oth_rt_c into ben_ext_person.g_ttl_other_rate, ben_ext_person.g_pev_ttl_other_rate;
  close ttl_oth_rt_c;

  -- cwb 2832419
  -- reimbursement
  open ttl_reimb_c;
  fetch ttl_reimb_c into ben_ext_person.g_er_reimbursement , ben_ext_person.g_pev_er_reimbursement;
  close ttl_reimb_c;

  hr_utility.set_location( 'reimb ' || ben_ext_person.g_er_reimbursement , 911 );
  hr_utility.set_location( 'reimb ' || ben_ext_person.g_pev_er_reimbursement,911 );
  --- Forfeiture
  open ttl_type_cd_c('PRTRFS');
  fetch ttl_type_cd_c into ben_ext_person.g_er_forfeited , ben_ext_person.g_pev_er_forfeited;
  close ttl_type_cd_c ;

  -- CWB
  open ttl_type_cd_c('CWBDB');
  fetch ttl_type_cd_c into ben_ext_person.g_er_cwb_dst_bdgt,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBES');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_elig_salary,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBGP');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_grant_price,l_dummy ;
  close ttl_type_cd_c ;

  hr_utility.set_location( 'CWBGP ' || ben_ext_person.g_er_cwb_grant_price , 911 );

  open ttl_type_cd_c('CWBMR1');
  fetch ttl_type_cd_c into ben_ext_person.g_er_cwb_misc_rate_1,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBMR2');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_misc_rate_2,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBMR3');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_misc_rate_3,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBOS');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_other_salary,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBR');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_reserve ,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBRA');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_recomond_amt,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBSS');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_stated_salary,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBTC');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_tot_compensation,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBWB');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_worksheet_bdgt,l_dummy ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBWS');
  fetch ttl_type_cd_c into  ben_ext_person.g_er_cwb_worksheet_amt,l_dummy ;
  close ttl_type_cd_c ;

  hr_utility.set_location( 'CWBWS ' || ben_ext_person.g_er_cwb_worksheet_amt , 911 );

  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End get_rt_info;
-- ----------------------------------------------------------------------------
-- |--------------------< main >----------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE main
    (                        p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
   l_include          varchar2(1) := 'Y';


   --

   cursor c_enrt_rslt is
   select
            enrt.prtt_enrt_rslt_id       prtt_enrt_rslt_id,
            enrt.pl_id                   pl_id,
            enrt.oipl_id                 oipl_id,
            enrt.orgnl_enrt_dt           orgn_strdt,
            enrt.prtt_enrt_rslt_stat_cd  status_cd,
            enrt.enrt_cvg_strt_dt        cvg_strt_dt,
            enrt.enrt_cvg_thru_dt        cvg_thru_dt,
            enrt.enrt_mthd_cd            mthd_cd,
            enrt.enrt_ovridn_flag        ovridn_flag,
            enrt.enrt_ovrid_thru_dt      ovrid_thru_dt,
            enrt.enrt_ovrid_rsn_cd       ovrid_rsn_cd,
            enrt.sspndd_flag             sspndd_flag,
            enrt.effective_start_date    effct_strdt,
            enrt.bnft_amt                bnft_amt,
            enrt.bnft_ordr_num           bnft_order_num,
            enrt.pgm_id                  pgm_id,
            enrt.last_update_date,
            enrt.prtt_enrt_rslt_stat_cd,
            enrt.per_in_ler_id,
            enrt.pl_ordr_num             pl_seq_num,
            enrt.plip_ordr_num           plip_seq_num,
            enrt.ptip_ordr_num           ptip_seq_num,
            enrt.oipl_ordr_num           oipl_seq_num,
            enrt.ler_id                  enrt_ler_id,
            enrt.assignment_id           assignment_id,
            enrt.rplcs_sspndd_rslt_id    ,
            enrt.uom                     uom,
            enrt.pen_attribute1,
            enrt.pen_attribute2,
            enrt.pen_attribute3,
            enrt.pen_attribute4,
            enrt.pen_attribute5,
            enrt.pen_attribute6,
            enrt.pen_attribute7,
            enrt.pen_attribute8,
            enrt.pen_attribute9,
            enrt.pen_attribute10,
            pl.name                 	 pl_name,
            pl.short_name              	 pl_fd_name,
            pl.short_code              	 pl_fd_code,
            pl.pl_typ_id            	 pl_typ_id,
            pl.pln_attribute1,
            pl.pln_attribute2,
            pl.pln_attribute3,
            pl.pln_attribute4,
            pl.pln_attribute5,
            pl.pln_attribute6,
            pl.pln_attribute7,
            pl.pln_attribute8,
            pl.pln_attribute9,
            pl.pln_attribute10,
            ptp.name pl_typ_name,
            ptp.short_name  ptp_fd_name,
            ptp.short_code	 ptp_fd_code,
            ptp.ptp_attribute1,
            ptp.ptp_attribute2,
            ptp.ptp_attribute3,
            ptp.ptp_attribute4,
            ptp.ptp_attribute5,
            ptp.ptp_attribute6,
            ptp.ptp_attribute7,
            ptp.ptp_attribute8,
            ptp.ptp_attribute9,
            ptp.ptp_attribute10
     from ben_prtt_enrt_rslt_f     enrt,
           ben_pl_f                 pl,
           ben_pl_typ_f             ptp
     where enrt.person_id = p_person_id
      and p_effective_date between enrt.effective_start_date
          and enrt.effective_end_date
      and enrt.pl_id  = pl.pl_id
      and p_effective_date between pl.effective_start_date and pl.effective_end_date
      and pl.pl_typ_id = ptp.pl_typ_id
      and p_effective_date between ptp.effective_start_date
          and ptp.effective_end_date
       ;




    cursor c_pil_rslt (p_pil_id number) is
    select  pil.lf_evt_ocrd_dt,
            pil.ntfn_dt,
            pil.ler_id,
            pil.per_in_ler_stat_cd,
            ler.name       ler_name
      from  ben_per_in_ler  pil,
            ben_ler_f       ler
     where  pil.per_in_ler_id  = p_pil_id
       and  ler.ler_id = pil.ler_id
       and  p_effective_date between ler.effective_start_date and ler.effective_end_date
       ;

   l_pil_rslt  c_pil_rslt%rowtype ;

   cursor c_pgm_rslt (p_pgm_id  number) is
   select pgm.name                	 pgm_name,
          pgm.short_name             	 pgm_fd_name,
          pgm.short_code            	 pgm_fd_code,
          pgm.pgm_attribute1,
          pgm.pgm_attribute2,
          pgm.pgm_attribute3,
          pgm.pgm_attribute4,
          pgm.pgm_attribute5,
          pgm.pgm_attribute6,
          pgm.pgm_attribute7,
          pgm.pgm_attribute8,
          pgm.pgm_attribute9,
          pgm.pgm_attribute10
    from  ben_pgm_f pgm
    where p_pgm_id = pgm.pgm_id
      and p_effective_date between pgm.effective_start_date
          and pgm.effective_end_date
         ;


    cursor c_oipl_rslt (p_oipl_id number) is
    select oipl.short_name     oipl_fd_name,
           oipl.short_code     oipl_fd_code,
           oipl.cop_attribute1,
           oipl.cop_attribute2,
           oipl.cop_attribute3,
           oipl.cop_attribute4,
           oipl.cop_attribute5,
           oipl.cop_attribute6,
           oipl.cop_attribute7,
           oipl.cop_attribute8,
           oipl.cop_attribute9,
           oipl.cop_attribute10,
           opt.opt_id   opt_id,
           opt.name     opt_name,
           opt.short_name    opt_fd_name,
           opt.short_code    opt_fd_code,
           opt.opt_attribute1,
           opt.opt_attribute2,
           opt.opt_attribute3,
           opt.opt_attribute4,
           opt.opt_attribute5,
           opt.opt_attribute6,
           opt.opt_attribute7,
           opt.opt_attribute8,
           opt.opt_attribute9,
           opt.opt_attribute10
     from  ben_oipl_f               oipl,
           ben_opt_f                opt
    where  p_oipl_id = oipl.oipl_id
      and  p_effective_date between oipl.effective_start_date
           and oipl.effective_end_date
       and opt.opt_id   = oipl.opt_id
       and p_effective_date between opt.effective_start_date
           and opt.effective_end_date
       ;


   l_oipl_rslt  c_oipl_rslt%rowtype ;

   cursor c_plip_rslt (p_pgm_id  number ,
                       p_pl_id   number ) is
   select   cpp.cpp_attribute1,
            cpp.cpp_attribute2,
            cpp.cpp_attribute3,
            cpp.cpp_attribute4,
            cpp.cpp_attribute5,
            cpp.cpp_attribute6,
            cpp.cpp_attribute7,
            cpp.cpp_attribute8,
            cpp.cpp_attribute9,
            cpp.cpp_attribute10,
            cpp.short_name     plip_fd_name,
            cpp.short_code     plip_fd_code
    from    ben_plip_f               cpp
   where    p_pl_id = cpp.pl_id
       and  p_pgm_id = cpp.pgm_id
       and p_effective_date between cpp.effective_start_date
           and cpp.effective_end_date
       ;

/*
    cursor c_popl_rslt  (p_pgm_id  number ,
                         p_pl_id   number ,
                         p_oipl_id number ,
                         p_pil_id  number ) is
    select ppopl.elcns_made_dt          elec_made_dt
    from   ben_elig_per_elctbl_chc  ece,
           ben_pil_elctbl_chc_popl  ppopl
    where (p_pgm_id is  null or  p_pgm_id = ece.pgm_id)
    and   p_pl_id = ece.pl_id
    and   (p_oipl_id is null or p_oipl_id  = ece.oipl_id)
    and   (p_pil_id is null or  p_pil_id   = ece.per_in_ler_id )
    and    ece.pil_elctbl_chc_popl_id = ppopl.pil_elctbl_chc_popl_id
    ;

*/




  cursor c_popl_rslt  (p_pgm_id  number ,
                       p_pl_id   number ,
                       p_pil_id  number ) is
    select popl.elcns_made_dt          elec_made_dt
    from   ben_pil_elctbl_chc_popl  popl
    where ( (p_pgm_id is not null and p_pgm_id = popl.pgm_id)
        or ( p_pgm_id is null and  p_pl_id = popl.pl_id )
          )
    and   p_pil_id   = popl.per_in_ler_id
    ;

  cursor c_ptip_fd ( l_pgm_id    number ,
                     l_pl_typ_id number ) is
    select short_name , short_code
    from ben_ptip_f  ptip
    where  pl_typ_id = l_pl_typ_id
      and  pgm_id    = l_pgm_id
      and p_effective_date between nvl(ptip.effective_start_date, p_effective_date)
          and nvl(ptip.effective_end_date, p_effective_date)
   ;


--
  cursor plcy_c (l_pl_id Number) is
   select ppl.plcy_r_grp
     from ben_popl_org_f ppl ,
          per_all_assignments_f asg
    where pl_id = l_pl_id
      and plcy_r_grp is not null
      and asg.assignment_id = ben_ext_person.g_assignment_id
      and ppl.organization_id = asg.organization_id
      and p_effective_date between ppl.effective_start_date
                             and ppl.effective_end_date
      and  p_effective_date between asg.effective_start_date
                             and asg.effective_end_date
    ;

--
  cursor c_prmry_care_prvdr(l_prtt_enrt_rslt_id  number) is
  SELECT name
        ,ext_ident
        ,prmry_care_prvdr_typ_cd
        ,effective_start_date
        ,effective_end_date
  FROM   ben_prmry_care_prvdr_f ppr
  WHERE  ppr.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
  AND    p_effective_date between ppr.effective_start_date
         and ppr.effective_end_date;
--
  cursor prem_tot_c(l_prtt_enrt_rslt_id number) is
  select
          sum(ppr.std_prem_val)
        , ppr.std_prem_uom
  from ben_prtt_prem_f ppr,
       ben_per_in_ler pil
  where ppr.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
    and p_effective_date between nvl(ppr.effective_start_date, p_effective_date)
                             and nvl(ppr.effective_end_date, p_effective_date)
    and pil.per_in_ler_id=ppr.per_in_ler_id
    and pil.business_group_id+0=ppr.business_group_id+0
    group by ppr.std_prem_uom
  ;

--
  cursor c_rpt_grp(l_prtt_enrt_rslt_id number) is
  select grp.rptg_grp_id,
         grp.name
  from ben_prtt_enrt_rslt_f  prst,
       ben_popl_rptg_grp_f   prpg,
       ben_rptg_grp          grp
  where
       prst.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
  and  prst.pl_id = prpg.pl_id
  and  prpg.rptg_grp_id = grp.rptg_grp_id;
 --
 --Bill Burns 05-Jul-2001
 --
 cursor c_pl_yr(l_prtt_enrt_rslt_id number) is
 select yrp.start_date,yrp.end_date
 from ben_yr_perd          yrp,
      ben_popl_yr_perd     pop,
      ben_prtt_enrt_rslt_f pen
 where pop.yr_perd_id = yrp.yr_perd_id
 and pop.pl_id = pen.pl_id
 and p_effective_date  between yrp.start_date and nvl(yrp.end_date,p_effective_date)
 and p_effective_date between pen.effective_start_date and pen.effective_end_date
 and pen.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
 and yrp.business_group_id = pen.business_group_id
 and pop.business_group_id = pen.business_group_id;

cursor c_pgm_yr(l_prtt_enrt_rslt_id number) is
select yrp.start_date,yrp.end_date
 from ben_yr_perd          yrp,
      ben_popl_yr_perd     pop,
      ben_prtt_enrt_rslt_f pen
 where pop.yr_perd_id = yrp.yr_perd_id
 and pop.pgm_id = pen.pgm_id
 and p_effective_date  between yrp.start_date and nvl(yrp.end_date,p_effective_date)
 and p_effective_date  between pen.effective_start_date and pen.effective_end_date
 and pen.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
 and yrp.business_group_id = pen.business_group_id
 and pop.business_group_id = pen.business_group_id;
 --
 --End Bill Burns 05-Jul-2001
 --
  cursor c_mntot_prem(l_prtt_enrt_rslt_id number) is
  select sum(prm.val)
        ,sum(prm.cr_val)
  from ben_prtt_prem_by_mo_f   prm
      , ben_prtt_prem_f        ppe
  where ppe.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
  and   ppe.prtt_prem_id = prm.prtt_prem_id
  and   prm.yr_num = to_number(to_char(p_effective_date,'YYYY'))
  and   prm.mo_num = to_number(to_char(p_effective_date,'MM'));
 --
  cursor c_intrm(l_prtt_enrt_rslt_id number) is
  select 1
  from ben_prtt_enrt_rslt_f   enrt
  where enrt.rplcs_sspndd_rslt_id = l_prtt_enrt_rslt_id
  and   enrt.person_id = p_person_id
  and   sspndd_flag = 'Y'
  and p_effective_date between enrt.effective_start_date
                                and enrt.effective_end_date
  and p_effective_date between enrt.ENRT_CVG_STRT_DT
                                and enrt.ENRT_CVG_THRU_DT ;
--
  cursor c_interim(l_rplcs_sspndd_rslt_id number) is
  select
  enrt.pl_id   pl_id,
  pl.name      pl_name,
  enrt.oipl_id,
  opt.opt_id   opt_id,
  opt.name     opt_name,
  enrt.bnft_amt cvg_amt
  from ben_prtt_enrt_rslt_f   enrt,
  ben_pl_f pl,
  ben_oipl_f oipl,
  ben_opt_f opt
  where enrt.prtt_enrt_rslt_id = l_rplcs_sspndd_rslt_id
  and enrt.pl_id  = pl.pl_id
  and enrt.oipl_id = oipl.oipl_id (+)
  and opt.opt_id (+)  = oipl.opt_id
  and p_effective_date between enrt.effective_start_date
                                and enrt.effective_end_date
  and p_effective_date between pl.effective_start_date
                                and pl.effective_end_date
  and p_effective_date between nvl(oipl.effective_start_date, p_effective_date)
                                and nvl(oipl.effective_end_date, p_effective_date)
  and p_effective_date between opt.effective_start_date
                                and opt.effective_end_date
  and   enrt.person_id = p_person_id;
--
  l_interim    c_interim%rowtype;
--
  cursor ext_rcd_cnt_c is
  select count(*) from
    ben_ext_rcd a,
    ben_ext_rcd_in_file b
  where a.ext_rcd_id = b.ext_rcd_id
  and   b.ext_file_id = p_ext_file_id
  and   b.rqd_flag = 'Y';

  l_cnt       number;
  l_dummy     number;
--

   BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   FOR enrt IN c_enrt_rslt LOOP
     --
     -- initialize enrt globals - May, 99
     initialize_enrt_globals;

     -- intialize the cursor variable
     l_pil_rslt  := null ;
     l_oipl_rslt := null ;

     --- get /pil/ler date
     if  enrt.per_in_ler_id  is not null then
         open c_pil_rslt (enrt.per_in_ler_id) ;
         fetch c_pil_rslt into l_pil_rslt ;
         close c_pil_rslt ;
     end if ;

    ---  get option information
    if enrt.oipl_id is not null then
        open c_oipl_rslt (enrt.oipl_id) ;
        fetch c_oipl_rslt into l_oipl_rslt ;
        close c_oipl_rslt ;

    end if ;




     ben_ext_evaluate_inclusion.Evaluate_Benefit_Incl
                    (p_pl_id    => enrt.pl_id,
                     p_sspndd_flag => enrt.sspndd_flag,
                     p_enrt_cvg_strt_dt => enrt.cvg_strt_dt,
                     p_enrt_cvg_thru_dt => enrt.cvg_thru_dt,
                     p_prtt_enrt_rslt_stat_cd => enrt.prtt_enrt_rslt_stat_cd,
                     p_enrt_mthd_cd => enrt.mthd_cd,
                     p_pgm_id       => enrt.pgm_id,
                     p_pl_typ_id    => enrt.pl_typ_id,
                     p_opt_id       => l_oipl_rslt.opt_id,
                     p_last_update_date => trunc(enrt.last_update_date),
                     p_ler_id    => l_pil_rslt.ler_id,
                     p_ntfn_dt      => l_pil_rslt.ntfn_dt,
                     p_lf_evt_ocrd_dt  => l_pil_rslt.lf_evt_ocrd_dt,
                     p_per_in_ler_stat_cd  => l_pil_rslt.per_in_ler_stat_cd,
                     p_per_in_ler_id    => enrt.per_in_ler_id,
                     p_prtt_enrt_rslt_id => enrt.prtt_enrt_rslt_id,
                     p_effective_date => p_effective_date,
                     p_include => l_include
                     );
     --
     IF l_include = 'Y' THEN
       --
       -- assign enrollment info to global variables
       -- after the include calidation get the ptip name and code
       if  enrt.pgm_id is not null and enrt.pl_typ_id is not null then

           open c_ptip_fd(l_pgm_id    => enrt.pgm_id ,
                          l_pl_typ_id => enrt.pl_typ_id ) ;
           fetch c_ptip_fd
                 into ben_ext_person.g_enrt_pl_typ_pgm_fd_name
                     ,ben_ext_person.g_enrt_pl_typ_pgm_fd_code ;
           close c_ptip_fd ;

       end if ;
       --
          /* Start of Changes for WWBUG: 1828349			*/
          ben_ext_person.g_enrt_prtt_enrt_rslt_id  := enrt.prtt_enrt_rslt_id;
          /* End of Changes for WWBUG: 1828349				*/
          ben_ext_person.g_enrt_pl_name            := enrt.pl_name;
          ben_ext_person.g_enrt_orgcovg_strdt      := enrt.orgn_strdt;
          ben_ext_person.g_enrt_prt_orgcovg_strdt  := enrt.orgn_strdt;
          ben_ext_person.g_enrt_status_cd          := enrt.status_cd;
          ben_ext_person.g_enrt_pl_id              := enrt.pl_id;
          ben_ext_person.g_enrt_pl_seq_num         := enrt.pl_seq_num;
          ben_ext_person.g_enrt_pip_seq_num        := enrt.plip_seq_num;
          ben_ext_person.g_enrt_ptp_seq_num        := enrt.ptip_seq_num;
          ben_ext_person.g_enrt_oip_seq_num        := enrt.oipl_seq_num;
          ben_ext_person.g_enrt_cvg_strt_dt        := enrt.cvg_strt_dt;
          ben_ext_person.g_enrt_cvg_thru_dt        := enrt.cvg_thru_dt;
          ben_ext_person.g_enrt_method             := enrt.mthd_cd;
          ben_ext_person.g_enrt_ovrd_flag          := enrt.ovridn_flag;
          ben_ext_person.g_enrt_ovrd_thru_dt       := enrt.ovrid_thru_dt;
          ben_ext_person.g_enrt_ovrd_reason        := enrt.ovrid_rsn_cd;
          ben_ext_person.g_enrt_suspended_flag     := enrt.sspndd_flag;
          ben_ext_person.g_enrt_rslt_effct_strdt   := enrt.effct_strdt;
          ben_ext_person.g_enrt_cvg_amt            := enrt.bnft_amt;
          ben_ext_person.g_enrt_benefit_order_num  := enrt.bnft_order_num;
          ben_ext_person.g_enrt_pgm_id             := enrt.pgm_id;
          ben_ext_person.g_enrt_pl_typ_id          := enrt.pl_typ_id;
          ben_ext_person.g_enrt_pl_typ_name        := enrt.pl_typ_name;
          ben_ext_person.g_enrt_attr_1             := enrt.pen_attribute1;
          ben_ext_person.g_enrt_attr_2             := enrt.pen_attribute2;
          ben_ext_person.g_enrt_attr_3             := enrt.pen_attribute3;
          ben_ext_person.g_enrt_attr_4             := enrt.pen_attribute4;
          ben_ext_person.g_enrt_attr_5             := enrt.pen_attribute5;
          ben_ext_person.g_enrt_attr_6             := enrt.pen_attribute6;
          ben_ext_person.g_enrt_attr_7             := enrt.pen_attribute7;
          ben_ext_person.g_enrt_attr_8             := enrt.pen_attribute8;
          ben_ext_person.g_enrt_attr_9             := enrt.pen_attribute9;
          ben_ext_person.g_enrt_attr_10            := enrt.pen_attribute10;
          ben_ext_person.g_enrt_ler_id             := enrt.enrt_ler_id;
          ben_ext_person.g_enrt_assignment_id      := enrt.assignment_id;
          ben_ext_person.g_enrt_uom                := enrt.uom;
          ben_ext_person.g_pl_attr_1               := enrt.pln_attribute1;
          ben_ext_person.g_pl_attr_2               := enrt.pln_attribute2;
          ben_ext_person.g_pl_attr_3               := enrt.pln_attribute3;
          ben_ext_person.g_pl_attr_4               := enrt.pln_attribute4;
          ben_ext_person.g_pl_attr_5               := enrt.pln_attribute5;
          ben_ext_person.g_pl_attr_6               := enrt.pln_attribute6;
          ben_ext_person.g_pl_attr_7               := enrt.pln_attribute7;
          ben_ext_person.g_pl_attr_8               := enrt.pln_attribute8;
          ben_ext_person.g_pl_attr_9               := enrt.pln_attribute9;
          ben_ext_person.g_pl_attr_10              := enrt.pln_attribute10;
          ben_ext_person.g_ptp_attr_1              := enrt.ptp_attribute1;
          ben_ext_person.g_ptp_attr_2              := enrt.ptp_attribute2;
          ben_ext_person.g_ptp_attr_3              := enrt.ptp_attribute3;
          ben_ext_person.g_ptp_attr_4              := enrt.ptp_attribute4;
          ben_ext_person.g_ptp_attr_5              := enrt.ptp_attribute5;
          ben_ext_person.g_ptp_attr_6              := enrt.ptp_attribute6;
          ben_ext_person.g_ptp_attr_7              := enrt.ptp_attribute7;
          ben_ext_person.g_ptp_attr_8              := enrt.ptp_attribute8;
          ben_ext_person.g_ptp_attr_9              := enrt.ptp_attribute9;
          ben_ext_person.g_ptp_attr_10             := enrt.ptp_attribute10;

          --
          ben_ext_person.g_enrt_lfevt_name         := l_pil_rslt.ler_name;
          ben_ext_person.g_enrt_lfevt_status       := l_pil_rslt.per_in_ler_stat_cd;
          ben_ext_person.g_enrt_lfevt_note_dt      := l_pil_rslt.ntfn_dt;
          ben_ext_person.g_enrt_lfevt_ocrd_dt      := l_pil_rslt.lf_evt_ocrd_dt;
          --
          ben_ext_person.g_enrt_opt_id             := l_oipl_rslt.opt_id;
          ben_ext_person.g_enrt_opt_name           := l_oipl_rslt.opt_name;
          ben_ext_person.g_oipl_attr_1             := l_oipl_rslt.cop_attribute1;
          ben_ext_person.g_oipl_attr_2             := l_oipl_rslt.cop_attribute2;
          ben_ext_person.g_oipl_attr_3             := l_oipl_rslt.cop_attribute3;
          ben_ext_person.g_oipl_attr_4             := l_oipl_rslt.cop_attribute4;
          ben_ext_person.g_oipl_attr_5             := l_oipl_rslt.cop_attribute5;
          ben_ext_person.g_oipl_attr_6             := l_oipl_rslt.cop_attribute6;
          ben_ext_person.g_oipl_attr_7             := l_oipl_rslt.cop_attribute7;
          ben_ext_person.g_oipl_attr_8             := l_oipl_rslt.cop_attribute8;
          ben_ext_person.g_oipl_attr_9             := l_oipl_rslt.cop_attribute9;
          ben_ext_person.g_oipl_attr_10            := l_oipl_rslt.cop_attribute10;
          ben_ext_person.g_opt_attr_1              := l_oipl_rslt.opt_attribute1;
          ben_ext_person.g_opt_attr_2              := l_oipl_rslt.opt_attribute2;
          ben_ext_person.g_opt_attr_3              := l_oipl_rslt.opt_attribute3;
          ben_ext_person.g_opt_attr_4              := l_oipl_rslt.opt_attribute4;
          ben_ext_person.g_opt_attr_5              := l_oipl_rslt.opt_attribute5;
          ben_ext_person.g_opt_attr_6              := l_oipl_rslt.opt_attribute6;
          ben_ext_person.g_opt_attr_7              := l_oipl_rslt.opt_attribute7;
          ben_ext_person.g_opt_attr_8              := l_oipl_rslt.opt_attribute8;
          ben_ext_person.g_opt_attr_9              := l_oipl_rslt.opt_attribute9;
          ben_ext_person.g_opt_attr_10             := l_oipl_rslt.opt_attribute10;
          ben_ext_person.g_enrt_opt_fd_name        := l_oipl_rslt.opt_fd_name  ;
          ben_ext_person.g_enrt_opt_fd_code        := l_oipl_rslt.opt_fd_code  ;
          ben_ext_person.g_enrt_opt_pl_fd_name     := l_oipl_rslt.oipl_fd_name ;
          ben_ext_person.g_enrt_opt_pl_fd_code     := l_oipl_rslt.oipl_fd_code ;
          --2559743
          ben_ext_person.g_enrt_pl_fd_name         :=  enrt.pl_fd_name   ;
          ben_ext_person.g_enrt_pl_fd_code         :=  enrt.pl_fd_code   ;
          ben_ext_person.g_enrt_pl_typ_fd_name     :=  enrt.ptp_fd_name  ;
          ben_ext_person.g_enrt_pl_typ_fd_code     :=  enrt.ptp_fd_code  ;
          ----

          if  enrt.pgm_id is not null then
              open c_pgm_rslt(enrt.pgm_id ) ;
              fetch c_pgm_rslt into
                    ben_ext_person.g_enrt_pgm_name
                  , ben_ext_person.g_enrt_pgm_fd_name
                  , ben_ext_person.g_enrt_pgm_fd_code
                  , ben_ext_person.g_pgm_attr_1
                  , ben_ext_person.g_pgm_attr_2
                  , ben_ext_person.g_pgm_attr_3
                  , ben_ext_person.g_pgm_attr_4
                  , ben_ext_person.g_pgm_attr_5
                  , ben_ext_person.g_pgm_attr_6
                  , ben_ext_person.g_pgm_attr_7
                  , ben_ext_person.g_pgm_attr_8
                  , ben_ext_person.g_pgm_attr_9
                  , ben_ext_person.g_pgm_attr_10
                  ;
               close c_pgm_rslt ;
          end if ;

          if enrt.pgm_id is not null and enrt.pl_id is not null then
             open c_plip_rslt (enrt.pgm_id  ,
                               enrt.pl_id ) ;
             fetch c_plip_rslt into
                   ben_ext_person.g_plip_attr_1
                  ,ben_ext_person.g_plip_attr_2
                  ,ben_ext_person.g_plip_attr_3
                  ,ben_ext_person.g_plip_attr_4
                  ,ben_ext_person.g_plip_attr_5
                  ,ben_ext_person.g_plip_attr_6
                  ,ben_ext_person.g_plip_attr_7
                  ,ben_ext_person.g_plip_attr_8
                  ,ben_ext_person.g_plip_attr_9
                  ,ben_ext_person.g_plip_attr_10
                  ,ben_ext_person.g_enrt_pl_pgm_fd_name
                  ,ben_ext_person.g_enrt_pl_pgm_fd_code
                  ;
             close  c_plip_rslt ;
          end if ;

          open  c_popl_rslt(enrt.pgm_id   ,
                            enrt.pl_id    ,
                            enrt.per_in_ler_id ) ;
          fetch c_popl_rslt into  ben_ext_person.g_enrt_elec_made_dt ;

          close c_popl_rslt ;



         --
       -- retrieve additional enrollment information
          --
          -- retrieve policy or group number if required
          if ben_extract.g_pgn_csr = 'Y' then
            open plcy_c(enrt.pl_id);
            fetch plcy_c into ben_ext_person.g_enrt_plcy_r_grp;
            close plcy_c;
          end if;
          --
          -- retrieve primary care provider info if required
          if ben_extract.g_ppcp_csr = 'Y' then
            open c_prmry_care_prvdr(enrt.prtt_enrt_rslt_id);
            fetch c_prmry_care_prvdr into ben_ext_person.g_ppr_name
                                            ,ben_ext_person.g_ppr_ident
                                            ,ben_ext_person.g_ppr_typ
                                            ,ben_ext_person.g_ppr_strt_dt
                                            ,ben_ext_person.g_ppr_end_dt;
            close c_prmry_care_prvdr;
          end if;
       --
          if ben_extract.g_rt_csr = 'Y' then
          --
             hr_utility.set_location(' person Id ' || p_person_id , 991) ;
             hr_utility.set_location(' result id ' || enrt.prtt_enrt_rslt_id , 991 ) ;
             get_rt_info(p_prtt_enrt_rslt_id => enrt.prtt_enrt_rslt_id,
                         p_effective_date    => p_effective_date);
          --
          end if;
       --
          -- retrieve total premium info if required
          if ben_extract.g_pprem_csr = 'Y' then
            open prem_tot_c(enrt.prtt_enrt_rslt_id);
            fetch prem_tot_c into ben_ext_person.g_enrt_total_premium_amt
                                 ,ben_ext_person.g_enrt_total_premium_uom;
            close prem_tot_c;
          end if;
          --
          -- this is for person level so moving benxpers
          -- retrieve total flex credit info
         /*
          if ben_extract.g_flxcr_csr = 'Y' then
            hr_utility.set_location('entering to open flex credit ' ,160);
            hr_utility.set_location('entering to open flex credit '|| enrt.prtt_enrt_rslt_id ,160);
            open flex_cred_info_c(enrt.prtt_enrt_rslt_id);
            fetch flex_cred_info_c into ben_ext_person.g_flex_credit_provided
                                 ,ben_ext_person.g_flex_credit_forfited
                                 ,ben_ext_person.g_flex_credit_used;

            ben_ext_person.g_flex_credit_excess :=
              nvl(ben_ext_person.g_flex_credit_provided,0) -
              nvl(ben_ext_person.g_flex_credit_forfited,0) -
              nvl(ben_ext_person.g_flex_credit_used,0);
            close flex_cred_info_c;
          end if;
         */
          --
          --
          -- Reporting group informations
          --
          if ben_extract.g_prgrp_csr = 'Y' then
             open c_rpt_grp(enrt.prtt_enrt_rslt_id);
             fetch c_rpt_grp into ben_ext_person.g_enrt_rpt_group_id,
                                  ben_ext_person.g_enrt_rpt_group_name;
             close c_rpt_grp;
          end if;
          --
          --
          -- Plan Year Informations
          -- --B.Burns #: 1641610
          if ben_extract.g_pplyr_csr = 'Y' then
             open c_pl_yr(enrt.prtt_enrt_rslt_id);
             fetch c_pl_yr into ben_ext_person.g_enrt_pl_yr_strdt,
                                ben_ext_person.g_enrt_pl_yr_enddt;
             if c_pl_yr%notfound then
                open c_pgm_yr(enrt.prtt_enrt_rslt_id);
                fetch c_pgm_yr into ben_ext_person.g_enrt_pl_yr_strdt,
                                       ben_ext_person.g_enrt_pl_yr_enddt;
                close c_pgm_yr;
             end if;
             close c_pl_yr;
          end if;
          --end B.Burns
          --
          -- Monthly Total Premium Informations
          --
          if ben_extract.g_pmtpr_csr = 'Y' then
           ben_ext_prem.premium_total(
                          p_person_id          => p_person_id,
                          p_prtt_enrt_rslt_id  => enrt.prtt_enrt_rslt_id,
                          p_ext_rslt_id        => p_ext_rslt_id,
                          p_ext_file_id        => p_ext_file_id,
                          p_data_typ_cd        => p_data_typ_cd,
                          p_ext_typ_cd         => p_ext_typ_cd,
                          p_chg_evt_cd         => p_chg_evt_cd,
                          p_business_group_id  => p_business_group_id,
                          p_effective_date     => p_effective_date
                          );


          end if;
          --
          if ben_extract.g_int_csr = 'Y' then
             if enrt.rplcs_sspndd_rslt_id is not null and enrt.sspndd_flag = 'Y' then
                open c_interim(enrt.rplcs_sspndd_rslt_id);
                fetch c_interim into l_interim;
                if c_interim%FOUND then
                ben_ext_person.g_enrt_int_pl_id   := l_interim.pl_id;
                ben_ext_person.g_enrt_int_pl_name := l_interim.pl_name;
                ben_ext_person.g_enrt_int_opt_id  := l_interim.opt_id;
                ben_ext_person.g_enrt_int_opt_name:= l_interim.opt_name;
                ben_ext_person.g_enrt_int_cvg_amt := l_interim.cvg_amt;
                close c_interim;
                else
                close c_interim;
                end if;
              end if;
          end if;

          -- Interim Flag
          --
          if ben_extract.g_intrm_csr = 'Y' then
             open c_intrm(enrt.prtt_enrt_rslt_id);
             fetch c_intrm into l_dummy;
             if c_intrm%FOUND then
                ben_ext_person.g_enrt_intrcovg_flag := 'Y';
             else
                ben_ext_person.g_enrt_intrcovg_flag := 'N';
             end if;
             close c_intrm;
          end if;
          --
          --
       --
         IF ben_extract.g_enrt_lvl = 'Y' THEN
            --
            -- format and write enrollment
            -- ===========================
            --
            ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                         p_ext_file_id       => p_ext_file_id,
                                         p_data_typ_cd       => p_data_typ_cd,
                                         p_ext_typ_cd        => p_ext_typ_cd,
                                         p_rcd_typ_cd        => 'D',
                                         p_low_lvl_cd        => 'E',
                                         p_person_id         => p_person_id,
                                         p_chg_evt_cd        => p_chg_evt_cd,
                                         p_business_group_id => p_business_group_id,
                                         p_effective_date    => p_effective_date
                                         );
            --
          END IF;


          -- call premium level process
          --
          IF ben_extract.g_prem_lvl = 'Y' then
            --
            ben_ext_prem.main(
                             p_person_id          => p_person_id,
                             p_prtt_enrt_rslt_id  => enrt.prtt_enrt_rslt_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => p_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date
                             );
            --
          END IF;


          --
          -- call dependent level process
          -- ====================================
          --
          IF ben_extract.g_dpnt_lvl = 'Y' then
            --
            ben_ext_dpnt.main(
                             p_person_id          => p_person_id,
                             p_prtt_enrt_rslt_id  => enrt.prtt_enrt_rslt_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => p_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date
                             );
            --
          END IF;
          --
          -- call beneficiary level process
          -- =================================================
          --
          IF ben_extract.g_bnf_lvl = 'Y' then
            --
            ben_ext_bnf.main(
                             p_person_id          => p_person_id,
                             p_prtt_enrt_rslt_id  => enrt.prtt_enrt_rslt_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => p_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date
                             );
            --
          END IF;
          --
          --
          -- call actions level process
          -- =================================================
          --
          IF ben_extract.g_actn_lvl = 'Y' then
            --
            ben_ext_actn.main(
                             p_person_id          => p_person_id,
                             p_prtt_enrt_rslt_id  => enrt.prtt_enrt_rslt_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => p_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date
                             );
            --
          END IF;
          --
     END IF;  -- l_include = 'Y'
     --
   END LOOP;
   hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- main
 --
END;  -- package

/
