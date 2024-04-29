--------------------------------------------------------
--  DDL for Package BEN_LEN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LEN_RKD" AUTHID CURRENT_USER as
/* $Header: belenrhi.pkh 120.1 2007/05/13 22:39:07 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_lee_rsn_id                     in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_popl_enrt_typ_cycl_id_o        in number
 ,p_ler_id_o                       in number
 ,p_cls_enrt_dt_to_use_cd_o        in varchar2
 ,p_dys_aftr_end_to_dflt_num_o     in number
 ,p_enrt_cvg_end_dt_cd_o           in varchar2
 ,p_enrt_cvg_strt_dt_cd_o          in varchar2
 ,p_enrt_perd_strt_dt_cd_o         in varchar2
 ,p_enrt_perd_strt_dt_rl_o         in number
 ,p_enrt_perd_end_dt_cd_o          in varchar2
 ,p_enrt_perd_end_dt_rl_o          in number
 ,p_addl_procg_dys_num_o           in number
 ,p_dys_no_enrl_not_elig_num_o     in number
 ,p_dys_no_enrl_cant_enrl_num_o    in number
 ,p_rt_end_dt_cd_o                 in varchar2
 ,p_rt_end_dt_rl_o                 in number
 ,p_rt_strt_dt_cd_o                in varchar2
 ,p_rt_strt_dt_rl_o                in number
 ,p_enrt_cvg_end_dt_rl_o           in number
 ,p_enrt_cvg_strt_dt_rl_o          in number
 ,p_len_attribute_category_o      in varchar2
 ,p_len_attribute1_o              in varchar2
 ,p_len_attribute2_o              in varchar2
 ,p_len_attribute3_o              in varchar2
 ,p_len_attribute4_o              in varchar2
 ,p_len_attribute5_o              in varchar2
 ,p_len_attribute6_o              in varchar2
 ,p_len_attribute7_o              in varchar2
 ,p_len_attribute8_o              in varchar2
 ,p_len_attribute9_o              in varchar2
 ,p_len_attribute10_o             in varchar2
 ,p_len_attribute11_o             in varchar2
 ,p_len_attribute12_o             in varchar2
 ,p_len_attribute13_o             in varchar2
 ,p_len_attribute14_o             in varchar2
 ,p_len_attribute15_o             in varchar2
 ,p_len_attribute16_o             in varchar2
 ,p_len_attribute17_o             in varchar2
 ,p_len_attribute18_o             in varchar2
 ,p_len_attribute19_o             in varchar2
 ,p_len_attribute20_o             in varchar2
 ,p_len_attribute21_o             in varchar2
 ,p_len_attribute22_o             in varchar2
 ,p_len_attribute23_o             in varchar2
 ,p_len_attribute24_o             in varchar2
 ,p_len_attribute25_o             in varchar2
 ,p_len_attribute26_o             in varchar2
 ,p_len_attribute27_o             in varchar2
 ,p_len_attribute28_o             in varchar2
 ,p_len_attribute29_o             in varchar2
 ,p_len_attribute30_o             in varchar2
 ,p_object_version_number_o        in number
 --,p_enrt_perd_det_ovrlp_bckdt_cd_o             in varchar2
 ,p_enrt_perd_det_ovrlp_cd_o             in varchar2
  ,p_reinstate_cd_o			in varchar2
 ,p_reinstate_ovrdn_cd_o		in varchar2
 ,p_ENRT_PERD_STRT_DAYS_o		in number
 ,p_ENRT_PERD_END_DAYS_o		in number
 ,p_defer_deenrol_flag_o            in varchar2
  );
--
end ben_len_rkd;

/
