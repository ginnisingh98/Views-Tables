--------------------------------------------------------
--  DDL for Package BEN_ENP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENP_RKD" AUTHID CURRENT_USER as
/* $Header: beenprhi.pkh 120.1 2007/05/13 22:29:48 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_enrt_perd_id                   in number
 ,p_business_group_id_o            in number
 ,p_yr_perd_id_o                   in number
 ,p_popl_enrt_typ_cycl_id_o        in number
 ,p_end_dt_o                       in date
 ,p_strt_dt_o                      in date
 ,p_asnd_lf_evt_dt_o               in date
 ,p_cls_enrt_dt_to_use_cd_o        in varchar2
 ,p_dflt_enrt_dt_o                 in date
 ,p_enrt_cvg_strt_dt_cd_o          in varchar2
 ,p_rt_strt_dt_rl_o                in number
 ,p_enrt_cvg_end_dt_cd_o           in varchar2
 ,p_enrt_cvg_strt_dt_rl_o          in number
 ,p_enrt_cvg_end_dt_rl_o           in number
 ,p_procg_end_dt_o                 in date
 ,p_rt_strt_dt_cd_o                in varchar2
 ,p_rt_end_dt_cd_o                 in varchar2
 ,p_rt_end_dt_rl_o                 in number
 ,p_bdgt_upd_strt_dt_o             in date
 ,p_bdgt_upd_end_dt_o              in date
 ,p_ws_upd_strt_dt_o               in date
 ,p_ws_upd_end_dt_o                in date
 ,p_dflt_ws_acc_cd_o               in varchar2
 ,p_prsvr_bdgt_cd_o                in varchar2
 ,p_uses_bdgt_flag_o               in varchar2
 ,p_auto_distr_flag_o              in varchar2
 ,p_hrchy_to_use_cd_o              in varchar2
 ,p_pos_structure_version_id_o        in number
 ,p_emp_interview_type_cd_o        in varchar2
 ,p_wthn_yr_perd_id_o              in number
 ,p_ler_id_o                       in number
 ,p_perf_revw_strt_dt_o            in date
 ,p_asg_updt_eff_date_o            in date
 ,p_enp_attribute_category_o       in varchar2
 ,p_enp_attribute1_o               in varchar2
 ,p_enp_attribute2_o               in varchar2
 ,p_enp_attribute3_o               in varchar2
 ,p_enp_attribute4_o               in varchar2
 ,p_enp_attribute5_o               in varchar2
 ,p_enp_attribute6_o               in varchar2
 ,p_enp_attribute7_o               in varchar2
 ,p_enp_attribute8_o               in varchar2
 ,p_enp_attribute9_o               in varchar2
 ,p_enp_attribute10_o              in varchar2
 ,p_enp_attribute11_o              in varchar2
 ,p_enp_attribute12_o              in varchar2
 ,p_enp_attribute13_o              in varchar2
 ,p_enp_attribute14_o              in varchar2
 ,p_enp_attribute15_o              in varchar2
 ,p_enp_attribute16_o              in varchar2
 ,p_enp_attribute17_o              in varchar2
 ,p_enp_attribute18_o              in varchar2
 ,p_enp_attribute19_o              in varchar2
 ,p_enp_attribute20_o              in varchar2
 ,p_enp_attribute21_o              in varchar2
 ,p_enp_attribute22_o              in varchar2
 ,p_enp_attribute23_o              in varchar2
 ,p_enp_attribute24_o              in varchar2
 ,p_enp_attribute25_o              in varchar2
 ,p_enp_attribute26_o              in varchar2
 ,p_enp_attribute27_o              in varchar2
 ,p_enp_attribute28_o              in varchar2
 ,p_enp_attribute29_o              in varchar2
 ,p_enp_attribute30_o              in varchar2
 --,p_enrt_perd_det_ovrlp_bckdt_cd_o              in varchar2
 ,p_enrt_perd_det_ovrlp_cd_o              in varchar2
 --cwb
 ,p_data_freeze_date_o             in  date
 ,p_Sal_chg_reason_cd_o            in  varchar2
 ,p_Approval_mode_cd_o             in  varchar2
 ,p_hrchy_ame_trn_cd_o             in  varchar2
 ,p_hrchy_rl_o                     in  number
 ,p_hrchy_ame_app_id_o             in  number
  --
 ,p_object_version_number_o        in number
 ,p_reinstate_cd_o				in varchar2
 ,p_reinstate_ovrdn_cd_o		in varchar2
 ,p_defer_deenrol_flag_o           in varchar2
  );
--
end ben_enp_rkd;

/
