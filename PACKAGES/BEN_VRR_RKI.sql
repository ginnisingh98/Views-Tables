--------------------------------------------------------
--  DDL for Package BEN_VRR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRR_RKI" AUTHID CURRENT_USER as
/* $Header: bevrrrhi.pkh 120.0.12010000.1 2008/07/29 13:08:42 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_vrbl_rt_rl_id                  in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_drvbl_fctr_apls_flag           in varchar2
 ,p_rt_trtmt_cd                    in varchar2
 ,p_business_group_id              in number
 ,p_formula_id                     in number
 ,p_acty_base_rt_id                in number
 ,p_ordr_to_aply_num               in number
 ,p_vrr_attribute_category         in varchar2
 ,p_vrr_attribute1                 in varchar2
 ,p_vrr_attribute2                 in varchar2
 ,p_vrr_attribute3                 in varchar2
 ,p_vrr_attribute4                 in varchar2
 ,p_vrr_attribute5                 in varchar2
 ,p_vrr_attribute6                 in varchar2
 ,p_vrr_attribute7                 in varchar2
 ,p_vrr_attribute8                 in varchar2
 ,p_vrr_attribute9                 in varchar2
 ,p_vrr_attribute10                in varchar2
 ,p_vrr_attribute11                in varchar2
 ,p_vrr_attribute12                in varchar2
 ,p_vrr_attribute13                in varchar2
 ,p_vrr_attribute14                in varchar2
 ,p_vrr_attribute15                in varchar2
 ,p_vrr_attribute16                in varchar2
 ,p_vrr_attribute17                in varchar2
 ,p_vrr_attribute18                in varchar2
 ,p_vrr_attribute19                in varchar2
 ,p_vrr_attribute20                in varchar2
 ,p_vrr_attribute21                in varchar2
 ,p_vrr_attribute22                in varchar2
 ,p_vrr_attribute23                in varchar2
 ,p_vrr_attribute24                in varchar2
 ,p_vrr_attribute25                in varchar2
 ,p_vrr_attribute26                in varchar2
 ,p_vrr_attribute27                in varchar2
 ,p_vrr_attribute28                in varchar2
 ,p_vrr_attribute29                in varchar2
 ,p_vrr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_vrr_rki;

/
