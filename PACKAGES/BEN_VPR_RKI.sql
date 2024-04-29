--------------------------------------------------------
--  DDL for Package BEN_VPR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VPR_RKI" AUTHID CURRENT_USER as
/* $Header: bevprrhi.pkh 120.0.12010000.1 2008/07/29 13:08:14 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_vrbl_rt_prfl_rl_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_formula_id                     in number
 ,p_ordr_to_aply_num               in number
 ,p_drvbl_fctr_apls_flag            in varchar2
 ,p_vpr_attribute_category         in varchar2
 ,p_vpr_attribute1                 in varchar2
 ,p_vpr_attribute2                 in varchar2
 ,p_vpr_attribute3                 in varchar2
 ,p_vpr_attribute4                 in varchar2
 ,p_vpr_attribute5                 in varchar2
 ,p_vpr_attribute6                 in varchar2
 ,p_vpr_attribute7                 in varchar2
 ,p_vpr_attribute8                 in varchar2
 ,p_vpr_attribute9                 in varchar2
 ,p_vpr_attribute10                in varchar2
 ,p_vpr_attribute11                in varchar2
 ,p_vpr_attribute12                in varchar2
 ,p_vpr_attribute13                in varchar2
 ,p_vpr_attribute14                in varchar2
 ,p_vpr_attribute15                in varchar2
 ,p_vpr_attribute16                in varchar2
 ,p_vpr_attribute17                in varchar2
 ,p_vpr_attribute18                in varchar2
 ,p_vpr_attribute19                in varchar2
 ,p_vpr_attribute20                in varchar2
 ,p_vpr_attribute21                in varchar2
 ,p_vpr_attribute22                in varchar2
 ,p_vpr_attribute23                in varchar2
 ,p_vpr_attribute24                in varchar2
 ,p_vpr_attribute25                in varchar2
 ,p_vpr_attribute26                in varchar2
 ,p_vpr_attribute27                in varchar2
 ,p_vpr_attribute28                in varchar2
 ,p_vpr_attribute29                in varchar2
 ,p_vpr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_vpr_rki;

/
