--------------------------------------------------------
--  DDL for Package BEN_PYR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYR_RKU" AUTHID CURRENT_USER as
/* $Header: bepyrrhi.pkh 120.0.12010000.1 2008/07/29 12:59:15 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pyrl_rt_id                     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_vrbl_rt_prfl_id                in number
 ,p_payroll_id                     in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_business_group_id              in number
 ,p_pr_attribute_category          in varchar2
 ,p_pr_attribute1                  in varchar2
 ,p_pr_attribute2                  in varchar2
 ,p_pr_attribute3                  in varchar2
 ,p_pr_attribute4                  in varchar2
 ,p_pr_attribute5                  in varchar2
 ,p_pr_attribute6                  in varchar2
 ,p_pr_attribute7                  in varchar2
 ,p_pr_attribute8                  in varchar2
 ,p_pr_attribute9                  in varchar2
 ,p_pr_attribute10                 in varchar2
 ,p_pr_attribute11                 in varchar2
 ,p_pr_attribute12                 in varchar2
 ,p_pr_attribute13                 in varchar2
 ,p_pr_attribute14                 in varchar2
 ,p_pr_attribute15                 in varchar2
 ,p_pr_attribute16                 in varchar2
 ,p_pr_attribute17                 in varchar2
 ,p_pr_attribute18                 in varchar2
 ,p_pr_attribute19                 in varchar2
 ,p_pr_attribute20                 in varchar2
 ,p_pr_attribute21                 in varchar2
 ,p_pr_attribute22                 in varchar2
 ,p_pr_attribute23                 in varchar2
 ,p_pr_attribute24                 in varchar2
 ,p_pr_attribute25                 in varchar2
 ,p_pr_attribute26                 in varchar2
 ,p_pr_attribute27                 in varchar2
 ,p_pr_attribute28                 in varchar2
 ,p_pr_attribute29                 in varchar2
 ,p_pr_attribute30                 in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_payroll_id_o                   in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_business_group_id_o            in number
 ,p_pr_attribute_category_o        in varchar2
 ,p_pr_attribute1_o                in varchar2
 ,p_pr_attribute2_o                in varchar2
 ,p_pr_attribute3_o                in varchar2
 ,p_pr_attribute4_o                in varchar2
 ,p_pr_attribute5_o                in varchar2
 ,p_pr_attribute6_o                in varchar2
 ,p_pr_attribute7_o                in varchar2
 ,p_pr_attribute8_o                in varchar2
 ,p_pr_attribute9_o                in varchar2
 ,p_pr_attribute10_o               in varchar2
 ,p_pr_attribute11_o               in varchar2
 ,p_pr_attribute12_o               in varchar2
 ,p_pr_attribute13_o               in varchar2
 ,p_pr_attribute14_o               in varchar2
 ,p_pr_attribute15_o               in varchar2
 ,p_pr_attribute16_o               in varchar2
 ,p_pr_attribute17_o               in varchar2
 ,p_pr_attribute18_o               in varchar2
 ,p_pr_attribute19_o               in varchar2
 ,p_pr_attribute20_o               in varchar2
 ,p_pr_attribute21_o               in varchar2
 ,p_pr_attribute22_o               in varchar2
 ,p_pr_attribute23_o               in varchar2
 ,p_pr_attribute24_o               in varchar2
 ,p_pr_attribute25_o               in varchar2
 ,p_pr_attribute26_o               in varchar2
 ,p_pr_attribute27_o               in varchar2
 ,p_pr_attribute28_o               in varchar2
 ,p_pr_attribute29_o               in varchar2
 ,p_pr_attribute30_o               in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pyr_rku;

/
