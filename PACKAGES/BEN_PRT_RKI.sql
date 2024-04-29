--------------------------------------------------------
--  DDL for Package BEN_PRT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRT_RKI" AUTHID CURRENT_USER as
/* $Header: beprtrhi.pkh 120.0.12010000.1 2008/07/29 12:55:43 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_poe_rt_id                      in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_mn_poe_num                     in number
 ,p_mx_poe_num                     in number
 ,p_no_mn_poe_flag                 in varchar2
 ,p_no_mx_poe_flag                 in varchar2
 ,p_rndg_cd                        in varchar2
 ,p_rndg_rl                        in number
 ,p_poe_nnmntry_uom                in varchar2
 ,p_vrbl_rt_prfl_id                in number
 ,p_business_group_id              in number
 ,p_prt_attribute_category         in varchar2
 ,p_prt_attribute1                 in varchar2
 ,p_prt_attribute2                 in varchar2
 ,p_prt_attribute3                 in varchar2
 ,p_prt_attribute4                 in varchar2
 ,p_prt_attribute5                 in varchar2
 ,p_prt_attribute6                 in varchar2
 ,p_prt_attribute7                 in varchar2
 ,p_prt_attribute8                 in varchar2
 ,p_prt_attribute9                 in varchar2
 ,p_prt_attribute10                in varchar2
 ,p_prt_attribute11                in varchar2
 ,p_prt_attribute12                in varchar2
 ,p_prt_attribute13                in varchar2
 ,p_prt_attribute14                in varchar2
 ,p_prt_attribute15                in varchar2
 ,p_prt_attribute16                in varchar2
 ,p_prt_attribute17                in varchar2
 ,p_prt_attribute18                in varchar2
 ,p_prt_attribute19                in varchar2
 ,p_prt_attribute20                in varchar2
 ,p_prt_attribute21                in varchar2
 ,p_prt_attribute22                in varchar2
 ,p_prt_attribute23                in varchar2
 ,p_prt_attribute24                in varchar2
 ,p_prt_attribute25                in varchar2
 ,p_prt_attribute26                in varchar2
 ,p_prt_attribute27                in varchar2
 ,p_prt_attribute28                in varchar2
 ,p_prt_attribute29                in varchar2
 ,p_prt_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_cbr_dsblty_apls_flag           in varchar2
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_prt_rki;

/
