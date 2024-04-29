--------------------------------------------------------
--  DDL for Package BEN_LER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_RKD" AUTHID CURRENT_USER as
/* $Header: belerrhi.pkh 120.2 2006/11/03 10:24:29 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_id                         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_ler_rkd;

/
