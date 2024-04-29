--------------------------------------------------------
--  DDL for Package BEN_DCP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DCP_RKD" AUTHID CURRENT_USER as
/* $Header: bedcprhi.pkh 120.0 2005/05/28 01:34:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dpnt_cvrd_plip_rt_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_plip_id_o                      in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_dcp_attribute_category_o       in varchar2
 ,p_dcp_attribute1_o               in varchar2
 ,p_dcp_attribute2_o               in varchar2
 ,p_dcp_attribute3_o               in varchar2
 ,p_dcp_attribute4_o               in varchar2
 ,p_dcp_attribute5_o               in varchar2
 ,p_dcp_attribute6_o               in varchar2
 ,p_dcp_attribute7_o               in varchar2
 ,p_dcp_attribute8_o               in varchar2
 ,p_dcp_attribute9_o               in varchar2
 ,p_dcp_attribute10_o              in varchar2
 ,p_dcp_attribute11_o              in varchar2
 ,p_dcp_attribute12_o              in varchar2
 ,p_dcp_attribute13_o              in varchar2
 ,p_dcp_attribute14_o              in varchar2
 ,p_dcp_attribute15_o              in varchar2
 ,p_dcp_attribute16_o              in varchar2
 ,p_dcp_attribute17_o              in varchar2
 ,p_dcp_attribute18_o              in varchar2
 ,p_dcp_attribute19_o              in varchar2
 ,p_dcp_attribute20_o              in varchar2
 ,p_dcp_attribute21_o              in varchar2
 ,p_dcp_attribute22_o              in varchar2
 ,p_dcp_attribute23_o              in varchar2
 ,p_dcp_attribute24_o              in varchar2
 ,p_dcp_attribute25_o              in varchar2
 ,p_dcp_attribute26_o              in varchar2
 ,p_dcp_attribute27_o              in varchar2
 ,p_dcp_attribute28_o              in varchar2
 ,p_dcp_attribute29_o              in varchar2
 ,p_dcp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dcp_rkd;

 

/
