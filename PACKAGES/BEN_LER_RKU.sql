--------------------------------------------------------
--  DDL for Package BEN_LER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_RKU" AUTHID CURRENT_USER as
/* $Header: belerrhi.pkh 120.2 2006/11/03 10:24:29 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_id                         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_typ_cd                         in varchar2
 ,p_lf_evt_oper_cd                 in varchar2
 ,p_short_name                in varchar2
 ,p_short_code                in varchar2
 ,p_ptnl_ler_trtmt_cd              in varchar2
 ,p_ck_rltd_per_elig_flag          in varchar2
 ,p_ler_eval_rl                    in number
 ,p_cm_aply_flag                   in varchar2
 ,p_ovridg_le_flag                 in varchar2
 ,p_qualg_evt_flag                 in varchar2
 ,p_whn_to_prcs_cd                 in varchar2
 ,p_desc_txt                       in varchar2
 ,p_tmlns_eval_cd                  in varchar2
 ,p_tmlns_perd_cd                  in varchar2
 ,p_tmlns_dys_num                  in number
 ,p_tmlns_perd_rl                  in number
 ,p_ocrd_dt_det_cd                 in varchar2
 ,p_ler_stat_cd                    in varchar2
 ,p_slctbl_slf_svc_cd              in varchar2
 ,p_ss_pcp_disp_cd                 in varchar2
 ,p_ler_attribute_category         in varchar2
 ,p_ler_attribute1                 in varchar2
 ,p_ler_attribute2                 in varchar2
 ,p_ler_attribute3                 in varchar2
 ,p_ler_attribute4                 in varchar2
 ,p_ler_attribute5                 in varchar2
 ,p_ler_attribute6                 in varchar2
 ,p_ler_attribute7                 in varchar2
 ,p_ler_attribute8                 in varchar2
 ,p_ler_attribute9                 in varchar2
 ,p_ler_attribute10                in varchar2
 ,p_ler_attribute11                in varchar2
 ,p_ler_attribute12                in varchar2
 ,p_ler_attribute13                in varchar2
 ,p_ler_attribute14                in varchar2
 ,p_ler_attribute15                in varchar2
 ,p_ler_attribute16                in varchar2
 ,p_ler_attribute17                in varchar2
 ,p_ler_attribute18                in varchar2
 ,p_ler_attribute19                in varchar2
 ,p_ler_attribute20                in varchar2
 ,p_ler_attribute21                in varchar2
 ,p_ler_attribute22                in varchar2
 ,p_ler_attribute23                in varchar2
 ,p_ler_attribute24                in varchar2
 ,p_ler_attribute25                in varchar2
 ,p_ler_attribute26                in varchar2
 ,p_ler_attribute27                in varchar2
 ,p_ler_attribute28                in varchar2
 ,p_ler_attribute29                in varchar2
 ,p_ler_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_typ_cd_o                       in varchar2
 ,p_lf_evt_oper_cd_o               in varchar2
 ,p_short_name_o                in varchar2
 ,p_short_code_o                in varchar2
 ,p_ptnl_ler_trtmt_cd_o            in varchar2
 ,p_ck_rltd_per_elig_flag_o        in varchar2
 ,p_ler_eval_rl_o                  in number
 ,p_cm_aply_flag_o                 in varchar2
 ,p_ovridg_le_flag_o               in varchar2
 ,p_qualg_evt_flag_o               in varchar2
 ,p_whn_to_prcs_cd_o               in varchar2
 ,p_desc_txt_o                     in varchar2
 ,p_tmlns_eval_cd_o                in varchar2
 ,p_tmlns_perd_cd_o                in varchar2
 ,p_tmlns_dys_num_o                in number
 ,p_tmlns_perd_rl_o                in number
 ,p_ocrd_dt_det_cd_o               in varchar2
 ,p_ler_stat_cd_o                  in varchar2
 ,p_slctbl_slf_svc_cd_o            in varchar2
 ,p_ss_pcp_disp_cd_o               in varchar2
 ,p_ler_attribute_category_o       in varchar2
 ,p_ler_attribute1_o               in varchar2
 ,p_ler_attribute2_o               in varchar2
 ,p_ler_attribute3_o               in varchar2
 ,p_ler_attribute4_o               in varchar2
 ,p_ler_attribute5_o               in varchar2
 ,p_ler_attribute6_o               in varchar2
 ,p_ler_attribute7_o               in varchar2
 ,p_ler_attribute8_o               in varchar2
 ,p_ler_attribute9_o               in varchar2
 ,p_ler_attribute10_o              in varchar2
 ,p_ler_attribute11_o              in varchar2
 ,p_ler_attribute12_o              in varchar2
 ,p_ler_attribute13_o              in varchar2
 ,p_ler_attribute14_o              in varchar2
 ,p_ler_attribute15_o              in varchar2
 ,p_ler_attribute16_o              in varchar2
 ,p_ler_attribute17_o              in varchar2
 ,p_ler_attribute18_o              in varchar2
 ,p_ler_attribute19_o              in varchar2
 ,p_ler_attribute20_o              in varchar2
 ,p_ler_attribute21_o              in varchar2
 ,p_ler_attribute22_o              in varchar2
 ,p_ler_attribute23_o              in varchar2
 ,p_ler_attribute24_o              in varchar2
 ,p_ler_attribute25_o              in varchar2
 ,p_ler_attribute26_o              in varchar2
 ,p_ler_attribute27_o              in varchar2
 ,p_ler_attribute28_o              in varchar2
 ,p_ler_attribute29_o              in varchar2
 ,p_ler_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ler_rku;

/
