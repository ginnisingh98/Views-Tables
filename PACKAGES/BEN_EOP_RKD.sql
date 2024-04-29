--------------------------------------------------------
--  DDL for Package BEN_EOP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EOP_RKD" AUTHID CURRENT_USER as
/* $Header: beeoprhi.pkh 120.0 2005/05/28 02:32:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ELIG_ANTHR_PL_PRTE_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_pl_id_o                        in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_eop_attribute_category_o       in varchar2
 ,p_eop_attribute1_o               in varchar2
 ,p_eop_attribute2_o               in varchar2
 ,p_eop_attribute3_o               in varchar2
 ,p_eop_attribute4_o               in varchar2
 ,p_eop_attribute5_o               in varchar2
 ,p_eop_attribute6_o               in varchar2
 ,p_eop_attribute7_o               in varchar2
 ,p_eop_attribute8_o               in varchar2
 ,p_eop_attribute9_o               in varchar2
 ,p_eop_attribute10_o              in varchar2
 ,p_eop_attribute11_o              in varchar2
 ,p_eop_attribute12_o              in varchar2
 ,p_eop_attribute13_o              in varchar2
 ,p_eop_attribute14_o              in varchar2
 ,p_eop_attribute15_o              in varchar2
 ,p_eop_attribute16_o              in varchar2
 ,p_eop_attribute17_o              in varchar2
 ,p_eop_attribute18_o              in varchar2
 ,p_eop_attribute19_o              in varchar2
 ,p_eop_attribute20_o              in varchar2
 ,p_eop_attribute21_o              in varchar2
 ,p_eop_attribute22_o              in varchar2
 ,p_eop_attribute23_o              in varchar2
 ,p_eop_attribute24_o              in varchar2
 ,p_eop_attribute25_o              in varchar2
 ,p_eop_attribute26_o              in varchar2
 ,p_eop_attribute27_o              in varchar2
 ,p_eop_attribute28_o              in varchar2
 ,p_eop_attribute29_o              in varchar2
 ,p_eop_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eop_rkd;

 

/
