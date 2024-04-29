--------------------------------------------------------
--  DDL for Package BEN_BNR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNR_RKU" AUTHID CURRENT_USER as
/* $Header: bebnrrhi.pkh 120.0 2005/05/28 00:46:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_rptg_grp_id                    in number
 ,p_name                           in varchar2
 ,p_business_group_id              in number
-- ,p_pgm_id                         in number
 ,p_rptg_prps_cd                   in varchar2
 ,p_rpg_desc                       in varchar2
 ,p_bnr_attribute_category         in varchar2
 ,p_bnr_attribute1                 in varchar2
 ,p_bnr_attribute2                 in varchar2
 ,p_bnr_attribute3                 in varchar2
 ,p_bnr_attribute4                 in varchar2
 ,p_bnr_attribute5                 in varchar2
 ,p_bnr_attribute6                 in varchar2
 ,p_bnr_attribute7                 in varchar2
 ,p_bnr_attribute8                 in varchar2
 ,p_bnr_attribute9                 in varchar2
 ,p_bnr_attribute10                in varchar2
 ,p_bnr_attribute11                in varchar2
 ,p_bnr_attribute12                in varchar2
 ,p_bnr_attribute13                in varchar2
 ,p_bnr_attribute14                in varchar2
 ,p_bnr_attribute15                in varchar2
 ,p_bnr_attribute16                in varchar2
 ,p_bnr_attribute17                in varchar2
 ,p_bnr_attribute18                in varchar2
 ,p_bnr_attribute19                in varchar2
 ,p_bnr_attribute20                in varchar2
 ,p_bnr_attribute21                in varchar2
 ,p_bnr_attribute22                in varchar2
 ,p_bnr_attribute23                in varchar2
 ,p_bnr_attribute24                in varchar2
 ,p_bnr_attribute25                in varchar2
 ,p_bnr_attribute26                in varchar2
 ,p_bnr_attribute27                in varchar2
 ,p_bnr_attribute28                in varchar2
 ,p_bnr_attribute29                in varchar2
 ,p_bnr_attribute30                in varchar2
 ,p_function_code                  in varchar2
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_ordr_num                       in number             --iRec
 ,p_effective_date                 in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
-- ,p_pgm_id_o                       in number
 ,p_rptg_prps_cd_o                 in varchar2
 ,p_rpg_desc_o                     in varchar2
 ,p_bnr_attribute_category_o       in varchar2
 ,p_bnr_attribute1_o               in varchar2
 ,p_bnr_attribute2_o               in varchar2
 ,p_bnr_attribute3_o               in varchar2
 ,p_bnr_attribute4_o               in varchar2
 ,p_bnr_attribute5_o               in varchar2
 ,p_bnr_attribute6_o               in varchar2
 ,p_bnr_attribute7_o               in varchar2
 ,p_bnr_attribute8_o               in varchar2
 ,p_bnr_attribute9_o               in varchar2
 ,p_bnr_attribute10_o              in varchar2
 ,p_bnr_attribute11_o              in varchar2
 ,p_bnr_attribute12_o              in varchar2
 ,p_bnr_attribute13_o              in varchar2
 ,p_bnr_attribute14_o              in varchar2
 ,p_bnr_attribute15_o              in varchar2
 ,p_bnr_attribute16_o              in varchar2
 ,p_bnr_attribute17_o              in varchar2
 ,p_bnr_attribute18_o              in varchar2
 ,p_bnr_attribute19_o              in varchar2
 ,p_bnr_attribute20_o              in varchar2
 ,p_bnr_attribute21_o              in varchar2
 ,p_bnr_attribute22_o              in varchar2
 ,p_bnr_attribute23_o              in varchar2
 ,p_bnr_attribute24_o              in varchar2
 ,p_bnr_attribute25_o              in varchar2
 ,p_bnr_attribute26_o              in varchar2
 ,p_bnr_attribute27_o              in varchar2
 ,p_bnr_attribute28_o              in varchar2
 ,p_bnr_attribute29_o              in varchar2
 ,p_bnr_attribute30_o              in varchar2
 ,p_function_code_o                in varchar2
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
 ,p_ordr_num_o                     in number           --iRec
  );
--
end ben_bnr_rku;

 

/
