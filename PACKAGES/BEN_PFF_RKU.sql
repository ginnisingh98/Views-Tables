--------------------------------------------------------
--  DDL for Package BEN_PFF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PFF_RKU" AUTHID CURRENT_USER as
/* $Header: bepffrhi.pkh 120.0 2005/05/28 10:42:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pct_fl_tm_fctr_id              in number
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_mx_pct_val                     in number
 ,p_mn_pct_val                     in number
 ,p_no_mn_pct_val_flag             in varchar2
 ,p_no_mx_pct_val_flag             in varchar2
 ,p_use_prmry_asnt_only_flag       in varchar2
 ,p_use_sum_of_all_asnts_flag      in varchar2
 ,p_rndg_cd                        in varchar2
 ,p_rndg_rl                        in number
 ,p_pff_attribute_category         in varchar2
 ,p_pff_attribute1                 in varchar2
 ,p_pff_attribute2                 in varchar2
 ,p_pff_attribute3                 in varchar2
 ,p_pff_attribute4                 in varchar2
 ,p_pff_attribute5                 in varchar2
 ,p_pff_attribute6                 in varchar2
 ,p_pff_attribute7                 in varchar2
 ,p_pff_attribute8                 in varchar2
 ,p_pff_attribute9                 in varchar2
 ,p_pff_attribute10                in varchar2
 ,p_pff_attribute11                in varchar2
 ,p_pff_attribute12                in varchar2
 ,p_pff_attribute13                in varchar2
 ,p_pff_attribute14                in varchar2
 ,p_pff_attribute15                in varchar2
 ,p_pff_attribute16                in varchar2
 ,p_pff_attribute17                in varchar2
 ,p_pff_attribute18                in varchar2
 ,p_pff_attribute19                in varchar2
 ,p_pff_attribute20                in varchar2
 ,p_pff_attribute21                in varchar2
 ,p_pff_attribute22                in varchar2
 ,p_pff_attribute23                in varchar2
 ,p_pff_attribute24                in varchar2
 ,p_pff_attribute25                in varchar2
 ,p_pff_attribute26                in varchar2
 ,p_pff_attribute27                in varchar2
 ,p_pff_attribute28                in varchar2
 ,p_pff_attribute29                in varchar2
 ,p_pff_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_mx_pct_val_o                   in number
 ,p_mn_pct_val_o                   in number
 ,p_no_mn_pct_val_flag_o           in varchar2
 ,p_no_mx_pct_val_flag_o           in varchar2
 ,p_use_prmry_asnt_only_flag_o     in varchar2
 ,p_use_sum_of_all_asnts_flag_o    in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_pff_attribute_category_o       in varchar2
 ,p_pff_attribute1_o               in varchar2
 ,p_pff_attribute2_o               in varchar2
 ,p_pff_attribute3_o               in varchar2
 ,p_pff_attribute4_o               in varchar2
 ,p_pff_attribute5_o               in varchar2
 ,p_pff_attribute6_o               in varchar2
 ,p_pff_attribute7_o               in varchar2
 ,p_pff_attribute8_o               in varchar2
 ,p_pff_attribute9_o               in varchar2
 ,p_pff_attribute10_o              in varchar2
 ,p_pff_attribute11_o              in varchar2
 ,p_pff_attribute12_o              in varchar2
 ,p_pff_attribute13_o              in varchar2
 ,p_pff_attribute14_o              in varchar2
 ,p_pff_attribute15_o              in varchar2
 ,p_pff_attribute16_o              in varchar2
 ,p_pff_attribute17_o              in varchar2
 ,p_pff_attribute18_o              in varchar2
 ,p_pff_attribute19_o              in varchar2
 ,p_pff_attribute20_o              in varchar2
 ,p_pff_attribute21_o              in varchar2
 ,p_pff_attribute22_o              in varchar2
 ,p_pff_attribute23_o              in varchar2
 ,p_pff_attribute24_o              in varchar2
 ,p_pff_attribute25_o              in varchar2
 ,p_pff_attribute26_o              in varchar2
 ,p_pff_attribute27_o              in varchar2
 ,p_pff_attribute28_o              in varchar2
 ,p_pff_attribute29_o              in varchar2
 ,p_pff_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pff_rku;

 

/
