--------------------------------------------------------
--  DDL for Package BEN_LBR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LBR_RKD" AUTHID CURRENT_USER as
/* $Header: belbrrhi.pkh 120.0 2005/05/28 03:17:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_bnft_rstrn_id              in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_no_mx_cvg_amt_apls_flag_o      in varchar2
 ,p_no_mn_cvg_incr_apls_flag_o     in varchar2
 ,p_no_mx_cvg_incr_apls_flag_o     in varchar2
 ,p_mx_cvg_incr_wcf_alwd_amt_o     in number
 ,p_mx_cvg_incr_alwd_amt_o         in number
 ,p_mx_cvg_alwd_amt_o              in number
 ,p_mx_cvg_mlt_incr_num_o          in number
 ,p_mx_cvg_mlt_incr_wcf_num_o      in number
 ,p_mx_cvg_rl_o                    in number
 ,p_mx_cvg_wcfn_amt_o              in number
 ,p_mx_cvg_wcfn_mlt_num_o          in number
 ,p_mn_cvg_amt_o                   in number
 ,p_mn_cvg_rl_o                    in number
 ,p_cvg_incr_r_decr_only_cd_o      in varchar2
 ,p_unsspnd_enrt_cd_o              in varchar2
 ,p_dflt_to_asn_pndg_ctfn_cd_o     in varchar2
 ,p_dflt_to_asn_pndg_ctfn_rl_o     in number
 ,p_ler_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_business_group_id_o            in number
 ,p_plip_id_o                      in number
 ,p_lbr_attribute_category_o       in varchar2
 ,p_lbr_attribute1_o               in varchar2
 ,p_lbr_attribute2_o               in varchar2
 ,p_lbr_attribute3_o               in varchar2
 ,p_lbr_attribute4_o               in varchar2
 ,p_lbr_attribute5_o               in varchar2
 ,p_lbr_attribute6_o               in varchar2
 ,p_lbr_attribute7_o               in varchar2
 ,p_lbr_attribute8_o               in varchar2
 ,p_lbr_attribute9_o               in varchar2
 ,p_lbr_attribute10_o              in varchar2
 ,p_lbr_attribute11_o              in varchar2
 ,p_lbr_attribute12_o              in varchar2
 ,p_lbr_attribute13_o              in varchar2
 ,p_lbr_attribute14_o              in varchar2
 ,p_lbr_attribute15_o              in varchar2
 ,p_lbr_attribute16_o              in varchar2
 ,p_lbr_attribute17_o              in varchar2
 ,p_lbr_attribute18_o              in varchar2
 ,p_lbr_attribute19_o              in varchar2
 ,p_lbr_attribute20_o              in varchar2
 ,p_lbr_attribute21_o              in varchar2
 ,p_lbr_attribute22_o              in varchar2
 ,p_lbr_attribute23_o              in varchar2
 ,p_lbr_attribute24_o              in varchar2
 ,p_lbr_attribute25_o              in varchar2
 ,p_lbr_attribute26_o              in varchar2
 ,p_lbr_attribute27_o              in varchar2
 ,p_lbr_attribute28_o              in varchar2
 ,p_lbr_attribute29_o              in varchar2
 ,p_lbr_attribute30_o              in varchar2
 ,p_susp_if_ctfn_not_prvd_flag_o   in varchar2
 ,p_ctfn_determine_cd_o            in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lbr_rkd;

 

/
