--------------------------------------------------------
--  DDL for Package BEN_PBB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBB_RKU" AUTHID CURRENT_USER as
/* $Header: bepbbrhi.pkh 120.0 2005/05/28 10:03:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_per_bnfts_bal_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_val                            in number
 ,p_bnfts_bal_id                   in number
 ,p_person_id                      in number
 ,p_business_group_id              in number
 ,p_pbb_attribute_category         in varchar2
 ,p_pbb_attribute1                 in varchar2
 ,p_pbb_attribute2                 in varchar2
 ,p_pbb_attribute3                 in varchar2
 ,p_pbb_attribute4                 in varchar2
 ,p_pbb_attribute5                 in varchar2
 ,p_pbb_attribute6                 in varchar2
 ,p_pbb_attribute7                 in varchar2
 ,p_pbb_attribute8                 in varchar2
 ,p_pbb_attribute9                 in varchar2
 ,p_pbb_attribute10                in varchar2
 ,p_pbb_attribute11                in varchar2
 ,p_pbb_attribute12                in varchar2
 ,p_pbb_attribute13                in varchar2
 ,p_pbb_attribute14                in varchar2
 ,p_pbb_attribute15                in varchar2
 ,p_pbb_attribute16                in varchar2
 ,p_pbb_attribute17                in varchar2
 ,p_pbb_attribute18                in varchar2
 ,p_pbb_attribute19                in varchar2
 ,p_pbb_attribute20                in varchar2
 ,p_pbb_attribute21                in varchar2
 ,p_pbb_attribute22                in varchar2
 ,p_pbb_attribute23                in varchar2
 ,p_pbb_attribute24                in varchar2
 ,p_pbb_attribute25                in varchar2
 ,p_pbb_attribute26                in varchar2
 ,p_pbb_attribute27                in varchar2
 ,p_pbb_attribute28                in varchar2
 ,p_pbb_attribute29                in varchar2
 ,p_pbb_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_val_o                          in number
 ,p_bnfts_bal_id_o                 in number
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_pbb_attribute_category_o       in varchar2
 ,p_pbb_attribute1_o               in varchar2
 ,p_pbb_attribute2_o               in varchar2
 ,p_pbb_attribute3_o               in varchar2
 ,p_pbb_attribute4_o               in varchar2
 ,p_pbb_attribute5_o               in varchar2
 ,p_pbb_attribute6_o               in varchar2
 ,p_pbb_attribute7_o               in varchar2
 ,p_pbb_attribute8_o               in varchar2
 ,p_pbb_attribute9_o               in varchar2
 ,p_pbb_attribute10_o              in varchar2
 ,p_pbb_attribute11_o              in varchar2
 ,p_pbb_attribute12_o              in varchar2
 ,p_pbb_attribute13_o              in varchar2
 ,p_pbb_attribute14_o              in varchar2
 ,p_pbb_attribute15_o              in varchar2
 ,p_pbb_attribute16_o              in varchar2
 ,p_pbb_attribute17_o              in varchar2
 ,p_pbb_attribute18_o              in varchar2
 ,p_pbb_attribute19_o              in varchar2
 ,p_pbb_attribute20_o              in varchar2
 ,p_pbb_attribute21_o              in varchar2
 ,p_pbb_attribute22_o              in varchar2
 ,p_pbb_attribute23_o              in varchar2
 ,p_pbb_attribute24_o              in varchar2
 ,p_pbb_attribute25_o              in varchar2
 ,p_pbb_attribute26_o              in varchar2
 ,p_pbb_attribute27_o              in varchar2
 ,p_pbb_attribute28_o              in varchar2
 ,p_pbb_attribute29_o              in varchar2
 ,p_pbb_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pbb_rku;

 

/
