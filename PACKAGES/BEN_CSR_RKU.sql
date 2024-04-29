--------------------------------------------------------
--  DDL for Package BEN_CSR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CSR_RKU" AUTHID CURRENT_USER as
/* $Header: becsrrhi.pkh 120.0 2005/05/28 01:24:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_css_rltd_per_per_in_ler_id     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_to_prcs_num               in number
 ,p_ler_id                         in number
 ,p_rsltg_ler_id                   in number
 ,p_business_group_id              in number
 ,p_csr_attribute_category         in varchar2
 ,p_csr_attribute1                 in varchar2
 ,p_csr_attribute2                 in varchar2
 ,p_csr_attribute3                 in varchar2
 ,p_csr_attribute4                 in varchar2
 ,p_csr_attribute5                 in varchar2
 ,p_csr_attribute6                 in varchar2
 ,p_csr_attribute7                 in varchar2
 ,p_csr_attribute8                 in varchar2
 ,p_csr_attribute9                 in varchar2
 ,p_csr_attribute10                in varchar2
 ,p_csr_attribute11                in varchar2
 ,p_csr_attribute12                in varchar2
 ,p_csr_attribute13                in varchar2
 ,p_csr_attribute14                in varchar2
 ,p_csr_attribute15                in varchar2
 ,p_csr_attribute16                in varchar2
 ,p_csr_attribute17                in varchar2
 ,p_csr_attribute18                in varchar2
 ,p_csr_attribute19                in varchar2
 ,p_csr_attribute20                in varchar2
 ,p_csr_attribute21                in varchar2
 ,p_csr_attribute22                in varchar2
 ,p_csr_attribute23                in varchar2
 ,p_csr_attribute24                in varchar2
 ,p_csr_attribute25                in varchar2
 ,p_csr_attribute26                in varchar2
 ,p_csr_attribute27                in varchar2
 ,p_csr_attribute28                in varchar2
 ,p_csr_attribute29                in varchar2
 ,p_csr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_to_prcs_num_o             in number
 ,p_ler_id_o                       in number
 ,p_rsltg_ler_id_o                 in number
 ,p_business_group_id_o            in number
 ,p_csr_attribute_category_o       in varchar2
 ,p_csr_attribute1_o               in varchar2
 ,p_csr_attribute2_o               in varchar2
 ,p_csr_attribute3_o               in varchar2
 ,p_csr_attribute4_o               in varchar2
 ,p_csr_attribute5_o               in varchar2
 ,p_csr_attribute6_o               in varchar2
 ,p_csr_attribute7_o               in varchar2
 ,p_csr_attribute8_o               in varchar2
 ,p_csr_attribute9_o               in varchar2
 ,p_csr_attribute10_o              in varchar2
 ,p_csr_attribute11_o              in varchar2
 ,p_csr_attribute12_o              in varchar2
 ,p_csr_attribute13_o              in varchar2
 ,p_csr_attribute14_o              in varchar2
 ,p_csr_attribute15_o              in varchar2
 ,p_csr_attribute16_o              in varchar2
 ,p_csr_attribute17_o              in varchar2
 ,p_csr_attribute18_o              in varchar2
 ,p_csr_attribute19_o              in varchar2
 ,p_csr_attribute20_o              in varchar2
 ,p_csr_attribute21_o              in varchar2
 ,p_csr_attribute22_o              in varchar2
 ,p_csr_attribute23_o              in varchar2
 ,p_csr_attribute24_o              in varchar2
 ,p_csr_attribute25_o              in varchar2
 ,p_csr_attribute26_o              in varchar2
 ,p_csr_attribute27_o              in varchar2
 ,p_csr_attribute28_o              in varchar2
 ,p_csr_attribute29_o              in varchar2
 ,p_csr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_csr_rku;

 

/
