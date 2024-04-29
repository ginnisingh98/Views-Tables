--------------------------------------------------------
--  DDL for Package BEN_CPN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPN_RKU" AUTHID CURRENT_USER as
/* $Header: becpnrhi.pkh 120.0 2005/05/28 01:15:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cntng_prtn_prfl_rt_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_name                           in varchar2
 ,p_pymt_must_be_rcvd_uom          in varchar2
 ,p_pymt_must_be_rcvd_num          in number
 ,p_pymt_must_be_rcvd_rl           in number
 ,p_cpn_attribute_category         in varchar2
 ,p_cpn_attribute1                 in varchar2
 ,p_cpn_attribute2                 in varchar2
 ,p_cpn_attribute3                 in varchar2
 ,p_cpn_attribute4                 in varchar2
 ,p_cpn_attribute5                 in varchar2
 ,p_cpn_attribute6                 in varchar2
 ,p_cpn_attribute7                 in varchar2
 ,p_cpn_attribute8                 in varchar2
 ,p_cpn_attribute9                 in varchar2
 ,p_cpn_attribute10                in varchar2
 ,p_cpn_attribute11                in varchar2
 ,p_cpn_attribute12                in varchar2
 ,p_cpn_attribute13                in varchar2
 ,p_cpn_attribute14                in varchar2
 ,p_cpn_attribute15                in varchar2
 ,p_cpn_attribute16                in varchar2
 ,p_cpn_attribute17                in varchar2
 ,p_cpn_attribute18                in varchar2
 ,p_cpn_attribute19                in varchar2
 ,p_cpn_attribute20                in varchar2
 ,p_cpn_attribute21                in varchar2
 ,p_cpn_attribute22                in varchar2
 ,p_cpn_attribute23                in varchar2
 ,p_cpn_attribute24                in varchar2
 ,p_cpn_attribute25                in varchar2
 ,p_cpn_attribute26                in varchar2
 ,p_cpn_attribute27                in varchar2
 ,p_cpn_attribute28                in varchar2
 ,p_cpn_attribute29                in varchar2
 ,p_cpn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_name_o                         in varchar2
 ,p_pymt_must_be_rcvd_uom_o        in varchar2
 ,p_pymt_must_be_rcvd_num_o        in number
 ,p_pymt_must_be_rcvd_rl_o         in number
 ,p_cpn_attribute_category_o       in varchar2
 ,p_cpn_attribute1_o               in varchar2
 ,p_cpn_attribute2_o               in varchar2
 ,p_cpn_attribute3_o               in varchar2
 ,p_cpn_attribute4_o               in varchar2
 ,p_cpn_attribute5_o               in varchar2
 ,p_cpn_attribute6_o               in varchar2
 ,p_cpn_attribute7_o               in varchar2
 ,p_cpn_attribute8_o               in varchar2
 ,p_cpn_attribute9_o               in varchar2
 ,p_cpn_attribute10_o              in varchar2
 ,p_cpn_attribute11_o              in varchar2
 ,p_cpn_attribute12_o              in varchar2
 ,p_cpn_attribute13_o              in varchar2
 ,p_cpn_attribute14_o              in varchar2
 ,p_cpn_attribute15_o              in varchar2
 ,p_cpn_attribute16_o              in varchar2
 ,p_cpn_attribute17_o              in varchar2
 ,p_cpn_attribute18_o              in varchar2
 ,p_cpn_attribute19_o              in varchar2
 ,p_cpn_attribute20_o              in varchar2
 ,p_cpn_attribute21_o              in varchar2
 ,p_cpn_attribute22_o              in varchar2
 ,p_cpn_attribute23_o              in varchar2
 ,p_cpn_attribute24_o              in varchar2
 ,p_cpn_attribute25_o              in varchar2
 ,p_cpn_attribute26_o              in varchar2
 ,p_cpn_attribute27_o              in varchar2
 ,p_cpn_attribute28_o              in varchar2
 ,p_cpn_attribute29_o              in varchar2
 ,p_cpn_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cpn_rku;

 

/
