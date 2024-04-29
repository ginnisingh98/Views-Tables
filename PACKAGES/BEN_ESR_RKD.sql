--------------------------------------------------------
--  DDL for Package BEN_ESR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESR_RKD" AUTHID CURRENT_USER as
/* $Header: beesrrhi.pkh 120.0 2005/05/28 02:58:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ee_stat_rt_id                  in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_assignment_status_type_id_o    in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 ,p_esr_attribute_category_o       in varchar2
 ,p_esr_attribute1_o               in varchar2
 ,p_esr_attribute2_o               in varchar2
 ,p_esr_attribute3_o               in varchar2
 ,p_esr_attribute4_o               in varchar2
 ,p_esr_attribute5_o               in varchar2
 ,p_esr_attribute6_o               in varchar2
 ,p_esr_attribute7_o               in varchar2
 ,p_esr_attribute8_o               in varchar2
 ,p_esr_attribute9_o               in varchar2
 ,p_esr_attribute10_o              in varchar2
 ,p_esr_attribute11_o              in varchar2
 ,p_esr_attribute12_o              in varchar2
 ,p_esr_attribute13_o              in varchar2
 ,p_esr_attribute14_o              in varchar2
 ,p_esr_attribute15_o              in varchar2
 ,p_esr_attribute16_o              in varchar2
 ,p_esr_attribute17_o              in varchar2
 ,p_esr_attribute18_o              in varchar2
 ,p_esr_attribute19_o              in varchar2
 ,p_esr_attribute20_o              in varchar2
 ,p_esr_attribute21_o              in varchar2
 ,p_esr_attribute22_o              in varchar2
 ,p_esr_attribute23_o              in varchar2
 ,p_esr_attribute24_o              in varchar2
 ,p_esr_attribute25_o              in varchar2
 ,p_esr_attribute26_o              in varchar2
 ,p_esr_attribute27_o              in varchar2
 ,p_esr_attribute28_o              in varchar2
 ,p_esr_attribute29_o              in varchar2
 ,p_esr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_esr_rkd;

 

/
