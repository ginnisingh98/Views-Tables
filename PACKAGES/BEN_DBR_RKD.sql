--------------------------------------------------------
--  DDL for Package BEN_DBR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DBR_RKD" AUTHID CURRENT_USER as
/* $Header: bedbrrhi.pkh 120.0 2005/05/28 01:30:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dsbld_rt_id                    in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_dsbld_cd_o                     in varchar2
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_business_group_id_o            in number
 ,p_dbr_attribute_category_o       in varchar2
 ,p_dbr_attribute1_o               in varchar2
 ,p_dbr_attribute2_o               in varchar2
 ,p_dbr_attribute3_o               in varchar2
 ,p_dbr_attribute4_o               in varchar2
 ,p_dbr_attribute5_o               in varchar2
 ,p_dbr_attribute6_o               in varchar2
 ,p_dbr_attribute7_o               in varchar2
 ,p_dbr_attribute8_o               in varchar2
 ,p_dbr_attribute9_o               in varchar2
 ,p_dbr_attribute10_o              in varchar2
 ,p_dbr_attribute11_o              in varchar2
 ,p_dbr_attribute12_o              in varchar2
 ,p_dbr_attribute13_o              in varchar2
 ,p_dbr_attribute14_o              in varchar2
 ,p_dbr_attribute15_o              in varchar2
 ,p_dbr_attribute16_o              in varchar2
 ,p_dbr_attribute17_o              in varchar2
 ,p_dbr_attribute18_o              in varchar2
 ,p_dbr_attribute19_o              in varchar2
 ,p_dbr_attribute20_o              in varchar2
 ,p_dbr_attribute21_o              in varchar2
 ,p_dbr_attribute22_o              in varchar2
 ,p_dbr_attribute23_o              in varchar2
 ,p_dbr_attribute24_o              in varchar2
 ,p_dbr_attribute25_o              in varchar2
 ,p_dbr_attribute26_o              in varchar2
 ,p_dbr_attribute27_o              in varchar2
 ,p_dbr_attribute28_o              in varchar2
 ,p_dbr_attribute29_o              in varchar2
 ,p_dbr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dbr_rkd;

 

/
