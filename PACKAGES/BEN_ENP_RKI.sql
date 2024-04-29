--------------------------------------------------------
--  DDL for Package BEN_ENP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENP_RKI" AUTHID CURRENT_USER as
/* $Header: beenprhi.pkh 120.1 2007/05/13 22:29:48 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_enrt_perd_id                   in number
 ,p_business_group_id              in number
 ,p_yr_perd_id                     in number
 ,p_popl_enrt_typ_cycl_id          in number
 ,p_end_dt                         in date
 ,p_strt_dt                        in date
 ,p_asnd_lf_evt_dt                 in date
 ,p_cls_enrt_dt_to_use_cd          in varchar2
 ,p_dflt_enrt_dt                   in date
 ,p_enrt_cvg_strt_dt_cd            in varchar2
 ,p_rt_strt_dt_rl                  in number
 ,p_enrt_cvg_end_dt_cd             in varchar2
 ,p_enrt_cvg_strt_dt_rl            in number
 ,p_enrt_cvg_end_dt_rl             in number
 ,p_procg_end_dt                   in date
 ,p_rt_strt_dt_cd                  in varchar2
 ,p_rt_end_dt_cd                   in varchar2
 ,p_rt_end_dt_rl                   in number
 ,p_bdgt_upd_strt_dt               in date
 ,p_bdgt_upd_end_dt                in date
 ,p_ws_upd_strt_dt                 in date
 ,p_ws_upd_end_dt                  in date
 ,p_dflt_ws_acc_cd                 in varchar2
 ,p_prsvr_bdgt_cd                  in varchar2
 ,p_uses_bdgt_flag                 in varchar2
 ,p_auto_distr_flag                in varchar2
 ,p_hrchy_to_use_cd                in varchar2
 ,p_pos_structure_version_id          in number
 ,p_emp_interview_type_cd          in varchar2
 ,p_wthn_yr_perd_id                in number
 ,p_ler_id                         in number
 ,p_perf_revw_strt_dt              in date
 ,p_asg_updt_eff_date              in date
 ,p_enp_attribute_category         in varchar2
 ,p_enp_attribute1                 in varchar2
 ,p_enp_attribute2                 in varchar2
 ,p_enp_attribute3                 in varchar2
 ,p_enp_attribute4                 in varchar2
 ,p_enp_attribute5                 in varchar2
 ,p_enp_attribute6                 in varchar2
 ,p_enp_attribute7                 in varchar2
 ,p_enp_attribute8                 in varchar2
 ,p_enp_attribute9                 in varchar2
 ,p_enp_attribute10                in varchar2
 ,p_enp_attribute11                in varchar2
 ,p_enp_attribute12                in varchar2
 ,p_enp_attribute13                in varchar2
 ,p_enp_attribute14                in varchar2
 ,p_enp_attribute15                in varchar2
 ,p_enp_attribute16                in varchar2
 ,p_enp_attribute17                in varchar2
 ,p_enp_attribute18                in varchar2
 ,p_enp_attribute19                in varchar2
 ,p_enp_attribute20                in varchar2
 ,p_enp_attribute21                in varchar2
 ,p_enp_attribute22                in varchar2
 ,p_enp_attribute23                in varchar2
 ,p_enp_attribute24                in varchar2
 ,p_enp_attribute25                in varchar2
 ,p_enp_attribute26                in varchar2
 ,p_enp_attribute27                in varchar2
 ,p_enp_attribute28                in varchar2
 ,p_enp_attribute29                in varchar2
 ,p_enp_attribute30                in varchar2
 ,p_enrt_perd_det_ovrlp_bckdt_cd   in varchar2
  --cwb
 ,p_data_freeze_date               in  date
 ,p_Sal_chg_reason_cd              in  varchar2
 ,p_Approval_mode_cd               in  varchar2
 ,p_hrchy_ame_trn_cd               in  varchar2
 ,p_hrchy_rl                       in  number
 ,p_hrchy_ame_app_id               in  number
  --
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_reinstate_cd		   in varchar2
 ,p_reinstate_ovrdn_cd		   in varchar2
 ,p_defer_deenrol_flag             in varchar2
  );
end ben_enp_rki;

/
