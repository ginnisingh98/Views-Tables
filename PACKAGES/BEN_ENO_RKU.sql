--------------------------------------------------------
--  DDL for Package BEN_ENO_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENO_RKU" AUTHID CURRENT_USER as
/* $Header: beenorhi.pkh 120.0 2005/05/28 02:29:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_no_othr_cvg_prte_id       in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_coord_ben_no_cvg_flag          in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_eno_attribute_category         in varchar2
 ,p_eno_attribute1                 in varchar2
 ,p_eno_attribute2                 in varchar2
 ,p_eno_attribute3                 in varchar2
 ,p_eno_attribute4                 in varchar2
 ,p_eno_attribute5                 in varchar2
 ,p_eno_attribute6                 in varchar2
 ,p_eno_attribute7                 in varchar2
 ,p_eno_attribute8                 in varchar2
 ,p_eno_attribute9                 in varchar2
 ,p_eno_attribute10                in varchar2
 ,p_eno_attribute11                in varchar2
 ,p_eno_attribute12                in varchar2
 ,p_eno_attribute13                in varchar2
 ,p_eno_attribute14                in varchar2
 ,p_eno_attribute15                in varchar2
 ,p_eno_attribute16                in varchar2
 ,p_eno_attribute17                in varchar2
 ,p_eno_attribute18                in varchar2
 ,p_eno_attribute19                in varchar2
 ,p_eno_attribute20                in varchar2
 ,p_eno_attribute21                in varchar2
 ,p_eno_attribute22                in varchar2
 ,p_eno_attribute23                in varchar2
 ,p_eno_attribute24                in varchar2
 ,p_eno_attribute25                in varchar2
 ,p_eno_attribute26                in varchar2
 ,p_eno_attribute27                in varchar2
 ,p_eno_attribute28                in varchar2
 ,p_eno_attribute29                in varchar2
 ,p_eno_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_coord_ben_no_cvg_flag_o        in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_eno_attribute_category_o       in varchar2
 ,p_eno_attribute1_o               in varchar2
 ,p_eno_attribute2_o               in varchar2
 ,p_eno_attribute3_o               in varchar2
 ,p_eno_attribute4_o               in varchar2
 ,p_eno_attribute5_o               in varchar2
 ,p_eno_attribute6_o               in varchar2
 ,p_eno_attribute7_o               in varchar2
 ,p_eno_attribute8_o               in varchar2
 ,p_eno_attribute9_o               in varchar2
 ,p_eno_attribute10_o              in varchar2
 ,p_eno_attribute11_o              in varchar2
 ,p_eno_attribute12_o              in varchar2
 ,p_eno_attribute13_o              in varchar2
 ,p_eno_attribute14_o              in varchar2
 ,p_eno_attribute15_o              in varchar2
 ,p_eno_attribute16_o              in varchar2
 ,p_eno_attribute17_o              in varchar2
 ,p_eno_attribute18_o              in varchar2
 ,p_eno_attribute19_o              in varchar2
 ,p_eno_attribute20_o              in varchar2
 ,p_eno_attribute21_o              in varchar2
 ,p_eno_attribute22_o              in varchar2
 ,p_eno_attribute23_o              in varchar2
 ,p_eno_attribute24_o              in varchar2
 ,p_eno_attribute25_o              in varchar2
 ,p_eno_attribute26_o              in varchar2
 ,p_eno_attribute27_o              in varchar2
 ,p_eno_attribute28_o              in varchar2
 ,p_eno_attribute29_o              in varchar2
 ,p_eno_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eno_rku;

 

/
