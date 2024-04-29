--------------------------------------------------------
--  DDL for Package BEN_LMM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LMM_RKD" AUTHID CURRENT_USER as
/* $Header: belmmrhi.pkh 120.0 2005/05/28 03:24:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_lbr_mmbr_rt_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_excld_flag_o                   in varchar2
 ,p_lbr_mmbr_flag_o                in varchar2
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 , p_lmm_attribute_category_o      in varchar2
 , p_lmm_attribute1_o              in varchar2
 , p_lmm_attribute2_o              in varchar2
 , p_lmm_attribute3_o              in varchar2
 , p_lmm_attribute4_o              in varchar2
 , p_lmm_attribute5_o              in varchar2
 , p_lmm_attribute6_o              in varchar2
 , p_lmm_attribute7_o              in varchar2
 , p_lmm_attribute8_o              in varchar2
 , p_lmm_attribute9_o              in varchar2
 , p_lmm_attribute10_o             in varchar2
 , p_lmm_attribute11_o             in varchar2
 , p_lmm_attribute12_o             in varchar2
 , p_lmm_attribute13_o             in varchar2
 , p_lmm_attribute14_o             in varchar2
 , p_lmm_attribute15_o             in varchar2
 , p_lmm_attribute16_o             in varchar2
 , p_lmm_attribute17_o             in varchar2
 , p_lmm_attribute18_o             in varchar2
 , p_lmm_attribute19_o             in varchar2
 , p_lmm_attribute20_o             in varchar2
 , p_lmm_attribute21_o             in varchar2
 , p_lmm_attribute22_o             in varchar2
 , p_lmm_attribute23_o             in varchar2
 , p_lmm_attribute24_o             in varchar2
 , p_lmm_attribute25_o             in varchar2
 , p_lmm_attribute26_o             in varchar2
 , p_lmm_attribute27_o             in varchar2
 , p_lmm_attribute28_o             in varchar2
 , p_lmm_attribute29_o             in varchar2
 , p_lmm_attribute30_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lmm_rkd;

 

/
