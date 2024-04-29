--------------------------------------------------------
--  DDL for Package BEN_CBS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBS_RKD" AUTHID CURRENT_USER as
/* $Header: becbsrhi.pkh 120.0 2005/05/28 00:56:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prem_cstg_by_sgmt_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_sgmt_num_o                     in number
 ,p_sgmt_cstg_mthd_cd_o            in varchar2
 ,p_sgmt_cstg_mthd_rl_o            in number
 ,p_business_group_id_o            in number
 ,p_actl_prem_id_o                 in number
 ,p_cbs_attribute_category_o       in varchar2
 ,p_cbs_attribute1_o               in varchar2
 ,p_cbs_attribute2_o               in varchar2
 ,p_cbs_attribute3_o               in varchar2
 ,p_cbs_attribute4_o               in varchar2
 ,p_cbs_attribute5_o               in varchar2
 ,p_cbs_attribute6_o               in varchar2
 ,p_cbs_attribute7_o               in varchar2
 ,p_cbs_attribute8_o               in varchar2
 ,p_cbs_attribute9_o               in varchar2
 ,p_cbs_attribute10_o              in varchar2
 ,p_cbs_attribute11_o              in varchar2
 ,p_cbs_attribute12_o              in varchar2
 ,p_cbs_attribute13_o              in varchar2
 ,p_cbs_attribute14_o              in varchar2
 ,p_cbs_attribute15_o              in varchar2
 ,p_cbs_attribute16_o              in varchar2
 ,p_cbs_attribute17_o              in varchar2
 ,p_cbs_attribute18_o              in varchar2
 ,p_cbs_attribute19_o              in varchar2
 ,p_cbs_attribute20_o              in varchar2
 ,p_cbs_attribute21_o              in varchar2
 ,p_cbs_attribute22_o              in varchar2
 ,p_cbs_attribute23_o              in varchar2
 ,p_cbs_attribute24_o              in varchar2
 ,p_cbs_attribute25_o              in varchar2
 ,p_cbs_attribute26_o              in varchar2
 ,p_cbs_attribute27_o              in varchar2
 ,p_cbs_attribute28_o              in varchar2
 ,p_cbs_attribute29_o              in varchar2
 ,p_cbs_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cbs_rkd;

 

/
