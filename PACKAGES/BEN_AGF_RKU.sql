--------------------------------------------------------
--  DDL for Package BEN_AGF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AGF_RKU" AUTHID CURRENT_USER as
/* $Header: beagfrhi.pkh 120.0 2005/05/28 00:23:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_age_fctr_id                    in number
 ,p_name                           in varchar2
 ,p_mx_age_num                     in number
 ,p_mn_age_num                     in number
 ,p_age_uom                        in varchar2
 ,p_no_mn_age_flag                 in varchar2
 ,p_no_mx_age_flag                 in varchar2
 ,p_age_to_use_cd                  in varchar2
 ,p_age_det_cd                     in varchar2
 ,p_age_det_rl                     in number
 ,p_rndg_cd                        in varchar2
 ,p_rndg_rl                        in number
 ,p_age_calc_rl                    in number
 ,p_business_group_id              in number
 ,p_agf_attribute_category         in varchar2
 ,p_agf_attribute1                 in varchar2
 ,p_agf_attribute2                 in varchar2
 ,p_agf_attribute3                 in varchar2
 ,p_agf_attribute4                 in varchar2
 ,p_agf_attribute5                 in varchar2
 ,p_agf_attribute6                 in varchar2
 ,p_agf_attribute7                 in varchar2
 ,p_agf_attribute8                 in varchar2
 ,p_agf_attribute9                 in varchar2
 ,p_agf_attribute10                in varchar2
 ,p_agf_attribute11                in varchar2
 ,p_agf_attribute12                in varchar2
 ,p_agf_attribute13                in varchar2
 ,p_agf_attribute14                in varchar2
 ,p_agf_attribute15                in varchar2
 ,p_agf_attribute16                in varchar2
 ,p_agf_attribute17                in varchar2
 ,p_agf_attribute18                in varchar2
 ,p_agf_attribute19                in varchar2
 ,p_agf_attribute20                in varchar2
 ,p_agf_attribute21                in varchar2
 ,p_agf_attribute22                in varchar2
 ,p_agf_attribute23                in varchar2
 ,p_agf_attribute24                in varchar2
 ,p_agf_attribute25                in varchar2
 ,p_agf_attribute26                in varchar2
 ,p_agf_attribute27                in varchar2
 ,p_agf_attribute28                in varchar2
 ,p_agf_attribute29                in varchar2
 ,p_agf_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_name_o                         in varchar2
 ,p_mx_age_num_o                   in number
 ,p_mn_age_num_o                   in number
 ,p_age_uom_o                      in varchar2
 ,p_no_mn_age_flag_o               in varchar2
 ,p_no_mx_age_flag_o               in varchar2
 ,p_age_to_use_cd_o                in varchar2
 ,p_age_det_cd_o                   in varchar2
 ,p_age_det_rl_o                   in number
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_age_calc_rl_o                  in number
 ,p_business_group_id_o            in number
 ,p_agf_attribute_category_o       in varchar2
 ,p_agf_attribute1_o               in varchar2
 ,p_agf_attribute2_o               in varchar2
 ,p_agf_attribute3_o               in varchar2
 ,p_agf_attribute4_o               in varchar2
 ,p_agf_attribute5_o               in varchar2
 ,p_agf_attribute6_o               in varchar2
 ,p_agf_attribute7_o               in varchar2
 ,p_agf_attribute8_o               in varchar2
 ,p_agf_attribute9_o               in varchar2
 ,p_agf_attribute10_o              in varchar2
 ,p_agf_attribute11_o              in varchar2
 ,p_agf_attribute12_o              in varchar2
 ,p_agf_attribute13_o              in varchar2
 ,p_agf_attribute14_o              in varchar2
 ,p_agf_attribute15_o              in varchar2
 ,p_agf_attribute16_o              in varchar2
 ,p_agf_attribute17_o              in varchar2
 ,p_agf_attribute18_o              in varchar2
 ,p_agf_attribute19_o              in varchar2
 ,p_agf_attribute20_o              in varchar2
 ,p_agf_attribute21_o              in varchar2
 ,p_agf_attribute22_o              in varchar2
 ,p_agf_attribute23_o              in varchar2
 ,p_agf_attribute24_o              in varchar2
 ,p_agf_attribute25_o              in varchar2
 ,p_agf_attribute26_o              in varchar2
 ,p_agf_attribute27_o              in varchar2
 ,p_agf_attribute28_o              in varchar2
 ,p_agf_attribute29_o              in varchar2
 ,p_agf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_agf_rku;

 

/
