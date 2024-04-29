--------------------------------------------------------
--  DDL for Package BEN_APC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APC_RKU" AUTHID CURRENT_USER as
/* $Header: beapcrhi.pkh 120.0.12010000.1 2008/07/29 10:49:32 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_acrs_ptip_cvg_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_mx_cvg_alwd_amt                in number
 ,p_mn_cvg_alwd_amt                in number
 ,p_pgm_id                         in number
 ,p_business_group_id              in number
 ,p_apc_attribute_category         in varchar2
 ,p_apc_attribute1                 in varchar2
 ,p_apc_attribute2                 in varchar2
 ,p_apc_attribute3                 in varchar2
 ,p_apc_attribute4                 in varchar2
 ,p_apc_attribute5                 in varchar2
 ,p_apc_attribute6                 in varchar2
 ,p_apc_attribute7                 in varchar2
 ,p_apc_attribute8                 in varchar2
 ,p_apc_attribute9                 in varchar2
 ,p_apc_attribute10                in varchar2
 ,p_apc_attribute11                in varchar2
 ,p_apc_attribute12                in varchar2
 ,p_apc_attribute13                in varchar2
 ,p_apc_attribute14                in varchar2
 ,p_apc_attribute15                in varchar2
 ,p_apc_attribute16                in varchar2
 ,p_apc_attribute17                in varchar2
 ,p_apc_attribute18                in varchar2
 ,p_apc_attribute19                in varchar2
 ,p_apc_attribute20                in varchar2
 ,p_apc_attribute21                in varchar2
 ,p_apc_attribute22                in varchar2
 ,p_apc_attribute23                in varchar2
 ,p_apc_attribute24                in varchar2
 ,p_apc_attribute25                in varchar2
 ,p_apc_attribute26                in varchar2
 ,p_apc_attribute27                in varchar2
 ,p_apc_attribute28                in varchar2
 ,p_apc_attribute29                in varchar2
 ,p_apc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_mx_cvg_alwd_amt_o              in number
 ,p_mn_cvg_alwd_amt_o              in number
 ,p_pgm_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_apc_attribute_category_o       in varchar2
 ,p_apc_attribute1_o               in varchar2
 ,p_apc_attribute2_o               in varchar2
 ,p_apc_attribute3_o               in varchar2
 ,p_apc_attribute4_o               in varchar2
 ,p_apc_attribute5_o               in varchar2
 ,p_apc_attribute6_o               in varchar2
 ,p_apc_attribute7_o               in varchar2
 ,p_apc_attribute8_o               in varchar2
 ,p_apc_attribute9_o               in varchar2
 ,p_apc_attribute10_o              in varchar2
 ,p_apc_attribute11_o              in varchar2
 ,p_apc_attribute12_o              in varchar2
 ,p_apc_attribute13_o              in varchar2
 ,p_apc_attribute14_o              in varchar2
 ,p_apc_attribute15_o              in varchar2
 ,p_apc_attribute16_o              in varchar2
 ,p_apc_attribute17_o              in varchar2
 ,p_apc_attribute18_o              in varchar2
 ,p_apc_attribute19_o              in varchar2
 ,p_apc_attribute20_o              in varchar2
 ,p_apc_attribute21_o              in varchar2
 ,p_apc_attribute22_o              in varchar2
 ,p_apc_attribute23_o              in varchar2
 ,p_apc_attribute24_o              in varchar2
 ,p_apc_attribute25_o              in varchar2
 ,p_apc_attribute26_o              in varchar2
 ,p_apc_attribute27_o              in varchar2
 ,p_apc_attribute28_o              in varchar2
 ,p_apc_attribute29_o              in varchar2
 ,p_apc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_apc_rku;

/
