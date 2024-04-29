--------------------------------------------------------
--  DDL for Package BEN_LRC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRC_RKU" AUTHID CURRENT_USER as
/* $Header: belrcrhi.pkh 120.0 2005/05/28 03:33:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_rltd_per_cs_ler_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ler_rltd_per_cs_chg_rl         in number
 ,p_ler_id                         in number
 ,p_rltd_per_chg_cs_ler_id         in number
 ,p_business_group_id              in number
 ,p_lrc_attribute_category         in varchar2
 ,p_lrc_attribute1                 in varchar2
 ,p_lrc_attribute2                 in varchar2
 ,p_lrc_attribute3                 in varchar2
 ,p_lrc_attribute4                 in varchar2
 ,p_lrc_attribute5                 in varchar2
 ,p_lrc_attribute6                 in varchar2
 ,p_lrc_attribute7                 in varchar2
 ,p_lrc_attribute8                 in varchar2
 ,p_lrc_attribute9                 in varchar2
 ,p_lrc_attribute10                in varchar2
 ,p_lrc_attribute11                in varchar2
 ,p_lrc_attribute12                in varchar2
 ,p_lrc_attribute13                in varchar2
 ,p_lrc_attribute14                in varchar2
 ,p_lrc_attribute15                in varchar2
 ,p_lrc_attribute16                in varchar2
 ,p_lrc_attribute17                in varchar2
 ,p_lrc_attribute18                in varchar2
 ,p_lrc_attribute19                in varchar2
 ,p_lrc_attribute20                in varchar2
 ,p_lrc_attribute21                in varchar2
 ,p_lrc_attribute22                in varchar2
 ,p_lrc_attribute23                in varchar2
 ,p_lrc_attribute24                in varchar2
 ,p_lrc_attribute25                in varchar2
 ,p_lrc_attribute26                in varchar2
 ,p_lrc_attribute27                in varchar2
 ,p_lrc_attribute28                in varchar2
 ,p_lrc_attribute29                in varchar2
 ,p_lrc_attribute30                in varchar2
 ,p_chg_mandatory_cd                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ler_rltd_per_cs_chg_rl_o       in number
 ,p_ler_id_o                       in number
 ,p_rltd_per_chg_cs_ler_id_o       in number
 ,p_business_group_id_o            in number
 ,p_lrc_attribute_category_o       in varchar2
 ,p_lrc_attribute1_o               in varchar2
 ,p_lrc_attribute2_o               in varchar2
 ,p_lrc_attribute3_o               in varchar2
 ,p_lrc_attribute4_o               in varchar2
 ,p_lrc_attribute5_o               in varchar2
 ,p_lrc_attribute6_o               in varchar2
 ,p_lrc_attribute7_o               in varchar2
 ,p_lrc_attribute8_o               in varchar2
 ,p_lrc_attribute9_o               in varchar2
 ,p_lrc_attribute10_o              in varchar2
 ,p_lrc_attribute11_o              in varchar2
 ,p_lrc_attribute12_o              in varchar2
 ,p_lrc_attribute13_o              in varchar2
 ,p_lrc_attribute14_o              in varchar2
 ,p_lrc_attribute15_o              in varchar2
 ,p_lrc_attribute16_o              in varchar2
 ,p_lrc_attribute17_o              in varchar2
 ,p_lrc_attribute18_o              in varchar2
 ,p_lrc_attribute19_o              in varchar2
 ,p_lrc_attribute20_o              in varchar2
 ,p_lrc_attribute21_o              in varchar2
 ,p_lrc_attribute22_o              in varchar2
 ,p_lrc_attribute23_o              in varchar2
 ,p_lrc_attribute24_o              in varchar2
 ,p_lrc_attribute25_o              in varchar2
 ,p_lrc_attribute26_o              in varchar2
 ,p_lrc_attribute27_o              in varchar2
 ,p_lrc_attribute28_o              in varchar2
 ,p_lrc_attribute29_o              in varchar2
 ,p_lrc_attribute30_o              in varchar2
 ,p_chg_mandatory_cd_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lrc_rku;

 

/
