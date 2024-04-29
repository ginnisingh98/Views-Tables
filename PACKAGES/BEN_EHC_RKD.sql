--------------------------------------------------------
--  DDL for Package BEN_EHC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EHC_RKD" AUTHID CURRENT_USER as
/* $Header: beehcrhi.pkh 120.0 2005/05/28 02:14:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ELIG_HLTH_CVG_PRTE_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_pl_typ_opt_typ_id_o            in number
 ,p_oipl_id_o                      in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_ehc_attribute_category_o       in varchar2
 ,p_ehc_attribute1_o               in varchar2
 ,p_ehc_attribute2_o               in varchar2
 ,p_ehc_attribute3_o               in varchar2
 ,p_ehc_attribute4_o               in varchar2
 ,p_ehc_attribute5_o               in varchar2
 ,p_ehc_attribute6_o               in varchar2
 ,p_ehc_attribute7_o               in varchar2
 ,p_ehc_attribute8_o               in varchar2
 ,p_ehc_attribute9_o               in varchar2
 ,p_ehc_attribute10_o              in varchar2
 ,p_ehc_attribute11_o              in varchar2
 ,p_ehc_attribute12_o              in varchar2
 ,p_ehc_attribute13_o              in varchar2
 ,p_ehc_attribute14_o              in varchar2
 ,p_ehc_attribute15_o              in varchar2
 ,p_ehc_attribute16_o              in varchar2
 ,p_ehc_attribute17_o              in varchar2
 ,p_ehc_attribute18_o              in varchar2
 ,p_ehc_attribute19_o              in varchar2
 ,p_ehc_attribute20_o              in varchar2
 ,p_ehc_attribute21_o              in varchar2
 ,p_ehc_attribute22_o              in varchar2
 ,p_ehc_attribute23_o              in varchar2
 ,p_ehc_attribute24_o              in varchar2
 ,p_ehc_attribute25_o              in varchar2
 ,p_ehc_attribute26_o              in varchar2
 ,p_ehc_attribute27_o              in varchar2
 ,p_ehc_attribute28_o              in varchar2
 ,p_ehc_attribute29_o              in varchar2
 ,p_ehc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ehc_rkd;

 

/
