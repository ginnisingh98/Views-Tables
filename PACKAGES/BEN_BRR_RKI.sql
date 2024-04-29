--------------------------------------------------------
--  DDL for Package BEN_BRR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRR_RKI" AUTHID CURRENT_USER as
/* $Header: bebrrrhi.pkh 120.0.12010000.1 2008/07/29 11:01:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_bnft_vrbl_rt_rl_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_to_aply_num               in number
 ,p_cvg_amt_calc_mthd_id           in number
 ,p_formula_id                     in number
 ,p_business_group_id              in number
 ,p_brr_attribute_category         in varchar2
 ,p_brr_attribute1                 in varchar2
 ,p_brr_attribute2                 in varchar2
 ,p_brr_attribute3                 in varchar2
 ,p_brr_attribute4                 in varchar2
 ,p_brr_attribute5                 in varchar2
 ,p_brr_attribute6                 in varchar2
 ,p_brr_attribute7                 in varchar2
 ,p_brr_attribute8                 in varchar2
 ,p_brr_attribute9                 in varchar2
 ,p_brr_attribute10                in varchar2
 ,p_brr_attribute11                in varchar2
 ,p_brr_attribute12                in varchar2
 ,p_brr_attribute13                in varchar2
 ,p_brr_attribute14                in varchar2
 ,p_brr_attribute15                in varchar2
 ,p_brr_attribute16                in varchar2
 ,p_brr_attribute17                in varchar2
 ,p_brr_attribute18                in varchar2
 ,p_brr_attribute19                in varchar2
 ,p_brr_attribute20                in varchar2
 ,p_brr_attribute21                in varchar2
 ,p_brr_attribute22                in varchar2
 ,p_brr_attribute23                in varchar2
 ,p_brr_attribute24                in varchar2
 ,p_brr_attribute25                in varchar2
 ,p_brr_attribute26                in varchar2
 ,p_brr_attribute27                in varchar2
 ,p_brr_attribute28                in varchar2
 ,p_brr_attribute29                in varchar2
 ,p_brr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_brr_rki;

/
