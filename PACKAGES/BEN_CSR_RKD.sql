--------------------------------------------------------
--  DDL for Package BEN_CSR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CSR_RKD" AUTHID CURRENT_USER as
/* $Header: becsrrhi.pkh 120.0 2005/05/28 01:24:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_css_rltd_per_per_in_ler_id     in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_csr_rkd;

 

/
