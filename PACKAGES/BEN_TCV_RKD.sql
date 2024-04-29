--------------------------------------------------------
--  DDL for Package BEN_TCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TCV_RKD" AUTHID CURRENT_USER as
/* $Header: betcvrhi.pkh 120.0.12010000.1 2008/07/29 13:05:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ttl_cvg_vol_rt_id              in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_excld_flag_o                   in varchar2
 ,p_no_mn_cvg_vol_amt_apls_fla_o  in varchar2
 ,p_no_mx_cvg_vol_amt_apls_fla_o  in varchar2
 ,p_ordr_num_o                     in number
 ,p_mn_cvg_vol_amt_o               in number
 ,p_mx_cvg_vol_amt_o               in number
 ,p_cvg_vol_det_cd_o               in varchar2
 ,p_cvg_vol_det_rl_o               in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_tcv_attribute_category_o       in varchar2
 ,p_tcv_attribute1_o               in varchar2
 ,p_tcv_attribute2_o               in varchar2
 ,p_tcv_attribute3_o               in varchar2
 ,p_tcv_attribute4_o               in varchar2
 ,p_tcv_attribute5_o               in varchar2
 ,p_tcv_attribute6_o               in varchar2
 ,p_tcv_attribute7_o               in varchar2
 ,p_tcv_attribute8_o               in varchar2
 ,p_tcv_attribute9_o               in varchar2
 ,p_tcv_attribute10_o              in varchar2
 ,p_tcv_attribute11_o              in varchar2
 ,p_tcv_attribute12_o              in varchar2
 ,p_tcv_attribute13_o              in varchar2
 ,p_tcv_attribute14_o              in varchar2
 ,p_tcv_attribute15_o              in varchar2
 ,p_tcv_attribute16_o              in varchar2
 ,p_tcv_attribute17_o              in varchar2
 ,p_tcv_attribute18_o              in varchar2
 ,p_tcv_attribute19_o              in varchar2
 ,p_tcv_attribute20_o              in varchar2
 ,p_tcv_attribute21_o              in varchar2
 ,p_tcv_attribute22_o              in varchar2
 ,p_tcv_attribute23_o              in varchar2
 ,p_tcv_attribute24_o              in varchar2
 ,p_tcv_attribute25_o              in varchar2
 ,p_tcv_attribute26_o              in varchar2
 ,p_tcv_attribute27_o              in varchar2
 ,p_tcv_attribute28_o              in varchar2
 ,p_tcv_attribute29_o              in varchar2
 ,p_tcv_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_tcv_rkd;

/
