--------------------------------------------------------
--  DDL for Package BEN_LSF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LSF_RKD" AUTHID CURRENT_USER as
/* $Header: belsfrhi.pkh 120.0 2005/05/28 03:37:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_los_fctr_id                    in number
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_los_det_cd_o                   in varchar2
 ,p_los_det_rl_o                   in number
 ,p_mn_los_num_o                   in number
 ,p_mx_los_num_o                   in number
 ,p_no_mx_los_num_apls_flag_o      in varchar2
 ,p_no_mn_los_num_apls_flag_o      in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_los_dt_to_use_cd_o             in varchar2
 ,p_los_dt_to_use_rl_o             in number
 ,p_los_uom_o                      in varchar2
 ,p_los_calc_rl_o                  in number
 ,p_los_alt_val_to_use_cd_o        in varchar2
 ,p_lsf_attribute_category_o       in varchar2
 ,p_lsf_attribute1_o               in varchar2
 ,p_lsf_attribute2_o               in varchar2
 ,p_lsf_attribute3_o               in varchar2
 ,p_lsf_attribute4_o               in varchar2
 ,p_lsf_attribute5_o               in varchar2
 ,p_lsf_attribute6_o               in varchar2
 ,p_lsf_attribute7_o               in varchar2
 ,p_lsf_attribute8_o               in varchar2
 ,p_lsf_attribute9_o               in varchar2
 ,p_lsf_attribute10_o              in varchar2
 ,p_lsf_attribute11_o              in varchar2
 ,p_lsf_attribute12_o              in varchar2
 ,p_lsf_attribute13_o              in varchar2
 ,p_lsf_attribute14_o              in varchar2
 ,p_lsf_attribute15_o              in varchar2
 ,p_lsf_attribute16_o              in varchar2
 ,p_lsf_attribute17_o              in varchar2
 ,p_lsf_attribute18_o              in varchar2
 ,p_lsf_attribute19_o              in varchar2
 ,p_lsf_attribute20_o              in varchar2
 ,p_lsf_attribute21_o              in varchar2
 ,p_lsf_attribute22_o              in varchar2
 ,p_lsf_attribute23_o              in varchar2
 ,p_lsf_attribute24_o              in varchar2
 ,p_lsf_attribute25_o              in varchar2
 ,p_lsf_attribute26_o              in varchar2
 ,p_lsf_attribute27_o              in varchar2
 ,p_lsf_attribute28_o              in varchar2
 ,p_lsf_attribute29_o              in varchar2
 ,p_lsf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_use_overid_svc_dt_flag_o       in varchar2
  );
--
end ben_lsf_rkd;

 

/
